import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class RetryDialogView extends StatelessWidget {
  const RetryDialogView({
    Key? key,
    this.description,
    this.rightButtonText,
    required this.onAgreeTap,
  }) : super(key: key);

  final String? description;
  final String? rightButtonText;
  final VoidCallback onAgreeTap;

  @override
  Widget build(BuildContext context) {
    final String titleText =
    Utils.getString(context, 'logout_dialog__confirm');

    return TaapdeelBaseDialog(
      icon: Icons.refresh_rounded,
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

      secondaryButtonLabel: null,
      onSecondaryTap: null,
    );
  }
}
