import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../modle/billing_data.dart';
import '../modle/user_balance_model.dart';
import '../payment_provider.dart';
import 'constants.dart';
import 'paymob_iframe.dart';
import '../modle/paymob_response.dart';

class FlutterPaymob {
  late String _authKey;
  late String _authToken;
  late var _paymentKey= '';
  late String _iFrameURL;
  late String _walletURL;
  late int _iFrameID;
  late int _integrationId;
  late int _walletIntegrationId;
  late int _orderId;
  late int _userTokenExpiration;
  bool _isInitialized = false;
  static FlutterPaymob instance = FlutterPaymob();
  Constants constants = Constants.production();


  Future<bool> initialize({
    required String apiKey,
    int? integrationID,
    int? walletIntegrationId,
    required int iFrameID,
    int userTokenExpiration = 3600,
  }) async {
    if (_isInitialized) {
      return true;
    }
    _authKey = apiKey;
    _integrationId = integrationID!;
    _walletIntegrationId = walletIntegrationId!;
    _iFrameID = iFrameID;
    _iFrameURL =
    'https://accept.paymobsolutions.com/api/acceptance/iframes/$_iFrameID?payment_token=';
    _isInitialized = true;
    _userTokenExpiration = userTokenExpiration;
    return _isInitialized;
  }

  var headers = {'Content-Type': 'application/json'};

  Future<String> _getApiKey() async {
    Map<String, dynamic> requestBody =<String, dynamic> {"api_key": _authKey};
    String requestBodyJson = jsonEncode(requestBody);
    http.Response response = await http.post(
      Uri.parse(constants.authorization),
      body: requestBodyJson,
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _authToken = jsonDecode(response.body)["token"];
      // print('_authToken');
      // print(_authToken);
      return _authToken;
    } else {
      // print('error in _getApiKey function');
      throw "Error";
    }
  }

  Future<int> _getOrderId(double amount, String currency) async {
    Map<String, dynamic> requestBody = <String, dynamic>{
      "auth_token": _authToken,
      "delivery_needed": "false",
      "amount_cents": "${amount * 100}",
      "currency": currency,
      //"items": [""]
    };
    String requestBodyJson = jsonEncode(requestBody);
    http.Response response = await http.post(Uri.parse(constants.order),
        body: requestBodyJson, headers: headers);
    if (response.statusCode >= 200) {
      _orderId = jsonDecode(response.body)["id"];
      // print('_orderId');
      // print(_orderId);
      return _orderId;
    } else {
      throw "Error";
    }
  }

  Future<String> _requestToken({
    required double amount,
    required String currency,
    required String integrationId,
    required BillingData billingData,
  }) async {
    Map<String, dynamic> requestBody = <String, dynamic>{
      "auth_token": _authToken,
      "expiration": _userTokenExpiration,
      "amount_cents": "${amount * 100}",
      "order_id": _orderId,
      "billing_data": billingData.toJson(),
      "currency": currency,
      "integration_id": integrationId,
      "lock_order_when_paid": "false"
    };
    String requestBodyJson = jsonEncode(requestBody);
    http.Response response = await http.post(Uri.parse(constants.keys),
        body: requestBodyJson, headers: headers);
    if (response.statusCode >= 200) {
      if (response.body == null) {
        throw "Response body is null";
      }
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      // print(responseBody);
      if (responseBody["token"] == null || !(responseBody["token"] is String)) {
        throw "Token is null or not a string";
      }
      _paymentKey = responseBody["token"];
      // print("_requestToken");
      // print(_paymentKey);
      return _paymentKey;
    } else {
      throw "Error";
    }
  }

  Future<String> _requestUrlWallet({
    required String number,
  }) async {
    Map<String, dynamic> requestBody =<String, dynamic> {
      "source": {"identifier": number, "subtype": "WALLET"},
      "payment_token": _paymentKey
    };
    String requestBodyJson = jsonEncode(requestBody);
    http.Response response = await http.post(Uri.parse(constants.wallet),
        body: requestBodyJson, headers: headers);
    if (response.statusCode >= 200) {
      _walletURL = jsonDecode(response.body)["redirect_url"];
      return _walletURL;
    } else {
      throw "Error";
    }
  }

  Future payWithCard({
    required BuildContext context,
    required String currency,
    required double amount,
    required bool fromPromoteScreen,
    void Function(PaymentPaymobResponse response)? onPayment,
  }) async {
    UserBalanceModel? userModel =
    Provider.of<PaymentProvider>(context, listen: false).getUserModel();
    print(userModel?.userName);
    print(userModel?.userEmail);
    await _getApiKey();
    await _getOrderId(amount, currency);
    await _requestToken(
        integrationId: _integrationId.toString(),
        amount: amount,
        currency: currency,
        billingData: BillingData(
            firstName: userModel?.userName ?? 'Name',
            email: userModel?.userEmail ?? 'email@gmail') ??
            BillingData());
    if (context.mounted) {
      final response = await PaymobIFrame.show(
        context: context,
        redirectURL: "$_iFrameURL$_paymentKey",
        onPayment: onPayment,
          fromPromoteScreen:fromPromoteScreen
      );
      return response;
    }
    return null;
  }

  Future payWithWallet({
    required BuildContext context,
    required String currency,
    required String number,
    required double amount,
    required bool fromPromoteScreen,
    void Function(PaymentPaymobResponse response)? onPayment,
  }) async {
    UserBalanceModel? userModel =
    Provider.of<PaymentProvider>(context, listen: false).getUserModel();
    await _getApiKey();
    await _getOrderId(amount, currency);
    await _requestToken(
        integrationId: _walletIntegrationId.toString(),
        amount: amount,
        currency: currency,
        billingData: BillingData(
            firstName: userModel?.userName ?? 'Name',
            email: userModel?.userEmail ?? 'email@gmail.com') ??
            BillingData());
    await _requestUrlWallet(number: number);
    if (context.mounted) {
      final response = await PaymobIFrame.show(
        context: context,
        redirectURL: _walletURL,
        onPayment: onPayment,
          fromPromoteScreen:fromPromoteScreen
      );
      return response;
    }
    return null;
  }
}
