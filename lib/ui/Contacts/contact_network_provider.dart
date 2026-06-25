import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:taapdeel/utils/perf_benchmark.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../api/ps_url.dart';
import '../../config/ps_config.dart';
import '../../constant/ps_constants.dart';
import '../../db/common/ps_shared_preferences.dart';
import 'user_phone_model.dart';

/// Central manager for Taapdeel contact-network discovery.
///
/// Final flow:
/// - Before login: can request contacts permission and fetch matched Taapdeel users
///   from the phone book. Results are saved locally only to motivate the user.
/// - After login: the same provider syncs matched users to backend suggestions table.
/// - AppBar consumes only [pendingCount], [suggestions], [hasPermission], [isSyncing].
/// - AppBar never reads contacts directly.
/// - Discover no longer owns any contact discovery logic.
///
/// Sync strategy:
/// - Full sync (reads ALL phone contacts + sends them to the backend in
///   chunks) only happens at most every [_fullSyncInterval], or when the
///   on-device contact list signature changed, or when force=true.
/// - Light check (cheap, single request: sends only the locally cached
///   signature) runs at most every [_lightCheckInterval]. It tells us
///   whether new Taapdeel users matching existing contacts have appeared,
///   without re-reading or re-sending the phone book.
// ============================================================
// ✅ PERF FIX: Top-level helpers for compute() isolate
// ============================================================

/// نتيجة معالجة الكونتاكتس — قابلة للإرسال بين الـ isolates
class _ContactProcessResult {
  const _ContactProcessResult({
    required this.phones,
    required this.nameByPhone,
  });

  final List<String> phones;
  final Map<String, String> nameByPhone;
}

/// بيانات مدخل للـ isolate — بنمررها لـ compute()
class _ContactProcessInput {
  const _ContactProcessInput({
    required this.contacts,
  });

  final List<Contact> contacts;
}

/// ✅ Top-level function — compute() تحتاج top-level أو static
/// بتعمل normalize للأرقام المصرية وتبني الـ nameByPhone map
/// ده بيتشغّل في background isolate — مش على الـ main thread
_ContactProcessResult _processContactsInIsolate(_ContactProcessInput input) {
  final Set<String> phones = <String>{};
  final Map<String, String> nameByPhone = <String, String>{};

  for (final Contact c in input.contacts) {
    final String contactName = c.displayName.trim();

    for (final Phone p in c.phones) {
      final String normalized = ContactNetworkProvider.normalizeEgyptPhone(p.number);
      if (normalized.isEmpty) continue;

      phones.add(normalized);

      if (contactName.isNotEmpty) {
        nameByPhone.putIfAbsent(normalized, () => contactName);
      }
    }
  }

  return _ContactProcessResult(
    phones: phones.toList()..sort(),
    nameByPhone: nameByPhone,
  );
}

// ============================================================

class ContactNetworkProvider extends ChangeNotifier {
  ContactNetworkProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _kSuggestionsKey = 'contact_network_cached_suggestions_v2';
  static const String _kLastSyncKey = 'contact_network_last_sync_at_v2';
  static const String _kLastSignatureKey = 'contact_network_last_signature_v2';
  static const String _kLastLightCheckKey = 'contact_network_last_lightcheck_v2';
  static const String _kPermissionExplainedKey = 'contact_network_permission_explained_v2';

  /// Full sync (read contacts + send chunks) at most this often.
  static const Duration _fullSyncInterval = Duration(hours: 24);

  /// Cheap "anything new?" check at most this often.
  static const Duration _lightCheckInterval = Duration(hours: 1);

  static const Duration _apiTimeout = Duration(seconds: 35);
  static const Duration _lightCheckTimeout = Duration(seconds: 10);
  static const int _chunkSize = 180;

  static int _contactPerfSeq = 0;

  Stopwatch _contactPerfStart() => Stopwatch()..start();

  void _contactPerfLog(
    String event,
    Stopwatch sw, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    sw.stop();
    final int seq = ++_contactPerfSeq;
    final String details = data.entries
        .map((MapEntry<String, Object?> e) => '${e.key}=${e.value ?? ''}')
        .join(' ');
    dev.log(
      '[CONTACT_SYNC_PERF][$seq] $event=${sw.elapsedMilliseconds}ms${details.isEmpty ? '' : ' $details'}',
      name: 'TAAPDEEL/CONTACT_SYNC_PERF',
    );
  }

  void _contactPerfInstant(
    String event, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    final int seq = ++_contactPerfSeq;
    final String details = data.entries
        .map((MapEntry<String, Object?> e) => '${e.key}=${e.value ?? ''}')
        .join(' ');
    dev.log(
      '[CONTACT_SYNC_PERF][$seq] $event${details.isEmpty ? '' : ' $details'}',
      name: 'TAAPDEEL/CONTACT_SYNC_PERF',
    );
  }

  Set<String> _suggestionUserIds(List<UsersPhoneModel> items) {
    return items
        .map((UsersPhoneModel user) => (user.userId ?? '').trim())
        .where((String id) => id.isNotEmpty)
        .toSet();
  }

  void _markContactNetworkChangedIfNewUsers({
    required String source,
    required List<UsersPhoneModel> before,
    required List<UsersPhoneModel> after,
  }) {
    final Set<String> beforeIds = _suggestionUserIds(before);
    final Set<String> afterIds = _suggestionUserIds(after);

    final bool hasNewUsers = afterIds.any((String id) => !beforeIds.contains(id));
    if (!hasNewUsers) return;

    _contactNetworkChangeVersion++;
    _lastContactNetworkChangedAt = DateTime.now();
    _lastContactNetworkChangeReason = source;

    debugPrint(
      '[TAAPDEEL/CONTACT_NETWORK_CHANGE] '
          'version=$_contactNetworkChangeVersion source=$source '
          'before=${beforeIds.length} after=${afterIds.length}',
    );
  }

  bool _initializedForSession = false;
  bool _isSyncing = false;
  bool _isLoadingCache = false;
  bool _hasPermission = false;
  bool _permissionChecked = false;
  String _userId = '';
  DateTime? _lastSyncAt;
  DateTime? _lastLightCheckAt;
  String? _lastSignature;
  List<UsersPhoneModel> _suggestions = <UsersPhoneModel>[];
  final Map<String, String> _contactNameByPhone = <String, String>{};

  int _contactNetworkChangeVersion = 0;
  DateTime? _lastContactNetworkChangedAt;
  String _lastContactNetworkChangeReason = '';

