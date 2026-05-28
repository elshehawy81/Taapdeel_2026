import 'package:taapdeel/viewobject/category.dart';

/// ====== Category Personalization Rules (Gender + Age) ======
///
/// بنشتغل بمفاتيح ثابتة (Keys) علشان ما نعتمدش على لغة اسم التصنيف:
///  - toys
///  - school_supplies
///  - books
///  - sports
///  - fashion_beauty
///  - electronics
///  - hobbies
///  - Discover
///  - moms
///  - clothes
///  - other
///
/// بعدين نعمل Mapping من catName (عربي / إنجليزي) → key

const Map<String, Map<String, List<String>>> kCategoryOrderRules = {
  'female': {
    '6-9': [
      'toys',
      'sports',
      'fashion_beauty',
      'electronics',
      'school_supplies',
      'books',
      'hobbies',
      'home',
      'moms',
      'clothes',
      'other',
    ],
    '10-11': [
      'toys',
      'fashion_beauty',
      'sports',
      'electronics',
      'school_supplies',
      'books',
      'hobbies',
      'home',
      'moms',
      'clothes',
      'other',
    ],
    '12-15': [
      'fashion_beauty',
      'toys',
      'electronics',
      'books',
      'sports',
      'school_supplies',
      'hobbies',
      'home',
      'moms',
      'clothes',
      'other',
    ],
    '16-22': [
      'fashion_beauty',
      'electronics',
      'books',
      'hobbies',
      'sports',
      'toys',
      'school_supplies',
      'home',
      'moms',
      'clothes',
      'other',
    ],
    '23-35': [
      'fashion_beauty',
      'electronics',
      'home',
      'toys',
      'books',
      'hobbies',
      'sports',
      'school_supplies',
      'moms',
      'clothes',
      'other',
    ],
    '36-50': [
      'fashion_beauty',
      'home',
      'moms',
      'school_supplies',
      'toys',
      'books',
      'electronics',
      'hobbies',
      'sports',
      'clothes',
      'other',
    ],
    '50+': [
      'home',
      'hobbies',
      'fashion_beauty',
      'books',
      'sports',
      'other',
      'moms',
      'electronics',
      'school_supplies',
      'toys',
      'clothes',
    ],
  },
  'male': {
    '6-9': [
      'toys',
      'school_supplies',
      'sports',
      'books',
      'electronics',
      'hobbies',
      'clothes',
      'fashion_beauty',
      'home',
      'moms',
      'other',
    ],
    '10-11': [
      'toys',
      'electronics',
      'sports',
      'school_supplies',
      'books',
      'hobbies',
      'clothes',
      'fashion_beauty',
      'home',
      'moms',
      'other',
    ],
    '12-15': [
      'toys',
      'electronics',
      'sports',
      'school_supplies',
      'books',
      'clothes',
      'fashion_beauty',
      'hobbies',
      'home',
      'moms',
      'other',
    ],
    '16-22': [
      'electronics',
      'toys',
      'sports',
      'clothes',
      'books',
      'school_supplies',
      'other',
      'hobbies',
      'home',
      'fashion_beauty',
      'moms',
    ],
    '23-35': [
      'electronics',
      'sports',
      'clothes',
      'other',
      'toys',
      'books',
      'hobbies',
      'school_supplies',
      'fashion_beauty',
      'home',
      'moms',
    ],
    '36-50': [
      'electronics',
      'sports',
      'clothes',
      'other',
      'hobbies',
      'books',
      'toys',
      'school_supplies',
      'fashion_beauty',
      'home',
      'moms',

    ],
    '50+': [
      'books',
      'clothes',
      'sports',
      'other',
      'electronics',
      'hobbies',
      'home',
      'school_supplies',
      'fashion_beauty',
      'moms',
      'toys',
    ],
  },
};

/// تحويل قيمة الفئة العمرية المخزّنة → مفتاح جدول القواعد
String? mapAgeRangeToRuleKey(String? ageRange) {
  if (ageRange == null || ageRange.isEmpty) return null;

  switch (ageRange) {
    case '12-':
      return '10-11';
    case '12-15':
      return '12-15';
    case '16-22':
      return '16-22';
    case '23-35':
      return '23-35';
    case '36-50':
      return '36-50';
    case '50+':
      return '50+';
    default:
      return null;
  }
}

