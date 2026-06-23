part of '../profile_share_gallery.dart';

class _SoftLifestyleCanvas extends StatelessWidget {
  const _SoftLifestyleCanvas({required this.products, required this.smartText});
  final List<ShareProductViewData> products;
  final String smartText;

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> list = products.take(5).toList(growable: false);
    final String headline = _shortSmartText(smartText);
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFFFFFBF4), Color(0xFFF3EFE6)])),
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        decoration: BoxDecoration(color: const Color(0xFFFFFAF2), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE6D8C5), width: 1.4), boxShadow: <BoxShadow>[BoxShadow(color: _ShareGalleryColors.navy.withOpacity(0.10), blurRadius: 22, offset: const Offset(0, 10))]),
        child: Column(
          children: <Widget>[
            const _BrandMark(compact: true),
            const SizedBox(height: 10),
            const Text('منتجاتك جاهزة للتبديل', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, height: 1.08, fontWeight: FontWeight.w900, color: _ShareGalleryColors.navy)),
            if (headline.isNotEmpty) ...<Widget>[const SizedBox(height: 6), Text(headline, maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.25, fontWeight: FontWeight.w700, color: _ShareGalleryColors.navy.withOpacity(0.58)))],
            const SizedBox(height: 10),
            Expanded(child: _ResponsiveProductGrid(products: list, cardBuilder: (ShareProductViewData p) => _SoftLifestyleProductCard(product: p))),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const <Widget>[_SmallBenefit(label: 'أسهل', icon: Icons.eco_rounded), SizedBox(width: 7), _SmallBenefit(label: 'أذكى', icon: Icons.lightbulb_rounded), SizedBox(width: 7), _SmallBenefit(label: 'أوفر', icon: Icons.groups_rounded)]),
          ],
        ),
      ),
    );
  }
}

class _SoftLifestyleProductCard extends StatelessWidget {
  const _SoftLifestyleProductCard({required this.product});
  final ShareProductViewData product;
  @override
  Widget build(BuildContext context) => _GenericProductCard(product: product, accent: const Color(0xFF0C587A), soft: true);
}
