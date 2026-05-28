import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/ps_constants.dart';
import '../../db/common/ps_shared_preferences.dart';
import 'dart:ui';

/*
Card Number	5123456789012346

Expiry Month	12
Expiry Year	25
CVV	123

*/

class PaymentConsts {
  static const Color grayColor = Color(0x15505050);
  static const Color yellowColor = Color(0xffFFD35A);
  static const Color blueColor = Color(0xff2D5E89);
  static const double borderRadius = 8;
  static const String appLogo = 'assets/images/Taapdeel_logo.png';
  static const String cardImage = 'assets/images/card.png';
  static const String eWalletsImage = 'assets/images/wallet.png';
  static const String apiKey = PsConfig.ps_api_key;
  static const Color lightGreen = Color.fromARGB(255, 156, 255, 161);
  static const Color lightRed = Color.fromARGB(255, 255, 156, 156);
  static String userID =  PsSharedPreferences.instance.shared
      .getString(PsConst.VALUE_HOLDER__USER_ID)!;

  static var screenUtilSize = Size(393, 830);
      //'usr5891e79d9a1d3ec87d541802db79dacd';
  //'usrc4671476b2872f12ec4e5848d0619b6b';

  static String congratsAnimation = 'assets/animations/celebratAnimation.json';
}

class PaymobConsts {
  static const String apiKey ="ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2T1RVNU1qVTFMQ0p1WVcxbElqb2lhVzVwZEdsaGJDSjkudWNCUHFEdllWQzgwM1lKVU5FaVExZVFwdlBCV2NvZjFZcGlDdjFvTXBRbFViVE9EY3BEbHJuYnU1WGVBby1jSDZmSDdGaURESGR6QUl4alFZdzRJV0E=";
  static int cardIntegrationId = 4484314;
  static int walletIntegrationId = 4486274;
  static int kioskIntegrationId = 4486275;
  static int iFrame = 824240;
}
//PsApiService.ps_app_url

