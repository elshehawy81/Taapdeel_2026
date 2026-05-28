part of 'profile_share_gallery.dart';

class SmartShareTextResolver {
  const SmartShareTextResolver._();

  static String resolve({
    required List<Product> products,
    required ShareGallerySource source,
  }) {
    final List<ShareProductViewData> mapped = ShareProductMapper.fromProducts(products);
    return resolveFromViewData(products: mapped, source: source);
  }

  static String resolveFromViewData({
    required List<ShareProductViewData> products,
    required ShareGallerySource source,
  }) {
    final String joined = products
        .map((ShareProductViewData p) => p.category ?? '')
        .where((String value) => value.trim().isNotEmpty)
        .join(' ')
        .toLowerCase();

    if (source == ShareGallerySource.familyGallery) {
      if (_hasAny(joined, const <String>['toy', 'لعب', 'أطفال', 'kids'])) {
        return 'معرض العيلة فتح أبوابه 😄\nمنتجات العيلة جاهزة للتبديل… يمكن تلاقي حاجة محتاجها.';
      }
      if (_hasAny(joined, const <String>['home', 'kitchen', 'decor', 'منزل', 'مطبخ', 'ديكور'])) {
        return 'معرض العيلة فتح أبوابه 😄\nحاجات من بيتنا ممكن تبدأ حياة جديدة عندك.';
      }
      return 'معرض العيلة فتح أبوابه 😄\nاختار منتج وابعت عرض تبديل مناسب.';
    }

    if (_hasAny(joined, const <String>['game', 'playstation', 'xbox', 'vr', 'gaming', 'ألعاب', 'بلايستيشن'])) {
      return 'حاجاتي جاهزة لتجربة جديدة 👀\nدي منتجاتي المتاحة للتبديل، اختار اللي يناسبك وابعتلي عرضك.';
    }
    if (_hasAny(joined, const <String>['mobile', 'phone', 'laptop', 'electronics', 'إلكترونيات', 'موبايل', 'لاب'])) {
      return 'حاجاتي جاهزة لتجربة جديدة 👀\nبدل ما تشتري جديد… شوف يمكن نبدّل ونكسب الاتنين.';
    }
    if (_hasAny(joined, const <String>['fashion', 'clothes', 'dress', 'shoes', 'أزياء', 'ملابس', 'فستان', 'حذاء'])) {
      return 'حاجاتي جاهزة لتجربة جديدة 👀\nلو عندك حاجة مناسبة، ابعتلي عرض تبديل على TaapdeeL.';
    }
    if (_hasAny(joined, const <String>['book', 'كتب', 'روايات'])) {
      return 'حاجاتي جاهزة لتجربة جديدة 👀\nدي منتجاتي المتاحة للتبديل، اختار اللي يناسبك وابعتلي عرضك.';
    }
    if (_hasAny(joined, const <String>['sport', 'رياضة', 'tennis', 'padel', 'squash'])) {
      return 'حاجاتي جاهزة لتجربة جديدة 👀\nلو عندك حاجة مناسبة، ابعتلي عرض تبديل على TaapdeeL.';
    }
    if (_hasAny(joined, const <String>['home', 'kitchen', 'decor', 'منزل', 'مطبخ', 'ديكور'])) {
      return 'حاجاتي جاهزة لتجربة جديدة 👀\nبدل ما تشتري جديد… شوف يمكن نبدّل ونكسب الاتنين.';
    }

    return 'حاجاتي جاهزة لتجربة جديدة 👀\nلو عندك حاجة مناسبة، ابعتلي عرض تبديل على TaapdeeL.';
  }

  static bool _hasAny(String text, List<String> keys) {
    for (final String key in keys) {
      if (text.contains(key.toLowerCase())) return true;
    }
    return false;
  }
}

String _shortSmartText(String text) {
  final List<String> parts = text
      .trim()
      .split(RegExp(r'[\n\r]+'))
      .map((String e) => e.trim())
      .where((String e) => e.isNotEmpty)
      .toList(growable: false);
  return parts.isEmpty ? '' : parts.first;
}

String _cardCuteLineFromSmartText(String text) {
  final List<String> parts = text
      .trim()
      .split(RegExp(r'[\n\r]+'))
      .map((String e) => e.trim())
      .where((String e) => e.isNotEmpty)
      .toList(growable: false);
  if (parts.length >= 2) return parts[1];
  return parts.isEmpty ? '' : parts.first;
}
