import 'dart:convert';

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
  bool nearestLoading = false;

  bool prefLoading = false;
  bool prefWishLoading = false;

  bool catLoading = false;
  bool wishLoading = false;
  bool swapLoading = false;
  bool recLoading = false;

  // ✅ NEW: bulk preferred loading
  bool prefBulkLoading = false;

  List<SubCategory> subCategories = <SubCategory>[];
  List<Product> myProducts = <Product>[];
  List<Product> nearestProducts = <Product>[];
  List<ChatHistory> successSwappedProducts = <ChatHistory>[];

  List<WishlistProductModel> wishListProducts = <WishlistProductModel>[];

  // ✅ old single-sub response (keep for compatibility)
  List<Product> preferredCatProducts = <Product>[];
  List<WishlistProductModel> preferredCatWishItems = <WishlistProductModel>[];

  // ✅ NEW: bulk result (for Grid 2x2 like other tabs)
  List<Product> preferredCatBulkProducts = <Product>[];

  // ✅ NEW: grouped map if you need per-sub sections later
  Map<String, List<Product>> preferredCatBulkBySub = <String, List<Product>>{};

  List<Product> recProducts = <Product>[];
  List<Category> categories = <Category>[];

  List<String> urls = <String>[
    PsUrl.ps_top_recom_url,
    PsUrl.ps_friends_recom_url,
    PsUrl.ps_nearest_recom_url,
    PsUrl.ps_wishitems_recom_url,
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

  /// ✅ يرجع true لو المنتج المختار لسه في انتظار موافقة الأدمن (status == '0')
  bool get isMyProductPending {
    final String status = (myProduct?.status ?? '1').toString().trim();
    return status == '0';
  }

  /// ✅ تفعيل زر طلب التبديل — يتطلب منتج مختار + مرشح مختار + منتج معتمد
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
  }

  /// ✅ Auto-select آخر منتج للمستخدم (مرة واحدة) بعد التحميل
  Future<void> autoSelectLastMyProductIfNeeded() async {
    if (_autoSelectedMyProductOnce) return;

    if (myProduct != null) {
      _autoSelectedMyProductOnce = true;
      return;
    }

    if (myProducts.isEmpty) return;

    _autoSelectedMyProductOnce = true;

    final Product lastProduct = myProducts.last;

    // ✅ اختر آخر منتج تمت إضافته + اعرض الترشيحات تلقائيًا
    await setSelectedMyProduct(lastProduct, fetchRecommendations: true);
  }

  /// ✅ اختيار منتج المستخدم
  Future<void> setSelectedMyProduct(
      Product? value, {
        bool fetchRecommendations = true,
      }) async {
    myProduct = value;
    myItemId = value?.id ?? '';

    selectedSwapProduct = null;
    sellerProduct = null;

    // ✅ أي اختيار مباشر من المستخدم أو الاختيار التلقائي يمنع إعادة الاختيار
    // فوقه مرة أخرى من أي مكان آخر.
    _autoSelectedMyProductOnce = myItemId.isNotEmpty;

    if (fetchRecommendations && myItemId.isNotEmpty) {
      // ✅ نظّف الترشيحات القديمة فورًا حتى لا تعرض الصفحة منتجًا قديمًا
      // أثناء تحميل ترشيحات المنتج الجديد.
      recProducts = <Product>[];
      recLoading = true;
      notifyListeners();

      await topRecProduct(PsUrl.ps_top_recom_url);
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
    subCatLoading = true;
    notifyListeners();

    selectedSub = <SubCategory>[];

    const String apiUrl =
        '${PsConfig.ps_app_url}rest/Subcategories/user_subcategory/api_key/${PsConfig.ps_api_key}';

    try {
      final http.Response response = await http.post(
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

        if (selectedSub.isNotEmpty) {
          await getPreferredCatWishItems(selectedSub[0].id ?? '');
        }

        notifyListeners();
      } else {
        subCatLoading = false;
        notifyListeners();
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      subCatLoading = false;
      notifyListeners();
      throw Exception('Error: $error');
    }
  }

  Future<void> getMyProduct(String loginUserId) async {
    myProductLoading = true;
    notifyListeners();

    myProducts = <Product>[];
    const String apiUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_my_pending_item_url}';

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: <String, String>{'added_user_id': loginUserId},
      );

      if (response.statusCode == 200) {
        myProducts = Product().fromMapList(json.decode(response.body));

        if (myProducts.isEmpty) {
          myItemId = '';
          myProduct = null;
          selectedSwapProduct = null;
          sellerProduct = null;
          _autoSelectedMyProductOnce = false; // ✅ لو فاضية نرجّعها
        } else {
          // ✅ Auto select أول منتج مرة واحدة فقط
          await autoSelectLastMyProductIfNeeded();
        }

        myProductLoading = false;
        notifyListeners();
      } else {
        myProductLoading = false;
        notifyListeners();
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      myProductLoading = false;
      notifyListeners();
      throw Exception('Error: $error');
    }
  }


  Future<void> getSuccessSwappedListProduct() async {
    swapLoading = true;
    notifyListeners();

    successSwappedProducts = <ChatHistory>[];
    const String apiUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_get_success_swap_items_url}';

    try {
      final http.Response response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        successSwappedProducts =
            ChatHistory().fromMapList(json.decode(response.body));
        swapLoading = false;
        notifyListeners();
      } else {
        swapLoading = false;
        notifyListeners();
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      swapLoading = false;
      notifyListeners();
      throw Exception('Error: $error');
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
      await http.post(Uri.parse(apiUrl), body: <String, String>{});

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
      final http.Response response = await http.post(
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

  /// ✅ OLD (single sub-cat) — keep as-is but fix body types to String
  Future<void> getPreferredCatProduct(String catId) async {
    prefLoading = true;
    notifyListeners();

    preferredCatProducts = <Product>[];
    const String apiUrl = '${PsConfig.ps_app_url}${PsUrl.ps_Prefcat_url}';

    try {
      final String locId = (PsSharedPreferences.instance.shared
          .get(PsConst.VALUE_HOLDER__LOCATION_ID) ??
          '')
          .toString();

      final String uid = (PsSharedPreferences.instance.shared
          .getString(PsConst.VALUE_HOLDER__USER_ID) ??
          '')
          .toString();

      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: <String, String>{
          'item_location_id': locId,
          'added_user_id': uid,
          'sub_cat_id': catId.toString(),
        },
      );

      if (response.statusCode == 200) {
        preferredCatProducts = Product().fromMapList(json.decode(response.body));
        prefLoading = false;
        notifyListeners();
      } else {
        prefLoading = false;
        notifyListeners();
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      prefLoading = false;
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

      final http.Response response = await http.post(
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

    final http.Response response = await http.post(
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
  Future<void> topRecProduct(String url) async {
    recLoading = true;
    notifyListeners();

    recProducts = <Product>[];

    final String apiUrl = '${PsConfig.ps_app_url}$url';
    try {
      if (myItemId.isNotEmpty) {
        final http.Response response =
        await http.post(Uri.parse(apiUrl), body: <String, String>{
          'item_id': myItemId,
          'login_user_id': PsSharedPreferences.instance.shared
              .getString(PsConst.VALUE_HOLDER__USER_ID) ??
              '',
        });

        if (response.statusCode == 200) {
          recProducts = Product().fromMapList(json.decode(response.body));

          // ✅ لا تختار أول مرشح تلقائيًا
          selectedSwapProduct = null;
          sellerProduct = null;

          recLoading = false;
          notifyListeners();
        } else {
          recLoading = false;
          notifyListeners();
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      } else {
        recLoading = false;
        notifyListeners();
      }
    } catch (error) {
      recLoading = false;
      notifyListeners();
      throw Exception('Error: $error');
    }
  }

  bool isSubmitting = false;

  Future<void> submitSwap({required BuildContext context}) async {
    if (!canSubmitSwap) {
      if (isMyProductPending) {
        Fluttertoast.showToast(msg: 'يمكنك طلب التبديل بعد موافقه الادمن لنشر منتجك');
      } else {
        Fluttertoast.showToast(msg: 'اختر منتجك ومنتج للتبديل أولاً');
      }
      return;
    }

    isSubmitting = true;
    notifyListeners();

    final Product target = selectedSwapProduct!;

    final SyncChatHistoryParameterHolder syncChatHistoryParameterHolder =
    SyncChatHistoryParameterHolder(
      itemId: target.id,
      buyerUserId:
      PsSharedPreferences.instance.shared.getString(PsConst.VALUE_HOLDER__USER_ID),
      sellerUserId: target.addedUserId,
      type: PsConst.CHAT_TO_SELLER,
      isUserOnline: '0',
      buyerItemId: myProduct!.id,
      message: '',
    );

    final String response =
    await Provider.of<SwapProductsProvider>(context, listen: false)
        .addPriceOffer(syncChatHistoryParameterHolder.toMap());

    if (response == 'success') {
      Fluttertoast.showToast(msg: 'Swap request sent successfully');
      Provider.of<SwapProductsProvider>(context, listen: false).decrementSwapBalance(
          PsSharedPreferences.instance.shared
              .getString(PsConst.VALUE_HOLDER__USER_ID)
              .toString());
    } else {
      Fluttertoast.showToast(msg: '!! Same Product already requested before');
    }

    isSubmitting = false;
    notifyListeners();
  }

  // ===== باقي الكود كما هو بدون تغيير =====

  bool isSubCategorySelected({SubCategory? subCategory}) {
    return selectedSub.contains(subCategory);
  }

  void toggleSelection({SubCategory? subCategory}) {
    if (subCategory != null) {
      if (selectedSub.contains(subCategory)) {
        selectedSub.remove(subCategory);
      } else {
        selectedSub.add(subCategory);
      }
      saveList();
      notifyListeners();
    }
  }

  List<SubCategory> selectedSub = <SubCategory>[];

  String encodeList(List<SubCategory> list) {
    List<Map<String, dynamic>?> mapList = SubCategory().toMapList(list);
    return jsonEncode(mapList);
  }

  List<SubCategory> decodeList(String json) {
    List<dynamic> mapList = jsonDecode(json);
    return SubCategory().fromMapList(mapList);
  }

  void saveList() {
    PsSharedPreferences.instance.shared
        .setString('myListKey', encodeList(selectedSub));
  }

  List<SubCategory> retrieveList() {
    final String jsonString =
        PsSharedPreferences.instance.shared.getString('myListKey') ?? '';
    return jsonString.isNotEmpty ? decodeList(jsonString) : <SubCategory>[];
  }

  void initSelectSub() {
    catLoading = true;
    notifyListeners();

    final List<SubCategory> temp = retrieveList();
    if (temp.isNotEmpty) {
      selectedSub = temp;
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
      await http.post(Uri.parse(apiUrl), body: wishListMap);

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

      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: <String, String>{'user_id': userId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }

      final List<SubCategory> serverList =
      SubCategory().fromMapList(json.decode(response.body));

      selectedSub = serverList;

      if (cacheToLocal) {
        saveList();
      }

      if (selectedSub.isNotEmpty) {
        await getPreferredCatWishItems(selectedSub[0].id ?? '');
      }

    } catch (e) {
      // ignore
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
}
