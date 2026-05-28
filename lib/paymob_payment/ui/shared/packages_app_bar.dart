import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constant/route_paths.dart';
import '../../core/consts.dart';

Widget paymentAppBar(BuildContext context) {
  return Container

    (
    margin: EdgeInsets.only(top: 10),
    height: 70,width: double.infinity,color:Colors.white,child: Row(
    children: [
      SizedBox(width: 10,),
      InkWell(onTap: (){print("To Home");
      Navigator.pushReplacementNamed(context,RoutePaths.home);},child:Icon(
        Icons.arrow_back,
        color:PaymentConsts. blueColor,
        size: 34,
      ), ),

      Image.asset(
        PaymentConsts. appLogo,
        height: 40,
        width: 40,
      ),
      SizedBox(width: 14),
      Text(
        'packages_details',
        style: TextStyle(
            color: PaymentConsts.blueColor, fontSize: 20.sp, fontWeight: FontWeight.bold),
      ).tr()
    ],
  ),);
}
