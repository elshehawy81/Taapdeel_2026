import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/consts.dart';

Widget myButton({required String title, required final dynamic onTap}) {
  return InkWell(
      onTap: onTap,
      child: Container(
        // width: double.infinity,
        height: 30,
        // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Center(
            child: Text(title,
                style: TextStyle(
                    color: PaymentConsts.blueColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold))),
        decoration: BoxDecoration(
          color: PaymentConsts.yellowColor,
          borderRadius: BorderRadius.circular(PaymentConsts.borderRadius),
        ),
      ));
}
