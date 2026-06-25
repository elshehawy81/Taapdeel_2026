import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/product.dart';

List<Map<String, dynamic>> castSwapBreakdown(dynamic rawAny) {
  final raw = rawAny is List ? rawAny : const <dynamic>[];
  final out = <Map<String, dynamic>>[];
  for (final e in raw) {
    if (e is Map) out.add(Map<String, dynamic>.from(e));
  }
  return out;
}

enum SwapBadgeTone {
  golden,
  excellent,
  suitable,
  neutral,
}

class SwapBadge {
  final String title;
  final IconData icon;
  final SwapBadgeTone tone;

  const SwapBadge({
    required this.title,
    required this.icon,
    required this.tone,
  });
}

class SwapBadgeStyle {
  const SwapBadgeStyle({
    required this.outerGradient,
    required this.innerGradient,
    required this.border,
    required this.innerBorder,
    required this.glow,
    required this.iconGradient,
    required this.iconRing,
    required this.iconFg,
    required this.accent,
    required this.textColor,
    required this.shine,
  });

  final List<Color> outerGradient;
  final List<Color> innerGradient;
  final Color border;
  final Color innerBorder;
  final Color glow;
  final List<Color> iconGradient;
  final Color iconRing;
  final Color iconFg;
  final Color accent;
  final Color textColor;
  final Color shine;
}

class InlineSwapVM {
  final int percent;
  final SwapBadge badge;

  const InlineSwapVM({
    required this.percent,
    required this.badge,
  });
}

const Color kFamilyRecommendationAccent = Color(0xFF8B5CF6);
const Color kFamilyRecommendationAccentDark = Color(0xFF5B21B6);
const Color kFamilyRecommendationBg = Color(0xFFF3E8FF);
const Color kFamilyRecommendationBorder = Color(0xFFA855F7);
const Color kFamilyRecommendationShadow = Color(0x338B5CF6);

class SwapCriterionItem {
  const SwapCriterionItem({
    required this.icon,
    required this.label,
    required this.enabled,
    this.isWarning = false,
    this.isGold = false,
    this.isFamilyInterest = false,
    this.overlayIcon,
    this.iconColor,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
  });

  final IconData icon;
  final IconData? overlayIcon;
  final String label;
  final bool enabled;
  final bool isWarning;
  final bool isGold;
  final bool isFamilyInterest;
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
}

SwapBadge swapBadgeFromPercent(int p) {
  final int percent = p.clamp(0, 100);

  if (percent > 80) {
    return const SwapBadge(
      title: 'فرصة ذهبية',
      icon: Icons.workspace_premium_rounded,
      tone: SwapBadgeTone.golden,
    );
  }

  if (percent >= 60) {
    return const SwapBadge(
      title: 'فرصة ممتازة',
      icon: Icons.verified_rounded,
      tone: SwapBadgeTone.excellent,
    );
  }

  if (percent >= 40) {
    return const SwapBadge(
      title: 'تبديل مناسب',
      icon: Icons.tips_and_updates_rounded,
      tone: SwapBadgeTone.suitable,
    );
  }

  return const SwapBadge(
    title: 'بنفس متوسط السعر',
    icon: Icons.info_rounded,
    tone: SwapBadgeTone.neutral,
  );
}

SwapBadgeStyle swapBadgeStyleForBadge(SwapBadge badge) {
  switch (badge.tone) {
    case SwapBadgeTone.golden:
      return const SwapBadgeStyle(
        outerGradient: <Color>[Color(0xFFFFF8DF), Color(0xFFF2E1A6)],
        innerGradient: <Color>[Color(0xFFFFF8DF), Color(0xFFF2E1A6)],
        border: Color(0xFFD8A33B),
        innerBorder: Color(0xFFFFF0BE),
        glow: Color(0x3FC99A2B),
        iconGradient: <Color>[Color(0xFF6D4700), Color(0xFFB97B12)],
        iconRing: Color(0xFFF3D78D),
        iconFg: Color(0xFFFFFFFF),
        accent: Color(0xFFD59A18),
        textColor: Color(0xFF6E4A00),
        shine: Color(0x52FFFFFF),
      );

    case SwapBadgeTone.excellent:
      return const SwapBadgeStyle(
        outerGradient: <Color>[Color(0xFF62EAF4), Color(0xFF149BB5)],
        innerGradient: <Color>[Color(0xFFEFFFFF), Color(0xFFC8F7FB)],
        border: Color(0xFF15AFC6),
        innerBorder: Color(0xFFAEEBF2),
        glow: Color(0x3314BDD2),
        iconGradient: <Color>[Color(0xFF0B6D83), Color(0xFF17B9D0)],
        iconRing: Color(0xFF98EEF6),
        iconFg: Color(0xFFFFFFFF),
        accent: Color(0xFF0FC4DA),
        textColor: Color(0xFF0C6070),
        shine: Color(0x48FFFFFF),
      );

    case SwapBadgeTone.suitable:
      return const SwapBadgeStyle(
        outerGradient: <Color>[Color(0xFFF5F2DE), Color(0xFFE6DEB2)],
        innerGradient: <Color>[Color(0xFFFCFAEE), Color(0xFFF0E9C9)],
        border: Color(0xFFB7A96A),
        innerBorder: Color(0xFFF0E6BC),
        glow: Color(0x2FBFA24A),
        iconGradient: <Color>[Color(0xFF7A6A2E), Color(0xFFC4A85A)],
        iconRing: Color(0xFFE9DEB1),
        iconFg: Color(0xFFFFFFFF),
        accent: Color(0xFFB99B43),
        textColor: Color(0xFF6D5B23),
        shine: Color(0x42FFFFFF),
      );

    case SwapBadgeTone.neutral:
      return const SwapBadgeStyle(
        outerGradient: <Color>[Color(0xFFEAF2F7), Color(0xFFD6E4EE)],
        innerGradient: <Color>[Color(0xFFF8FBFD), Color(0xFFE6EEF4)],
        border: Color(0xFF8DA7B8),
        innerBorder: Color(0xFFD7E4EC),
        glow: Color(0x1F6E8EA3),
        iconGradient: <Color>[Color(0xFF5D788A), Color(0xFF87A3B5)],
        iconRing: Color(0xFFD2E0E8),
        iconFg: Color(0xFFFFFFFF),
        accent: Color(0xFF6F8FA3),
        textColor: Color(0xFF486273),
        shine: Color(0x40FFFFFF),
      );
  }
}

