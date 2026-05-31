import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:taapdeel/repository/Common/ps_repository.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../api/ps_url.dart';
import '../config/ps_config.dart';
import '../constant/ps_constants.dart';
import '../db/common/ps_shared_preferences.dart';
import '../utils/utils.dart';


class SwapOfferCandidateItemsResult {
  const SwapOfferCandidateItemsResult({
    required this.sameRange,
    required this.higherRange,
  });

  final List<Product> sameRange;
  final List<Product> higherRange;

  int get totalCount => sameRange.length + higherRange.length;
  bool get isEmpty => totalCount == 0;
}

class SwapProductsProvider extends PsRepository {
  SwapProductsProvider({required this.sharedPref});

  PsSharedPreferences sharedPref;

  String _userId() =>
      sharedPref.shared.getString(PsConst.VALUE_HOLDER__USER_ID) ?? '';


  List<Product> _parseProductList(dynamic raw) {
    final List<Product> productsList = <Product>[];

    if (raw is List && raw.isNotEmpty) {
      for (int x = 0; x < raw.length; x++) {
        if (raw[x] is Map) {
          productsList.add(Product().fromMap(raw[x]));
        }
      }
    }

    return productsList;
  }

  Future<SwapOfferCandidateItemsResult> getSwapOfferCandidateItems({
    required String targetItemId,
    required String addedUserId,
    int maxLevel = 2,
  }) async {
    final String url =
        '${PsConfig.ps_app_url}rest/items/get_swap_offer_candidate_items/api_key/${PsConfig.ps_api_key}';

    log('url -> $url');

    final response = await http.post(
      Uri.parse(url),
      body: <String, String>{
        'target_item_id': targetItemId,
        'added_user_id': addedUserId,
        'login_user_id': addedUserId,
        'max_level': maxLevel.toString(),
      },
    );

    final dynamic parsed = json.decode(response.body);

    if (parsed is Map) {
      final List<Product> sameRange = _parseProductList(
        parsed['same_range'] ?? parsed['sameRange'] ?? parsed['same'],
      );
      final List<Product> higherRange = _parseProductList(
        parsed['higher_range'] ?? parsed['higherRange'] ?? parsed['higher'],
      );

      log('sameRange Size -> ${sameRange.length}');
      log('higherRange Size -> ${higherRange.length}');

      return SwapOfferCandidateItemsResult(
        sameRange: sameRange,
        higherRange: higherRange,
      );
    }

    if (parsed is List) {
      final List<Product> sameRange = <Product>[];
      final List<Product> higherRange = <Product>[];

      for (final dynamic item in parsed) {
        if (item is! Map) continue;

        final Product product = Product().fromMap(item);
        final String priceGroup = (item['price_group'] ?? '').toString();

        if (priceGroup == 'higher_range') {
          higherRange.add(product);
        } else {
          sameRange.add(product);
        }
      }

      return SwapOfferCandidateItemsResult(
        sameRange: sameRange,
        higherRange: higherRange,
      );
    }

    return const SwapOfferCandidateItemsResult(
      sameRange: <Product>[],
      higherRange: <Product>[],
    );
  }

  Future<List<Product>> getSwapProducts(
      String? itemPriceType, String userId) async {
    final List<Product> productsList = <Product>[];
    final String url =
        '${PsConfig.ps_app_url}rest/items/get_price_range_items/api_key/${PsConfig.ps_api_key}';

    log('url -> $url');

    final response = await http.post(
      Uri.parse(url),
      body: <String, String?>{
        'added_user_id': userId,
        'item_price_type': itemPriceType,
      },
    );

    final dynamic parsed = json.decode(response.body);

    if (parsed is List && parsed.isNotEmpty) {
      for (int x = 0; x < parsed.length; x++) {
        productsList.add(Product().fromMap(parsed[x]));
      }
    }

    log('productList Size -> ${productsList.length}');
    return productsList;
  }

  Future<List<Product>> getSwapLowRangeProducts(
      String? itemPriceType, String userId) async {
    final List<Product> productsList = <Product>[];
    final String url =
        '${PsConfig.ps_app_url}rest/items/get_low_price_range_items/api_key/${PsConfig.ps_api_key}';

    log('url -> $url');

    final response = await http.post(
      Uri.parse(url),
      body: <String, String?>{
        'added_user_id': userId,
        'item_price_type': itemPriceType,
      },
    );

    final dynamic parsed = json.decode(response.body);

    if (parsed is List && parsed.isNotEmpty) {
      for (int x = 0; x < parsed.length; x++) {
        productsList.add(Product().fromMap(parsed[x]));
      }
    }

    log('productList Size -> ${productsList.length}');
    return productsList;
  }

  Future<String> addPriceOffer(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_add_chat_history_url}';

    final Response response = await http
        .post(
      Uri.parse('${PsConfig.ps_app_url}$url'),
      headers: <String, String>{'content-type': 'application/json'},
      body: const JsonEncoder().convert(jsonMap),
    )
        .catchError((dynamic e) {
      debugPrint('** Error Post Data');
      debugPrint('$e');
      return http.Response('{}', 500);
    });

    log('add -> url -> ${'${PsConfig.ps_app_url}$url'} \nResponse -> ${response.body}');

