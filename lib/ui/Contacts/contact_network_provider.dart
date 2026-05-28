import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

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
class ContactNetworkProvider extends ChangeNotifier {
  ContactNetworkProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _kSuggestionsKey = 'contact_network_cached_suggestions_v2';
  static const String _kLastSyncKey = 'contact_network_last_sync_at_v2';
  static const String _kLastSignatureKey = 'contact_network_last_signature_v2';
  static const String _kPermissionExplainedKey = 'contact_network_permission_explained_v2';

  static const Duration _syncInterval = Duration(hours: 2);
  static const Duration _apiTimeout = Duration(seconds: 35);
  static const int _chunkSize = 180;

  bool _initializedForSession = false;
  bool _isSyncing = false;
  bool _isLoadingCache = false;
  bool _hasPermission = false;
  bool _permissionChecked = false;
  String _userId = '';
  DateTime? _lastSyncAt;
  String? _lastSignature;
  List<UsersPhoneModel> _suggestions = <UsersPhoneModel>[];
  final Map<String, String> _contactNameByPhone = <String, String>{};

  bool get isSyncing => _isSyncing;
  bool get isLoadingCache => _isLoadingCache;
  bool get hasPermission => _hasPermission;
  bool get permissionChecked => _permissionChecked;
  DateTime? get lastSyncAt => _lastSyncAt;
  List<UsersPhoneModel> get suggestions => List<UsersPhoneModel>.unmodifiable(_suggestions);
  int get pendingCount => _suggestions.length;

  bool get isLoggedIn => _userId.isNotEmpty && _userId != 'nologinuser';

  /// The network chip should remain visible because it is a core growth feature.
  /// It can show "شبكتي" before permission/login, or "X جدد" when matches exist.
  bool get canShowNetworkChip => true;

  Future<void> initForApp({String? userId, bool forceAfterLogin = false}) async {
    final String newUserId = _normalizeUserId(userId ?? _readCurrentUserId());
    final bool becameLoggedIn = _userId.isEmpty && newUserId.isNotEmpty;

    _userId = newUserId;

    await _loadCachedState();
    await _checkPermissionSilently();

    if (isLoggedIn) {
      unawaited(refreshSuggestionsFromServer());

      if (!_initializedForSession || forceAfterLogin || becameLoggedIn) {
        _initializedForSession = true;
        unawaited(
          syncInBackground(
            force: forceAfterLogin || becameLoggedIn,
            reason: becameLoggedIn ? 'after_login' : 'app_open',
          ),
        );
      }
    } else {
      // Guest mode: if permission already exists, show locally matched users from cache,
      // and refresh in background only when expired. This does not write to DB.
      if (_hasPermission && !_initializedForSession) {
        _initializedForSession = true;
        unawaited(syncInBackground(reason: 'guest_app_open'));
      }
    }
  }

  /// Explicitly call this after phone login succeeds. It reuses any intro permission
  /// and immediately syncs to backend so the DB suggestions table becomes populated.
  Future<void> initAfterLogin(String userId) async {
    _userId = _normalizeUserId(userId);
    _initializedForSession = true;

    await _loadCachedState();
    await _checkPermissionSilently();

    if (_userId.isEmpty) {
      notifyListeners();
      return;
    }

    await refreshSuggestionsFromServer();

    if (_hasPermission) {
      unawaited(syncInBackground(force: true, reason: 'after_login_force'));
    } else {
      notifyListeners();
    }
  }

  Future<void> refreshSuggestionsFromServer() async {
    if (!isLoggedIn) return;

    try {
      final Uri uri = _apiUri('rest/users/contact_suggestions_list/api_key/${PsConfig.ps_api_key}');
      final http.Response res = await _client.post(
        uri,
        body: <String, String>{'user_id': _userId},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode < 200 || res.statusCode >= 300) return;
      final dynamic decoded = jsonDecode(res.body);
      final List<UsersPhoneModel> parsed = _parseUsersList(decoded);

      _suggestions = _mergeUnique(parsed, _suggestions);
      await _saveCachedSuggestions(_suggestions);
      notifyListeners();
    } catch (e, st) {
      dev.log('refreshSuggestionsFromServer failed', name: 'TAAPDEEL/CONTACT_NETWORK', error: e, stackTrace: st);
    }
  }

  /// Called from Intro CTA, AppBar chip, or bottom sheet permission panel.
  /// Works both before and after login:
  /// - guest: local matching only
  /// - logged in: local matching + DB suggestions storage
  Future<bool> requestPermissionAndSync({bool force = true, String reason = 'explicit_permission'}) async {
    _userId = _normalizeUserId(_userId.isNotEmpty ? _userId : _readCurrentUserId());

    await PsSharedPreferences.instance.shared.setBool(_kPermissionExplainedKey, true);

    final bool granted = await FlutterContacts.requestPermission(readonly: true);
    _hasPermission = granted;
    _permissionChecked = true;
    notifyListeners();

    if (!_hasPermission) return false;

    await syncInBackground(force: force, reason: reason);
    return true;
  }

