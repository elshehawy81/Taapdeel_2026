import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:taapdeel/api/ps_url.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/viewobject/about_us.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/blocked_user.dart';
import 'package:taapdeel/viewobject/blog.dart';
import 'package:taapdeel/viewobject/buyadpost_transaction.dart';
import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/chat_history.dart';
import 'package:taapdeel/viewobject/condition_of_item.dart';
import 'package:taapdeel/viewobject/deal_option.dart';
import 'package:taapdeel/viewobject/default_photo.dart';
import 'package:taapdeel/viewobject/item_location.dart';
import 'package:taapdeel/viewobject/item_location_township.dart';
import 'package:taapdeel/viewobject/item_paid_history.dart';
import 'package:taapdeel/viewobject/item_price_type.dart';
import 'package:taapdeel/viewobject/item_type.dart';
import 'package:taapdeel/viewobject/noti.dart';
import 'package:taapdeel/viewobject/offer.dart';
import 'package:taapdeel/viewobject/offline_payment_method.dart';
import 'package:taapdeel/viewobject/package.dart';
import 'package:taapdeel/viewobject/paid_ad_item.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/ps_app_info.dart';
import 'package:taapdeel/viewobject/rating.dart';
import 'package:taapdeel/viewobject/reported_item.dart';
import 'package:taapdeel/viewobject/sub_category.dart';
import 'package:taapdeel/viewobject/user.dart';
import 'package:taapdeel/viewobject/user_unread_message.dart';

import '../ui/rating/item/rating_list_item.dart';
import '../ui/sweet_phrase/sweet_message.dart';
import '../viewobject/owner_relation.dart';
import '../viewobject/owner_subcat_subscribe.dart';
import '../viewobject/owner_subcat_subscribe_response.dart';
import 'common/ps_api.dart';
import 'common/ps_resource.dart';
import 'package:http/http.dart' as http;

import 'common/ps_status.dart';

class PsApiService extends PsApi {
  // Persistent client: reuses connections where possible (HTTP keep-alive).
  final http.Client _client = http.Client();

  static String _mapString(Map<dynamic, dynamic> map, String key) {
    return (map[key] ?? '').toString().trim();
  }

  static bool _isBlank(Map<dynamic, dynamic> map, String key) {
    return _mapString(map, key).isEmpty;
  }

