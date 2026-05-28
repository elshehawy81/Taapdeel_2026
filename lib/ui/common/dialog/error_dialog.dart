import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';
import 'package:taapdeel/utils/utils.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    Key? key,
    this.message,
    this.onPressed,
  }) : super(key: key);

  final String? message;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TaapdeelBaseDialog(
      title: Utils.getString(context, 'error_dialog__error'),

      message: message ?? '',

      icon: Icons.error_outline_rounded,
      iconColor: Colors.white,
      iconBackground: PsColors.activeColor ?? Colors.redAccent,

      primaryButtonLabel: Utils.getString(context, 'dialog__ok'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
        onPressed?.call();
      },

      // مفيش زرار تاني في حالة الـ Error dialog
      secondaryButtonLabel: null,
      onSecondaryTap: null,
    );
  }
}
