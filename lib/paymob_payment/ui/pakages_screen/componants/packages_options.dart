import 'package:flutter/material.dart';
import '../../../core/consts.dart';
import '../../../modle/subscription_packages.dart';
import 'package_widget.dart';

Widget buildPackagesOptions(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    margin: EdgeInsets.all(10),
    child: Row(
        children: List.generate(subscriptionPackages.length, (index) {
      return PackageWidget(subscriptionPackage: subscriptionPackages[index]);
    })),
    decoration: BoxDecoration(
      color: PaymentConsts.grayColor,
      borderRadius: BorderRadius.circular(PaymentConsts.borderRadius),
    ),
  );
}