SwapBadgeStyle swapBadgeStyleFromPercent(int p) {
  return swapBadgeStyleForBadge(swapBadgeFromPercent(p));
}

class _BreakdownReader {
  const _BreakdownReader(this.items);

  final List<Map<String, dynamic>> items;

  Map<String, dynamic>? find(Iterable<String> keys) {
    for (final b in items) {
      final String key = (b['key'] ?? '').toString().trim().toLowerCase();
      if (keys.contains(key)) return b;
    }
    return null;
  }

  bool hasKey(Iterable<String> keys) => find(keys) != null;

  int? valueAsInt(Map<String, dynamic>? item) {
    if (item == null) return null;
    final v = item['value'];
    if (v is int) return v;
    return int.tryParse('${v ?? ''}');
  }

  int pointsAsInt(Map<String, dynamic>? item) {
    if (item == null) return 0;
    final v = item['points'];
    if (v is int) return v;
    return int.tryParse('${v ?? ''}') ?? 0;
  }

  String why(Map<String, dynamic>? item) {
    if (item == null) return '';
    return (item['why'] ?? '').toString().trim();
  }
}

String relationLabelFromId(int id) {
  switch (id) {
    case 1:
      return 'صديق';
    case 2:
      return 'زوج/زوجة';
    case 3:
      return 'ابن/ابنة';
    case 4:
      return 'الأب/الأم';
    case 5:
      return 'الأخ/الأخت';
    case 6:
      return 'عائلة كبيرة';
    case 777:
      return 'أنت';
    case 999:
      return 'صديق صديقك';
    case 1001:
      return 'عائلة صديقك';
    case 1002:
      return 'قريب صديقك';
    case 1003:
      return 'صديق عائلتك';
    case 1004:
      return 'صديق قريبك';
    case 1005:
      return 'أقاربك';
    default:
      return '';
  }
}

String _cleanOwnerNameCandidate(dynamic value) {
  final String s = (value ?? '').toString().trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return '';
  return s;
}

String _safeOwnerNameCandidate(String Function() getter) {
  try {
    return _cleanOwnerNameCandidate(getter());
  } catch (_) {
    return '';
  }
}

String _ownerNameFromBreakdownItem(Map<String, dynamic>? item) {
  if (item == null) return '';

  const List<String> keys = <String>[
    'user_name',
  ];

  for (final String key in keys) {
    final String value = _cleanOwnerNameCandidate(item[key]);
    if (value.isNotEmpty) return value;
  }

  return '';
}

String _productOwnerDisplayName(Product? p) {
  if (p == null) return '';

  final dynamic d = p;
  final List<String Function()> candidates = <String Function()>[
        () => '${d.addedUserName ?? ''}',
        () => '${d.added_user_name ?? ''}',
        () => '${d.userName ?? ''}',
        () => '${d.user_name ?? ''}',
        () => '${d.username ?? ''}',
        () => '${d.sellerName ?? ''}',
        () => '${d.seller_name ?? ''}',
        () => '${d.ownerName ?? ''}',
        () => '${d.owner_name ?? ''}',
        () => '${d.addedUser?.userName ?? ''}',
        () => '${d.addedUser?.user_name ?? ''}',
        () => '${d.addedUser?.username ?? ''}',
        () => '${d.addedUser?.name ?? ''}',
        () => '${d.user?.userName ?? ''}',
        () => '${d.user?.user_name ?? ''}',
        () => '${d.user?.username ?? ''}',
        () => '${d.user?.name ?? ''}',
  ];

  for (final String Function() candidate in candidates) {
    final String value = _safeOwnerNameCandidate(candidate);
    if (value.isNotEmpty) return value;
  }

  return '';
}

String _relationReasonLabel({
  required Product product,
  required int relationVal,
  Map<String, dynamic>? relationItem,
  String? ownerNameOverride,
}) {
  final String relation = relationLabelFromId(relationVal).trim();
  if (relation.isEmpty) return '';

  final String ownerNameFromOverride =
  _cleanOwnerNameCandidate(ownerNameOverride);

  final String ownerNameFromBreakdown = _ownerNameFromBreakdownItem(relationItem);

  final String ownerName = ownerNameFromOverride.isNotEmpty
      ? ownerNameFromOverride
      : ownerNameFromBreakdown.isNotEmpty
      ? ownerNameFromBreakdown
      : _productOwnerDisplayName(product);

  if (ownerName.isNotEmpty) {
    return 'من $ownerName ($relation)';
  }

  return 'من $relation';
}

String _normalizeId(dynamic value) {
  final String s = (value ?? '').toString().trim();
  if (s.isEmpty || s.toLowerCase() == 'null') {
    return '';
  }
  return s;
}


int? _parseIntValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();

  final String text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  final double? asDouble = double.tryParse(text);
  if (asDouble != null) return asDouble.round();

  return int.tryParse(text);
}

dynamic _safeRead(dynamic Function() getter) {
  try {
    return getter();
  } catch (_) {
    return null;
  }
}

String _cleanNonNullText(dynamic value) {
  final String text = (value ?? '').toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return '';
  return text;
}

String _firstTextValue(List<dynamic Function()> readers) {
  for (final dynamic Function() reader in readers) {
    final String value = _cleanNonNullText(_safeRead(reader));
    if (value.isNotEmpty) return value;
  }
  return '';
}

int? _productConditionId(Product p) {
  final dynamic d = p;
  return _parseIntValue(_safeRead(() => d.conditionOfItemId)) ??
      _parseIntValue(_safeRead(() => d.condition_of_item_id)) ??
      _parseIntValue(_safeRead(() => d.conditionOfItem?.id)) ??
      _parseIntValue(_safeRead(() => d.condition_of_item?.id)) ??
      _parseIntValue(_safeRead(() => d.conditionOfItem?.value)) ??
      _parseIntValue(_safeRead(() => d.condition_of_item?.value));
}

