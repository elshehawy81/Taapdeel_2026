import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/provider/product/search_product_provider.dart';
import 'package:provider/provider.dart';

class SpecialCheckTextWidget extends StatefulWidget {
  const SpecialCheckTextWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.checkTitle,
    this.size = PsDimens.space20,
  }) : super(key: key);

  final String title;
  final IconData icon;

  /// 1 = featured switch, 2 = discount switch
  final int checkTitle;

  final double size;

  @override
  State<SpecialCheckTextWidget> createState() =>
      _SpecialCheckTextWidgetState();
}

class _SpecialCheckTextWidgetState extends State<SpecialCheckTextWidget> {
  @override
  Widget build(BuildContext context) {
    final SearchProductProvider provider =
    Provider.of<SearchProductProvider>(context);

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final double iconSize =
    widget.size < PsDimens.space20 ? PsDimens.space20 : widget.size;

    final bool isFeaturedSwitch = widget.checkTitle == 1;
    final bool isDiscountSwitch = widget.checkTitle == 2;

    final bool switchValue = isFeaturedSwitch
        ? provider.isSwitchedFeaturedProduct
        : provider.isSwitchedDiscountPrice;

    return Container(
      width: double.infinity,
      height: PsDimens.space52,
      margin: const EdgeInsets.symmetric(
        horizontal: PsDimens.space16,
        vertical: PsDimens.space6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PsDimens.space12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: Icon(
                    widget.icon,
                    size: iconSize,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: PsDimens.space12),
                Text(
                  widget.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Switch(
              value: switchValue,
              onChanged: (bool value) {
                setState(() {
                  if (isFeaturedSwitch) {
                    provider.isSwitchedFeaturedProduct = value;
                  } else if (isDiscountSwitch) {
                    provider.isSwitchedDiscountPrice = value;
                  }
                });
              },
              activeTrackColor: PsColors.primary500.withValues(alpha: 0.35),
              activeThumbColor: PsColors.primary500,
            ),
          ],
        ),
      ),
    );
  }
}
