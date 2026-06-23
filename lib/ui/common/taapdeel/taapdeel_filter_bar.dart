import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_chip.dart';

class TaapdeelFilterBar<T> extends StatelessWidget {
  const TaapdeelFilterBar({
    Key? key,
    required this.items,
    required this.labelBuilder,
    required this.selectedItems,
    required this.onSelectionChanged,
    this.multiSelect = true,
    this.compactChips = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: PsDimens.space16,
    ),
    this.spacing = PsDimens.space8,
  }) : super(key: key);

  /// قائمة العناصر المعروضة كـ Chips
  final List<T> items;

  /// طريقة عرض النص لكل عنصر
  final String Function(T item) labelBuilder;

  /// العناصر المختارة حاليًا
  final List<T> selectedItems;

  /// كول باك عند تغيير الاختيار
  final ValueChanged<List<T>> onSelectionChanged;

  /// هل يدعم اختيار أكثر من عنصر؟
  final bool multiSelect;

  /// Chip بحجم أصغر؟
  final bool compactChips;

  /// Padding خارجي للشريط (من برّه الـ Glass)
  final EdgeInsetsGeometry padding;

  /// المسافة بين الـ chips
  final double spacing;

  bool _isSelected(T item) => selectedItems.contains(item);

  void _handleTap(T item) {
    final List<T> current = List<T>.from(selectedItems);

    if (multiSelect) {
      if (current.contains(item)) {
        current.remove(item);
      } else {
        current.add(item);
      }
    } else {
      if (current.length == 1 && current.first == item) {
        // لو ضغط على نفس العنصر في single-select → نفك الاختيار
        current.clear();
      } else {
        current
          ..clear()
          ..add(item);
      }
    }

    onSelectionChanged(current);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // ----------------------------
    // Row of premium chips
    // ----------------------------
    final Widget chipsRow = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: spacing),
            TaapdeelChip(
              label: labelBuilder(items[i]),
              selected: _isSelected(items[i]),
              compact: compactChips,
              minWidth: 72,   // 👈 يضمن إن الكبسولة مش أصغر من كده
              withShadow: false,          // 👈 مهم جداً
              onTap: () => _handleTap(items[i]),
            ),
          ],
        ],
      ),
    );

    // ----------------------------
    // Glass Container لـ Filter Bar
    // ----------------------------
    const BorderRadius barRadius = BorderRadius.all(Radius.circular(28));

    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: barRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PsDimens.space8,
              vertical: PsDimens.space4,
            ),
            decoration: const BoxDecoration(
              borderRadius: barRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xF2FFFFFF), // white @ ~95%
                  Color(0xD9F3FFFE), // mint / ice blue tint
                ],
              ),
              border: Border.fromBorderSide(
                BorderSide(
                  color: Color(0xE6FFFFFF), // white @ ~90%
                  width: 1.0,
                ),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0x1A6FD8CD), // Mint @ 10%
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: chipsRow,
          ),
        ),
      ),
    );
  }
}