int? _productItemTypeId(Product p) {
  final dynamic d = p;
  return _parseIntValue(_safeRead(() => d.itemTypeId)) ??
      _parseIntValue(_safeRead(() => d.item_type_id)) ??
      _parseIntValue(_safeRead(() => d.itemType?.id)) ??
      _parseIntValue(_safeRead(() => d.item_type?.id)) ??
      _parseIntValue(_safeRead(() => d.itemType?.value)) ??
      _parseIntValue(_safeRead(() => d.item_type?.value));
}

int? _productBusinessMode(Product p) {
  final dynamic d = p;
  return _parseIntValue(_safeRead(() => d.businessMode)) ??
      _parseIntValue(_safeRead(() => d.business_mode));
}

String _productBrandValue(Product p) {
  final dynamic d = p;
  return _firstTextValue(<dynamic Function()>[
        () => d.brand,
        () => d.brandName,
        () => d.brand_name,
  ]);
}

bool _productIsImported(Product p) {
  final dynamic d = p;

  final dynamic direct = _safeRead(() => d.isImported) ??
      _safeRead(() => d.is_imported);

  final String directText = _cleanNonNullText(direct).toLowerCase();
  if (direct == true || directText == '1' || directText == 'true') {
    return true;
  }

  final dynamic highlight = _safeRead(() => d.highlightInfo) ??
      _safeRead(() => d.highlight_info);

  if (highlight is Map) {
    final dynamic imported = highlight['is_imported'] ?? highlight['isImported'];
    final String importedText = _cleanNonNullText(imported).toLowerCase();
    return imported == true || importedText == '1' || importedText == 'true';
  }

  final String highlightText = _cleanNonNullText(highlight).toLowerCase();
  return highlightText.contains('"is_imported":true') ||
      highlightText.contains('"isimported":true');
}

String _productLocationId(Product? p) {
  if (p == null) return '';

  final candidates = <dynamic>[
    p.itemLocationId,
    p.itemLocation?.id,
  ];

  for (final c in candidates) {
    final normalized = _normalizeId(c);
    if (normalized.isNotEmpty) return normalized;
  }

  return '';
}

String _productTownshipId(Product? p) {
  if (p == null) return '';

  final candidates = <dynamic>[
    p.itemLocationTownshipId,
    p.itemLocationTownship?.id,
  ];

  for (final c in candidates) {
    final normalized = _normalizeId(c);
    if (normalized.isNotEmpty) return normalized;
  }

  return '';
}

String _resolveLocationMatchLabel({
  required Product? myProduct,
  required Product suggestedProduct,
}) {
  final String myLocationId = _productLocationId(myProduct);
  final String suggestedLocationId = _productLocationId(suggestedProduct);

  if (myLocationId.isEmpty || suggestedLocationId.isEmpty) {
    return 'محافظة مختلفة';
  }

  if (myLocationId != suggestedLocationId) {
    return 'محافظة مختلفة';
  }

  final String myTownshipId = _productTownshipId(myProduct);
  final String suggestedTownshipId = _productTownshipId(suggestedProduct);

  if (myTownshipId.isNotEmpty &&
      suggestedTownshipId.isNotEmpty &&
      myTownshipId == suggestedTownshipId) {
    return 'نفس المحافظة والحي';
  }

  return 'نفس المحافظة';
}

InlineSwapVM buildInlineSwapVM({
  required int percent,
  required List<Map<String, dynamic>> breakdown,
}) {
  final int p = percent.clamp(0, 100);

  return InlineSwapVM(
    percent: p,
    badge: swapBadgeFromPercent(p),
  );
}

bool _textContainsAny(String text, Iterable<String> values) {
  final String normalized = text.trim().toLowerCase();
  if (normalized.isEmpty) return false;

  for (final String value in values) {
    if (normalized.contains(value.toLowerCase())) return true;
  }

  return false;
}

IconData _relationIconForLabel(String label) {
  if (_textContainsAny(label, const <String>[
    'صديق',
    'صديقه',
    'صديقتك',
    'friend',
  ])) {
    return Icons.handshake_rounded;
  }

  if (_textContainsAny(label, const <String>[
    'قريب',
    'أقارب',
    'اقارب',
    'عائلة',
    'عائلتك',
    'ابن',
    'ابنة',
    'الأب',
    'الأم',
    'الأخ',
    'الأخت',
    'زوج',
    'زوجة',
  ])) {
    return Icons.family_restroom_rounded;
  }

  return Icons.supervisor_account_rounded;
}

SwapCriterionItem _locationCriterion({
  required String label,
  required bool enabled,
  required bool isWarning,
}) {
  if (isWarning) {
    return SwapCriterionItem(
      icon: Icons.wrong_location_rounded,
      label: label,
      enabled: enabled,
      isWarning: true,
      iconColor: const Color(0xFFD65A5A),
      textColor: const Color(0xFF9E3A3A),
      backgroundColor: const Color(0xFFFFF1F1),
      borderColor: const Color(0xFFF2C7C7),
      shadowColor: const Color(0x14D65A5A),
    );
  }

  final bool sameNeighborhood = _textContainsAny(label, const <String>[
    'الحي',
    'المنطقة',
    'نفس المنطقة',
  ]);

  return SwapCriterionItem(
    icon: sameNeighborhood
        ? Icons.maps_home_work_rounded
        : Icons.location_on_sharp,
    label: label,
    enabled: enabled,
    iconColor: sameNeighborhood
        ? const Color(0xFF00897B)
        : const Color(0xFF0C587A),
    textColor: sameNeighborhood
        ? const Color(0xFF00695C)
        : const Color(0xFF123B52),
    backgroundColor: sameNeighborhood
        ? const Color(0xFFE6F7F4)
        : const Color(0xFFEAF8FC),
    borderColor: sameNeighborhood
        ? const Color(0xFF8EDBD1)
        : const Color(0xFFBFEAF0),
    shadowColor: sameNeighborhood
        ? const Color(0x1800897B)
        : const Color(0x120C587A),
  );
}