/// ✅ Public Mapping من اسم التصنيف (عربي / إنجليزي) → key موحّد
/// (دي اللي هنستخدمها في أي ملف تاني زي WishItemEntryView)
String mapCategoryNameToKey(String rawName) {
  final String name = rawName.trim().toLowerCase();

  // ملابس / Clothes
  if (name.contains('ملابس') ||
      name.contains('احذية') ||
      name.contains('أحذية') ||
      name.contains('shoes') ||
      name.contains('clothes') ||
      name.contains('clothing') ||
      name.contains('apparel')) {
    return 'clothes';
  }

  // موضة وجمال / Fashion & Beauty
  if (name.contains('موضة') ||
      name.contains('جمال') ||
      name.contains('beauty') ||
      name.contains('fashion') ||
      name.contains('makeup') ||
      name.contains('make-up') ||
      name.contains('cosmetic')) {
    return 'fashion_beauty';
  }

  // أمهات / Moms
  if (name.contains('أمهات') ||
      name.contains('الام') ||
      name.contains('الطفل') ||
      name.contains('moms') ||
      name.contains('mom') ||
      name.contains('mother')) {
    return 'moms';
  }

  // المنزل / Home
  if (name.contains('المنزل') ||
      name.contains('منزل') ||
      name.contains('Discover') ||
      name.contains('house') ||
      name.contains('household')) {
    return 'home';
  }

  // أدوات مدرسية / School Supplies
  if (name.contains('أدوات مدرسية') ||
      name.contains('ادوات مدرسية') ||
      name.contains('مدرسية') ||
      name.contains('school') ||
      name.contains('stationery') ||
      name.contains('supplies')) {
    return 'school_supplies';
  }

  // هوايات ومهن / Hobbies & Crafts
  if (name.contains('هوايات') ||
      name.contains('مهن') ||
      name.contains('هواية') ||
      name.contains('hobby') ||
      name.contains('hobbies') ||
      name.contains('craft') ||
      name.contains('crafts') ||
      name.contains('skills')) {
    return 'hobbies';
  }

  // كتب / Books
  if (name.contains('كتب') ||
      name.contains('كتاب') ||
      name.contains('books') ||
      name.contains('book') ||
      name.contains('reading')) {
    return 'books';
  }

  // إلكترونيات / Electronics
  if (name.contains('إلكترونيات') ||
      name.contains('الكترونيات') ||
      name.contains('الكترونك') ||
      name.contains('electronics') ||
      name.contains('electronic') ||
      name.contains('devices') ||
      name.contains('gadgets')) {
    return 'electronics';
  }

  // ألعاب / Toys
  if (name.contains('ألعاب') ||
      name.contains('العاب') ||
      name.contains('toy') ||
      name.contains('toys') ||
      name.contains('game') ||
      name.contains('games')) {
    return 'toys';
  }

  // رياضة / Sports
  if (name.contains('رياضة') ||
      name.contains('رياضي') ||
      name.contains('sports') ||
      name.contains('sport') ||
      name.contains('fitness')) {
    return 'sports';
  }

  return 'other';
}

/// توحيد قيمة gender لأي شكل (male/female أو عربي)
String? normalizeGender(String? gender) {
  if (gender == null) return null;
  final String g = gender.trim().toLowerCase();
  if (g.isEmpty) return null;

  if (g == 'male' || g == 'm' || g.contains('ذكر')) return 'male';
  if (g == 'female' || g == 'f' || g.contains('أنث') || g.contains('انث')) {
    return 'female';
  }
  return null;
}

/// دالة عامة لإعادة ترتيب التصنيفات بناء على (النوع + الفئة العمرية)
void sortCategoriesByProfile({
  required List<Category> categories,
  required String? gender,
  required String? ageRange,
}) {
  if (categories.isEmpty) return;

  final String? g = normalizeGender(gender);
  if (g == null) return;

  final String? ageGroupKey = mapAgeRangeToRuleKey(ageRange);
  if (ageGroupKey == null) return;

  final Map<String, List<String>>? genderRules = kCategoryOrderRules[g];
  final List<String>? ruleOrder = genderRules?[ageGroupKey];
  if (ruleOrder == null) return;

  // Map: key → ترتيب الأولوية
  final Map<String, int> orderIndex = <String, int>{
    for (int i = 0; i < ruleOrder.length; i++) ruleOrder[i]: i,
  };

  categories.sort((Category a, Category b) {
    final String keyA = mapCategoryNameToKey(a.catName ?? '');
    final String keyB = mapCategoryNameToKey(b.catName ?? '');

    final int indexA = orderIndex[keyA] ?? 999;
    final int indexB = orderIndex[keyB] ?? 999;

    return indexA.compareTo(indexB);
  });
}
