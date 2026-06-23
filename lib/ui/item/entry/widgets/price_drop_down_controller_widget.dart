import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/utils/utils.dart';

import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

bool _isWishlist = false;

class PriceDropDownControllerWidget extends StatelessWidget {
  const PriceDropDownControllerWidget({
    Key? key,
    this.PriceRange,
    this.ItemCondition,
    this.currencySymbolController,
    this.userInputPriceController,
  }) : super(key: key);

  final String? ItemCondition, PriceRange;
  final TextEditingController? currencySymbolController;
  final TextEditingController? userInputPriceController;

  /// ✅ دلوقتي مابقيناش نستخدم حالة المنتج في الحساب
  /// المستخدم هو اللي بيحدد رينج السعر مباشرة من الـ dropdown
  String calculate(String? itemCondition, String? priceRange) {
    if (priceRange == null || priceRange.trim().isEmpty) {
      userInputPriceController?.text = '';
      return ' - ';
    }

    // حالة Free زي ما هي
    if (priceRange.trim().toLowerCase() == 'free') {
      userInputPriceController?.text = 'Free';
      return 'Free';
    }

    // نتأكد إن الرينج في شكل "min - max"
    final List<String> parts = priceRange.split('-');
    if (parts.length != 2) {
      // لو الفورمات مختلف، نخزن النص زي ما هو
      final String normalized = priceRange.trim();
      userInputPriceController?.text = normalized;
      return normalized;
    }

    final int min =
        int.tryParse(parts[0].trim()) ?? 0;
    final int max =
        int.tryParse(parts[1].trim()) ?? min;

    final String normalizedRange = '$min - $max';

    // نخزن الرينج في الكنترولر عشان يتبعت للـ backend
    userInputPriceController?.text = normalizedRange;

    return normalizedRange;
  }

  /// 🔶 دالة موحّدة لفتح الديالوج الزجاجي TaapdeelBaseDialog
  void _showInfoDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => TaapdeelBaseDialog(
        title: Utils.getString(context, 'item_entry__price'),
        message: message,
        icon: Icons.info_outline_rounded,
        iconBackground: const Color(0xFF2563EB),
        primaryButtonLabel: Utils.getString(context, 'dialog__ok'),
        onPrimaryTap: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayPrice =
    calculate(ItemCondition, PriceRange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /// ===========================
        ///  Label + Info Icon
        /// ===========================
        Container(
          margin: const EdgeInsetsDirectional.only(
            top: PsDimens.space4,
            start: PsDimens.space6,
            end: PsDimens.space6,
          ),
          child: Row(
            children: <Widget>[
              Text(
                Utils.getString(context, 'item_entry__price'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PsColors.activeColor,
                ),
              ),
              Text(
                ' *',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: PsColors.activeColor,
                ),
              ),
              const SizedBox(width: 4),

              /// 🔸 زر فتح الديالوج
              GestureDetector(
                onTap: () {
                  _showInfoDialog(
                    context,
                    Utils.getString(context, 'swap__price'),
                  );
                },
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFA726),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// ===========================
        ///  Manual / Selected Price Box (من الـ dropdown)
        /// ===========================
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsetsDirectional.only(
                start: PsDimens.space14,
              ),
              width: MediaQuery.of(context).size.width * 0.811,
              height: PsDimens.space44,
              decoration: BoxDecoration(
                color: Utils.isLightMode(context)
                    ? Colors.white
                    : Colors.black54,
                borderRadius: BorderRadius.circular(PsDimens.space4),
                border: Border.all(
                  color: Utils.isLightMode(context)
                      ? Colors.grey[300]!
                      : Colors.black87,
                ),
              ),
              child: Center(
                child: Text(
                  displayPrice,
                  style:
                  Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
            const SizedBox(width: PsDimens.space8),
          ],
        ),
      ],
    );
  }
}

