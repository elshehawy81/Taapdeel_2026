import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/category/category_provider.dart';
import 'package:taapdeel/provider/entry/item_entry_provider.dart';
import 'package:taapdeel/provider/gallery/gallery_provider.dart';
import 'package:taapdeel/provider/subcategory/sub_category_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_glass_bottom_sheet.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';
import 'package:taapdeel/ui/item/share_theme/product_share_options.dart';
import 'package:taapdeel/utils/taapdeel_share_links.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/ui/category/taapdeel_category_rules.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/item_entry_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/sub_category.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/ps_config.dart';
import '../../../common/dialog/warning_dialog_view.dart';
import '../../../common/taapdeel/taapdeel_button.dart';
import '../../../common/taapdeel/taapdeel_standard_grid_picker.dart';
import '../../../common/taapdeel/taapdeel_standard_picker.dart';
import '../../../user/profile/profile_route_page.dart';
import 'dynamic_subcategory_fields.dart';
import 'editable_image_tags.dart';

/// ✅ Badge status model (مكتسبة/مقفولة) — داخل نفس الملف عشان ما نفتحش ملفات جديدة
class TaapdeelBadgeStatus {
  final String id;
  final String title;
  final IconData icon;
  final bool earned;
  final String? earnedHint;
  final String? lockedHint;

  const TaapdeelBadgeStatus({
    required this.id,
    required this.title,
    required this.icon,
    required this.earned,
    this.earnedHint,
    this.lockedHint,
  });
}

class AllControllerTextWidget extends StatefulWidget {
  const AllControllerTextWidget({
    Key? key,
    this.userInputListingTitle,
    this.categoryController,
    this.subCategoryController,
    this.typeController,
    this.itemConditionController,
    this.priceTypeController,
    this.priceController,
    this.userInputHighLightInformation,
    this.userInputDescription,
    this.dealOptionController,
    this.userInputDealOptionText,
    this.locationController,
    this.locationTownshipController,
    this.userInputLattitude,
    this.userInputLongitude,
    this.userInputAddress,
    this.userInputPrice,
    this.userInputDiscount,
    this.mapController,
    this.provider,
    this.galleryProvider,
    this.userProvider,
    this.latlng,
    this.zoom,
    this.flag,
    this.item,
    this.uploadImage,
    this.localShareImagePathResolver,
    required this.isImageSelected,
    this.isSelectedVideoImagePath,
    required this.currentStep,
    this.packagingController,
    this.onHighQualityChanged,
    this.onBadgesChanged,
    this.isBulkMode = false,
    this.bulkDefaults,
    this.onItemUploaded,
  }) : super(key: key);

  final TextEditingController? userInputListingTitle;
  final TextEditingController? categoryController;
  final TextEditingController? subCategoryController;
  final TextEditingController? typeController;
  final TextEditingController? itemConditionController;
  final TextEditingController? priceTypeController;
  final TextEditingController? priceController;
  final TextEditingController? userInputHighLightInformation;
  final TextEditingController? userInputDescription;
  final TextEditingController? dealOptionController;
  final TextEditingController? userInputDealOptionText;
  final ValueChanged<bool>? onHighQualityChanged;
  final void Function(int count, List<TaapdeelBadgeStatus> list)? onBadgesChanged;

  /// لو true: تخطي bottom sheet المشاركة والأمنيات بعد النشر
  final bool isBulkMode;

  /// Bulk mode defaults passed from BulkItemQueueView/ItemEntryContainerView.
  /// Kept dynamic to avoid adding a hard dependency from the shared entry widget
  /// to the bulk feature folder. Expected fields:
  /// categoryId/categoryName/subCategoryId/subCategoryName/conditionId/conditionName/usageDurationId/usageDurationName.
  final dynamic bulkDefaults;

  /// Called after a single product is completed and the success sheet is closed.
  /// Dashboard uses this to leave the entry tab and return to the normal app flow.
  final ValueChanged<String>? onItemUploaded;

  final TextEditingController? locationController;
  final TextEditingController? locationTownshipController;
  final TextEditingController? userInputLattitude;
  final TextEditingController? userInputLongitude;
  final TextEditingController? userInputAddress;
  final TextEditingController? userInputPrice;
  final TextEditingController? userInputDiscount;
  final dynamic mapController;
  final ItemEntryProvider? provider;
  final GalleryProvider? galleryProvider;
  final UserProvider? userProvider;
  final double? zoom;
  final String? flag;
  final Product? item;
  final LatLng? latlng;
  final Future<void> Function(String itemId)? uploadImage;
  final String Function()? localShareImagePathResolver;
  final List<bool> isImageSelected;
  final bool? isSelectedVideoImagePath;
  final TextEditingController? packagingController;
  final int currentStep;

  @override
  State<AllControllerTextWidget> createState() => AllControllerTextWidgetState();
}

class AllControllerTextWidgetState extends State<AllControllerTextWidget> {
  static const Color _filledBorderColor = Color(0xFF22C55E);
  static const Color _filledBorderColorFocused = Color(0xFF16A34A);
  static const double _filledBorderWidth = 0.9;

  LatLng? _latlng;
  int? _selectedMinPrice;
  int? _selectedMaxPrice;

  bool get _isHighQualitySelected {
    return _selectedConditionIndex == 2 || _selectedConditionIndex == 1;
  }

  bool get _isNew {
    return _selectedConditionIndex == 6;
  }

  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();

  Map<String, dynamic> _dynamicStep3Values = <String, dynamic>{};

  bool _isFree = false;
  bool _isImported = false;
  bool _isWrapped = false;

  String _visibilityGender = 'all';

  int _earnedBadgesCountExcludingFeatured() {
    int count = 0;

    if (_isHighQualitySelected) count++;
    if (_isLightUsageSelected()) count++;
    if (_hasBrandSelected()) count++;

    if (_isFree) count++;
    if (_isImported) count++;
    if (_isWrapped) count++;
    if (_isNew) count++;

    return count;
  }

  int _computeTierFromEarnedBadges() {
    final int earned = _earnedBadgesCountExcludingFeatured();
    if (earned >= 3) return 2;
    return 1;
  }

  String _buildEarnedBadgesRemarkJson() {
    final List<Map<String, dynamic>> earnedBadges = <Map<String, dynamic>>[];

    void addIf(bool cond, String id, String title) {
      if (cond) {
        earnedBadges.add(<String, dynamic>{'id': id, 'title': title});
      }
    }

    addIf(_isHighQualitySelected, 'high_quality', 'جودة عالية');
    addIf(_isLightUsageSelected(), 'light_usage', 'استخدام خفيف');
    addIf(_hasBrandSelected(), 'brand', 'براند');
    addIf(_isFree, 'free', 'مجاني');
    addIf(_isImported, 'imported', 'مستورد');
    addIf(_isWrapped, 'wrapped', 'ثقة');
    addIf(_isNew, 'new', 'جديد');

    final int tier = _computeTierFromEarnedBadges();

    final Map<String, dynamic> payload = <String, dynamic>{
      'tier': tier,
      'earned_count': earnedBadges.length,
      'earned_badges': earnedBadges,
    };

    return jsonEncode(payload);
  }

  PsValueHolder? valueHolder;
  late ItemEntryProvider itemEntryProvider;

  String _normalizeTag(String value) {
    return value.trim().toLowerCase();
  }

  List<String> _mergeTagsWithBrand({
    required List<String> baseTags,
    required String brand,
  }) {
    final List<String> result = <String>[];
    final Set<String> seen = <String>{};

    void addTag(String v) {
      final String cleaned = v.trim();
      if (cleaned.isEmpty) return;

      final String key = _normalizeTag(cleaned);
      if (seen.contains(key)) return;

      seen.add(key);
      result.add(cleaned);
    }

    for (final String t in baseTags) {
      addTag(t);
    }

    addTag(brand);

    return result;
  }

  Future<void> submit() async {
    await _handleSubmit();
  }

  bool _autoCategoryHintVisible = false;

  bool _isLightUsageSelected() {
    return itemEntryProvider.itemTypeId == '2' || itemEntryProvider.itemTypeId == '3';
  }

  final ScrollController _categoryScrollController = ScrollController();
  String? _loadedSubCategoryCatId;
  int _selectedConditionIndex = -1;
  bool _didPrefillLocation = false;
  bool _didApplyBulkDefaults = false;
  bool _isLoadingBulkSubCategories = false;

  final List<_ConditionOption> _conditionOptions = const <_ConditionOption>[
    _ConditionOption(id: '6', emoji: '💎', titleKey: 'item_condition__new_title', hintKey: 'item_condition__new_hint'),
    _ConditionOption(id: '5', emoji: '✨', titleKey: 'item_condition__excellent_title', hintKey: 'item_condition__excellent_hint'),
    _ConditionOption(id: '4', emoji: '👌', titleKey: 'item_condition__very_good_title', hintKey: 'item_condition__very_good_hint'),
    _ConditionOption(id: '3', emoji: '🙂', titleKey: 'item_condition__good_title', hintKey: 'item_condition__good_hint'),
    _ConditionOption(id: '2', emoji: '✅', titleKey: 'item_condition__acceptable_title', hintKey: 'item_condition__acceptable_hint'),
    _ConditionOption(id: '1', emoji: '🛠', titleKey: 'item_condition__needs_fix_title', hintKey: 'item_condition__needs_fix_hint'),
  ];

