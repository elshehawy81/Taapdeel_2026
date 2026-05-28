part of '../profile_share_gallery.dart';

class _ScrapbookCanvas extends StatelessWidget {
  const _ScrapbookCanvas({required this.products, required this.smartText});
  final List<ShareProductViewData> products;
  final String smartText;

  @override
  Widget build(BuildContext context) {
    final String headline = _shortSmartText(smartText);
    final String cuteLine = _cardCuteLineFromSmartText(smartText);
    return Container(
      color: const Color(0xFFEAF7FF),
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: <Widget>[
          Positioned(top: 0, left: 0, child: Transform.rotate(angle: -0.04, child: Container(color: const Color(0xFFFFF4E1), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: const _BrandMark(compact: true)))),
          const Positioned(top: 34, right: 0, child: _SwapIcon(size: 58)),
          Positioned(top: 86, right: 0, left: 0, child: Column(children: <Widget>[
            const Text('من حاجاتنا اللي تستاهل تتشاف', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, height: 1.15, fontWeight: FontWeight.w900, color: _ShareGalleryColors.navy)),
            if (headline.isNotEmpty) ...<Widget>[const SizedBox(height: 6), Text(headline, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ShareGalleryColors.teal, fontWeight: FontWeight.w700))],
          ])),
          if (cuteLine.isNotEmpty) Positioned(top: 168, right: 18, left: 18, child: Center(child: _CuteLinePill(text: cuteLine, compact: true))),
          Positioned(top: 214, bottom: 48, right: 0, left: 0, child: _StickerGrid(products: products.take(5).toList(growable: false))),
        ],
      ),
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({required this.products});
  final List<ShareProductViewData> products;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 12,
      spacing: 12,
      children: List<Widget>.generate(products.length, (int i) {
        return Transform.rotate(angle: (i.isEven ? -1 : 1) * 0.045, child: SizedBox(width: 92, height: 105, child: _MiniProductTile(product: products[i], sticker: true, compact: true)));
      }),
    );
  }
}
