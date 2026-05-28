part of '../profile_share_gallery.dart';

class _GlassPremiumCanvas extends StatelessWidget {
  const _GlassPremiumCanvas({required this.products, required this.smartText});

  final List<ShareProductViewData> products;
  final String smartText;

  @override
  Widget build(BuildContext context) {
    final String headline = _shortSmartText(smartText);
    final String cuteLine = _cardCuteLineFromSmartText(smartText);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[_ShareGalleryColors.deepNavy, _ShareGalleryColors.teal, _ShareGalleryColors.aqua],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.45)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
        child: Column(
          children: <Widget>[
            const _BrandMark(dark: true),
            const SizedBox(height: 16),
            const Text(
              'منتجاتي الجاهزة للتبديل',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, height: 1.03, color: Colors.white, fontWeight: FontWeight.w900),
            ),
            if (headline.isNotEmpty) ...<Widget>[
              const SizedBox(height: 7),
              Text(headline, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.88), fontWeight: FontWeight.w700, fontSize: 11)),
            ],
            if (cuteLine.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Center(child: _CuteLinePill(text: cuteLine, dark: true, compact: true)),
            ],
            const SizedBox(height: 10),
            Expanded(child: _GlassDepthProducts(products: products.take(5).toList(growable: false))),
            const SizedBox(height: 10),
            Text('تبديل أسهل  •  خيارات أكثر  •  قيمة تدوم', style: TextStyle(color: Colors.white.withOpacity(0.86), fontWeight: FontWeight.w800, fontSize: 10.5)),
          ],
        ),
      ),
    );
  }
}

