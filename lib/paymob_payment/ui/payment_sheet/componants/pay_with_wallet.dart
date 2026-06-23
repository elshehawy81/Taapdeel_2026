import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/consts.dart';
import '../../../modle/billing_data.dart';
import '../../../modle/subscription_packages.dart';
import '../../../payment_provider.dart';
import '../../../paymob_integration/flutter_paymob.dart';
import '../../shared/my_dialog.dart';
import '../../../functions.dart';

dynamic payWithWalletButton(
    {required BuildContext context,
    BillingData? billingData,
      required SubscriptionPackage subscriptionPackage,required bool fromPromoteScreen,dynamic promoteFunction}) {
  var provi = Provider.of<PaymentProvider>(context, listen: false);

  FlutterPaymob.instance.payWithWallet(
    fromPromoteScreen:fromPromoteScreen,
    context: context,
    currency: "EGP",
    amount: double.parse(subscriptionPackage.egpPrice.toString()),
    onPayment: (response) {
      provi.changeLoading(false);

      if (response.success == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: PaymentConsts.lightRed,
            content: Text(
              response.message ?? "payment_error".tr(),
              style: TextStyle(color: Colors.black,fontSize: 20.sp),
            ),
          ),
        );
      }
      if (response.success == true) {
        if (fromPromoteScreen == false) {
          addSwapRequests(
              context: context,
              userId: PaymentConsts.userID,
              swapRequests: subscriptionPackage.swapRequests,
              apiKey: PaymentConsts.apiKey,
              fromPoints: false
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: PaymentConsts.lightGreen,
              content: Text(
                response.message ??
                    "${subscriptionPackage.swapRequests} " +
                        "requests_added".tr(),
                style: TextStyle(color: Colors.black, fontSize: 20.sp),
              ),
            ),
          );
        } else {
          promoteFunction();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor:PaymentConsts. lightGreen,
              content: Text(
                response.message ??
                    "Success",
                style: TextStyle(color: Colors.black,fontSize: 20.sp),
              ),
            ),
          );
        }
      }},
    number: billingData!.phoneNumber.toString(),
  );
}
