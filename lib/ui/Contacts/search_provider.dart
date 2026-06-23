import 'dart:convert';
import 'dart:developer' as dev;
import 'package:taapdeel/utils/perf_benchmark.dart';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../api/ps_url.dart';
import '../../../../config/ps_config.dart';
import '../../../../constant/ps_constants.dart';
import '../../../../db/common/ps_shared_preferences.dart';
import '../../../../viewobject/product.dart';
import 'user_phone_model.dart';

String _short(Object? v, {int max = 400}) {
  final s = (v ?? '').toString();
  if (s.length <= max) return s;
  return '${s.substring(0, max)}...';
}

void tlog(String tag, String msg, {Object? err, StackTrace? st}) {
  dev.log(msg, name: 'TAAPDEEL/$tag', error: err, stackTrace: st);
}

class SearchProvider extends ChangeNotifier {
  // ✅ FIX: persistent HTTP client — يُنشأ مرة واحدة، يستخدم keep-alive تلقائياً
  final http.Client _client = http.Client();

  static SearchProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<SearchProvider>(context, listen: listen);
  }

  // =============================
  // Constants
  // =============================
  // Home sections must not block the UI for 30 seconds.
  // Keep recommendations quality untouched; this only bounds section/network waits.
  static const int _defaultTimeoutSeconds = 15;
  static const int _networkItemsTimeoutSeconds = 20;

  static bool _isNoRecordMessage(String msg) {
    final s = msg.toLowerCase();
    return s.contains('10001') ||
        s.contains('record not found') ||
        s.contains('no record');
  }

  static String _normalizeUserId(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    if (s.toLowerCase() == 'nologinuser') return '';
    return s;
  }

  String _myUserId() {
    final raw =
        PsSharedPreferences.instance.shared.getString(PsConst.VALUE_HOLDER__USER_ID) ?? '';
    return _normalizeUserId(raw);
  }

  String _locationId() {
    return (PsSharedPreferences.instance.shared.get(PsConst.VALUE_HOLDER__LOCATION_ID) ?? '')
        .toString();
  }

  String _townshipId() {
    return (PsSharedPreferences.instance.shared.get(PsConst.VALUE_HOLDER__LOCATION_TOWNSHIP_ID) ??
        '')
        .toString();
  }

  String _headerValue(http.Response response, String key) {
    return response.headers[key.toLowerCase()] ??
        response.headers[key] ??
        response.headers[key.toUpperCase()] ??
        '';
  }

  @override
  void dispose() {
    // ✅ FIX: أغلق الـ client لما الـ provider يتdispose
    _client.close();
    super.dispose();
  }

  // =============================
  // Products Pagination State (VIEW ALL)
  // =============================
  List<Product> filteredProductsList = <Product>[];

  int _offset = 0;
  int _pageSize = 10;
  bool hasMore = true;

  bool filteredProd = false;
  bool loadingMore = false;

  String _currentFilterUrl = PsUrl.ps_premium_url;
  String _currentCatId = '';

  // =============================
  // Sections State (HOME SECTIONS)
  // =============================
  final Map<String, List<Product>> _sectionProducts = <String, List<Product>>{};
  final Map<String, bool> _sectionLoading = <String, bool>{};
  final Map<String, int> _sectionOffsets = <String, int>{};
  final Map<String, bool> _sectionHasMore = <String, bool>{};
  final Map<String, bool> _sectionLoadingMore = <String, bool>{};
  final Map<String, bool> _sectionRequested = <String, bool>{};
  final Map<String, int> _sectionRequestTokens = <String, int>{};
  int _sectionRequestSequence = 0;

  // ✅ جديد: Sub-categories لكل section
  final Map<String, List<SectionSubCatItem>> _sectionSubCats = <String, List<SectionSubCatItem>>{};
  final Map<String, String> _sectionSelectedSubCat = <String, String>{};

  // Cache لفحص هل التصنيف يحتوي على منتجات داخل سيكشن معين.
  final Map<String, bool> _categoryHasProductsCache = <String, bool>{};

  List<Product> sectionProducts(String url) => _sectionProducts[url] ?? <Product>[];
  bool sectionLoading(String url) => _sectionLoading[url] ?? false;
  bool sectionHasMore(String url) => _sectionHasMore[url] ?? true;
  bool sectionLoadingMore(String url) => _sectionLoadingMore[url] ?? false;
  bool sectionRequested(String url) => _sectionRequested[url] ?? false;

  /// ✅ جديد: قراءة الـ sub-categories المشتقة من المنتجات الموجودة
  List<SectionSubCatItem> sectionSubCats(String url) => _sectionSubCats[url] ?? <SectionSubCatItem>[];
  String sectionSelectedSubCat(String url) => _sectionSelectedSubCat[url] ?? '';

  /// ✅ جديد: تغيير الـ sub-category المختارة وفلترة محلية
  void selectSectionSubCat(String url, String subCatId) {
    _sectionSelectedSubCat[url] = subCatId;
    notifyListeners();
  }

  /// المنتجات بعد الفلترة بالـ category المختارة
  List<Product> sectionFilteredProducts(String url) {
    final all = _sectionProducts[url] ?? <Product>[];
    final selected = _sectionSelectedSubCat[url] ?? '';
    if (selected.isEmpty) return all;
    return all.where((p) {
      final dynamic d = p;
      try {
        final String catId = (d.catId ?? d.cat_id ?? '').toString().trim();
        return catId == selected;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  /// بناء الـ category chips من المنتجات المحملة
  void _rebuildSubCats(String url) {
    final all = _sectionProducts[url] ?? <Product>[];
    final Map<String, String> seen = <String, String>{};

    for (final Product p in all) {
      final dynamic d = p;
      try {
        // cat_id مباشرة من الـ product
        final String catId = (d.catId ?? d.cat_id ?? '').toString().trim();
        if (catId.isEmpty) continue;

        // الاسم من category.cat_name — nested object في الـ product
        String catName = '';
        try {
          final dynamic cat = d.category;
          if (cat != null) {
            catName = (cat.catName ?? cat.cat_name ?? cat['cat_name'] ?? '').toString().trim();
          }
        } catch (_) {}

        // fallback لو مفيش nested object
        if (catName.isEmpty) {
          try {
            catName = (d.catName ?? d.cat_name ?? '').toString().trim();
          } catch (_) {}
        }

        if (!seen.containsKey(catId)) {
          seen[catId] = catName.isNotEmpty ? catName : catId;
        }
      } catch (_) {}
    }

    // لو في category واحدة بس — مفيش داعي للـ chips
    if (seen.length <= 1) {
      _sectionSubCats[url] = <SectionSubCatItem>[];
      return;
    }

    final list = seen.entries
        .map((e) => SectionSubCatItem(id: e.key, name: e.value))
        .toList();

    _sectionSubCats[url] = list;
  }

  void markSectionRequested(String url) {
    if (_sectionRequested[url] == true) return;
    _sectionRequested[url] = true;
  }

  void clearSection(String url) {
    _sectionProducts.remove(url);
    _sectionLoading.remove(url);
    _sectionOffsets.remove(url);
    _sectionHasMore.remove(url);
    _sectionLoadingMore.remove(url);
    _sectionRequested.remove(url);
    _sectionSubCats.remove(url);
    _sectionSelectedSubCat.remove(url);
    notifyListeners();
  }

  void clearSections() {
    _sectionProducts.clear();
    _sectionLoading.clear();
    _sectionOffsets.clear();
    _sectionHasMore.clear();
    _sectionLoadingMore.clear();
    _sectionRequested.clear();
    _sectionRequestTokens.clear();
    _sectionRequestSequence++;
    _sectionSubCats.clear();
    _sectionSelectedSubCat.clear();
    _categoryHasProductsCache.clear();
    notifyListeners();
  }

  // =============================
  // Public API (View All List)
  // =============================
  Future<void> getFilteredProducts({
    String filterUrl = PsUrl.ps_premium_url,
    String catId = '',
    int pageSize = 10,
  }) async {
    _currentFilterUrl = filterUrl;
    _currentCatId = catId;

    _pageSize = pageSize;
    _offset = 0;
    hasMore = true;

    filteredProd = true;
    loadingMore = false;
    filteredProductsList = <Product>[];
    notifyListeners();

    try {
      final firstPage = await _fetchProducts(
        filterUrl: filterUrl,
        catId: catId,
        limit: _pageSize,
        offset: _offset,
      );

      filteredProductsList = firstPage;
      filteredProd = false;

      if (firstPage.length < _pageSize) {
        hasMore = false;
      } else {
        _offset += _pageSize;
      }
    } catch (e) {
      filteredProd = false;
      Fluttertoast.showToast(msg: e.toString());
    }

    notifyListeners();
  }

  Future<void> loadMoreFilteredProducts({
    String? filterUrl,
    String? catId,
  }) async {
    final urlToUse = filterUrl ?? _currentFilterUrl;
    final catToUse = catId ?? _currentCatId;

    if (filteredProd) return;
    if (loadingMore) return;
    if (!hasMore) return;
    loadingMore = true;
    notifyListeners();

    try {
      final nextPage = await _fetchProducts(
        filterUrl: urlToUse,
        catId: catToUse,
        limit: _pageSize,
        offset: _offset,
      );

      filteredProductsList.addAll(nextPage);

      if (nextPage.length < _pageSize) {
        hasMore = false;
      } else {
        _offset += _pageSize;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      loadingMore = false;
      notifyListeners();
    }
  }

  // =============================
  // Public API (Home Sections)
  // =============================

  Future<void> loadSection({
    required String filterUrl,
    required String catId,
    int pageSize = 8,
  }) async {
    final String perfTag = 'section_${filterUrl.split('/').last}';
    final int requestToken = ++_sectionRequestSequence;
    _sectionRequestTokens[filterUrl] = requestToken;

    TaapdeelPerfBenchmark.start(perfTag);

    _sectionLoading[filterUrl] = true;
    _sectionOffsets[filterUrl] = 0;
    _sectionHasMore[filterUrl] = true;
    _sectionLoadingMore[filterUrl] = false;
    markSectionRequested(filterUrl);
    notifyListeners();

    try {
      final res = await _fetchProducts(
        filterUrl: filterUrl,
        catId: catId,
        limit: pageSize,
        offset: 0,
      );

      // Ignore stale response from a previous tab/category selection.
      if (_sectionRequestTokens[filterUrl] != requestToken) return;

      _sectionProducts[filterUrl] = List<Product>.from(res);
      _rebuildSubCats(filterUrl);

      if (res.length < pageSize) {
        _sectionHasMore[filterUrl] = false;
        _sectionOffsets[filterUrl] = res.length;
      } else {
        _sectionOffsets[filterUrl] = pageSize;
        _sectionHasMore[filterUrl] = true;
      }
    } catch (e) {
      // Do not delete already visible data because one refresh timed out.
      _sectionProducts.putIfAbsent(filterUrl, () => <Product>[]);
      if ((_sectionProducts[filterUrl] ?? <Product>[]).isEmpty) {
        _sectionHasMore[filterUrl] = false;
      }
      tlog('SECTION_ERR', 'loadSection error for $filterUrl: $e');
    } finally {
      if (_sectionRequestTokens[filterUrl] == requestToken) {
        _sectionLoading[filterUrl] = false;
        TaapdeelPerfBenchmark.end(perfTag);
        notifyListeners();
      } else {
        TaapdeelPerfBenchmark.end(perfTag);
      }
    }
  }

  Future<void> loadMoreSection({
    required String filterUrl,
    required String catId,
    int pageSize = 8,
  }) async {
    markSectionRequested(filterUrl);

    if (sectionLoading(filterUrl)) return;
    if (sectionLoadingMore(filterUrl)) return;
    if (!sectionHasMore(filterUrl)) return;

    // ✅ BENCHMARK: وقت تحميل الصفحة التالية (pagination)
    final String _perfTag = 'more_${filterUrl.split('/').last}';
    TaapdeelPerfBenchmark.start(_perfTag);

    _sectionLoadingMore[filterUrl] = true;
    notifyListeners();

    try {
      final offset = _sectionOffsets[filterUrl] ?? 0;

      final nextPage = await _fetchProducts(
        filterUrl: filterUrl,
        catId: catId,
        limit: pageSize,
        offset: offset,
      );

      if (nextPage.isEmpty) {
        _sectionHasMore[filterUrl] = false;
        return;
      }

      final current = List<Product>.from(_sectionProducts[filterUrl] ?? <Product>[]);
      final existingIds = current.map((p) => (p.id ?? '').toString()).toSet();

      final uniqueNext = nextPage.where((p) {
        final id = (p.id ?? '').toString();
        return id.isNotEmpty && !existingIds.contains(id);
      }).toList();

      current.addAll(uniqueNext);
      _sectionProducts[filterUrl] = current;
      _rebuildSubCats(filterUrl); // ✅ تحديث الـ sub-cats مع البيانات الجديدة

      if (nextPage.length < pageSize) {
        _sectionHasMore[filterUrl] = false;
      } else {
        _sectionOffsets[filterUrl] = offset + pageSize;
        _sectionHasMore[filterUrl] = true;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _sectionLoadingMore[filterUrl] = false;
      TaapdeelPerfBenchmark.end(_perfTag);
      notifyListeners();
    }
  }

  Future<void> loadInitialSection({
    required String filterUrl,
    required String catId,
    int pageSize = 20,
  }) async {
    await loadSection(filterUrl: filterUrl, catId: catId, pageSize: pageSize);
  }

  void preloadOtherSections({
    required String currentUrl,
    required String catId,
    required bool isLoggedIn,
    int pageSize = 20,
  }) {
    final List<String> urlsToPreload = [
      PsUrl.ps_premium_url,
      PsUrl.ps_brands_url,
      PsUrl.ps_explore_url,
      if (isLoggedIn) PsUrl.ps_family_network_items_url,
    ].where((u) => u != currentUrl).toList();

    int index = 0;
    for (final url in urlsToPreload) {
      final bool alreadyLoaded = sectionRequested(url) &&
          !sectionLoading(url) &&
          sectionProducts(url).isNotEmpty;
      if (alreadyLoaded) continue;

      final Duration delay = Duration(milliseconds: 450 * index++);
      Future<void>.delayed(delay, () {
        loadSection(filterUrl: url, catId: catId, pageSize: pageSize)
            .catchError((_) {});
      });
    }
  }

  Future<void> refreshFriendsFamilyAll({int pageSize = 30}) async {
    final myId = _myUserId();
    if (myId.isEmpty) return;

    await Future.wait([
      loadSection(filterUrl: PsUrl.ps_friends_network_items_url, catId: '', pageSize: pageSize),
      loadSection(filterUrl: PsUrl.ps_family_network_items_url, catId: '', pageSize: pageSize),
    ]);
  }

  Future<bool> sectionCategoryHasProducts({
    required String filterUrl,
    required String catId,
    int probeLimit = 1,
  }) async {
    final String cleanCatId = catId.trim();
    if (cleanCatId.isEmpty) return true;

    // ✅ BENCHMARK: وقت probe كل category (هيظهر الفرق مع Future.wait fix)
    TaapdeelPerfBenchmark.start('probe_cat_$cleanCatId');

    final String cacheKey =
        '$filterUrl::$cleanCatId::${_locationId()}::${_townshipId()}';

    final bool? cached = _categoryHasProductsCache[cacheKey];
    if (cached != null) {
      TaapdeelPerfBenchmark.end('probe_cat_$cleanCatId'); // cache hit — instant
      return cached;
    }

    try {
      final List<Product> products = await _fetchProducts(
        filterUrl: filterUrl,
        catId: cleanCatId,
        limit: probeLimit,
        offset: 0,
      );

      final bool hasProducts = products.isNotEmpty;
      _categoryHasProductsCache[cacheKey] = hasProducts;
      TaapdeelPerfBenchmark.end('probe_cat_$cleanCatId');
      return hasProducts;
    } catch (e, st) {
      tlog(
        'CAT_PROBE_ERR',
        'Failed to probe category products filterUrl=$filterUrl catId=$cleanCatId',
        err: e,
        st: st,
      );

      // UX: لا نخزن false عند timeout/network error، لأن هذا أخفى تصنيفات
      // بها منتجات في Explore مثل الألعاب. في حالة عدم اليقين، أظهر التصنيف
      // واترك تحميل المنتجات عند اختياره يحدد النتيجة.
      _categoryHasProductsCache.remove(cacheKey);
      TaapdeelPerfBenchmark.end('probe_cat_$cleanCatId');
      return true;
    }
  }

  // =============================
  // Internal Fetch
  // =============================

  bool _isFriendsOrFamily(String filterUrl) {
    return filterUrl == PsUrl.ps_friends_network_items_url ||
        filterUrl == PsUrl.ps_family_network_items_url;
  }


  String _extractServerMessage(dynamic parsed, String fallback) {
    try {
      if (parsed is Map) {
        final m = parsed['message']?.toString();
        if (m != null && m.trim().isNotEmpty) return m;
      }
      if (parsed is String && parsed.trim().isNotEmpty) return parsed;
    } catch (_) {}
    return fallback;
  }

  Future<List<Product>> _fetchProducts({
    required String filterUrl,
    required String catId,
    required int limit,
    required int offset,
  }) async {
    final loginUserId = _myUserId();

    final appUrl = PsConfig.ps_app_url;
    final apiKey = PsConfig.ps_api_key;

    final isFF = _isFriendsOrFamily(filterUrl);

    final bool filterUrlHasApiKey = filterUrl.contains('/api_key/');
    final String cleanFilterUrl = filterUrl.endsWith('/')
        ? filterUrl.substring(0, filterUrl.length - 1)
        : filterUrl;

    final String url = isFF
        ? '$appUrl$cleanFilterUrl/api_key/$apiKey'
        : filterUrlHasApiKey
            ? '$appUrl$cleanFilterUrl/limit/$limit/offset/$offset/login_user_id/$loginUserId'
            : '$appUrl$cleanFilterUrl/api_key/$apiKey/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    final Map<String, String> body = <String, String>{
      'item_location_id': _locationId(),
      'item_location_township_id': _townshipId(),
      'cat_id': catId,
    };

    if (isFF) {
      body['user_id'] = loginUserId;
      body['limit'] = limit.toString();
      body['offset'] = offset.toString();
    }

    final String reqId = DateTime.now().microsecondsSinceEpoch.toString();
    final sw = Stopwatch()..start();

    tlog(
      'NET_REQ',
      '[$reqId] POST url=$url\n'
          'filterUrl=$filterUrl isFF=$isFF\n'
          'loginUserId="$loginUserId" catId="$catId" limit=$limit offset=$offset\n'
          'body=$body',
    );

    http.Response response;
    try {
      // ✅ FIX: استخدام _client المشترك — keep-alive تلقائي
      final int timeoutSecs = isFF ? _networkItemsTimeoutSeconds : _defaultTimeoutSeconds;
      response = await _client
          .post(Uri.parse(url), body: body)
          .timeout(Duration(seconds: timeoutSecs));
    } catch (e, st) {
      sw.stop();
      tlog(
        'NET_ERR',
        '[$reqId] EXCEPTION after ${sw.elapsedMilliseconds}ms url=$url\nbody=$body',
        err: e,
        st: st,
      );
      rethrow;
    }

    sw.stop();
    final raw = response.body;

    final String serverReqId = _headerValue(response, 'x-taapdeel-request-id');
    final String serverMs = _headerValue(response, 'x-taapdeel-server-ms');

    tlog(
      'NET_RES',
      '[$reqId] status=${response.statusCode} time=${sw.elapsedMilliseconds}ms '
          'server_ms=$serverMs server_req=$serverReqId url=$url\n'
          'resp=${_short(raw, max: 600)}',
    );

    if (response.statusCode != 200) {
      if (raw.trim().isEmpty) {
        tlog('NET_ERR', '[$reqId] status=${response.statusCode} empty body — returning []');
        return <Product>[];
      }

      dynamic parsedErr;
      try {
        parsedErr = json.decode(raw);
      } catch (_) {
        parsedErr = raw;
      }

      final msg = _extractServerMessage(parsedErr, 'Server error: ${response.statusCode}');

      if (_isNoRecordMessage(msg)) {
        return <Product>[];
      }

      if (response.statusCode >= 500) {
        tlog('NET_ERR', '[$reqId] Server 5xx — returning [] silently');
        return <Product>[];
      }

      throw Exception('Server ${response.statusCode}: $msg');
    }

    dynamic parsed;
    try {
      parsed = json.decode(raw);
    } catch (_) {
      throw Exception('Invalid JSON response');
    }

    if (parsed is Map) {
      final msg = parsed['message']?.toString() ?? '';
      if (_isNoRecordMessage(msg)) return <Product>[];
      if (msg.trim().isNotEmpty) throw Exception(msg);
      throw Exception('Unexpected response format');
    }

    if (parsed is! List) {
      throw Exception('Unexpected response format');
    }

    return parsed
        .where((e) => e != null && e is Map)
        .map<Product>((e) => Product().fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // =============================
  // Contacts / Phone users
  // =============================

  bool getUserPhoneLoading = false;
  List<UsersPhoneModel> usersPhone = <UsersPhoneModel>[];

  DateTime? _contactsLastLoadedAt;
  static const Duration _contactsCacheDuration = Duration(minutes: 10);

  bool get isContactsCacheValid {
    if (_contactsLastLoadedAt == null) return false;
    return DateTime.now().difference(_contactsLastLoadedAt!) < _contactsCacheDuration;
  }

  Future<void> getMyContactUser(String contactNumbers) async {
    if (contactNumbers.trim().isEmpty) {
      tlog('CONTACTS_API_SKIP', 'contactNumbers is empty — skipping API call');
      return;
    }

    usersPhone = <UsersPhoneModel>[];
    getUserPhoneLoading = true;
    notifyListeners();

    final String myId = _myUserId();
    final String apiUrl = '${PsConfig.ps_app_url}${PsUrl.ps_get_users_by_phone_url}';

    tlog('CONTACTS_API_REQ', 'sending phones = $contactNumbers , user_id = $myId');

    try {
      // ✅ FIX: استخدام _client المشترك
      final http.Response response = await _client
          .post(
        Uri.parse(apiUrl),
        body: {
          'phone_numbers': contactNumbers,
          'user_id': myId,
        },
      )
          .timeout(const Duration(seconds: _defaultTimeoutSeconds));



      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          usersPhone = decoded.map((e) => UsersPhoneModel.fromJson(e)).toList();
        } else {
          usersPhone = <UsersPhoneModel>[];
        }
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e, st) {
      tlog('CONTACTS_API_ERR', e.toString(), err: e, st: st);
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      getUserPhoneLoading = false;
      notifyListeners();
    }
  }

  List<Contact> contacts = <Contact>[];
  String contactNumbers = '';

  Future<void> askPermissions(BuildContext context) async {
    if (isContactsCacheValid && usersPhone.isNotEmpty) {
      tlog('CONTACTS_CACHE', 'Using cached contacts — skipping reload');
      return;
    }

    final bool permissionOk = await _getContactPermission();

    if (!permissionOk) {
      _handleInvalidPermissions(context);
      return;
    }

    contacts = await FlutterContacts.getContacts(withProperties: true);

    try {
      final List<String> phoneList = contacts
          .where((c) => c.phones.isNotEmpty)
          .expand((c) => c.phones)
          .map((phone) {
        final String cleaned = phone.number
            .replaceAll(RegExp(r'\s'), '')
            .replaceAll('+2', '')
            .replaceAll('-', '')
            .replaceAll('(', '')
            .replaceAll(')', '');

        if (RegExp(r'^[\d]+$').hasMatch(cleaned)) {
          return cleaned;
        }
        return null;
      })
          .whereType<String>()
          .toSet()
          .toList();

      contactNumbers = phoneList.join(',');

      if (phoneList.isNotEmpty) {
        // ✅ FIX: parallel chunks بدل sequential — أسرع بكثير
        const int chunkSize = 150;
        final List<List<String>> chunks = <List<String>>[];
        for (int i = 0; i < phoneList.length; i += chunkSize) {
          final int end = (i + chunkSize).clamp(0, phoneList.length);
          chunks.add(phoneList.sublist(i, end));
        }

        // نسخة مؤقتة لكل chunk
        final List<UsersPhoneModel> allUsers = <UsersPhoneModel>[];
        final List<Future<void>> futures = chunks.map((chunk) async {
          final chunkStr = chunk.join(',');
          await getMyContactUser(chunkStr);
          allUsers.addAll(usersPhone);
        }).toList();

        await Future.wait(futures);
        usersPhone = allUsers;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    _contactsLastLoadedAt = DateTime.now();
  }

  Future<bool> _getContactPermission() async {
    final PermissionStatus status = await Permission.contacts.request();

    if (status.isDenied ||
        status.isPermanentlyDenied ||
        await Permission.contacts.isRestricted) {
      return false;
    }

    return await Permission.contacts.isGranted;
  }

  void _handleInvalidPermissions(BuildContext context) {
    final snackBar = SnackBar(content: Text('Contact data not available on device'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // =============================
  // Follow
  // =============================
  void removeContactUsersByIds(Iterable<String> userIds) {
    final Set<String> ids = userIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet();

    if (ids.isEmpty || usersPhone.isEmpty) {
      return;
    }

    final int before = usersPhone.length;
    usersPhone.removeWhere((UsersPhoneModel u) => ids.contains((u.userId ?? '').trim()));

    if (usersPhone.length != before) {
      _contactsLastLoadedAt = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> followUser({
    String userId = '',
    int relationType = 1,
    bool? receiveRecommendations,
  }) async {
    final String myId = _myUserId();

    if (myId.isEmpty) {
      Fluttertoast.showToast(msg: 'Please login first');
      return;
    }

    if (userId.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Invalid user');
      return;
    }

    final String url =
        '${PsConfig.ps_app_url}${PsUrl.ps_user_follow_url}/api_key/${PsConfig.ps_api_key}';

    final bool receive = receiveRecommendations ?? false;

    final Map<String, String> body = <String, String>{
      'user_id': myId,
      'followed_user_id': userId.trim(),
      'relation_type': relationType.toString(),
      'receive_recommendations': receive ? '1' : '0',
    };

    try {
      // ✅ FIX: استخدام _client المشترك
      final http.Response response = await _client
          .post(Uri.parse(url), body: body)
          .timeout(const Duration(seconds: _defaultTimeoutSeconds));

      dynamic parsed;
      try {
        parsed = json.decode(response.body);
      } catch (_) {
        parsed = response.body;
      }

      if (response.statusCode == 200) {
        await getMyContactUser(contactNumbers);
        _contactsLastLoadedAt = DateTime.now();
        await refreshFriendsFamilyAll(pageSize: 30);
        Fluttertoast.showToast(msg: 'following');
      } else {
        final msg = (parsed is Map && parsed['message'] != null)
            ? parsed['message'].toString()
            : 'Error';
        Fluttertoast.showToast(msg: msg);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      notifyListeners();
    }
  }
}

class SectionSubCatItem {
  const SectionSubCatItem({required this.id, required this.name});
  final String id;
  final String name;
}
