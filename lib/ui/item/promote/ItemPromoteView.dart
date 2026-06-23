

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/ps_api_service.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/paymob_payment/modle/subscription_packages.dart';
import 'package:taapdeel/paymob_payment/ui/payment_sheet/payment_methodes_sheet.dart';
import 'package:taapdeel/provider/app_info/app_info_provider.dart';
import 'package:taapdeel/provider/promotion/item_promotion_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/app_info_repository.dart';
import 'package:taapdeel/repository/item_paid_history_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/base/ps_widget_with_multi_provider.dart';
import 'package:taapdeel/ui/common/dialog/demo_warning_dialog.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/dialog/success_dialog.dart';
import 'package:taapdeel/ui/common/dialog/warning_dialog_view.dart';
import 'package:taapdeel/ui/common/ps_button_widget.dart';
import 'package:taapdeel/ui/common/ps_dropdown_base_with_controller_widget.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/item_paid_history_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/paystack_intent_holder.dart';
import 'package:taapdeel/viewobject/item_paid_history.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../paymob_payment/core/consts.dart';
import '../../../paymob_payment/functions.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

class ItemPromoteView extends StatefulWidget {
  const ItemPromoteView({Key? key, required this.product}) : super(key: key);

  final Product product;
  @override
  _ItemPromoteViewState createState() => _ItemPromoteViewState();
}

class _ItemPromoteViewState extends State<ItemPromoteView>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  Animation<double>? animation;
  ItemPaidHistoryRepository? itemPaidHistoryRepository;
  ItemPromotionProvider? itemPaidHistoryProvider;
  PsValueHolder? psValueHolder;
  AppInfoRepository? appInfoRepository;
  AppInfoProvider? appInfoProvider;
  PsApiService? psApiService;
  UserProvider? userProvider;
  UserRepository? userRepository;

  final TextEditingController priceTypeController = TextEditingController();
  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    psValueHolder = Provider.of<PsValueHolder>(context);
    appInfoRepository = Provider.of<AppInfoRepository>(context);
    itemPaidHistoryRepository = Provider.of<ItemPaidHistoryRepository>(context);
    psApiService = Provider.of<PsApiService>(context);
    userRepository = Provider.of<UserRepository>(context);
    getUserData(     apiKey: PaymentConsts.apiKey,
      userId: PaymentConsts.userID, context: context,);
    return PsWidgetWithMultiProvider(
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ItemPromotionProvider?>(
            lazy: false,
            create: (BuildContext context) {
              itemPaidHistoryProvider = ItemPromotionProvider(
                  itemPaidHistoryRepository: itemPaidHistoryRepository);

              return itemPaidHistoryProvider;
            },
          ),
          ChangeNotifierProvider<UserProvider?>(
            lazy: false,
            create: (BuildContext context) {
              userProvider = UserProvider(
                  repo: userRepository, psValueHolder: psValueHolder);
              userProvider!.getUser(psValueHolder!.loginUserId);
              return userProvider;
            },
          ),
          ChangeNotifierProvider<AppInfoProvider?>(
              lazy: false,
              create: (BuildContext context) {
                appInfoProvider = AppInfoProvider(
                    repo: appInfoRepository, psValueHolder: psValueHolder);
                appInfoProvider!.loadDeleteHistorywithNotifier();
                return appInfoProvider;
              }),

        ],
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
            ),
            iconTheme: IconThemeData(
                color: PsColors.backArrowColor
              // color: Utils.isLightMode(context)
              //     ? PsColors.primary500
              //     : PsColors.primaryDarkWhite
            ),
            title: Text(
              Utils.getString(context, 'item_promote__entry'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                //  color:
                //  Utils.isLightMode(context)? PsColors.primary500 : PsColors.primaryDarkWhite
                //PsColors.primaryDarkWhite
              ),
            ),
          ),

        ),
      ),
    );
  }
}

class AdsStartDateDropDownWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdsStartDateDropDownWidgetState();
  }
}

