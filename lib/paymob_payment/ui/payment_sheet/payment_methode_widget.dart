import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/consts.dart';
import '../../modle/billing_data.dart';
import '../../modle/subscription_packages.dart';
import 'componants/pay_with_card.dart';
import 'componants/take_wallet_number.dart';

class PaymentMethodeWidget extends StatelessWidget {
  PaymentMethodeWidget(
      {
      required this.methodeName,
      required this.image,
      required this.subscriptionPackage,
      required this.paymetMethod,
        required this.fromPromoteScreen,
this.promoteFunction
      });

  bool fromPromoteScreen  ;
  dynamic promoteFunction ;
  String methodeName;
  String image;
  double price = 0;
  SubscriptionPackage subscriptionPackage;
  PaymetMethods paymetMethod;
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: PaymentConsts.screenUtilSize);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: () {
          paymetMethod == PaymetMethods.Card
              ? payWithCardButton(context, subscriptionPackage,fromPromoteScreen:fromPromoteScreen,promoteFunction: promoteFunction)
              : showPhoneNumberDialog(context, subscriptionPackage,fromPromoteScreen,promoteFunction);
        },
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Text(
                          'pay_with',
                          style: TextStyle(fontSize: 20.sp),
                        ).tr(),
                        Text(
                          methodeName.toString(),
                          style: TextStyle(
                              fontSize: 20.sp,
                              color:PaymentConsts. blueColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                Expanded(
                  flex: 2,
                  child: Image.asset(image.toString()),
                )
              ],
            ),
          ),
          height: 100,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15))),
        ),
      ),
    );
  }
}

enum PaymetMethods { Wallet, Card }

Widget walletTextFeild(TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        hintText: 'enter_your_wallet_number'.tr(),
        hintStyle: TextStyle(color: Colors.grey,fontSize: 25.sp),
        border: InputBorder.none),
    keyboardType: TextInputType.number,
  );
}

BillingData defultBillingData = BillingData(
  email: "Unknown@gmail.com",
  firstName: "Unknown name ",
  lastName: "unknown feild",
  phoneNumber: "01011403690",
);
