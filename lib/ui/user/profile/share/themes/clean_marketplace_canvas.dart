part of '../profile_share_gallery.dart';

class _CleanMarketplaceCanvas extends StatelessWidget {
  const _CleanMarketplaceCanvas({required this.products, required this.smartText});
  final List<ShareProductViewData> products;
  final String smartText;

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> list = products.take(4).toList(growable: false);
    final String headline = _shortSmartText(smartText);
    final String cuteLine = _cardCuteLineFromSmartText(smartText);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFFF2FAFC), Color(0xFFE6F5F8)]),
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFB9E6EC), width: 1.4),
          boxShadow: <BoxShadow>[BoxShadow(color: _ShareGalleryColors.teal.withOpacity(0.16), blurRadius: 22, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(top: 0, left: 0, child: _BrandMark(compact: true)),
            Positioned(
              top: 80,
              right: 0,
              left: 0,
              child: Column(
                children: <Widget>[
                  const Text('مجموعة تبديل مختارة', textAlign: TextAlign.center, style: TextStyle(fontSize: 29, height: 1.05, fontWeight: FontWeight.w900, color: _ShareGalleryColors.navy)),
                  if (headline.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(headline, maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: _ShareGalleryColors.text.withOpacity(0.62), fontWeight: FontWeight.w700)),
                  ],
                ],
              ),
            ),
            Positioned(top: 180, right: 0, left: 0, height: 170, child: _MarketplaceRow(products: list)),
            if (cuteLine.isNotEmpty) Positioned(bottom: 98, right: 0, left: 0, child: Center(child: _CuteLinePill(text: cuteLine, compact: true))),
            Positioned(
              bottom: 48,
              right: 0,
              left: 0,
              child: Container(
                height: 43,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: <Color>[Color(0xFF004A78), Color(0xFF0C8CAC)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('استكشف المزيد على Taapdeel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
              ),
            ),
            const Positioned(bottom: 6, right: 0, left: 0, child: Center(child: Text('Taapdeel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _ShareGalleryColors.navy, fontFamily: 'serif')))),
          ],
        ),
      ),
    );
  }
}

class _MarketplaceRow extends StatelessWidget {
  const _MarketplaceRow({required this.products});
  final List<ShareProductViewData> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Row(
      children: List<Widget>.generate(products.length, (int i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _MarketplaceProductShowcaseCard(product: products[i]),
          ),
        );
      }),
    );
  }
}

class _MarketplaceProductShowcaseCard extends StatelessWidget {
  const _MarketplaceProductShowcaseCard({required this.product});
  final ShareProductViewData product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE0EAF0)), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 9, offset: const Offset(0, 5))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: _ProductImageView(image: product.imageUrl)),
                  if (product.hasCategory)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF004A78), borderRadius: BorderRadius.circular(999)),
                        child: Text(product.category!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w900)),
                      ),
                    ),
                ],
              ),
            ),
            if (product.hasTitle)
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 6, 5, 5),
                child: Text(product.title!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: _ShareGalleryColors.navy, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
          ],
        ),
      ),
    );
  }
}
