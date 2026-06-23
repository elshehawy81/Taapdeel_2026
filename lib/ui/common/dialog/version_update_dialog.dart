import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class VersionUpdateDialog extends StatelessWidget {
  const VersionUpdateDialog({
    Key? key,
    this.title,
    this.description,
    this.leftButtonText,
    this.rightButtonText,
    this.onCancelTap,
    this.onUpdateTap,
  }) : super(key: key);

  final String? title;
  final String? description;
  final String? leftButtonText;
  final String? rightButtonText;
  final VoidCallback? onCancelTap;
  final VoidCallback? onUpdateTap;

  @override
  Widget build(BuildContext context) {
    return TaapdeelBaseDialog(
      icon: Icons.upgrade_rounded,
      iconColor: Colors.white,
      iconBackground: PsColors.primary500, // أو أي لون يناسب الـ brand

      title: title ??
          Utils.getString(context, 'version_update_dialog__version_update'),

      message: description ?? '',

      // Primary button (Update)
      primaryButtonLabel:
      rightButtonText ?? Utils.getString(context, 'dialog__ok'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
        onUpdateTap?.call();
      },

      // Secondary button (Cancel)
      secondaryButtonLabel:
      leftButtonText ?? Utils.getString(context, 'dialog__cancel'),
      onSecondaryTap: () {
        Navigator.of(context).pop();
        onCancelTap?.call();
      },
    );
  }
}
