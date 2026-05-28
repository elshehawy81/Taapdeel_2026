import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/utils/utils.dart';

class FilterDialog extends StatelessWidget {
  const FilterDialog({
    Key? key,
    this.onDescendingTap,
    this.onAscendingTap,
  }) : super(key: key);

  final VoidCallback? onDescendingTap;
  final VoidCallback? onAscendingTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color baseColor =
    (theme.dialogTheme.backgroundColor ?? PsColors.baseLightColor)
        .withValues(alpha: isDark ? 0.96 : 0.98);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: PsDimens.space24,
        vertical: PsDimens.space24,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha:0.20),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(PsDimens.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: PsDimens.space8),

              // العنوان
              Text(
                Utils.getString(context, 'item_filter__title'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PsColors.textColor1,
                ),
              ),

              const SizedBox(height: PsDimens.space24),

              // من الأقل للأعلى
              TaapdeelButton(
                label: Utils.getString(
                  context,
                  'item_filter__lowest_to_highest_letter',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onAscendingTap?.call();
                },
                isPrimary: true,
                isExpanded: true,
              ),

              const SizedBox(height: PsDimens.space16),

              // من الأعلى للأقل
              TaapdeelButton(
                label: Utils.getString(
                  context,
                  'item_filter__highest_to_lowest_letter',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onDescendingTap?.call();
                },
                isPrimary: true,
                isExpanded: true,
              ),

              const SizedBox(height: PsDimens.space16),

              TaapdeelButton(
                label: Utils.getString(context, 'dialog__cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                isPrimary: false,
                isExpanded: true,
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
