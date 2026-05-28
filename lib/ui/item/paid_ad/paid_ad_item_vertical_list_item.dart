import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/paid_ad_item.dart';
import 'package:provider/provider.dart';

import '../../common/taapdeel/taapdeel_info_card_shell.dart';

class PaidAdItemVerticalListItem extends StatelessWidget {
  const PaidAdItemVerticalListItem({
    Key? key,
    required this.paidAdItem,
    this.onTap,
    this.animationController,
    this.animation,
    this.productDetailIntentHolder,
  }) : super(key: key);

  final PaidAdItem paidAdItem;
  final Function? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final ProductDetailIntentHolder? productDetailIntentHolder;

  @override
  Widget build(BuildContext context) {
    // ✅ safe: avoid calling forward repeatedly if parent rebuilds
    if (animationController != null && !(animationController!.isAnimating)) {
      animationController!.forward();
    }

    final PsValueHolder valueHolder =
    Provider.of<PsValueHolder>(context, listen: false);

    return AnimatedBuilder(
      animation: animationController!,
      child: Padding(
        padding: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12,
          top: PsDimens.space8,
          bottom: PsDimens.space8,
        ),
        child: TaapdeelInfoCardShell(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          withBlur: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap as void Function()?,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 410,
                  child: PaidAdItemWidget(
                    paidAdItem: paidAdItem,
                    onTap: onTap,
                    valueHolder: valueHolder,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 60 * (1.0 - animation!.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }
}

class PaidAdItemWidget extends StatelessWidget {
  const PaidAdItemWidget({
    Key? key,
    required this.paidAdItem,
    required this.onTap,
    required this.valueHolder,
  }) : super(key: key);

  final PaidAdItem paidAdItem;
  final Function? onTap;
  final PsValueHolder valueHolder;

  @override
  Widget build(BuildContext context) {
    final String userName = (paidAdItem.item?.user?.userName ?? '').isEmpty
        ? Utils.getString(context, 'default__user_name')
        : '${paidAdItem.item!.user!.userName}';

    final bool isVerified =
        paidAdItem.item?.user?.isVerifyBlueMark == PsConst.ONE;

    final String title = paidAdItem.item?.title ?? '';
    final String addedDateStr = paidAdItem.addedDateStr ?? '';

    final String conditionName =
        paidAdItem.item?.conditionOfItem?.name ?? '';

    final bool showCondition = Utils.showUI(valueHolder.conditionOfItemId);

    final bool hasDiscount =
        paidAdItem.item != null && paidAdItem.item!.discountRate != '0';

    final String currency =
        paidAdItem.item?.itemCurrency?.currencySymbol ?? '';

    final String displayPrice = _getDisplayPrice(context);

    final String originalPrice = paidAdItem.item?.price ?? '';

    final String discountRate = paidAdItem.item?.discountRate ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // ===================== Header (User) =====================
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PsDimens.space12,
            PsDimens.space12,
            PsDimens.space12,
            PsDimens.space10,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (PsColors.activeColor ?? PsColors.baseColor)
                        .withOpacity(0.16),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: PsNetworkCircleImageForUser(
                    photoKey: '',
                    imagePath: paidAdItem.item?.user?.userProfilePhoto,
                    boxfit: BoxFit.cover,
                    onTap: () {},
                  ),
                ),
              ),
              const SizedBox(width: PsDimens.space10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: PsColors.textColor1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isVerified) ...<Widget>[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.verified_rounded,
                            color: PsColors.bluemarkColor,
                            size: valueHolder.bluemarkSize,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addedDateStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PsColors.textColor3,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // subtle chevron
              Icon(
                Icons.chevron_right_rounded,
                color: PsColors.textColor3,
              ),
            ],
          ),
        ),

        // ===================== Image + Status Chip =====================
        Expanded(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: PsNetworkImage(
                  photoKey: '',
                  defaultPhoto: paidAdItem.item!.defaultPhoto,
                  width: double.infinity,
                  height: double.infinity,
                  boxfit: BoxFit.cover,
                  imageAspectRation: PsConst.Aspect_Ratio_3x,
                  onTap: () => onTap?.call(),
                ),
              ),

              // top gradient for premium feel
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: PsDimens.space12,
                top: PsDimens.space12,
                child: _PaidStatusChip(
                  status: paidAdItem.paidStatus ?? '',
                ),
              ),
            ],
          ),
        ),

        // ===================== Title + Price Row =====================
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PsDimens.space12,
            PsDimens.space12,
            PsDimens.space12,
            PsDimens.space8,
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PsColors.textColor1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            PsDimens.space12,
            0,
            PsDimens.space12,
            PsDimens.space10,
          ),
          child: Row(
            children: <Widget>[
              Text(
                displayPrice,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PsColors.textColor1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: PsDimens.space8),

              if (hasDiscount) ...<Widget>[
                Text(
                  '$currency${Utils.getPriceFormat(originalPrice, valueHolder.priceFormat!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PsColors.textColor3,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: PsDimens.space6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (PsColors.activeColor ?? PsColors.baseColor)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '-$discountRate%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PsColors.textColor1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              if (showCondition && conditionName.isNotEmpty)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: PsColors.baseColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: PsColors.textColor3!.withOpacity(0.22),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    conditionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PsColors.textColor2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ===================== Details (Start / End / Amount) =====================
        Container(
          margin: const EdgeInsets.fromLTRB(
              PsDimens.space12, 0, PsDimens.space12, PsDimens.space12),
          padding: const EdgeInsets.all(PsDimens.space12),
          decoration: BoxDecoration(
            color: PsColors.baseColor.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PsColors.textColor3!.withOpacity(0.14),
              width: 1,
            ),
          ),
          child: Column(
            children: <Widget>[
              _MetaRow(
                label: Utils.getString(context, 'profile__start_date'),
                value: paidAdItem.startTimeStamp == ''
                    ? '-'
                    : Utils.changeTimeStampToStandardDateTimeFormat(
                    paidAdItem.startTimeStamp),
                icon: Icons.play_circle_outline_rounded,
              ),
              const SizedBox(height: 10),
              _MetaRow(
                label: Utils.getString(context, 'profile__end_date'),
                value: paidAdItem.endTimeStamp == ''
                    ? '-'
                    : Utils.changeTimeStampToStandardDateTimeFormat(
                    paidAdItem.endTimeStamp),
                icon: Icons.stop_circle_outlined,
              ),
              const SizedBox(height: 10),
              _MetaRow(
                label: Utils.getString(context, 'profile__amount'),
                value: '$currency${paidAdItem.amount}',
                icon: Icons.payments_outlined,
                isValueStrong: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDisplayPrice(BuildContext context) {
    if (paidAdItem.item == null) return '';

    final String discountRate = paidAdItem.item!.discountRate ?? '';
    final bool noDiscount = discountRate == '' || discountRate == '0';

    if (noDiscount) {
      if (paidAdItem.item!.price != '0' && paidAdItem.item!.price != '') {
        return '${paidAdItem.item!.itemCurrency!.currencySymbol}'
            '${Utils.getPriceFormat(paidAdItem.item!.price!, valueHolder.priceFormat!)}';
      }
      return Utils.getString(context, 'item_price_free');
    }

    return '${paidAdItem.item!.itemCurrency!.currencySymbol}'
        '${Utils.getPriceFormat(paidAdItem.item!.discountedPrice!, valueHolder.priceFormat!)}';
  }
}

// ============================================================
// Premium helpers
// ============================================================

class _PaidStatusChip extends StatelessWidget {
  const _PaidStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    // default
    Color bg = Colors.black.withOpacity(0.45);
    String text = '';

    if (status == PsConst.ADSPROGRESS) {
      bg = Colors.lightGreen.withOpacity(0.92);
      text = Utils.getString(context, 'paid__ads_in_progress');
    } else if (status == PsConst.ADSFINISHED) {
      bg = Colors.black.withOpacity(0.55);
      text = Utils.getString(context, 'paid__ads_in_completed');
    } else if (status == PsConst.ADSNOTYETSTART) {
      bg = Colors.orange.withOpacity(0.92);
      text = Utils.getString(context, 'paid__ads_is_not_yet_start');
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.20), width: 1),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isValueStrong = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isValueStrong;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: (PsColors.activeColor ?? PsColors.baseColor).withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: PsColors.textColor1),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PsColors.textColor3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PsColors.textColor1,
              fontWeight: isValueStrong ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class PaidAdItemGridItem extends StatelessWidget {
  const PaidAdItemGridItem({
    Key? key,
    required this.paidAdItem,
    this.onTap,
  }) : super(key: key);

  final PaidAdItem paidAdItem;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final PsValueHolder valueHolder =
    Provider.of<PsValueHolder>(context, listen: false);

    final String title = paidAdItem.item?.title ?? '';
    final String userName = (paidAdItem.item?.user?.userName ?? '').isEmpty
        ? Utils.getString(context, 'default__user_name')
        : paidAdItem.item!.user!.userName!;

    final String currency =
        paidAdItem.item?.itemCurrency?.currencySymbol ?? '';

    final bool hasDiscount =
        (paidAdItem.item?.discountRate ?? '0') != '0' &&
            (paidAdItem.item?.discountRate ?? '') != '';

    final String displayPrice = _getDisplayPrice(context, valueHolder);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: PsColors.baseColor,
            border: Border.all(
              color: PsColors.textColor3!.withOpacity(0.14),
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ✅ صورة قصيرة
                AspectRatio(
                  aspectRatio: 1.35,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: PsNetworkImage(
                          photoKey: '',
                          defaultPhoto: paidAdItem.item!.defaultPhoto,
                          width: double.infinity,
                          height: double.infinity,
                          boxfit: BoxFit.cover,
                          imageAspectRation: PsConst.Aspect_Ratio_3x,
                          onTap: onTap ?? () {},
                        ),
                      ),

                      // ✅ Status Chip
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _PaidStatusChipCompact(
                          status: paidAdItem.paidStatus ?? '',
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ المحتوى
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: PsColors.textColor1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              displayPrice,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                color: PsColors.textColor1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (PsColors.activeColor ??
                                    PsColors.baseColor)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '-${paidAdItem.item!.discountRate}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: PsColors.textColor1,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ✅ user صغير
                      Row(
                        children: <Widget>[
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: (PsColors.activeColor ??
                                    PsColors.baseColor)
                                    .withOpacity(0.18),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: PsNetworkCircleImageForUser(
                                photoKey: '',
                                imagePath: paidAdItem.item?.user
                                    ?.userProfilePhoto,
                                boxfit: BoxFit.cover,
                                onTap: () {},
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: PsColors.textColor2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayPrice(BuildContext context, PsValueHolder valueHolder) {
    if (paidAdItem.item == null) return '';

    final String currency =
        paidAdItem.item?.itemCurrency?.currencySymbol ?? '';

    final String discountRate = paidAdItem.item!.discountRate ?? '';
    final bool noDiscount = discountRate == '' || discountRate == '0';

    if (noDiscount) {
      if (paidAdItem.item!.price != '0' && paidAdItem.item!.price != '') {
        return '$currency${Utils.getPriceFormat(paidAdItem.item!.price!, valueHolder.priceFormat!)}';
      }
      return Utils.getString(context, 'item_price_free');
    }

    return '$currency${Utils.getPriceFormat(paidAdItem.item!.discountedPrice!, valueHolder.priceFormat!)}';
  }
}

class _PaidStatusChipCompact extends StatelessWidget {
  const _PaidStatusChipCompact({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.black.withOpacity(0.45);
    String text = '';

    if (status == PsConst.ADSPROGRESS) {
      bg = Colors.lightGreen.withOpacity(0.92);
      text = Utils.getString(context, 'paid__ads_in_progress');
    } else if (status == PsConst.ADSFINISHED) {
      bg = Colors.black.withOpacity(0.55);
      text = Utils.getString(context, 'paid__ads_in_completed');
    } else if (status == PsConst.ADSNOTYETSTART) {
      bg = Colors.orange.withOpacity(0.92);
      text = Utils.getString(context, 'paid__ads_is_not_yet_start');
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.20), width: 1),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}
