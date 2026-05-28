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

class SwapCriterionItem {
  const SwapCriterionItem({
    required this.icon,
    required this.label,
    required this.enabled,
    this.isWarning = false,
    this.isGold = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final bool isWarning;
  final bool isGold;
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
    title: 'تبديل بنفس متوسط السعر',
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
    'userName',
    'owner_name',
    'ownerName',
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
    return '$ownerName ($relation)';
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

  if (fromInterest) {
    if (matchType == 'self') {
      interestLabel = 'من الفئات المفضلة لك';
    } else if (matchType == 'family') {
      final String who = ownerRelationLabel.isNotEmpty
          ? ownerRelationLabel
          : 'أحد أفراد الأسرة';
      interestLabel = 'من الفئات المفضلة ل $who';
    } else {
      interestLabel = 'من الاهتمامات';
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
    // ✅ العلاقة أولاً
    SwapCriterionItem(
      icon: Icons.groups_rounded,
      label: relationLabel,
      enabled: relationOk,
    ),
    SwapCriterionItem(
      icon: Icons.verified_rounded,
      label: 'حالة جيدة جدًا',
      enabled: qualityOk,
      isGold: qualityOk,
    ),
    SwapCriterionItem(
      icon: Icons.verified_rounded,
      label: 'حالة كسر زيرو',
      enabled: qualityExcellent,
      isGold: qualityExcellent,
    ),
    SwapCriterionItem(
      icon: Icons.verified_rounded,
      label: 'حالة جديد',
      enabled: qualityNew,
      isGold: qualityNew,
    ),
    SwapCriterionItem(
      icon: Icons.schedule_rounded,
      label: 'استخدام أقل من 6 شهور',
      enabled: usageLessThan6,
      isGold: usageLessThan6,
    ),
    SwapCriterionItem(
      icon: Icons.schedule_rounded,
      label: 'استخدام أقل من 3 شهور',
      enabled: usageLessThan3,
      isGold: usageLessThan3,
    ),
    SwapCriterionItem(
      icon: Icons.local_offer_rounded,
      label: 'براند: $brandValue',
      enabled: hasBrand,
      isGold: hasBrand,
    ),
    SwapCriterionItem(
      icon: Icons.storefront_rounded,
      label: 'مستورد',
      enabled: importedOk,
      isGold: importedOk,
    ),
    SwapCriterionItem(
      icon: Icons.favorite_rounded,
      label: interestLabel,
      enabled: fromInterest && interestLabel.isNotEmpty,
    ),
    SwapCriterionItem(
      icon: Icons.place_rounded,
      label: locationMatchLabel,
      enabled: hasLocationState,
      isWarning: locationWarning,
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
  // ✅ الـ chips دلوقتي سطر واحد أفقي بارتفاع ثابت
  final double verticalPadding = compact ? 20 : 24;
  final double topBarHeight = 44;
  final double gapAfterTopBar = 10;
  final double compareRowHeight = compact ? 166 : 178;
  final double gapBeforeChips = 10;
  final double chipsBlockHeight = compact ? 62 : 68; // +3/4px safety margin
  final double bottomBuffer = compact ? 10 : 12;    // +4px to avoid overflow

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

class SuggestedSwapReasonsGrid extends StatelessWidget {
  const SuggestedSwapReasonsGrid({
    Key? key,
    required this.items,
    required this.compact,
  }) : super(key: key);

  final List<SwapCriterionItem> items;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 3,
            end: 3,
            bottom: 6,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: compact ? 20 : 22,
                height: compact ? 20 : 22,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8FB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFBFEAF0),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: compact ? 13 : 14,
                  color: const Color(0xFF149EB7),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'مميزات ترشيح التبديل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF17425E),
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 10.8 : 11.5,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ✅ سطر واحد أفقي قابل للسحب — المستخدم يعمل scroll عشان يشوف الباقي
        SizedBox(
          height: compact ? 33 : 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) => SuggestedSwapReasonPill(
              item: items[index],
              compact: compact,
            ),
          ),
        ),
      ],
    );
  }
}

class SuggestedSwapReasonPill extends StatelessWidget {
  const SuggestedSwapReasonPill({
    Key? key,
    required this.item,
    required this.compact,
  }) : super(key: key);

  final SwapCriterionItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool isWarning = item.isWarning;
    final bool isGold = item.isGold && !isWarning;

    const Color goldBgStart = Color(0xFFFFFFFF);
    const Color goldBgEnd = Color(0xFFFFFFFF);
    const Color goldBorder = Color(0xFFD8A33B);
    const Color goldText = Color(0xFF6E4A00);
    const Color goldIcon = Color(0xFFB97B12);

    final Color border = isWarning
        ? const Color(0xFFF2C7C7)
        : isGold
        ? goldBorder
        : const Color(0xFFBFEAF0);

    final Color text = isWarning
        ? const Color(0xFF9E3A3A)
        : isGold
        ? goldText
        : const Color(0xFF17425E);

    final Color icon = isWarning
        ? const Color(0xFFD65A5A)
        : isGold
        ? goldIcon
        : const Color(0xFF149EB7);

    final Color shadow = isWarning
        ? const Color(0x14D65A5A)
        : isGold
        ? const Color(0x33D8A33B)
        : const Color(0x120D8EAD);

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
        color: isGold
            ? null
            : isWarning
            ? const Color(0xFFFFF1F1)
            : const Color(0xFFEAF8FB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: border,
          width: isGold ? 1.2 : 1.0,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadow,
            blurRadius: isGold ? 10 : 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: compact ? 14 : 15, color: icon),
          const SizedBox(width: 6),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: text,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 10.4 : 11,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}