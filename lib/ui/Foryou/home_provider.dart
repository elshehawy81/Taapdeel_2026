import 'dart:async';
import 'dart:convert';
import 'package:taapdeel/utils/perf_benchmark.dart';

import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/holder/subscribe_parameter_holder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../api/common/ps_status.dart';
import '../../../../api/ps_url.dart';
import '../../../../config/ps_config.dart';
import '../../../../constant/ps_constants.dart';
import 'package:taapdeel/ui/chat/list/chat_list_screen.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_glass_bottom_sheet.dart';
import '../../../../db/common/ps_shared_preferences.dart';
import '../../../../provider/SwapProductsProvider.dart';
import '../../../../provider/subcategory/sub_category_provider.dart';
import '../../../../repository/sub_category_repository.dart';
import '../../../../utils/ps_progress_dialog.dart';
import '../../../../utils/utils.dart';
import '../../../../viewobject/chat_history.dart';
import '../../../../viewobject/common/ps_value_holder.dart';
import '../../../../viewobject/holder/sync_chat_history_parameter_holder.dart';
import '../../../../viewobject/product.dart';
import '../../../../viewobject/sub_category.dart';
import '../common/dialog/error_dialog.dart';
import '../wish_Items/Wishlist_model.dart';

class HomeProvider extends ChangeNotifier {
  static HomeProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<HomeProvider>(context, listen: listen);
  }

  bool myProductLoading = false;
  bool subCatLoading = false;

  bool prefLoading = false;
  bool prefWishLoading = false;

  bool catLoading = false;
  bool wishLoading = false;
  bool recLoading = false;

  // ✅ NEW: bulk preferred loading
  bool prefBulkLoading = false;

  List<SubCategory> subCategories = <SubCategory>[];
  List<Product> myProducts = <Product>[];
  List<ChatHistory> successSwappedProducts = <ChatHistory>[];

  List<WishlistProductModel> wishListProducts = <WishlistProductModel>[];

  // ✅ old single-sub response (keep for compatibility)
  List<WishlistProductModel> preferredCatWishItems = <WishlistProductModel>[];

  // ✅ NEW: bulk result (for Grid 2x2 like other tabs)

  // ✅ NEW: grouped map if you need per-sub sections later
  Map<String, List<Product>> preferredCatBulkBySub = <String, List<Product>>{};

  List<Product> recProducts = <Product>[];
  List<Category> categories = <Category>[];

  String? recommendationsErrorMessage;
  int _recommendationRequestSerial = 0;
  int _myProductsRequestSerial = 0;

  final http.Client _httpClient = http.Client();

  String _headerValue(http.Response response, String key) {
    return response.headers[key.toLowerCase()] ??
        response.headers[key] ??
        response.headers[key.toUpperCase()] ??
        '';
  }

  List<String> urls = <String>[
    PsUrl.ps_top_recom_url,

  ];

  String myItemId = '';

  /// ✅ منتج المستخدم المختار
  Product? myProduct;

  /// ✅ المنتج المرشح المختار للتبديل
  Product? selectedSwapProduct;

  /// ✅ (قديم) للتوافق
  Product? sellerProduct;

  // ==========================================================
  // ✅ Pending status helpers
  // ==========================================================

  dynamic _safeProductRead(dynamic Function() getter) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }

  String _normalizePendingStatusValue(dynamic value) {
    final String text = (value ?? '').toString().trim().toLowerCase();

    if (text.isEmpty || text == 'null') {
      return '';
    }

    return text
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  String _productApprovalStatus(Product? product) {
    if (product == null) return '';

    final dynamic dynamicProduct = product;

    final List<dynamic> candidates = <dynamic>[
      _safeProductRead(() => product.status),
    ];

    for (final dynamic candidate in candidates) {
      final String normalized = _normalizePendingStatusValue(candidate);
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return '';
  }

  bool isProductPending(Product? product) {
    final String status = _productApprovalStatus(product);
    if (status.isEmpty) return false;

    const Set<String> pendingValues = <String>{
      '0',
      'pending',
      'wait',
      'waiting',
      'under_review',
      'review',
      'in_review',
      'admin_pending',
      'need_approval',
      'needs_approval',
      'awaiting_approval',
      'not_approved',
    };

    return pendingValues.contains(status) ||
        status.contains('pending') ||
        status.contains('review') ||
        status.contains('approval');
  }

  /// ✅ يرجع true لو المنتج المختار لسه في انتظار موافقة الأدمن.
  /// القراءة موحدة وتدعم أكثر من اسم للحقل، وليس status فقط.
  bool get isMyProductPending => isProductPending(myProduct);

  /// ✅ تفعيل زر طلب التبديل — يتطلب منتج مختار + مرشح مختار + منتج معتمد.
  /// المنتج pending تظهر له الترشيحات، لكن لا يسمح بإرسال طلب تبديل قبل الموافقة.
  bool get canSubmitSwap =>
      myProduct != null &&
          selectedSwapProduct != null &&
          !isMyProductPending;

  // ==========================================================
  // ✅ NEW: Auto select guard (مرة واحدة فقط)
  // ==========================================================
  bool _autoSelectedMyProductOnce = false;

  /// ✅ Reset لو احتجت (مثلاً Logout أو Refresh كامل)
  void resetAutoSelection() {
    _autoSelectedMyProductOnce = false;
    _recommendationRequestSerial++;
    _myProductsRequestSerial++;
  }

  void _scheduleRecommendationsForSelectedProduct({
    Duration delay = const Duration(milliseconds: 250),
  }) {
    final String itemId = myItemId.trim();
    if (itemId.isEmpty) return;

    final int scheduledSerial = ++_recommendationRequestSerial;

    Future<void>.delayed(delay, () async {
      if (scheduledSerial != _recommendationRequestSerial) return;
      if (myItemId.trim() != itemId) return;

      await topRecProduct(
        PsUrl.ps_top_recom_url,
        itemId: itemId,
        requestSerial: scheduledSerial,
      );
    });
  }

  /// ✅ Auto-select أول منتج للمستخدم (مرة واحدة) بعد التحميل
  Future<void> autoSelectFirstMyProductIfNeeded() async {
    if (_autoSelectedMyProductOnce) return;

    if (myProduct != null) {
      _autoSelectedMyProductOnce = true;
      return;
    }

    if (myProducts.isEmpty) return;

    _autoSelectedMyProductOnce = true;

    final Product firstProduct = myProducts.first;

    // يقيس الاختيار فقط، وليس API الترشيحات.
    TaapdeelPerfBenchmark.start('hp_auto_select');
    await setSelectedMyProduct(firstProduct, fetchRecommendations: false);
    TaapdeelPerfBenchmark.end('hp_auto_select');

    // شغّل الترشيحات بعد أول frame/هدوء بسيط حتى لا يضخم foryou_my_products.
    _scheduleRecommendationsForSelectedProduct();
  }

  /// ✅ اختيار منتج المستخدم
  Future<void> setSelectedMyProduct(
      Product? value, {
        bool fetchRecommendations = true,
      }) async
  {
    myProduct = value;
    myItemId = (value?.id ?? '').toString().trim();

    selectedSwapProduct = null;
    sellerProduct = null;

    // أي اختيار مباشر من المستخدم أو الاختيار التلقائي يمنع إعادة الاختيار فوقه مرة أخرى.
    _autoSelectedMyProductOnce = myItemId.isNotEmpty;

    if (fetchRecommendations && myItemId.isNotEmpty) {
      // نظّف الترشيحات القديمة فورًا، ثم شغّل API الترشيحات بشكل منفصل.
      // لا ننتظر الترشيحات هنا حتى لا يتضخم foryou_my_products/hp_auto_select.
      recProducts = <Product>[];
      recommendationsErrorMessage = null;
      selectedSwapProduct = null;
      sellerProduct = null;
      notifyListeners();

      _scheduleRecommendationsForSelectedProduct();
      return;
    }

    notifyListeners();
  }


  /// ✅ اختيار منتج للتبديل
  void setSelectedSwapProduct(Product? value) {
    selectedSwapProduct = value;
    sellerProduct = value;
    notifyListeners();
  }

  void selectProduct({Product? value, bool isMyProduct = false}) {
    if (isMyProduct) {
      setSelectedMyProduct(value, fetchRecommendations: true);
    } else {
      setSelectedSwapProduct(value);
    }
  }

  void setItemId(String value) {
    myItemId = value;
    notifyListeners();
  }

  Future<void> getSubCategory() async {
    // ✅ BENCHMARK: وقت تحميل الـ subcategories
    TaapdeelPerfBenchmark.start('hp_subcategory_load');

    subCatLoading = true;
    notifyListeners();

    selectedSub = <SubCategory>[];

    const String apiUrl =
        '${PsConfig.ps_app_url}rest/Subcategories/user_subcategory/api_key/${PsConfig.ps_api_key}';

    try {
      final http.Response response = await _httpClient.post(
        Uri.parse(apiUrl),
        body: <String, String>{
          'user_id': (PsSharedPreferences.instance.shared
              .getString(PsConst.VALUE_HOLDER__USER_ID) ??
              '')
              .toString(),
        },
      );

      if (response.statusCode == 200) {
        selectedSub = SubCategory().fromMapList(json.decode(response.body));
        subCatLoading = false;
        TaapdeelPerfBenchmark.end('hp_subcategory_load');

        if (selectedSub.isNotEmpty) {
          await getPreferredCatWishItems(selectedSub[0].id ?? '');
        }

        notifyListeners();
      } else {
        subCatLoading = false;
        TaapdeelPerfBenchmark.end('hp_subcategory_load');
        notifyListeners();
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      subCatLoading = false;
      TaapdeelPerfBenchmark.end('hp_subcategory_load');
      notifyListeners();
      throw Exception('Error: $error');
    }
  }

  Future<void> getMyProduct(String loginUserId) async {
    final String requestedUserId = loginUserId.trim();
    final String prefUserId = (PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__USER_ID) ??
        '')
        .toString()
        .trim();

    // Source of truth for "My Products" is the logged-in user.
    // The add-product flow stores added_user_id from SharedPreferences, so using
    // the same source here prevents searching with a stale widget/user id.
    final String effectiveUserId = prefUserId.isNotEmpty &&
        prefUserId.toLowerCase() != 'nologinuser'
        ? prefUserId
        : requestedUserId;

    debugPrint(
      '[TAAPDEEL/MY_PRODUCTS] requested_user_id=$requestedUserId '
          'pref_user_id=$prefUserId effective_user_id=$effectiveUserId',
    );

    bool isInvalidUserId(String value) {
      final String normalized = value.trim().toLowerCase();
      return normalized.isEmpty || normalized == 'nologinuser';
    }

    void clearMyProductsState() {
      myProducts = <Product>[];
      myProduct = null;
      myItemId = '';
      selectedSwapProduct = null;
      sellerProduct = null;
      recProducts = <Product>[];
      recLoading = false;
      recommendationsErrorMessage = null;
      _autoSelectedMyProductOnce = false;
      _recommendationRequestSerial++;
    }

    if (isInvalidUserId(effectiveUserId)) {
      _myProductsRequestSerial++;
      myProductLoading = false;
      clearMyProductsState();
      notifyListeners();
      return;
    }

    final int requestSerial = ++_myProductsRequestSerial;
    TaapdeelPerfBenchmark.start('hp_get_my_products');

    myProductLoading = true;
    // Keep old products visible until the new response arrives.
    // This avoids flashing the "add first product" empty state during network delay.
    notifyListeners();

    final String apiUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_my_pending_item_url}/limit/30/offset/0';

    int rowSortValue(Map<String, dynamic> row) {
      final List<String> dateKeys = <String>[
        'added_date',
      ];

      for (final String key in dateKeys) {
        final String value = (row[key] ?? '').toString().trim();
        if (value.isEmpty || value.toLowerCase() == 'null') continue;

        final int? number = int.tryParse(value);
        if (number != null) {
          // Supports unix seconds and unix milliseconds.
          return number > 9999999999 ? number : number * 1000;
        }

        final DateTime? parsed = DateTime.tryParse(
          value.contains('T') ? value : value.replaceFirst(' ', 'T'),
        );
        if (parsed != null) {
          return parsed.millisecondsSinceEpoch;
        }
      }

      return 0;
    }

    List<Map<String, dynamic>> normalizeRows(dynamic decoded) {
      if (decoded is! List) {
        throw const FormatException('My products response is not a JSON list');
      }

      final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
      for (final dynamic item in decoded) {
        if (item is Map) {
          rows.add(Map<String, dynamic>.from(item));
        }
      }

      // Defensive ordering: backend already orders by added_date DESC, but this
      // keeps UI correct even if the SQL order changes later.
      rows.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final int byDate = rowSortValue(b).compareTo(rowSortValue(a));
        if (byDate != 0) return byDate;

        final String aId = (a['id'] ?? '').toString();
        final String bId = (b['id'] ?? '').toString();
        return bId.compareTo(aId);
      });

      // Defensive de-duplication, preserving newest row first.
      final Set<String> seenIds = <String>{};
      final List<Map<String, dynamic>> uniqueRows = <Map<String, dynamic>>[];

      for (final Map<String, dynamic> row in rows) {
        final String id = (row['id'] ?? '').toString().trim();
        final String key = id.isNotEmpty
            ? id
            : 'no_id_${uniqueRows.length}_${row.hashCode}';

        if (seenIds.contains(key)) continue;

        seenIds.add(key);
        uniqueRows.add(row);
      }

      return uniqueRows;
    }

    try {
      debugPrint('[TAAPDEEL/MY_PRODUCTS] url=$apiUrl');

      TaapdeelPerfBenchmark.start('my_products_http_post');
      late final http.Response response;
      try {
        // Do not send status here.
        // Backend get_my_pending_items_model already returns status IN (0, 1)
        // when status is absent, so one request is enough for production.
        response = await _httpClient
            .post(
          Uri.parse(apiUrl),
          body: <String, String>{
            'added_user_id': effectiveUserId,
            'is_sold_out': '0',
          },
        )
            .timeout(const Duration(seconds: 20));
      } finally {
        TaapdeelPerfBenchmark.end('my_products_http_post');
      }

      if (requestSerial != _myProductsRequestSerial) return;

      final String serverMs = _headerValue(response, 'x-taapdeel-server-ms');
      final String serverReq = _headerValue(response, 'x-taapdeel-request-id');
      final String serverRows = _headerValue(response, 'x-taapdeel-rows');

      debugPrint(
        '[TAAPDEEL/MY_PRODUCTS] http_status=${response.statusCode} '
            'server_ms=$serverMs server_req=$serverReq server_rows=$serverRows '
            'bytes=${response.bodyBytes.length}',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load my products: ${response.statusCode}');
      }

      TaapdeelPerfBenchmark.start('my_products_json_decode');
      final dynamic decoded = json.decode(response.body);
      TaapdeelPerfBenchmark.end('my_products_json_decode');

      final List<Map<String, dynamic>> rows = normalizeRows(decoded);

      TaapdeelPerfBenchmark.start('my_products_fromMapList');
      final List<Product> loadedProducts = Product().fromMapList(rows);
      TaapdeelPerfBenchmark.end('my_products_fromMapList');

      if (requestSerial != _myProductsRequestSerial) return;

      debugPrint(
        '[TAAPDEEL/MY_PRODUCTS] decoded_type=${decoded.runtimeType} '
            'rows=${rows.length} parsed_count=${loadedProducts.length}',
      );

      myProducts = loadedProducts;
      recommendationsErrorMessage = null;

      if (myProducts.isEmpty) {
        clearMyProductsState();
        return;
      }

      final String currentSelectedId =
      (myProduct?.id ?? '').toString().trim();

      if (currentSelectedId.isNotEmpty) {
        final int currentIndex = myProducts.indexWhere((Product product) {
          return (product.id ?? '').toString().trim() == currentSelectedId;
        });

        if (currentIndex >= 0) {
          myProduct = myProducts[currentIndex];
          myItemId = (myProduct?.id ?? '').toString().trim();
        } else {
          myProduct = null;
          myItemId = '';
          selectedSwapProduct = null;
          sellerProduct = null;
          _autoSelectedMyProductOnce = false;
        }
      }

      // Pending products are selectable and can show recommendations.
      // Swap submission remains blocked by canSubmitSwap/isMyProductPending.
      await autoSelectFirstMyProductIfNeeded();
    } on TimeoutException catch (error) {
      if (requestSerial != _myProductsRequestSerial) return;
      recommendationsErrorMessage = 'تعذر تحميل منتجاتك بسبب بطء الاتصال.';
      debugPrint('[TAAPDEEL/MY_PRODUCTS] timeout=$error');
    } on FormatException catch (error) {
      if (requestSerial != _myProductsRequestSerial) return;
      recommendationsErrorMessage = 'تعذر قراءة بيانات منتجاتك من السيرفر.';
      debugPrint('[TAAPDEEL/MY_PRODUCTS] format_error=$error');
    } catch (error) {
      if (requestSerial != _myProductsRequestSerial) return;
      recommendationsErrorMessage = 'تعذر تحميل منتجاتك الآن.';
      debugPrint('[TAAPDEEL/MY_PRODUCTS] error=$error');
    } finally {
      TaapdeelPerfBenchmark.end('hp_get_my_products');

      if (requestSerial == _myProductsRequestSerial) {
        myProductLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> getWishListProduct() async {
    wishLoading = true;
    notifyListeners();

    wishListProducts = <WishlistProductModel>[];
    const String apiUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_get_wishlist_items_url}';

    try {
      final http.Response response =
      await _httpClient.post(Uri.parse(apiUrl), body: <String, String>{});

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        wishListProducts = jsonList
            .map((dynamic item) => WishlistProductModel.fromJson(item))
            .toList();
        wishLoading = false;
        notifyListeners();
      } else {
        wishLoading = false;
        notifyListeners();
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      wishLoading = false;
      notifyListeners();
      throw Exception('Error: $error');
    }
  }

  Future<void> getOwnerWishListProduct(String userId) async {
    wishLoading = true;
    notifyListeners();

    const String apiUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_get_owner_wishlist_items_url}';

    try {
      final http.Response response = await _httpClient.post(
        Uri.parse(apiUrl),
        body: <String, String>{'added_user_id': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        wishListProducts = jsonList
            .map((dynamic item) => WishlistProductModel.fromJson(item))
            .toList();

        wishLoading = false;
        notifyListeners();
      } else {
        wishLoading = false;
        notifyListeners();
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      wishLoading = false;
      notifyListeners();
      throw Exception('Error: $error');
    }
  }



  Future<void> getPreferredCatWishItems(String subCatId) async {
    if (subCatId.isEmpty) return;

    prefWishLoading = true;
    notifyListeners();

    preferredCatWishItems = <WishlistProductModel>[];

    final String apiUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_get_wishlist_items_url}';

    try {
      final String uid = (PsSharedPreferences.instance.shared
          .getString(PsConst.VALUE_HOLDER__USER_ID) ??
          '')
          .toString();

      final String locId = (PsSharedPreferences.instance.shared
          .get(PsConst.VALUE_HOLDER__LOCATION_ID) ??
          '')
          .toString();

      final http.Response response = await _httpClient.post(
        Uri.parse(apiUrl),
        body: <String, String>{
          'sub_cat_id': subCatId.toString(),
          'added_user_id': uid,
          'item_location_id': locId,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        preferredCatWishItems = jsonList
            .map((dynamic item) => WishlistProductModel.fromJson(item))
            .toList();

        prefWishLoading = false;
        notifyListeners();
      } else {
        prefWishLoading = false;
        notifyListeners();
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      prefWishLoading = false;
      notifyListeners();
      throw Exception('Error: $error');
    }
  }

  /// ✅ Fetch (no notify) for widget-local loading
  Future<List<Product>> fetchPreferredCatProducts(String catId) async {
    const String apiUrl = '${PsConfig.ps_app_url}${PsUrl.ps_Prefcat_url}';

    final String locId = (PsSharedPreferences.instance.shared
        .get(PsConst.VALUE_HOLDER__LOCATION_ID) ??
        '')
        .toString();

    final String uid = (PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__USER_ID) ??
        '')
        .toString();

    final http.Response response = await _httpClient.post(
      Uri.parse(apiUrl),
      body: <String, String>{
        'item_location_id': locId,
        'added_user_id': uid,
        'sub_cat_id': catId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return Product().fromMapList(json.decode(response.body));
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  /// ✅ تحميل الترشيحات لمنتج المستخدم الحالي
  /// لا يغيّر جودة الترشيحات ولا يقلل النتائج. الهدف هنا:
  /// - فصل قياس HTTP / JSON / mapping / notify.
  /// - منع أي response قديم من الكتابة فوق المنتج الحالي.
  /// - عدم رمي Exception يسبب Unhandled Exception في Flutter.
  Future<void> topRecProduct(
      String url, {
        String? itemId,
        int? requestSerial,
      }) async
  {
    final String requestedItemId = (itemId ?? myItemId).trim();
    if (requestedItemId.isEmpty) {
      recLoading = false;
      notifyListeners();
      return;
    }

    final int serial = requestSerial ?? ++_recommendationRequestSerial;
    final String benchKey = 'hp_recommendations_$requestedItemId';

    TaapdeelPerfBenchmark.start(benchKey);

    recommendationsErrorMessage = null;
    recLoading = true;
    recProducts = <Product>[];
    selectedSwapProduct = null;
    sellerProduct = null;
    notifyListeners();

    final String apiUrl = '${PsConfig.ps_app_url}$url';

    try {
      final String loginUserId = PsSharedPreferences.instance.shared
          .getString(PsConst.VALUE_HOLDER__USER_ID) ??
          '';

      TaapdeelPerfBenchmark.start('rec_http_post');
      late final http.Response response;
      try {
        response = await _httpClient.post(
          Uri.parse(apiUrl),
          body: <String, String>{
            'item_id': requestedItemId,
            'login_user_id': loginUserId,
          },
        );
      } finally {
        TaapdeelPerfBenchmark.end('rec_http_post');
      }

      // لو المستخدم غيّر المنتج أثناء انتظار السيرفر، تجاهل النتيجة القديمة.
      if (serial != _recommendationRequestSerial || myItemId.trim() != requestedItemId) {
        return;
      }

      if (response.statusCode == 200) {
        TaapdeelPerfBenchmark.start('rec_json_decode');
        final dynamic decoded = json.decode(response.body);
        TaapdeelPerfBenchmark.end('rec_json_decode');

        TaapdeelPerfBenchmark.start('rec_fromMapList');
        final List<Product> parsed = Product().fromMapList(decoded);
        TaapdeelPerfBenchmark.end('rec_fromMapList');

        recProducts = parsed;
        recommendationsErrorMessage = null;
      } else {
        recommendationsErrorMessage = 'تعذر تحميل الترشيحات الآن، جرّب لاحقًا.';
      }
    } catch (error) {
      // لا ترمي exception هنا. الصفحة يجب ألا تتعطل بسبب timeout أو network error.
      recommendationsErrorMessage = 'تعذر تحميل الترشيحات الآن، جرّب لاحقًا.';
    } finally {
      if (serial == _recommendationRequestSerial && myItemId.trim() == requestedItemId) {
        TaapdeelPerfBenchmark.start('rec_notify');
        recLoading = false;
        selectedSwapProduct = null;
        sellerProduct = null;
        notifyListeners();
        TaapdeelPerfBenchmark.end('rec_notify');
      }

      TaapdeelPerfBenchmark.end(benchKey);
    }
  }

  bool isSubmitting = false;

  void _openSwapRequestsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (_) => const ChatListScreen(),
      ),
    );
  }

  void _showSwapRequestSentSnackBar(BuildContext context) {
    _showSwapRequestResultSheet(
      context: context,
      title: 'تم إرسال طلب التبديل بنجاح 🎉',
      message: 'يمكنك متابعة حالة الطلب والردود من صفحة طلبات التبديل.',
      icon: Icons.check_circle_outline_rounded,
      iconColor: const Color(0xFF065F46),
      iconBackgroundColor: const Color(0xFFD1FAE5),
    );
  }

  void _showSwapRequestAlreadySentSnackBar(BuildContext context) {
    _showSwapRequestResultSheet(
      context: context,
      title: 'طلب التبديل موجود بالفعل',
      message: 'تم إرسال طلب تبديل لهذا المنتج من قبل. يمكنك متابعة الطلب من صفحة طلبات التبديل.',
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF0C587A),
      iconBackgroundColor: const Color(0xFFE6FAFD),
    );
  }

  void _showSwapRequestResultSheet({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
  })
  {
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);

        Future<void> closeSheet() async {
          if (Navigator.of(sheetContext, rootNavigator: true).canPop()) {
            Navigator.of(sheetContext, rootNavigator: true).pop();
          }
        }

        Future<void> closeAndOpenRequests() async {
          await closeSheet();
          await Future<void>.delayed(const Duration(milliseconds: 110));
          _openSwapRequestsPage(context);
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: TaapdeelGlassBottomSheet(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.65),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TaapdeelButton(
                    label: 'إغلاق',
                    isPrimary: false,
                    isExpanded: true,
                    onPressed: closeSheet,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> submitSwap({required BuildContext context}) async {
    if (isSubmitting) {
      return;
    }

    if (!canSubmitSwap) {
      if (isMyProductPending) {
        Fluttertoast.showToast(
          msg: 'يمكنك طلب التبديل بعد موافقة الأدمن لنشر منتجك',
        );
      } else {
        Fluttertoast.showToast(msg: 'اختر منتجك ومنتج للتبديل أولاً');
      }
      return;
    }

    final Product? currentMyProduct = myProduct;
    final Product? target = selectedSwapProduct;

    if (currentMyProduct == null || target == null) {
      Fluttertoast.showToast(msg: 'اختر منتجك ومنتج للتبديل أولاً');
      return;
    }

    isSubmitting = true;
    notifyListeners();

    final String targetId = (target.id ?? '').toString().trim();

    void removeRequestedRecommendationLocally() {
      if (targetId.isNotEmpty) {
        recProducts = recProducts.where((Product product) {
          return (product.id ?? '').toString().trim() != targetId;
        }).toList(growable: false);
      }

      selectedSwapProduct = null;
      sellerProduct = null;
    }

    bool isAlreadySentResponse(String response) {
      final String normalized = response.trim().toLowerCase();

      return normalized == 'already' ||
          normalized == 'already_sent' ||
          normalized == 'already_exists' ||
          normalized == 'exist' ||
          normalized == 'exists' ||
          normalized == 'duplicate' ||
          normalized.contains('already') ||
          normalized.contains('exist') ||
          normalized.contains('duplicate');
    }

    try {
      final SyncChatHistoryParameterHolder syncChatHistoryParameterHolder =
      SyncChatHistoryParameterHolder(
        itemId: target.id,
        buyerUserId: PsSharedPreferences.instance.shared
            .getString(PsConst.VALUE_HOLDER__USER_ID),
        sellerUserId: target.addedUserId,
        type: PsConst.CHAT_TO_SELLER,
        isUserOnline: '0',
        buyerItemId: currentMyProduct.id,
        message: '',
      );

      final SwapProductsProvider swapProductsProvider =
      Provider.of<SwapProductsProvider>(context, listen: false);

      final String response =
      await swapProductsProvider.addPriceOffer(
        syncChatHistoryParameterHolder.toMap(),
      );

      if (response == 'success') {
        removeRequestedRecommendationLocally();
        _showSwapRequestSentSnackBar(context);

        final String loginUserId = (PsSharedPreferences.instance.shared
            .getString(PsConst.VALUE_HOLDER__USER_ID) ??
            '')
            .toString();

        if (loginUserId.isNotEmpty) {
          swapProductsProvider.decrementSwapBalance(loginUserId);
        }
      } else if (isAlreadySentResponse(response)) {
        // الطلب موجود بالفعل، لذلك نخفي نفس الترشيح من القائمة الحالية
        // والمستخدم يقدر يتابعه من صفحة طلبات التبديل.
        removeRequestedRecommendationLocally();
        _showSwapRequestAlreadySentSnackBar(context);
      } else {
        debugPrint('[TAAPDEEL/SUBMIT_SWAP] unexpected_response=$response');
        Fluttertoast.showToast(
          msg: 'تعذر إرسال طلب التبديل الآن، حاول مرة أخرى',
        );
      }
    } catch (error) {
      debugPrint('[TAAPDEEL/SUBMIT_SWAP] error=$error');
      Fluttertoast.showToast(
        msg: 'تعذر إرسال طلب التبديل الآن، تحقق من الاتصال وحاول مرة أخرى',
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  List<SubCategory> selectedSub = <SubCategory>[];

  String _subCategoryKey(SubCategory? subCategory) {
    final String catId = (subCategory?.catId ?? '').toString().trim();
    final String subId = (subCategory?.id ?? '').toString().trim();
    if (catId.isEmpty || subId.isEmpty) return '';
    return '$catId::$subId';
  }

  bool _isSameSubCategory(SubCategory? a, SubCategory? b) {
    final String aKey = _subCategoryKey(a);
    final String bKey = _subCategoryKey(b);
    return aKey.isNotEmpty && aKey == bKey;
  }

  bool isSubCategorySelected({SubCategory? subCategory}) {
    if (subCategory == null) return false;
    return selectedSub.any((SubCategory item) {
      return _isSameSubCategory(item, subCategory);
    });
  }

  void toggleSelection({SubCategory? subCategory}) {
    if (subCategory == null) return;

    final bool selected = isSubCategorySelected(subCategory: subCategory);
    if (selected) {
      selectedSub.removeWhere((SubCategory item) {
        return _isSameSubCategory(item, subCategory);
      });
    } else {
      selectedSub.add(subCategory);
    }

    saveList();
    notifyListeners();
  }

  void replaceSelectedSubCategories(
      List<SubCategory> list, {
        bool cacheToLocal = true,
        bool notify = true,
      })
  {
    final Map<String, SubCategory> unique = <String, SubCategory>{};

    for (final SubCategory item in list) {
      final String key = _subCategoryKey(item);
      if (key.isEmpty) continue;
      unique[key] = item;
    }

    selectedSub = unique.values.toList();

    if (cacheToLocal) {
      saveList();
    }

    if (notify) {
      notifyListeners();
    }
  }

  String encodeList(List<SubCategory> list) {
    final List<Map<String, dynamic>?> mapList = SubCategory().toMapList(list);
    return jsonEncode(mapList);
  }

  List<SubCategory> decodeList(String json) {
    final List<dynamic> mapList = jsonDecode(json);
    return SubCategory().fromMapList(mapList);
  }

  void saveList() {
    PsSharedPreferences.instance.shared
        .setString('myListKey', encodeList(selectedSub));
  }

  List<SubCategory> retrieveList() {
    final String jsonString =
        PsSharedPreferences.instance.shared.getString('myListKey') ?? '';
    if (jsonString.isEmpty) return <SubCategory>[];

    try {
      return decodeList(jsonString);
    } catch (_) {
      PsSharedPreferences.instance.shared.remove('myListKey');
      return <SubCategory>[];
    }
  }

  void restoreSelectedSubFromLocal({bool notify = true}) {
    replaceSelectedSubCategories(
      retrieveList(),
      cacheToLocal: false,
      notify: notify,
    );
  }

  void initSelectSub() {
    catLoading = true;
    notifyListeners();

    final List<SubCategory> temp = retrieveList();
    if (temp.isNotEmpty) {
      replaceSelectedSubCategories(
        temp,
        cacheToLocal: false,
        notify: false,
      );
      catLoading = false;
      notifyListeners();

      final String uid = PsSharedPreferences.instance.shared
          .getString(PsConst.VALUE_HOLDER__USER_ID) ??
          '';

      if (uid.isNotEmpty) {
        getSubCategory();
      } else {
        getPreferredCatWishItems(selectedSub[0].id ?? '');
      }
    }

    catLoading = false;
    notifyListeners();
  }

  bool addingWishItem = false;
  String? addingWishItemID;

  Future<void> addWishListItem(
      Map<String, dynamic> wishListMap, BuildContext context) async {
    addingWishItem = true;
    notifyListeners();

    final String apiUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_wish_item_entry_url}/login_user_id/${wishListMap['added_user_id']}';

    try {
      final http.Response response =
      await _httpClient.post(Uri.parse(apiUrl), body: wishListMap);

      if (response.statusCode == 200) {
        addingWishItemID = json.decode(response.body)['id'];
        notifyListeners();
      } else {
        showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(message: response.body);
          },
        );
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(message: error.toString());
        },
      );
      notifyListeners();
      throw Exception('Error: $error');
    } finally {
      addingWishItem = false;
      notifyListeners();
    }
  }

  SubCategoryProvider? _subCategoryProvider;
  PsValueHolder? valueHolder;
  SubCategoryRepository? repo1;

  Future<void> pullSelectedSubFromServer({
    required String userId,
    bool cacheToLocal = true,
  }) async {
    if (userId.isEmpty) return;

    subCatLoading = true;
    notifyListeners();

    try {
      final String apiUrl =
          '${PsConfig.ps_app_url}rest/Subcategories/user_subcategory/api_key/${PsConfig.ps_api_key}';

      final http.Response response = await _httpClient.post(
        Uri.parse(apiUrl),
        body: <String, String>{'user_id': userId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }

      final List<SubCategory> serverList =
      SubCategory().fromMapList(json.decode(response.body));

      replaceSelectedSubCategories(
        serverList,
        cacheToLocal: cacheToLocal,
        notify: false,
      );

      if (selectedSub.isNotEmpty) {
        await getPreferredCatWishItems(selectedSub[0].id ?? '');
      }

    } catch (_) {
      if (selectedSub.isEmpty) {
        restoreSelectedSubFromLocal(notify: false);
      }
    } finally {
      subCatLoading = false;
      notifyListeners();
    }
  }

  Future<void> subscribeAfterLogin(String userId, BuildContext context) async {
    repo1 = Provider.of<SubCategoryRepository>(context, listen: false);
    valueHolder = Provider.of<PsValueHolder>(context, listen: false);
    _subCategoryProvider =
        SubCategoryProvider(repo: repo1, psValueHolder: valueHolder);

    await PsProgressDialog.showDialog(context);

    final List<String> catIdList = <String>[];
    for (final SubCategory element in retrieveList()) {
      if (element.catId != null && !catIdList.contains(element.catId)) {
        catIdList.add(element.catId!);
      }
    }

    for (final String catId in catIdList) {
      final List<String> subCatIdList = <String>[];

      for (final SubCategory subCat in retrieveList()) {
        if (subCat.catId == catId && (subCat.id ?? '').isNotEmpty) {
          subCatIdList.add('${subCat.id}_MB');
        }
      }

      final holder = SubscribeParameterHolder(
        userId: userId,
        catId: catId,
        selectedsubCatId: subCatIdList,
      );

      final res = await _subCategoryProvider!.postSubCategorySubscribe(holder.toMap());

      if (res.status == PsStatus.SUCCESS) {
        Utils.subscribeToModelTopics(subCatIdList);
        notifyListeners();
      }
    }

    PsProgressDialog.dismissDialog();
  }

  @override
  void dispose() {
    _myProductsRequestSerial++;
    _recommendationRequestSerial++;
    _httpClient.close();
    super.dispose();
  }

}
