part of 'profile_share_gallery.dart';

enum ShareGallerySource { myProducts, familyGallery }

enum ShareGalleryThemeType {
  playfulStickers,
  cleanMarketplace,
  neonDark,
  softLifestyle,
  scrapbook,
  luxuryDeck,
  energeticPromo,
  glassPremium,
}

class ShareGalleryThemeConfig {
  const ShareGalleryThemeConfig({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final ShareGalleryThemeType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

@immutable
class ShareProductViewData {
  const ShareProductViewData({
    required this.id,
    this.title,
    this.category,
    this.imageUrl,
  });

  final String id;
  final String? title;
  final String? category;
  final String? imageUrl;

  bool get hasTitle => title != null && title!.trim().isNotEmpty;
  bool get hasCategory => category != null && category!.trim().isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
}

class _SafeShareTarget {
  const _SafeShareTarget({
    required this.key,
    required this.products,
    required this.smartText,
    required this.source,
    required this.profileUserId,
    required this.referralCode,
  });

  final GlobalKey key;
  final List<Product> products;
  final String smartText;
  final ShareGallerySource source;
  final String profileUserId;
  final String referralCode;
}