  /// Auto contact-sync is intentionally deferred until the first recommendations
  /// request finishes. This prevents phone-book sync from competing with the
  /// ForYou opening path.
  bool _autoSyncPendingAfterRecommendations = false;
  bool _autoSyncStartedAfterRecommendations = false;
  bool _pendingAutoSyncForceAfterRecommendations = false;
  String _pendingAutoSyncReasonAfterRecommendations = '';

  bool get isSyncing => _isSyncing;
  bool get isLoadingCache => _isLoadingCache;
  bool get hasPermission => _hasPermission;
  bool get permissionChecked => _permissionChecked;
  DateTime? get lastSyncAt => _lastSyncAt;
  List<UsersPhoneModel> get suggestions => List<UsersPhoneModel>.unmodifiable(_suggestions);
  int get pendingCount => _suggestions.length;

  /// يزيد فقط عندما تنتهي مزامنة الكونتاكتس وتضيف علاقات/اقتراحات جديدة.
  /// Home/ForYou تستخدمه لإعادة تحميل الترشيحات مرة واحدة بدون تعطيل فتح الصفحة.
  int get contactNetworkChangeVersion => _contactNetworkChangeVersion;
  DateTime? get lastContactNetworkChangedAt => _lastContactNetworkChangedAt;
  String get lastContactNetworkChangeReason => _lastContactNetworkChangeReason;

  bool get isLoggedIn => _userId.isNotEmpty && _userId != 'nologinuser';

  /// The network chip should remain visible because it is a core growth feature.
  /// It can show "شبكتي" before permission/login, or "X جدد" when matches exist.
  bool get canShowNetworkChip => true;

  void _resetDeferredAutoSyncState() {
    _autoSyncPendingAfterRecommendations = false;
    _autoSyncStartedAfterRecommendations = false;
    _pendingAutoSyncForceAfterRecommendations = false;
    _pendingAutoSyncReasonAfterRecommendations = '';
  }

  bool _isAutoAppOpenReason(String reason) {
    final String r = reason.toLowerCase();
    return r.contains('app_open') || r.contains('guest_app_open');
  }

  bool _hasFreshContactSignature() {
    final bool hasSignature = (_lastSignature ?? '').trim().isNotEmpty;
    final DateTime? lastSync = _lastSyncAt;
    if (!hasSignature || lastSync == null) return false;
    return DateTime.now().difference(lastSync) < _fullSyncInterval;
  }

  void _deferAutoSyncUntilRecommendations({
    required bool force,
    required String reason,
  }) {
    // مهم جدًا: app_open لا يجب أن يتحول إلى full phone-book sync.
    // قراءة الكونتاكتس من platform channel قد تجمد الـ UI على أجهزة بها آلاف الأسماء.
    final bool safeForce = force && !_isAutoAppOpenReason(reason);

    if (_autoSyncStartedAfterRecommendations) {
      _contactPerfInstant('auto_sync_defer_skip_already_started', data: <String, Object?>{
        'reason': reason,
        'force': force,
        'safeForce': safeForce,
      });
      return;
    }

    _autoSyncPendingAfterRecommendations = true;
    _pendingAutoSyncForceAfterRecommendations =
        _pendingAutoSyncForceAfterRecommendations || safeForce;

    if (_pendingAutoSyncReasonAfterRecommendations.isEmpty || safeForce) {
      _pendingAutoSyncReasonAfterRecommendations = reason;
    }

    _contactPerfInstant('auto_sync_deferred_until_recommendations', data: <String, Object?>{
      'reason': reason,
      'force': force,
      'safeForce': safeForce,
    });

    debugPrint(
      '[TAAPDEEL/CONTACT_SYNC_DEFERRED] '
          'deferred_until_recommendations reason=$reason force=$safeForce',
    );
  }

  Future<void> startDeferredSyncAfterRecommendations({
    String? userId,
    String reason = 'recommendations_finished',
  }) async {
    final Stopwatch totalSw = _contactPerfStart();

    final String normalizedUserId = _normalizeUserId(
      userId ?? (_userId.isNotEmpty ? _userId : _readCurrentUserId()),
    );
    if (normalizedUserId.isNotEmpty) {
      _userId = normalizedUserId;
    }

    if (!isLoggedIn) {
      _contactPerfLog('auto_sync_after_recommendations_skip_not_logged_in', totalSw, data: <String, Object?>{
        'reason': reason,
      });
      return;
    }

    if (_autoSyncStartedAfterRecommendations) {
      _contactPerfLog('auto_sync_after_recommendations_skip_already_started', totalSw, data: <String, Object?>{
        'reason': reason,
      });
      return;
    }

    // Safety fallback: if initForApp did not run before HomeView, still allow
    // the first sync to start after recommendations finish.
    if (!_autoSyncPendingAfterRecommendations) {
      _autoSyncPendingAfterRecommendations = true;
      _pendingAutoSyncReasonAfterRecommendations = reason;
    }

    _autoSyncStartedAfterRecommendations = true;

    final String baseReason = _pendingAutoSyncReasonAfterRecommendations.isNotEmpty
        ? _pendingAutoSyncReasonAfterRecommendations
        : reason;
    final bool force = _pendingAutoSyncForceAfterRecommendations &&
        !_isAutoAppOpenReason(baseReason);

    _autoSyncPendingAfterRecommendations = false;
    _pendingAutoSyncForceAfterRecommendations = false;
    _pendingAutoSyncReasonAfterRecommendations = '';

    _contactPerfLog('auto_sync_start_after_recommendations', totalSw, data: <String, Object?>{
      'reason': baseReason,
      'force': force,
    });

    debugPrint(
      '[TAAPDEEL/CONTACT_SYNC_DEFERRED] '
          'start_after_recommendations reason=$baseReason force=$force',
    );

    unawaited(
      syncInBackground(
        force: force,
        reason: '${baseReason}_after_recommendations',
      ),
    );
  }

