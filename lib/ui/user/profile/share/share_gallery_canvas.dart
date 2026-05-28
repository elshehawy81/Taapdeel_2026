part of 'profile_share_gallery.dart';

class ShareGalleryCanvas extends StatelessWidget {
  const ShareGalleryCanvas({
    Key? key,
    required this.source,
    required this.products,
    required this.theme,
    required this.smartText,
  }) : super(key: key);

  final ShareGallerySource source;
  final List<Product> products;
  final ShareGalleryThemeType theme;
  final String smartText;

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> viewProducts = ShareProductMapper.fromProducts(products);
    const double width = _ShareGalleryDims.canvasWidth;
    const double height = _ShareGalleryDims.canvasHeight;

    switch (theme) {
      case ShareGalleryThemeType.playfulStickers:
        return _CanvasFrame(width: width, height: height, child: _PlayfulStickerCanvas(products: viewProducts, smartText: smartText));
      case ShareGalleryThemeType.cleanMarketplace:
        return _CanvasFrame(width: width, height: height, child: _CleanMarketplaceCanvas(products: viewProducts, smartText: smartText));
      case ShareGalleryThemeType.neonDark:
        return _CanvasFrame(width: width, height: height, child: _NeonCanvas(products: viewProducts, smartText: smartText));
      case ShareGalleryThemeType.softLifestyle:
        return _CanvasFrame(width: width, height: height, child: _SoftLifestyleCanvas(products: viewProducts, smartText: smartText));
      case ShareGalleryThemeType.scrapbook:
        return _CanvasFrame(width: width, height: height, child: _ScrapbookCanvas(products: viewProducts, smartText: smartText));
      case ShareGalleryThemeType.luxuryDeck:
        return _CanvasFrame(width: width, height: height, child: _LuxuryDeckCanvas(products: viewProducts, smartText: smartText));
      case ShareGalleryThemeType.energeticPromo:
        return _CanvasFrame(width: width, height: height, child: _EnergeticPromoCanvas(products: viewProducts, smartText: smartText));
      case ShareGalleryThemeType.glassPremium:
        return _CanvasFrame(width: width, height: height, child: _GlassPremiumCanvas(products: viewProducts, smartText: smartText));
     }
  }
}