class AdsStartDateDropDownWidgetState
    extends State<AdsStartDateDropDownWidget> {
  TextEditingController startDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemPromotionProvider>(
      builder: (BuildContext context,
          ItemPromotionProvider itemPaidHistoryProvider, Widget? child) {
        // ignore: unnecessary_null_comparison
        if (itemPaidHistoryProvider == null) {
          return Container();
        } else {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: PsDimens.space12),
                child: PsDropdownBaseWithControllerWidget(
                    title: Utils.getString(
                        context, 'item_promote__ads_start_date'),
                    textEditingController: startDateController,
                    isStar: true,
                    onTap: () async {
                      // final DateTime today = DateTime.now();
                      // Utils.psPrint('Today is ' + today.toString());
                      await DatePicker.showDateTimePicker(context,
                          minTime: DateTime.now(), onConfirm: (DateTime date) {
                            itemPaidHistoryProvider.selectedDateTime = date;
                          }, locale: LocaleType.en);

                      if (itemPaidHistoryProvider.selectedDateTime != null) {
                        itemPaidHistoryProvider.selectedDate =
                            DateFormat.yMMMMd('en_US').format(
                                itemPaidHistoryProvider.selectedDateTime!) +
                                ' ' +
                                DateFormat.Hms('en_US').format(
                                    itemPaidHistoryProvider.selectedDateTime!);
                      }
                      setState(() {
                        startDateController.text =
                        itemPaidHistoryProvider.selectedDate!;
                      });
                    }),
              ),
            ],
          );
        }
      },
    );
  }
}

class AdsHowManyDayWidget extends StatefulWidget {
  const AdsHowManyDayWidget(
      {Key? key, required this.product})
      : super(key: key);

  final Product product;
  @override
  State<StatefulWidget> createState() {
    return AdsHowManyDayWidgetState();
  }
}

class AdsHowManyDayWidgetState extends State<AdsHowManyDayWidget> {
  TextEditingController getEnterDateCountController = TextEditingController();
  bool getDefaultChoiceDate = true;
  bool getFirstChoiceDate = false;
  bool getSecondChoiceDate = false;
  bool getThirdChoiceDate = false;
  bool getFourthChoiceDate = false;
  bool getFifthChoiceDate = false;
  String? amount;
  String? howManyDay;
  String? startDate;
  String? stripePublishableKey;
  String? payStackKey;
  bool paymentFinish  =false;
  // static String text = getEnterDateCountController.text;
  @override
  Widget build(BuildContext context) {
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);
    final Widget payStackButtonWidget = Container(
      margin: const EdgeInsets.only(
          left: PsDimens.space16,
          right: PsDimens.space16,
          bottom: PsDimens.space16),
      width: double.infinity,
      height: PsDimens.space44,
      child:
      PSButtonWithIconWidget(
          hasShadow: true,
          width: double.infinity,
          icon: FontAwesome.credit_card, //FontAwesome.credit_card,
          titleText: Utils.getString(context, 'item_promote__pay_stack'),
          colorData: PsColors.primary500,
          onPressed: () async {
            if (double.parse(amount!) <= 0) {
              return;
            }
            final ItemPromotionProvider provider =
            Provider.of<ItemPromotionProvider>(context, listen: false);

            if (provider.selectedDate == '' || provider.selectedDate == null) {
              showDialog<dynamic>(
                  context: context,
                  builder: (BuildContext context) {
                    return WarningDialog(
                      message: Utils.getString(
                          context, 'item_promote__choose_start_date'),
                      onPressed: () {},
                    );
                  });
            } else {
              if (PsConfig.isDemo) {
                await callDemoWarningDialog(context);
              }
              final AppInfoProvider appProvider =
              Provider.of<AppInfoProvider>(context, listen: false);
              final UserProvider userProvider =
              Provider.of<UserProvider>(context, listen: false);
              payStackKey = appProvider.appInfo.data!.payStackKey;

              if (provider.selectedDate != null) {
                startDate = provider.selectedDate;
              }
              if (getEnterDateCountController.text != '') {
                howManyDay = getEnterDateCountController.text;

                final AppInfoProvider provider =
                Provider.of<AppInfoProvider>(context, listen: false);
                final double amountByEnterDay = double.parse(howManyDay!) *
                    double.parse(provider.appInfo.data!.oneDay!);
                amount = amountByEnterDay.toString();
                payStackKey = provider.appInfo.data!.payStackKey;
              }

              final int resultStartTimeStamp =
              Utils.getTimeStampDividedByOneThousand(
                  provider.selectedDateTime!);

              final dynamic returnData = await Navigator.pushNamed(
                  context, RoutePaths.payStackPayment,
                  arguments: PayStackInterntHolder(
                      product: widget.product,
                      amount: amount,
                      howManyDay: howManyDay,
                      paymentMethod: PsConst.PAYMENT_PAY_STACK_METHOD,
                      stripePublishableKey: stripePublishableKey,
                      startDate: startDate,
                      startTimeStamp: resultStartTimeStamp.toString(),
                      itemPaidHistoryProvider: provider,
                      userProvider: userProvider,
                      payStackKey: payStackKey));

              if (returnData == null || returnData) {
                Navigator.pop(context, true);
              }
            }
          }),
    );

