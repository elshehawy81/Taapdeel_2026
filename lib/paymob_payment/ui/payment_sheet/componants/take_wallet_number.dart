import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../../../core/consts.dart';
import '../../../modle/billing_data.dart';
import '../../../modle/subscription_packages.dart';
import '../../../payment_provider.dart';
import '../../pakages_screen/packages_screen.dart';
import '../../../functions.dart';
import 'pay_with_wallet.dart';

class PhoneNumberDialog extends StatefulWidget {
  PhoneNumberDialog(this.subscriptionPackage,this.fromPromoteScreen,this.promoteFunction);
bool fromPromoteScreen;
  SubscriptionPackage subscriptionPackage;
  dynamic promoteFunction;
  @override
  _PhoneNumberDialogState createState() => _PhoneNumberDialogState();
}

class _PhoneNumberDialogState extends State<PhoneNumberDialog> {
  late TextEditingController _controller;
  final _formkey = GlobalKey<FormState>();
  String phoneNumber = '';
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var loading = Provider.of<PaymentProvider>(context, listen: true).isLoading;
    var provi = Provider.of<PaymentProvider>(context, listen: false);
    ScreenUtil.init(context, designSize: PaymentConsts.screenUtilSize);

    return ModalProgressHUD(
      inAsyncCall: loading,
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: Text('enter_your_wallet_number',style: TextStyle(fontSize: 18.sp),).tr(),
        content: Form(
          key: _formkey,
          child: TextFormField(
            keyboardType: TextInputType.phone,
            validator: (val) {
              if (val!.isEmpty || val.length != 11) {
                return 'invalid_phone_number'.tr();
              }
              return null;
            },
            onSaved: (val) {
              provi.changeLoading(true);
              setState(() {
                phoneNumber = val!;
              });
            },
            decoration: InputDecoration(
              hintText: 'wallet_number'.tr(),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('cancel').tr(),
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(PaymentConsts.lightGreen)),
            onPressed: () {
              if (_formkey.currentState!.validate()) {
                _formkey.currentState!.save();
                payWithWalletButton(fromPromoteScreen:widget.fromPromoteScreen ,

                    context: context,
                    billingData: BillingData(phoneNumber: phoneNumber),
                    subscriptionPackage: widget.subscriptionPackage,
                    promoteFunction:widget.promoteFunction
                );
              }
            },
            child: Text(
              'pay'.tr(),
              style: TextStyle(color: Colors.black,fontSize:15.sp),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

void showPhoneNumberDialog(
    BuildContext context, SubscriptionPackage subscriptionPackage,bool fromPromoteScreen,dynamic promoteFunction) {
  showDialog<AlertDialog>(
    context: context,
    builder: (BuildContext context) {
      return PhoneNumberDialog(subscriptionPackage,fromPromoteScreen, promoteFunction);
    },
  );
}

class RedeemDialog extends StatefulWidget {
  RedeemDialog({ required this.subscriptionPackage});
  SubscriptionPackage subscriptionPackage;
  @override
  State<RedeemDialog> createState() => _RedeemDialogState();
}

class _RedeemDialogState extends State<RedeemDialog> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize:PaymentConsts.screenUtilSize);
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: Text('confirmation').tr(),
        content: Text(
          'redeem_confirmation',
          style: TextStyle(fontSize: 30.sp),
        ).tr(),
        actions: [
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(PaymentConsts.lightGreen),
              ),
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                await packageRedeemTransaction(
                        points: widget.subscriptionPackage.requiredPoints,
                        swapRequests: widget.subscriptionPackage.swapRequests,
                        userId: PaymentConsts.userID,
                        context: context,
                        apiKey:PaymentConsts. apiKey)
                    .then((value) {
                  setState(() {
                    loading = false;
                  });
                  Navigator.pop(context);
                  if (value == true) {
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //     backgroundColor: lightGreen,
                    //     content: Text(
                    //       '${subscriptionPackage.swapRequests} Swap Requests added successfully',
                    //     )));
                  } else {}
                }).catchError((dynamic e) {
                  setState(() {
                    loading = false;
                  });
                  // showMyDialog(context, lightRed, 'Error', e.toString(), () {
                  //   Navigator.pop(context);
                  // });
                });
              },
              child: Text(
                'yes',
                style: TextStyle(color: Colors.black,fontSize: 17.sp),
              ).tr()),
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(PaymentConsts.lightRed),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'no',
                style: TextStyle(color: Colors.black,fontSize: 17.sp),
              ).tr()),
        ],
      ),
    );
  }
}
