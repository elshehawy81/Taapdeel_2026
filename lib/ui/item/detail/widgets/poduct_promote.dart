
import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/app_info/app_info_provider.dart';
import 'package:taapdeel/provider/product/product_provider.dart';
import 'package:taapdeel/ui/common/dialog/choose_payment_type_dialog.dart';
import 'package:taapdeel/ui/common/ps_button_widget.dart';
import 'package:taapdeel/ui/common/ps_expansion_tile.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:provider/provider.dart';


class PromoteTileView extends StatefulWidget {
  const PromoteTileView({
    Key? key,
    required this.animationController,
    required this.product,
    required this.provider,
  }) : super(key: key);

  final AnimationController? animationController;
  final Product? product;
  final ItemDetailProvider provider;

  @override
  _PromoteTileViewState createState() => _PromoteTileViewState();
}

class _PromoteTileViewState extends State<PromoteTileView> {
  @override
  Widget build(BuildContext context) {
    final Widget _expansionTileTitleWidget = Text(
        Utils.getString(context, 'item_detail__promote_your_item'),
        style: Theme.of(context).textTheme.titleMedium);

    final Widget _expansionTileLeadingIconWidget =
        Icon(Entypo.megaphone, //Ionicons.ios_megaphone,
            color: PsColors.primary500);

    return Consumer<AppInfoProvider>(builder:
        (BuildContext context, AppInfoProvider appInfoprovider, Widget? child) {
      if (appInfoprovider.appInfo.data == null) {
        return Container();
      } else {
        return Container(
          margin: const EdgeInsets.only(
              left: PsDimens.space12,
              right: PsDimens.space12,
              bottom: PsDimens.space12),
          decoration: BoxDecoration(
            color: PsColors.primary50,
            borderRadius:
                const BorderRadius.all(Radius.circular(PsDimens.space8)),
          ),
          child: PsExpansionTile(
            initiallyExpanded: true,
            leading: _expansionTileLeadingIconWidget,
            title: _expansionTileTitleWidget,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(
                    height: PsDimens.space1,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(PsDimens.space12),
                    child: Text(Utils.getString(
                        context, 'item_detail__promote_sub_title')),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: PsDimens.space12,
                        right: PsDimens.space12,
                        bottom: PsDimens.space12),
                    child: Text(Utils.getString(
                        context, 'item_detail__promote_description')),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(width: PsDimens.space2),
                      SizedBox(
                          width: PsDimens.space220,
                          child: PSButtonWithIconWidget(
                              hasShadow: false,
                              width: double.infinity,
                              icon: FontAwesome.megaphone,
                              //Ionicons.ios_megaphone,
                              titleText: Utils.getString(
                                  context, 'item_detail__promte'),
                              onPressed: () async {
                                if (appInfoprovider.appInfo.data!
                                            .inAppPurchasedEnabled ==
                                        PsConst.ONE &&
                                    appInfoprovider
                                            .appInfo.data!.payStackEnabled ==
                                        PsConst.ZERO  &&
                                    appInfoprovider
                                            .appInfo.data!.offlineEnabled ==
                                        PsConst.ZERO) {
                                  // InAppPurchase View
                                  final dynamic returnData =
                                      await Navigator.pushNamed(
                                          context, RoutePaths.inAppPurchase,
                                          arguments: <String, dynamic>{
                                        'productId': widget.product!.id,
                                        'appInfo': appInfoprovider.appInfo.data
                                      });
                                  if (returnData == true ||
                                      returnData == null) {
                                    final String? loginUserId =
                                        Utils.checkUserLoginId(
                                            widget.provider.psValueHolder!);
                                    widget.provider.loadProduct(
                                        widget.product!.id, loginUserId);
                                  }
                                } else if (appInfoprovider
                                        .appInfo.data!.inAppPurchasedEnabled ==
                                    PsConst.ZERO) {
                                  //Original Item Promote View
                                  final dynamic returnData =
                                      await Navigator.pushNamed(
                                          context, RoutePaths.itemPromote,
                                          arguments: widget.product);
                                  if (returnData == true ||
                                      returnData == null) {
                                    final String? loginUserId =
                                        Utils.checkUserLoginId(
                                            widget.provider.psValueHolder!);
                                    widget.provider.loadProduct(
                                        widget.product!.id, loginUserId);
                                  }
                                } else {
                                  //choose payment
                                  showDialog<dynamic>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ChoosePaymentTypeDialog(
                                          onInAppPurchaseTap: () async {
                                            final dynamic returnData =
                                                await Navigator.pushNamed(
                                                    context,
                                                    RoutePaths.inAppPurchase,
                                                    arguments: <String,
                                                        dynamic>{
                                                  'productId':
                                                      widget.product!.id,
                                                  'appInfo': appInfoprovider
                                                      .appInfo.data
                                                });
                                            if (returnData == true ||
                                                returnData == null) {
                                              final String? loginUserId =
                                                  Utils.checkUserLoginId(widget
                                                      .provider.psValueHolder!);
                                              widget.provider.loadProduct(
                                                  widget.product!.id,
                                                  loginUserId);
                                            }
                                          },
                                          onOtherPaymentTap: () async {
                                            final dynamic returnData =
                                                await Navigator.pushNamed(
                                                    context,
                                                    RoutePaths.itemPromote,
                                                    arguments: widget.product);
                                            if (returnData == true ||
                                                returnData == null) {
                                              final String? loginUserId =
                                                  Utils.checkUserLoginId(widget
                                                      .provider.psValueHolder!);
                                              widget.provider.loadProduct(
                                                  widget.product!.id,
                                                  loginUserId);
                                            }
                                          },
                                        );
                                      });
                                }
                              })),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: PsDimens.space18, bottom: PsDimens.space8),
                        child: Image.asset(
                          'assets/images/baseline_promotion_color_74.png',
                          width: PsDimens.space80,
                          height: PsDimens.space80,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      }
    });
  }
}

dynamic isAllPaymentDisable(AppInfoProvider appInfoProvider) {
  if (appInfoProvider.appInfo.data!.inAppPurchasedEnabled == PsConst.ZERO &&
      appInfoProvider.appInfo.data!.payStackEnabled == PsConst.ZERO &&
      appInfoProvider.appInfo.data!.offlineEnabled == PsConst.ZERO) {
    return true;
  } else {
    return false;
  }
}