  Future<void> initForApp({String? userId, bool forceAfterLogin = false}) async {
    // ✅ BENCHMARK: وقت init كامل لنظام جهات الاتصال
    TaapdeelPerfBenchmark.start('contact_init');
    final Stopwatch totalSw = _contactPerfStart();

    final String newUserId = _normalizeUserId(userId ?? _readCurrentUserId());
    final String previousUserId = _userId;
    final bool becameLoggedIn = previousUserId.isEmpty && newUserId.isNotEmpty;
    final bool userChanged = previousUserId.isNotEmpty &&
        newUserId.isNotEmpty &&
        previousUserId != newUserId;

    if (becameLoggedIn || userChanged) {
      _resetDeferredAutoSyncState();
    }

    _userId = newUserId;

    final Stopwatch cacheSw = _contactPerfStart();
    await _loadCachedState();
    _contactPerfLog('init_load_cache', cacheSw, data: <String, Object?>{
      'suggestions': _suggestions.length,
      'hasSignature': (_lastSignature ?? '').isNotEmpty,
      'lastSync': _lastSyncAt?.toIso8601String() ?? '',
    });

    final Stopwatch permissionSw = _contactPerfStart();
    await _checkPermissionSilently();
    _contactPerfLog('init_permission_check', permissionSw, data: <String, Object?>{
      'hasPermission': _hasPermission,
      'loggedIn': isLoggedIn,
    });

    if (isLoggedIn) {
      _contactPerfInstant('init_schedule_refresh_and_defer_sync', data: <String, Object?>{
        'becameLoggedIn': becameLoggedIn,
        'forceAfterLogin': forceAfterLogin,
        'initialized': _initializedForSession,
      });
      unawaited(refreshSuggestionsFromServer());

      if (!_initializedForSession || forceAfterLogin || becameLoggedIn) {
        _initializedForSession = true;

        // Cold start with a saved user used to be treated as "becameLoggedIn",
        // which forced a full contacts read on every app open. Keep automatic
        // app-open sync cheap; full phone-book sync is reserved for real login,
        // explicit permission/manual refresh, or when there is no recent cache.
        final bool hasFreshSignature = _hasFreshContactSignature();
        final bool shouldForceDeferredSync = forceAfterLogin && !hasFreshSignature;
        final String deferredReason = shouldForceDeferredSync ? 'after_login' : 'app_open';

        _deferAutoSyncUntilRecommendations(
          force: shouldForceDeferredSync,
          reason: deferredReason,
        );
      }
    } else {
      // Guest mode: if permission already exists, show locally matched users from cache,
      // and refresh in background only when expired. This does not write to DB.
      if (_hasPermission && !_initializedForSession) {
        _initializedForSession = true;
        _contactPerfInstant('init_guest_sync_deferred_until_recommendations');
        _deferAutoSyncUntilRecommendations(
          force: false,
          reason: 'guest_app_open',
        );
      }
    }

    _contactPerfLog('init_total', totalSw, data: <String, Object?>{
      'loggedIn': isLoggedIn,
      'hasPermission': _hasPermission,
      'suggestions': _suggestions.length,
    });
    TaapdeelPerfBenchmark.end('contact_init');
  }

  /// Explicitly call this after phone login succeeds. It reuses any intro permission
  /// and defers the backend sync until the first recommendations request finishes.
  Future<void> initAfterLogin(String userId) async {
    final Stopwatch totalSw = _contactPerfStart();
    _resetDeferredAutoSyncState();
    _userId = _normalizeUserId(userId);
    _initializedForSession = true;

    final Stopwatch cacheSw = _contactPerfStart();
    await _loadCachedState();
    _contactPerfLog('after_login_load_cache', cacheSw, data: <String, Object?>{
      'suggestions': _suggestions.length,
      'hasSignature': (_lastSignature ?? '').isNotEmpty,
    });

    final Stopwatch permissionSw = _contactPerfStart();
    await _checkPermissionSilently();
    _contactPerfLog('after_login_permission_check', permissionSw, data: <String, Object?>{
      'hasPermission': _hasPermission,
      'userIdEmpty': _userId.isEmpty,
    });

    if (_userId.isEmpty) {
      notifyListeners();
      _contactPerfLog('after_login_total_empty_user', totalSw);
      return;
    }

    await refreshSuggestionsFromServer();

    if (_hasPermission) {
      _contactPerfInstant('after_login_force_sync_deferred_until_recommendations');
      _deferAutoSyncUntilRecommendations(
        force: true,
        reason: 'after_login_force',
      );
    } else {
      notifyListeners();
    }

    _contactPerfLog('after_login_total', totalSw, data: <String, Object?>{
      'hasPermission': _hasPermission,
      'suggestions': _suggestions.length,
    });
  }

