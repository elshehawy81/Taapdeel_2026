import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../../core/consts.dart';
import '../../modle/subscription_packages.dart';
import '../../payment_provider.dart';
import 'payment_methode_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Widget paymentMethodesSheet(SubscriptionPackage subscriptionPackage) {
//   return DraggableScrollableSheet(
//     shouldCloseOnMinExtent: true,
//     minChildSize: 0.5,
//     // snap: true,
//     //expand: true,
//     initialChildSize: 1,
//     maxChildSize: 1,
//     builder: ((context, scrollController) {
//       return ClipRRect(
//         borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20), topRight: Radius.circular(20)),
//         child: Container(
//           color: Color.fromARGB(255, 235, 235, 235),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Text(
//                     'Choose payment method',
//                     style: TextStyle(fontSize: 20, color: blueColor),
//                   ),
//                 ),
//                 PaymentMethodeWidget(
//                     methodeName: 'E-wallets',
//                     image: eWalletsImage,
//                     subscriptionPackage: subscriptionPackage,
//                       paymetMethod:  PaymetMethods.Wallet

//                     ),
//                 PaymentMethodeWidget(
//                     methodeName: 'Card',
//                     image: cardImage,
//                     subscriptionPackage: subscriptionPackage,
//                     paymetMethod:  PaymetMethods.Card
//                     ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }),
//   );
// }

class PaymentMethodesSheet extends StatefulWidget {
   PaymentMethodesSheet({required this.subscriptionPackage,required this.fromPromoteScreen,this.promoteFunction});
  SubscriptionPackage subscriptionPackage;
  bool fromPromoteScreen =false ;
  dynamic promoteFunction;
  @override
  State<PaymentMethodesSheet> createState() => _PaymentMethodesSheetState();
}

class _PaymentMethodesSheetState extends State<PaymentMethodesSheet> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: PaymentConsts.screenUtilSize);

    var loading =Provider.of<PaymentProvider>(context, listen: true).isLoading;
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: DraggableScrollableSheet(
        //shouldCloseOnMinExtent: true,
        minChildSize:1,
        initialChildSize: 1,
        maxChildSize:1 ,
        expand:true,
        builder: ((context, scrollController) {
          return ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Container(
              height: 600,
              color: Color.fromARGB(255, 235, 235, 235),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'choose_payment_method'.tr(),
                        style: TextStyle(fontSize: 30.sp, color: PaymentConsts.blueColor),
                      ),
                    ),
                    PaymentMethodeWidget(
                         fromPromoteScreen :widget .fromPromoteScreen ,
                        methodeName: 'e-wallets'.tr(),
                        image: PaymentConsts.eWalletsImage,
                        subscriptionPackage: widget.subscriptionPackage,
                        paymetMethod: PaymetMethods.Wallet,
                        promoteFunction:widget.promoteFunction
                    ),
                    PaymentMethodeWidget(
                        fromPromoteScreen :widget.fromPromoteScreen ,
                        methodeName: 'card'.tr(),
                        image:PaymentConsts. cardImage,
                        subscriptionPackage:widget.subscriptionPackage,
                        paymetMethod: PaymetMethods.Card,
                        promoteFunction:widget.promoteFunction),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
