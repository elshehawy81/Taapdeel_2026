import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showMyDialog(BuildContext context, Color? color, String title, String message,
    final dynamic onTap) {
  showDialog<AlertDialog>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: color ?? Colors.white,
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
              ),
              onPressed: onTap,
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.white,fontSize:14.sp ),
              )),
        ],
      );
    },
  );
}