  static const List<_UsageDurationOption> _usageDurationOptions = <_UsageDurationOption>[
    _UsageDurationOption(id: '2', label: 'أقل من 3 شهور'),
    _UsageDurationOption(id: '3', label: 'من 3 إلى 6 شهور'),
    _UsageDurationOption(id: '4', label: 'من 6 إلى 12 شهر'),
    _UsageDurationOption(id: '5', label: 'من سنة إلى سنتين'),
    _UsageDurationOption(id: '6', label: 'من سنتين إلى 3 سنوات'),
    _UsageDurationOption(id: '7', label: 'من 3 إلى 4 سنوات'),
    _UsageDurationOption(id: '8', label: 'من 4 إلى 5 سنوات'),
    _UsageDurationOption(id: '9', label: 'أكثر من 5 سنوات'),
  ];

  static const int _openEndedMax = 120000;

  static const List<_PriceBand> _priceBands = <_PriceBand>[
    _PriceBand(label: '0–10,000', min: 0, max: 10000),
    _PriceBand(label: '10k–20k', min: 10000, max: 20000),
    _PriceBand(label: '20k–30k', min: 20000, max: 30000),
    _PriceBand(label: '30k–40k', min: 30000, max: 40000),
    _PriceBand(label: '40k–50k', min: 40000, max: 50000),
    _PriceBand(label: '50k–60k', min: 50000, max: 60000),
    _PriceBand(label: '+60k', min: 60000, max: _openEndedMax),
  ];

  int _selectedBandIndex = 0;

  int _stepForMin(int min) {
    if (min < 500) {
      return 100;
    } else if (min < 1000) {
      return 300;
    } else if (min < 5000) {
      return 500;
    } else {
      return 1000;
    }
  }

  _PriceBand _bandForMin(int min) {
    final int idx = _priceBands.indexWhere((b) => min >= b.min && min < b.max);
    if (idx != -1) return _priceBands[idx];
    return _priceBands.last;
  }

  String _digitsOnly(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');

  String _lastBadgesSignature = '';

  bool _hasBrandSelected() {
    final keys = <String>['brand_id', 'brandId', 'brand', 'brand_name', 'brandName'];
    for (final k in keys) {
      if (_dynamicStep3Values.containsKey(k) && _hasValue(_dynamicStep3Values[k])) {
        return true;
      }
    }
    return false;
  }

  String _extractBrandValue() {
    final List<String> keys = <String>['brand', 'brand_name', 'brandName', 'brand_id', 'brandId'];

    dynamic raw;
    for (final k in keys) {
      if (_dynamicStep3Values.containsKey(k) && _hasValue(_dynamicStep3Values[k])) {
        raw = _dynamicStep3Values[k];
        break;
      }
    }

    if ((raw == null || !_hasValue(raw)) &&
        (itemEntryProvider.brand ?? '').toString().trim().isNotEmpty) {
      raw = itemEntryProvider.brand;
    }

    if (raw == null) return '';

    if (raw is Map) {
      final dynamic name = raw['name'] ?? raw['title'] ?? raw['label'];
      if (_hasValue(name)) return name.toString().trim();

      final dynamic id = raw['id'] ?? raw['value'];
      if (_hasValue(id)) return id.toString().trim();

      return raw.toString().trim();
    }

    if (raw is List) {
      final parts = raw
          .map((e) => e?.toString().trim())
          .where((s) => s != null && s!.isNotEmpty)
          .toList();
      return parts.join(',');
    }

    return raw.toString().trim();
  }

  bool _hasDiscountSelected() {
    final String v = widget.userInputDiscount?.text.trim() ?? '';
    if (v.isEmpty) return false;
    final int? n = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
    return (n ?? 0) > 0;
  }

  void _emitBadgesChanged() {
    final bool bHighQuality = _isHighQualitySelected;
    final bool bLightUsage = _isLightUsageSelected();
    final bool bBrand = _hasBrandSelected();
    final bool bFree = _isFree;
    final bool bImported = _isImported;
    final bool bWrapped = _isWrapped;
    final bool bNew = _isNew;

    final List<TaapdeelBadgeStatus> list = <TaapdeelBadgeStatus>[
      TaapdeelBadgeStatus(
        id: 'high_quality',
        title: 'جودة عالية',
        icon: Icons.verified_rounded,
        earned: bHighQuality,
        earnedHint: 'حالة المنتج: ممتاز/جيد جداً',
        lockedHint: 'اختار حالة: ممتاز أو جيد جداً.',
      ),
      TaapdeelBadgeStatus(
        id: 'light_usage',
        title: 'استخدام خفيف',
        icon: Icons.eco_rounded,
        earned: bLightUsage,
        earnedHint: 'مدة استخدام أقل من 6 شهور',
        lockedHint: 'اختار مدة استخدام: أقل من 6 شهور.',
      ),
      TaapdeelBadgeStatus(
        id: 'brand',
        title: 'براند',
        icon: Icons.verified_outlined,
        earned: bBrand,
        earnedHint: 'اختر البراند من الحقول الإضافية',
        lockedHint: 'اختار براند في الحقول الإضافية.',
      ),
      TaapdeelBadgeStatus(
        id: 'free',
        title: 'مجاني',
        icon: Icons.card_giftcard_rounded,
        earned: bFree,
        earnedHint: 'السعر مجاني',
        lockedHint: 'فعّل خيار مجاني.',
      ),
      TaapdeelBadgeStatus(
        id: 'imported',
        title: 'مستورد',
        icon: Icons.public_rounded,
        earned: bImported,
        earnedHint: 'المنتج مستورد',
        lockedHint: 'فعّل خيار مستورد.',
      ),
      TaapdeelBadgeStatus(
        id: 'wrapped',
        title: 'ثقة',
        icon: Icons.inventory_2_rounded,
        earned: bWrapped,
        earnedHint: 'المنتج مغلف/جاهز',
        lockedHint: 'فعّل خيار مغلف.',
      ),
      TaapdeelBadgeStatus(
        id: 'new',
        title: 'جديد',
        icon: Icons.new_releases,
        earned: bNew,
        earnedHint: 'المنتج جديد',
        lockedHint: 'فعّل خيار جديد.',
      ),
    ];

    final int count = list.where((b) => b.earned).length;
    final String signature = list.map((b) => '${b.id}:${b.earned ? 1 : 0}').join('|');
    if (signature == _lastBadgesSignature) return;
    _lastBadgesSignature = signature;

    widget.onBadgesChanged?.call(count, list);
  }

  void _updateAllBadgeToasts() {
    widget.onHighQualityChanged?.call(_isHighQualitySelected);
    _emitBadgesChanged();
  }

  void _updateQualityBanner() {
    _updateAllBadgeToasts();
  }

  void _syncAutoMaxFromMin(String rawMin) {
    final String cleaned = _digitsOnly(rawMin);
    if (cleaned.isEmpty) {
      setState(() {
        _selectedMinPrice = null;
        _selectedMaxPrice = null;
        _maxPriceCtrl.text = '';
        widget.userInputPrice?.clear();
        widget.priceTypeController?.clear();
      });
      return;
    }

    final int? min = int.tryParse(cleaned);
    if (min == null) {
      setState(() {
        _selectedMinPrice = null;
        _selectedMaxPrice = null;
        _maxPriceCtrl.text = '';
        widget.userInputPrice?.clear();
        widget.priceTypeController?.clear();
      });
      return;
    }

    final _PriceBand band = _bandForMin(min);
    final int step = _stepForMin(min);
    final int max = min + step;

    final int bandIndex = _priceBands.indexWhere((b) => b.min == band.min && b.max == band.max);

    setState(() {
      _selectedBandIndex = bandIndex == -1 ? _selectedBandIndex : bandIndex;
      _selectedMinPrice = min;
      _selectedMaxPrice = max;

      _maxPriceCtrl.text = max.toString();

      final String value = '$min-$max';
      widget.userInputPrice?.text = value;
      widget.priceTypeController?.text = value;
    });
  }

  void _syncHighlightInfoJson() {
    final Map<String, dynamic> merged = <String, dynamic>{
      ..._dynamicStep3Values,
    };

    merged['is_free'] = _isFree;
    merged['is_imported'] = _isImported;
    merged['is_wrapped'] = _isWrapped;
    merged['is_new'] = _isNew;
    merged['visibility_gender'] = _visibilityGender;

    widget.userInputHighLightInformation?.text = jsonEncode(merged);

    final List<String> tags = <String>[
      if (_isFree) 'free',
      if (_isImported) 'imported',
      if (_isWrapped) 'wrapped',
      if (_isNew) 'new',
    ];
    widget.packagingController?.text = tags.join(',');
  }

  void _prefillPackagingFromHighlightInfo() {
    final String raw = widget.userInputHighLightInformation?.text.trim() ?? '';
    if (raw.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _isFree = decoded['is_free'] == true;
          _isImported = decoded['is_imported'] == true;
          _isWrapped = decoded['is_wrapped'] == true;
          _visibilityGender = (decoded['visibility_gender'] ?? 'all').toString().trim().isEmpty
              ? 'all'
              : (decoded['visibility_gender'] ?? 'all').toString();
        }
      } catch (_) {}
    }

