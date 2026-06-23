part of 'profile_share_gallery.dart';

class ShareProductMapper {
  const ShareProductMapper._();

  static ShareProductViewData? fromProduct(Product product) {
    final String id = _clean(product.id);
    if (id.isEmpty) return null;

    return ShareProductViewData(
      id: id,
      title: _nullIfEmpty(product.title),
      category: _nullIfEmpty(
        product.subCategory?.name ?? product.category?.catName,
      ),
      imageUrl: _nullIfEmpty(product.defaultPhoto?.imgPath),
    );
  }

  static List<ShareProductViewData> fromProducts(
      Iterable<Product> products, {
        int? limit,
      }) {
    final List<ShareProductViewData> result = <ShareProductViewData>[];

    for (final Product product in products) {
      final ShareProductViewData? mapped = fromProduct(product);
      if (mapped == null) continue;

      result.add(mapped);
      if (limit != null && result.length >= limit) break;
    }

    return result;
  }

  static String safeProductId(Product product) {
    return fromProduct(product)?.id ?? '';
  }

  static String? productTitle(Product product) {
    return fromProduct(product)?.title;
  }

  static String? productCategory(Product product) {
    return fromProduct(product)?.category;
  }

  static String? productImage(Product product) {
    return fromProduct(product)?.imageUrl;
  }

  static String _clean(Object? value) {
    final String clean = (value ?? '').toString().trim();
    return clean == 'null' ? '' : clean;
  }

  static String? _nullIfEmpty(Object? value) {
    final String clean = _clean(value);
    return clean.isEmpty ? null : clean;
  }
}