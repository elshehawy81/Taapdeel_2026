import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class WarningDialog extends StatefulWidget {
  const WarningDialog({this.message, this.onPressed});

  final String? message;
  final Function? onPressed;

  @override
  _WarningDialogState createState() => _WarningDialogState();
}

class _WarningDialogState extends State<WarningDialog> {
  @override
  Widget build(BuildContext context) {
    return TaapdeelBaseDialog(
      icon: Icons.warning_amber_rounded,
      iconColor: PsColors.white,
      iconBackground: PsColors.orangeColor,
      title: Utils.getString(context, 'warning_dialog__warning'),
      message: widget.message ?? '',
      primaryButtonLabel: Utils.getString(context, 'dialog__ok'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
        widget.onPressed?.call();
      },
      secondaryButtonLabel: null,
      onSecondaryTap: null,
    );
  }
}
