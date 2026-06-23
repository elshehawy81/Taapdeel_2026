import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';

class ChoosePaymentTypeDialog extends StatelessWidget {
  const ChoosePaymentTypeDialog({
    Key? key,
    this.onInAppPurchaseTap,
    this.onFirstPaymentTap,
    this.onSecondPaymentTap,
    this.onOtherPaymentTap,
  }) : super(key: key);

  /// Old usage from product_detail_view:
  /// ChoosePaymentTypeDialog(onInAppPurchaseTap: () async { ... })
  final VoidCallback? onInAppPurchaseTap;

  /// Optional aliases if حبيت تستخدم أسماء تانية جوه الكود.
  final VoidCallback? onFirstPaymentTap;
  final VoidCallback? onSecondPaymentTap;

  /// Used in some places as: onOtherPaymentTap: () async { ... }
  final VoidCallback? onOtherPaymentTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Primary action: in-app purchase أو firstPayment لو الأولى مش موجودة.
    final VoidCallback? primaryCallback =
        onInAppPurchaseTap ?? onFirstPaymentTap;

    // Secondary action: لو الكود بيبعت onOtherPaymentTap نستخدمها،
    // لو مش موجودة ممكن نرجع لـ onSecondPaymentTap.
    final VoidCallback? secondaryCallback =
        onOtherPaymentTap ?? onSecondPaymentTap;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(PsDimens.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: PsDimens.space8),

              Text(
                'Choose payment method',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: PsDimens.space24),

              // Primary action → In-App Purchase (أو first payment)
              TaapdeelButton(
                label: 'Go to in-app purchase',
                onPressed: () {
                  Navigator.pop(context);
                  primaryCallback?.call();
                },
                isPrimary: true,
                isExpanded: true,
              ),

              const SizedBox(height: PsDimens.space16),

              // Secondary action (other payment) لو متوفر
              if (secondaryCallback != null)
                TaapdeelButton(
                  label: 'Other payment method',
                  onPressed: () {
                    Navigator.pop(context);
                    secondaryCallback.call();
                  },
                  isPrimary: false,
                  isExpanded: true,
                  outlined: true,
                )
              else
                TaapdeelButton(
                  label: 'Cancel',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  isPrimary: false,
                  isExpanded: true,
                  outlined: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
