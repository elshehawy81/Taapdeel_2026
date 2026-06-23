import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/category/category_provider.dart';
import 'package:taapdeel/provider/gallery/gallery_provider.dart';
import 'package:taapdeel/provider/subcategory/sub_category_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/category_repository.dart';
import 'package:taapdeel/repository/gallery_repository.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/repository/sub_category_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/base/ps_widget_with_multi_provider.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/dialog/in_app_purchase_for_package_dialog.dart';
import 'package:taapdeel/ui/common/dialog/retry_dialog_view.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';
import 'package:taapdeel/ui/item/entry/widgets/all_controller_text_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/default_photo.dart';
import 'package:taapdeel/viewobject/holder/image_reorder_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../provider/entry/item_entry_provider.dart';
import '../../../utils/ps_progress_dialog.dart';
import '../bulk_entry/bulk_item_data.dart';
import '../bulk_entry/bulk_item_defaults.dart';
import 'widgets/orbit_tags_around.dart';
import 'widgets/image_upload_horizontal_list.dart';
import 'package:taapdeel/ui/category/taapdeel_category_rules.dart';

class ItemEntryViewBase extends StatefulWidget {
  const ItemEntryViewBase({
    Key? key,
    this.flag,
    this.item,
    required this.animationController,
    this.onItemUploaded,
    required this.maxImageCount,
    this.bulkItemData,
    this.bulkDefaults,
    this.onBulkItemDone,
  }) : super(key: key);

  final AnimationController? animationController;
  final String? flag;
  final Product? item;
  final ValueChanged<String>? onItemUploaded;
  final int maxImageCount;
  final BulkItemData? bulkItemData;
  final BulkItemDefaults? bulkDefaults;
  final VoidCallback? onBulkItemDone;

  @override
  State<StatefulWidget> createState() => _ItemEntryViewBaseState();
}