List<SwapCriterionItem> buildSuggestedSwapCriteria(
    Product p,
    InlineSwapVM vm, {
      Product? myProduct,
      int? relationTypeOverride,
      String? relationOwnerNameOverride,
    }) {
  final reader = _BreakdownReader(castSwapBreakdown(p.swapScoreBreakdown));

  final conditionItem = reader.find(['condition']);
  final itemTypeItem = reader.find(['item_type']);
  final brandItem = reader.find(['brand']);
  final businessModeItem = reader.find(['business_mode']);

  final int? conditionVal = reader.valueAsInt(conditionItem) ?? _productConditionId(p);
  final int? itemTypeVal = reader.valueAsInt(itemTypeItem) ?? _productItemTypeId(p);
  final int? businessModeVal = reader.valueAsInt(businessModeItem) ?? _productBusinessMode(p);


  final String brandFromBreakdown = (brandItem?['value'] ?? '').toString().trim();
  final String brandValue = brandFromBreakdown.isNotEmpty &&
      brandFromBreakdown.toLowerCase() != 'null'
      ? brandFromBreakdown
      : _productBrandValue(p);
  final bool hasBrand =
      brandValue.isNotEmpty && brandValue.toLowerCase() != 'null';
  final bool qualitynormal = conditionVal == 3;
  final bool qualityOk = conditionVal == 4;
  final bool qualityExcellent = conditionVal == 5;
  final bool qualityNew = conditionVal == 6;
  final bool usageLessThan6 = itemTypeVal == 3;
  final bool usageLessThan3 = itemTypeVal == 2;
  final bool importedOk = businessModeVal == 2 || _productIsImported(p);
  final interestItem = reader.find(const ['interest_match']);

  final int interestPoints = reader.pointsAsInt(interestItem);

  final String matchType =
  (interestItem?['match_type'] ?? '').toString().trim().toLowerCase();

  final String ownerRelationLabel =
  (interestItem?['owner_relation_label'] ?? '').toString().trim();

  final bool fromInterest =
      interestItem != null &&
          (interestPoints > 0 || (matchType.isNotEmpty && matchType != 'none'));

  String interestLabel = '';
  bool isFamilyInterest = false;

  if (fromInterest) {
    if (matchType == 'self') {
      interestLabel = 'مفضل لك';
    } else if (matchType == 'family') {
      final String who = ownerRelationLabel.isNotEmpty
          ? ownerRelationLabel
          : 'أحد أفراد الأسرة';
      interestLabel = 'تصنيف مفضل لـ $who';
      isFamilyInterest = true;
    } else {
      interestLabel = 'من الاهتمامات';
    }
  }

  // ✅ العامل الجديد: منتجك من ضمن التصنيفات المفضلة لصاحب المنتج المرشح (أو عائلته المباشرة)
  final reverseInterestItem = reader.find(const ['reverse_interest_match']);

  final int reverseInterestPoints = reader.pointsAsInt(reverseInterestItem);

  final String reverseMatchType =
  (reverseInterestItem?['match_type'] ?? '').toString().trim().toLowerCase();

  final String reverseOwnerRelationLabel =
  (reverseInterestItem?['owner_relation_label'] ?? '').toString().trim();

  final bool fromReverseInterest =
      reverseInterestItem != null &&
          (reverseInterestPoints > 0 ||
              (reverseMatchType.isNotEmpty && reverseMatchType != 'none'));

  String reverseInterestLabel = '';
  bool isReverseFamilyInterest = false;

  if (fromReverseInterest) {
    if (reverseMatchType == 'self') {
      reverseInterestLabel = 'تصنيف منتجك يهم صاحب هذا المنتج';
    } else if (reverseMatchType == 'family') {
      final String who = reverseOwnerRelationLabel.isNotEmpty
          ? reverseOwnerRelationLabel
          : 'أحد أفراد أسرته';
      reverseInterestLabel = 'تصنيف منتجك يهم $who لصاحب المنتج';
      isReverseFamilyInterest = true;
    } else {
      reverseInterestLabel = 'منتجك يهم الطرف الآخر';
    }
  }

  final relationItem = reader.find(['relation']);

  final dynamic relationTypeRaw = relationItem?['relation_type'];

  final int? relationValFromBreakdown =
  relationTypeRaw is int
      ? relationTypeRaw
      : int.tryParse('${relationTypeRaw ?? ''}') ??
      reader.valueAsInt(relationItem);

  final int? relationVal = relationTypeOverride ?? relationValFromBreakdown;

  final int relationPoints = reader.pointsAsInt(relationItem);

  final bool relationOk =
      relationVal != null &&
          relationVal > 0 &&
          relationVal != 777 &&
          (relationTypeOverride != null || relationPoints > 0);

  final String relationLabel = relationOk
      ? _relationReasonLabel(
    product: p,
    relationVal: relationVal!,
    relationItem: relationItem,
    ownerNameOverride: relationOwnerNameOverride,
  )
      : '';



  final String locationMatchLabel = _resolveLocationMatchLabel(
    myProduct: myProduct,
    suggestedProduct: p,
  );
  final bool hasLocationState  = locationMatchLabel.isNotEmpty;
  final bool locationWarning = locationMatchLabel == 'محافظة مختلفة';
  return <SwapCriterionItem>[
    // ✅ من اهتماماتي / من اهتمامات عائلتي: أيقونة شخص/عائلة + قلب
    SwapCriterionItem(
      icon: isFamilyInterest
          ? Icons.family_restroom_rounded
          : Icons.person_rounded,
      overlayIcon: Icons.favorite_rounded,
      label: interestLabel,
      enabled: fromInterest && interestLabel.isNotEmpty,
      isFamilyInterest: isFamilyInterest,
      iconColor: isFamilyInterest
          ? kFamilyRecommendationAccent
          : const Color(0xFF0C587A),
      textColor: isFamilyInterest
          ? kFamilyRecommendationAccentDark
          : const Color(0xFF123B52),
      backgroundColor: isFamilyInterest
          ? kFamilyRecommendationBg
          : const Color(0xFFEAF8FC),
      borderColor: isFamilyInterest
          ? kFamilyRecommendationBorder
          : const Color(0xFFBFEAF0),
      shadowColor: isFamilyInterest
          ? kFamilyRecommendationShadow
          : const Color(0x120C587A),
    ),

    SwapCriterionItem(
      icon: Icons.new_releases_rounded,
      label: 'حالة جديد',
      enabled: qualityNew,
      isGold: qualityOk,
    ),
    SwapCriterionItem(
      icon: Icons.verified_user_rounded,
      label: 'حالة جيدة جدًا',
      enabled: qualityOk,
      isGold: qualityOk,
    ),
    SwapCriterionItem(
      icon: Icons.auto_awesome_rounded,
      label: 'حالة كسر زيرو',
      enabled: qualityExcellent,
      isGold: qualityExcellent,
    ),

    SwapCriterionItem(
      icon: Icons.update_rounded,
      label: 'استخدام أقل من 6 شهور',
      enabled: usageLessThan6,
      isGold: usageLessThan6,
    ),
    SwapCriterionItem(
      icon: Icons.hourglass_top_rounded,
      label: 'استخدام أقل من 3 شهور',
      enabled: usageLessThan3,
      isGold: usageLessThan3,
    ),
    SwapCriterionItem(
      icon: Icons.sell_rounded,
      label: 'براند: $brandValue',
      enabled: hasBrand,
      isGold: hasBrand,
    ),
    _locationCriterion(
      label: locationMatchLabel,
      enabled: hasLocationState,
      isWarning: locationWarning,
    ),

    SwapCriterionItem(
      icon: Icons.storefront_rounded,
      label: 'مستورد',
      enabled: importedOk,
      isGold: importedOk,
    ),

    // ✅ العلاقة: صديق = مصافحة، قريب/عائلة = عائلة، عام = أشخاص
    SwapCriterionItem(
      icon: Icons.verified_user_rounded,
      label: 'حالة جيدة',
      enabled: qualitynormal,
      isGold: false,
    ),
    SwapCriterionItem(
      icon: _relationIconForLabel(relationLabel),
      label: relationLabel,
      enabled: relationOk,
      iconColor: const Color(0xFF00897B),
      textColor: const Color(0xFF00695C),
      backgroundColor: const Color(0xFFE6F7F4),
      borderColor: const Color(0xFF8EDBD1),
      shadowColor: const Color(0x1800897B),
    ),
    // ✅ منتجك مناسب للطرف الآخر / لعائلة الطرف الآخر
    SwapCriterionItem(
      icon: isReverseFamilyInterest
          ? Icons.family_restroom_rounded
          : Icons.person_rounded,
      overlayIcon: Icons.favorite_rounded,
      label: reverseInterestLabel,
      enabled: fromReverseInterest && reverseInterestLabel.isNotEmpty,
      isFamilyInterest: isReverseFamilyInterest,
      iconColor: isReverseFamilyInterest
          ? kFamilyRecommendationAccent
          : const Color(0xFF0E9F6E),
      textColor: isReverseFamilyInterest
          ? kFamilyRecommendationAccentDark
          : const Color(0xFF047857),
      backgroundColor: isReverseFamilyInterest
          ? kFamilyRecommendationBg
          : const Color(0xFFE8F8F1),
      borderColor: isReverseFamilyInterest
          ? kFamilyRecommendationBorder
          : const Color(0xFF9CE4C6),
      shadowColor: isReverseFamilyInterest
          ? kFamilyRecommendationShadow
          : const Color(0x180E9F6E),
    ),

  ];
}

