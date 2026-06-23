import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({Key? key, required this.message}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return TaapdeelBaseDialog(
      icon: Icons.info_rounded,
      iconColor: Colors.white,
      iconBackground: PsColors.primary500,

      title: Utils.getString(context, 'info_dialog__info'),
      message: message,

      primaryButtonLabel: Utils.getString(context, 'dialog__ok'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
      },

      secondaryButtonLabel: null,
      onSecondaryTap: null,
    );
  }
}