  Future<void> syncInBackground({bool force = false, String reason = 'unknown'}) async {
    if (_isSyncing) return;

    _userId = _normalizeUserId(_userId.isNotEmpty ? _userId : _readCurrentUserId());

    await _checkPermissionSilently();
    if (!_hasPermission) return;

    if (!force && !_shouldSyncNow()) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final List<String> phones = await _readNormalizedContactPhones();
      if (phones.isEmpty) {
        await _saveLastSync(DateTime.now());
        return;
      }

      final String signature = _buildSignature(phones);
      final bool sameContacts = signature == _lastSignature;
      final bool expired = _lastSyncAt == null || DateTime.now().difference(_lastSyncAt!) >= _syncInterval;

      // Even if contacts did not change, we still sync when expired because new users may have joined.
      if (!force && sameContacts && !expired) return;

      final List<UsersPhoneModel> merged = <UsersPhoneModel>[];
      final Set<String> seen = <String>{};

      for (int i = 0; i < phones.length; i += _chunkSize) {
        final int end = (i + _chunkSize).clamp(0, phones.length);
        final List<String> chunk = phones.sublist(i, end);
        final List<UsersPhoneModel> part = isLoggedIn
            ? await _syncChunkLoggedIn(chunk)
            : await _matchChunkGuest(chunk);

        for (final UsersPhoneModel u in part) {
          final String id = (u.userId ?? '').trim();
          if (id.isEmpty || seen.contains(id)) continue;
          seen.add(id);
          merged.add(u);
        }
      }

      _suggestions = _mergeUnique(merged, <UsersPhoneModel>[]);
      _lastSignature = signature;

      await _saveCachedSuggestions(_suggestions);
      await _saveLastSync(DateTime.now());
      await PsSharedPreferences.instance.shared.setString(_kLastSignatureKey, signature);
      notifyListeners();
    } catch (e, st) {
      dev.log('syncInBackground failed reason=$reason', name: 'TAAPDEEL/CONTACT_NETWORK', error: e, stackTrace: st);
    } finally {
      _isSyncing = false;
      notifyListeners();
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

  Future<List<UsersPhoneModel>> _syncChunkLoggedIn(List<String> phones) async {
    final Uri uri = _apiUri('rest/users/contact_suggestions_sync/api_key/${PsConfig.ps_api_key}');
    final http.Response res = await _client.post(
      uri,
      body: <String, String>{
        'user_id': _userId,
        'phone_numbers': phones.join(','),
      },
    ).timeout(_apiTimeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Contact sync failed: ${res.statusCode}');
    }

    final dynamic decoded = jsonDecode(res.body);
    return _parseUsersList(decoded);
  }

  /// Guest mode matching. It uses the old compare-by-phone endpoint only for
  /// returning matched Taapdeel users. Nothing is written to bs_contact_suggestions.
  Future<List<UsersPhoneModel>> _matchChunkGuest(List<String> phones) async {
    final String url = '${PsConfig.ps_app_url}${PsUrl.ps_get_users_by_phone_url}';
    final http.Response res = await _client.post(
      Uri.parse(url),
      body: <String, String>{
        'phone_numbers': phones.join(','),
        'user_id': '',
      },
    ).timeout(_apiTimeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Guest contact match failed: ${res.statusCode}');
    }

    final dynamic decoded = jsonDecode(res.body);
    return _parseUsersList(decoded);
  }

  List<UsersPhoneModel> _parseUsersList(dynamic decoded) {
    dynamic payload = decoded;
    if (decoded is Map) {
      payload = decoded['data'] ?? decoded['users'] ?? decoded['suggestions'] ?? decoded['result'];
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
    final bool granted = await FlutterContacts.requestPermission(readonly: true);
    if (!granted) return <String>[];

    final List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
    final Set<String> phones = <String>{};
    _contactNameByPhone.clear();

    for (final Contact c in contacts) {
      final String contactName = c.displayName.trim();
      for (final Phone p in c.phones) {
        final String normalized = normalizeEgyptPhone(p.number);
        if (normalized.isEmpty) continue;
        phones.add(normalized);

        if (contactName.isNotEmpty) {
          // Keep the first phone-book name found for this number.
          _contactNameByPhone.putIfAbsent(normalized, () => contactName);
        }
      }
    }

    final List<String> out = phones.toList()..sort();
    return out;
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

  bool _shouldSyncNow() {
    if (_lastSyncAt == null) return true;
    return DateTime.now().difference(_lastSyncAt!) >= _syncInterval;
  }

  Future<void> _checkPermissionSilently() async {
    final PermissionStatus status = await Permission.contacts.status;
    _hasPermission = status.isGranted;
    _permissionChecked = true;
    notifyListeners();
  }

  Future<void> _loadCachedState() async {
    _isLoadingCache = true;
    notifyListeners();
    try {
      final prefs = PsSharedPreferences.instance.shared;
      _lastSyncAt = DateTime.tryParse(prefs.getString(_kLastSyncKey) ?? '');
      _lastSignature = prefs.getString(_kLastSignatureKey);
      final String raw = prefs.getString(_kSuggestionsKey) ?? '';
      if (raw.trim().isNotEmpty) {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is List) {
          _suggestions = decoded
              .whereType<Map>()
              .map((e) => UsersPhoneModel.fromJson(Map<String, dynamic>.from(e)))
              .where((u) => (u.userId ?? '').trim().isNotEmpty)
              .toList();
        }
      }
    } catch (_) {
      _suggestions = <UsersPhoneModel>[];
    } finally {
      _isLoadingCache = false;
      notifyListeners();
    }
  }

  Future<void> _saveCachedSuggestions(List<UsersPhoneModel> items) async {
    await PsSharedPreferences.instance.shared.setString(
      _kSuggestionsKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveLastSync(DateTime value) async {
    _lastSyncAt = value;
    await PsSharedPreferences.instance.shared.setString(_kLastSyncKey, value.toIso8601String());
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
