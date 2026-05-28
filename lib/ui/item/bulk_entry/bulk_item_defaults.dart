// ─────────────────────────────────────────────────────────────────────────────
// bulk_item_defaults.dart
// القيم الافتراضية المشتركة لجميع منتجات الـ Bulk session
// ─────────────────────────────────────────────────────────────────────────────

class BulkItemDefaults {
  final String? categoryId;
  final String? categoryName;
  final String? subCategoryId;
  final String? subCategoryName;

  /// ID حالة المنتج (1..5)
  final String conditionId;
  final String conditionName;

  /// ID مدة الاستخدام (1..9)
  final String usageDurationId;
  final String usageDurationName;

  const BulkItemDefaults({
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.conditionId = '3',
    this.conditionName = 'جيد',
    this.usageDurationId = '4',
    this.usageDurationName = '6 - 12 شهور',
  });

  BulkItemDefaults copyWith({
    String? categoryId,
    String? categoryName,
    String? subCategoryId,
    String? subCategoryName,
    String? conditionId,
    String? conditionName,
    String? usageDurationId,
    String? usageDurationName,
  }) {
    return BulkItemDefaults(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      conditionId: conditionId ?? this.conditionId,
      conditionName: conditionName ?? this.conditionName,
      usageDurationId: usageDurationId ?? this.usageDurationId,
      usageDurationName: usageDurationName ?? this.usageDurationName,
    );
  }
}
