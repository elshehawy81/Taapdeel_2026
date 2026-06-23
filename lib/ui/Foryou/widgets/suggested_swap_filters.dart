part of 'suggested_swaps_section.dart';

class _SuggestedSwapFilters {
  const _SuggestedSwapFilters({
    this.conditionKeys = const <String>{},
    this.itemTypeKeys = const <String>{},
    this.interestGroups = const <String>{},
    this.subCategoryKeys = const <String>{},
    this.relationGroups = const <String>{},
    this.brandKeys = const <String>{},
    this.sameGovernorateOnly = false,
    this.sameTownshipOnly = false,
    this.hasBrandOnly = false,
  });

  final Set<String> conditionKeys;
  final Set<String> itemTypeKeys;
  final Set<String> interestGroups;
  final Set<String> subCategoryKeys;
  final Set<String> relationGroups;
  final Set<String> brandKeys;
  final bool sameGovernorateOnly;
  final bool sameTownshipOnly;
  final bool hasBrandOnly;

  int get activeCount {
    return conditionKeys.length +
        itemTypeKeys.length +
        interestGroups.length +
        subCategoryKeys.length +
        relationGroups.length +
        brandKeys.length +
        (sameGovernorateOnly ? 1 : 0) +
        (sameTownshipOnly ? 1 : 0) +
        (hasBrandOnly ? 1 : 0);
  }

  bool get isEmpty => activeCount == 0;

  _SuggestedSwapFilters copyWith({
    Set<String>? conditionKeys,
    Set<String>? itemTypeKeys,
    Set<String>? interestGroups,
    Set<String>? subCategoryKeys,
    Set<String>? relationGroups,
    Set<String>? brandKeys,
    bool? sameGovernorateOnly,
    bool? sameTownshipOnly,
    bool? hasBrandOnly,
  }) {
    return _SuggestedSwapFilters(
      conditionKeys: conditionKeys ?? this.conditionKeys,
      itemTypeKeys: itemTypeKeys ?? this.itemTypeKeys,
      interestGroups: interestGroups ?? this.interestGroups,
      subCategoryKeys: subCategoryKeys ?? this.subCategoryKeys,
      relationGroups: relationGroups ?? this.relationGroups,
      brandKeys: brandKeys ?? this.brandKeys,
      sameGovernorateOnly: sameGovernorateOnly ?? this.sameGovernorateOnly,
      sameTownshipOnly: sameTownshipOnly ?? this.sameTownshipOnly,
      hasBrandOnly: hasBrandOnly ?? this.hasBrandOnly,
    );
  }

  List<Product> apply(
      List<Product> products, {
        required Product? myProduct,
      }) {
    if (isEmpty) return products;

    return products.where((Product p) {
      if (conditionKeys.isNotEmpty &&
          !conditionKeys.contains(_SuggestedSwapFilterData.conditionKey(p))) {
        return false;
      }

      if (itemTypeKeys.isNotEmpty &&
          !itemTypeKeys.contains(_SuggestedSwapFilterData.itemTypeKey(p))) {
        return false;
      }

      if (interestGroups.isNotEmpty &&
          !interestGroups.any((String g) =>
              _SuggestedSwapFilterData.matchesInterestGroup(p, g))) {
        return false;
      }

      if (subCategoryKeys.isNotEmpty &&
          !subCategoryKeys.contains(_SuggestedSwapFilterData.subCategoryKey(p))) {
        return false;
      }

      if (relationGroups.isNotEmpty &&
          !relationGroups.any((String g) =>
              _SuggestedSwapFilterData.matchesRelationGroup(p, g))) {
        return false;
      }

      if (hasBrandOnly && !_SuggestedSwapFilterData.hasBrand(p)) {
        return false;
      }

      if (brandKeys.isNotEmpty &&
          !brandKeys.contains(_SuggestedSwapFilterData.brandKey(p))) {
        return false;
      }

      if (sameGovernorateOnly &&
          !_SuggestedSwapFilterData.sameGovernorate(myProduct, p)) {
        return false;
      }

      if (sameTownshipOnly &&
          !_SuggestedSwapFilterData.sameTownship(myProduct, p)) {
        return false;
      }

      return true;
    }).toList(growable: false);
  }
}

