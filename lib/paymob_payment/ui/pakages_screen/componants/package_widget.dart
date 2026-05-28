import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taapdeel/paymob_payment/modle/subscription_packages.dart';
import '../../../core/consts.dart';
import '../../payment_sheet/componants/take_wallet_number.dart';
import '../../payment_sheet/payment_methodes_sheet.dart';
import '../../shared/my_button.dart';
import '../../../functions.dart';

class PackageWidget extends StatelessWidget {
  PackageWidget({ required this.subscriptionPackage});
  SubscriptionPackage subscriptionPackage;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: PaymentConsts.screenUtilSize);

    return Expanded(
      child: Container(
        //padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: EdgeInsets.all(5),
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PaymentConsts.borderRadius),
        ),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 5,
                ),
                Column(children: [
                  Text(
                    '${subscriptionPackage.swapRequests}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: PaymentConsts.blueColor),
                  ),
                  Text(
                    'swap_requests'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: PaymentConsts.blueColor,fontSize:24.sp),
                  ),
                ]),
                Container(
                  decoration: BoxDecoration(
                    color: PaymentConsts.blueColor,
                    borderRadius:
                        BorderRadius.circular(PaymentConsts.borderRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${subscriptionPackage.requiredPoints} \n'+'point'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            myButton(
                                title: 'redeem'.tr(),
                                onTap: () {
                                  // showRedeemDialog(
                                  //   context,
                                  //   subscriptionPackage,
                                  // );
                                  showDialog<AlertDialog>(
                                      context: context,
                                      builder: (context) {
                                        return RedeemDialog(
                                          subscriptionPackage:
                                              subscriptionPackage,
                                        );
                                      });
                                })
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 80,
                        color: Colors.white,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: Text(
                                '${subscriptionPackage.egpPrice} \n '+'EGP'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            myButton(
                                title: 'buy'.tr(),
                                onTap: () {
                                  showModalBottomSheet<DraggableScrollableSheet>(
                                      elevation: 18,
                                      showDragHandle: true,
                                      isDismissible: true,
                                      context: context,
                                      builder: (context) {
                                        return PaymentMethodesSheet(
                                            subscriptionPackage:
                                                subscriptionPackage,fromPromoteScreen: false,);
                                      });
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
    ;
  }
}

void showRedeemDialog(
  BuildContext context,
  SubscriptionPackage subscriptionPackage,
) {
  showDialog<AlertDialog>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('confirmation').tr(),
        content: Text(
          "redeem_confirmation",
          style: TextStyle(fontSize: 16.sp),
        ).tr(),
        actions: [
          FilledButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(PaymentConsts.lightGreen),
              ),
              onPressed: () async {
                await packageRedeemTransaction(
                        points: subscriptionPackage.requiredPoints,
                        swapRequests: subscriptionPackage.swapRequests,
                        userId: PaymentConsts.userID,
                        context: context,
                        apiKey: PaymentConsts.apiKey)
                    .then((value) {
                  if (value == true) {
                  } else {}
                }).catchError((dynamic e) {});
              },
              child: Text(
                'yes'.tr(),
                style: TextStyle(color: Colors.black,fontSize: 20.sp),
              )),
          FilledButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(PaymentConsts.lightRed),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'no'.tr(),
                style: TextStyle(color: Colors.black,fontSize: 20.sp),
              )),
        ],
      );
    },
  );
}