    final String csv = widget.packagingController?.text.trim() ?? '';
    if (csv.isNotEmpty) {
      final List<String> parts = csv.split(',').map((e) => e.trim().toLowerCase()).toList();
      if (parts.contains('free')) _isFree = true;
      if (parts.contains('imported')) _isImported = true;
      if (parts.contains('wrapped')) _isWrapped = true;
    }
  }

  static const String _specsStart = '\n\nالمواصفات:\n';

  bool _hasValue(dynamic v) {
    if (v == null) return false;
    if (v is String) return v.trim().isNotEmpty;
    if (v is bool) return true;
    if (v is num) return true;
    if (v is List) return v.isNotEmpty;
    if (v is Map) return v.isNotEmpty;
    return v.toString().trim().isNotEmpty;
  }

  String _stringify(dynamic v) {
    if (v == null) return '';
    if (v is bool) return v ? 'نعم' : 'لا';

    if (v is Map) {
      final dynamic name = v['name'] ?? v['title'] ?? v['label'];
      if (_hasValue(name)) return name.toString().trim();
      final dynamic id = v['id'] ?? v['value'];
      if (_hasValue(id)) return id.toString().trim();
      return v.toString().trim();
    }

    if (v is List) {
      return v.map(_stringify).where((s) => s.trim().isNotEmpty).join('، ');
    }

    return v.toString().trim();
  }

  bool _hasAnyDynamicValue() {
    for (final v in _dynamicStep3Values.values) {
      if (_hasValue(v)) return true;
    }
    return false;
  }

  String _buildSpecsText(Map<String, dynamic> dynamicValues) {
    final List<String> lines = [];

    dynamicValues.forEach((key, value) {
      if (!_hasValue(value)) return;
      final String label = key.replaceAll('_', ' ').trim();
      final String val = _stringify(value);
      if (val.isEmpty) return;
      lines.add('$label: $val');
    });

    if (lines.isEmpty) return '';
    return _specsStart + lines.join('\n');
  }

  Widget _buildPackagingInlineSwitches() {
    final ThemeData theme = Theme.of(context);

    Widget item({
      required String label,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value ? _filledBorderColor : Colors.transparent,
              width: value ? _filledBorderWidth : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F2E57),
                  ),
                ),
              ),
              const SizedBox(width: 0),
              SizedBox(
                width: 40,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Switch.adaptive(
                    value: value,
                    onChanged: onChanged,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        item(
          label: 'مستورد',
          value: _isImported,
          onChanged: (v) {
            setState(() {
              _isImported = v;
              _syncHighlightInfoJson();
            });
            _updateAllBadgeToasts();
          },
        ),
        const SizedBox(width: 5),
        item(
          label: 'مغلف',
          value: _isWrapped,
          onChanged: (v) {
            setState(() {
              _isWrapped = v;
              _syncHighlightInfoJson();
            });
            _updateAllBadgeToasts();
          },
        ),
      ],
    );
  }

  Widget _buildVisibilityCard() {
    final ThemeData theme = Theme.of(context);
    final bool visibilityFilled = _visibilityGender != 'all';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: visibilityFilled
              ? _filledBorderColor
              : Colors.black.withOpacity(0.06),
          width: visibilityFilled ? _filledBorderWidth : 1.0,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Text(
            'يظهر المنتج إلى',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F2E57),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildVisibilityGenderDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityGenderDropdown() {
    final ThemeData theme = Theme.of(context);
    final bool filled = _visibilityGender != 'all';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: filled ? _filledBorderColor : Colors.black.withOpacity(0.08),
          width: filled ? _filledBorderWidth : 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _visibilityGender,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFF0F2E57).withOpacity(0.72),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F2E57),
          ),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(
              value: 'all',
              child: Text('الجميع (رجال / نساء)'),
            ),
            DropdownMenuItem<String>(
              value: 'female_only',
              child: Text('نساء فقط'),
            ),
            DropdownMenuItem<String>(
              value: 'male_only',
              child: Text('رجال فقط'),
            ),
          ],
          onChanged: (String? value) {
            if (value == null) return;
            setState(() {
              _visibilityGender = value;
              _syncHighlightInfoJson();
            });
          },
        ),
      ),
    );
  }

  void _prefillLocationFromValueHolder() {
    final PsValueHolder? vh = valueHolder;
    if (vh == null) return;

    final bool alreadyHasLoc = (itemEntryProvider.itemLocationId ?? '').trim().isNotEmpty ||
        (itemEntryProvider.itemLocationTownshipId ?? '').trim().isNotEmpty ||
        (widget.userInputLattitude?.text.trim().isNotEmpty ?? false) ||
        (widget.userInputLongitude?.text.trim().isNotEmpty ?? false);

    if (alreadyHasLoc) return;

    final String locId = (vh.locationId ?? '').trim();
    final String locName = (vh.locactionName ?? '').trim();

    final String townId = (vh.locationTownshipId ?? '').trim();
    final String townName = (vh.locationTownshipName ?? '').trim();

    if (locId.isEmpty) return;

    itemEntryProvider.itemLocationId = locId;
    itemEntryProvider.itemLocationTownshipId = townId.isNotEmpty ? townId : '';

    widget.locationController?.text = locName;
    widget.locationTownshipController?.text = townName;

    final String townLat = (vh.locationTownshipLat ?? '').trim();
    final String townLng = (vh.locationTownshipLng ?? '').trim();
    final String locLat = (vh.locationLat ?? '').trim();
    final String locLng = (vh.locationLng ?? '').trim();

    final String latStr = townLat.isNotEmpty ? townLat : locLat;
    final String lngStr = townLng.isNotEmpty ? townLng : locLng;

    if (latStr.isNotEmpty && lngStr.isNotEmpty) {
      widget.userInputLattitude?.text = latStr;
      widget.userInputLongitude?.text = lngStr;

      final double? lat = double.tryParse(latStr);
      final double? lng = double.tryParse(lngStr);
      if (lat != null && lng != null) {
        _latlng = LatLng(lat, lng);
      }
    }
  }


  String _categoryNameFromLoadedList(String categoryId) {
    final String id = categoryId.trim();
    if (id.isEmpty) return '';
    try {
      final CategoryProvider catProvider = context.read<CategoryProvider>();
      final List<Category> categories = catProvider.categoryList.data ?? <Category>[];
      for (final Category c in categories) {
        if ((c.catId ?? '').trim() == id) {
          return (c.catName ?? '').trim();
        }
      }
    } catch (_) {}
    return '';
  }

  String _subCategoryNameFromLoadedList(String subCategoryId) {
    final String id = subCategoryId.trim();
    if (id.isEmpty) return '';
    try {
      final SubCategoryProvider subProvider = context.read<SubCategoryProvider>();
      final List<SubCategory> subCategories = subProvider.subCategoryList.data ?? <SubCategory>[];
      for (final SubCategory s in subCategories) {
        if ((s.id ?? '').trim() == id) {
          return (s.name ?? '').trim();
        }
      }
    } catch (_) {}
    return '';
  }

  void _ensureBulkControllerDisplayText() {
    if (!widget.isBulkMode) return;

    final String categoryId = (itemEntryProvider.categoryId ?? '').trim();
    final String subCategoryId = (itemEntryProvider.subCategoryId ?? '').trim();

    if (categoryId.isNotEmpty && (widget.categoryController?.text.trim().isEmpty ?? true)) {
      final String nameFromDefaults = _bulkDefaultText(<String>['categoryName']);
      final String nameFromList = _categoryNameFromLoadedList(categoryId);
      widget.categoryController?.text = nameFromDefaults.isNotEmpty
          ? nameFromDefaults
          : (nameFromList.isNotEmpty ? nameFromList : categoryId);
    }

    if (subCategoryId.isNotEmpty && (widget.subCategoryController?.text.trim().isEmpty ?? true)) {
      final String nameFromDefaults = _bulkDefaultText(<String>['subCategoryName']);
      final String nameFromList = _subCategoryNameFromLoadedList(subCategoryId);
      widget.subCategoryController?.text = nameFromDefaults.isNotEmpty
          ? nameFromDefaults
          : (nameFromList.isNotEmpty ? nameFromList : subCategoryId);
    }

    final String conditionId = (itemEntryProvider.itemConditionId ?? '').trim();
    if (conditionId.isNotEmpty && (widget.itemConditionController?.text.trim().isEmpty ?? true)) {
      final String nameFromDefaults = _bulkDefaultText(<String>['conditionName']);
      widget.itemConditionController?.text = nameFromDefaults.isNotEmpty
          ? nameFromDefaults
          : _bulkConditionTitleFromId(conditionId);
    }

    final String usageId = (itemEntryProvider.itemTypeId ?? '').trim();
    if (usageId.isNotEmpty && (widget.typeController?.text.trim().isEmpty ?? true)) {
      final String nameFromDefaults = _bulkDefaultText(<String>['usageDurationName']);
      widget.typeController?.text = nameFromDefaults.isNotEmpty
          ? nameFromDefaults
          : _bulkUsageTitleFromId(usageId);
    }
  }


  String _bulkDefaultText(List<String> keys) {
    final dynamic defaults = widget.bulkDefaults;
    if (defaults == null) return '';

    if (defaults is Map) {
      for (final String key in keys) {
        final dynamic value = defaults[key];
        final String text = (value ?? '').toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
      }
      return '';
    }

    for (final String key in keys) {
      try {
        dynamic value;
        switch (key) {
          case 'categoryId':
            value = (defaults as dynamic).categoryId;
            break;
          case 'categoryName':
            value = (defaults as dynamic).categoryName;
            break;
          case 'subCategoryId':
            value = (defaults as dynamic).subCategoryId;
            break;
          case 'subCategoryName':
            value = (defaults as dynamic).subCategoryName;
            break;
          case 'conditionId':
            value = (defaults as dynamic).conditionId;
            break;
          case 'conditionName':
            value = (defaults as dynamic).conditionName;
            break;
          case 'usageDurationId':
            value = (defaults as dynamic).usageDurationId;
            break;
          case 'usageDurationName':
            value = (defaults as dynamic).usageDurationName;
            break;
        }

        final String text = (value ?? '').toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
      } catch (_) {}
    }

    return '';
  }

  String _bulkConditionTitleFromId(String id) {
    if (id.trim().isEmpty) return '';
    final int idx = _conditionOptions.indexWhere((_ConditionOption o) => o.id == id);
    if (idx == -1) return '';
    return Utils.getString(context, _conditionOptions[idx].titleKey);
  }

  String _bulkUsageTitleFromId(String id) {
    if (id.trim().isEmpty) return '';
    try {
      return _usageDurationOptions
          .firstWhere((_UsageDurationOption o) => o.id == id)
          .label;
    } catch (_) {
      return '';
    }
  }

  Future<void> _loadBulkSubCategoriesIfNeeded(String categoryId) async {
    final String safeCategoryId = categoryId.trim();
    if (safeCategoryId.isEmpty) return;
    if (_loadedSubCategoryCatId == safeCategoryId || _isLoadingBulkSubCategories) return;

    _isLoadingBulkSubCategories = true;
    try {
      final SubCategoryProvider subProvider = context.read<SubCategoryProvider>();
      subProvider.subCategoryParameterHolder.catId = safeCategoryId;
      subProvider.categoryId = safeCategoryId;

      await subProvider.loadAllSubCategoryList(
        subProvider.subCategoryParameterHolder.toMap(),
        Utils.checkUserLoginId(subProvider.psValueHolder!),
      );

      if (!mounted) return;
      setState(() {
        _loadedSubCategoryCatId = safeCategoryId;
      });
      _ensureBulkControllerDisplayText();
    } catch (_) {
    } finally {
      _isLoadingBulkSubCategories = false;
    }
  }

  Future<void> _applyBulkDefaultsIfNeeded() async {
    if (!widget.isBulkMode || _didApplyBulkDefaults) return;

    _didApplyBulkDefaults = true;

    itemEntryProvider = Provider.of<ItemEntryProvider>(context, listen: false);

    final String defaultCategoryId = _bulkDefaultText(<String>['categoryId']);
    final String defaultCategoryName = _bulkDefaultText(<String>['categoryName']);
    final String defaultSubCategoryId = _bulkDefaultText(<String>['subCategoryId']);
    final String defaultSubCategoryName = _bulkDefaultText(<String>['subCategoryName']);
    final String defaultConditionId = _bulkDefaultText(<String>['conditionId']);
    final String defaultConditionName = _bulkDefaultText(<String>['conditionName']);
    final String defaultUsageDurationId = _bulkDefaultText(<String>['usageDurationId']);
    final String defaultUsageDurationName = _bulkDefaultText(<String>['usageDurationName']);

    final String currentCategoryId = (itemEntryProvider.categoryId ?? '').trim();
    final String currentSubCategoryId = (itemEntryProvider.subCategoryId ?? '').trim();
    final String currentConditionId = (itemEntryProvider.itemConditionId ?? '').trim();
    final String currentUsageId = (itemEntryProvider.itemTypeId ?? '').trim();

    final String effectiveCategoryId = currentCategoryId.isNotEmpty ? currentCategoryId : defaultCategoryId;
    final String effectiveSubCategoryId = currentSubCategoryId.isNotEmpty ? currentSubCategoryId : defaultSubCategoryId;
    final String effectiveConditionId = currentConditionId.isNotEmpty ? currentConditionId : defaultConditionId;
    final String effectiveUsageId = currentUsageId.isNotEmpty ? currentUsageId : defaultUsageDurationId;

    if (!mounted) return;
    setState(() {
      if (currentCategoryId.isEmpty && effectiveCategoryId.isNotEmpty) {
        itemEntryProvider.categoryId = effectiveCategoryId;
      }

      if (effectiveCategoryId.isNotEmpty && (widget.categoryController?.text.trim().isEmpty ?? true)) {
        final String listName = _categoryNameFromLoadedList(effectiveCategoryId);
        widget.categoryController?.text = defaultCategoryName.isNotEmpty
            ? defaultCategoryName
            : (listName.isNotEmpty ? listName : effectiveCategoryId);
      }

      if (currentSubCategoryId.isEmpty && effectiveSubCategoryId.isNotEmpty) {
        itemEntryProvider.subCategoryId = effectiveSubCategoryId;
      }

      if (effectiveSubCategoryId.isNotEmpty && (widget.subCategoryController?.text.trim().isEmpty ?? true)) {
        final String listName = _subCategoryNameFromLoadedList(effectiveSubCategoryId);
        widget.subCategoryController?.text = defaultSubCategoryName.isNotEmpty
            ? defaultSubCategoryName
            : (listName.isNotEmpty ? listName : effectiveSubCategoryId);
      }

      if (currentConditionId.isEmpty && effectiveConditionId.isNotEmpty) {
        itemEntryProvider.itemConditionId = effectiveConditionId;
      }

      if (effectiveConditionId.isNotEmpty) {
        _selectedConditionIndex = _conditionOptions.indexWhere((_ConditionOption o) => o.id == effectiveConditionId);
        if (widget.itemConditionController?.text.trim().isEmpty ?? true) {
          widget.itemConditionController?.text = defaultConditionName.isNotEmpty
              ? defaultConditionName
              : _bulkConditionTitleFromId(effectiveConditionId);
        }
      }

      if (currentUsageId.isEmpty && effectiveUsageId.isNotEmpty) {
        itemEntryProvider.itemTypeId = effectiveUsageId;
      }

      if (effectiveUsageId.isNotEmpty && (widget.typeController?.text.trim().isEmpty ?? true)) {
        widget.typeController?.text = defaultUsageDurationName.isNotEmpty
            ? defaultUsageDurationName
            : _bulkUsageTitleFromId(effectiveUsageId);
      }
    });

    await _loadBulkSubCategoriesIfNeeded(effectiveCategoryId);
    _ensureBulkControllerDisplayText();
    _updateAllBadgeToasts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrefillLocation) return;

    itemEntryProvider = Provider.of<ItemEntryProvider>(context, listen: false);
    valueHolder = Provider.of<PsValueHolder>(context, listen: false);

    _prefillLocationFromValueHolder();
    _didPrefillLocation = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyBulkDefaultsIfNeeded();
    });
  }

  @override
  void initState() {
    super.initState();

    _prefillPackagingFromHighlightInfo();

    final String existing = (widget.userInputPrice?.text.trim().isNotEmpty == true)
        ? widget.userInputPrice!.text.trim()
        : (widget.priceTypeController?.text.trim() ?? '');

    final _ParsedRange? parsed = _parseMinMax(existing);
    if (parsed != null) {
      _selectedMinPrice = parsed.min;
      _selectedMaxPrice = parsed.max;

      _minPriceCtrl.text = parsed.min.toString();
      _maxPriceCtrl.text = parsed.max.toString();

      final int idx = _priceBands.indexWhere((b) => parsed.min >= b.min && parsed.min < b.max);
      if (idx != -1) _selectedBandIndex = idx;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncHighlightInfoJson();
      _updateAllBadgeToasts();
      _applyBulkDefaultsIfNeeded();
    });
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _showConditionPicker() async {
    final ItemEntryProvider itemEntryProvider = context.read<ItemEntryProvider>();

    final options = _conditionOptions.map((opt) {
      return TaapdeelPickerOption(
        id: opt.id,
        title: Utils.getString(context, opt.titleKey),
        subtitle: Utils.getString(context, opt.hintKey),
        emoji: opt.emoji,
      );
    }).toList();

    await showTaapdeelStandardPicker(
      context: context,
      title: 'حالة المنتج',
      options: options,
      initialSelectedIndex: _selectedConditionIndex,
      onClear: () {
        setState(() {
          _selectedConditionIndex = -1;
          itemEntryProvider.itemConditionId = '';
          widget.itemConditionController?.clear();
        });
        _updateQualityBanner();
      },
      onConfirm: (tempIndex) {
        if (tempIndex < 0 || tempIndex >= options.length) return;

        final selected = options[tempIndex];
        setState(() {
          _selectedConditionIndex = tempIndex;
          itemEntryProvider.itemConditionId = selected.id;
          widget.itemConditionController?.text = selected.title;
        });
        _updateQualityBanner();
      },
    );
  }

  Future<void> _showCategoryPicker() async {
    FocusScope.of(context).unfocus();

    final CategoryProvider catProvider = context.read<CategoryProvider>();
    final cats = catProvider.categoryList.data ?? <Category>[];

    if (cats.isEmpty) {
      final dynamic res = await Navigator.pushNamed(
        context,
        RoutePaths.searchCategory,
      );
      if (res is Category) {
        setState(() {
          itemEntryProvider.categoryId = res.catId;
          widget.categoryController?.text = res.catName ?? '';

          itemEntryProvider.subCategoryId = '';
          widget.subCategoryController?.clear();
          _loadedSubCategoryCatId = null;
        });
      }
      return;
    }

    final options = cats
        .map(
          (c) => TaapdeelPickerOption(
        id: c.catId ?? '',
        title: c.catName ?? '',
        subtitle: null,
        emoji: '📦',
      ),
    )
        .toList();

    int initialIndex = -1;
    final currentId = itemEntryProvider.categoryId ?? '';
    if (currentId.isNotEmpty) {
      initialIndex = options.indexWhere((o) => o.id == currentId);
    }

    await showTaapdeelStandardPicker(
      context: context,
      title: 'اختر الفئة',
      options: options,
      initialSelectedIndex: initialIndex,
      onClear: () {
        setState(() {
          itemEntryProvider.categoryId = '';
          widget.categoryController?.clear();

          itemEntryProvider.subCategoryId = '';
          widget.subCategoryController?.clear();
          _loadedSubCategoryCatId = null;
        });
      },
      onConfirm: (idx) async {
        if (idx < 0 || idx >= options.length) return;

        final selected = options[idx];

        setState(() {
          itemEntryProvider.categoryId = selected.id;
          widget.categoryController?.text = selected.title;

          itemEntryProvider.subCategoryId = '';
          widget.subCategoryController?.clear();
          _loadedSubCategoryCatId = null;
        });

        final SubCategoryProvider subProvider = context.read<SubCategoryProvider>();
        subProvider.subCategoryParameterHolder.catId = selected.id;
        subProvider.categoryId = selected.id;

        await subProvider.loadAllSubCategoryList(
          subProvider.subCategoryParameterHolder.toMap(),
          Utils.checkUserLoginId(subProvider.psValueHolder!),
        );

        setState(() {
          _loadedSubCategoryCatId = selected.id;
        });
      },
    );
  }

  Future<void> _showSubCategoryPicker() async {
    FocusScope.of(context).unfocus();

    final String catId = itemEntryProvider.categoryId ?? '';
    if (catId.isEmpty) {
      await _showWarning('item_entry_need_category');
      return;
    }

    final SubCategoryProvider subProvider = context.read<SubCategoryProvider>();

    if (_loadedSubCategoryCatId != catId) {
      subProvider.subCategoryParameterHolder.catId = catId;
      subProvider.categoryId = catId;

      await subProvider.loadAllSubCategoryList(
        subProvider.subCategoryParameterHolder.toMap(),
        Utils.checkUserLoginId(subProvider.psValueHolder!),
      );

      setState(() {
        _loadedSubCategoryCatId = catId;
      });
    }

    final subs = subProvider.subCategoryList.data ?? <SubCategory>[];
    if (subs.isEmpty) {
      await _showWarning('item_entry_need_subcategory');
      return;
    }

    final options = subs
        .map(
          (s) => TaapdeelPickerOption(
        id: s.id ?? '',
        title: s.name ?? '',
        subtitle: null,
        emoji: '🧩',
      ),
    )
        .toList();

    int initialIndex = -1;
    final currentId = itemEntryProvider.subCategoryId ?? '';
    if (currentId.isNotEmpty) {
      initialIndex = options.indexWhere((o) => o.id == currentId);
    }

    await showTaapdeelStandardPicker(
      context: context,
      title: 'اختر التصنيف الفرعي',
      options: options,
      initialSelectedIndex: initialIndex,
      onClear: () {
        setState(() {
          itemEntryProvider.subCategoryId = '';
          widget.subCategoryController?.clear();
        });
      },
      onConfirm: (idx) {
        if (idx < 0 || idx >= options.length) return;

        final selected = options[idx];
        setState(() {
          itemEntryProvider.subCategoryId = selected.id;
          widget.subCategoryController?.text = selected.title;
        });
      },
    );
  }

  Future<void> _showUsageDurationPicker() async {
    final selected = await showTaapdeelStandardGridPicker<_UsageDurationOption>(
      context: context,
      title: 'مدة استخدام المنتج',
      options: _usageDurationOptions,
      selectedId: itemEntryProvider.itemTypeId ?? '',
      idGetter: (o) => o.id,
      labelGetter: (o) => o.label,
      columns: 2,
      maxHeight: 340,
    );

    if (selected == null) {
      setState(() {
        itemEntryProvider.itemTypeId = '';
        widget.typeController?.clear();
      });
      return;
    }

    setState(() {
      itemEntryProvider.itemTypeId = selected.id;
      widget.typeController?.text = selected.label;
    });

    _updateAllBadgeToasts();
  }

  @override
  Widget build(BuildContext context) {
    itemEntryProvider = Provider.of<ItemEntryProvider>(context, listen: false);
    valueHolder = Provider.of<PsValueHolder>(context, listen: false);
    _ensureBulkControllerDisplayText();
    final ThemeData theme = Theme.of(context);

    if (!_didPrefillLocation) {
      _prefillLocationFromValueHolder();
      _didPrefillLocation = true;
    }

    if (widget.isBulkMode) {
      final String bulkCategoryId = (itemEntryProvider.categoryId ?? '').trim();
      if (bulkCategoryId.isNotEmpty && _loadedSubCategoryCatId != bulkCategoryId && !_isLoadingBulkSubCategories) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _loadBulkSubCategoriesIfNeeded(bulkCategoryId);
        });
      }
    }

    if (itemEntryProvider.itemConditionId != null && itemEntryProvider.itemConditionId!.isNotEmpty) {
      final int idx = _conditionOptions.indexWhere((opt) => opt.id == itemEntryProvider.itemConditionId);
      if (idx != -1) _selectedConditionIndex = idx;
    }

    final String existingUsageId = itemEntryProvider.itemTypeId ?? '';
    if ((widget.typeController?.text.isEmpty ?? true) && existingUsageId.isNotEmpty) {
      try {
        final _UsageDurationOption opt =
        _usageDurationOptions.firstWhere((_UsageDurationOption o) => o.id == existingUsageId);
        widget.typeController?.text = opt.label;
      } catch (_) {}
    }

    _latlng ??= widget.latlng ?? const LatLng(0.0, 0.0);



    final bool titleFilled = _isFilledTextCtrl(widget.userInputListingTitle);
    final bool descFilled = _isFilledTextCtrl(widget.userInputDescription);

    Widget _buildPickerCard({
      required String labelText,
      required String titleText,
      String? hintText,
      required VoidCallback onTap,
      bool hasSelection = false,
      IconData trailingIcon = Icons.keyboard_arrow_down,
      bool showTopLabel = true,
    }) {
      final ThemeData theme = Theme.of(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTopLabel) ...[
            Text(
              labelText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF16355B),
              ),
            ),
            const SizedBox(height: 8),
          ],
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasSelection ? _filledBorderColor : Colors.red.shade100,
                  width: hasSelection ? _filledBorderWidth : 1.0,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F2E57),
                          ),
                        ),
                        if (hintText != null && hintText.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            hintText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F2E57).withOpacity(0.55),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    hasSelection ? Icons.check_circle_rounded : trailingIcon,
                    color: hasSelection ? _filledBorderColor : const Color(0xFF0F2E57).withOpacity(0.75),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildConditionPickerCard() {
      final bool hasSelection = _selectedConditionIndex >= 0 && _selectedConditionIndex < _conditionOptions.length;

      String titleText = 'حالة المنتج';
      String? hintText;

      if (hasSelection) {
        final _ConditionOption current = _conditionOptions[_selectedConditionIndex];
        titleText = Utils.getString(context, current.titleKey);
        itemEntryProvider.itemConditionId = current.id;
        widget.itemConditionController?.text = titleText;
      } else {
        itemEntryProvider.itemConditionId = '';
        widget.itemConditionController?.text = '';
      }

      return _buildPickerCard(
        labelText: '${Utils.getString(context, "item_entry__item_condition")} *',
        titleText: titleText,
        hintText: hintText,
        hasSelection: hasSelection,
        onTap: _showConditionPicker,
        showTopLabel: false,
      );
    }

    Widget _buildCategoryPickerCard() {
      final bool hasSel =
          (itemEntryProvider.categoryId ?? '').isNotEmpty && (widget.categoryController?.text.trim().isNotEmpty ?? false);

      final String titleText = hasSel ? widget.categoryController!.text.trim() : 'التصنيف الرئيسي';

      return _buildPickerCard(
        labelText: '${Utils.getString(context, 'item_entry__category')} *',
        titleText: titleText,
        hasSelection: hasSel,
        onTap: () async {
          await _showCategoryPicker();
          setState(() {});
        },
        showTopLabel: false,
      );
    }

    Widget _buildSubCategoryPickerCard() {
      final bool hasSel = (itemEntryProvider.subCategoryId ?? '').isNotEmpty &&
          (widget.subCategoryController?.text.trim().isNotEmpty ?? false);

      final String catId = itemEntryProvider.categoryId ?? '';

      final String titleText =
      catId.isEmpty ? 'التصنيف الفرعيً' : (hasSel ? widget.subCategoryController!.text.trim() : 'التصنيف الفرعي');

      return _buildPickerCard(
        labelText: '${Utils.getString(context, 'item_entry__subCategory')} *',
        titleText: titleText,
        hasSelection: hasSel,
        showTopLabel: false,
        onTap: () async {
          if (catId.isEmpty) {
            await _showWarning('item_entry_need_category');
            return;
          }
          await _showSubCategoryPicker();
          setState(() {});
        },
      );
    }

    Widget _buildUsageDurationPickerCard() {
      final bool hasSelection =
          (itemEntryProvider.itemTypeId ?? '').isNotEmpty && (widget.typeController?.text.trim().isNotEmpty ?? false);

      final String titleText = hasSelection ? widget.typeController!.text.trim() : 'مدة الاستخدام';

      return _buildPickerCard(
        labelText: '${Utils.getString(context, "item_entry__duration")} *',
        titleText: titleText,
        hasSelection: hasSelection,
        showTopLabel: false,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          await _showUsageDurationPicker();
          setState(() {});
        },
      );
    }

    Widget _buildPriceMinMaxFields() {
      final ThemeData theme = Theme.of(context);
      final bool hasSelection = _selectedMinPrice != null && _selectedMaxPrice != null;

      Widget _compactField({
        required TextEditingController controller,
        required String hint,
        bool readOnly = false,
        TextInputAction? action,
        ValueChanged<String>? onChanged,
      }) {
        final bool filled = controller.text.trim().isNotEmpty;

        final BorderSide enabledSide = BorderSide(
          color: filled ? _filledBorderColor : Colors.black.withOpacity(0.06),
          width: filled ? _filledBorderWidth : 1.0,
        );

        final BorderSide focusedSide = BorderSide(
          color: filled ? _filledBorderColorFocused : const Color(0xFFB8D9FF),
          width: filled ? 1.8 : 1.3,
        );

        return Container(
          height: 42,
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: TextInputType.number,
            textInputAction: action,
            onChanged: (v) {
              if (onChanged != null) onChanged(v);
              setState(() {});
            },
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F2E57),
              height: 1.0,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: enabledSide,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: enabledSide,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: focusedSide,
              ),
            ),
          ),
        );
      }

      final bool priceBlockCompleted = hasSelection || _isFree;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: priceBlockCompleted ? _filledBorderColor : Colors.red.shade100,
                width: priceBlockCompleted ? _filledBorderWidth : 1.0,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'متوسط السعر بناء على الحالة',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F2E57),
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_isFree) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _compactField(
                          controller: _minPriceCtrl,
                          hint: 'الحد الأدنى',
                          action: TextInputAction.next,
                          onChanged: (v) {
                            final String cleaned = _digitsOnly(v);
                            if (cleaned != v) {
                              _minPriceCtrl.text = cleaned;
                              _minPriceCtrl.selection = TextSelection.fromPosition(
                                TextPosition(offset: cleaned.length),
                              );
                            }
                            _syncAutoMaxFromMin(cleaned);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _compactField(
                          controller: _maxPriceCtrl,
                          hint: 'الحد الأعلى (تلقائي)',
                          readOnly: true,
                          action: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    final List<Widget> step1Fields = <Widget>[
      const SizedBox(height: PsDimens.space10),
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: titleFilled ? _filledBorderColor : Colors.transparent,
            width: titleFilled ? _filledBorderWidth : 1.0,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TaapdeelTextField(
          controller: widget.userInputListingTitle,
          label: '${Utils.getString(context, 'item_entry__listing_title')} *',
          hint: Utils.getString(context, 'item_entry__entry_title'),
          textInputAction: TextInputAction.next,
          onChanged: (String value) {
            setState(() {});
            _autoSuggestCategory(context);
          },
        ),
      ),
      const SizedBox(height: PsDimens.space10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: descFilled ? _filledBorderColor : Colors.transparent,
            width: descFilled ? _filledBorderWidth : 1.0,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        constraints: const BoxConstraints(minHeight: 40),
        child: TaapdeelTextField(
          controller: widget.userInputDescription,
          label: '${Utils.getString(context, 'item_entry__description')} *',
          hint: Utils.getString(context, 'item_entry__description'),
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          onChanged: (_) => setState(() {}),
        ),
      ),
    ];

    final bool dynamicFilled = _hasAnyDynamicValue() || _hasBrandSelected();

    final bool step2Filled = _isFilledId(itemEntryProvider.categoryId) ||
        _isFilledId(itemEntryProvider.subCategoryId) ||
        _selectedConditionIndex != -1 ||
        (itemEntryProvider.itemTypeId ?? '').isNotEmpty ||
        _isFree ||
        (_selectedMinPrice != null && _selectedMaxPrice != null) ||
        _isImported ||
        _isWrapped ||
        _hasAnyDynamicValue() ||
        _visibilityGender != 'all';

    final List<Widget> step2Fields = <Widget>[
      _buildDetailsCard(
        title: 'بيانات تفصيلية',
        filled: step2Filled,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: _buildCategoryPickerCard()),
              const SizedBox(width: PsDimens.space8),
              Expanded(
                flex: 1,
                child: Opacity(
                  opacity: (itemEntryProvider.categoryId ?? '').trim().isEmpty ? 0.5 : 1,
                  child: IgnorePointer(
                    ignoring: (itemEntryProvider.categoryId ?? '').trim().isEmpty,
                    child: _buildSubCategoryPickerCard(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PsDimens.space8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: _buildConditionPickerCard()),
              const SizedBox(width: PsDimens.space8),
              Expanded(flex: 1, child: _buildUsageDurationPickerCard()),
            ],
          ),
          const SizedBox(height: PsDimens.space12),
          _buildPriceMinMaxFields(),
          const SizedBox(height: PsDimens.space12),
          _buildPackagingInlineSwitches(),
          const SizedBox(height: PsDimens.space12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: dynamicFilled ? _filledBorderColor : Colors.transparent,
                width: dynamicFilled ? _filledBorderWidth : 1.0,
              ),
            ),
            child: DynamicSubCategoryFields(
              subCategoryId: itemEntryProvider.subCategoryId,
              subCategoryName: widget.subCategoryController?.text,
              initialValues: {"brand": itemEntryProvider.brand},
              onChanged: (Map<String, dynamic> map) {
                setState(() {
                  _dynamicStep3Values = map;
                  _syncHighlightInfoJson();
                });
                _updateAllBadgeToasts();
              },
            ),
          ),
          const SizedBox(height: PsDimens.space12),
          _buildVisibilityCard(),
        ],
      ),
    ];

    final Widget stepBody = (widget.currentStep == 0)
        ? Column(key: const ValueKey('step1'), children: step1Fields)
        : Column(key: const ValueKey('step2'), children: step2Fields);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        final slide = Tween<Offset>(
          begin: const Offset(0.00, 0.06),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: SizeTransition(
              sizeFactor: fade,
              axisAlignment: -1,
              child: child,
            ),
          ),
        );
      },
      child: stepBody,
    );
  }

  bool _isFilledTextCtrl(TextEditingController? c) {
    return (c?.text.trim().isNotEmpty ?? false);
  }

  bool _isFilledId(String? id) {
    return (id ?? '').trim().isNotEmpty;
  }

  Widget _buildDetailsCard({
    required String title,
    required List<Widget> children,
    bool filled = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: filled ? _filledBorderColor : Colors.black.withOpacity(0.06),
          width: filled ? _filledBorderWidth : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: const Color(0xFF3167B0).withOpacity(0.95),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F2E57),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.black.withOpacity(0.06)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (widget.provider == null || valueHolder == null) return;

    final ItemEntryProvider provider = Provider.of<ItemEntryProvider>(context, listen: false);
    final PsValueHolder vh = valueHolder!;
    final String loginUserId = vh.loginUserId ?? '';

    if (loginUserId.isEmpty) {
      await _showWarning('login__login');
      return;
    }

    if (widget.userInputListingTitle == null || widget.userInputListingTitle!.text.trim().isEmpty) {
      await _showWarning('item_entry__listing_title');
      return;
    }

    if ((provider.categoryId == null || provider.categoryId!.isEmpty) ||
        widget.categoryController == null ||
        widget.categoryController!.text.trim().isEmpty) {
      await _showWarning('item_entry_need_category');
      return;
    }

    if ((provider.subCategoryId == null || provider.subCategoryId!.isEmpty) ||
        widget.subCategoryController == null ||
        widget.subCategoryController!.text.trim().isEmpty) {
      await _showWarning('item_entry_need_subcategory');
      return;
    }

    if (Utils.showUI(vh.conditionOfItemId) &&
        ((provider.itemConditionId == null || provider.itemConditionId!.isEmpty) ||
            widget.itemConditionController == null ||
            widget.itemConditionController!.text.trim().isEmpty)) {
      await _showWarning('item_entry_need_item_condition');
      return;
    }

    if (!_isFree) {
      if (_selectedMinPrice == null || _selectedMaxPrice == null) {
        await _showWarning('item_entry_need_price');
        return;
      }

      final int step = _stepForMin(_selectedMinPrice!);
      final String priceVal = widget.userInputPrice?.text.trim() ?? '';
      if (priceVal.isEmpty || (_selectedMaxPrice! - _selectedMinPrice!) != step) {
        await _showWarning('item_entry_need_price');
        return;
      }
    } else {
      widget.userInputPrice?.text = '0';
      widget.priceTypeController?.text = '0';
      widget.priceController?.text = '0';
    }

    _prefillLocationFromValueHolder();

    if ((provider.itemLocationId ?? '').trim().isEmpty) {
      await _showWarning('item_entry_need_location_township');
      return;
    }

    if (!widget.isImageSelected.contains(true) && (widget.isSelectedVideoImagePath != true)) {
      await _showWarning('item_entry_need_image');
      return;
    }

    _syncHighlightInfoJson();

    final String computedItemPriceTypeId = _isFree ? '1' : (provider.itemPriceTypeId ?? '');
    final String computedDealOptionId = _computeTierFromEarnedBadges().toString();
    final String computedBusinessMode = _isImported ? '2' : (provider.isCheckBoxSelect ? PsConst.ONE : PsConst.ZERO);

    final String userDesc = widget.userInputDescription?.text ?? '';
    final String specsText = _buildSpecsText(_dynamicStep3Values);
    final String mergedDesc = (specsText.isEmpty) ? userDesc.trim() : (userDesc.trim() + specsText);

    final String computedBrand = _extractBrandValue();

    provider.itemPriceTypeId = computedItemPriceTypeId;
    provider.itemDealOptionId = computedDealOptionId;

    final ItemEntryParameterHolder param = ItemEntryParameterHolder(
      id: widget.flag == PsConst.EDIT_ITEM ? widget.item?.id : '',
      catId: provider.categoryId ?? '',
      subCatId: provider.subCategoryId ?? '',
      itemTypeId: provider.itemTypeId ?? '',
      itemPriceTypeId: computedItemPriceTypeId,
      conditionOfItemId: provider.itemConditionId ?? '',
      price: widget.userInputPrice?.text.trim() ?? '',
      discountRate: Utils.showUI(vh.discountRateByPercentage) ? (widget.userInputDiscount?.text.trim() ?? '') : '',
      dealOptionId: computedDealOptionId,
      brand: computedBrand,
      description: mergedDesc,
      businessMode: computedBusinessMode,
      title: widget.userInputListingTitle?.text.trim() ?? '',
      address: widget.userInputAddress?.text.trim() ?? '',
      latitude: widget.userInputLattitude?.text.trim() ?? '',
      longitude: widget.userInputLongitude?.text.trim() ?? '',
      itemLocationId: provider.itemLocationId ?? '',
      itemLocationTownshipId: provider.itemLocationTownshipId ?? '',
      dealOptionRemark: _buildEarnedBadgesRemarkJson(),
      highlightInfomation: widget.userInputHighLightInformation?.text.trim() ?? '',
      addedUserId: loginUserId,
    );

    try {
      if (!PsProgressDialog.isShowing()) {
        await PsProgressDialog.showDialog(
          context,
          message: Utils.getString(context, 'progressloading_item_uploading'),
        );
      }

      final PsResource<Product> itemData = await provider.postItemEntry(
        param.toMap(),
        loginUserId,
      );

      PsProgressDialog.dismissDialog();

      if (itemData.status == PsStatus.SUCCESS && itemData.data != null) {
        provider.itemId = itemData.data!.id;

        final List<String> mergedTagsEn = _mergeTagsWithBrand(
          baseTags: List<String>.from(widget.provider?.tags_en ?? <String>[]),
          brand: computedBrand,
        );

        final List<String> mergedTagsAr = _mergeTagsWithBrand(
          baseTags: List<String>.from(widget.provider?.tags ?? <String>[]),
          brand: computedBrand,
        );

        log('computedBrand = $computedBrand');
        log('mergedTagsEn = $mergedTagsEn');
        log('mergedTagsAr = $mergedTagsAr');

        if (mergedTagsEn.isNotEmpty || mergedTagsAr.isNotEmpty) {
          final Map<String, dynamic> jsonMap = <String, dynamic>{
            'entity_type': 'item',
            'entity_id': provider.itemId,
            'source': computedBrand.isNotEmpty ? 'ai+brand' : 'ai',
            'confidence': widget.provider?.tags_confidence ?? '',
            'tags_en': mergedTagsEn,
            'tags_ar': mergedTagsAr,
          };

          try {
            await provider.postSaveTags(jsonMap);
          } catch (e) {
            log('postSaveTags skipped/failed: $e');
          }
        } else {
          log('postSaveTags skipped because tags_en and tags_ar are empty');
        }

        if (widget.uploadImage != null && provider.itemId != null) {
          // ✅ ننتظر رفع الصور يكتمل بالكامل قبل أي قرار navigation.
          // في Bulk mode: uploadImage نفسها تعمل dismissDialog + pop + postFrameCallback(onBulkItemDone)
          // في Normal mode: uploadImage تنتهي وتسيب _handleSubmit يكمل الـ sheet
          await widget.uploadImage!(provider.itemId!);
          _forceDismissItemLoadingDialog();
          if (widget.isBulkMode) return; // ← uploadImage خلصت الـ bulk flow
        } else if (widget.isBulkMode) {
          // ─── Bulk mode بدون صور (نادر جداً) ───
          // مفيش uploadImage → نعمل pop مباشرة
          // الـ pop بـ result=true هيخلي الـ Queue screen يعرف إن المنتج اتحفظ
          if (mounted) Navigator.pop(context, true);
          return;
        }

        await _showAdminApprovalSheetThenGoHome(itemData.data!);
      } else {
        await showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) => ErrorDialog(message: itemData.message),
        );
      }
    } catch (e) {
      _forceDismissItemLoadingDialog();
      await showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) => ErrorDialog(message: e.toString()),
      );
    }
  }

  Future<void> _showWarning(String messageKey) async {
    await showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) => WarningDialog(message: Utils.getString(context, messageKey)),
    );
  }

  void _scrollToCategoryIndex(int index, int totalCount) {
    const double cardWidth = 76;
    const double spacing = 12;

    final int safeIndex = index.clamp(0, totalCount - 1);
    final double targetOffset = (cardWidth + spacing) * safeIndex;

    if (_categoryScrollController.hasClients) {
      _categoryScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  String _safeText(dynamic value) => (value ?? '').toString().trim();

  bool _hasSafeText(dynamic value) {
    final String text = _safeText(value);
    return text.isNotEmpty && text.toLowerCase() != 'null';
  }

  String _normalizeCreatedShareImageUrl(dynamic rawValue) {
    String raw = _safeText(rawValue);
    if (!_hasSafeText(raw)) return '';

    if (raw.startsWith('file://') ||
        raw.startsWith('/data/') ||
        raw.startsWith('/storage/')) {
      return raw;
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final String base = _safeText(PsConfig.ps_app_image_url);
    if (!_hasSafeText(base)) return raw;

    final String cleanBase =
    base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final String cleanPath = raw.startsWith('/') ? raw.substring(1) : raw;

    return '$cleanBase/$cleanPath';
  }

  String _extractCreatedShareImagePathFromAny(dynamic source, {int depth = 0}) {
    if (source == null || depth > 3) return '';

    if (source is String) {
      final String value = _safeText(source);
      if (!_hasSafeText(value)) return '';

      final String lower = value.toLowerCase();
      final bool looksLikeImage = lower.startsWith('http://') ||
          lower.startsWith('https://') ||
          lower.startsWith('file://') ||
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp') ||
          lower.contains('/uploads/') ||
          lower.contains('uploads/');

      return looksLikeImage ? value : '';
    }

    if (source is Iterable) {
      for (final dynamic item in source) {
        final String found = _extractCreatedShareImagePathFromAny(
          item,
          depth: depth + 1,
        );
        if (_hasSafeText(found)) return found;
      }
      return '';
    }

    if (source is Map) {
      const List<String> keys = <String>[
        'img_path',
        'imgPath',
        'image_path',
        'imagePath',
        'image_url',
        'imageUrl',
        'photo_url',
        'photoUrl',
        'file_path',
        'filePath',
        'path',
        'url',
        'thumbnail',
        'thumbnail_path',
        'default_photo',
        'defaultPhoto',
        'data',
      ];

      for (final String key in keys) {
        if (!source.containsKey(key)) continue;
        final String found = _extractCreatedShareImagePathFromAny(
          source[key],
          depth: depth + 1,
        );
        if (_hasSafeText(found)) return found;
      }
      return '';
    }

    final List<dynamic Function()> readers = <dynamic Function()>[
          () => (source as dynamic).imgPath,
          () => (source as dynamic).img_path,
          () => (source as dynamic).imagePath,
          () => (source as dynamic).image_path,
          () => (source as dynamic).imageUrl,
          () => (source as dynamic).image_url,
          () => (source as dynamic).photoUrl,
          () => (source as dynamic).photo_url,
          () => (source as dynamic).filePath,
          () => (source as dynamic).file_path,
          () => (source as dynamic).path,
          () => (source as dynamic).url,
          () => (source as dynamic).thumbnail,
          () => (source as dynamic).thumbnailPath,
          () => (source as dynamic).thumbnail_path,
          () => (source as dynamic).defaultPhoto,
          () => (source as dynamic).default_photo,
          () => (source as dynamic).galleryList,
          () => (source as dynamic).galleryList?.data,
          () => (source as dynamic).galleryList?.data?.data,
          () => (source as dynamic).imageList,
          () => (source as dynamic).imageList?.data,
          () => (source as dynamic).selectedImageList,
          () => (source as dynamic).selectedImagePath,
          () => (source as dynamic).selectedImages,
          () => (source as dynamic).imagePathList,
          () => (source as dynamic).images,
          () => (source as dynamic).data,
    ];

    for (final dynamic Function() reader in readers) {
      try {
        final dynamic value = reader();
        final String found = _extractCreatedShareImagePathFromAny(
          value,
          depth: depth + 1,
        );
        if (_hasSafeText(found)) return found;
      } catch (_) {}
    }

    return '';
  }

  String _resolveCreatedProductShareImageUrl(Product product) {
    final List<dynamic> candidates = <dynamic>[
      product,
      widget.galleryProvider,
      widget.galleryProvider?.galleryList,
      widget.galleryProvider?.galleryList.data,
      widget.provider,
      widget.item,
    ];

    for (final dynamic candidate in candidates) {
      final String raw = _extractCreatedShareImagePathFromAny(candidate);
      final String normalized = _normalizeCreatedShareImageUrl(raw);
      if (_hasSafeText(normalized)) return normalized;
    }

    try {
      final String localPath = widget.localShareImagePathResolver?.call() ?? '';
      final String normalized = _normalizeCreatedShareImageUrl(localPath);
      if (_hasSafeText(normalized)) return normalized;
    } catch (_) {}

    return '';
  }

  void _openCreatedProductShareOptions(Product product) {
    if (!mounted) return;

    final String imageUrl = _resolveCreatedProductShareImageUrl(product);

    log('created product share imageUrl = $imageUrl');

    ProductShareOptions.show(
      context: context,
      product: product,
      dynamicLink: TaapdeelShareLinks.product(product.id),
      imageUrl: imageUrl,
    );
  }


  // ── طلب إذن الإشعارات — يُستدعى مرة واحدة فقط بعد أول إضافة منتج ──────────
  Future<void> _requestNotificationPermissionIfNeeded() async {
    const String _prefKey = 'noti_permission_requested_after_product';

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool alreadyRequested = prefs.getBool(_prefKey) ?? false;
      if (alreadyRequested) return; // سبق وطلبنا — لا نزعج المستخدم مرة تانية

      // علّم إننا طلبنا عشان لا نطلب مرة تانية
      await prefs.setBool(_prefKey, true);

      // Android 13+ و iOS: نطلب الـ permission
      final NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // المستخدم وافق — احفظ أحدث FCM token محليًا ليستفيد منه login/register flows.
        final String? token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          await prefs.setString('fcm_device_token', token);
          log('[FCM] Permission granted after product. Token saved.');
        }
      } else {
        log('[FCM] Permission denied or not determined.');
      }
    } catch (e) {
      log('[FCM] requestPermission error: $e');
    }
  }

  void _forceDismissItemLoadingDialog() {
    try {
      if (PsProgressDialog.isShowing()) {
        PsProgressDialog.dismissDialog();
      }
    } catch (e) {
      log('PsProgressDialog dismiss skipped: $e');
    }
  }

  Future<void> _showAdminApprovalSheetThenGoHome(Product createdProduct) async {
    if (!mounted) return;

    _forceDismissItemLoadingDialog();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _forceDismissItemLoadingDialog();

    // ── طلب إذن الإشعارات (مرة واحدة فقط) ──────────────────────────────────
    unawaited(_requestNotificationPermissionIfNeeded());

    // ─── Bulk mode يجب أن لا يصل هنا أبداً ───
    // المسار الصح في Bulk: uploadImage → postFrameCallback(onBulkItemDone) → pop
    if (widget.isBulkMode) return;

    // ─── Normal mode: نفتح الـ bottom sheet ───
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext ctx) {
        final ThemeData theme = Theme.of(ctx);

        Future<void> closeAndGoHome() async {
          final String createdItemId =
          (createdProduct.id ?? widget.provider?.itemId ?? '').trim();

          // Close only the approval bottom sheet first.
          if (Navigator.of(ctx, rootNavigator: true).canPop()) {
            Navigator.of(ctx, rootNavigator: true).pop();
          }

          await Future<void>.delayed(const Duration(milliseconds: 90));
          if (!mounted) return;

          // When ItemEntryView is hosted inside Dashboard tab body, popping routes is
          // not enough because the upload screen is not a pushed route. The dashboard
          // callback changes the selected tab and leaves the entry flow correctly.
          _forceDismissItemLoadingDialog();

          if (widget.onItemUploaded != null && createdItemId.isNotEmpty) {
            widget.onItemUploaded!(createdItemId);
            await Future<void>.delayed(const Duration(milliseconds: 80));
            _forceDismissItemLoadingDialog();
            return;
          }

          // Fallback for cases where ItemEntryView is opened as a pushed route.
          Navigator.of(context, rootNavigator: true).popUntil(
                (Route<dynamic> route) => route.isFirst,
          );
        }

        return TaapdeelGlassBottomSheet(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF065F46),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'سيتم نشر المنتج بعد موافقة الأدمن 🎉',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'شارك المنتج بتصميم جذاب لزيادة فرص التبديل.\nوللحصول على تبديلات أفضل أضف منتجات تتمناها.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(0.65),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TaapdeelButton(
                  label: 'شارك المنتج بتصميم جذاب',
                  isPrimary: true,
                  isExpanded: true,
                  onPressed: () async {
                    await closeAndGoHome();
                    await Future<void>.delayed(const Duration(milliseconds: 120));
                    if (!mounted) return;
                    _openCreatedProductShareOptions(createdProduct);
                  },
                ),
                const SizedBox(height: 12),
                TaapdeelButton(
                  label: 'إغلاق',
                  isPrimary: false,
                  isExpanded: true,
                  onPressed: () async => closeAndGoHome(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _autoSuggestCategory(BuildContext context) async {
    if (widget.isBulkMode) return;
    final String title = widget.userInputListingTitle?.text.trim() ?? '';
    if (title.length < 3) return;

    final TaapdeelCategoryMatch? match = TaapdeelCategoryRules.suggestFromTitle(title);
    if (match == null) return;

    final ItemEntryProvider itemProvider = Provider.of<ItemEntryProvider>(context, listen: false);
    final CategoryProvider catProvider = Provider.of<CategoryProvider>(context, listen: false);
    final SubCategoryProvider subCatProvider = Provider.of<SubCategoryProvider>(context, listen: false);

    final List<Category> categories = catProvider.categoryList.data ?? <Category>[];
    if (categories.isEmpty) return;

    final String normalizedTarget = match.categoryName.trim();

    Category? cat;
    try {
      cat = categories.firstWhere((Category c) => (c.catName ?? '').trim() == normalizedTarget);
    } catch (_) {
      return;
    }

    itemProvider.categoryId = cat.catId;
    widget.categoryController?.text = cat.catName ?? '';

    subCatProvider.subCategoryParameterHolder.catId = cat.catId;
    subCatProvider.categoryId = cat.catId!;

    await subCatProvider.loadAllSubCategoryList(
      subCatProvider.subCategoryParameterHolder.toMap(),
      Utils.checkUserLoginId(subCatProvider.psValueHolder!),
    );

    final String? wantedSub = match.subCategoryName?.trim();
    if (wantedSub != null && wantedSub.isNotEmpty) {
      final List<SubCategory> subList = subCatProvider.subCategoryList.data ?? <SubCategory>[];

      String norm(String? v) => (v ?? '').trim().toLowerCase();

      try {
        final SubCategory sub = subList.firstWhere(
              (SubCategory s) => norm(s.name) == norm(wantedSub) && s.catId == cat!.catId,
        );

        itemProvider.subCategoryId = sub.id;
        widget.subCategoryController?.text = sub.name ?? '';
      } catch (_) {
        itemProvider.subCategoryId = '';
        widget.subCategoryController?.text = '';
      }
    } else {
      itemProvider.subCategoryId = '';
      widget.subCategoryController?.text = '';
    }

    final int selectedIndex = categories.indexWhere((Category c) => c.catId == cat!.catId);
    if (selectedIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCategoryIndex(selectedIndex, categories.length);
      });
    }

    setState(() {
      _autoCategoryHintVisible = true;
      _loadedSubCategoryCatId = cat!.catId;
    });
  }

  Future<void> _goToProfileTabFromDashboard(BuildContext context) async {
    bool done = false;

    context.visitAncestorElements((Element element) {
      if (element is StatefulElement) {
        final dynamic st = element.state;

        try {
          (st as dynamic).goToProfileTab();
          done = true;
          return false;
        } catch (_) {}

        try {
          (st as dynamic).goToBottomTab(4);
          done = true;
          return false;
        } catch (_) {}
      }
      return true;
    });

    if (done) return;

    try {
      Navigator.pushNamed(context, RoutePaths.profile_container);
    } catch (_) {}
  }

  _ParsedRange? _parseMinMax(String input) {
    final String raw = input.trim();
    if (raw.isEmpty) return null;
    if (!raw.contains('-')) return null;

    final List<String> parts = raw.split('-');
    if (parts.length < 2) return null;

    final int? min = int.tryParse(parts[0].trim());
    final int? max = int.tryParse(parts[1].trim());
    if (min == null || max == null) return null;

    return _ParsedRange(min: min, max: max);
  }
}

class _ParsedRange {
  final int min;
  final int max;
  const _ParsedRange({required this.min, required this.max});
}

class _PriceBand {
  final String label;
  final int min;
  final int max;
  const _PriceBand({required this.label, required this.min, required this.max});
}

class _ConditionOption {
  final String id;
  final String emoji;
  final String titleKey;
  final String hintKey;

  const _ConditionOption({
    required this.id,
    required this.emoji,
    required this.titleKey,
    required this.hintKey,
  });
}

class _UsageDurationOption {
  final String id;
  final String label;

  const _UsageDurationOption({required this.id, required this.label});
}