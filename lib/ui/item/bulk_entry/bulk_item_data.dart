// ─────────────────────────────────────────────────────────────────────────────
// bulk_item_data.dart
// Model للمنتج المكتشف من AI قبل ما يدخل ItemEntryView
// ─────────────────────────────────────────────────────────────────────────────

class BulkItemData {
  final String title;
  final String? description;
  final String? categoryHint; // اسم التصنيف للعرض
  final String? subCategoryHint; // اسم التصنيف الفرعي للعرض
  final String? conditionHint; // "جيد", "ممتاز", etc
  final String? priceRangeHint; // fallback قديم لو موجود
  final String? brandHint;

  /// IDs الرسمية القادمة من السيرفر بعد مطابقة التصنيفات.
  final String? categoryId;
  final String? subCategoryId;

  /// متوسط السعر المتوقع من الـ AI إن توفر.
  final String? averagePrice;

  /// صورة المنتج بعد القص التلقائي من الصورة الجماعية.
  final String? croppedImagePath;

  /// الصورة الجماعية الأصلية التي تم اكتشاف المنتج منها.
  /// نستخدمها كصورة إضافية مع كل منتج، وكـ fallback لو القص غير متاح.
  final String? sourceImagePath;

  /// Optional metadata returned by the group/bulk AI.
  /// These are used to reduce the number of follow-up per-item AI calls.
  final List<String>? tagsAr;
  final List<String>? tagsEn;
  final String? tagsConfidence;

  const BulkItemData({
    required this.title,
    this.description,
    this.categoryHint,
    this.subCategoryHint,
    this.conditionHint,
    this.priceRangeHint,
    this.brandHint,
    this.categoryId,
    this.subCategoryId,
    this.averagePrice,
    this.croppedImagePath,
    this.sourceImagePath,
    this.tagsAr,
    this.tagsEn,
    this.tagsConfidence,
  });

  BulkItemData copyWith({
    String? title,
    String? description,
    String? categoryHint,
    String? subCategoryHint,
    String? conditionHint,
    String? priceRangeHint,
    String? brandHint,
    String? categoryId,
    String? subCategoryId,
    String? averagePrice,
    String? croppedImagePath,
    String? sourceImagePath,
    List<String>? tagsAr,
    List<String>? tagsEn,
    String? tagsConfidence,
  }) {
    return BulkItemData(
      title: title ?? this.title,
      description: description ?? this.description,
      categoryHint: categoryHint ?? this.categoryHint,
      subCategoryHint: subCategoryHint ?? this.subCategoryHint,
      conditionHint: conditionHint ?? this.conditionHint,
      priceRangeHint: priceRangeHint ?? this.priceRangeHint,
      brandHint: brandHint ?? this.brandHint,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      averagePrice: averagePrice ?? this.averagePrice,
      croppedImagePath: croppedImagePath ?? this.croppedImagePath,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      tagsAr: tagsAr ?? this.tagsAr,
      tagsEn: tagsEn ?? this.tagsEn,
      tagsConfidence: tagsConfidence ?? this.tagsConfidence,
    );
  }

  @override
  String toString() => 'BulkItemData(title: $title, category: $categoryHint)';
}
