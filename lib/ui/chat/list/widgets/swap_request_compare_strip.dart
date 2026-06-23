import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/product.dart';

import '../../../Product/product_widget.dart';

class SwapRequestCompareStrip extends StatelessWidget {
  const SwapRequestCompareStrip({
    Key? key,
    required this.myProduct,
    required this.otherProduct,
    this.onTapMyProduct,
    this.onTapOtherProduct,
    this.height = 170,
    this.width = 150,
  }) : super(key: key);

  final Product? myProduct;
  final Product? otherProduct;
  final VoidCallback? onTapMyProduct;
  final VoidCallback? onTapOtherProduct;
  final double height;
  final double width;


  @override
  Widget build(BuildContext context) {
    final double cardHeight = height;
    final double cardWidth = width  ;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _CompareProductSlot(
                product: myProduct,
                onTap: onTapMyProduct,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                slotLabel: 'منتجك',
                coreTagKey: _buildTagKey(myProduct, 'mine'),
              ),
            ),
          ),
          _SwapCenterConnector(size: height * 0.20),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _CompareProductSlot(
                product: otherProduct,
                onTap: onTapOtherProduct,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                slotLabel: 'عرض التبديل',
                coreTagKey: _buildTagKey(otherProduct, 'other'),
              ),
            ),
          ),


        ],
      ),
    );
  }

  String _buildTagKey(Product? product, String fallback) {
    final String id = (product?.id ?? '').trim();
    if (id.isNotEmpty) {
      return 'swap_compare_$fallback\_$id';
    }
    return 'swap_compare_$fallback';
  }
}

class _CompareProductSlot extends StatelessWidget {
  const _CompareProductSlot({
    Key? key,
    required this.product,
    required this.onTap,
    required this.cardWidth,
    required this.cardHeight,
    required this.slotLabel,
    required this.coreTagKey,
  }) : super(key: key);

  final Product? product;
  final VoidCallback? onTap;
  final double cardWidth;
  final double cardHeight;
  final String slotLabel;
  final String coreTagKey;

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return _EmptyCompareCard(
        width: cardWidth,
        height: cardHeight,
        label: slotLabel,
      );
    }

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: TaapdeelProductCardItem(
              coreTagKey: coreTagKey,
              product: product!,
              onTap: onTap ?? () {},
              variant: TaapdeelProductCardVariant.deal,
              showRotatingBanner: true,
              showRelationPanel: true,
              showConditionChip: true,
              onTapFav: null,
              selectedFav: false,
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              outerMargin: EdgeInsets.zero,
            ),
          ),
          Positioned(
            top: -2,
            left: 10,
            child: _SlotBadge(label: slotLabel),
          ),
        ],
      ),
    );
  }
}

class _SlotBadge extends StatelessWidget {
  const _SlotBadge({
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7FA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFD1ECF2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF127E95),
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
        ),
      ),
    );
  }
}

class _SwapCenterConnector extends StatelessWidget {
  const _SwapCenterConnector({
    Key? key,
    required this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: 50,
          height: 48,
          child: Image.asset(
            'assets/images/Taapdeel_icon.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _EmptyCompareCard extends StatelessWidget {
  const _EmptyCompareCard({
    Key? key,
    required this.width,
    required this.height,
    required this.label,
  }) : super(key: key);

  final double width;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FBFD),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFD9E7EE),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFF9CB3C0),
                  size: 28,
                ),
              ),
            ),
          ),
          Positioned(
            top: -2,
            left: 10,
            child: _SlotBadge(label: label),
          ),
        ],
      ),
    );
  }
}