List<SwapCriterionItem> buildSuggestedSwapFallbackCriteria(InlineSwapVM vm) {
  return <SwapCriterionItem>[
    SwapCriterionItem(
      icon: Icons.auto_awesome_rounded,
      label: vm.percent >= 80
          ? 'تطابق ممتاز'
          : vm.percent >= 60
          ? 'تطابق قوي'
          : 'فرصة مناسبة',
      enabled: true,
    ),
  ];
}

double _estimateSingleSuggestedSwapCardHeight({
  required BuildContext context,
  required Product product,
  required InlineSwapVM vm,
  required bool smallLayout,
  required bool compact,
  Product? myProduct,
}) {
  // التقييم أصبح أعلى منتجك داخل صف المقارنة، والمنتج المرشح أصبح أكبر.
  final double verticalPadding = compact ? 20 : 24;
  final double topBarHeight = 0;
  final double gapAfterTopBar = 0;
  final double compareRowHeight = compact ? 238 : 254;
  final double gapBeforeChips = 6;
  final double chipsBlockHeight = compact ? 62 : 68; // صف المميزات فقط بعد نقل العنوان تحت منتج المستخدم
  final double bottomBuffer = compact ? 10 : 12;     // safety margin يمنع أي overflow

  return verticalPadding +
      topBarHeight +
      gapAfterTopBar +
      compareRowHeight +
      gapBeforeChips +
      chipsBlockHeight +
      bottomBuffer +
      8; // ✅ global safety buffer يمنع أي overflow

}

double estimateSuggestedSwapPageHeight({
  required BuildContext context,
  required List<Product> recProducts,
  required InlineSwapVM Function(Product p) vmBuilder,
  required bool smallLayout,
  required bool compact,
  Product? currentProduct,
  InlineSwapVM? currentVm,
  Product? myProduct,
}) {
  if (recProducts.isEmpty) {
    return compact ? 320 : 336;
  }

  if (currentProduct != null) {
    final vm = currentVm ?? vmBuilder(currentProduct);
    return _estimateSingleSuggestedSwapCardHeight(
      context: context,
      product: currentProduct,
      vm: vm,
      smallLayout: smallLayout,
      compact: compact,
      myProduct: myProduct,
    );
  }

  double maxHeight = 0;
  for (final p in recProducts) {
    final vm = vmBuilder(p);
    final h = _estimateSingleSuggestedSwapCardHeight(
      context: context,
      product: p,
      vm: vm,
      smallLayout: smallLayout,
      compact: compact,
      myProduct: myProduct,
    );
    if (h > maxHeight) maxHeight = h;
  }

  return maxHeight;
}

class SuggestedSwapReasonsGrid extends StatefulWidget {
  const SuggestedSwapReasonsGrid({
    Key? key,
    required this.items,
    required this.compact,
    this.vm,
    this.expanded,
    this.onToggleExpanded,
  }) : super(key: key);