class _ItemEntryViewBaseState extends State<ItemEntryViewBase>
    with SingleTickerProviderStateMixin {
  ProductRepository? repo1;
  GalleryRepository? galleryRepository;
  ItemEntryProvider? _itemEntryProvider;
  GalleryProvider? galleryProvider;
  UserProvider? userProvider;
  UserRepository? userRepository;
  CategoryRepository? categoryRepository;
  SubCategoryRepository? subCategoryRepository;
  PsValueHolder? valueHolder;

  final GlobalKey<AllControllerTextWidgetState> _formKey =
  GlobalKey<AllControllerTextWidgetState>();

  // ── Controllers ────────────────────────────────────────────────────────────
  final TextEditingController userInputListingTitle = TextEditingController();
  final TextEditingController userInputHighLightInformation =
  TextEditingController();
  final TextEditingController userInputDescription = TextEditingController();
  final TextEditingController userInputDealOptionText = TextEditingController();
  final TextEditingController userInputLattitude = TextEditingController();
  final TextEditingController userInputLongitude = TextEditingController();
  final TextEditingController userInputAddress = TextEditingController();
  final TextEditingController userInputPrice = TextEditingController();
  final TextEditingController userInputDiscount = TextEditingController();
  final MapController mapController = MapController();


  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController itemConditionController = TextEditingController();
  final TextEditingController priceTypeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController dealOptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController locationTownshipController =
  TextEditingController();
  final TextEditingController featuredNameController = TextEditingController();
  bool isFeaturedProduct = false;

  late LatLng latlng;
  final double zoom = 16;

  bool bindDataFirstTime = true;
  bool bindImageFirstTime = true;

  bool isSelectedVideoImagePath = false;
  List<XFile> images = <XFile>[];
  late List<bool> isImageSelected;
  late List<XFile?> galleryImageAsset;
  late List<String?> cameraImagePath;
  late List<DefaultPhoto?> uploadedImages;

  String? videoFilePath;
  String? selectedVideoImagePath;
  String? videoFileThumbnailPath;
  String? selectedVideoPath;
  XFile? defaultAssetImage;

  String isShopCheckbox = '1';

  bool _didRunBulkAiSuggestion = false;
  bool _bulkAiSuggestionInProgress = false;

  int _currentStep = 0;
  bool _isSubmitting = false;

  // ── AI scanning state ──────────────────────────────────────────────────────
  /// true لما الـ AI request شغال — يُمرَّر لـ ImageUploadHorizontalList
  bool _isAiScanning = false;

  // ── Image slots ───────────────────────────────────────────────────────────
  // في مسار إضافة منتج واحد لا نعتمد على maxImageCount القادم من caller فقط؛
  // بعض المسارات كانت ترسله = 1، فكانت الصورة الأولى فقط تظهر وتُرفع.
  // نترك الـ bulk كما هو، ونضمن في الإضافة العادية وجود عدة slots للصور.
  static const int _normalMinImageSlots = 5;

  int _resolvedImageSlotCount([PsValueHolder? holder]) {
    final int holderMax = holder?.maxImageCount ?? 0;
    final int configuredMax = math.max(widget.maxImageCount, holderMax);

    if (widget.bulkItemData != null) {
      return math.max(1, configuredMax);
    }

    return math.max(_normalMinImageSlots, configuredMax);
  }

  int get _imageSlotCount => galleryImageAsset.length;

  void _ensureImageSlotCapacity([int? desiredCount]) {
    final int desired = desiredCount ?? _resolvedImageSlotCount(valueHolder);
    if (desired <= 0 || galleryImageAsset.length >= desired) return;

    final int extra = desired - galleryImageAsset.length;
    isImageSelected.addAll(List<bool>.filled(extra, false));
    galleryImageAsset.addAll(List<XFile?>.filled(extra, null));
    cameraImagePath.addAll(List<String?>.filled(extra, null));
    uploadedImages.addAll(
      List<DefaultPhoto?>.generate(
        extra,
            (_) => DefaultPhoto(imgId: '', imgPath: ''),
      ),
    );
  }

  // ── Badges ─────────────────────────────────────────────────────────────────
  int _badgesCount = 0;
  bool _pulseBadges = false;
  bool _shakeBadges = false;
  List<TaapdeelBadgeStatus> _badges = <TaapdeelBadgeStatus>[];

  // ── Upload dialog ──────────────────────────────────────────────────────────
  final ValueNotifier<String> _uploadMsg = ValueNotifier<String>('');
  bool _uploadDialogOpen = false;
  bool _uploadDialogDismissing = false;
  BuildContext? _uploadDialogContext;

  void _showUploadDialog(String msg) {
    if (!mounted) return;
    _uploadMsg.value = msg;
    if (_uploadDialogOpen) return;

    _uploadDialogOpen = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext ctx) {
        _uploadDialogContext = ctx;
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: _uploadMsg,
                      builder: (_, String v, __) {
                        return Text(
                          v,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _uploadDialogOpen = false;
      _uploadDialogContext = null;
      _uploadDialogDismissing = false;
    });
  }

  void _updateUploadDialog(String msg) {
    _uploadMsg.value = msg;
  }

  bool _isContextMounted(BuildContext context) {
    return context is Element && context.mounted;
  }

  Future<void> _dismissUploadDialog() async {
    if (_uploadDialogDismissing) return;
    if (!_uploadDialogOpen) return;

    _uploadDialogDismissing = true;

    try {
      // Important: close only the upload dialog route.
      // Do not use rootNavigator here, because if the dialog has already been
      // removed, rootNavigator.pop() may close the item-entry page itself and
      // leave another progress dialog stuck over the app.
      BuildContext? dialogContext = _uploadDialogContext;

      // showDialog may need a frame before its builder gives us dialogContext.
      // Without this guard, a very fast upload/error path can mark the dialog as
      // closed while the route appears afterwards and remains stuck on screen.
      for (int i = 0; i < 6 && dialogContext == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        dialogContext = _uploadDialogContext;
      }

      if (dialogContext != null && _isContextMounted(dialogContext)) {
        final NavigatorState dialogNavigator = Navigator.of(dialogContext);
        if (dialogNavigator.canPop()) {
          dialogNavigator.pop();
        }
      }
    } catch (e) {
      debugPrint('Upload dialog dismiss skipped: $e');
    }

    _uploadDialogOpen = false;
    _uploadDialogContext = null;

    await Future<void>.delayed(const Duration(milliseconds: 80));
    _uploadDialogDismissing = false;
  }



  @override
  void initState() {
    super.initState();

    final int initialImageSlotCount = _resolvedImageSlotCount();

    isImageSelected = List<bool>.generate(
      initialImageSlotCount,
          (int index) => false,
    );
    galleryImageAsset = List<XFile?>.generate(
      initialImageSlotCount,
          (int index) => null,
    );
    cameraImagePath = List<String?>.generate(
      initialImageSlotCount,
          (int index) => null,
    );
    uploadedImages = List<DefaultPhoto?>.generate(
      initialImageSlotCount,
          (int index) => DefaultPhoto(imgId: '', imgPath: ''),
    );

    featuredNameController.text = '';
    _applyBulkPrefill();

    if (widget.bulkItemData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final String currentTitle = userInputListingTitle.text;
        if (currentTitle.isNotEmpty) {
          userInputListingTitle.notifyListeners();
        }
      });
    }
  }

  void _applyBulkPrefill() {
    final BulkItemData? data = widget.bulkItemData;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyDefaultsToProvider();
      _applyBulkMetadataToProvider();
    });

    if (data == null) return;

    if (data.title.isNotEmpty && userInputListingTitle.text.trim().isEmpty) {
      userInputListingTitle.text = data.title;
    }
    if (data.description != null &&
        data.description!.isNotEmpty &&
        userInputDescription.text.trim().isEmpty) {
      userInputDescription.text = data.description!;
    }
    if ((data.categoryHint ?? '').trim().isNotEmpty &&
        categoryController.text.trim().isEmpty) {
      categoryController.text = data.categoryHint!.trim();
    }
    if ((data.subCategoryHint ?? '').trim().isNotEmpty &&
        subCategoryController.text.trim().isEmpty) {
      subCategoryController.text = data.subCategoryHint!.trim();
    }
    if ((data.averagePrice ?? '').trim().isNotEmpty &&
        userInputPrice.text.trim().isEmpty) {
      userInputPrice.text = data.averagePrice!.trim();
      priceController.text = data.averagePrice!.trim();
      priceTypeController.text = data.averagePrice!.trim();
    }
    if (data.croppedImagePath != null && data.croppedImagePath!.isNotEmpty) {
      final XFile croppedFile = XFile(data.croppedImagePath!);
      galleryImageAsset[0] = croppedFile;
      isImageSelected[0] = true;
      images = <XFile>[croppedFile];
    }
  }

  void _applyDefaultsToProvider() {
    if (!mounted) return;
    final BulkItemDefaults? defs = widget.bulkDefaults;
    if (defs == null) return;

    if (defs.conditionId.isNotEmpty && itemConditionController.text.isEmpty) {
      itemConditionController.text = defs.conditionName;
    }
    if (defs.usageDurationId.isNotEmpty && typeController.text.isEmpty) {
      typeController.text = defs.usageDurationName;
    }
    if ((defs.categoryId ?? '').isNotEmpty && categoryController.text.isEmpty) {
      categoryController.text = defs.categoryName ?? '';
    }
    if ((defs.subCategoryId ?? '').isNotEmpty &&
        subCategoryController.text.isEmpty) {
      subCategoryController.text = defs.subCategoryName ?? '';
    }

    if (mounted) setState(() {});
  }

  bool _hasText(String? value) => (value ?? '').trim().isNotEmpty;

  bool _hasAnyAiTags() {
    final ItemEntryProvider? provider = _itemEntryProvider;
    if (provider == null) return false;

    return (provider.tags ?? <String>[]).isNotEmpty ||
        (provider.tags_en ?? <String>[]).isNotEmpty ||
        ((provider.tags_confidence ?? '').trim().isNotEmpty);
  }

  bool _hasCategoryAndSubCategorySelection() {
    final ItemEntryProvider? provider = _itemEntryProvider;
    if (provider == null) return false;

    return _hasText(provider.categoryId) && _hasText(provider.subCategoryId);
  }

  bool _bulkItemHasTags() {
    final BulkItemData? data = widget.bulkItemData;
    if (data == null) return false;

    return (data.tagsAr ?? <String>[]).isNotEmpty ||
        (data.tagsEn ?? <String>[]).isNotEmpty ||
        ((data.tagsConfidence ?? '').trim().isNotEmpty);
  }

  bool _bulkItemHasCategoryAndSubCategory() {
    final BulkItemData? data = widget.bulkItemData;
    if (data == null) return false;

    return _hasText(data.categoryId) && _hasText(data.subCategoryId);
  }

  void _applyBulkMetadataToProvider() {
    if (_itemEntryProvider == null) return;
    final BulkItemData? data = widget.bulkItemData;
    if (data == null) return;

    if (_hasText(data.categoryId) && !_hasText(_itemEntryProvider!.categoryId)) {
      _itemEntryProvider!.categoryId = data.categoryId!.trim();
    }
    if (_hasText(data.subCategoryId) && !_hasText(_itemEntryProvider!.subCategoryId)) {
      _itemEntryProvider!.subCategoryId = data.subCategoryId!.trim();
    }
    if (_hasText(data.averagePrice) && !_hasText(_itemEntryProvider!.avgPrice)) {
      _itemEntryProvider!.avgPrice = data.averagePrice!.trim();
    }
    if (_hasText(data.brandHint) && !_hasText(_itemEntryProvider!.brand)) {
      _itemEntryProvider!.brand = data.brandHint!.trim();
    }

    if (_bulkItemHasTags()) {
      _itemEntryProvider!.tags = List<String>.from(data.tagsAr ?? <String>[]);
      _itemEntryProvider!.tags_en = List<String>.from(data.tagsEn ?? <String>[]);
      _itemEntryProvider!.tags_confidence = data.tagsConfidence ?? '';
    }
  }

  void _applyBulkTagsToProvider() {
    _applyBulkMetadataToProvider();
  }

  Future<void> _runBulkAiSuggestionIfNeeded() async {
    if (!mounted) return;
    if (widget.bulkItemData == null) return;
    if (_itemEntryProvider == null) return;

    // استخدم ميتاداتا الـ Bulk AI أولاً.
    // لا نشغّل Individual AI إلا لو التصنيف/التصنيف الفرعي أو التاجز ناقصين.
    _applyBulkMetadataToProvider();

    if (_didRunBulkAiSuggestion || _bulkAiSuggestionInProgress) return;
    if (_hasAnyAiTags() && _hasCategoryAndSubCategorySelection()) return;

    final String croppedPath =
        widget.bulkItemData?.croppedImagePath?.trim() ?? '';
    if (croppedPath.isEmpty) return;

    final File croppedFile = File(croppedPath);
    if (!croppedFile.existsSync()) return;

    _didRunBulkAiSuggestion = true;
    _bulkAiSuggestionInProgress = true;

    // ✅ بدأ الـ scan
    if (mounted) setState(() => _isAiScanning = true);

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('جاري تحليل صورة المنتج بالذكاء الاصطناعي…'),
        duration: Duration(days: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final apiResponse =
      await _itemEntryProvider!.getAiSuggestion(croppedFile);

      if (!mounted) return;
      messenger.hideCurrentSnackBar();

      if (apiResponse.success) {
        final dynamic productInfo = apiResponse.productInfo;
        if (productInfo is Map) {
          _applyAiSuggestionToCurrentItem(productInfo);

          messenger.showSnackBar(
            const SnackBar(
              content: Text('تم إضافة التصنيفات والتاجز بالذكاء الاصطناعي ✅'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('تم تجهيز الصورة، يرجى مراجعة بيانات المنتج'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم تجهيز الصورة، يرجى استكمال بيانات المنتج'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log('Bulk AI suggestion failed silently: $e');

      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('تم تجهيز الصورة، يرجى استكمال بيانات المنتج'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _bulkAiSuggestionInProgress = false;
      // ✅ خلص الـ scan
      if (mounted) setState(() => _isAiScanning = false);
    }
  }

  void _applyAiSuggestionToCurrentItem(Map<dynamic, dynamic> productInfo) {
    if (!mounted || _itemEntryProvider == null) return;

    final String aiTitle =
    (productInfo["title"]?["ar"] ?? '').toString().trim();
    final String aiDescription = (productInfo["short_description"]?["ar"] ??
        productInfo["description"]?["ar"] ??
        '')
        .toString()
        .trim();
    final String aiCategoryName =
    (productInfo["category"]?["ar"] ?? '').toString().trim();
    final String aiSubCategoryName =
    (productInfo["subcategory"]?["ar"] ?? '').toString().trim();
    final String aiBrand =
    (productInfo["brand"]?["value"] ?? '').toString().trim();

    setState(() {
      final String aiCategoryId =
          productInfo["category"]?["cat_id"]?.toString().trim() ?? '';
      final String aiSubCategoryId =
          productInfo["subcategory"]?["sub_cat_id"]?.toString().trim() ?? '';
      final String aiAveragePrice =
          productInfo["average_price"]?["value"]?.toString().trim() ?? '';

      if (aiCategoryId.isNotEmpty && !_hasText(_itemEntryProvider!.categoryId)) {
        _itemEntryProvider!.categoryId = aiCategoryId;
      }
      if (aiSubCategoryId.isNotEmpty && !_hasText(_itemEntryProvider!.subCategoryId)) {
        _itemEntryProvider!.subCategoryId = aiSubCategoryId;
      }
      if (aiAveragePrice.isNotEmpty && !_hasText(_itemEntryProvider!.avgPrice)) {
        _itemEntryProvider!.avgPrice = aiAveragePrice;
      }

      _itemEntryProvider!.tags =
      List<String>.from(productInfo["tags"]?["ar"] ?? <String>[]);
      _itemEntryProvider!.tags_en =
      List<String>.from(productInfo["tags"]?["en"] ?? <String>[]);
      _itemEntryProvider!.tags_confidence =
          productInfo["tags"]?["confidence"]?.toString() ?? "";
      if (aiBrand.isNotEmpty && !_hasText(_itemEntryProvider!.brand)) {
        _itemEntryProvider!.brand = aiBrand;
      }

      final bool isBulk = widget.bulkItemData != null;

      // في bulk mode: لا نستبدل بيانات Bulk AI الأساسية إلا لو الحقول فاضية.
      // في normal mode: السلوك القديم كما هو.
      if (aiTitle.isNotEmpty &&
          (!isBulk || userInputListingTitle.text.trim().isEmpty)) {
        userInputListingTitle.text = aiTitle;
      }
      if (aiDescription.isNotEmpty &&
          (!isBulk || userInputDescription.text.trim().isEmpty)) {
        userInputDescription.text = aiDescription;
      }
      if (aiCategoryName.isNotEmpty &&
          (!isBulk || categoryController.text.trim().isEmpty)) {
        categoryController.text = aiCategoryName;
      }
      if (aiSubCategoryName.isNotEmpty &&
          (!isBulk || subCategoryController.text.trim().isEmpty)) {
        subCategoryController.text = aiSubCategoryName;
      }
    });

    if (userInputListingTitle.text.trim().isNotEmpty) {
      userInputListingTitle.notifyListeners();
    }
  }

  void _triggerCategoryFromHint(
      String categoryHint, String? subCategoryHint) {
    if (!mounted) return;

    final String title = userInputListingTitle.text;
    if (title.isNotEmpty) {
      final TaapdeelCategoryMatch? match =
      TaapdeelCategoryRules.suggestFromTitle(title);
      if (match != null) {
        categoryController.text = match.categoryName;
        if (match.subCategoryName != null) {
          subCategoryController.text = match.subCategoryName!;
        }
      } else {
        categoryController.text = categoryHint;
        if (subCategoryHint != null && subCategoryHint.isNotEmpty) {
          subCategoryController.text = subCategoryHint;
        }
      }
    } else {
      categoryController.text = categoryHint;
      if (subCategoryHint != null && subCategoryHint.isNotEmpty) {
        subCategoryController.text = subCategoryHint;
      }
    }

    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) userInputListingTitle.notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    userInputListingTitle.dispose();
    userInputHighLightInformation.dispose();
    userInputDescription.dispose();
    userInputDealOptionText.dispose();
    userInputLattitude.dispose();
    userInputLongitude.dispose();
    userInputAddress.dispose();
    userInputPrice.dispose();
    userInputDiscount.dispose();

    categoryController.dispose();
    subCategoryController.dispose();
    typeController.dispose();
    itemConditionController.dispose();
    priceTypeController.dispose();
    priceController.dispose();
    dealOptionController.dispose();
    locationController.dispose();
    locationTownshipController.dispose();
    featuredNameController.dispose();

    _uploadMsg.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step.clamp(0, 1);
    });
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitItem() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await _formKey.currentState?.submit();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _firstLocalShareImagePath() {
    for (final XFile? file in galleryImageAsset) {
      final String path = file?.path.trim() ?? '';
      if (path.isNotEmpty) return path;
    }
    for (final String? path in cameraImagePath) {
      final String clean = path?.trim() ?? '';
      if (clean.isNotEmpty) return clean;
    }
    final String defaultPath = defaultAssetImage?.path.trim() ?? '';
    if (defaultPath.isNotEmpty) return defaultPath;
    final String videoThumb = videoFileThumbnailPath?.trim() ?? '';
    if (videoThumb.isNotEmpty) return videoThumb;
    final String selectedVideoThumb = selectedVideoImagePath?.trim() ?? '';
    if (selectedVideoThumb.isNotEmpty) return selectedVideoThumb;
    return '';
  }


  bool _hasAnyProductMedia() {
    if (isSelectedVideoImagePath) return true;

    for (int i = 0; i < _imageSlotCount; i++) {
      if (i < galleryImageAsset.length && galleryImageAsset[i] != null) {
        final String path = galleryImageAsset[i]!.path.trim();
        if (path.isNotEmpty) return true;
      }

      if (i < cameraImagePath.length) {
        final String path = cameraImagePath[i]?.trim() ?? '';
        if (path.isNotEmpty) return true;
      }

      if (i < uploadedImages.length) {
        final String imgId = uploadedImages[i]?.imgId?.trim() ?? '';
        final String imgPath = uploadedImages[i]?.imgPath?.trim() ?? '';
        if (imgId.isNotEmpty || imgPath.isNotEmpty) return true;
      }

      if (i < isImageSelected.length && isImageSelected[i]) return true;
    }

    return false;
  }

  // ── Badges callbacks ───────────────────────────────────────────────────────

  void _onBadgesChanged(int count, List<TaapdeelBadgeStatus> list) {
    if (!mounted) return;

    final bool increased = count > _badgesCount;

    setState(() {
      _badgesCount = count;
      _badges = list;
      if (increased) {
        _pulseBadges = true;
        _shakeBadges = true;
      }
    });

    if (increased) {
      Future.delayed(const Duration(milliseconds: 420), () {
        if (!mounted) return;
        setState(() => _pulseBadges = false);
      });
      Future.delayed(const Duration(milliseconds: 520), () {
        if (!mounted) return;
        setState(() => _shakeBadges = false);
      });
    }
  }

  void _openBadgesSheet() {
    if (_badgesCount == 0) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);

        final List<TaapdeelBadgeStatus> earned =
        _badges.where((e) => e.earned).toList();
        final List<TaapdeelBadgeStatus> locked =
        _badges.where((e) => !e.earned).toList();

        Widget buildRow(TaapdeelBadgeStatus b, {required bool earned}) {
          final Color iconBg = earned
              ? const Color(0xFF3167B0).withOpacity(0.12)
              : Colors.black.withOpacity(0.05);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: earned
                    ? const Color(0xFF3167B0).withOpacity(0.25)
                    : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    b.icon,
                    color: earned
                        ? const Color(0xFF3167B0)
                        : Colors.black.withOpacity(0.35),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        b.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: earned
                              ? const Color(0xFF0F2E57)
                              : Colors.black.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        earned ? (b.earnedHint ?? '') : (b.lockedHint ?? ''),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black.withOpacity(0.55),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: earned
                        ? const Color(0xFF2ECC71).withOpacity(0.12)
                        : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: earned
                          ? const Color(0xFF2ECC71).withOpacity(0.22)
                          : Colors.black.withOpacity(0.06),
                    ),
                  ),
                  child: Text(
                    earned ? 'مكتسبة' : 'مقفولة',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: earned
                          ? const Color(0xFF1E9E57)
                          : Colors.black.withOpacity(0.55),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.62),
                    borderRadius: BorderRadius.circular(26),
                    border:
                    Border.all(color: Colors.white.withOpacity(0.75)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Text(
                            'Badges',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F2E57),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3167B0).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFF3167B0).withOpacity(0.18),
                              ),
                            ),
                            child: Text(
                              '$_badgesCount',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF3167B0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                          MediaQuery.of(context).size.height * 0.62,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (earned.isNotEmpty) ...<Widget>[
                                Text(
                                  'المكتسبة',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F2E57),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                for (final TaapdeelBadgeStatus b in earned)
                                  buildRow(b, earned: true),
                                const SizedBox(height: 6),
                              ],
                              Text(
                                'المقفولة',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F2E57),
                                ),
                              ),
                              const SizedBox(height: 10),
                              for (final TaapdeelBadgeStatus b in locked)
                                buildRow(b, earned: false),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TaapdeelButton(
                        label: 'إغلاق',
                        isPrimary: true,
                        isExpanded: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Bottom actions ─────────────────────────────────────────────────────────

  Widget _buildBottomActions() {
    final bool isBulkMode = widget.bulkItemData != null;

    if (_currentStep == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          PsDimens.space16,
          0,
          PsDimens.space16,
          PsDimens.space8,
        ),
        child: TaapdeelButton(
          label: 'التالي',
          onPressed: _nextStep,
          isPrimary: true,
          isExpanded: true,
        ),
      );
    }

    final String submitLabel = _isSubmitting
        ? (isBulkMode
            ? 'جاري الحفظ...'
            : (widget.flag == PsConst.EDIT_ITEM
                ? 'جاري حفظ التعديل...'
                : 'جاري إضافة المنتج...'))
        : (isBulkMode
            ? 'حفظ والتالي ›'
            : (widget.flag == PsConst.EDIT_ITEM
                ? 'حفظ التعديل'
                : 'إضافة المنتج'));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PsDimens.space16,
        0,
        PsDimens.space16,
        PsDimens.space8,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Opacity(
              opacity: _isSubmitting ? 0.55 : 1,
              child: IgnorePointer(
                ignoring: _isSubmitting,
                child: TaapdeelButton(
                  label: 'السابق',
                  onPressed: _previousStep,
                  isPrimary: false,
                  outlined: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: PsDimens.space8),
          Expanded(
            flex: 2,
            child: Opacity(
              opacity: _isSubmitting ? 0.78 : 1,
              child: IgnorePointer(
                ignoring: _isSubmitting,
                child: TaapdeelButton(
                  label: submitLabel,
                  onPressed: _submitItem,
                  isPrimary: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating badge chip ────────────────────────────────────────────────────

  Widget _buildFloatingCornerBadge() {
    if (_badgesCount <= 0) return const SizedBox.shrink();

    final BadgeTier tier = _tierFromBadges(_badgesCount);
    final _BadgeTierTheme t = _themeForTier(tier);

    Widget chip = AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      scale: _pulseBadges ? 1.06 : 1.0,
      child: GestureDetector(
        onTap: _openBadgesSheet,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: t.glassGradient,
                ),
                border: Border.all(color: t.glassBorder, width: 1.2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: t.glow,
                    blurRadius: 6,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withOpacity(0.34),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.46)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          t.title,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.4,
                            color: t.textColor,
                          ),
                        ),
                        if (_badgesCount > 0) ...<Widget>[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.star_rounded,
                                  size: 20,
                                  color: Color(0xFFE0A100),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$_badgesCount',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFE0A100),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (_shakeBadges) {
      chip = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double tt, Widget? child) {
          final double dx =
          (tt < 1) ? (4.5 * (1 - tt) * math.sin(tt * 12)) : 0;
          return Transform.translate(
              offset: Offset(dx, 0), child: child);
        },
        child: chip,
      );
    }

    return chip;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    Utils.psPrint(
      '............................Build UI Again ............................',
    );
    valueHolder = Provider.of<PsValueHolder>(context);
    _ensureImageSlotCapacity(_resolvedImageSlotCount(valueHolder));

    void showRetryDialog(String description, Function uploadImageFn) {
      unawaited(_dismissUploadDialog());

      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return RetryDialogView(
            description: description,
            rightButtonText:
            Utils.getString(context, 'item_entry__retry'),
            onAgreeTap: () {
              Navigator.pop(context);
              uploadImageFn();
            },
          );
        },
      );
    }

    Future<bool> uploadImage(String itemId) async {
      final List<ImageReorderParameterHolder> reorderObjList =
      <ImageReorderParameterHolder>[];

      try {
        int totalToUpload = 0;
        for (int i = 0; i < _imageSlotCount; i++) {
          if (isImageSelected[i] &&
              (galleryImageAsset[i] != null || cameraImagePath[i] != null)) {
            totalToUpload++;
          }
        }

        int uploadedCount = 0;

        if (totalToUpload > 0) {
          _showUploadDialog('Uploading 1/$totalToUpload...');
        } else if (isSelectedVideoImagePath) {
          _showUploadDialog(
            Utils.getString(context, 'progressloading_video_uploading'),
          );
        } else {
          _showUploadDialog('Uploading...');
        }

        for (int i = 0;
        i < _imageSlotCount && isImageSelected.contains(true);
        i++) {
          if (!isImageSelected[i]) continue;

          if (galleryImageAsset[i] != null || cameraImagePath[i] != null) {
            uploadedCount++;
            _updateUploadDialog('Uploading $uploadedCount/$totalToUpload...');

            final dynamic apiStatus =
            await galleryProvider!.postItemImageUpload(
              itemId,
              uploadedImages[i]?.imgId ?? '',
              '${i + 1}',
              galleryImageAsset[i] == null
                  ? await Utils.getImageFileFromCameraImagePath(
                cameraImagePath[i],
                valueHolder!.uploadImageSize!,
              )
                  : await Utils.getImageFileFromAssets(
                galleryImageAsset[i]!,
                valueHolder!.uploadImageSize!,
              ),
              valueHolder!.loginUserId!,
            );

            if (apiStatus != null &&
                apiStatus.data is DefaultPhoto &&
                apiStatus.data != null) {
              uploadedImages[i] = apiStatus.data as DefaultPhoto;
              isImageSelected[i] = false;
            } else {
              await _dismissUploadDialog();
              if (mounted) {
                showDialog<dynamic>(
                  context: context,
                  builder: (BuildContext context) {
                    return ErrorDialog(
                      message:
                      apiStatus?.message ?? 'فشل رفع الصورة، حاول مرة أخرى',
                    );
                  },
                );
              }
              return false;
            }
          } else if ((uploadedImages[i]?.imgPath ?? '') != '') {
            reorderObjList.add(
              ImageReorderParameterHolder(
                imgId: uploadedImages[i]!.imgId,
                ordering: (i + 1).toString(),
              ),
            );
          }
        }

        if (reorderObjList.isNotEmpty) {
          _updateUploadDialog('Reordering images...');

          final List<Map<String, dynamic>> reorderMapList =
          <Map<String, dynamic>>[];
          for (ImageReorderParameterHolder? data in reorderObjList) {
            if (data != null) reorderMapList.add(data.toMap());
          }

          final PsResource<ApiStatus>? apiStatus =
          await galleryProvider!.postReorderImages(
              reorderMapList, valueHolder!.loginUserId!);

          if (apiStatus?.data != null &&
              apiStatus!.status == PsStatus.SUCCESS) {
            isImageSelected =
                isImageSelected.map<bool>((bool v) => false).toList();
          } else {
            await _dismissUploadDialog();
            if (mounted) {
              showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                      message: apiStatus?.message ?? 'Error');
                },
              );
            }
            return false;
          }
        }

        if (isSelectedVideoImagePath) {
          _updateUploadDialog(
            Utils.getString(
                context, 'progressloading_video_uploading'),
          );

          final PsResource<DefaultPhoto> apiStatus =
          await galleryProvider!.postVideoUpload(
            itemId,
            '',
            File(videoFilePath!),
            valueHolder!.loginUserId!,
          );

          final PsResource<DefaultPhoto> apiStatus2 =
          await galleryProvider!.postVideoThumbnailUpload(
            itemId,
            '',
            File(videoFileThumbnailPath!),
            valueHolder!.loginUserId!,
          );

          if (apiStatus.data != null && apiStatus2.data != null) {
            isSelectedVideoImagePath = false;
          } else {
            await _dismissUploadDialog();
            showRetryDialog(
              Utils.getString(
                  context, 'item_entry__fail_to_upload_video'),
                  () {
                uploadImage(itemId);
              },
            );
            return false;
          }
        }

        await _dismissUploadDialog();

        if (widget.bulkItemData != null) {
          // Bulk queue waits for Navigator result=true.
          // Do not call onBulkItemDone here; otherwise the queue will advance twice.
          if (mounted) Navigator.pop(context, true);
          return true;
        }

        return true;
      } catch (e, st) {
        log('uploadImage failed: $e', stackTrace: st);
        await _dismissUploadDialog();

        if (mounted) {
          showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: 'فشل رفع الصور، حاول مرة أخرى',
              );
            },
          );
        }

        return false;
      } finally {
        await _dismissUploadDialog();
      }
    }

    dynamic updateImagesFromVideo(String imagePath, int index) {
      if (!mounted) return;
      setState(() {
        if (index == -2 && imagePath.isNotEmpty) {
          videoFilePath = imagePath;
          isSelectedVideoImagePath = true;
        }
      });
    }

    dynamic getImageFromVideo(String videoPathUrl) async {
      videoFileThumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPathUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 25,
      );
      return videoFileThumbnailPath;
    }

    dynamic onReorder(int oldIndex, int newIndex) {
      if (galleryImageAsset[oldIndex] != null) {
        if (galleryImageAsset[newIndex] != null) {
          setState(() {
            final XFile? temp = galleryImageAsset[oldIndex];
            galleryImageAsset[oldIndex] = galleryImageAsset[newIndex];
            galleryImageAsset[newIndex] = temp;
          });
        } else if (cameraImagePath[newIndex] != null &&
            cameraImagePath[newIndex] != '') {
          setState(() {
            cameraImagePath[oldIndex] = cameraImagePath[newIndex];
            galleryImageAsset[newIndex] = galleryImageAsset[oldIndex];
            galleryImageAsset[oldIndex] = null;
            cameraImagePath[newIndex] = null;
          });
        } else if ((uploadedImages[newIndex]?.imgPath ?? '') != '' &&
            (uploadedImages[newIndex]?.imgId ?? '') != '') {
          setState(() {
            uploadedImages[oldIndex] = uploadedImages[newIndex];
            uploadedImages[newIndex] =
                DefaultPhoto(imgId: '', imgPath: '');
            galleryImageAsset[newIndex] = galleryImageAsset[oldIndex];
            galleryImageAsset[oldIndex] = null;
            isImageSelected[newIndex] = true;
            isImageSelected[oldIndex] = true;
          });
        }
      } else if (cameraImagePath[oldIndex] != null &&
          cameraImagePath[oldIndex] != '') {
        if (galleryImageAsset[newIndex] != null) {
          setState(() {
            galleryImageAsset[oldIndex] = galleryImageAsset[newIndex];
            cameraImagePath[newIndex] = cameraImagePath[oldIndex];
            cameraImagePath[oldIndex] = null;
            galleryImageAsset[newIndex] = null;
          });
        } else if (cameraImagePath[newIndex] != null &&
            cameraImagePath[newIndex] != '') {
          setState(() {
            final String? temp = cameraImagePath[oldIndex];
            cameraImagePath[oldIndex] = cameraImagePath[newIndex];
            cameraImagePath[newIndex] = temp;
          });
        } else if ((uploadedImages[newIndex]?.imgPath ?? '') != '' &&
            (uploadedImages[newIndex]?.imgId ?? '') != '') {
          setState(() {
            uploadedImages[oldIndex] = uploadedImages[newIndex];
            uploadedImages[newIndex] =
                DefaultPhoto(imgId: '', imgPath: '');
            cameraImagePath[newIndex] = cameraImagePath[oldIndex];
            cameraImagePath[oldIndex] = null;
            isImageSelected[newIndex] = true;
            isImageSelected[oldIndex] = true;
          });
        }
      } else if ((uploadedImages[oldIndex]?.imgPath ?? '') != '' &&
          (uploadedImages[oldIndex]?.imgId ?? '') != '') {
        if (galleryImageAsset[newIndex] != null) {
          setState(() {
            uploadedImages[newIndex] = uploadedImages[oldIndex];
            uploadedImages[oldIndex] =
                DefaultPhoto(imgId: '', imgPath: '');
            galleryImageAsset[oldIndex] = galleryImageAsset[newIndex];
            galleryImageAsset[newIndex] = null;
            isImageSelected[newIndex] = true;
            isImageSelected[oldIndex] = true;
          });
        } else if (cameraImagePath[newIndex] != null &&
            cameraImagePath[newIndex] != '') {
          setState(() {
            uploadedImages[newIndex] = uploadedImages[oldIndex];
            uploadedImages[oldIndex] =
                DefaultPhoto(imgId: '', imgPath: '');
            cameraImagePath[oldIndex] = cameraImagePath[newIndex];
            cameraImagePath[newIndex] = null;
            isImageSelected[newIndex] = true;
            isImageSelected[oldIndex] = true;
          });
        } else if ((uploadedImages[newIndex]?.imgPath ?? '') != '' &&
            (uploadedImages[newIndex]?.imgId ?? '') != '') {
          setState(() {
            final DefaultPhoto? temp = uploadedImages[newIndex];
            uploadedImages[newIndex] = uploadedImages[oldIndex];
            uploadedImages[oldIndex] = temp;
            isImageSelected[oldIndex] = true;
            isImageSelected[newIndex] = true;
          });
        }
      }
    }

    // ── updateImages: AI scan بيبدأ هنا ──────────────────────────────────────
    dynamic updateImages(
        List<XFile> resultList, int index, int currentIndex) async {
      log("images updated");
      XFile? firstImage = galleryImageAsset[0];

      if (!mounted) return;

      setState(() {
        images = resultList;

        if (index != -1 && resultList.isNotEmpty) {
          galleryImageAsset[currentIndex] = resultList[0];
          isImageSelected[currentIndex] = true;
        }

        if (index == -1) {
          int indexToStart = 0;
          for (indexToStart = 0;
          indexToStart < currentIndex;
          indexToStart++) {
            if (!isImageSelected[indexToStart] &&
                indexToStart >
                    (galleryProvider?.selectedImageList?.length ?? 0) -
                        1) {
              break;
            }
          }

          for (int i = 0;
          i < resultList.length &&
              indexToStart < _imageSlotCount;
          i++, indexToStart++) {
            galleryImageAsset[indexToStart] = resultList[i];
            isImageSelected[indexToStart] = true;
          }
        }
      });

      if (resultList.isNotEmpty &&
          firstImage?.path != galleryImageAsset[0]?.path) {
        // ✅ ابدأ الـ scan animation
        if (mounted) setState(() => _isAiScanning = true);

        final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('جاري معالجة الصورة بالذكاء الاصطناعي…'),
            duration: Duration(days: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );

        try {
          final apiResponse = await _itemEntryProvider!.getAiSuggestion(
            File(galleryImageAsset[0]!.path),
          );

          if (!mounted) return;
          messenger.hideCurrentSnackBar();

          if (apiResponse.success) {
            final dynamic productInfo = apiResponse.productInfo;
            if (productInfo is Map) {
              setState(() {
                _itemEntryProvider!.categoryId =
                productInfo["category"]?["cat_id"];
                _itemEntryProvider!.subCategoryId =
                productInfo["subcategory"]?["sub_cat_id"];
                _itemEntryProvider!.avgPrice =
                    productInfo["average_price"]?["value"]
                        ?.toString() ??
                        "";
                _itemEntryProvider!.tags = List<String>.from(
                    productInfo["tags"]?["ar"] ?? <String>[]);
                _itemEntryProvider!.tags_en = List<String>.from(
                    productInfo["tags"]?["en"] ?? <String>[]);
                _itemEntryProvider!.tags_confidence =
                    productInfo["tags"]?["confidence"]?.toString() ??
                        "";
                _itemEntryProvider!.brand =
                    productInfo["brand"]?["value"]?.toString() ?? "";
              });

              final bool isBulk = widget.bulkItemData != null;
              final String aiTitle =
              (productInfo["title"]?["ar"] ?? '').toString().trim();
              final String aiDescription =
              (productInfo["short_description"]?["ar"] ??
                  productInfo["description"]?["ar"] ??
                  '')
                  .toString()
                  .trim();
              final String aiCategory =
              (productInfo["category"]?["ar"] ?? '').toString().trim();
              final String aiSubCategory =
              (productInfo["subcategory"]?["ar"] ?? '').toString().trim();

              if (aiTitle.isNotEmpty &&
                  (!isBulk || userInputListingTitle.text.trim().isEmpty)) {
                userInputListingTitle.text = aiTitle;
              }
              if (aiDescription.isNotEmpty &&
                  (!isBulk || userInputDescription.text.trim().isEmpty)) {
                userInputDescription.text = aiDescription;
              }
              if (aiCategory.isNotEmpty &&
                  (!isBulk || categoryController.text.trim().isEmpty)) {
                categoryController.text = aiCategory;
              }
              if (aiSubCategory.isNotEmpty &&
                  (!isBulk || subCategoryController.text.trim().isEmpty)) {
                subCategoryController.text = aiSubCategory;
              }
            }

            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                    'تم إضافة التصنيفات والتاجز بالذكاء الاصطناعي ✅'),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            messenger.showSnackBar(
              const SnackBar(
                content:
                Text('تم إضافة الصورة، يرجى استكمال البيانات'),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          log('AI suggestion failed silently: $e');
          if (!mounted) return;
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content:
              Text('تم إضافة الصورة، يرجى استكمال البيانات'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } finally {
          // ✅ أوقف الـ scan animation
          if (mounted) setState(() => _isAiScanning = false);
        }
      }
    }

    repo1 = Provider.of<ProductRepository>(context);
    galleryRepository = Provider.of<GalleryRepository>(context);
    userRepository = Provider.of<UserRepository>(context);
    categoryRepository = Provider.of<CategoryRepository>(context);
    subCategoryRepository = Provider.of<SubCategoryRepository>(context);
    widget.animationController?.forward();

    return PsWidgetWithMultiProvider(
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ItemEntryProvider?>(
            lazy: false,
            create: (BuildContext context) {
              _itemEntryProvider = ItemEntryProvider(
                repo: repo1,
                psValueHolder: valueHolder,
              );

              _itemEntryProvider!.item = widget.item;

              if (valueHolder!.isSubLocation == PsConst.ONE &&
                  valueHolder!.locationTownshipLat != '') {
                latlng = LatLng(
                  double.parse(valueHolder!.locationTownshipLat),
                  double.parse(valueHolder!.locationTownshipLng),
                );
                if (_itemEntryProvider!.itemLocationTownshipId != null ||
                    _itemEntryProvider!.itemLocationTownshipId != '') {
                  _itemEntryProvider!.itemLocationTownshipId =
                      _itemEntryProvider!
                          .psValueHolder!.locationTownshipId;
                }
                if (userInputLattitude.text.isEmpty) {
                  userInputLattitude.text = _itemEntryProvider!
                      .psValueHolder!.locationTownshipLat;
                }
                if (userInputLongitude.text.isEmpty) {
                  userInputLongitude.text = _itemEntryProvider!
                      .psValueHolder!.locationTownshipLng;
                }
              } else {
                latlng = LatLng(
                  double.parse(valueHolder!.locationLat!),
                  double.parse(valueHolder!.locationLng!),
                );
                if (userInputLattitude.text.isEmpty) {
                  userInputLattitude.text =
                  _itemEntryProvider!.psValueHolder!.locationLat!;
                }
                if (userInputLongitude.text.isEmpty) {
                  userInputLongitude.text =
                  _itemEntryProvider!.psValueHolder!.locationLng!;
                }
              }

              if (_itemEntryProvider!.itemLocationId != null ||
                  _itemEntryProvider!.itemLocationId != '') {
                _itemEntryProvider!.itemLocationId =
                    _itemEntryProvider!.psValueHolder!.locationId;
              }

              if (widget.item?.id != null &&
                  (widget.item!.id ?? '').isNotEmpty) {
                _itemEntryProvider!.getItemFromDB(widget.item!.id);
              }

              final BulkItemDefaults? defs = widget.bulkDefaults;
              if (defs != null) {
                if (defs.conditionId.isNotEmpty) {
                  _itemEntryProvider!.itemConditionId = defs.conditionId;
                }
                if (defs.usageDurationId.isNotEmpty) {
                  _itemEntryProvider!.itemTypeId = defs.usageDurationId;
                }
                if (defs.categoryId != null &&
                    defs.categoryId!.isNotEmpty) {
                  _itemEntryProvider!.categoryId = defs.categoryId;
                }
                if (defs.subCategoryId != null &&
                    defs.subCategoryId!.isNotEmpty) {
                  _itemEntryProvider!.subCategoryId = defs.subCategoryId;
                }
              }

              if (widget.bulkItemData != null) {
                _applyBulkMetadataToProvider();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _applyBulkMetadataToProvider();
                  _runBulkAiSuggestionIfNeeded();
                });
              }

              return _itemEntryProvider;
            },
          ),
          ChangeNotifierProvider<GalleryProvider?>(
            lazy: false,
            create: (BuildContext context) {
              galleryProvider =
                  GalleryProvider(repo: galleryRepository!);
              if (widget.flag == PsConst.EDIT_ITEM &&
                  widget.item?.defaultPhoto?.imgParentId != null) {
                galleryProvider!.loadImageList(
                  widget.item!.defaultPhoto!.imgParentId,
                  PsConst.ITEM_TYPE,
                );
              }
              return galleryProvider;
            },
          ),
          ChangeNotifierProvider<UserProvider?>(
            lazy: false,
            create: (BuildContext context) {
              userProvider = UserProvider(
                repo: userRepository,
                psValueHolder: valueHolder,
              );
              userProvider!.getUser(valueHolder!.loginUserId);
              return userProvider;
            },
          ),
          ChangeNotifierProvider<CategoryProvider?>(
            lazy: false,
            create: (BuildContext context) {
              final CategoryProvider provider = CategoryProvider(
                repo: categoryRepository!,
                psValueHolder: valueHolder!,
              );
              provider.loadCategoryList(
                provider.categoryParameterHolder.toMap(),
                Utils.checkUserLoginId(provider.psValueHolder!),
              );
              return provider;
            },
          ),
          ChangeNotifierProvider<SubCategoryProvider?>(
            lazy: false,
            create: (BuildContext context) {
              final SubCategoryProvider provider = SubCategoryProvider(
                repo: subCategoryRepository!,
                psValueHolder: valueHolder!,
                limit: 50,
              );
              provider.loadSubCategoryList(
                provider.subCategoryParameterHolder.toMap(),
                Utils.checkUserLoginId(provider.psValueHolder!),
              );
              return provider;
            },
          ),
        ],
        child: Consumer<UserProvider>(
          builder: (BuildContext context, UserProvider provider,
              Widget? child) {
            if (widget.flag == PsConst.ADD_NEW_ITEM &&
                valueHolder!.isPaidApp == PsConst.ONE &&
                provider.user.data == null) {
              return Container(color: PsColors.coreBackgroundColor);
            }

            final bool canPost = widget.flag == PsConst.EDIT_ITEM ||
                (valueHolder!.isPaidApp != PsConst.ONE ||
                    provider.user.data != null);

            if (!canPost) {
              return InAppPurchaseBuyPackageDialog(
                onInAppPurchaseTap: () async {
                  final dynamic returnData =
                  await Navigator.pushNamed(
                    context,
                    RoutePaths.buyPackage,
                    arguments: <String, dynamic>{
                      'android': valueHolder?.packageAndroidKeyList,
                      'ios': valueHolder?.packageIOSKeyList,
                    },
                  );

                  if (returnData != null) {
                    setState(() {
                      userProvider!.user.data!.remainingPost =
                          returnData;
                    });
                  } else {
                    provider.getUser(valueHolder!.loginUserId);
                  }
                },
              );
            }

            return TaapdeelScaffold(
              padding: EdgeInsets.zero,
              floatingTopLeft: (_badgesCount > 0)
                  ? _buildFloatingCornerBadge()
                  : null,
              floatingTopLeftMargin:
              const EdgeInsetsDirectional.only(
                start: 250,
                top: 25,
              ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedBuilder(
                        animation: widget.animationController!,
                        child: Container(
                          padding:
                          const EdgeInsetsDirectional.only(
                            start: PsDimens.space16,
                            end: PsDimens.space16,
                            top: PsDimens.space8,
                            bottom: PsDimens.space8,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: PsDimens.space8),

                              if (widget.bulkItemData != null)
                                _BulkModeBanner(
                                    data: widget.bulkItemData!),

                              // ── Images (step 0 only) ──────────────────
                              if (_currentStep == 0)
                                Consumer<GalleryProvider>(
                                  builder: (
                                      BuildContext context,
                                      GalleryProvider provider,
                                      Widget? child,
                                      ) {
                                    if (bindImageFirstTime &&
                                        (provider.galleryList.data ??
                                            <DefaultPhoto>[])
                                            .isNotEmpty) {
                                      final list =
                                          provider.galleryList.data ??
                                              <DefaultPhoto>[];
                                      for (int i = 0;
                                      i < _imageSlotCount &&
                                          i < list.length;
                                      i++) {
                                        if (list[i].imgId != null) {
                                          uploadedImages[i] = list[i];
                                        }
                                      }
                                      bindImageFirstTime = false;
                                    }

                                    return ImageUploadHorizontalList(
                                      flag: widget.flag,
                                      images: images,
                                      selectedImageList: uploadedImages,
                                      updateImages: updateImages,
                                      updateImagesFromCustomCamera:
                                      updateImagesFromVideo,
                                      videoFilePath: videoFilePath,
                                      videoFileThumbnailPath:
                                      videoFileThumbnailPath,
                                      selectedVideoImagePath:
                                      selectedVideoImagePath,
                                      updateImagesFromVideo:
                                      updateImagesFromVideo,
                                      selectedVideoPath:
                                      selectedVideoPath,
                                      getImageFromVideo:
                                      getImageFromVideo,
                                      imageDesc1Controller: galleryProvider!
                                          .imageDesc1Controller,
                                      provider: _itemEntryProvider,
                                      galleryProvider: provider,
                                      onReorder: onReorder,
                                      cameraImagePath: cameraImagePath,
                                      galleryImagePath:
                                      galleryImageAsset,
                                      enableOrbit: true,
                                      ringCount: 2,
                                      orbitPadding:
                                      const EdgeInsets.all(10),
                                      orbitCategoryLabel:
                                      categoryController.text,
                                      orbitSubCategoryLabel:
                                      subCategoryController.text,
                                      orbitTags:
                                      _itemEntryProvider?.tags ??
                                          <String>[],
                                      // ✅ AI scan overlay
                                      isAiScanning: _isAiScanning,
                                    );
                                  },
                                ),

                              Consumer<ItemEntryProvider>(
                                builder: (
                                    BuildContext context,
                                    ItemEntryProvider provider,
                                    Widget? child,
                                    ) {
                                  if (provider.item?.id != null &&
                                      (provider.item!.id ?? '')
                                          .isNotEmpty) {
                                    if (bindDataFirstTime) {
                                      userInputListingTitle.text =
                                          provider.item!.title ?? '';
                                      userInputHighLightInformation
                                          .text =
                                          provider.item!
                                              .highlightInformation ??
                                              '';
                                      userInputDescription.text =
                                          provider.item!.description ??
                                              '';
                                      userInputDealOptionText.text =
                                          provider.item!
                                              .dealOptionRemark ??
                                              '';

                                      if (valueHolder!.isSubLocation ==
                                          PsConst.ONE) {
                                        userInputLattitude.text = provider
                                            .item!
                                            .itemLocationTownship!
                                            .lat!;
                                        userInputLongitude.text = provider
                                            .item!
                                            .itemLocationTownship!
                                            .lng!;
                                        provider.itemLocationTownshipId =
                                            provider
                                                .item!
                                                .itemLocationTownship!
                                                .id;
                                        locationTownshipController
                                            .text =
                                            provider
                                                .item!
                                                .itemLocationTownship!
                                                .townshipName ??
                                                '';
                                      } else {
                                        userInputLattitude.text =
                                            provider.item!.lat ?? '';
                                        userInputLongitude.text =
                                            provider.item!.lng ?? '';
                                      }

                                      provider.itemLocationId = provider
                                          .item!.itemLocation!.id;
                                      locationController.text = provider
                                          .item!.itemLocation!.name ??
                                          '';
                                      userInputAddress.text =
                                          provider.item!.address ?? '';
                                      userInputPrice.text =
                                          provider.item!.price ?? '';
                                      userInputDiscount.text = provider
                                          .item!.discountRate ??
                                          '';

                                      categoryController.text = provider
                                          .item?.category!.catName ??
                                          '';
                                      subCategoryController.text = provider
                                          .item!.subCategory!.name ??
                                          '';
                                      typeController.text = provider
                                          .item!.itemType!.name ??
                                          '';
                                      itemConditionController.text =
                                          provider.item!.conditionOfItem!
                                              .name ??
                                              '';
                                      priceTypeController.text = provider
                                          .item!.itemPriceType!.name ??
                                          '';
                                      priceController.text = provider
                                          .item!
                                          .itemCurrency!
                                          .currencySymbol ??
                                          '';
                                      dealOptionController.text = provider
                                          .item!.dealOption!.name ??
                                          '';

                                      provider.categoryId =
                                          provider.item!.category!.catId;
                                      provider.subCategoryId =
                                          provider.item!.subCategory!.id;
                                      provider.itemTypeId =
                                          provider.item!.itemType!.id;
                                      provider.itemConditionId = provider
                                          .item!.conditionOfItem!.id;
                                      provider.itemDealOptionId =
                                          provider.item!.dealOption!.id;
                                      provider.itemPriceTypeId = provider
                                          .item!.itemPriceType!.id;

                                      selectedVideoImagePath = provider
                                          .item!.videoThumbnail!.imgPath;
                                      selectedVideoPath =
                                          provider.item!.video!.imgPath;

                                      bindDataFirstTime = false;

                                      provider.isCheckBoxSelect =
                                      (provider.item?.businessMode ==
                                          '1');
                                    }
                                  }

                                  return Column(
                                    children: <Widget>[
                                      AllControllerTextWidget(
                                        key: _formKey,
                                        userInputListingTitle:
                                        userInputListingTitle,
                                        categoryController:
                                        categoryController,
                                        subCategoryController:
                                        subCategoryController,
                                        typeController: typeController,
                                        itemConditionController:
                                        itemConditionController,
                                        priceTypeController:
                                        priceTypeController,
                                        priceController: priceController,
                                        userInputHighLightInformation:
                                        userInputHighLightInformation,
                                        userInputDescription:
                                        userInputDescription,
                                        dealOptionController:
                                        dealOptionController,
                                        userInputDealOptionText:
                                        userInputDealOptionText,
                                        locationController:
                                        locationController,
                                        locationTownshipController:
                                        locationTownshipController,
                                        userInputLattitude:
                                        userInputLattitude,
                                        userInputLongitude:
                                        userInputLongitude,
                                        userInputAddress: userInputAddress,
                                        userInputPrice: userInputPrice,
                                        userInputDiscount: userInputDiscount,
                                        mapController: mapController,
                                        zoom: zoom,
                                        flag: widget.flag,
                                        item: widget.item,
                                        provider: provider,
                                        galleryProvider: galleryProvider,
                                        userProvider: userProvider,
                                        latlng: latlng,
                                        uploadImage: uploadImage,
                                        hasAnyProductMedia: _hasAnyProductMedia,
                                        localShareImagePathResolver:
                                        _firstLocalShareImagePath,
                                        isImageSelected: isImageSelected,
                                        isSelectedVideoImagePath:
                                        isSelectedVideoImagePath,
                                        currentStep: _currentStep,
                                        onHighQualityChanged: (bool v) {
                                          if (!mounted) return;
                                        },
                                        onBadgesChanged: _onBadgesChanged,
                                        isBulkMode:
                                        widget.bulkItemData != null,
                                        bulkDefaults: widget.bulkDefaults,
                                        onItemUploaded: widget.onItemUploaded,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        builder:
                            (BuildContext context, Widget? child) {
                          return child!;
                        },
                      ),
                    ),
                  ),
                  _buildBottomActions(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bulk mode banner
// ─────────────────────────────────────────────────────────────────────────────

class _BulkModeBanner extends StatelessWidget {
  const _BulkModeBanner({required this.data});
  final BulkItemData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: PsDimens.space8),
      padding: const EdgeInsets.symmetric(
          horizontal: PsDimens.space14, vertical: PsDimens.space8),
      decoration: BoxDecoration(
        color: PsColors.primary500.withOpacity(0.07),
        borderRadius: BorderRadius.circular(PsDimens.space10),
        border: Border.all(color: PsColors.primary500.withOpacity(0.2)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Icon(Icons.inventory_2_outlined,
              color: PsColors.primary500, size: 16),
          const SizedBox(width: PsDimens.space8),
          Expanded(
            child: Text(
              data.title,
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: PsColors.primary500,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: PsDimens.space8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: PsColors.primary500,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'وضع المجموعة',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Tag card helpers (kept for compatibility)
// ─────────────────────────────────────────────────────────────────────────────

class _TagCard extends StatelessWidget {
  const _TagCard(
      {required this.color, required this.child, this.hole = true});

  final Color color;
  final Widget child;
  final bool hole;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TagClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            child,
            if (hole)
              Positioned(
                left: 18,
                top: 14,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.95),
                      width: 5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TagClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size s) {
    final double r = 14.0;
    final double notch = 18.0;

    final ui.Path p = ui.Path();
    p.moveTo(r, 0);
    p.lineTo(s.width - r, 0);
    p.quadraticBezierTo(s.width, 0, s.width, r);
    p.lineTo(s.width, s.height - r);
    p.quadraticBezierTo(s.width, s.height, s.width - r, s.height);
    p.lineTo(notch + r, s.height);
    p.quadraticBezierTo(notch, s.height, notch - 6, s.height - 8);
    p.lineTo(6, s.height / 2 + 8);
    p.quadraticBezierTo(0, s.height / 2, 6, s.height / 2 - 8);
    p.lineTo(notch - 6, 8);
    p.quadraticBezierTo(notch, 0, notch + r, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<ui.Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Badge tier theming
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeTierTheme {
  const _BadgeTierTheme({
    required this.title,
    required this.icon,
    required this.textColor,
    required this.countBg,
    required this.countBorder,
    required this.countText,
    required this.glassGradient,
    required this.glassBorder,
    required this.glow,
    required this.coinGradient,
    required this.coinShadow,
    required this.coinIconColor,
    required this.emoji,
  });

  final String title;
  final IconData icon;
  final String emoji;
  final Color textColor;
  final Color countBg;
  final Color countBorder;
  final Color countText;
  final List<Color> glassGradient;
  final Color glassBorder;
  final Color glow;
  final List<Color> coinGradient;
  final Color coinShadow;
  final Color coinIconColor;
}

enum BadgeTier { featured, deal }

BadgeTier _tierFromBadges(int count) {
  if (count >= 3) return BadgeTier.deal;
  return BadgeTier.featured;
}

_BadgeTierTheme _themeForTier(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.featured:
      return _BadgeTierTheme(
        emoji: '',
        title: 'منتج مميز',
        icon: Icons.workspace_premium_rounded,
        textColor: const Color(0xFF123055),
        countBg: const Color(0xFF1D9BF0).withOpacity(0.10),
        countBorder: const Color(0xFF1D9BF0).withOpacity(0.18),
        countText: const Color(0xFF0F4C81),
        glassGradient: <Color>[
          const Color(0xFFEEF6FF),
          const Color(0xFFE6F4FB),
          Colors.white.withOpacity(0.92),
        ],
        glassBorder: const Color(0xFF8ED1E8).withOpacity(0.55),
        glow: const Color(0xFF7CC7E8).withOpacity(0.12),
        coinGradient: const <Color>[
          Color(0xFF1E5B8F),
          Color(0xFF2BA9C8),
        ],
        coinShadow: const Color(0xFF2BA9C8),
        coinIconColor: Colors.white,
      );

    case BadgeTier.deal:
      return _BadgeTierTheme(
        title: 'منتج لُقْطَة',
        icon: Icons.local_fire_department_rounded,
        emoji: '💥',
        textColor: const Color(0xFF6A4A00),
        countBg: const Color(0xFFFFDE79).withOpacity(0.14),
        countBorder: const Color(0xFFE0A100).withOpacity(0.18),
        countText: const Color(0xFFAA7A00),
        glassGradient: <Color>[
          const Color(0xFFFFF8E1),
          const Color(0xFFFFFFFF),
          Colors.white.withOpacity(0.82),
        ],
        glassBorder: const Color(0xFFFFD76A).withOpacity(0.68),
        glow: const Color(0xFFE0A100).withOpacity(0.10),
        coinGradient: const <Color>[
          Color(0xFFFFE38E),
          Color(0xFFE0A100),
        ],
        coinShadow: const Color(0xFFE0A100),
        coinIconColor: Colors.white,
      );
  }
}