    Widget payButton(BuildContext btncontext,) {
      return FilledButton(
        child: Container(
          height: 70,
          width: 150,
          child: Center(
            child: Text(
              'pay',
              style: TextStyle(fontSize: 20),
            ).tr(),
          ),
        ),
        onPressed: () async {
          promoteApiRun ()async {
            print("---------CAll paidAdSubmitApi Function---");
            if (await Utils.checkInternetConnectivity()) {

            final ItemPromotionProvider itemPromotionProvider =
            Provider.of<ItemPromotionProvider>(context, listen: false);

            final int resultStartTimeStamp = Utils.getTimeStampDividedByOneThousand(
            itemPromotionProvider.selectedDateTime!,
            );
            final ItemPaidHistoryParameterHolder itemPaidHistoryParameterHolder =

            ItemPaidHistoryParameterHolder(
            itemId: widget.product.id,
            amount: amount,
            howManyDay: howManyDay,
            paymentMethod: PsConst.PAYMENT_PAY_STACK_METHOD,
            paymentMethodNounce: '',
            //Platform.isIOS ? token : token,
            startDate: startDate,
            startTimeStamp: resultStartTimeStamp.toString(),
            razorId: '',
            purchasedId: '',
            isPaystack: PsConst.ZERO,
            );
            var itemPaidHistoryProvider = Provider.of<ItemPromotionProvider>(context, listen: false);
            final PsResource<ItemPaidHistory> padiHistoryDataStatus =
            await itemPaidHistoryProvider.postItemHistoryEntry(itemPaidHistoryParameterHolder.toMap());
            }
          }
          void  navugateBackToProduct()
          {
            final Product product =widget.product;

          }
          showModalBottomSheet<DraggableScrollableSheet>(
              elevation: 18,
              showDragHandle: true,
              isDismissible: true,
              context: context,
              builder: (BuildContext sheetcontext) {
                return PaymentMethodesSheet(
                  promoteFunction: () {
                    print('promoteFunctionRun');
                   promoteApiRun();
                    Future.delayed(Duration.zero, () {
                       final Product product =widget.product;
                       Navigator.of(context).popUntil((route)  {return route.isFirst;} );
                    }

                    );
                  },
                  subscriptionPackage: SubscriptionPackage(
                    name: 'Promote',
                    egpPrice: int.parse(amount.toString().replaceAll(".0", "")),
                    swapRequests: 0,
                    requiredPoints: 0,
                  ),
                  fromPromoteScreen: true,
                );
              },
            );
        },
      );
    }
    return Consumer<AppInfoProvider>(builder:
        (BuildContext context, AppInfoProvider appInfoprovider, Widget? child) {
      return Consumer<UserProvider>(builder:
          (BuildContext context, UserProvider userProvider, Widget? child) {
        if (appInfoprovider.appInfo.data == null) {
          return Container();
        } else {
          final String oneDay = appInfoprovider.appInfo.data!.oneDay!;
          final String? currencySymbol =
              appInfoprovider.appInfo.data!.currencySymbol;

          final double amountByFirstChoice = double.parse(oneDay) *
              double.parse(psValueHolder.promoteFirstChoiceDay!);
          final double amountBySecondChoice = double.parse(oneDay) *
              double.parse(psValueHolder.promoteSecondChoiceDay!);
          final double amountByThirdChoice = double.parse(oneDay) *
              double.parse(psValueHolder.promoteThirdChoiceDay!);
          final double amountByFourthChoice = double.parse(oneDay) *
              double.parse(psValueHolder.promoteFourthChoiceDay!);

          if (getDefaultChoiceDate) {
            amount = amountByFirstChoice.toString();
            howManyDay = psValueHolder.promoteFirstChoiceDay;
          }

          return Column(
            children: <Widget>[
              //First Choice or Default
              InkWell(
                onTap: () {
                  getFirstChoiceDate = true;
                  setState(() {
                    getFirstChoiceDate = true;
                    getDefaultChoiceDate = true;
                    getSecondChoiceDate = false;
                    getThirdChoiceDate = false;
                    getFourthChoiceDate = false;
                    getFifthChoiceDate = false;
                    getEnterDateCountController.clear();
                    amount = amountByFirstChoice.toString();
                    howManyDay =
                        psValueHolder.promoteFirstChoiceDay;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: PsDimens.space72,
                  margin: const EdgeInsets.only(
                      left: PsDimens.space12, right: PsDimens.space12),
                  decoration: BoxDecoration(
                    color: Utils.isLightMode(context)
                        ? Colors.white60
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(PsDimens.space4),
                    border: Border.all(
                        color: Utils.isLightMode(context)
                            ? Colors.grey[200]!
                            : Colors.black87),
                  ),
                  child: Row(
                    children: <Widget>[
                      if (getFirstChoiceDate || getDefaultChoiceDate)
                        Container(
                          width: PsDimens.space4,
                          height: double.infinity,
                          color: PsColors.activeColor,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(PsDimens.space8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(Utils.getString(context,
                                      'item_promote__promote_for') +
                                      psValueHolder.promoteFirstChoiceDay! +
                                      Utils.getString(context,
                                          'item_promote__promote_for_days')),
                                  Text(
                                      Utils.getString(context, currencySymbol) +
                                          Utils.getPriceFormat(
                                              amountByFirstChoice.toString(), psValueHolder.priceFormat!)),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: PsDimens.space12),
                                child: Text(psValueHolder.promoteFirstChoiceDay! +
                                    Utils.getString(
                                        context, 'item_promote__days')),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              //Second Choice
              InkWell(
                onTap: () {
                  getSecondChoiceDate = true;
                  setState(() {
                    getSecondChoiceDate = true;
                    getFirstChoiceDate = false;
                    getThirdChoiceDate = false;
                    getFourthChoiceDate = false;
                    getFifthChoiceDate = false;
                    getDefaultChoiceDate = false;
                    getEnterDateCountController.clear();
                    amount = amountBySecondChoice.toString();
                    howManyDay = psValueHolder.promoteSecondChoiceDay;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: PsDimens.space72,
                  margin: const EdgeInsets.only(
                      left: PsDimens.space12, right: PsDimens.space12),
                  decoration: BoxDecoration(
                    color: Utils.isLightMode(context)
                        ? Colors.white60
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(PsDimens.space4),
                    border: Border.all(
                        color: Utils.isLightMode(context)
                            ? Colors.grey[200]!
                            : Colors.black87),
                  ),
                  child: Ink(
                    color: PsColors.backgroundColor,
                    child: Row(
                      children: <Widget>[
                        if (getSecondChoiceDate)
                          Container(
                            width: PsDimens.space4,
                            height: double.infinity,
                            color: PsColors.activeColor,
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(PsDimens.space8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(Utils.getString(context,
                                        'item_promote__promote_for') +
                                        psValueHolder.promoteSecondChoiceDay! +
                                        Utils.getString(context,
                                            'item_promote__promote_for_days')),
                                    Text(Utils.getString(
                                        context, currencySymbol) +
                                        Utils.getPriceFormat(
                                            amountBySecondChoice.toString(), psValueHolder.priceFormat!)),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: PsDimens.space12),
                                  child: Text(
                                      psValueHolder.promoteSecondChoiceDay! +
                                          Utils.getString(
                                              context, 'item_promote__days')),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //Third Choice
              InkWell(
                onTap: () {
                  getThirdChoiceDate = true;
                  setState(() {
                    getThirdChoiceDate = true;
                    getFirstChoiceDate = false;
                    getSecondChoiceDate = false;
                    getFourthChoiceDate = false;
                    getFifthChoiceDate = false;
                    getDefaultChoiceDate = false;
                    getEnterDateCountController.clear();
                    amount = amountByThirdChoice.toString();
                    howManyDay = psValueHolder.promoteThirdChoiceDay;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: PsDimens.space72,
                  margin: const EdgeInsets.only(
                      left: PsDimens.space12, right: PsDimens.space12),
                  decoration: BoxDecoration(
                    color: Utils.isLightMode(context)
                        ? Colors.white60
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(PsDimens.space4),
                    border: Border.all(
                        color: Utils.isLightMode(context)
                            ? Colors.grey[200]!
                            : Colors.black87),
                  ),
                  child: Row(
                    children: <Widget>[
                      if (getThirdChoiceDate)
                        Container(
                          width: PsDimens.space4,
                          height: double.infinity,
                          color: PsColors.activeColor,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(PsDimens.space8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(Utils.getString(context,
                                      'item_promote__promote_for') +
                                      psValueHolder.promoteThirdChoiceDay! +
                                      Utils.getString(context,
                                          'item_promote__promote_for_days')),
                                  Text(
                                      Utils.getString(context, currencySymbol) +
                                          Utils.getPriceFormat(
                                              amountByThirdChoice.toString(), psValueHolder.priceFormat!)),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: PsDimens.space12),
                                child: Text(psValueHolder.promoteThirdChoiceDay! +
                                    Utils.getString(
                                        context, 'item_promote__days')),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              //Fourth Choice
              InkWell(
                onTap: () {
                  getFourthChoiceDate = true;
                  setState(() {
                    getFourthChoiceDate = true;
                    getFirstChoiceDate = false;
                    getSecondChoiceDate = false;
                    getThirdChoiceDate = false;
                    getFifthChoiceDate = false;
                    getDefaultChoiceDate = false;
                    getEnterDateCountController.clear();
                    amount = amountByFourthChoice.toString();
                    howManyDay = psValueHolder.promoteFourthChoiceDay;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: PsDimens.space72,
                  margin: const EdgeInsets.only(
                      left: PsDimens.space12, right: PsDimens.space12),
                  decoration: BoxDecoration(
                    color: Utils.isLightMode(context)
                        ? Colors.white60
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(PsDimens.space4),
                    border: Border.all(
                        color: Utils.isLightMode(context)
                            ? Colors.grey[200]!
                            : Colors.black87),
                  ),
                  child: Ink(
                    color: PsColors.backgroundColor,
                    child: Row(
                      children: <Widget>[
                        if (getFourthChoiceDate)
                          Container(
                            width: PsDimens.space4,
                            height: double.infinity,
                            color: PsColors.activeColor,
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(PsDimens.space8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(Utils.getString(context,
                                        'item_promote__promote_for') +
                                        psValueHolder.promoteFourthChoiceDay! +
                                        Utils.getString(context,
                                            'item_promote__promote_for_days')),
                                    Text(Utils.getString(
                                        context, currencySymbol) +
                                        Utils.getPriceFormat(
                                            amountByFourthChoice.toString(), psValueHolder.priceFormat!)),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: PsDimens.space12),
                                  child: Text(
                                      psValueHolder.promoteFourthChoiceDay! +
                                          Utils.getString(
                                              context, 'item_promote__days')),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //Fifth Choice
              InkWell(
                onTap: () {
                  getFifthChoiceDate = true;
                  setState(() {
                    getFifthChoiceDate = true;
                    getFirstChoiceDate = false;
                    getSecondChoiceDate = false;
                    getThirdChoiceDate = false;
                    getFourthChoiceDate = false;
                    getDefaultChoiceDate = false;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: PsDimens.space72,
                  margin: const EdgeInsets.only(
                      left: PsDimens.space12, right: PsDimens.space12),
                  decoration: BoxDecoration(
                    color: Utils.isLightMode(context)
                        ? Colors.white60
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(PsDimens.space4),
                    border: Border.all(
                        color: Utils.isLightMode(context)
                            ? Colors.grey[200]!
                            : Colors.black87),
                  ),
                  child: Row(
                    children: <Widget>[
                      if (getFifthChoiceDate)
                        Container(
                          width: PsDimens.space4,
                          height: double.infinity,
                          color: PsColors.activeColor,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(PsDimens.space8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(Utils.getString(
                                      context, 'item_promote__customs')),
                                  if (getEnterDateCountController.text != '' &&
                                      double.parse(getEnterDateCountController.text) >
                                          0.0)
                                    Text(Utils.getString(context, currencySymbol) +
                                        Utils.getPriceFormat((double.parse(
                                            getEnterDateCountController
                                                .text) *
                                            double.parse(appInfoprovider
                                                .appInfo.data!.oneDay!))
                                            .toString(), psValueHolder.priceFormat!))
                                  else
                                    Text(Utils.getString(context, currencySymbol) +
                                        getEnterDateCountController.text)
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      right: PsDimens.space12),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                          width: PsDimens.space60,
                                          height: PsDimens.space32,
                                          margin: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Utils.isLightMode(context)
                                                ? Colors.white60
                                                : Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                                PsDimens.space4),
                                            border: Border.all(
                                                color:
                                                Utils.isLightMode(context)
                                                    ? Colors.grey[200]!
                                                    : Colors.black87),
                                          ),
                                          child: TextField(
                                              onChanged: (String text) {
                                                print('dddd');
                                                if (double.parse(
                                                    getEnterDateCountController
                                                        .text) >
                                                    0.0) {
                                                  setState(() {});
                                                }
                                              },
                                              onTap: () {
                                                getFifthChoiceDate = true;
                                                setState(() {
                                                  getFifthChoiceDate = true;
                                                  getFirstChoiceDate = false;
                                                  getSecondChoiceDate = false;
                                                  getThirdChoiceDate = false;
                                                  getFourthChoiceDate = false;
                                                  getDefaultChoiceDate = false;
                                                });
                                              },
                                              keyboardType:
                                              TextInputType.number,
                                              maxLines: null,
                                              controller:
                                              getEnterDateCountController,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.only(
                                                    left: PsDimens.space28,
                                                    bottom: PsDimens.space16),
                                                border: InputBorder.none,
                                              ))),
                                      Text(Utils.getString(
                                          context, 'item_promote__days')),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: PsDimens.space16),
              payButton(context,),
              SizedBox(height: PsDimens.space32),
            ],
          );
        }
      });
    });
  }


}
dynamic callDemoWarningDialog(BuildContext context) async {
  await showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return const DemoWarningDialog();
      });
}


dynamic paidAdSubmitApi({
  required  BuildContext context,
  required Product product,
  String? amount,
  String? howManyDay,
  required  String paymentMethod,
  String? startDate,
  required String startTimeStamp,
  required  ItemPromotionProvider itemPaidHistoryProvider,
  String? token,}
    ) async {
  print("---------CAll paidAdSubmitApi Function---");
  if (await Utils.checkInternetConnectivity()) {

    final ItemPaidHistoryParameterHolder itemPaidHistoryParameterHolder =
    ItemPaidHistoryParameterHolder(
        itemId: product.id,
        amount: amount,
        howManyDay: howManyDay,
        paymentMethod: paymentMethod,
        paymentMethodNounce:'',
        //Platform.isIOS ? token : token,
        startDate: startDate,
        startTimeStamp: startTimeStamp,
        razorId: '',
        purchasedId: '',
        isPaystack: PsConst.ZERO);

    final PsResource<ItemPaidHistory> padiHistoryDataStatus =
    await itemPaidHistoryProvider
        .postItemHistoryEntry(itemPaidHistoryParameterHolder.toMap());

    if (padiHistoryDataStatus.data != null) {
      // progressDialog.dismiss();
      PsProgressDialog.dismissDialog();
      print('Done --------');
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext contet) {
            return SuccessDialog(
              message: Utils.getString(context, 'item_promote__success'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            );
          });
    } else {
      PsProgressDialog.dismissDialog();
      print('Error --------');
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: padiHistoryDataStatus.message,
            );
          });
    }
  } else {
    // showDialog<dynamic>(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return ErrorDialog(
    //         message: Utils.getString(context, 'error_dialog__no_internet'),
    //       );
    //     });
  }
}

