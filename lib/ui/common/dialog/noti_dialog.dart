import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class NotiDialog extends StatelessWidget {
  const NotiDialog({
    Key? key,
    this.message,
  }) : super(key: key);

  final String? message;

  @override
  Widget build(BuildContext context) {
    final String bodyText = message ??
        Utils.getString(context, 'chat_noti__new_message');

    return TaapdeelBaseDialog(
      icon: Icons.mail_outline_rounded,
      iconColor: Colors.white,
      iconBackground: PsColors.primary500,

      title: Utils.getString(context, 'noti_dialog__notification'),
      message: bodyText,

      primaryButtonLabel: Utils.getString(context, 'dialog__ok'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
      },

      secondaryButtonLabel: null,
      onSecondaryTap: null,
    );
  }
}