class _SuggestedSwapFilterOption {
  const _SuggestedSwapFilterOption({
    required this.key,
    required this.label,
    required this.count,
  });

  final String key;
  final String label;
  final int count;
}

class _SuggestedSwapFilterData {
  static String _safe(dynamic value) {
    final String text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  static dynamic _read(dynamic object, List<String> names) {
    for (final String name in names) {
      try {
        switch (name) {
          case 'id':
            return object.id;
          case 'name':
            return object.name;
          case 'title':
            return object.title;
          case 'catId':
            return object.catId;
          case 'cat_id':
            return object.cat_id;
          case 'subCatId':
            return object.subCatId;
          case 'sub_cat_id':
            return object.sub_cat_id;
          case 'brand':
            return object.brand;
          case 'itemLocationId':
            return object.itemLocationId;
          case 'item_location_id':
            return object.item_location_id;
          case 'itemLocationTownshipId':
            return object.itemLocationTownshipId;
          case 'item_location_township_id':
            return object.item_location_township_id;
          case 'conditionOfItemId':
            return object.conditionOfItemId;
          case 'condition_of_item_id':
            return object.condition_of_item_id;
          case 'conditionOfItem':
            return object.conditionOfItem;
          case 'condition_of_item':
            return object.condition_of_item;
          case 'itemTypeId':
            return object.itemTypeId;
          case 'item_type_id':
            return object.item_type_id;
          case 'itemType':
            return object.itemType;
          case 'item_type':
            return object.item_type;
          case 'subCategory':
            return object.subCategory;
          case 'sub_category':
            return object.sub_category;
          case 'relationType':
            return object.relationType;
          case 'relation_type':
            return object.relation_type;
          case 'relationCode':
            return object.relationCode;
          case 'relation_code':
            return object.relation_code;
          case 'interestMatchType':
            return object.interestMatchType;
          case 'interest_match_type':
            return object.interest_match_type;
          case 'interestOwnerRelationType':
            return object.interestOwnerRelationType;
          case 'interest_owner_relation_type':
            return object.interest_owner_relation_type;
          case 'interestOwnerRelationLabel':
            return object.interestOwnerRelationLabel;
          case 'interest_owner_relation_label':
            return object.interest_owner_relation_label;
        }
      } catch (_) {
        // try next key spelling
      }
    }
    return null;
  }

  static String _nestedId(dynamic object, List<String> objectNames) {
    for (final String name in objectNames) {
      final dynamic nested = _read(object, <String>[name]);
      final String id = _safe(_read(nested, const <String>['id']));
      if (id.isNotEmpty) return id;
    }
    return '';
  }

  static String _nestedName(dynamic object, List<String> objectNames) {
    for (final String name in objectNames) {
      final dynamic nested = _read(object, <String>[name]);
      final String value = _safe(_read(nested, const <String>['name']));
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  static String conditionKey(Product p) {
    final String direct = _safe(_read(p, const <String>[
      'conditionOfItemId',
      'condition_of_item_id',
    ]));
    if (direct.isNotEmpty) return direct;

    final String nested = _nestedId(p, const <String>[
      'conditionOfItem',
      'condition_of_item',
    ]);
    if (nested.isNotEmpty) return nested;

    return conditionLabel(p);
  }

  static String conditionLabel(Product p) {
    final String nested = _nestedName(p, const <String>[
      'conditionOfItem',
      'condition_of_item',
    ]);
    if (nested.isNotEmpty) return nested;

    final String id = _safe(_read(p, const <String>[
      'conditionOfItemId',
      'condition_of_item_id',
    ]));
    if (id == '5') return 'كسر زيرو';
    if (id == '4') return 'جيد جدًا';
    if (id == '3') return 'جيد';
    if (id == '2') return 'مقبول';
    if (id == '1') return 'جديد';
    return id.isEmpty ? 'حالة غير محددة' : id;
  }

  static String itemTypeKey(Product p) {
    final String direct = _safe(_read(p, const <String>[
      'itemTypeId',
      'item_type_id',
    ]));
    if (direct.isNotEmpty) return direct;

    final String nested = _nestedId(p, const <String>[
      'itemType',
      'item_type',
    ]);
    if (nested.isNotEmpty) return nested;

    return itemTypeLabel(p);
  }

  static String itemTypeLabel(Product p) {
    final String nested = _nestedName(p, const <String>[
      'itemType',
      'item_type',
    ]);
    if (nested.isNotEmpty) return nested;

    final String id = _safe(_read(p, const <String>[
      'itemTypeId',
      'item_type_id',
    ]));
    if (id == '2') return 'أقل من 3 شهور';
    if (id == '3') return 'من 3 إلى 6 شهور';
    if (id == '4') return 'من 6 إلى 12 شهر';
    if (id == '5') return 'أكثر من سنة';
    return id.isEmpty ? 'مدة غير محددة' : id;
  }

  static String subCategoryKey(Product p) {
    final String direct = _safe(_read(p, const <String>[
      'subCatId',
      'sub_cat_id',
    ]));
    if (direct.isNotEmpty) return direct;

    final String nested = _nestedId(p, const <String>[
      'subCategory',
      'sub_category',
    ]);
    if (nested.isNotEmpty) return nested;

    return subCategoryLabel(p);
  }

  static String subCategoryLabel(Product p) {
    final String nested = _nestedName(p, const <String>[
      'subCategory',
      'sub_category',
    ]);
    if (nested.isNotEmpty) return nested;
    final String key = _safe(_read(p, const <String>['subCatId', 'sub_cat_id']));
    return key.isEmpty ? 'تصنيف غير محدد' : key;
  }

  static String brandKey(Product p) => brandLabel(p).toLowerCase();

  static String brandLabel(Product p) => _safe(_read(p, const <String>['brand']));

  static bool hasBrand(Product p) => brandLabel(p).isNotEmpty;

  static String locationKey(Product? p) {
    if (p == null) return '';
    return _safe(_read(p, const <String>[
      'itemLocationId',
      'item_location_id',
    ]));
  }

  static String townshipKey(Product? p) {
    if (p == null) return '';
    return _safe(_read(p, const <String>[
      'itemLocationTownshipId',
      'item_location_township_id',
    ]));
  }

  static bool sameGovernorate(Product? mine, Product candidate) {
    final String myLocation = locationKey(mine);
    final String candidateLocation = locationKey(candidate);
    return myLocation.isNotEmpty && candidateLocation == myLocation;
  }

  static bool sameTownship(Product? mine, Product candidate) {
    final String myTownship = townshipKey(mine);
    final String candidateTownship = townshipKey(candidate);
    return myTownship.isNotEmpty && candidateTownship == myTownship;
  }

  static int relationType(Product p) {
    final String direct = _safe(_read(p, const <String>[
      'relationType',
      'relation_type',
    ]));
    final int? parsed = int.tryParse(direct);
    if (parsed != null) return parsed;

    final String code = relationCode(p).toUpperCase();
    if (code == 'FRIEND' || code == 'FRIENDS' || code == 'DIRECT_FRIEND') {
      return 1;
    }
    if (code.isNotEmpty && code != 'NONE' && code != 'SELF') {
      return 2;
    }
    return 0;
  }

  static String relationCode(Product p) => _safe(_read(p, const <String>[
    'relationCode',
    'relation_code',
  ]));

  static bool matchesRelationGroup(Product p, String group) {
    final int type = relationType(p);
    final String code = relationCode(p).toUpperCase();

    if (group == 'friends') {
      return type == 1 || code.contains('FRIEND');
    }

    if (group == 'family') {
      return type >= 2 && type <= 6;
    }

    if (group == 'relatives') {
      return type > 0 || (code.isNotEmpty && code != 'NONE');
    }

    return false;
  }

  static String interestMatchType(Product p) => _safe(_read(p, const <String>[
    'interestMatchType',
    'interest_match_type',
  ])).toLowerCase();

  static int interestOwnerRelationType(Product p) {
    final String value = _safe(_read(p, const <String>[
      'interestOwnerRelationType',
      'interest_owner_relation_type',
    ]));
    return int.tryParse(value) ?? 0;
  }

  static bool matchesInterestGroup(Product p, String group) {
    final String matchType = interestMatchType(p);
    final int ownerRelationType = interestOwnerRelationType(p);

    if (group == 'me') {
      return matchType == 'self' ||
          matchType == 'me' ||
          matchType == 'mine' ||
          ownerRelationType == 777;
    }

    if (group == 'friends') {
      return matchType == 'friend' ||
          matchType == 'friends' ||
          ownerRelationType == 1;
    }

    if (group == 'family') {
      return matchType == 'family' ||
          (ownerRelationType >= 2 && ownerRelationType <= 6);
    }

    return false;
  }

  static List<_SuggestedSwapFilterOption> buildOptions(
      List<Product> products, {
        required String Function(Product product) keyOf,
        required String Function(Product product) labelOf,
      }) {
    final Map<String, _SuggestedSwapFilterOption> map =
    <String, _SuggestedSwapFilterOption>{};

    for (final Product p in products) {
      final String key = keyOf(p).trim();
      if (key.isEmpty) continue;

      final String label = labelOf(p).trim();
      if (label.isEmpty) continue;

      final _SuggestedSwapFilterOption? current = map[key];
      map[key] = _SuggestedSwapFilterOption(
        key: key,
        label: label,
        count: (current?.count ?? 0) + 1,
      );
    }

    final List<_SuggestedSwapFilterOption> options = map.values.toList();
    options.sort((a, b) {
      final int countCompare = b.count.compareTo(a.count);
      if (countCompare != 0) return countCompare;
      return a.label.compareTo(b.label);
    });
    return options;
  }
}

class _SuggestedSwapFiltersBottomSheet extends StatefulWidget {
  const _SuggestedSwapFiltersBottomSheet({
    required this.products,
    required this.myProduct,
    required this.initialFilters,
  });

  final List<Product> products;
  final Product? myProduct;
  final _SuggestedSwapFilters initialFilters;

  @override
  State<_SuggestedSwapFiltersBottomSheet> createState() =>
      _SuggestedSwapFiltersBottomSheetState();
}

class _SuggestedSwapFiltersBottomSheetState
    extends State<_SuggestedSwapFiltersBottomSheet> {
  late _SuggestedSwapFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilters;
  }

  void _toggleSet(String key, Set<String> current, ValueChanged<Set<String>> save) {
    final Set<String> next = Set<String>.from(current);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    save(next);
  }

  int _countWhere(bool Function(Product product) test) {
    int count = 0;
    for (final Product p in widget.products) {
      if (test(p)) count++;
    }
    return count;
  }

  bool _isLocationAllSelected() {
    return !_draft.sameGovernorateOnly && !_draft.sameTownshipOnly;
  }

  bool _isSetAllSelected(Set<String> values) {
    return values.isEmpty;
  }

  bool _isBrandAllSelected() {
    return !_draft.hasBrandOnly && _draft.brandKeys.isEmpty;
  }

  void _selectAllLocations() {
    setState(() {
      _draft = _draft.copyWith(
        sameGovernorateOnly: false,
        sameTownshipOnly: false,
      );
    });
  }

  void _selectAllForSet(String type) {
    setState(() {
      switch (type) {
        case 'condition':
          _draft = _draft.copyWith(conditionKeys: <String>{});
          break;
        case 'itemType':
          _draft = _draft.copyWith(itemTypeKeys: <String>{});
          break;
        case 'interest':
          _draft = _draft.copyWith(interestGroups: <String>{});
          break;
        case 'relation':
          _draft = _draft.copyWith(relationGroups: <String>{});
          break;
        case 'subCategory':
          _draft = _draft.copyWith(subCategoryKeys: <String>{});
          break;
        case 'brand':
          _draft = _draft.copyWith(
            hasBrandOnly: false,
            brandKeys: <String>{},
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<_SuggestedSwapFilterOption> conditionOptions =
    _SuggestedSwapFilterData.buildOptions(
      widget.products,
      keyOf: _SuggestedSwapFilterData.conditionKey,
      labelOf: _SuggestedSwapFilterData.conditionLabel,
    );

    final List<_SuggestedSwapFilterOption> itemTypeOptions =
    _SuggestedSwapFilterData.buildOptions(
      widget.products,
      keyOf: _SuggestedSwapFilterData.itemTypeKey,
      labelOf: _SuggestedSwapFilterData.itemTypeLabel,
    );

    final List<_SuggestedSwapFilterOption> subCategoryOptions =
    _SuggestedSwapFilterData.buildOptions(
      widget.products,
      keyOf: _SuggestedSwapFilterData.subCategoryKey,
      labelOf: _SuggestedSwapFilterData.subCategoryLabel,
    );

    final List<_SuggestedSwapFilterOption> brandOptions =
    _SuggestedSwapFilterData.buildOptions(
      widget.products.where(_SuggestedSwapFilterData.hasBrand).toList(growable: false),
      keyOf: _SuggestedSwapFilterData.brandKey,
      labelOf: _SuggestedSwapFilterData.brandLabel,
    );

    final int sameGovernorateCount = _countWhere(
          (Product p) => _SuggestedSwapFilterData.sameGovernorate(widget.myProduct, p),
    );
    final int sameTownshipCount = _countWhere(
          (Product p) => _SuggestedSwapFilterData.sameTownship(widget.myProduct, p),
    );
    final int hasBrandCount = _countWhere(_SuggestedSwapFilterData.hasBrand);
    final int friendRelationCount = _countWhere(
          (Product p) => _SuggestedSwapFilterData.matchesRelationGroup(p, 'friends'),
    );
    final int familyRelationCount = _countWhere(
          (Product p) => _SuggestedSwapFilterData.matchesRelationGroup(p, 'family'),
    );
    final int relativesCount = _countWhere(
          (Product p) => _SuggestedSwapFilterData.matchesRelationGroup(p, 'relatives'),
    );
    final int myInterestCount = _countWhere(
          (Product p) => _SuggestedSwapFilterData.matchesInterestGroup(p, 'me'),
    );
    final int friendsInterestCount = _countWhere(
          (Product p) => _SuggestedSwapFilterData.matchesInterestGroup(p, 'friends'),
    );
    final int familyInterestCount = _countWhere(
          (Product p) => _SuggestedSwapFilterData.matchesInterestGroup(p, 'family'),
    );

    final int resultCount = _draft
        .apply(widget.products, myProduct: widget.myProduct)
        .length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.48,
        maxChildSize: 0.94,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 22,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5E7EE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF8FC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.filter_alt_rounded,
                          color: Color(0xFF0C587A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'تصفية الترشيحات',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF123B52),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'الفلاتر تظهر حسب الترشيحات المعروضة حاليًا',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: const Color(0xFF6B8594),
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4FCFE),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFD8EFF5)),
                        ),
                        child: Text(
                          '$resultCount نتيجة',
                          style: const TextStyle(
                            color: Color(0xFF0C587A),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    children: <Widget>[

                      _SuggestedSwapFilterSection(
                        title: 'الترشيح مناسب لـ',
                        children: <Widget>[
                          _SuggestedSwapFilterChip(
                            label: 'الكل',
                            count: widget.products.length,
                            selected: _isSetAllSelected(_draft.interestGroups),
                            icon: Icons.apps_rounded,
                            onTap: () => _selectAllForSet('interest'),
                          ),
                          if (myInterestCount > 0)
                            _SuggestedSwapFilterChip(
                              label: 'اهتماماتي',
                              count: myInterestCount,
                              selected: _draft.interestGroups.contains('me'),
                              icon: Icons.person_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  'me',
                                  _draft.interestGroups,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(interestGroups: next),
                                );
                              }),
                            ),
                          if (friendsInterestCount > 0)
                            _SuggestedSwapFilterChip(
                              label: 'الأصدقاء',
                              count: friendsInterestCount,
                              selected: _draft.interestGroups.contains('friends'),
                              icon: Icons.groups_2_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  'friends',
                                  _draft.interestGroups,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(interestGroups: next),
                                );
                              }),
                            ),
                          if (familyInterestCount > 0)
                            _SuggestedSwapFilterChip(
                              label: 'اهتمامات افراد عائلتي',
                              count: familyInterestCount,
                              selected: _draft.interestGroups.contains('family'),
                              icon: Icons.family_restroom_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  'family',
                                  _draft.interestGroups,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(interestGroups: next),
                                );
                              }),
                            ),
                        ],
                      ),
                      _SuggestedSwapFilterSection(
                        title: 'ترشيحات من',
                        subtitle: 'أصدقاء، أقارب، عائلة',
                        children: <Widget>[
                          _SuggestedSwapFilterChip(
                            label: 'الكل',
                            count: widget.products.length,
                            selected: _isSetAllSelected(_draft.relationGroups),
                            icon: Icons.apps_rounded,
                            onTap: () => _selectAllForSet('relation'),
                          ),
                          if (friendRelationCount > 0)
                            _SuggestedSwapFilterChip(
                              label: 'أصدقاء',
                              count: friendRelationCount,
                              selected: _draft.relationGroups.contains('friends'),
                              icon: Icons.group_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  'friends',
                                  _draft.relationGroups,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(relationGroups: next),
                                );
                              }),
                            ),

                          if (relativesCount > 0)
                            _SuggestedSwapFilterChip(
                              label: 'أقارب ومعارف',
                              count: relativesCount,
                              selected: _draft.relationGroups.contains('relatives'),
                              icon: Icons.hub_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  'relatives',
                                  _draft.relationGroups,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(relationGroups: next),
                                );
                              }),
                            ),
                          if (familyRelationCount > 0)
                            _SuggestedSwapFilterChip(
                              label: 'افراد العائلة',
                              count: familyRelationCount,
                              selected: _draft.relationGroups.contains('family'),
                              icon: Icons.family_restroom_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  'family',
                                  _draft.relationGroups,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(relationGroups: next),
                                );
                              }),
                            ),
                        ],
                      ),
                      _SuggestedSwapFilterSection(
                        title: 'الترشيحات من فئات',
                        subtitle: 'يمكن اختيار أكثر من تصنيف',
                        children: <Widget>[
                          _SuggestedSwapFilterChip(
                            label: 'الكل',
                            count: widget.products.length,
                            selected: _isSetAllSelected(_draft.subCategoryKeys),
                            icon: Icons.apps_rounded,
                            onTap: () => _selectAllForSet('subCategory'),
                          ),
                          ...subCategoryOptions.map((o) {
                            return _SuggestedSwapFilterChip(
                              label: o.label,
                              count: o.count,
                              selected: _draft.subCategoryKeys.contains(o.key),
                              icon: Icons.category_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  o.key,
                                  _draft.subCategoryKeys,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(subCategoryKeys: next),
                                );
                              }),
                            );
                          }),
                        ],
                      ),
                      _SuggestedSwapFilterSection(
                        title: 'مكان الترشيحات',
                        subtitle: 'فلترة ذكية مقارنة بمكان منتجك',
                        children: <Widget>[
                          _SuggestedSwapFilterChip(
                            label: 'الكل',
                            count: widget.products.length,
                            selected: _isLocationAllSelected(),
                            icon: Icons.apps_rounded,
                            onTap: _selectAllLocations,
                          ),
                          if (sameGovernorateCount > 0)
                            _SuggestedSwapFilterChip(
                              label: 'نفس المحافظة',
                              count: sameGovernorateCount,
                              selected: _draft.sameGovernorateOnly && !_draft.sameTownshipOnly,
                              icon: Icons.location_city_rounded,
                              onTap: () => setState(() {
                                final bool isSelected =
                                    _draft.sameGovernorateOnly && !_draft.sameTownshipOnly;
                                _draft = _draft.copyWith(
                                  sameGovernorateOnly: !isSelected,
                                  sameTownshipOnly: false,
                                );
                              }),
                            ),
                          if (sameTownshipCount > 0)
                            _SuggestedSwapFilterChip(
                              label: 'نفس المنطقة',
                              count: sameTownshipCount,
                              selected: _draft.sameTownshipOnly,
                              icon: Icons.place_rounded,
                              onTap: () => setState(() {
                                final bool isSelected = _draft.sameTownshipOnly;
                                _draft = _draft.copyWith(
                                  sameTownshipOnly: !isSelected,
                                  sameGovernorateOnly: !isSelected,
                                );
                              }),
                            ),
                        ],
                      ),
                      _SuggestedSwapFilterSection(
                        title: 'جودة الترشيحات',
                        children: <Widget>[
                          _SuggestedSwapFilterChip(
                            label: 'الكل',
                            count: widget.products.length,
                            selected: _isSetAllSelected(_draft.conditionKeys),
                            icon: Icons.apps_rounded,
                            onTap: () => _selectAllForSet('condition'),
                          ),
                          ...conditionOptions.map((o) {
                            return _SuggestedSwapFilterChip(
                              label: o.label,
                              count: o.count,
                              selected: _draft.conditionKeys.contains(o.key),
                              icon: Icons.verified_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  o.key,
                                  _draft.conditionKeys,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(conditionKeys: next),
                                );
                              }),
                            );
                          }),
                        ],
                      ),
                      _SuggestedSwapFilterSection(
                        title: ' مدة استخدام الترشيحات',
                        children: <Widget>[
                          _SuggestedSwapFilterChip(
                            label: 'الكل',
                            count: widget.products.length,
                            selected: _isSetAllSelected(_draft.itemTypeKeys),
                            icon: Icons.apps_rounded,
                            onTap: () => _selectAllForSet('itemType'),
                          ),
                          ...itemTypeOptions.map((o) {
                            return _SuggestedSwapFilterChip(
                              label: o.label,
                              count: o.count,
                              selected: _draft.itemTypeKeys.contains(o.key),
                              icon: Icons.schedule_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  o.key,
                                  _draft.itemTypeKeys,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(itemTypeKeys: next),
                                );
                              }),
                            );
                          }),
                        ],
                      ),
                      _SuggestedSwapFilterSection(
                        title: 'البراند',
                        children: <Widget>[
                          _SuggestedSwapFilterChip(
                            label: 'الكل',
                            count: widget.products.length,
                            selected: _isBrandAllSelected(),
                            icon: Icons.apps_rounded,
                            onTap: () => _selectAllForSet('brand'),
                          ),
                          if (hasBrandCount > 0)
                            _SuggestedSwapFilterChip(
                              label: 'له براند',
                              count: hasBrandCount,
                              selected: _draft.hasBrandOnly,
                              icon: Icons.sell_rounded,
                              onTap: () => setState(() {
                                _draft = _draft.copyWith(
                                  hasBrandOnly: !_draft.hasBrandOnly,
                                );
                              }),
                            ),
                          ...brandOptions.map((o) {
                            return _SuggestedSwapFilterChip(
                              label: o.label,
                              count: o.count,
                              selected: _draft.brandKeys.contains(o.key),
                              icon: Icons.local_offer_rounded,
                              onTap: () => setState(() {
                                _toggleSet(
                                  o.key,
                                  _draft.brandKeys,
                                      (Set<String> next) =>
                                  _draft = _draft.copyWith(brandKeys: next),
                                );
                              }),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() {
                              _draft = const _SuggestedSwapFilters();
                            }),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              side: const BorderSide(color: Color(0xFFBFEAF0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'إعادة ضبط',
                              style: TextStyle(
                                color: Color(0xFF0C587A),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(_draft),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              backgroundColor: const Color(0xFF0C587A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'تطبيق الفلتر ($resultCount)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SuggestedSwapFilterSection extends StatelessWidget {
  const _SuggestedSwapFilterSection({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> visibleChildren = children
        .where((Widget child) => child is! SizedBox || child.height != 0)
        .toList(growable: false);
    if (visibleChildren.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2F1F6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF123B52),
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
              height: 1.1,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF7A929F),
                fontWeight: FontWeight.w700,
                fontSize: 10.7,
                height: 1.15,
              ),
            ),
          ],
          const SizedBox(height: 9),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < visibleChildren.length; i++) ...<Widget>[
                  visibleChildren[i],
                  if (i != visibleChildren.length - 1)
                    const SizedBox(width: 7),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedSwapFilterChip extends StatelessWidget {
  const _SuggestedSwapFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsetsDirectional.only(
            start: 10,
            end: 9,
            top: 8,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE6FAFD) : const Color(0xFFF7FBFC),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? const Color(0xFF19D4E2) : const Color(0xFFD8EFF5),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(
                  icon,
                  size: 14,
                  color: selected
                      ? const Color(0xFF0C587A)
                      : const Color(0xFF7194A5),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF0C587A)
                      : const Color(0xFF35586A),
                  fontWeight: FontWeight.w900,
                  fontSize: 11.2,
                  height: 1,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                height: 18,
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF0C587A) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? const Color(0xFF0C587A) : const Color(0xFFD8EFF5),
                  ),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF0C587A),
                    fontWeight: FontWeight.w900,
                    fontSize: 9.2,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


