import 'package:flutter/material.dart';
import 'package:taapdeel/ui/Product/product_widget.dart';
import 'package:taapdeel/viewobject/product.dart';

class CheckSwapItem extends StatelessWidget {
  const CheckSwapItem({
    Key? key,
    required this.product,
    required this.onChecked,
    required this.onTap,
    required this.isChecked,
    this.isFocused = false,
    this.ribbonText,
  }) : super(key: key);

  final bool? isChecked;
  final bool isFocused;
  final String? ribbonText;
  final Product product;
  final void Function(bool?)? onChecked;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool selected = isFocused || (isChecked ?? false);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: selected
                ? const Color(0xFF19C2D8)
                : const Color(0xFF60A5FA).withOpacity(0.28),
            width: selected ? 3.2 : 1.4,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: selected
                  ? const Color(0x3319C2D8)
                  : const Color(0x12011934),
              blurRadius: selected ? 18 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: TaapdeelProductCardItem(
                  coreTagKey: 'swap_pick_${product.id ?? ""}_',
                  product: product,
                  onTap: () {},
                  variant: TaapdeelProductCardVariant.family,
                  showRotatingBanner: true,
                  showRelationPanel: true,
                  showConditionChip: true,
                  onTapFav: null,
                  selectedFav: false,
                  cardWidth: double.infinity,
                  cardHeight: double.infinity,
                  outerMargin: EdgeInsets.zero,
                ),
              ),
            ),


            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: onTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

