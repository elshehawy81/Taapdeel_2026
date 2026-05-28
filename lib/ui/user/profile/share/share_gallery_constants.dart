part of 'profile_share_gallery.dart';

class _ShareGalleryDims {
  const _ShareGalleryDims._();

  static const double canvasWidth = 390;
  static const double canvasHeight = 560;
  static const int maxSelectedProducts = 8;
  static const int minSelectedProducts = 2;
  static const int initialSelectedProducts = 5;
  static const int maxLoadedProducts = 50;
  static const int previewPixelRatio = 3;
}

class _ShareGalleryColors {
  const _ShareGalleryColors._();

  static const Color navy = Color(0xFF0F2E57);
  static const Color deepNavy = Color(0xFF011934);
  static const Color teal = Color(0xFF0C587A);
  static const Color aqua = Color(0xFF24A9C4);
  static const Color softBg = Color(0xFFF7FBFD);
  static const Color text = Color(0xFF102A43);
}

const List<ShareGalleryThemeConfig> kShareGalleryThemes = <ShareGalleryThemeConfig>[
  ShareGalleryThemeConfig(
    type: ShareGalleryThemeType.playfulStickers,
    title: 'لقطات تبديل',
    subtitle: 'ستايل ملصقات لطيف وشبابي',
    icon: Icons.auto_awesome_rounded,
    colors: <Color>[Color(0xFF0B376D), Color(0xFF26C7C9), Color(0xFFFF7B6E)],
  ),
  ShareGalleryThemeConfig(
    type: ShareGalleryThemeType.cleanMarketplace,
    title: 'مجموعة مختارة',
    subtitle: 'شكل كتالوج واضح واحترافي',
    icon: Icons.dashboard_customize_rounded,
    colors: <Color>[Color(0xFFFFFFFF), Color(0xFF0C587A), Color(0xFF24A9C4)],
  ),
  ShareGalleryThemeConfig(
    type: ShareGalleryThemeType.neonDark,
    title: 'افتح باب التبديل',
    subtitle: 'ستايل غامق مضيء وجذاب',
    icon: Icons.bolt_rounded,
    colors: <Color>[Color(0xFF010A1E), Color(0xFF00E5FF), Color(0xFF10C7B8)],
  ),
  ShareGalleryThemeConfig(
    type: ShareGalleryThemeType.softLifestyle,
    title: 'جاهزة للتبديل',
    subtitle: 'هادئ ومناسب للمنتجات الراقية',
    icon: Icons.spa_rounded,
    colors: <Color>[Color(0xFFFFFAF2), Color(0xFF0F2E57), Color(0xFF1AA7A8)],
  ),

  ShareGalleryThemeConfig(
    type: ShareGalleryThemeType.scrapbook,
    title: 'حاجات تستاهل تتشاف',
    subtitle: 'سكراب بوك ولطيف للعائلة',
    icon: Icons.push_pin_rounded,
    colors: <Color>[Color(0xFFEAF7FF), Color(0xFF0F2E57), Color(0xFF38C7C7)],
  ),
  ShareGalleryThemeConfig(
    type: ShareGalleryThemeType.luxuryDeck,
    title: 'اختيارات مميزة',
    subtitle: 'كروت فاخرة للمنتجات القيمة',
    icon: Icons.diamond_rounded,
    colors: <Color>[Color(0xFFFFFFFF), Color(0xFF001E3C), Color(0xFF008C8C)],
  ),
  ShareGalleryThemeConfig(
    type: ShareGalleryThemeType.energeticPromo,
    title: 'جاهز تبدّل؟',
    subtitle: 'بوستر إعلاني واضح ومتحرك',
    icon: Icons.campaign_rounded,
    colors: <Color>[Color(0xFF002E5D), Color(0xFF00AFAE), Color(0xFFFFFFFF)],
  ),
  ShareGalleryThemeConfig(
    type: ShareGalleryThemeType.glassPremium,
    title: 'منتجاتي للتبديل',
    subtitle: 'زجاجي Premium قريب من هوية تبديل',
    icon: Icons.blur_on_rounded,
    colors: <Color>[Color(0xFF011934), Color(0xFF0C587A), Color(0xFF24A9C4)],
  ),

];