    if (response.statusCode == 200) {
      final String chId = json.decode(response.body)['id'];
      jsonMap['id'] = chId;
      jsonMap['type'] = 'to_seller';
      return 'success';
    } else {
      return 'failed';
    }
  }

  Future<String> rejectOffer(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_rejected_offer_url}';

    final Response response = await http
        .post(
      Uri.parse('${PsConfig.ps_app_url}$url'),
      headers: <String, String>{'content-type': 'application/json'},
      body: const JsonEncoder().convert(jsonMap),
    )
        .catchError((dynamic e) {
      debugPrint('** Error Post Data');
      debugPrint('$e');
      return http.Response('{}', 500);
    });

    log('url -> ${'${PsConfig.ps_app_url}$url'} \nResponse -> ${response.body}');
    return response.statusCode == 200 ? 'success' : 'failed';
  }

  Future<String> approveRequest(Map<String, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_accepted_offer_url}';

    final Response response = await http
        .post(
      Uri.parse('${PsConfig.ps_app_url}$url'),
      headers: <String, String>{'content-type': 'application/json'},
      body: const JsonEncoder().convert(jsonMap),
    )
        .catchError((dynamic e) {
      debugPrint('** Error Post Data');
      debugPrint('$e');
      return http.Response('{}', 500);
    });

    log('url -> ${'${PsConfig.ps_app_url}$url'} \nResponse -> ${response.body}');
    approveOffer(jsonMap);
    return response.statusCode == 200 ? 'success' : 'failed';
  }

  String statusString(BuildContext context, String type) {
    String status = '';

    switch (type) {
      case PsConst.REQUEST_PENDING:
        status = Utils.getString(context, 'request_pending');
        break;
      case PsConst.REQUEST_ACCEPTED:
        status = Utils.getString(context, 'request_accepted');
        break;
      case PsConst.REQUEST_SWAPPED:
        status = Utils.getString(context, 'request_swapped');
        break;
      case PsConst.REQUEST_REJECTED:
        status = Utils.getString(context, 'request_rejected');
        break;
    }

    return status;
  }

  Future<String> approveOffer(Map<String, dynamic> jsonMap) async {
    String responseMessage = '';
    log('approve offer Map $jsonMap');

    final String url =
        '${PsConfig.ps_app_url}${PsUrl.ps_accepted_offer_url}/login_user_id/${_userId()}';

    log('approve offer $url');

    final response = await http.post(Uri.parse(url), body: jsonMap);
    log('approve offer Code = ${response.statusCode} -- ${response.body}');

    if (response.statusCode == 200) {
      responseMessage = 'Success';
    } else {
      responseMessage = json.decode(response.body)['message'];
    }

    return responseMessage;
  }

  Future<dynamic> makeMarkAsSold(
      Map<dynamic, dynamic> jsonMap, String? loginUserId) async {
    final String userBoughtUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_is_user_bought_url}/login_user_id/$loginUserId';

    final String markAsSoldUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_mark_as_sold_url}/login_user_id/$loginUserId';

    jsonMap['is_user_online'] = '1';

    final response2 = await http.post(Uri.parse(userBoughtUrl), body: jsonMap);
    log('response 2 == ${response2.body}');

    final response = await http.post(Uri.parse(markAsSoldUrl), body: jsonMap);
    log('response 1 == ${response.body}');

    await incrementSwapNumber('${jsonMap['seller_user_id']}');
    await incrementUserPoints10('${jsonMap['seller_user_id']}');
    await incrementSwapNumber('${jsonMap['buyer_user_id']}');
    await incrementUserPoints10('${jsonMap['buyer_user_id']}');

    return 'Done';
  }

  Future<dynamic> BuyermakeMarkAsSold(
      Map<dynamic, dynamic> jsonMap, String? loginUserId) async {
    final String buyerMarkAsSoldUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_Buyer_mark_as_sold_url}/login_user_id/$loginUserId';

    final response3 =
    await http.post(Uri.parse(buyerMarkAsSoldUrl), body: jsonMap);

    log('response 3 == ${response3.body}');
    return 'Done';
  }

  Future<dynamic> BuyerMarkNotSold(
      Map<dynamic, dynamic> jsonMap, String? loginUserId) async {
    final String buyerMarkAsSoldUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_Buyer_mark_Not_sold_url}/login_user_id/$loginUserId';

    final response3 =
    await http.post(Uri.parse(buyerMarkAsSoldUrl), body: jsonMap);

    log('response 3 == ${response3.body}');
    return 'Done';
  }

  Future<String?> decrementSwapBalance(String userId) async {
    try {
      debugPrint('SWAP START');
      const String url =
          '${PsConfig.ps_app_url}${PsUrl.ps_swap_balance_decrease_url}';

      debugPrint('SWAP User: ');

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{'user_id': userId}),
      );

      debugPrint('Decrement Swap');
      debugPrint(jsonDecode(response.body).toString());

      return jsonDecode(response.body)['status'];
    } catch (e) {
      debugPrint('SWAP $e');
    }
    return null;
  }

  Future<String?> incrementSwapNumber(String userId) async {
    try {
      debugPrint('SWAP START');
      const String url =
          '${PsConfig.ps_app_url}${PsUrl.ps_swap_no_increase_url}';

      debugPrint('SWAP User: ');

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{'user_id': userId}),
      );

      return jsonDecode(response.body)['status'];
    } catch (e) {
      debugPrint('SWAP $e');
    }
    return null;
  }

  Future<String?> incrementSwapBalance(String userId) async {
    try {
      debugPrint('SWAP START');
      const String url =
          '${PsConfig.ps_app_url}${PsUrl.ps_swap_balance_increase_url}';

      debugPrint('SWAP User: ');

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{'user_id': userId}),
      );

      return jsonDecode(response.body)['status'];
    } catch (e) {
      debugPrint('SWAP $e');
    }
    return null;
  }

  Future<String?> incrementUserPoints10(String userId) async {
    try {
      debugPrint('SWAP START');
      const String url =
          '${PsConfig.ps_app_url}${PsUrl.ps_points_increase10_url}';

      debugPrint('SWAP User: ');

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{'user_id': userId}),
      );

      return jsonDecode(response.body)['status'];
    } catch (e) {
      debugPrint('SWAP $e');
    }
    return null;
  }
}