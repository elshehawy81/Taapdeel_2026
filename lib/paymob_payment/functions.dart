import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/ps_config.dart';
import 'core/consts.dart';
import 'modle/user_balance_model.dart';
import 'payment_provider.dart';
import 'ui/pakages_screen/packages_screen.dart';
import 'ui/shared/my_dialog.dart';

Future<String?> getSharedPrefUserId() async {
//  SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? storedUserId = prefs.getString(PsConst.VALUE_HOLDER__USER_ID);
//   return storedUserId??'usrc4671476b2872f12ec4e5848d0619b6b';
}

Future<UserBalanceModel?> getUserData(
    {required String apiKey,
    required String userId,
    required BuildContext context}) async {
  try {
    final response = await http.get(Uri.parse(
        '${PsConfig.ps_core_url}/index.php/rest/users/get/api_key/$apiKey/user_id/$userId'));
    if (response.statusCode == 200) {
      UserBalanceModel? userBalanceModel;
      final List<dynamic> responseData = jsonDecode(response.body);
      userBalanceModel = UserBalanceModel.fromJson(responseData[0]);
      Provider.of<PaymentProvider>(context, listen: false)
          .setUserModel(userBalanceModel);
      print('From User Get Methode ');
      print(userBalanceModel.points);
      return userBalanceModel;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      return null;
    }
  } catch (e) {
    showMyDialog(context, const Color.fromARGB(255, 255, 169, 163), 'error'.tr(),
        'loading_user_error_msg'.tr(), () {
      Navigator.of(context).pop();
    });
    print(e);
    return null;
  }
}

Future<bool?> packageRedeemTransaction(
    {required int points,
    required int swapRequests,
    required String userId,
    required BuildContext context,
    required String apiKey}) async {
  await decreasePoints(
          context: context, userId: userId, points: points, apiKey: apiKey)
      .then((value) async {
    if (value == true) {
      await addSwapRequests(
              context: context,
              userId: userId,
              swapRequests: swapRequests,
              apiKey: apiKey,
              fromPoints: true)
          .then((bool value) {
        return true;
      }).catchError((Object e) {
        print(e);
        return false;
      });
    } else {
      return false;
    }
  }).catchError((Object e) {
    print(e);
    return false;
  });
}

Future<bool?> decreasePoints(
    {required BuildContext context,
    required String userId,
    required int points,
    required String apiKey}) async {
  try {
    final url = Uri.parse(
        '${PsConfig.ps_core_url}/index.php/rest/Users/points_decrease$points/api_key/$apiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_id': userId,
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      Map<String, dynamic> responseMap = jsonDecode(response.body);
      String message = responseMap['message'];
      print('Error: $message');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: PaymentConsts.lightRed,
          content: Text(
            'Error: $message',
            style: TextStyle(color: Colors.black),
          )));
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: PaymentConsts.lightRed,
        content: Text('Error occurs while decreasing your points',
            style: TextStyle(color: Colors.black))));
    print(e);
    return false;
  }
}

Future<bool> addSwapRequests(
    {required BuildContext context,
    required String userId,
    required int swapRequests,
    required String apiKey,
    required bool fromPoints}) async {
  try {
    final url = Uri.parse(
        '${PsConfig.ps_core_url}/index.php/rest/Users/swap_balance_increase$swapRequests/api_key/$apiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_id': userId,
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print('-------------------------');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: PaymentConsts.lightGreen,
          content: Text('${swapRequests} '+'requests_added'.tr(),
              style: TextStyle(color: Colors.black))));
      return true;

    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
