import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    Key? key,
    this.message,
    this.onPressed,
  }) : super(key: key);

  final String? message;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TaapdeelBaseDialog(
      icon: Icons.check_circle_rounded,
      iconColor: Colors.white,
      iconBackground: Colors.green.shade500,

      title: Utils.getString(context, 'success_dialog__success'),
      message: message ?? '',

      primaryButtonLabel: Utils.getString(context, 'dialog__ok'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
        onPressed?.call();
      },

      secondaryButtonLabel: null,
      onSecondaryTap: null,
    );
  }
}
