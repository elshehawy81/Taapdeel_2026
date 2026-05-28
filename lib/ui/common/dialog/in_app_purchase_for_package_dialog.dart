import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class InAppPurchaseBuyPackageDialog extends StatelessWidget {
  const InAppPurchaseBuyPackageDialog({
    Key? key,
    required this.onInAppPurchaseTap,
  }) : super(key: key);

  final VoidCallback onInAppPurchaseTap;

  @override
  Widget build(BuildContext context) {
    return TaapdeelBaseDialog(
      icon: Icons.shopping_bag_rounded,
      iconColor: Colors.white,
      iconBackground: PsColors.primary500,

      title: Utils.getString(
        context,
        'item_entry__buy_package_title',
      ),

      message: '',

      primaryButtonLabel: Utils.getString(
        context,
        'item_entry__package_go_to_shop',
      ),

      onPrimaryTap: () {
        onInAppPurchaseTap();
      },

      secondaryButtonLabel: null,
      onSecondaryTap: null,
    );
  }
}
