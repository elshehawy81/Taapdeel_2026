part of '../profile_share_gallery.dart';

class _NeonCanvas extends StatelessWidget {
  const _NeonCanvas({required this.products, required this.smartText});
  final List<ShareProductViewData> products;
  final String smartText;

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> list = products.take(4).toList(growable: false);
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(center: Alignment.topRight, radius: 1.30, colors: <Color>[Color(0xFF073A5F), Color(0xFF010A1E), Color(0xFF000713)]),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _NeonOrbitPainter())),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  const Row(children: <Widget>[_BrandMark(dark: true, compact: true), Spacer(), _SwapIcon(size: 48)]),
                  const Text('افتح باب التبديل', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, height: 1, fontWeight: FontWeight.w900, color: Color(0xFF18F0E4), shadows: <Shadow>[Shadow(color: Color(0xAA00E5FF), blurRadius: 18)])),
                  const SizedBox(height: 14),
                  Expanded(child: _NeonProductsBoard(products: list)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF18D9E1).withOpacity(0.35))),
                    child: const Text('اختَر منتجك وابدأ التبديل', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonProductsBoard extends StatelessWidget {
  const _NeonProductsBoard({required this.products});
  final List<ShareProductViewData> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    Widget buildCard(ShareProductViewData product, {required double width, required double height, double angle = 0}) {
      return Transform.rotate(angle: angle, child: SizedBox(width: width, height: height, child: _NeonShowcaseCard(product: product)));
    }

    if (products.length == 1) return Center(child: buildCard(products.first, width: 165, height: 228));
    if (products.length == 2) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        buildCard(products[0], width: 128, height: 184, angle: -0.04),
        const SizedBox(width: 16),
        buildCard(products[1], width: 128, height: 184, angle: 0.04),
      ]);
    }

    final List<ShareProductViewData> top = products.take(2).toList(growable: false);
    final List<ShareProductViewData> bottom = products.skip(2).take(2).toList(growable: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List<Widget>.generate(top.length, (int i) => buildCard(top[i], width: 118, height: 168, angle: i == 0 ? -0.05 : 0.05))),
        if (bottom.isNotEmpty) const SizedBox(height: 16),
        if (bottom.isNotEmpty) Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List<Widget>.generate(bottom.length, (int i) => buildCard(bottom[i], width: 118, height: 168, angle: i == 0 ? -0.02 : 0.02))),
      ],
    );
  }
}

class _NeonShowcaseCard extends StatelessWidget {
  const _NeonShowcaseCard({required this.product});
  final ShareProductViewData product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF07182E).withOpacity(0.96), borderRadius: BorderRadius.circular(22), border: Border.all(width: 2, color: const Color(0xFF18D9E1)), boxShadow: <BoxShadow>[BoxShadow(color: _ShareGalleryColors.aqua.withOpacity(0.42), blurRadius: 18, spreadRadius: 1)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: Alignment.topRight, radius: 1.25, colors: <Color>[const Color(0xFF0A4F77).withOpacity(0.78), const Color(0xFF061A32)])))),
            Positioned(top: 8, right: 8, left: 8, bottom: product.hasTitle ? 42 : 8, child: ClipRRect(borderRadius: BorderRadius.circular(14), child: _ProductImageView(image: product.imageUrl, fit: BoxFit.cover))),
            if (product.hasTitle)
              Positioned(right: 8, left: 8, bottom: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: Colors.black.withOpacity(0.28), borderRadius: BorderRadius.circular(12)), child: Text(product.title!, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, height: 1.15)))),
          ],
        ),
      ),
    );
  }
}

class _NeonOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint ring = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.3;
    final Offset center = Offset(size.width * 0.52, size.height * 0.69);
    for (int i = 0; i < 5; i++) {
      ring.color = const Color(0xFF18F0E4).withOpacity(0.23 - i * 0.025);
      canvas.drawOval(Rect.fromCenter(center: center, width: size.width * (0.72 + i * 0.12), height: size.height * (0.23 + i * 0.055)), ring);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
