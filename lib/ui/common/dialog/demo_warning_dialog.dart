import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class DemoWarningDialog extends StatelessWidget {
  const DemoWarningDialog({
    Key? key,
    this.message,
    this.onOkTap,
  }) : super(key: key);

  final String? message;
  final VoidCallback? onOkTap;

  @override
  Widget build(BuildContext context) {
    return TaapdeelBaseDialog(
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.white,
      iconBackground: PsColors.orangeColor,
      title: Utils.getString(context, 'warning_dialog__warning'),
      message: message ??
          Utils.getString(context, 'demo_warning_dialog__message'),
      primaryButtonLabel:
      Utils.getString(context, 'dialog__ok'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
        onOkTap?.call();
      },
      secondaryButtonLabel: null,
      onSecondaryTap: null,
    );
  }
}
