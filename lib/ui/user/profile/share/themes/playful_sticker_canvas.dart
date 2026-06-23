part of '../profile_share_gallery.dart';

class _PlayfulStickerCanvas extends StatelessWidget {
  const _PlayfulStickerCanvas({required this.products, required this.smartText});
  final List<ShareProductViewData> products;
  final String smartText;

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> list = products.take(6).toList(growable: false);
    final String cuteLine = _cardCuteLineFromSmartText(smartText);
    final String headline = _shortSmartText(smartText);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF072D59), Color(0xFF0E789D), Color(0xFF8DE5E0), Color(0xFFEAFBFF)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(top: 20, left: 18, child: _BrandMark(dark: true, compact: true)),
          Positioned(
            top: 68,
            left: 92,
            right: 18,
            child: Transform.rotate(
              angle: -0.03,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.17), blurRadius: 14)],
                ),
                child: Column(
                  children: <Widget>[
                    const Text(
                      'لقيت لك\nشوية لقطات تبديل',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, height: 1.18, fontWeight: FontWeight.w900, color: Color(0xFF073263)),
                    ),
                    if (headline.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF2C69B7), fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 228, right: 10, left: 10, bottom: 100, child: _PlayfulThemeProducts(products: list)),
          if (cuteLine.isNotEmpty)
            Positioned(bottom: 75, left: 30, right: 30, child: Center(child: _CuteLinePill(text: cuteLine, compact: true))),
          const Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Column(
              children: <Widget>[
                _BrandMark(compact: true),
                SizedBox(height: 4),
                Text('تبديل ذكي لحياة أفضل', style: TextStyle(color: _ShareGalleryColors.navy, fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayfulThemeProducts extends StatelessWidget {
  const _PlayfulThemeProducts({required this.products});
  final List<ShareProductViewData> products;

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> top = products.take(3).toList(growable: false);
    final List<ShareProductViewData> bottom = products.skip(3).take(3).toList(growable: false);

    Widget tile(ShareProductViewData product, int index) {
      return Expanded(
        child: Transform.rotate(
          angle: (index.isEven ? -1 : 1) * 0.035,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 82,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.11), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(15), child: _ProductImageView(image: product.imageUrl, fit: BoxFit.cover)),
              ),
              if (product.hasTitle) ...<Widget>[
                const SizedBox(height: 5),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: <Color>[Color(0xFF2CC7C8), Color(0xFF2F67CA)]),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    product.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8.8, height: 1.1),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: List<Widget>.generate(top.length, (int i) => tile(top[i], i))),
        if (bottom.isNotEmpty) const SizedBox(height: 12),
        if (bottom.isNotEmpty) Row(crossAxisAlignment: CrossAxisAlignment.start, children: List<Widget>.generate(bottom.length, (int i) => tile(bottom[i], i + 3))),
      ],
    );
  }
}