  Future<void> refreshSuggestionsFromServer() async {
    if (!isLoggedIn) return;

    // ✅ BENCHMARK: وقت جلب الاقتراحات من السيرفر
    TaapdeelPerfBenchmark.start('contact_suggestions_api');
    final Stopwatch totalSw = _contactPerfStart();

    try {
      final Uri uri = _apiUri('rest/users/contact_suggestions_list/api_key/${PsConfig.ps_api_key}');
      final Stopwatch httpSw = _contactPerfStart();
      final http.Response res = await _client.post(
        uri,
        body: <String, String>{'user_id': _userId},
      ).timeout(const Duration(seconds: 15));
      _contactPerfLog('suggestions_list_http', httpSw, data: <String, Object?>{
        'status': res.statusCode,
        'bytes': res.bodyBytes.length,
        'serverMs': res.headers['x-taapdeel-contact-server-ms'] ?? res.headers['x-taapdeel-server-ms'] ?? '',
        'req': res.headers['x-taapdeel-contact-req'] ?? res.headers['x-taapdeel-request-id'] ?? '',
      });

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _contactPerfLog('suggestions_list_total_bad_status', totalSw, data: <String, Object?>{
          'status': res.statusCode,
        });
        TaapdeelPerfBenchmark.end('contact_suggestions_api');
        return;
      }

      final Stopwatch decodeSw = _contactPerfStart();
      final dynamic decoded = jsonDecode(res.body);
      _contactPerfLog('suggestions_list_json_decode', decodeSw);

      final Stopwatch parseSw = _contactPerfStart();
      final List<UsersPhoneModel> parsed = _parseUsersList(decoded);
      _contactPerfLog('suggestions_list_parse_users', parseSw, data: <String, Object?>{
        'parsed': parsed.length,
      });

      final Stopwatch mergeSw = _contactPerfStart();
      _suggestions = _mergeUnique(parsed, _suggestions);
      _contactPerfLog('suggestions_list_merge', mergeSw, data: <String, Object?>{
        'result': _suggestions.length,
      });

      final Stopwatch cacheSw = _contactPerfStart();
      await _saveCachedSuggestions(_suggestions);
      _contactPerfLog('suggestions_list_save_cache', cacheSw, data: <String, Object?>{
        'items': _suggestions.length,
      });

      _contactPerfLog('suggestions_list_total', totalSw, data: <String, Object?>{
        'items': _suggestions.length,
      });
      TaapdeelPerfBenchmark.end('contact_suggestions_api');
      notifyListeners();
    } catch (e, st) {
      _contactPerfLog('suggestions_list_total_error', totalSw, data: <String, Object?>{
        'error': e.runtimeType,
      });
      TaapdeelPerfBenchmark.end('contact_suggestions_api');
      dev.log('refreshSuggestionsFromServer failed', name: 'TAAPDEEL/CONTACT_NETWORK', error: e, stackTrace: st);
    }
  }

  /// Called from Intro CTA, AppBar chip, or bottom sheet permission panel.
  /// Works both before and after login:
  /// - guest: local matching only
  /// - logged in: local matching + DB suggestions storage
  Future<bool> requestPermissionAndSync({bool force = true, String reason = 'explicit_permission'}) async {
    final Stopwatch totalSw = _contactPerfStart();
    _userId = _normalizeUserId(_userId.isNotEmpty ? _userId : _readCurrentUserId());

    final Stopwatch explainSw = _contactPerfStart();
    await PsSharedPreferences.instance.shared.setBool(_kPermissionExplainedKey, true);
    _contactPerfLog('permission_explained_save', explainSw);

    final Stopwatch requestSw = _contactPerfStart();
    final bool granted = await FlutterContacts.requestPermission(readonly: true);
    _contactPerfLog('permission_request', requestSw, data: <String, Object?>{
      'granted': granted,
      'reason': reason,
    });

    _hasPermission = granted;
    _permissionChecked = true;
    notifyListeners();

    if (!_hasPermission) {
      _contactPerfLog('permission_and_sync_total_denied', totalSw, data: <String, Object?>{
        'reason': reason,
      });
      return false;
    }

    await syncInBackground(force: force, reason: reason);
    _contactPerfLog('permission_and_sync_total', totalSw, data: <String, Object?>{
      'reason': reason,
      'force': force,
    });
    return true;
  }

  /// Main entry point for keeping the contact network up to date.
  ///
  /// - `force == true`: always perform a full sync (read contacts, compute
  ///   signature, send chunks to backend). Use this only right after the
  ///   permission was first granted, or right after login.
  /// - `force == false`: cheap path. Only performs a full sync if it is
  ///   genuinely due ([_fullSyncInterval] elapsed or no signature stored
  ///   yet). Otherwise, performs at most a lightweight "anything new?"
  ///   check every [_lightCheckInterval], which does NOT read the phone
  ///   book and sends only a tiny signature string.
  Future<void> syncInBackground({bool force = false, String reason = 'unknown'}) async {
    final Stopwatch totalSw = _contactPerfStart();

    if (_isSyncing) {
      _contactPerfLog('sync_skip_already_running', totalSw, data: <String, Object?>{
        'reason': reason,
      });
      return;
    }

    _userId = _normalizeUserId(_userId.isNotEmpty ? _userId : _readCurrentUserId());

    final Stopwatch permissionSw = _contactPerfStart();
    await _checkPermissionSilently();
    _contactPerfLog('sync_permission_check', permissionSw, data: <String, Object?>{
      'reason': reason,
      'hasPermission': _hasPermission,
      'loggedIn': isLoggedIn,
    });

    if (!_hasPermission) {
      _contactPerfLog('sync_skip_no_permission', totalSw, data: <String, Object?>{
        'reason': reason,
      });
      return;
    }

    // ✅ BENCHMARK: وقت مزامنة جهات الاتصال كاملاً (قراءة + hash + API chunks)
    TaapdeelPerfBenchmark.start('contact_sync_$reason');

    final bool fullSyncDue = _lastSyncAt == null ||
        DateTime.now().difference(_lastSyncAt!) >= _fullSyncInterval;

    _contactPerfInstant('sync_decision', data: <String, Object?>{
      'reason': reason,
      'force': force,
      'fullSyncDue': fullSyncDue,
      'hasSignature': (_lastSignature ?? '').isNotEmpty,
      'lastSync': _lastSyncAt?.toIso8601String() ?? '',
      'lastLightCheck': _lastLightCheckAt?.toIso8601String() ?? '',
    });

    final bool autoAppOpenReason = _isAutoAppOpenReason(reason);

    if (!force && autoAppOpenReason) {
      // Automatic app-open sync must never read the full phone book.
      // FlutterContacts.getContacts(withProperties: true) can freeze UI for seconds
      // on large address books. Use only server-side light check/cache here.
      if ((_lastSignature ?? '').trim().isNotEmpty && _shouldLightCheckNow()) {
        final Stopwatch lightSw = _contactPerfStart();
        await _runLightCheck(reason: reason);
        _contactPerfLog('sync_auto_app_open_lightcheck_path', lightSw, data: <String, Object?>{
          'reason': reason,
        });
      } else {
        _contactPerfInstant('sync_auto_app_open_skip_full_read', data: <String, Object?>{
          'reason': reason,
          'hasSignature': (_lastSignature ?? '').trim().isNotEmpty,
          'lightCheckDue': _shouldLightCheckNow(),
        });
      }
      _contactPerfLog('sync_total_auto_app_open_light_or_skip', totalSw, data: <String, Object?>{
        'reason': reason,
      });
      TaapdeelPerfBenchmark.end('contact_sync_$reason');
      return;
    }

    if (!force && !fullSyncDue) {
      if (_lastSignature != null && _shouldLightCheckNow()) {
        final Stopwatch lightSw = _contactPerfStart();
        await _runLightCheck(reason: reason);
        _contactPerfLog('sync_lightcheck_path', lightSw, data: <String, Object?>{
          'reason': reason,
        });
      } else {
        _contactPerfInstant('sync_skip_not_due', data: <String, Object?>{
          'reason': reason,
          'lightCheckDue': _shouldLightCheckNow(),
        });
      }
      _contactPerfLog('sync_total_light_or_skip', totalSw, data: <String, Object?>{
        'reason': reason,
      });
      TaapdeelPerfBenchmark.end('contact_sync_$reason');
      return;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final Stopwatch readSw = _contactPerfStart();
      final List<String> phones = await _readNormalizedContactPhones();
      _contactPerfLog('sync_read_contacts_total', readSw, data: <String, Object?>{
        'reason': reason,
        'phones': phones.length,
      });

      if (phones.isEmpty) {
        final Stopwatch saveEmptySw = _contactPerfStart();
        await _saveLastSync(DateTime.now());
        _contactPerfLog('sync_save_empty_last_sync', saveEmptySw);
        _contactPerfLog('sync_total_empty_contacts', totalSw, data: <String, Object?>{
          'reason': reason,
        });
        return;
      }

      final Stopwatch signatureSw = _contactPerfStart();
      final String signature = _buildSignature(phones);
      final bool sameContacts = signature == _lastSignature;
      final bool expired = _lastSyncAt == null || DateTime.now().difference(_lastSyncAt!) >= _fullSyncInterval;
      _contactPerfLog('sync_signature_build', signatureSw, data: <String, Object?>{
        'phones': phones.length,
        'sameContacts': sameContacts,
        'expired': expired,
      });

      // Even if contacts did not change, we still sync when expired because new users may have joined.
      if (!force && sameContacts && !expired) {
        _contactPerfLog('sync_skip_same_contacts_not_expired', totalSw, data: <String, Object?>{
          'reason': reason,
          'phones': phones.length,
        });
        return;
      }

      final List<UsersPhoneModel> merged = <UsersPhoneModel>[];
      final Set<String> seen = <String>{};
      final int totalChunks = (phones.length / _chunkSize).ceil();

      final Stopwatch chunksTotalSw = _contactPerfStart();
      for (int i = 0; i < phones.length; i += _chunkSize) {
        final int end = (i + _chunkSize).clamp(0, phones.length);
        final int chunkIndex = (i ~/ _chunkSize) + 1;
        final List<String> chunk = phones.sublist(i, end);
        final Stopwatch chunkSw = _contactPerfStart();
        final List<UsersPhoneModel> part = isLoggedIn
            ? await _syncChunkLoggedIn(
                chunk,
                signature: signature,
                chunkIndex: chunkIndex,
                totalChunks: totalChunks,
              )
            : await _matchChunkGuest(
                chunk,
                chunkIndex: chunkIndex,
                totalChunks: totalChunks,
              );
        _contactPerfLog('sync_chunk_total', chunkSw, data: <String, Object?>{
          'reason': reason,
          'chunk': '$chunkIndex/$totalChunks',
          'phones': chunk.length,
          'matches': part.length,
          'loggedIn': isLoggedIn,
        });

        for (final UsersPhoneModel u in part) {
          final String id = (u.userId ?? '').trim();
          if (id.isEmpty || seen.contains(id)) continue;
          seen.add(id);
          merged.add(u);
        }
      }
      _contactPerfLog('sync_all_chunks_total', chunksTotalSw, data: <String, Object?>{
        'reason': reason,
        'chunks': totalChunks,
        'merged': merged.length,
      });

      final Stopwatch mergeSw = _contactPerfStart();
      final List<UsersPhoneModel> suggestionsBeforeSync = List<UsersPhoneModel>.from(_suggestions);
      _suggestions = _mergeUnique(merged, <UsersPhoneModel>[]);
      _markContactNetworkChangedIfNewUsers(
        source: 'full_sync_$reason',
        before: suggestionsBeforeSync,
        after: _suggestions,
      );
      _lastSignature = signature;
      _contactPerfLog('sync_merge_unique', mergeSw, data: <String, Object?>{
        'input': merged.length,
        'suggestions': _suggestions.length,
      });

      final Stopwatch saveSuggestionsSw = _contactPerfStart();
      await _saveCachedSuggestions(_suggestions);
      _contactPerfLog('sync_save_cached_suggestions', saveSuggestionsSw, data: <String, Object?>{
        'items': _suggestions.length,
      });

      final Stopwatch saveLastSyncSw = _contactPerfStart();
      await _saveLastSync(DateTime.now());
      _contactPerfLog('sync_save_last_sync', saveLastSyncSw);

      final Stopwatch saveLightSw = _contactPerfStart();
      await _saveLastLightCheck(DateTime.now());
      _contactPerfLog('sync_save_last_lightcheck', saveLightSw);

      final Stopwatch saveSignatureSw = _contactPerfStart();
      await PsSharedPreferences.instance.shared.setString(_kLastSignatureKey, signature);
      _contactPerfLog('sync_save_signature', saveSignatureSw);

      notifyListeners();
      _contactPerfLog('sync_total_full', totalSw, data: <String, Object?>{
        'reason': reason,
        'phones': phones.length,
        'chunks': totalChunks,
        'suggestions': _suggestions.length,
      });
    } catch (e, st) {
      _contactPerfLog('sync_total_error', totalSw, data: <String, Object?>{
        'reason': reason,
        'error': e.runtimeType,
      });
      dev.log('syncInBackground failed reason=$reason', name: 'TAAPDEEL/CONTACT_NETWORK', error: e, stackTrace: st);
    } finally {
      TaapdeelPerfBenchmark.end('contact_sync_$reason');
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Cheap check: sends only the locally cached signature. The backend
  /// tells us whether:
  /// - the signature no longer matches what it has on file (meaning the
  ///   on-device contact list likely changed since the last full sync,
  ///   or no full sync has happened yet) -> we clear lastSyncAt so the
  ///   next syncInBackground() call performs a full sync.
  /// - there are new pending suggestions for contacts we already matched
  ///   -> merge them into _suggestions immediately, no full sync needed.
  Future<void> _runLightCheck({String reason = 'unknown'}) async {
    final Stopwatch totalSw = _contactPerfStart();
    if (!isLoggedIn) {
      _contactPerfLog('lightcheck_skip_not_logged_in', totalSw, data: <String, Object?>{
        'reason': reason,
      });
      return;
    }

    final String? signature = _lastSignature;
    if (signature == null || signature.isEmpty) {
      _contactPerfLog('lightcheck_skip_no_signature', totalSw, data: <String, Object?>{
        'reason': reason,
      });
      return;
    }

    try {
      final Uri uri = _apiUri('rest/users/contact_suggestions_lightcheck/api_key/${PsConfig.ps_api_key}');
      final Stopwatch httpSw = _contactPerfStart();
      final http.Response res = await _client.post(
        uri,
        body: <String, String>{
          'user_id': _userId,
          'signature': signature,
        },
      ).timeout(_lightCheckTimeout);
      _contactPerfLog('lightcheck_http', httpSw, data: <String, Object?>{
        'reason': reason,
        'status': res.statusCode,
        'bytes': res.bodyBytes.length,
        'serverMs': res.headers['x-taapdeel-contact-server-ms'] ?? res.headers['x-taapdeel-server-ms'] ?? '',
        'req': res.headers['x-taapdeel-contact-req'] ?? res.headers['x-taapdeel-request-id'] ?? '',
      });

      final Stopwatch saveLightSw = _contactPerfStart();
      await _saveLastLightCheck(DateTime.now());
      _contactPerfLog('lightcheck_save_last_check', saveLightSw);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _contactPerfLog('lightcheck_total_bad_status', totalSw, data: <String, Object?>{
          'reason': reason,
          'status': res.statusCode,
        });
        return;
      }

      final Stopwatch decodeSw = _contactPerfStart();
      final dynamic decoded = jsonDecode(res.body);
      _contactPerfLog('lightcheck_json_decode', decodeSw);

      if (decoded is! Map || decoded['status'] != 'success') {
        _contactPerfLog('lightcheck_total_bad_payload', totalSw, data: <String, Object?>{
          'reason': reason,
        });
        return;
      }

      final bool signatureMatch = decoded['signature_match'] == true;
      _contactPerfInstant('lightcheck_signature_result', data: <String, Object?>{
        'reason': reason,
        'signatureMatch': signatureMatch,
      });

      if (!signatureMatch) {
        // On-device contacts likely changed since the last full sync (or
        // the server has no record yet). Force a full sync next time.
        _lastSyncAt = null;
        final Stopwatch removeSw = _contactPerfStart();
        await PsSharedPreferences.instance.shared.remove(_kLastSyncKey);
        _contactPerfLog('lightcheck_remove_last_sync', removeSw);
        _contactPerfLog('lightcheck_total_signature_mismatch', totalSw, data: <String, Object?>{
          'reason': reason,
        });
        return;
      }

      final dynamic newMatchesRaw = decoded['new_matches'];
      final int newRawCount = newMatchesRaw is List ? newMatchesRaw.length : 0;
      if (newMatchesRaw is List && newMatchesRaw.isNotEmpty) {
        final Stopwatch parseSw = _contactPerfStart();
        final List<UsersPhoneModel> newMatches = _parseUsersList(<String, dynamic>{'data': newMatchesRaw});
        _contactPerfLog('lightcheck_parse_new_matches', parseSw, data: <String, Object?>{
          'raw': newRawCount,
          'parsed': newMatches.length,
        });
        if (newMatches.isNotEmpty) {
          final Stopwatch mergeSw = _contactPerfStart();
          final List<UsersPhoneModel> suggestionsBeforeLightCheck = List<UsersPhoneModel>.from(_suggestions);
          _suggestions = _mergeUnique(newMatches, _suggestions);
          _markContactNetworkChangedIfNewUsers(
            source: 'lightcheck_$reason',
            before: suggestionsBeforeLightCheck,
            after: _suggestions,
          );
          _contactPerfLog('lightcheck_merge_new_matches', mergeSw, data: <String, Object?>{
            'suggestions': _suggestions.length,
          });
          final Stopwatch cacheSw = _contactPerfStart();
          await _saveCachedSuggestions(_suggestions);
          _contactPerfLog('lightcheck_save_cache', cacheSw, data: <String, Object?>{
            'items': _suggestions.length,
          });
          notifyListeners();
        }
      }

      _contactPerfLog('lightcheck_total', totalSw, data: <String, Object?>{
        'reason': reason,
        'signatureMatch': signatureMatch,
        'newRaw': newRawCount,
        'suggestions': _suggestions.length,
      });
    } catch (e, st) {
      _contactPerfLog('lightcheck_total_error', totalSw, data: <String, Object?>{
        'reason': reason,
        'error': e.runtimeType,
      });
      dev.log('lightCheck failed reason=$reason', name: 'TAAPDEEL/CONTACT_NETWORK', error: e, stackTrace: st);
    }
  }

  Future<void> markUsersHandled(Iterable<String> userIds, {String status = 'followed'}) async {
    final Set<String> ids = userIds.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
    if (ids.isEmpty) return;

    _suggestions.removeWhere((u) => ids.contains((u.userId ?? '').trim()));
    await _saveCachedSuggestions(_suggestions);
    notifyListeners();

    if (!isLoggedIn) return;

    for (final String id in ids) {
      unawaited(_markSuggestionStatus(id, status));
    }
  }

  Future<void> dismissUser(String userId) async {
    final String id = userId.trim();
    if (id.isEmpty) return;
    _suggestions.removeWhere((u) => (u.userId ?? '').trim() == id);
    await _saveCachedSuggestions(_suggestions);
    notifyListeners();

    if (isLoggedIn) {
      unawaited(_markSuggestionStatus(id, 'dismissed'));
    }
  }

  Future<void> _markSuggestionStatus(String suggestedUserId, String status) async {
    if (!isLoggedIn) return;

    try {
      final Uri uri = _apiUri('rest/users/contact_suggestion_status/api_key/${PsConfig.ps_api_key}');
      await _client.post(uri, body: <String, String>{
        'user_id': _userId,
        'suggested_user_id': suggestedUserId,
        'status': status,
      }).timeout(const Duration(seconds: 12));
    } catch (_) {}
  }

  Future<List<UsersPhoneModel>> _syncChunkLoggedIn(
    List<String> phones, {
    required String signature,
    int chunkIndex = 1,
    int totalChunks = 1,
  }) async {
    final Uri uri = _apiUri('rest/users/contact_suggestions_sync/api_key/${PsConfig.ps_api_key}');
    final Stopwatch httpSw = _contactPerfStart();
    final http.Response res = await _client.post(
      uri,
      body: <String, String>{
        'user_id': _userId,
        'phone_numbers': phones.join(','),
        'signature': signature,
      },
    ).timeout(_apiTimeout);
    _contactPerfLog('sync_chunk_logged_http', httpSw, data: <String, Object?>{
      'chunk': '$chunkIndex/$totalChunks',
      'phones': phones.length,
      'status': res.statusCode,
      'bytes': res.bodyBytes.length,
      'serverMs': res.headers['x-taapdeel-contact-server-ms'] ?? res.headers['x-taapdeel-server-ms'] ?? '',
      'req': res.headers['x-taapdeel-contact-req'] ?? res.headers['x-taapdeel-request-id'] ?? '',
    });

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Contact sync failed: ${res.statusCode}');
    }

    final Stopwatch decodeSw = _contactPerfStart();
    final dynamic decoded = jsonDecode(res.body);
    _contactPerfLog('sync_chunk_logged_json_decode', decodeSw, data: <String, Object?>{
      'chunk': '$chunkIndex/$totalChunks',
    });

    final Stopwatch parseSw = _contactPerfStart();
    final List<UsersPhoneModel> parsed = _parseUsersList(decoded);
    _contactPerfLog('sync_chunk_logged_parse_users', parseSw, data: <String, Object?>{
      'chunk': '$chunkIndex/$totalChunks',
      'parsed': parsed.length,
    });
    return parsed;
  }

  /// Guest mode matching. It uses the old compare-by-phone endpoint only for
  /// returning matched Taapdeel users. Nothing is written to bs_contact_suggestions.
  Future<List<UsersPhoneModel>> _matchChunkGuest(
    List<String> phones, {
    int chunkIndex = 1,
    int totalChunks = 1,
  }) async {
    final String url = '${PsConfig.ps_app_url}${PsUrl.ps_get_users_by_phone_url}';
    final Stopwatch httpSw = _contactPerfStart();
    final http.Response res = await _client.post(
      Uri.parse(url),
      body: <String, String>{
        'phone_numbers': phones.join(','),
        'user_id': '',
      },
    ).timeout(_apiTimeout);
    _contactPerfLog('sync_chunk_guest_http', httpSw, data: <String, Object?>{
      'chunk': '$chunkIndex/$totalChunks',
      'phones': phones.length,
      'status': res.statusCode,
      'bytes': res.bodyBytes.length,
      'serverMs': res.headers['x-taapdeel-contact-server-ms'] ?? res.headers['x-taapdeel-server-ms'] ?? '',
      'req': res.headers['x-taapdeel-contact-req'] ?? res.headers['x-taapdeel-request-id'] ?? '',
    });

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Guest contact match failed: ${res.statusCode}');
    }

    final Stopwatch decodeSw = _contactPerfStart();
    final dynamic decoded = jsonDecode(res.body);
    _contactPerfLog('sync_chunk_guest_json_decode', decodeSw, data: <String, Object?>{
      'chunk': '$chunkIndex/$totalChunks',
    });

    final Stopwatch parseSw = _contactPerfStart();
    final List<UsersPhoneModel> parsed = _parseUsersList(decoded);
    _contactPerfLog('sync_chunk_guest_parse_users', parseSw, data: <String, Object?>{
      'chunk': '$chunkIndex/$totalChunks',
      'parsed': parsed.length,
    });
    return parsed;
  }

  List<UsersPhoneModel> _parseUsersList(dynamic decoded) {
    dynamic payload = decoded;
    if (decoded is Map) {
      payload = decoded['data'] ?? decoded['users'] ?? decoded['suggestions'] ?? decoded['result'] ?? decoded['new_matches'];
    }
    if (payload is! List) return <UsersPhoneModel>[];

    final List<UsersPhoneModel> parsed = payload
        .whereType<Map>()
        .map((e) => UsersPhoneModel.fromJson(Map<String, dynamic>.from(e)))
        .where((u) => (u.userId ?? '').trim().isNotEmpty)
        .toList();

    return _attachLocalContactNames(parsed);
  }

  List<UsersPhoneModel> _attachLocalContactNames(List<UsersPhoneModel> users) {
    if (_contactNameByPhone.isEmpty || users.isEmpty) return users;

    for (final UsersPhoneModel u in users) {
      if ((u.localContactName ?? '').trim().isNotEmpty) continue;

      final List<String> possiblePhones = <String>[
        u.userPhone ?? '',
        u.whatsapp ?? '',
        u.phoneId ?? '',
      ];

      for (final String raw in possiblePhones) {
        final String normalized = normalizeEgyptPhone(raw);
        if (normalized.isEmpty) continue;
        final String? contactName = _contactNameByPhone[normalized];
        if (contactName != null && contactName.trim().isNotEmpty) {
          u.localContactName = contactName.trim();
          break;
        }
      }
    }

    return users;
  }

  List<UsersPhoneModel> _mergeUnique(
      List<UsersPhoneModel> first,
      List<UsersPhoneModel> second,
      ) {
    final List<UsersPhoneModel> out = <UsersPhoneModel>[];
    final Map<String, UsersPhoneModel> byId = <String, UsersPhoneModel>{};

    for (final UsersPhoneModel u in <UsersPhoneModel>[...first, ...second]) {
      final String id = (u.userId ?? '').trim();
      if (id.isEmpty) continue;

      final UsersPhoneModel? existing = byId[id];
      if (existing == null) {
        byId[id] = u;
        out.add(u);
        continue;
      }

      // Preserve the phone-book name from cache/local matching when the fresh
      // server response does not contain it.
      if ((existing.localContactName ?? '').trim().isEmpty &&
          (u.localContactName ?? '').trim().isNotEmpty) {
        existing.localContactName = u.localContactName;
      }

      if ((existing.userProfilePhoto ?? '').trim().isEmpty &&
          (u.userProfilePhoto ?? '').trim().isNotEmpty) {
        existing.userProfilePhoto = u.userProfilePhoto;
      }
    }

    return out;
  }

  Future<List<String>> _readNormalizedContactPhones() async {
    TaapdeelPerfBenchmark.start('contacts_read_phone');
    final Stopwatch totalSw = _contactPerfStart();

    // ✅ STEP 1: Permission check (main isolate — لازم)
    final Stopwatch permissionSw = _contactPerfStart();
    final bool granted = await FlutterContacts.requestPermission(readonly: true);
    _contactPerfLog('contacts_permission_request_inside_read', permissionSw, data: <String, Object?>{
      'granted': granted,
    });
    if (!granted) {
      TaapdeelPerfBenchmark.end('contacts_read_phone');
      _contactPerfLog('contacts_read_total_denied', totalSw);
      return <String>[];
    }

    // ✅ STEP 2: قراءة الكونتاكتس من الـ platform (main isolate — لازم)
    // Platform channels مش بتشتغل في background isolate
    // deduplicateProperties: false أسرع بدون deduplication overhead
    TaapdeelPerfBenchmark.start('contacts_platform_read');
    final Stopwatch platformSw = _contactPerfStart();
    final List<Contact> contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
      withThumbnail: false,
      deduplicateProperties: false,
    );
    _contactPerfLog('contacts_platform_read', platformSw, data: <String, Object?>{
      'contacts': contacts.length,
    });
    TaapdeelPerfBenchmark.end('contacts_platform_read');

    if (contacts.isEmpty) {
      TaapdeelPerfBenchmark.end('contacts_read_phone');
      _contactPerfLog('contacts_read_total_empty', totalSw);
      return <String>[];
    }

    int rawPhonesCount = 0;
    for (final Contact c in contacts) {
      rawPhonesCount += c.phones.length;
    }
    _contactPerfInstant('contacts_raw_stats', data: <String, Object?>{
      'contacts': contacts.length,
      'rawPhones': rawPhonesCount,
    });

    // ✅ STEP 3: معالجة الكونتاكتس في background isolate
    // هنا بيحصل normalize للأرقام والبحث فيها — ده CPU-intensive
    // compute() بينقله لـ isolate منفصل ويحرّر الـ main thread للـ UI
    TaapdeelPerfBenchmark.start('contacts_process_isolate');
    final Stopwatch isolateSw = _contactPerfStart();
    final _ContactProcessResult result = await compute(
      _processContactsInIsolate,
      _ContactProcessInput(contacts: contacts),
    );
    _contactPerfLog('contacts_process_isolate', isolateSw, data: <String, Object?>{
      'normalizedPhones': result.phones.length,
      'names': result.nameByPhone.length,
    });
    TaapdeelPerfBenchmark.end('contacts_process_isolate');

    // ✅ STEP 4: تحديث الـ name map على الـ main isolate
    final Stopwatch nameMapSw = _contactPerfStart();
    _contactNameByPhone
      ..clear()
      ..addAll(result.nameByPhone);
    _contactPerfLog('contacts_update_name_map', nameMapSw, data: <String, Object?>{
      'names': _contactNameByPhone.length,
    });

    dev.log(
      'contacts_read_phone: ${result.phones.length} phones from ${contacts.length} contacts',
      name: 'TAAPDEEL/CONTACT_NETWORK',
    );

    TaapdeelPerfBenchmark.end('contacts_read_phone');
    _contactPerfLog('contacts_read_total', totalSw, data: <String, Object?>{
      'contacts': contacts.length,
      'rawPhones': rawPhonesCount,
      'normalizedPhones': result.phones.length,
    });
    return result.phones;
  }

  static String normalizeEgyptPhone(String raw) {
    String digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) digits = digits.substring(1);
    if (digits.startsWith('00')) digits = digits.substring(2);

    if (digits.startsWith('20') && digits.length == 12) {
      digits = '0${digits.substring(2)}';
    } else if (digits.startsWith('20') && digits.length == 13) {
      digits = '0${digits.substring(2)}';
    }

    if (digits.length == 11 && digits.startsWith('01')) return digits;
    return '';
  }

  bool _shouldLightCheckNow() {
    if (_lastLightCheckAt == null) return true;
    return DateTime.now().difference(_lastLightCheckAt!) >= _lightCheckInterval;
  }

  Future<void> _checkPermissionSilently() async {
    final Stopwatch sw = _contactPerfStart();
    final PermissionStatus status = await Permission.contacts.status;
    _hasPermission = status.isGranted;
    _permissionChecked = true;
    _contactPerfLog('permission_status_silent', sw, data: <String, Object?>{
      'status': status.toString(),
      'granted': _hasPermission,
    });
    notifyListeners();
  }

  Future<void> _loadCachedState() async {
    final Stopwatch totalSw = _contactPerfStart();
    _isLoadingCache = true;
    notifyListeners();
    try {
      final prefs = PsSharedPreferences.instance.shared;
      final Stopwatch prefsSw = _contactPerfStart();
      _lastSyncAt = DateTime.tryParse(prefs.getString(_kLastSyncKey) ?? '');
      _lastLightCheckAt = DateTime.tryParse(prefs.getString(_kLastLightCheckKey) ?? '');
      _lastSignature = prefs.getString(_kLastSignatureKey);
      final String raw = prefs.getString(_kSuggestionsKey) ?? '';
      _contactPerfLog('cache_read_prefs', prefsSw, data: <String, Object?>{
        'rawChars': raw.length,
        'hasSignature': (_lastSignature ?? '').isNotEmpty,
      });
      if (raw.trim().isNotEmpty) {
        final Stopwatch decodeSw = _contactPerfStart();
        final dynamic decoded = jsonDecode(raw);
        _contactPerfLog('cache_json_decode', decodeSw);
        if (decoded is List) {
          final Stopwatch parseSw = _contactPerfStart();
          _suggestions = decoded
              .whereType<Map>()
              .map((e) => UsersPhoneModel.fromJson(Map<String, dynamic>.from(e)))
              .where((u) => (u.userId ?? '').trim().isNotEmpty)
              .toList();
          _contactPerfLog('cache_parse_users', parseSw, data: <String, Object?>{
            'items': _suggestions.length,
          });
        }
      }
    } catch (e) {
      _suggestions = <UsersPhoneModel>[];
      _contactPerfInstant('cache_load_error', data: <String, Object?>{
        'error': e.runtimeType,
      });
    } finally {
      _isLoadingCache = false;
      notifyListeners();
      _contactPerfLog('cache_load_total', totalSw, data: <String, Object?>{
        'items': _suggestions.length,
      });
    }
  }

  Future<void> _saveCachedSuggestions(List<UsersPhoneModel> items) async {
    final Stopwatch encodeSw = _contactPerfStart();
    final String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    _contactPerfLog('cache_save_json_encode', encodeSw, data: <String, Object?>{
      'items': items.length,
      'chars': encoded.length,
    });

    final Stopwatch writeSw = _contactPerfStart();
    await PsSharedPreferences.instance.shared.setString(
      _kSuggestionsKey,
      encoded,
    );
    _contactPerfLog('cache_save_write_prefs', writeSw, data: <String, Object?>{
      'items': items.length,
    });
  }

  Future<void> _saveLastSync(DateTime value) async {
    _lastSyncAt = value;
    await PsSharedPreferences.instance.shared.setString(_kLastSyncKey, value.toIso8601String());
  }

  Future<void> _saveLastLightCheck(DateTime value) async {
    _lastLightCheckAt = value;
    await PsSharedPreferences.instance.shared.setString(_kLastLightCheckKey, value.toIso8601String());
  }

  String _readCurrentUserId() {
    return PsSharedPreferences.instance.shared.getString(PsConst.VALUE_HOLDER__USER_ID) ?? '';
  }

  static String _normalizeUserId(String raw) {
    final String s = raw.trim();
    if (s.isEmpty || s.toLowerCase() == 'nologinuser') return '';
    return s;
  }

  Uri _apiUri(String path) {
    final String base = PsConfig.ps_app_url.trim().endsWith('/')
        ? PsConfig.ps_app_url.trim()
        : '${PsConfig.ps_app_url.trim()}/';
    return Uri.parse('$base$path');
  }

  static String _buildSignature(List<String> phones) {
    int hash = 0x811c9dc5;
    for (final String p in phones) {
      for (final int unit in p.codeUnits) {
        hash ^= unit;
        hash = (hash * 0x01000193) & 0xffffffff;
      }
      hash ^= 124; // '|'
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return '${phones.length}:$hash';
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
