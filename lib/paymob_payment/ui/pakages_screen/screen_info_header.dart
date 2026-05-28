import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/ps_colors.dart';
import '../../../ui/common/ps_button_widget.dart';
import '../../core/consts.dart';
import '../../modle/user_balance_model.dart';
import '../../payment_provider.dart';
import '../shared/my_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taapdeel/utils/utils.dart';


class ScreenInfoHeader extends StatelessWidget {
  final UserBalanceModel model;

  const ScreenInfoHeader({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize:PaymentConsts.screenUtilSize);
    UserBalanceModel? userModel =
        Provider.of<PaymentProvider>(context, listen: true).getUserModel();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: PaymentConsts.blueColor,
        borderRadius:
            BorderRadius.all(Radius.circular(PaymentConsts.borderRadius)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "packages_info_header",
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ).tr(),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'your_balance',
                    style: TextStyle(
                        color: PaymentConsts.yellowColor, fontSize: 18.sp),
                  ).tr(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${userModel?.points ?? 0}',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16.sp),
                            ),
                            Text(
                              'point',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16.sp),
                            ).tr(),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${userModel?.swapBalance ?? 0}',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16.sp),
                            ),
                            Text(
                              'request',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16.sp),
                            ).tr(),
                          ],
                        )
                      ],
                    ),
                  ),
                  myButton(onTap: () {

                    showDialog<dynamic>(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                              insetPadding:
                                  const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              elevation: 0.0,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                height: 300,
                                padding: EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(30),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        Utils.getString(context, 'More_Points_details'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                color: PsColors
                                                    .primary500,
                                                fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    PSButtonWithIconWidget(
                                        hasShadow: true,
                                        width: double.infinity,
                                        //icon: FontAwesome.money, //FontAwesome.money,
                                        titleText: Utils.getString(
                                            context,
                                            'home__logout_dialog_ok_button'),
                                        colorData:
                                            PsColors.primary500,
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        }),
                                  ],
                                ),
                              ));
                        });

                  }, title: 'more_points'.tr())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
