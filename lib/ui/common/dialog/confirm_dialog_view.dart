import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class ConfirmDialogView extends StatelessWidget {
  const ConfirmDialogView({
    Key? key,
    this.description,
    this.leftButtonText,
    this.rightButtonText,
    required this.onAgreeTap,
    this.onCancelTap,
  }) : super(key: key);

  final String? description;
  final String? leftButtonText;
  final String? rightButtonText;
  final VoidCallback onAgreeTap;
  final VoidCallback? onCancelTap;

  @override
  Widget build(BuildContext context) {
    final String titleText =
    Utils.getString(context, 'logout_dialog__confirm');

    return TaapdeelBaseDialog(
      icon: Icons.help_outline_rounded,
      iconColor: Colors.white,
      iconBackground: PsColors.primary500,
      title: titleText,
      message: description ?? '',

      primaryButtonLabel:
      rightButtonText ?? Utils.getString(context, 'dialog__ok'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
        onAgreeTap();
      },

      secondaryButtonLabel:
      leftButtonText ?? Utils.getString(context, 'dialog__cancel'),
      onSecondaryTap: () {
        Navigator.of(context).pop();
        onCancelTap?.call();
      },
    );
  }
}
