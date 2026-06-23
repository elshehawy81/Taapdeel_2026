import 'share_product_data.dart';
import 'share_theme_definition.dart';

class ShareThemeCategoryResolver {
  const ShareThemeCategoryResolver._();

  static List<ShareThemeGroup> resolve(ShareProductData data) {
    final String text = <String>[
      data.category,
      data.subCategory,
      data.title,
      data.description,
    ].join(' ').toLowerCase();

    final List<ShareThemeGroup> groups = <ShareThemeGroup>[];

    void add(ShareThemeGroup group) {
      if (!groups.contains(group)) groups.add(group);
    }

    if (_containsAny(text, const <String>[
      'كتاب',
      'كتب',
      'رواية',
      'روايات',
      'book',
      'books',
      'novel',
      'science book',
    ])) {
      add(ShareThemeGroup.books);
      add(ShareThemeGroup.school);
    }

    if (_containsAny(text, const <String>[
      'رياضة',
      'رياضي',
      'مضرب',
      'تنس',
      'اسكواش',
      'سباحة',
      'كرة',
      'football',
      'sport',
      'sports',
      'racket',
      'gym',
    ])) {
      add(ShareThemeGroup.sports);
    }

    if (_containsAny(text, const <String>[
      'الكترونيات',
      'شاشة',
      'موبايل',
      'سماعة',
      'كاميرا',
      'ساعة',
      'لابتوب',
      'كمبيوتر',
      'بلايستيشن',
      'gaming',
      'electronics',
      'mobile',
      'headset',
      'watch',
      'laptop',
      'Camera',
      'VR',
      'Playstation',
    ])) {
      add(ShareThemeGroup.electronics);
    }

    if (_containsAny(text, const <String>[
      'الموضة',
      'الجمال',
      'ملابس حريمي',
      'حذاء',
      'جزمة',
      'شنطة',
      'فستان',
      'بلوزة',
      'بنطلون',
      'fashion',
      'women',
      'shoes',
      'dress',
      'bag',
      'محجبات',
      'حجاب',
      'طرحة',
      'عباية',
      'خمار',
      'modest',
      'hijab',
      'abaya',
      'نقاب',
      'Hijab',
      'hood',
      'سواريه',
      'makeup',
    ])) {
      add(ShareThemeGroup.womenFashion);
      add(ShareThemeGroup.modestWear);
    }

    if (_containsAny(text, const <String>[
      'رجالي',
      'شباب',
      'بولو',
      'بدلة',
      'بنطلون',
      'تيشيرت',
      'شورت',
      'كوتشي',
    ])) {
      add(ShareThemeGroup.mensWear);
    }

    if (_containsAny(text, const <String>[
      'الطفل',
      'الأم',
      'الام',
      'حديث الولادة',
      'أطفال',
      'عربية أطفال',
      'بيبي',
      'baby',
      'kids',
      'toy',
      'toys',
      'stroller',
    ])) {
      add(ShareThemeGroup.kids);
    }

    if (_containsAny(text, const <String>[
      'ادوات مدرسية',
      'أدوات مدرسية',
      'مدرسة',
      'شنطة مدرسة',
      'كراسة',
      'school',
      'stationery',
      'pencil',
      'backpack',
    ])) {
      add(ShareThemeGroup.school);
      add(ShareThemeGroup.kids);
    }

    if (_containsAny(text, const <String>[
      'المنزل',
      'منزل',
      'ديكور',
      'المطبخ والمائدة',
      'شنط سفر',
      'العناية بالمنزل',
      'اجهزة منزلية',
      'مفروشات',
      'home',
      'decor',
      'kitchen',
      'furniture',
    ])) {
      add(ShareThemeGroup.home);
    }

    if (_containsAny(text, const <String>[
      'العاب',
      'ألعاب',
      'لعبة',
      'العاب ورقية',
      'العاب تعليمية',
      'Games',
      'Game',
      'ذكاء والغاز',
      'بازل',
      'اسكوتر',
      'عجلة',
    ])) {
      add(ShareThemeGroup.games);
    }

    if (groups.isEmpty) {
      add(ShareThemeGroup.general);
    }

    return groups;
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final String keyword in keywords) {
      if (text.contains(keyword.toLowerCase())) return true;
    }
    return false;
  }
}
