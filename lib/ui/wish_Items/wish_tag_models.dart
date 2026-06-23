class WishTag {
  final String id;
  final String ar;
  final String en;

  const WishTag({required this.id, required this.ar, required this.en});

  factory WishTag.fromJson(Map<String, dynamic> json) => WishTag(
        id: (json['id'] ?? '').toString(),
        ar: (json['ar'] ?? '').toString(),
        en: (json['en'] ?? '').toString(),
      );

  String label(bool isArabic) => isArabic ? ar : en;
}

class SubCategoryTagBundle {
  final String subCategoryId;
  final String subCategoryNameAr;
  final String subCategoryNameEn;
  final String catId;
  final String catNameAr;
  final String catNameEn;
  final List<WishTag> tags;

  const SubCategoryTagBundle({
    required this.subCategoryId,
    required this.subCategoryNameAr,
    required this.subCategoryNameEn,
    required this.catId,
    required this.catNameAr,
    required this.catNameEn,
    required this.tags,
  });

  factory SubCategoryTagBundle.fromJson(Map<String, dynamic> json) =>
      SubCategoryTagBundle(
        subCategoryId: (json['sub_category_id'] ?? '').toString(),
        subCategoryNameAr: (json['sub_category_name_ar'] ?? '').toString(),
        subCategoryNameEn: (json['sub_category_name_en'] ?? '').toString(),
        catId: (json['cat_id'] ?? '').toString(),
        catNameAr: (json['cat_name_ar'] ?? '').toString(),
        catNameEn: (json['cat_name_en'] ?? '').toString(),
        tags: ((json['tags'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => WishTag.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class WishTagsCatalog {
  final List<SubCategoryTagBundle> bundles;

  const WishTagsCatalog({required this.bundles});

  factory WishTagsCatalog.fromJson(Map<String, dynamic> json) => WishTagsCatalog(
        bundles: ((json['bundles'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => SubCategoryTagBundle.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

/// Template used by "احكي أمنيتك" to propose story hooks based on item text.
class HawadeetHookTemplate {
  const HawadeetHookTemplate({
    required this.id,
    required this.categoryKey,
    required this.title,
    required this.hook,
    required this.storyText,
    required this.personaType,
    required this.needReason,
    this.keywords = const <String>[],
  });

  final String id;
  final String categoryKey;
  final String title;
  final String hook;
  final String storyText;
  final String personaType;
  final String needReason;
  final List<String> keywords;
}

/// Filter used by Hawadeet/Wish grid.
class HawadeetCategoryFilter {
  const HawadeetCategoryFilter({
    required this.key,
    required this.label,
    required this.iconName,
    required this.keywords,
  });

  final String key;
  final String label;
  final String iconName;
  final List<String> keywords;
}