  final List<SwapCriterionItem> items;
  final bool compact;
  final InlineSwapVM? vm;
  final bool? expanded;
  final VoidCallback? onToggleExpanded;

  @override
  State<SuggestedSwapReasonsGrid> createState() => _SuggestedSwapReasonsGridState();
}

class _SuggestedSwapReasonsGridState extends State<SuggestedSwapReasonsGrid> {
  bool _expanded = false;

  void _toggleExpanded() {
    if (widget.onToggleExpanded != null) {
      widget.onToggleExpanded!();
      return;
    }

    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final bool compact = widget.compact;
    final bool expanded = widget.expanded ?? _expanded;
    final bool showInlineToggle = widget.onToggleExpanded == null;

    // ✅ المعايير المتحققة فقط (enabled = true) ولها label فعلي، بترتيب الأولوية الأصلي.
    final List<SwapCriterionItem> activeItems = widget.items
        .where((it) => it.enabled && it.label.trim().isNotEmpty)
        .toList();

    final List<SwapCriterionItem> displayItems =
    activeItems.isNotEmpty ? activeItems : widget.items;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: _toggleExpanded,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.fromLTRB(
                  compact ? 5 : 6,
                  compact ? 6 : 7,
                  compact ? 5 : 6,
                  compact ? 6 : 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FDFF),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFD8EFF5),
                    width: 1,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x0F0C587A),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: expanded
                      ? _ExpandedCriteriaWrap(
                    items: displayItems,
                    compact: compact,
                    onToggle: _toggleExpanded,
                    showInlineToggle: showInlineToggle,
                  )
                      : _CollapsedCriteriaFeaturesPreview(
                    items: displayItems,
                    compact: compact,
                    expanded: expanded,
                    onToggle: _toggleExpanded,
                    showInlineToggle: showInlineToggle,
                    vm: widget.vm,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// ✅ عرض المميزات عند الفتح بشكل شبكي منتظم: كروت متساوية ومتناسقة.
class _ExpandedCriteriaWrap extends StatelessWidget {
  const _ExpandedCriteriaWrap({
    required this.items,
    required this.compact,
    required this.onToggle,
    required this.showInlineToggle,
  });

  final List<SwapCriterionItem> items;
  final bool compact;
  final VoidCallback onToggle;
  final bool showInlineToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final double spacing = compact ? 7 : 8;
    final double cardHeight = compact ? 50 : 54;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final bool oneColumn = maxWidth < 292;
        final double itemWidth = oneColumn
            ? maxWidth
            : ((maxWidth - spacing) / 2).floorToDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showInlineToggle) ...<Widget>[
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _FeatureExpandToggleTile(
                  compact: compact,
                  expanded: true,
                  onTap: onToggle,
                  size: compact ? 30 : 32,
                  showLabel: false,
                ),
              ),
              SizedBox(height: compact ? 6 : 7),
            ],
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: <Widget>[
                for (final SwapCriterionItem item in items)
                  SizedBox(
                    width: itemWidth,
                    height: cardHeight,
                    child: _ExpandedCriterionFeatureCard(
                      item: item,
                      compact: compact,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ExpandedCriterionFeatureCard extends StatelessWidget {
  const _ExpandedCriterionFeatureCard({
    required this.item,
    required this.compact,
  });

  final SwapCriterionItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final _CriterionVisual visual = _visualForCriterion(item);
    final double iconBoxSize = compact ? 26 : 28;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        compact ? 8 : 9,
        compact ? 7 : 8,
        compact ? 8 : 9,
        compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: visual.border,
          width: (item.isGold || item.isFamilyInterest) ? 1.2 : 1.0,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: visual.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _CriterionIconChip(
            item: item,
            size: iconBoxSize,
            iconSize: compact ? 16 : 17,
          ),
          SizedBox(width: compact ? 6 : 7),
          Expanded(
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: visual.text,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 10.0 : 10.7,
                height: 1.16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ عرض مختصر للمميزات وهو مقفول: نسبة الترشيح أولًا، ثم المميزات، ثم زر التفاصيل في النهاية.
class _CollapsedCriteriaFeaturesPreview extends StatelessWidget {
  const _CollapsedCriteriaFeaturesPreview({
    required this.items,
    required this.compact,
    required this.expanded,
    required this.onToggle,
    required this.showInlineToggle,
    this.vm,
  });

  final List<SwapCriterionItem> items;
  final bool compact;
  final bool expanded;
  final VoidCallback onToggle;
  final bool showInlineToggle;
  final InlineSwapVM? vm;

  @override
  Widget build(BuildContext context) {
    final double tileWidth = compact ? 51 : 55;
    final double percentTileWidth = compact ? 68 : 74;
    final double detailsTileWidth = compact ? 58 : 62;
    final double tileHeight = compact ? 52 : 56;
    final double gap = compact ? 4 : 5;

    // ✅ العرض المختصر يخفي معيار "منتجك مفضل له" فقط.
    // المعيار يظل ظاهرًا عند فتح التفاصيل لأنه ما زال موجودًا داخل items الأصلية.
    final List<SwapCriterionItem> collapsedItems = items
        .where(
          (SwapCriterionItem item) =>
      !_shouldShowCriterionOnlyInDetails(item),
    )
        .toList(growable: false);

    final List<Widget> children = <Widget>[
      if (vm != null) ...<Widget>[
        _RecommendationPercentFeatureTile(
          vm: vm!,
          width: percentTileWidth,
          height: tileHeight,
          compact: compact,
        ),
        if (collapsedItems.isNotEmpty || showInlineToggle) SizedBox(width: gap),
      ],
      for (int i = 0; i < collapsedItems.length; i++) ...<Widget>[
        if (i > 0) SizedBox(width: gap),
        _CollapsedCriterionFeatureTile(
          item: collapsedItems[i],
          width: tileWidth,
          height: tileHeight,
          compact: compact,
        ),
      ],
      if (showInlineToggle) ...<Widget>[
        if (collapsedItems.isNotEmpty) SizedBox(width: gap),
        _FeatureExpandToggleTile(
          compact: compact,
          expanded: expanded,
          onTap: onToggle,
          width: detailsTileWidth,
          height: tileHeight,
        ),
      ],

    ];

    return SizedBox(
      height: tileHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsetsDirectional.only(
          start: compact ? 1 : 2,
          end: compact ? 1 : 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _RecommendationPercentFeatureTile extends StatelessWidget {
  const _RecommendationPercentFeatureTile({
    required this.vm,
    required this.width,
    required this.height,
    required this.compact,
  });

  final InlineSwapVM vm;
  final double width;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final SwapBadgeStyle style = swapBadgeStyleForBadge(vm.badge);
    final int percent = vm.percent.clamp(0, 100).toInt();

    return Tooltip(
      message: 'نسبة الترشيح $percent% - ${_recommendationPercentFeatureTitle(vm)}',
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              height: compact ? 23 : 24,
              constraints: BoxConstraints(
                minWidth: compact ? 42 : 46,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 7 : 8,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: style.innerGradient,
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: style.border,
                  width: 1.15,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: style.glow,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$percent%',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: style.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 10.2 : 11.2,
                    height: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 3 : 5),
            Expanded(
              child: Text(
                _recommendationPercentFeatureTitle(vm),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: style.textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 7.6 : 8.2,
                  height: 1.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _recommendationPercentFeatureTitle(InlineSwapVM vm) {
  switch (vm.badge.tone) {
    case SwapBadgeTone.golden:
      return 'فرصة ذهبية';
    case SwapBadgeTone.excellent:
      return 'فرصة ممتازة';
    case SwapBadgeTone.suitable:
    case SwapBadgeTone.neutral:
      return 'تبديل مناسب';
  }
}

bool _shouldShowCriterionOnlyInDetails(SwapCriterionItem item) {
  final String label = item.label.trim();
  if (label.isEmpty) return false;

  // ✅ معيار reverse_interest_match يظهر في التفاصيل فقط، وليس في السطر المختصر.
  return _textContainsAny(label, const <String>[
    'تصنيف منتجك يهم',
    'منتجك يهم الطرف الآخر',
    'منتجك يهم صاحب',
    'يهم صاحب هذا المنتج',
    'لصاحب المنتج',
  ]);
}

class _CollapsedCriterionFeatureTile extends StatelessWidget {
  const _CollapsedCriterionFeatureTile({
    required this.item,
    required this.width,
    required this.height,
    required this.compact,
  });

  final SwapCriterionItem item;
  final double width;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double iconBoxSize = compact ? 23 : 24;

    return Tooltip(
      message: item.label,
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _CriterionIconChip(
              item: item,
              size: iconBoxSize,
              iconSize: compact ? 15 : 16,
            ),
            SizedBox(height: compact ? 3 : 4),
            Expanded(
              child: Text(
                _shortCriterionLabel(item),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _visualForCriterion(item).text,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 8.0 : 9,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _FeatureExpandToggleTile extends StatelessWidget {
  const _FeatureExpandToggleTile({
    required this.compact,
    required this.expanded,
    required this.onTap,
    this.width,
    this.height,
    this.size,
    this.showLabel = true,
  });

  final bool compact;
  final bool expanded;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double? size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final double resolvedWidth = width ?? (size ?? (compact ? 30 : 32));
    final double resolvedHeight = height ?? (size ?? (compact ? 30 : 32));
    final double circleSize = size ?? (compact ? 23 : 24);

    return Tooltip(
      message: expanded ? 'إخفاء التفاصيل' : 'تفاصيل المميزات',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: SizedBox(
            width: resolvedWidth,
            height: resolvedHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: circleSize,
                  height: circleSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: expanded
                        ? const Color(0xFF0C587A)
                        : const Color(0xFFEAF8FC),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: expanded
                          ? const Color(0xFF0C587A)
                          : const Color(0xFFBFEAF0),
                      width: 1.15,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x120D8EAD),
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: expanded ? Colors.white : const Color(0xFF0C587A),
                      size: compact ? 18 : 20,
                    ),
                  ),
                ),
                if (showLabel) ...<Widget>[
                  SizedBox(height: compact ? 3 : 4),
                  Expanded(
                    child: Text(
                      expanded ? 'إخفاء' : 'تفاصيل',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF0C587A),
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 8.0 : 8.6,
                        height: 1.08,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _shortCriterionLabel(SwapCriterionItem item) {
  final String label = item.label.trim();
  if (label.isEmpty) return '';

  if (_textContainsAny(label, const <String>['نفس المحافظة والحي', 'نفس المنطقة', 'الحي'])) {
    return 'نفس الحي';
  }

  if (_textContainsAny(label, const <String>['نفس المحافظة'])) {
    return 'نفس المحافظة';
  }

  if (_textContainsAny(label, const <String>['محافظة مختلفة'])) {
    return 'محافظة مختلفة';
  }

  if (_textContainsAny(label, const <String>['حالة كسر زيرو'])) {
    return 'كسر زيرو';
  }

  if (_textContainsAny(label, const <String>['حالة جيدة جدًا'])) {
    return 'حالة\nجيدة جدًا';
  }
  if (_textContainsAny(label, const <String>['جيدة'])) {
    return 'حالة جيدة';
  }

  if (_textContainsAny(label, const <String>['حالة جديد'])) {
    return 'جديد';
  }

  if (_textContainsAny(label, const <String>['استخدام أقل'])) {
    return 'استخدام قليل';
  }

  if (_textContainsAny(label, const <String>['براند:'])) {
    return 'براند';
  }

  if (_textContainsAny(label, const <String>['مستورد'])) {
    return 'مستورد';
  }

  if (_textContainsAny(label, const <String>['صديق'])) {
    return 'من صديق';
  }

  if (_textContainsAny(label, const <String>['قريب', 'أقارب', 'اقارب'])) {
    return 'من قريب';
  }

  if (_textContainsAny(label, const <String>['عائلة', 'العائلة', 'الأسرة', 'أسرته'])) {
    return 'للعائلة';
  }

  if (_textContainsAny(label, const <String>['تصنيف مفضل'])) {
    return item.isFamilyInterest ? 'مفضل لعائلتك' : 'تصنيف مفضل';
  }

  if (_textContainsAny(label, const <String>['الاهتمامات', 'اهتمامات'])) {
    return 'اهتمامات';
  }

  if (_textContainsAny(label, const <String>['يهم صاحب', 'يهم الطرف', 'يهم'])) {
    return 'منتجك مفضل له';
  }

  final List<String> words = label
      .replaceAll('(', ' ')
      .replaceAll(')', ' ')
      .replaceAll(':', ' ')
      .split(RegExp(r'\s+'))
      .where((String word) => word.trim().isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) return label;
  return words.take(2).join(' ');
}

/// دائرة صغيرة بأيقونة معيار واحد، بألوان متسقة مع [SuggestedSwapReasonPill].
class _CriterionIconChip extends StatelessWidget {
  const _CriterionIconChip({
    required this.item,
    required this.size,
    required this.iconSize,
  });

  final SwapCriterionItem item;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final _CriterionVisual visual = _visualForCriterion(item);

    return Tooltip(
      message: item.label,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: visual.background,
          shape: BoxShape.circle,
          border: Border.all(color: visual.border, width: 1.15),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: visual.shadow,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _CriterionStackedIcon(
          icon: item.icon,
          overlayIcon: item.overlayIcon,
          color: visual.icon,
          size: iconSize,
        ),
      ),
    );
  }
}

class _CriterionVisual {
  const _CriterionVisual({
    required this.background,
    required this.border,
    required this.icon,
    required this.text,
    required this.shadow,
  });

  final Color background;
  final Color border;
  final Color icon;
  final Color text;
  final Color shadow;
}

_CriterionVisual _visualForCriterion(SwapCriterionItem item) {
  final bool isWarning = item.isWarning;
  final bool isFamilyInterest = item.isFamilyInterest && !isWarning;
  final bool isGold = item.isGold && !isWarning && !isFamilyInterest;

  const Color goldBorder = Color(0xFFD8A33B);
  const Color goldIcon = Color(0xFFB97B12);
  const Color goldBg = Color(0xFFFFFBF0);
  const Color goldText = Color(0xFF6E4A00);

  final Color background = item.backgroundColor ??
      (isWarning
          ? const Color(0xFFFFF1F1)
          : isFamilyInterest
          ? kFamilyRecommendationBg
          : isGold
          ? goldBg
          : const Color(0xFFEAF8FB));

  final Color border = item.borderColor ??
      (isWarning
          ? const Color(0xFFF2C7C7)
          : isFamilyInterest
          ? kFamilyRecommendationBorder
          : isGold
          ? goldBorder
          : const Color(0xFFBFEAF0));

  final Color icon = item.iconColor ??
      (isWarning
          ? const Color(0xFFD65A5A)
          : isFamilyInterest
          ? kFamilyRecommendationAccent
          : isGold
          ? goldIcon
          : const Color(0xFF149EB7));

  final Color text = item.textColor ??
      (isWarning
          ? const Color(0xFF9E3A3A)
          : isFamilyInterest
          ? kFamilyRecommendationAccentDark
          : isGold
          ? goldText
          : const Color(0xFF17425E));

  final Color shadow = item.shadowColor ??
      (isWarning
          ? const Color(0x14D65A5A)
          : isFamilyInterest
          ? kFamilyRecommendationShadow
          : isGold
          ? const Color(0x33D8A33B)
          : const Color(0x120D8EAD));

  return _CriterionVisual(
    background: background,
    border: border,
    icon: icon,
    text: text,
    shadow: shadow,
  );
}

class _CriterionStackedIcon extends StatelessWidget {
  const _CriterionStackedIcon({
    required this.icon,
    required this.overlayIcon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final IconData? overlayIcon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (overlayIcon == null) {
      return Icon(icon, size: size, color: color);
    }

    return SizedBox(
      width: size + 4,
      height: size + 4,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Icon(icon, size: size + 1, color: color),
          PositionedDirectional(
            end: -1,
            bottom: -1,
            child: Container(
              width: size * 0.72,
              height: size * 0.72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Icon(
                overlayIcon,
                size: size * 0.46,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestedSwapReasonPill extends StatelessWidget {
  const SuggestedSwapReasonPill({
    Key? key,
    required this.item,
    required this.compact,
    this.allowHorizontalScroll = false,
    this.showFullText = false,
  }) : super(key: key);

  final SwapCriterionItem item;
  final bool compact;
  final bool allowHorizontalScroll;
  final bool showFullText;

  @override
  Widget build(BuildContext context) {
    final bool isGold = item.isGold && !item.isWarning && !item.isFamilyInterest;
    final _CriterionVisual visual = _visualForCriterion(item);

    const Color goldBgStart = Color(0xFFFFFFFF);
    const Color goldBgEnd = Color(0xFFFFFFFF);

    final Widget labelWidget = Text(
      item.label,
      maxLines: showFullText ? null : 1,
      overflow: showFullText ? TextOverflow.visible : TextOverflow.ellipsis,
      softWrap: showFullText,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: visual.text,
        fontWeight: FontWeight.w800,
        fontSize: compact ? 10.4 : 11,
        height: showFullText ? 1.25 : 1.4,
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        gradient: isGold
            ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[goldBgStart, goldBgEnd],
        )
            : null,
        color: isGold ? null : visual.background,
        borderRadius: BorderRadius.circular(showFullText ? 16 : 999),
        border: Border.all(
          color: visual.border,
          width: (isGold || item.isFamilyInterest) ? 1.2 : 1.0,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: visual.shadow,
            blurRadius: (isGold || item.isFamilyInterest) ? 10 : 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment:
        showFullText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: showFullText ? 1 : 0),
            child: _CriterionStackedIcon(
              icon: item.icon,
              overlayIcon: item.overlayIcon,
              color: visual.icon,
              size: compact ? 16 : 17,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: allowHorizontalScroll && !showFullText
                ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const BouncingScrollPhysics(),
              child: Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: visual.text,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 10.4 : 11,
                  height: 1.4,
                ),
              ),
            )
                : labelWidget,
          ),
        ],
      ),
    );
  }
}