  static bool _isMyPendingItemsRequest(
    Map<dynamic, dynamic> map,
    String? loginUserId,
  ) {
    final String ownerId = _mapString(map, 'added_user_id');
    final String userId = (loginUserId ?? '').trim();
    if (ownerId.isEmpty || userId.isEmpty || ownerId != userId) return false;

    final String status = _mapString(map, 'status');
    final String isSoldOut = _mapString(map, 'is_sold_out');
    if (status != '1' || isSoldOut != '0') return false;

    // This is the exact old generic request used for My Products.
    return _isBlank(map, 'searchterm') &&
        _isBlank(map, 'cat_id') &&
        _isBlank(map, 'subcat_id') &&
        _isBlank(map, 'item_type_id') &&
        _isBlank(map, 'item_price_type_id') &&
        _isBlank(map, 'brand') &&
        _isBlank(map, 'ad_post_type') &&
        (_isBlank(map, 'order_by') || _mapString(map, 'order_by') == 'added_date');
  }
  ///
  /// App Info
  ///
  Future<PsResource<PSAppInfo>> postPsAppInfo(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_app_info_url}';
    return await postData<PSAppInfo, PSAppInfo>(PSAppInfo(), url, jsonMap);
  }

  ///
  /// User Zone ShippingMethod
  ///
  ///
  /// User Register
  ///
  Future<PsResource<User>> postUserRegister(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_register_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// User Verify Email
  ///
  Future<PsResource<User>> postUserEmailVerify(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_email_verify_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// User Login
  ///
  Future<PsResource<User>> postUserLogin(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// FB Login
  ///
  Future<PsResource<User>> postFBLogin(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_fb_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// Google Login
  ///
  Future<PsResource<User>> postGoogleLogin(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_google_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// Apple Login
  ///
  Future<PsResource<User>> postAppleLogin(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_apple_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// User Forgot Password
  ///
  Future<PsResource<ApiStatus>> postForgotPassword(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_forgot_password_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User Change Password
  ///
  Future<PsResource<ApiStatus>> postChangePassword(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_change_password_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User Change Password
  ///
  Future<PsResource<ApiStatus>> postApplyBlueMark(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_apply_blue_mark_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User Profile Update
  ///
  Future<PsResource<User>> postProfileUpdate(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_update_profile_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// User Phone Login
  ///
  Future<PsResource<User>> postPhoneLogin(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_phone_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  ///  User Follow
  ///
  Future<PsResource<User>> postUserFollow(Map<dynamic, dynamic> jsonMap) async {
    const String url =
        '${PsUrl.ps_user_follow_url}/api_key/${PsConfig.ps_api_key}';

    return await postData<User, User>(User(), url, jsonMap);
  }

  Future<bool> postIsFollow(String? userId, String? followedUserId) async {

    const String url =
        '${PsUrl.ps_is_follow_url}/api_key/${PsConfig.ps_api_key}';

    var response = await _client.post(
      Uri.parse('${PsConfig.ps_app_url}$url'),
      body: {
        'user_id': userId,
        'followed_user_id': followedUserId,
      },
    );

    return response.body.toString().toLowerCase() == 'true';

  }

  ///
  /// User Resend Code
  ///
  Future<PsResource<ApiStatus>> postResendCode(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_resend_code_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User Detail
  ///
  Future<PsResource<User>> getUserDetail(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_user_detail_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// Touch Count
  ///
  Future<PsResource<ApiStatus>> postTouchCount(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_touch_count_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Get User
  ///
  Future<PsResource<List<User>>> getUser(String? userId) async {
    final String url =
        '${PsUrl.ps_user_url}/api_key/${PsConfig.ps_api_key}/user_id/$userId';

    return await getServerCall<User, List<User>>(User(), url);
  }

  Future<PsResource<User>> postImageUpload(
      String userId, String platformName, File imageFile) async {
    const String url = '${PsUrl.ps_image_upload_url}';

    return await postUploadImage<User, User>(User(), url, 'user_id', userId,
        'platform_name', platformName, imageFile);
  }

  Future<PsResource<DefaultPhoto>> postVideoUpload(
      String itemId, String videoId, File imageFile, String loginUserId) async {
    final String url =
        '${PsUrl.ps_video_upload_url}/login_user_id/$loginUserId';

    return await postUploadImage<DefaultPhoto, DefaultPhoto>(
        DefaultPhoto(), url, 'item_id', itemId, 'img_id', videoId, imageFile);
  }

  Future<PsResource<DefaultPhoto>> postVideoThumbnailUpload(
      String itemId, String videoId, File imageFile, String loginUserId) async {
    final String url =
        '${PsUrl.ps_video_thumbnail_upload_url}/login_user_id/$loginUserId';

    return await postUploadImage<DefaultPhoto, DefaultPhoto>(
        DefaultPhoto(), url, 'item_id', itemId, 'img_id', videoId, imageFile);
  }

  Future<PsResource<DefaultPhoto>> postItemImageUpload(
      String itemId,
      String? imgId,
      String ordering,
      File imageFile,
      String loginUserId) async {
    final String url =
        '${PsUrl.ps_item_image_upload_url}/login_user_id/$loginUserId';

    return await postUploadItemImage<DefaultPhoto, DefaultPhoto>(
        DefaultPhoto(),
        url,
        'item_id',
        itemId,
        'img_id',
        imgId,
        'ordering',
        ordering,
        imageFile);
  }


  Future<PsResource<DefaultPhoto>> postwishItemImageUpload(
      String itemId,
      String? imgId,
      String ordering,
      File imageFile,
      String loginUserId) async {
    final String url =
        '${PsUrl.ps_wishitem_image_upload_url}/login_user_id/$loginUserId';

    return await postUploadItemImage<DefaultPhoto, DefaultPhoto>(
        DefaultPhoto(),
        url,
        'item_id',
        itemId,
        'img_id',
        imgId,
        'ordering',
        ordering,
        imageFile);
  }

  ///
  /// Image Reorder
  ///
  Future<PsResource<ApiStatus>> postReorderImages(
      List<Map<dynamic, dynamic>> jsonMap, String? loginUserId) async {
    final String url =
        '${PsUrl.ps_item_reorder_image_upload_url}/api_key/${PsConfig.ps_api_key}/login_user_id/$loginUserId';

    return await postListData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Offline Payment
  ///
  Future<PsResource<OfflinePaymentMethod>> getOfflinePaymentList(
      int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_offline_payment_method_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await getServerCall<OfflinePaymentMethod, OfflinePaymentMethod>(
        OfflinePaymentMethod(), url);
  }

  ///
  /// Search User
  ///
  Future<PsResource<List<User>>> getSearchUserList(
      Map<dynamic, dynamic> jsonMap,
      String? loginUserId,
      int limit,
      int? offset) async {
    final String url =
        '${PsUrl.ps_get_user_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await postData<User, List<User>>(User(), url, jsonMap);
  }

  ///
  /// Category
  ///
  Future<PsResource<List<Category>>> getCategoryList(
      Map<dynamic, dynamic> jsonMap,
      String? loginUserId,
      int limit,
      int? offset) async {
    final String url =
        '${PsUrl.ps_category_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';
    return await postData<Category, List<Category>>(Category(), url, jsonMap);
  }

  Future<PsResource<List<Category>>> getAllCategoryList(
      Map<dynamic, dynamic> jsonMap) async {
    const String url =
        '${PsUrl.ps_category_url}/api_key/${PsConfig.ps_api_key}';

    return await postData<Category, List<Category>>(Category(), url, jsonMap);
  }
  ///
  /// Save Entity Tags (Item or Wish)
  ///

  ///
  /// Item List From Follower
  ///
  Future<PsResource<List<Product>>> getAllItemListFromFollower(
      Map<dynamic, dynamic> jsonMap,
      String? loginUserId,
      int limit,
      int? offset) async {
    final String url =
        '${PsUrl.ps_item_list_from_followers_url}/api_key/${PsConfig.ps_api_key}/login_user_id/$loginUserId/limit/$limit/offset/$offset';

    return await postData<Product, List<Product>>(Product(), url, jsonMap);
  }

  ///
  /// Paid Ad List
  ///
  Future<PsResource<List<PaidAdItem>>> getPaidAdItemList(
      String? loginUserId, int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_paid_ad_item_list_url}/api_key/${PsConfig.ps_api_key}/login_user_id/$loginUserId/limit/$limit/offset/$offset';

    return await getServerCall<PaidAdItem, List<PaidAdItem>>(PaidAdItem(), url);
  }

  ///
  /// Sub Category
  ///
  Future<PsResource<List<SubCategory>>> getSubCategoryList(
      Map<dynamic, dynamic> jsonMap,
      String? loginUserId,
      int limit,
      int? offset) async {
    final String url =
        '${PsUrl.ps_subCategory_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await postData<SubCategory, List<SubCategory>>(
        SubCategory(), url, jsonMap);
  }

  ///
  /// Item Type
  ///
  Future<PsResource<List<ItemType>>> getItemTypeList(
      int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_item_type_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await getServerCall<ItemType, List<ItemType>>(ItemType(), url);
  }

  ///
  /// Reported Item
  ///
  Future<PsResource<List<ReportedItem>>> getReportedItemList(
      String? loginUserId, int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_reported_item_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await getServerCall<ReportedItem, List<ReportedItem>>(
        ReportedItem(), url);
  }

  ///
  /// Item Condition
  ///
  Future<PsResource<List<ConditionOfItem>>> getItemConditionList(
      int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_item_condition_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await getServerCall<ConditionOfItem, List<ConditionOfItem>>(
        ConditionOfItem(), url);
  }

  ///
  /// Item Price Type
  ///
  Future<PsResource<List<ItemPriceType>>> getItemPriceTypeList(
      int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_item_price_type_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await getServerCall<ItemPriceType, List<ItemPriceType>>(
        ItemPriceType(), url);
  }

  ///
  /// Item Currency Type

  ///
  /// Item Deal Option
  ///
  Future<PsResource<List<DealOption>>> getItemDealOptionList(
      int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_item_deal_option_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await getServerCall<DealOption, List<DealOption>>(DealOption(), url);
  }

  Future<PsResource<List<SubCategory>>> getAllSubCategoryList(
      Map<dynamic, dynamic> jsonMap, String loginUserId) async {
    final String url =
        '${PsUrl.ps_subCategory_url}/api_key/${PsConfig.ps_api_key}/login_user_id/$loginUserId';

    return await postData<SubCategory, List<SubCategory>>(
        SubCategory(), url, jsonMap);
  }

  // ── Taapdeel App Notifications ───────────────────────────────────────
  // ── Taapdeel App Notifications ───────────────────────────────────────
  Future<PsResource<List<Noti>>> getNotificationList(
      Map<dynamic, dynamic> paramMap,
      int limit,
      int? offset,
      ) async {
    final String url =
        '${PsConfig.ps_app_url}rest/app_notifications/list/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/${offset ?? 0}';

    try {
      final Map<String, String> body = <String, String>{
        'user_id': (paramMap['user_id'] ?? '').toString(),
      };


      final http.Response response = await http
          .post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      )
          .timeout(const Duration(seconds: 20));


      if (response.statusCode != 200) {
        return PsResource<List<Noti>>(
          PsStatus.ERROR,
          'HTTP ${response.statusCode}',
          <Noti>[],
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is List) {
        final List<Noti> list = decoded
            .whereType<Map>()
            .map((dynamic e) => Noti().fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();

        return PsResource<List<Noti>>(
          PsStatus.SUCCESS,
          '',
          list,
        );
      }

      if (decoded is Map<String, dynamic>) {
        final dynamic data = decoded['data'];

        if (data is List) {
          final List<Noti> list = data
              .whereType<Map>()
              .map((dynamic e) =>
              Noti().fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();

          return PsResource<List<Noti>>(
            PsStatus.SUCCESS,
            '',
            list,
          );
        }

        return PsResource<List<Noti>>(
          PsStatus.SUCCESS,
          decoded['message']?.toString() ?? '',
          <Noti>[],
        );
      }

      return PsResource<List<Noti>>(
        PsStatus.ERROR,
        'Invalid notification response',
        <Noti>[],
      );
    } on TimeoutException catch (e) {
      return PsResource<List<Noti>>(
        PsStatus.ERROR,
        'Timeout Error',
        <Noti>[],
      );
    } catch (e) {
      return PsResource<List<Noti>>(
        PsStatus.ERROR,
        e.toString(),
        <Noti>[],
      );
    }
  }
  //
  /// Product
  ///
  Future<PsResource<List<Product>>> getProductList(
      Map<dynamic, dynamic> paramMap,
      String? loginUserId,
      int limit,
      int? offset) async {
    final String url = _isMyPendingItemsRequest(paramMap, loginUserId)
        ? '${PsUrl.ps_my_pending_item_url}/limit/$limit/offset/${offset ?? 0}'
        : '${PsUrl.ps_product_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await postData<Product, List<Product>>(Product(), url, paramMap);
  }

  ///
  /// ItemDetail
  ///
  Future<PsResource<Product>> getItemDetail(
      String? itemId, String? loginUserId) async {
    final String url =
        '${PsUrl.ps_item_detail_url}/api_key/${PsConfig.ps_api_key}/id/$itemId/login_user_id/$loginUserId';

    log('url -> $url');
    return await getServerCall<Product, Product>(Product(), url);
  }

  Future<List<SweetMessage>> getReceivedSweetMessages(
      Map<dynamic, dynamic> jsonMap) async {
    final String url =
        '${PsConfig.ps_app_url}rest/Sweet_messages/get_received/api_key/${PsConfig.ps_api_key}';

    final http.Response response = await _client.post(
      Uri.parse(url),
      body: jsonMap.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    );

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      if ((decoded['status'] ?? '').toString().toLowerCase() == 'error') {
        throw Exception(decoded['message']?.toString() ?? 'Failed to load messages.');
      }

      final dynamic data = decoded['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((dynamic e) => SweetMessage.fromMap(
          Map<String, dynamic>.from(e as Map),
        ))
            .toList();
      }
    }

    return <SweetMessage>[];
  }

  Future<int> getSweetMessagesUnreadCount(
      Map<dynamic, dynamic> jsonMap) async {
    final String url =
        '${PsConfig.ps_app_url}rest/Sweet_messages/get_unread_count/api_key/${PsConfig.ps_api_key}';

    final http.Response response = await _client.post(
      Uri.parse(url),
      body: jsonMap.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    );

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      if ((decoded['status'] ?? '').toString().toLowerCase() == 'error') {
        throw Exception(decoded['message']?.toString() ?? 'Failed to load unread count.');
      }

      final dynamic data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return int.tryParse((data['unread_count'] ?? '0').toString()) ?? 0;
      }
    }

    return 0;
  }

  Future<bool> markSweetMessageRead(
      Map<dynamic, dynamic> jsonMap) async {
    final String url =
        '${PsConfig.ps_app_url}rest/Sweet_messages/mark_read/api_key/${PsConfig.ps_api_key}';

    final http.Response response = await _client.post(
      Uri.parse(url),
      body: jsonMap.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    );

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      if ((decoded['status'] ?? '').toString().toLowerCase() == 'error') {
        throw Exception(decoded['message']?.toString() ?? 'Failed to mark message as read.');
      }

      return (decoded['status'] ?? '').toString().toLowerCase() == 'success';
    }

    return false;
  }

  Future<PsResource<OwnerRelation>> getOwnerRelation({
    required String viewerId,
    required String ownerId,
  }) async {
    final String url =
        '${PsConfig.ps_app_url}rest/items/get_owner_relation/api_key/${PsConfig.ps_api_key}';

    final response = await _client.post(
      Uri.parse(url),
      body: {
        'viewer_id': viewerId,
        'owner_id': ownerId,
      },
    );

    final Map<String, dynamic> jsonMap = jsonDecode(response.body);

    if (jsonMap['status'] == 'ok' && jsonMap['data'] is Map<String, dynamic>) {
      final OwnerRelation relation =
      OwnerRelation().fromMap(jsonMap['data'] as Map<String, dynamic>);

      return PsResource<OwnerRelation>(
        PsStatus.SUCCESS,
        '',
        relation,
      );
    } else {
      return PsResource<OwnerRelation>(
        PsStatus.ERROR,
        'No relation',
        null,
      );
    }
  }

  Future<PsResource<List<Product>>> getRelatedProductList(String productId,
      String categoryId, String loginUserId, int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_relatedProduct_url}/api_key/${PsConfig.ps_api_key}/id/$productId/cat_id/$categoryId/limit/$limit/offset/$offset/login_user_id/$loginUserId';
    return await getServerCall<Product, List<Product>>(Product(), url);
  }

  ///
  /// Search Item
  ///
  Future<PsResource<List<Product>>> getItemListByUserId(
      Map<dynamic, dynamic> jsonMap,
      String? loginUserId,
      int limit,
      int? offset,
      ) async {
    final String url = _isMyPendingItemsRequest(jsonMap, loginUserId)
        ? '${PsUrl.ps_my_pending_item_url}/limit/$limit/offset/${offset ?? 0}'
        : '${PsUrl.ps_search_item_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await postData<Product, List<Product>>(Product(), url, jsonMap);
  }

  Future<void> markNotificationRead({
    required String userId,
    required String notiId,
  }) async {
    final String url =
        '${PsConfig.ps_app_url}rest/app_notifications/mark_read/api_key/${PsConfig.ps_api_key}';
    try {
      await _client.post(
        Uri.parse(url),
        body: <String, String>{
          'user_id': userId,
          'noti_id': notiId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllNotificationsRead({required String userId}) async {
    final String url =
        '${PsConfig.ps_app_url}rest/app_notifications/mark_all_read/api_key/${PsConfig.ps_api_key}';
    try {
      await _client.post(
        Uri.parse(url),
        body: <String, String>{
          'user_id': userId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadNotificationCount({
    required String userId,
    String deviceToken = '',
  }) async {
    final String url =
        '${PsConfig.ps_app_url}rest/app_notifications/unread_count/api_key/${PsConfig.ps_api_key}';
    try {
      final http.Response response = await _client.post(
        Uri.parse(url),
        body: <String, String>{
          'user_id': userId,
        },
      );

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final dynamic data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return int.tryParse((data['unread_count'] ?? '0').toString()) ?? 0;
        }
        if (decoded['count'] != null) {
          return int.tryParse(decoded['count'].toString()) ?? 0;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<PsResource<List<Product>>> getFamilyItems(
      Map<dynamic, dynamic> jsonMap,
      String userId,
      int limit,
      int? offset,
      ) async {
    final String url =
        '${PsUrl.ps_family_items_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await postData<Product, List<Product>>(Product(), url, jsonMap);
  }

  Future<PsResource<List<Product>>> getFamilyNetworkItems(
      Map<dynamic, dynamic> jsonMap,
      String userId,
      int limit,
      int? offset,
      ) async {
    final String url =
        '${PsUrl.ps_family_network_items_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$userId';

    return await postData<Product, List<Product>>(Product(), url, jsonMap);
  }

  Future<PsResource<List<Product>>> getFriendsNetworkItems(
      Map<dynamic, dynamic> jsonMap,
      String userId,
      int limit,
      int? offset,
      ) async {
    final String url =
        '${PsUrl.ps_friends_network_items_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$userId';

    return await postData<Product, List<Product>>(Product(), url, jsonMap);
  }
  ///
  /// Search Category
  ///
  Future<PsResource<List<Product>>> searchCategoryList(
      Map<dynamic, dynamic> jsonMap,
      String loginUserId,
      int limit,
      int offset,
      ) async {
    final String url =
        '${PsUrl.ps_search_category_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await postData<Product, List<Product>>(Product(), url, jsonMap);
  }

  ///
  /// Save Tags
  ///
  Future<PsResource<ApiStatus>> postSaveTags(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_entity_tags_save_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Search Sub Category
  ///
  Future<PsResource<List<Product>>> searchSubCategoryList(
      Map<dynamic, dynamic> jsonMap,
      String loginUserId,
      int limit,
      int offset,
      ) async {
    final String url =
        '${PsUrl.ps_search_sub_category_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await postData<Product, List<Product>>(Product(), url, jsonMap);
  }

  ///
  /// Sub Category Subscribe
  ///
  Future<PsResource<ApiStatus>> postSubCategorySubscribe(
      Map<dynamic, dynamic> jsonMap,
      ) async {
    const String url = '${PsUrl.ps__sub_category_subscribe_url}';

    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }


  Future<PsResource<OwnerSubcatSubscribeResponse>> getOwnerSubcatSubscribes(
      Map<dynamic, dynamic> jsonMap,
      ) async {
    const String url = PsUrl.ps_get_owner_subcat_subscribes_url;

    return await postData<OwnerSubcatSubscribeResponse, OwnerSubcatSubscribeResponse>(
      OwnerSubcatSubscribeResponse(status: '', message: <OwnerSubcatSubscribe>[]),
      url,
      jsonMap,
    );
  }
  ///
  /// Search User
  ///
  Future<PsResource<List<User>>> getUserList(
      Map<dynamic, dynamic> jsonMap, int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_search_user_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await postData<User, List<User>>(User(), url, jsonMap);
  }

  ///
  /// Block User List
  ///
  Future<PsResource<List<BlockedUser>>> getBlockedUserList(
      String? loginUserId, int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_blocked_user_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await getServerCall<BlockedUser, List<BlockedUser>>(
        BlockedUser(), url);
  }

  ///Setting
  ///

  // Future<PsResource<ShopInfo>> getShopInfo() async {
  //   const String url = '$ps_shop_info_url/api_key/${PsConfig.ps_api_key}';
  //   return await getServerCall<ShopInfo, ShopInfo>(ShopInfo(), url);
  // }

  ///Blog
  ///

  Future<PsResource<List<Blog>>> getBlogList(Map<dynamic, dynamic> paramMap,
      String loginUserId, int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_bloglist_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await postData<Blog, List<Blog>>(Blog(), url, paramMap);
  }

  ///
  /// Favourites
  ///
  Future<PsResource<List<Product>>> getFavouritesList(
      String? loginUserId, int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_favouriteList_url}/api_key/${PsConfig.ps_api_key}/login_user_id/$loginUserId/limit/$limit/offset/$offset';

    return await getServerCall<Product, List<Product>>(Product(), url);
  }


  ///
  /// Product List By Collection Id
  ///
  Future<PsResource<List<Product>>> getProductListByCollectionId(
      String collectionId, String loginUserId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_all_collection_url}/api_key/${PsConfig.ps_api_key}/id/$collectionId/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await getServerCall<Product, List<Product>>(Product(), url);
  }

  Future<PsResource<ApiStatus>> postDeleteUser(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_delete_user_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  Future<PsResource<ApiStatus>> rawRegisterNotiToken(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_noti_register_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  Future<PsResource<ApiStatus>> rawUnRegisterNotiToken(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_noti_unregister_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  Future<PsResource<Noti>> postNoti(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_noti_post_url}';
    return await postData<Noti, Noti>(Noti(), url, jsonMap);
  }

  Future<PsResource<ApiStatus>> postChatNoti(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_chat_noti_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Rating
  ///
  Future<PsResource<Rating>> postRating(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_ratingPost_url}';
    return await postData<Rating, Rating>(Rating(), url, jsonMap);
  }

  // Future<PsResource<List<Rating>>> getRatingList(
  //     String userId, int limit, int offset) async {
  //   final String url =
  //       '${PsUrl.ps_ratingList_url}/api_key/${PsConfig.ps_api_key}/user_id/$userId/limit/$limit/offset/$offset';

  //   return await getServerCall<Rating, List<Rating>>(Rating(), url);
  // }

  Future<PsResource<List<Rating>>> getRatingList(
      Map<dynamic, dynamic> jsonMap, int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_ratingList_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';
    return await postData<Rating, List<Rating>>(Rating(), url, jsonMap);
  }

  Future<PsResource<Product>> postFavourite(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_favouritePost_url}';
    return await postData<Product, Product>(Product(), url, jsonMap);
  }

  ///
  /// Gallery
  ///
  Future<PsResource<List<DefaultPhoto>>> getImageList(
      String? parentImgId, String imageType, int limit, int? offset) async {
    final String url =
        '${PsUrl.ps_gallery_url}/api_key/${PsConfig.ps_api_key}/img_parent_id/$parentImgId/img_type/$imageType/limit/$limit/offset/$offset';

    return await getServerCall<DefaultPhoto, List<DefaultPhoto>>(
        DefaultPhoto(), url);
  }

  Future<PsResource<List<Product>>> getSimilarItemsByTags(
      Map<dynamic, dynamic> jsonMap,
      String? loginUserId,
      int limit,
      int? offset,
      ) async {
    final String url =
        '${PsConfig.ps_app_url}${PsUrl.ps_similar_by_tags_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/${offset ?? 0}/login_user_id/${loginUserId ?? ''}';



    try {
      final http.Response response = await _client.post(
        Uri.parse(url),
        body: jsonMap.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
        ),
      );
      final dynamic decoded = jsonDecode(response.body);

      // ✅ Case 1: API returns raw list directly
      if (decoded is List) {
        final List<Product> products = decoded
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> e) => Product().fromMap(e))
            .toList();

        return PsResource<List<Product>>(
          PsStatus.SUCCESS,
          'success',
          products,
        );
      }

      // ✅ Case 2: API returns wrapped map {status,message,data}
      if (decoded is Map<String, dynamic>) {
        final String status = (decoded['status'] ?? '').toString().toLowerCase();
        final String message = (decoded['message'] ?? '').toString();

        final dynamic rawData = decoded['data'];
        final List<dynamic> rawList = rawData is List ? rawData : <dynamic>[];

        final List<Product> products = rawList
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> e) => Product().fromMap(e))
            .toList();

        if (status == 'success' || rawData is List) {
          return PsResource<List<Product>>(
            PsStatus.SUCCESS,
            message,
            products,
          );
        }

        return PsResource<List<Product>>(
          PsStatus.ERROR,
          message,
          <Product>[],
        );
      }

      return PsResource<List<Product>>(
        PsStatus.ERROR,
        'Invalid response format',
        <Product>[],
      );
    } catch (e) {

      return PsResource<List<Product>>(
        PsStatus.ERROR,
        e.toString(),
        <Product>[],
      );
    }
  }
  ///
  /// Contact
  ///
  Future<PsResource<ApiStatus>> postContactUs(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_contact_us_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Item Entry
  ///
  Future<PsResource<Product>> postItemEntry(
      Map<dynamic, dynamic> jsonMap, String loginUserId) async {
    final String url = '${PsUrl.ps_item_entry_url}/login_user_id/$loginUserId';
    return await postData<Product, Product>(Product(), url, jsonMap);
  }

  ///
  ///Wish Item Entry
  ///
  Future<PsResource<Product>> postWishItemEntry(
      Map<dynamic, dynamic> jsonMap, String loginUserId) async {
    final String url = '${PsUrl.ps_wish_item_entry_url}/login_user_id/$loginUserId';
    return await postData<Product, Product>(Product(), url, jsonMap);
  }


  Future<PsResource<List<ItemLocation>>> getItemLocationList(
      Map<dynamic, dynamic> jsonMap,
      String? loginUserId,
      int limit,
      int? offset) async {
    final String url =
        '${PsUrl.ps_item_location_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await postData<ItemLocation, List<ItemLocation>>(
        ItemLocation(), url, jsonMap);
  }

  Future<PsResource<List<ItemLocationTownship>>> getItemLocationTownshipList(
      Map<dynamic, dynamic> jsonMap,
      String? loginUserId,
      int limit,
      int? offset,
      String cityId) async {
    final String url =
        '${PsUrl.ps_item_location_township_url}/api_key/${PsConfig.ps_api_key}/city_id/$cityId/limit/$limit/offset/$offset';

    return await postData<ItemLocationTownship, List<ItemLocationTownship>>(
        ItemLocationTownship(), url, jsonMap);
  }

  ////
  ///  Offer sent and received
  ///
  Future<PsResource<List<Offer>>> getOfferList(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_offer_url}';

    return await postData<Offer, List<Offer>>(Offer(), url, jsonMap);
  }

  ///
  /// ChatHistory (or) GetBuyerAndSeller
  ///
  Future<PsResource<List<ChatHistory>>> getChatHistoryList(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_chat_history_url}';



    return await postData<ChatHistory, List<ChatHistory>>(
        ChatHistory(), url, jsonMap);
  }

  ///
  /// Add Chat History or Sync Chat History
  ///
  Future<PsResource<ChatHistory>> syncChatHistory(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_add_chat_history_url}';

    return await postData<ChatHistory, ChatHistory>(
        ChatHistory(), url, jsonMap);
  }

  Future<PsResource<ChatHistory>> NotifyChat(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_notify_chat_url}';

    return await postData<ChatHistory, ChatHistory>(
        ChatHistory(), url, jsonMap);
  }

  ///
  /// Accepted Offer
  ///
  Future<PsResource<ChatHistory>> acceptedOffer(
      Map<dynamic, dynamic> jsonMap, String? loginUserId) async {
    final String url =
        '${PsUrl.ps_accepted_offer_url}/login_user_id/$loginUserId';

    return await postData<ChatHistory, ChatHistory>(
        ChatHistory(), url, jsonMap);
  }

  ///
  /// Reject Offer
  ///
  Future<PsResource<ChatHistory>> rejectedOffer(
      Map<dynamic, dynamic> jsonMap, String? loginUserId) async {
    final String url =
        '${PsUrl.ps_rejected_offer_url}/login_user_id/$loginUserId';

    return await postData<ChatHistory, ChatHistory>(
        ChatHistory(), url, jsonMap);
  }

  ///
  /// get Chat History
  ///
  Future<PsResource<ChatHistory>> getChatHistory(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_get_chat_history_url}';

    return await postData<ChatHistory, ChatHistory>(
        ChatHistory(), url, jsonMap);
  }

  ///
  /// Make Mark As Sold
  ///
  Future<PsResource<ChatHistory>> makeMarkAsSold(
      Map<dynamic, dynamic> jsonMap, String? loginUserId) async {
    final String url =
        '${PsUrl.ps_mark_as_sold_url}/login_user_id/$loginUserId';

    return await postData<ChatHistory, ChatHistory>(
        ChatHistory(), url, jsonMap);
  }

  ///
  /// Mark As Sold
  ///
  Future<PsResource<Product>> markSoldOutItem(
      Map<dynamic, dynamic> jsonMap, String? loginUserId) async {
    final String url =
        '${PsUrl.ps_mark_sold_out_url}/login_user_id/$loginUserId';
    return await postData<Product, Product>(Product(), url, jsonMap);
  }

  ///
  /// Is User Bought
  ///
  Future<PsResource<ApiStatus>> makeUserBoughtItem(
      Map<dynamic, dynamic> jsonMap, String? loginUserId) async {
    final String url =
        '${PsUrl.ps_is_user_bought_url}/login_user_id/$loginUserId';

    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// About Us
  ///
  Future<PsResource<List<AboutUs>>> getAboutUsDataList() async {
    const String url =
        '${PsUrl.ps_about_us_url}/api_key/${PsConfig.ps_api_key}/';
    return await getServerCall<AboutUs, List<AboutUs>>(AboutUs(), url);
  }

  ///
  ///
  /// Delete Item Image
  ///
  Future<PsResource<ApiStatus>> deleteItemImage(
      Map<dynamic, dynamic> jsonMap, String? loginUserId) async {
    final String url =
        '${PsUrl.ps_delete_item_image_url}/login_user_id/$loginUserId';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  ///
  /// Delete Item Video
  ///
  Future<PsResource<ApiStatus>> deleItemVideo(
      Map<dynamic, dynamic> jsonMap, String loginUserId) async {
    final String url =
        '${PsUrl.ps_delete_item_video_url}/login_user_id/$loginUserId';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User Report Item
  ///
  Future<PsResource<ApiStatus>> reportItem(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_report_item_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User Block Item
  ///
  Future<PsResource<ApiStatus>> blockUser(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_block_user_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User UnBlock Item
  ///
  Future<PsResource<ApiStatus>> postUnBlockUser(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_unblock_user_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Item Paid History
  ///
  Future<PsResource<ItemPaidHistory>> postItemPaidHistory(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_item_paid_history_entry_url}';
    return await postData<ItemPaidHistory, ItemPaidHistory>(
        ItemPaidHistory(), url, jsonMap);
  }

  ///
  /// Buy Ad Post Package
  ///
  Future<PsResource<ApiStatus>> buyAdPackage(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_buy_post_packgage}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Buy Ad Post Package detail
  ///
  Future<PsResource<List<PackageTransaction>>> getPackageTransactionDetailList(
      Map<dynamic, dynamic> jsonMap,
      ) async {
    const String url = '${PsUrl.ps_buy_post_packgage_transaction_detail}';
    return await postData<PackageTransaction, List<PackageTransaction>>(
        PackageTransaction(), url, jsonMap);
  }

  ///
  /// Get Packages
  ///
  Future<PsResource<List<Package>>> getPackages() async {
    const String url = '${PsUrl.ps_get_packages}';
    return await getServerCall<Package, List<Package>>(Package(), url);
  }

  /// Reset Unread Message Count
  ///
  Future<PsResource<ChatHistory>> resetUnreadMessageCount(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_reset_unread_message_count_url}';

    return await postData<ChatHistory, ChatHistory>(
        ChatHistory(), url, jsonMap);
  }

  ///
  /// User Unread Message Count
  ///
  Future<PsResource<UserUnreadMessage>> postUserUnreadMessageCount(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_user_unread_count_url}';

    return await postData<UserUnreadMessage, UserUnreadMessage>(
        UserUnreadMessage(), url, jsonMap);
  }

  ///
  /// Chat Image Upload
  ///

  Future<PsResource<DefaultPhoto>> postChatImageUpload(
      String senderId,
      String sellerUserId,
      String buyerUserId,
      String itemId,
      String type,
      File imageFile,
      String isUserOnline,
      ) async {
    const String url = '${PsUrl.ps_chat_image_upload_url}';

    return await postUploadChatImage<DefaultPhoto, DefaultPhoto>(
        DefaultPhoto(),
        url,
        'sender_id',
        senderId,
        'seller_user_id',
        sellerUserId,
        'buyer_user_id',
        buyerUserId,
        'item_id',
        itemId,
        'type',
        type,
        'is_user_online',
        isUserOnline,
        imageFile);
  }

  ///
  /// User Delete Item
  ///
  Future<PsResource<ApiStatus>> deleteItem(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_item_delete_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User Logout
  ///
  Future<PsResource<ApiStatus>> postUserLogout(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_user_logout_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Sold out item
  ///
  Future<PsResource<List<Product>>> getSoldOutItemList(
      int limit, int? offset, String loginUserId) async {
    final String url =
        '${PsUrl.ps_sold_out_item_url}/limit/$limit/offset/$offset/login_user_id/$loginUserId';

    return await getServerCall<Product, List<Product>>(Product(), url);
  }

/// Swap Items
// Future<>
}
