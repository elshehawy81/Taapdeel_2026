import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/product.dart';

class HistoryListItem extends StatelessWidget {
  const HistoryListItem({
    Key? key,
    required this.history,
    this.onTap,
    this.animationController,
    this.animation,
    this.heroTagImage,
  }) : super(key: key);

  final Product history;
  final Function? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String? heroTagImage;

  @override
  Widget build(BuildContext context) {
    final Widget card = _HistoryGridProductCard(
      history: history,
      heroTagImage: heroTagImage,
      onTap: onTap,
    );

    if (animationController == null || animation == null) {
      return card;
    }

    animationController!.forward();

    return AnimatedBuilder(
      animation: animationController!,
      child: card,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - animation!.value),
              0.0,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _HistoryGridProductCard extends StatelessWidget {
  const _HistoryGridProductCard({
    required this.history,
    required this.heroTagImage,
    required this.onTap,
  });

  final Product history;
  final String? heroTagImage;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    final PsValueHolder valueHolder =
    Provider.of<PsValueHolder>(context, listen: false);

    final String title =
    history.title?.trim().isNotEmpty == true ? history.title!.trim() : 'منتج بدون عنوان';

    final String dateText = _getFormattedDate(valueHolder);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap as void Function()?,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: PsNetworkImage(
                          photoKey: heroTagImage ?? '',
                          imageAspectRation: PsConst.Aspect_Ratio_1x,
                          defaultPhoto: history.defaultPhoto,
                        ),
                      ),
                      PositionedDirectional(
                        top: 8,
                        start: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.42),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.history_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'شوهد',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PsDimens.space10,
                      PsDimens.space8,
                      PsDimens.space10,
                      PsDimens.space10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: const Color(0xFF15221D),
                          ),
                        ),
                        const Spacer(),
                        if (dateText.isNotEmpty)
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: PsColors.textPrimaryLightColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  dateText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color: PsColors.textPrimaryLightColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(PsValueHolder valueHolder) {
    if (history.addedDate == null || history.addedDate == '') {
      return '';
    }

    if (valueHolder.dateFormat == null || valueHolder.dateFormat == '') {
      return history.addedDate!;
    }

    return Utils.getDateFormat(
      history.addedDate!,
      valueHolder.dateFormat!,
    );
  }
}