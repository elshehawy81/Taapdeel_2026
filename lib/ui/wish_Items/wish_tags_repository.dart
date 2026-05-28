import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'wish_tag_models.dart';

class WishTagsRepository {
  WishTagsCatalog? _cache;

  Future<WishTagsCatalog> _load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/wish_tags_catalog.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _cache = WishTagsCatalog.fromJson(map);
    return _cache!;
  }

  String _normalizeAr(String s) {
    return s
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  Future<List<SubCategoryTagBundle>> bundles() async {
    return (await _load()).bundles;
  }

  Future<List<SubCategoryTagBundle>> findBundlesByPreferredSubIds(
    Iterable<String> subIds,
  ) async {
    final ids = subIds.map((e) => e.toString()).toSet();
    return (await bundles()).where((b) => ids.contains(b.subCategoryId)).toList();
  }

  Future<List<WishTag>> searchTags(String query) async {
    final q = _normalizeAr(query);
    if (q.isEmpty) return const <WishTag>[];

    final result = <WishTag>[];
    for (final bundle in await bundles()) {
      for (final tag in bundle.tags) {
        final ar = _normalizeAr(tag.ar);
        final en = tag.en.toLowerCase();
        if (ar.contains(q) || en.contains(q)) result.add(tag);
      }
    }
    return result;
  }

  /// Hawadeet filters used by the wish grid and future DB screens.
  static const List<HawadeetCategoryFilter> hawadeetFilters =
      <HawadeetCategoryFilter>[
    HawadeetCategoryFilter(
      key: 'all',
      label: 'كل الحواديت',
      iconName: 'auto_stories',
      keywords: <String>[],
    ),
    HawadeetCategoryFilter(
      key: 'clothes_events',
      label: 'ملابس ومناسبات',
      iconName: 'checkroom',
      keywords: <String>['فستان', 'بدلة', 'روب', 'ملابس', 'شنطة', 'حذاء', 'فرح', 'خطوبة', 'تخرج'],
    ),
    HawadeetCategoryFilter(
      key: 'school_books',
      label: 'كتب ومدرسة',
      iconName: 'menu_book',
      keywords: <String>['كتاب', 'كتب', 'رواية', 'مدرسة', 'خارجي', 'أدوات', 'ادوات', 'مكتبة', 'supplies'],
    ),
    HawadeetCategoryFilter(
      key: 'kids_toys',
      label: 'أطفال ولعب',
      iconName: 'toys',
      keywords: <String>['لعبة', 'العاب', 'ألعاب', 'طفل', 'أطفال', 'اطفال', 'ليجو', 'بازل'],
    ),
    HawadeetCategoryFilter(
      key: 'home_clutter',
      label: 'بيت وكراكيب',
      iconName: 'home',
      keywords: <String>['بيت', 'كراكيب', 'مطبخ', 'ديكور', 'أثاث', 'اثاث', 'دولاب', 'مركونة'],
    ),
    HawadeetCategoryFilter(
      key: 'electronics',
      label: 'إلكترونيات',
      iconName: 'devices',
      keywords: <String>['موبايل', 'ايفون', 'جراب', 'كاميرا', 'لاب', 'إلكترونيات', 'الكترونيات'],
    ),
    HawadeetCategoryFilter(
      key: 'sports',
      label: 'رياضة',
      iconName: 'sports_soccer',
      keywords: <String>['رياضة', 'تمرين', 'مضرب', 'تنس', 'اسكواش', 'كاراتيه', 'كرة'],
    ),
    HawadeetCategoryFilter(
      key: 'gifts',
      label: 'هدايا ومناسبات',
      iconName: 'card_giftcard',
      keywords: <String>['هدية', 'عيد ميلاد', 'مناسبة', 'فرح', 'خطوبة', 'تخرج'],
    ),
  ];

  /// Hook templates shown in "احكي أمنيتك".
  static const List<HawadeetHookTemplate> hawadeetHookTemplates =
      <HawadeetHookTemplate>[
    HawadeetHookTemplate(
      id: 'dress_seen_before',
      categoryKey: 'clothes_events',
      title: 'فستان شافوه قبل كده',
      hook: 'كل الفساتين اللي عندي شافوني بيها قبل كده',
      storyText: 'عندي مناسبة ومش عايزة أشتري فستان جديد عشان يوم واحد.',
      personaType: 'daughter',
      needReason: 'مناسبة جاية',
      keywords: <String>['فستان', 'فساتين', 'فرح', 'خطوبة'],
    ),
    HawadeetHookTemplate(
      id: 'one_day_clothes',
      categoryKey: 'clothes_events',
      title: 'لبس ليوم واحد',
      hook: 'هنشتريه عشان يوم واحد؟',
      storyText: 'محتاجينه في مناسبة واحدة، وبعدها غالبًا هيدخل الدولاب.',
      personaType: 'family',
      needReason: 'توفير مصاريف',
      keywords: <String>['بدلة', 'روب', 'لبس', 'حذاء', 'شنطة'],
    ),
    HawadeetHookTemplate(
      id: 'kg_robe_450',
      categoryKey: 'clothes_events',
      title: 'روب التخرج أبو 450',
      hook: 'نشتريهم بـ450 جنيه عشان يوم واحد؟ دول كانوا مصاريفي في 5 سنين كلية!',
      storyText: 'المدرسة طالبة روب وطاقية لحفلة التخرج، والاستخدام ساعات قليلة فقط.',
      personaType: 'couple',
      needReason: 'مناسبة مدرسية',
      keywords: <String>['روب', 'تخرج', 'طاقية', 'كي جي', 'kg'],
    ),
    HawadeetHookTemplate(
      id: 'library_store',
      categoryKey: 'school_books',
      title: 'المكتبة اللي بقت مخزن',
      hook: 'المكتبة بقت مخزن',
      storyText: 'كتب وروايات وكتب خارجية خلصناها ولسه واخدة مكان في البيت.',
      personaType: 'mother',
      needReason: 'تقليل الكراكيب',
      keywords: <String>['كتب', 'كتاب', 'رواية', 'روايات', 'مكتبة'],
    ),
    HawadeetHookTemplate(
      id: 'books_done',
      categoryKey: 'school_books',
      title: 'كتب خلصت مهمتها',
      hook: 'الكتب دي خلصت مهمتها عندنا',
      storyText: 'كتاب خلص عندك ممكن يبدأ سنة جديدة في بيت تاني.',
      personaType: 'family',
      needReason: 'بداية الدراسة',
      keywords: <String>['كتب', 'مدرسة', 'خارجي', 'خارجيه'],
    ),
    HawadeetHookTemplate(
      id: 'school_supplies',
      categoryKey: 'school_books',
      title: 'لسه الأدوات المدرسية؟',
      hook: 'كل ده ولسه مجبناش الأدوات المدرسية؟',
      storyText: 'قائمة المدرسة طويلة وممكن نبدّل شنط وأدوات وكتب بدل شراء كل حاجة جديدة.',
      personaType: 'couple',
      needReason: 'بداية الدراسة',
      keywords: <String>['أدوات', 'ادوات', 'مدرسة', 'شنطة', 'مقلمة', 'supplies'],
    ),
    HawadeetHookTemplate(
      id: 'toy_two_days',
      categoryKey: 'kids_toys',
      title: 'اللعبة اللي اتلعبت يومين',
      hook: 'اللعبة دي كانت غالية واترمت بعد يومين',
      storyText: 'الأطفال بيكبروا بسرعة، واللعب المركونة ممكن تفرّح طفل تاني.',
      personaType: 'mother',
      needReason: 'توفير مصاريف',
      keywords: <String>['لعبة', 'ألعاب', 'العاب', 'ليجو', 'بازل'],
    ),
    HawadeetHookTemplate(
      id: 'clutter_treasure',
      categoryKey: 'home_clutter',
      title: 'كراكيب ولا كنوز؟',
      hook: 'في بيتك حاجة مركونة… وفي بيت تاني مستنيها',
      storyText: 'الحاجة اللي مش محتاجها ممكن تحل مشكلة بيت تاني.',
      personaType: 'family',
      needReason: 'تقليل الكراكيب',
      keywords: <String>['كراكيب', 'بيت', 'ديكور', 'مطبخ', 'دولاب'],
    ),
    HawadeetHookTemplate(
      id: 'not_everything_new',
      categoryKey: 'home_clutter',
      title: 'مش لازم جديد',
      hook: 'مش كل حاجة ناقصة لازم تتشترى',
      storyText: 'قبل ما تشتري، شوف ممكن تبدّلها بحاجة مركونة عندك.',
      personaType: 'family',
      needReason: 'توفير مصاريف',
      keywords: <String>['محتاج', 'عايز', 'عاوزه', 'نفسي'],
    ),
    HawadeetHookTemplate(
      id: 'old_phone_drawer',
      categoryKey: 'electronics',
      title: 'الموبايل القديم في الدرج',
      hook: 'لسه جايبالُه جراب جديد',
      storyText: 'إكسسوارات موبايل قديم عندك ممكن تكون بالضبط اللي حد تاني بيدور عليه.',
      personaType: 'daughter',
      needReason: 'استفادة من الموجود',
      keywords: <String>['موبايل', 'جراب', 'ايفون', 'سكرينة', 'كاميرا'],
    ),
  ];

  List<HawadeetHookTemplate> hooksForText(String text) {
    final String normalized = _normalizeAr(text);
    if (normalized.isEmpty) {
      return hawadeetHookTemplates.take(4).toList(growable: false);
    }

    final List<HawadeetHookTemplate> matches =
        hawadeetHookTemplates.where((HawadeetHookTemplate t) {
      return t.keywords.any((String keyword) {
        return normalized.contains(_normalizeAr(keyword));
      });
    }).toList(growable: false);

    if (matches.isNotEmpty) return matches.take(5).toList(growable: false);
    return hawadeetHookTemplates.take(5).toList(growable: false);
  }
}
