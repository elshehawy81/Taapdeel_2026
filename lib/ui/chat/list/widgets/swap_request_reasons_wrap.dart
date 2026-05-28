import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/product.dart';

class SwapRequestReasonsWrap extends StatelessWidget {
  const SwapRequestReasonsWrap({
    Key? key,
    required this.myProduct,
    required this.otherProduct,
    this.maxItems = 0,
  }) : super(key: key);

  final Product? myProduct;
  final Product? otherProduct;

  /// 0 means show all reasons.
  /// Keep this parameter for backward compatibility with old callers.
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final List<_ReasonChipData> allReasons = _buildReasons();
    final List<_ReasonChipData> reasons =
    maxItems > 0 ? allReasons.take(maxItems).toList() : allReasons;

    if (reasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 1,
            end: 1,
            bottom: 6,
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              const Icon(
                Icons.auto_awesome_rounded,
                size: 13,
                color: Color(0xFF0C587A),
              ),
              const SizedBox(width: 4),
              Text(
                'مميزات ترشيح التبديل',
                textDirection: TextDirection.rtl,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF0C587A),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 29,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Row(
                textDirection: TextDirection.rtl,
                children: reasons.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final _ReasonChipData data = entry.value;

                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: index == 0 ? 0 : 6,
                    ),
                    child: _ReasonChip(data: data),
                  );
                }).toList(growable: false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<_ReasonChipData> _buildReasons() {
    final Product? product = otherProduct;

    if (product == null) {
      return const <_ReasonChipData>[];
    }

    final List<_ReasonChipData> reasons = <_ReasonChipData>[];

    final String relationLabel = _resolveRelationLabel(product);
    if (_isValidLabel(relationLabel)) {
      reasons.add(
        _ReasonChipData(
          icon: Icons.groups_rounded,
          label: relationLabel,
        ),
      );
    }

    final String conditionLabel = _resolveConditionLabel(product);
    if (_isValidLabel(conditionLabel)) {
      reasons.add(
        _ReasonChipData(
          icon: Icons.verified_rounded,
          label: conditionLabel,
        ),
      );
    }

    final String usageLabel = _resolveUsageLabel(product);
    if (_isValidLabel(usageLabel)) {
      reasons.add(
        _ReasonChipData(
          icon: Icons.schedule_rounded,
          label: usageLabel,
        ),
      );
    }

    final String brandLabel = _resolveBrandLabel(product);
    if (_isValidLabel(brandLabel)) {
      reasons.add(
        _ReasonChipData(
          icon: Icons.local_offer_rounded,
          label: brandLabel,
        ),
      );
    }

    final String importedLabel = _resolveImportedLabel(product);
    if (_isValidLabel(importedLabel)) {
      reasons.add(
        _ReasonChipData(
          icon: Icons.storefront_rounded,
          label: importedLabel,
        ),
      );
    }

    final String interestLabel = _resolveInterestLabel(product);
    if (_isValidLabel(interestLabel)) {
      reasons.add(
        _ReasonChipData(
          icon: Icons.favorite_rounded,
          label: interestLabel,
        ),
      );
    }

    final String locationLabel = _resolveLocationLabel(
      myProduct: myProduct,
      otherProduct: product,
    );
    if (_isValidLabel(locationLabel)) {
      reasons.add(
        _ReasonChipData(
          icon: Icons.place_rounded,
          label: locationLabel,
          isWarning: locationLabel == 'محافظة مختلفة',
        ),
      );
    }

    if (reasons.isNotEmpty) {
      return reasons;
    }

    return const <_ReasonChipData>[
      _ReasonChipData(
        icon: Icons.auto_awesome_rounded,
        label: 'فرصة مناسبة للتبديل',
      ),
    ];
  }

  String _resolveConditionLabel(Product product) {
    final Map<String, dynamic>? conditionBreakdown =
    _findBreakdownItem(product, const <String>['condition']);

    final int? conditionFromBreakdown = _mapValueAsInt(conditionBreakdown);
    final int? conditionId = conditionFromBreakdown ?? _productConditionId(product);
    final String conditionName = _productConditionName(product);

    if (conditionId == 6) return 'حالة جديد';
    if (conditionId == 5) return 'حالة كسر زيرو';
    if (conditionId == 4) return 'حالة جيدة جدًا';

    if (conditionName.contains('جديد')) return 'حالة جديد';
    if (conditionName.contains('كسر')) return 'حالة كسر زيرو';
    if (conditionName.contains('جيد')) return 'حالة جيدة جدًا';

    return '';
  }

  String _resolveUsageLabel(Product product) {
    final Map<String, dynamic>? itemTypeBreakdown =
    _findBreakdownItem(product, const <String>['item_type']);

    final int? itemTypeFromBreakdown = _mapValueAsInt(itemTypeBreakdown);
    final int? itemTypeId = itemTypeFromBreakdown ?? _productItemTypeId(product);
    final String itemTypeName = _productItemTypeName(product);

    if (itemTypeId == 2) return 'استخدام أقل من 3 شهور';
    if (itemTypeId == 3) return 'استخدام أقل من 6 شهور';

    if (itemTypeName.contains('3') && itemTypeName.contains('6')) {
      return 'استخدام أقل من 6 شهور';
    }

    if (itemTypeName.contains('أقل') && itemTypeName.contains('3')) {
      return 'استخدام أقل من 3 شهور';
    }

    return '';
  }

  String _resolveBrandLabel(Product product) {
    final Map<String, dynamic>? brandBreakdown =
    _findBreakdownItem(product, const <String>['brand']);

    final String brandFromBreakdown =
    _cleanText(brandBreakdown == null ? '' : brandBreakdown['value']);

    final String brand =
    brandFromBreakdown.isNotEmpty ? brandFromBreakdown : _productBrand(product);

    if (brand.isEmpty) return '';

    return 'براند: $brand';
  }

  String _resolveImportedLabel(Product product) {
    final Map<String, dynamic>? businessModeBreakdown =
    _findBreakdownItem(product, const <String>['business_mode']);

    final int? businessModeFromBreakdown = _mapValueAsInt(businessModeBreakdown);
    final int? businessMode = businessModeFromBreakdown ?? _productBusinessMode(product);

    if (businessMode == 2 || _productIsImported(product)) {
      return 'مستورد';
    }

    return '';
  }

  String _resolveInterestLabel(Product product) {
    final Map<String, dynamic>? interestBreakdown =
    _findBreakdownItem(product, const <String>['interest_match']);

    final int interestPoints = _mapPointsAsInt(interestBreakdown);
    final String matchTypeFromBreakdown =
    _cleanText(interestBreakdown == null ? '' : interestBreakdown['match_type'])
        .toLowerCase();

    final String ownerRelationFromBreakdown =
    _cleanText(interestBreakdown == null
        ? ''
        : interestBreakdown['owner_relation_label']);

    if (interestBreakdown != null &&
        (interestPoints > 0 ||
            (matchTypeFromBreakdown.isNotEmpty &&
                matchTypeFromBreakdown != 'none'))) {
      if (matchTypeFromBreakdown == 'self') {
        return 'من اهتماماتك';
      }

      if (matchTypeFromBreakdown == 'family') {
        final String who = ownerRelationFromBreakdown.isNotEmpty
            ? ownerRelationFromBreakdown
            : 'العائلة';
        return 'من اهتمامات $who';
      }

      return 'من الاهتمامات';
    }

    final String directMatchType = _productInterestMatchType(product);
    final String directOwnerRelation = _productInterestOwnerRelationLabel(product);

    if (directMatchType == 'self') {
      return 'من اهتماماتك';
    }

    if (directMatchType == 'family') {
      if (directOwnerRelation.isNotEmpty) {
        return 'من اهتمامات $directOwnerRelation';
      }
      return 'من اهتمامات العائلة';
    }

    return '';
  }

  String _resolveRelationLabel(Product product) {
    final Map<String, dynamic>? relationBreakdown =
    _findBreakdownItem(product, const <String>['relation']);

    final dynamic relationTypeRaw = relationBreakdown == null
        ? null
        : relationBreakdown['relation_type'];

    final int? relationFromBreakdown =
        _parseInt(relationTypeRaw) ?? _mapValueAsInt(relationBreakdown);

    final int relationPoints = _mapPointsAsInt(relationBreakdown);

    if (relationFromBreakdown != null &&
        relationFromBreakdown > 0 &&
        relationFromBreakdown != 777 &&
        (relationBreakdown == null || relationPoints > 0)) {
      final String relationText = _relationLabelFromId(relationFromBreakdown);
      final String ownerName = _ownerNameFromBreakdownItem(relationBreakdown);
      if (relationText.isEmpty) return '';

      if (ownerName.isNotEmpty) {
        return '$ownerName ($relationText)';
      }

      return 'من $relationText';
    }

    final String relationCode = _productRelationCode(product);
    if (relationCode.isEmpty) return '';

    switch (relationCode) {
      case 'FRIEND':
        return 'من صديقك';
      case 'SPOUSE':
        return 'من الزوج/الزوجة';
      case 'CHILD':
        return 'من ابنك/ابنتك';
      case 'PARENTS':
        return 'من الأب/الأم';
      case 'SIBLING':
        return 'من الأخ/الأخت';
      case 'BIG_FAMILY':
        return 'من العائلة الكبيرة';
      case 'FRIEND_OF_FRIEND':
        return 'من صديق صديقك';
      case 'FRIENDS_FAMILY':
        return 'من عائلة صديقك';
      case 'FRIENDS_BIG_FAMILY':
        return 'من أقارب صديقك';
      case 'FRIEND_OF_FAMILY':
        return 'من صديق عائلتك';
      case 'FRIEND_OF_BIG_FAMILY':
        return 'من صديق قريبك';
      case 'FAMILY_OF_FAMILY':
      case 'FAMILY_OF_BIG_FAMILY':
        return 'من أقاربك';
      default:
        return '';
    }
  }

  String _resolveLocationLabel({
    required Product? myProduct,
    required Product? otherProduct,
  }) {
    final String myLocationId = _productLocationId(myProduct);
    final String otherLocationId = _productLocationId(otherProduct);

    if (myLocationId.isEmpty || otherLocationId.isEmpty) {
      return '';
    }

    if (myLocationId != otherLocationId) {
      return 'محافظة مختلفة';
    }

    final String myTownshipId = _productTownshipId(myProduct);
    final String otherTownshipId = _productTownshipId(otherProduct);

    if (myTownshipId.isNotEmpty &&
        otherTownshipId.isNotEmpty &&
        myTownshipId == otherTownshipId) {
      return 'نفس المحافظة والحي';
    }

    return 'نفس المحافظة';
  }

  Map<String, dynamic>? _findBreakdownItem(
      Product product,
      Iterable<String> keys,
      ) {
    final List<Map<String, dynamic>> breakdown =
    _castSwapBreakdown(_productSwapScoreBreakdown(product));

    for (final Map<String, dynamic> item in breakdown) {
      final String key = _cleanText(item['key']).toLowerCase();
      if (keys.contains(key)) {
        return item;
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _castSwapBreakdown(dynamic rawAny) {
    final dynamic raw = rawAny is List ? rawAny : const <dynamic>[];
    final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];

    for (final dynamic e in raw) {
      if (e is Map) {
        out.add(Map<String, dynamic>.from(e));
      }
    }

    return out;
  }

  dynamic _productSwapScoreBreakdown(Product product) {
    final dynamic p = product;

    return _safeRead(() => p.swapScoreBreakdown) ??
        _safeRead(() => p.swap_score_breakdown) ??
        _safeRead(() => p.swapBreakdown) ??
        _safeRead(() => p.swap_breakdown);
  }

  int? _productConditionId(Product product) {
    final dynamic p = product;

    return _parseInt(_safeRead(() => p.conditionOfItemId)) ??
        _parseInt(_safeRead(() => p.condition_of_item_id)) ??
        _parseInt(_safeRead(() => p.conditionOfItem?.id)) ??
        _parseInt(_safeRead(() => p.condition_of_item?.id));
  }

  String _productConditionName(Product product) {
    final dynamic p = product;

    return _firstText(<dynamic Function()>[
          () => p.conditionOfItem?.name,
          () => p.condition_of_item?.name,
          () => p.conditionName,
          () => p.condition_name,
    ]);
  }

  int? _productItemTypeId(Product product) {
    final dynamic p = product;

    return _parseInt(_safeRead(() => p.itemTypeId)) ??
        _parseInt(_safeRead(() => p.item_type_id)) ??
        _parseInt(_safeRead(() => p.itemType?.id)) ??
        _parseInt(_safeRead(() => p.item_type?.id));
  }

  String _productItemTypeName(Product product) {
    final dynamic p = product;

    return _firstText(<dynamic Function()>[
          () => p.itemType?.name,
          () => p.item_type?.name,
          () => p.itemTypeName,
          () => p.item_type_name,
    ]);
  }

  String _productBrand(Product product) {
    final dynamic p = product;

    return _firstText(<dynamic Function()>[
          () => p.brand,
          () => p.brandName,
          () => p.brand_name,
    ]);
  }

  int? _productBusinessMode(Product product) {
    final dynamic p = product;

    return _parseInt(_safeRead(() => p.businessMode)) ??
        _parseInt(_safeRead(() => p.business_mode));
  }

  bool _productIsImported(Product product) {
    final dynamic p = product;

    final dynamic isImported = _safeRead(() => p.isImported) ??
        _safeRead(() => p.is_imported);

    if (_parseBool(isImported)) return true;

    final dynamic highlightInfo =
        _safeRead(() => p.highlightInfo) ?? _safeRead(() => p.highlight_info);

    if (highlightInfo is Map) {
      return _parseBool(highlightInfo['is_imported']) ||
          _parseBool(highlightInfo['isImported']);
    }

    final String highlightText = _cleanText(highlightInfo).toLowerCase();
    return highlightText.contains('"is_imported":true') ||
        highlightText.contains('"isimported":true');
  }

  String _productInterestMatchType(Product product) {
    final dynamic p = product;

    return _firstText(<dynamic Function()>[
          () => p.interestMatchType,
          () => p.interest_match_type,
          () => p.matchType,
          () => p.match_type,
    ]).toLowerCase();
  }

  String _productInterestOwnerRelationLabel(Product product) {
    final dynamic p = product;

    return _firstText(<dynamic Function()>[
          () => p.interestOwnerRelationLabel,
          () => p.interest_owner_relation_label,
          () => p.ownerRelationLabel,
          () => p.owner_relation_label,
    ]);
  }

  String _productRelationCode(Product product) {
    final dynamic p = product;

    final String raw = _firstText(<dynamic Function()>[
          () => p.relationCode,
          () => p.relation_code,
          () => p.ownerRelationCode,
          () => p.owner_relation_code,
    ]);

    return raw.trim().toUpperCase();
  }

  String _productLocationId(Product? product) {
    if (product == null) return '';

    final dynamic p = product;

    return _firstText(<dynamic Function()>[
          () => p.itemLocationId,
          () => p.item_location_id,
          () => p.itemLocation?.id,
          () => p.item_location?.id,
    ]);
  }

  String _productTownshipId(Product? product) {
    if (product == null) return '';

    final dynamic p = product;

    return _firstText(<dynamic Function()>[
          () => p.itemLocationTownshipId,
          () => p.item_location_township_id,
          () => p.itemLocationTownship?.id,
          () => p.item_location_township?.id,
    ]);
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
      final String value = _cleanText(item[key]);
      if (value.isNotEmpty) return value;
    }

    return '';
  }

  String _relationLabelFromId(int id) {
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

  int? _mapValueAsInt(Map<String, dynamic>? item) {
    if (item == null) return null;
    return _parseInt(item['value']);
  }

  int _mapPointsAsInt(Map<String, dynamic>? item) {
    if (item == null) return 0;
    return _parseInt(item['points']) ?? 0;
  }

  dynamic _safeRead(dynamic Function() getter) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }

  String _firstText(List<dynamic Function()> readers) {
    for (final dynamic Function() reader in readers) {
      final String value = _cleanText(_safeRead(reader));
      if (value.isNotEmpty) return value;
    }

    return '';
  }

  String _cleanText(dynamic value) {
    final String text = (value ?? '').toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return '';
    }

    return text;
  }

  bool _isValidLabel(String value) {
    final String text = value.trim();
    return text.isNotEmpty && text.toLowerCase() != 'null';
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();

    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    final double? asDouble = double.tryParse(text);
    if (asDouble != null) return asDouble.round();

    return int.tryParse(text);
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;

    final String text = value.toString().trim().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }
}

class _ReasonChipData {
  const _ReasonChipData({
    required this.icon,
    required this.label,
    this.isWarning = false,
  });

  final IconData icon;
  final String label;
  final bool isWarning;
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    Key? key,
    required this.data,
  }) : super(key: key);

  final _ReasonChipData data;

  @override
  Widget build(BuildContext context) {
    final Color border =
    data.isWarning ? const Color(0xFFF3CCCC) : const Color(0xFFD8EEF3);
    final Color fg =
    data.isWarning ? const Color(0xFFB42318) : const Color(0xFF0C587A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Icon(
            data.icon,
            size: 12.5,
            color: fg,
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 165),
            child: Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: 10.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}