class _GlassDepthProducts extends StatelessWidget {
  const _GlassDepthProducts({required this.products});
  final List<ShareProductViewData> products;

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> visible = products.take(5).toList(growable: false);
    if (visible.isEmpty) return const SizedBox.shrink();
    final List<_GlassDepthSpec> specs = _glassDepthSpecs(visible.length);
    final List<_GlassDepthEntry> entries = <_GlassDepthEntry>[];
    for (int i = 0; i < visible.length; i++) {
      entries.add(_GlassDepthEntry(product: visible[i], spec: specs[i]));
    }
    entries.sort((_GlassDepthEntry a, _GlassDepthEntry b) => a.spec.zIndex.compareTo(b.spec.zIndex));

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double stageWidth = constraints.maxWidth;
        final double stageHeight = constraints.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: 10,
              right: 10,
              bottom: 6,
              child: IgnorePointer(
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.elliptical(220, 58)),
                    gradient: RadialGradient(colors: <Color>[Colors.white.withOpacity(0.16), _ShareGalleryColors.aqua.withOpacity(0.08), Colors.transparent]),
                  ),
                ),
              ),
            ),
            ...entries.map((_GlassDepthEntry entry) {
              final _GlassDepthSpec spec = entry.spec;
              final double cardWidth = stageWidth * spec.widthFactor;
              final double cardHeight = cardWidth / _GlassDepthProductCard.aspectRatio;
              final double desiredTop = stageHeight * spec.topFactor;
              final double safeTop = desiredTop.clamp(0.0, math.max(0.0, stageHeight - cardHeight - 2));
              final double left = (stageWidth * spec.centerX) - (cardWidth / 2);
              return Positioned(
                top: safeTop,
                left: left,
                width: cardWidth,
                child: Opacity(
                  opacity: spec.opacity,
                  child: Transform.rotate(
                    angle: spec.rotation,
                    child: _GlassDepthProductCard(product: entry.product, isHero: spec.isHero, isFront: spec.zIndex >= 3),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _GlassDepthEntry {
  const _GlassDepthEntry({required this.product, required this.spec});
  final ShareProductViewData product;
  final _GlassDepthSpec spec;
}

class _GlassDepthSpec {
  const _GlassDepthSpec({required this.centerX, required this.topFactor, required this.widthFactor, required this.opacity, required this.rotation, required this.zIndex, required this.isHero});
  final double centerX;
  final double topFactor;
  final double widthFactor;
  final double opacity;
  final double rotation;
  final int zIndex;
  final bool isHero;
}

List<_GlassDepthSpec> _glassDepthSpecs(int count) {
  switch (count) {
    case 1:
      return const <_GlassDepthSpec>[
        _GlassDepthSpec(
          centerX: 0.50,
          topFactor: 0.10,
          widthFactor: 0.44,
          opacity: 1,
          rotation: 0,
          zIndex: 5,
          isHero: true,
        ),
      ];

    case 2:
      return const <_GlassDepthSpec>[
        _GlassDepthSpec(
          centerX: 0.50,
          topFactor: 0.02,
          widthFactor: 0.40,
          opacity: .96,
          rotation: 0,
          zIndex: 1,
          isHero: true,
        ),
        _GlassDepthSpec(
          centerX: 0.72,
          topFactor: 0.31,
          widthFactor: 0.33,
          opacity: 1,
          rotation: .07,
          zIndex: 4,
          isHero: false,
        ),
      ];

    case 3:
      return const <_GlassDepthSpec>[
        _GlassDepthSpec(
          centerX: 0.50,
          topFactor: 0.01,
          widthFactor: 0.40,
          opacity: .95,
          rotation: 0,
          zIndex: 1,
          isHero: true,
        ),
        _GlassDepthSpec(
          centerX: 0.27,
          topFactor: 0.27,
          widthFactor: 0.32,
          opacity: 1,
          rotation: -.08,
          zIndex: 3,
          isHero: false,
        ),
        _GlassDepthSpec(
          centerX: 0.73,
          topFactor: 0.27,
          widthFactor: 0.32,
          opacity: 1,
          rotation: .08,
          zIndex: 4,
          isHero: false,
        ),
      ];

    case 4:
      return const <_GlassDepthSpec>[
        _GlassDepthSpec(
          centerX: 0.50,
          topFactor: 0.00,
          widthFactor: 0.40,
          opacity: .95,
          rotation: 0,
          zIndex: 1,
          isHero: true,
        ),
        _GlassDepthSpec(
          centerX: 0.27,
          topFactor: 0.25,
          widthFactor: 0.32,
          opacity: 1,
          rotation: -.08,
          zIndex: 3,
          isHero: false,
        ),
        _GlassDepthSpec(
          centerX: 0.73,
          topFactor: 0.25,
          widthFactor: 0.32,
          opacity: 1,
          rotation: .08,
          zIndex: 4,
          isHero: false,
        ),
        _GlassDepthSpec(
          centerX: 0.50,
          topFactor: 0.56,
          widthFactor: 0.29,
          opacity: 1,
          rotation: .02,
          zIndex: 5,
          isHero: false,
        ),
      ];

    default:
      return const <_GlassDepthSpec>[
        _GlassDepthSpec(
          centerX: 0.50,
          topFactor: 0.00,
          widthFactor: 0.40,
          opacity: .96,
          rotation: 0,
          zIndex: 1,
          isHero: true,
        ),
        _GlassDepthSpec(
          centerX: 0.26,
          topFactor: 0.24,
          widthFactor: 0.31,
          opacity: 1,
          rotation: -.08,
          zIndex: 3,
          isHero: false,
        ),
        _GlassDepthSpec(
          centerX: 0.74,
          topFactor: 0.24,
          widthFactor: 0.31,
          opacity: 1,
          rotation: .08,
          zIndex: 4,
          isHero: false,
        ),
        _GlassDepthSpec(
          centerX: 0.20,
          topFactor: 0.55,
          widthFactor: 0.27,
          opacity: 1,
          rotation: -.12,
          zIndex: 5,
          isHero: false,
        ),
        _GlassDepthSpec(
          centerX: 0.80,
          topFactor: 0.55,
          widthFactor: 0.27,
          opacity: 1,
          rotation: .12,
          zIndex: 6,
          isHero: false,
        ),
      ];
  }
}


class _GlassDepthProductCard extends StatelessWidget {
  const _GlassDepthProductCard({required this.product, required this.isHero, required this.isFront});
  static const double aspectRatio = 0.70;
  final ShareProductViewData product;
  final bool isHero;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isHero ? 25 : 22),
          border: Border.all(color: isHero ? const Color(0xFFB7F6FF) : Colors.white.withOpacity(0.90), width: isHero ? 1.6 : 1.2),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black.withOpacity(isFront ? .20 : .11), blurRadius: isFront ? 16 : 10, offset: Offset(0, isFront ? 8 : 4)),
            if (isFront) BoxShadow(color: _ShareGalleryColors.aqua.withOpacity(.12), blurRadius: 18, spreadRadius: 1),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isHero ? 24 : 21),
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Colors.white, isHero ? const Color(0xFFF0FDFF) : const Color(0xFFF9FEFF)])))),
              Positioned(top: isHero ? 38 : 33, left: 9, right: 9, bottom: product.hasTitle || product.hasCategory ? (isHero ? 60 : 55) : 10, child: _ProductImageView(image: product.imageUrl, fit: BoxFit.contain)),
              if (product.hasTitle) Positioned(left: 8, right: 8, bottom: product.hasCategory ? (isHero ? 34 : 31) : 10, child: Text(product.title!, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: _ShareGalleryColors.navy, fontSize: isHero ? 10.6 : 9.3, height: 1.05, fontWeight: FontWeight.w900))),
              if (product.hasCategory) Positioned(left: 11, right: 11, bottom: 9, child: Container(padding: EdgeInsets.symmetric(horizontal: isHero ? 8 : 6, vertical: isHero ? 5 : 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), gradient: const LinearGradient(colors: <Color>[Color(0xFF20C7C9), Color(0xFF1B74B8)])), child: Text(product.category!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isHero ? 8.8 : 7.8, fontWeight: FontWeight.w900, height: 1.0)))),
            ],
          ),
        ),
      ),
    );
  }
}
