import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';
import 'package:taapdeel/utils/utils.dart';

class ChatNotiDialog extends StatelessWidget {
  const ChatNotiDialog({
    Key? key,
    this.description,
    this.leftButtonText,
    this.rightButtonText,
    this.onAgreeTap,
  }) : super(key: key);

  final String? description;
  final String? leftButtonText;
  final String? rightButtonText;
  final VoidCallback? onAgreeTap;

  @override
  Widget build(BuildContext context) {
    final String title =
    Utils.getString(context, 'noti_dialog__notification');
    final String body =
        description ?? Utils.getString(context, 'chat_noti__new_message');

    return TaapdeelBaseDialog(
      title: title,
      message: body,

      icon: Icons.mail_outline_rounded,
      iconColor: Colors.white,
      iconBackground: Colors.blueAccent,

      primaryButtonLabel:
      rightButtonText ?? Utils.getString(context, 'dialog__ok'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
        onAgreeTap?.call();
      },

      secondaryButtonLabel: leftButtonText,
      onSecondaryTap: leftButtonText == null
          ? null
          : () {
        Navigator.of(context).pop();
      },
    );
  }
}
