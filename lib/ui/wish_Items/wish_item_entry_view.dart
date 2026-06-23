import 'dart:convert';
import 'dart:io';
import 'dart:ui' show ImageFilter, Color;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, TextEditingValue, TextSelection;

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/category/category_provider.dart';
import 'package:taapdeel/provider/entry/item_entry_provider.dart';
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
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';
import 'package:taapdeel/ui/item/share_theme/core/share_product_data.dart';
import 'package:taapdeel/ui/item/share_theme/core/share_theme_definition.dart';
import 'package:taapdeel/ui/wish_Items/wish_product_share_options.dart';
import 'package:taapdeel/ui/wish_Items/wish_share_themes.dart';
import 'package:taapdeel/ui/wish_Items/wish_story_card_themes.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/taapdeel_share_links.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/default_photo.dart';
import 'package:taapdeel/viewobject/holder/image_reorder_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/item_entry_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../common/taapdeel/taapdeel_button.dart';
import '../common/taapdeel/taapdeel_glass_bottom_sheet.dart';
import '../item/entry/widgets/image_upload_horizontal_list.dart';

class WishItemEntryView extends StatefulWidget {
  const WishItemEntryView({
    Key? key,
    this.flag,
    this.item,
    required this.animationController,
    this.onItemUploaded,
    required this.maxImageCount,
  }) : super(key: key);

  final AnimationController? animationController;
  final String? flag;
  final Product? item;
  final Function? onItemUploaded;
  final int maxImageCount;

  @override
  State<StatefulWidget> createState() => _WishItemEntryViewState();
}

class _WishItemEntryViewState extends State<WishItemEntryView>
    with TickerProviderStateMixin {
  ProductRepository? repo1;
  GalleryRepository? galleryRepository;

  ItemEntryProvider? _itemEntryProvider;
  GalleryProvider? galleryProvider;
  UserProvider? userProvider;

  UserRepository? userRepository;
  CategoryRepository? categoryRepository;
  SubCategoryRepository? subCategoryRepository;

  PsValueHolder? valueHolder;



  // ✅ Optional fields (Card 2)
  final TextEditingController userInputListingTitle = TextEditingController();
  final TextEditingController userInputDescription = TextEditingController();
  final TextEditingController _storyCardTitleController = TextEditingController();
  final TextEditingController _hawadeetHookController = TextEditingController();
  final TextEditingController _hawadeetStoryController = TextEditingController();
  String _selectedPersonaType = 'family';
  String _selectedStoryThemeId = WishStoryCardThemes.defaultThemeId;
  String _selectedShareThemeId = WishShareThemes.themes.isNotEmpty
      ? WishShareThemes.themes.first.id
      : '';
  String _selectedNeedReason = 'توفير مصاريف';
  String _selectedHookTemplateId = '';
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();

  late LatLng latlng;

  bool bindDataFirstTime = true;
  bool bindImageFirstTime = true;

  // ✅ Images / Video upload
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









  // ✅ AI state (NEW)
  bool _aiInFlight = false;
  String? _lastAiImagePath; // prevent duplicate AI calls on same image

  bool _submittingWish = false;

  // ✅ NEW: Wish-entry design mode. First choice is plain product data.
  static const String _productDataEntryModeId = '__product_data__';
  String _selectedEntryModeId = _productDataEntryModeId;

  bool get _isThemedWishEntry => _selectedEntryModeId != _productDataEntryModeId;

  @override
  void initState() {
    super.initState();

    userInputListingTitle.addListener(_onWishEntryTextChanged);
    userInputDescription.addListener(_onWishEntryTextChanged);
    _storyCardTitleController.addListener(_onWishEntryTextChanged);
    _hawadeetStoryController.addListener(_onWishEntryTextChanged);


    isImageSelected = List<bool>.generate(widget.maxImageCount, (_) => false);
    galleryImageAsset = List<XFile?>.generate(widget.maxImageCount, (_) => null);
    cameraImagePath = List<String?>.generate(widget.maxImageCount, (_) => null);
    uploadedImages = List<DefaultPhoto?>.generate(
      widget.maxImageCount,
          (_) => DefaultPhoto(imgId: '', imgPath: ''),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.animationController?.forward();
    });

  }

  @override
  void dispose() {
    userInputListingTitle.removeListener(_onWishEntryTextChanged);
    userInputDescription.removeListener(_onWishEntryTextChanged);
    _storyCardTitleController.removeListener(_onWishEntryTextChanged);
    _hawadeetStoryController.removeListener(_onWishEntryTextChanged);

    userInputListingTitle.dispose();
    userInputDescription.dispose();
    _storyCardTitleController.dispose();
    _hawadeetHookController.dispose();
    _hawadeetStoryController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();

    super.dispose();
  }


  void _onWishEntryTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  int _wordCount(String text) {
    final String clean = text.trim();
    if (clean.isEmpty) return 0;
    return clean.split(RegExp(r'\s+')).where((String w) => w.trim().isNotEmpty).length;
  }

  String _firstWords(String text, int maxWords) {
    final List<String> words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.trim().isNotEmpty)
        .toList();
    if (words.length <= maxWords) return words.join(' ');
    return words.take(maxWords).join(' ');
  }

  String _twoLineStoryFromText(String source, String title) {
    final String clean = source.trim().replaceAll(RegExp(r'\s+'), ' ');
    final String product = title.trim().isEmpty ? 'الحاجة دي' : title.trim();
    if (clean.isEmpty) {
      return 'بدور على $product ومش لازم أشتري جديد.\nيمكن تكون موجودة عند حد ومش محتاجها.';
    }

    final String short = clean.length > 95 ? '${clean.substring(0, 95).trim()}...' : clean;
    return '$short\nلو عندك حاجة مناسبة، خلينا نعمل تبديل لطيف.';
  }


  String _limitStoryTitleToFiveWords(String value) {
    return _firstWords(value.trim().replaceAll(RegExp(r'\s+'), ' '), 5);
  }

  List<String> _suggestedHawadeetTitles(bool isArabic) {
    final String product = _firstWords(userInputListingTitle.text.trim(), 2);

    final List<String> dynamicTitles = product.isEmpty
        ? <String>[]
        : <String>[
      'حد عنده $product؟',
      'نفسي في $product',
      '$product اللي بدور عليه',
    ];

    final List<String> commonArabicTitles = <String>[
      'الجديد اسعاره نار',
      'البيت بقى مليان كراكيب',
      'احنا اخر الشهر',
      'استلفها من اي حد',
      'كفاية لف وشراء بقي',
      'عاوزين نجيب ال supplies',
      'هنشتريها عشان نستعملها مرتين تلاته حرااام',
      'نشتري عشان يوم واحد',
      'دي لسه جديدة… نرميها إزاي؟',
      'المقاس طلع غلط',
      'بدور عليها',
      'حد عنده ده؟',
      'نفسي ألاقيها',
      'مين ينقذني؟',
      'الشنطة دي خرجت مرتين بس',
      'محتاجاها بجد',
      'تبديل يفرحني',
      'دورها خلص عندك؟',
      'عندك الحل؟',
      'أمنية صغيرة',
    ];

    final List<String> commonEnglishTitles = <String>[
      'Anyone has this?',
      'Looking for this',
      'Not necessarily new',
      'Can you help?',
      'Small wish',
      'Swap would help',
      'Need this item',
      'Still useful?',
    ];

    final List<String> rawTitles = <String>[
      ...dynamicTitles,
      ...(isArabic ? commonArabicTitles : commonEnglishTitles),
    ];

    final List<String> titles = <String>[];
    final Set<String> seen = <String>{};

    for (final String rawTitle in rawTitles) {
      final String title = _limitStoryTitleToFiveWords(rawTitle);
      if (title.isEmpty || seen.contains(title)) continue;
      seen.add(title);
      titles.add(title);
    }

    return titles.take(12).toList(growable: false);
  }

  Widget _buildSuggestedStoryTitleChips({
    required bool isArabic,
    required WishStoryCardTheme theme,
  }) {
    final List<String> titles = _suggestedHawadeetTitles(isArabic);
    if (titles.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.accent.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Icon(Icons.auto_awesome_rounded, color: theme.accent, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isArabic ? 'اختر من عناوين مقترحة' : 'Suggested story titles',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              reverse: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: titles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final String title = titles[index];
                final bool selected = _storyCardTitleController.text.trim() == title;

                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    setState(() {
                      _storyCardTitleController.text = title;
                      _storyCardTitleController.selection = TextSelection.collapsed(
                        offset: _storyCardTitleController.text.length,
                      );
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? theme.accent : Colors.white.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected ? theme.accent : theme.accent.withOpacity(0.22),
                      ),
                      boxShadow: selected
                          ? <BoxShadow>[
                        BoxShadow(
                          color: theme.accent.withOpacity(0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : const <BoxShadow>[],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.rtl,
                      children: <Widget>[
                        if (selected) ...<Widget>[
                          const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          title,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: selected ? Colors.white : theme.titleColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _applyAiWishStoryDefaults(dynamic productInfo) {
    String read(List<String> path, {String fallback = ''}) {
      dynamic current = productInfo;
      for (final String key in path) {
        if (current is Map && current.containsKey(key)) {
          current = current[key];
        } else {
          return fallback;
        }
      }
      final String value = (current ?? '').toString().trim();
      return value.isEmpty || value.toLowerCase() == 'null' ? fallback : value;
    }

    final String aiTitle = read(<String>['title', 'ar']);
    final String aiShort = read(<String>['short_description', 'ar'],
        fallback: read(<String>['description', 'ar']));
    final String productTitle = aiTitle.isNotEmpty ? aiTitle : userInputListingTitle.text.trim();



    if (_hawadeetHookController.text.trim().isEmpty && productTitle.isNotEmpty) {
      _hawadeetHookController.text = 'بدور على $productTitle ومش عايز أشتري جديد.';
    }

    // مهم: الذكاء الاصطناعي يملأ وصف المنتج فقط.
    // حقل الحدوته يظل للمستخدم ولا يتم ملؤه تلقائياً.
    if (userInputDescription.text.trim().isEmpty && aiShort.isNotEmpty) {
      userInputDescription.text = aiShort;
    }
  }

  Future<void> _tryRunAiOnFirstImageIfNeeded() async {
    if (!mounted) return;
    if (_itemEntryProvider == null) return;

    // We run AI only if first slot has an image file (gallery/camera)
    final String? firstPath = galleryImageAsset[0]?.path ?? cameraImagePath[0];
    if (firstPath == null || firstPath.isEmpty) return;

    // prevent duplicate calls
    if (_aiInFlight) return;
    if (_lastAiImagePath == firstPath) return;

    _aiInFlight = true;
    _lastAiImagePath = firstPath;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    // ✅ Sticky snack (until we hide it manually)
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('جاري معالجة الصورة بالذكاء الاصطناعي…'),
        duration: Duration(days: 1), // stays until we hide it
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final File f = File(firstPath);

      final AiSuggestionResponse resp =
      await _itemEntryProvider!.getAiSuggestion(f);

      if (!mounted) return;

      // ✅ Hide processing snack when response arrives
      messenger.hideCurrentSnackBar();

      if (resp.success != true || resp.productInfo == null) {
        // ✅ Fail message (success=false)
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الصورة، يرجى استكمال البيانات'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final dynamic productInfo = resp.productInfo;
      if (productInfo is! Map) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الصورة، يرجى استكمال البيانات'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      try {
        // ✅ نفس item_entry_view.dart بالظبط
        if (!mounted) return;
        setState(() {
          _itemEntryProvider!.categoryId = productInfo["category"]?["cat_id"];
          _itemEntryProvider!.subCategoryId =
          productInfo["subcategory"]?["sub_cat_id"];

          _itemEntryProvider!.avgPrice =
              productInfo["average_price"]?["value"]?.toString() ?? "";

          _itemEntryProvider!.tags =
          List<String>.from(productInfo["tags"]?["ar"] ?? <String>[]);

          _itemEntryProvider!.tags_en =
          List<String>.from(productInfo["tags"]?["en"] ?? <String>[]);

          _itemEntryProvider!.tags_confidence =
              productInfo["tags"]?["confidence"]?.toString() ?? "";

          _itemEntryProvider!.brand =
              productInfo["brand"]?["value"]?.toString() ?? "";
        });

        // ✅ fill UI controllers
        userInputListingTitle.text =
            (productInfo["title"]?["ar"] ?? '').toString();

        userInputDescription.text =
            (productInfo["short_description"]?["ar"] ??
                productInfo["description"]?["ar"] ??
                '')
                .toString();

        categoryController.text =
            (productInfo["category"]?["ar"] ?? '').toString();

        subCategoryController.text =
            (productInfo["subcategory"]?["ar"] ?? '').toString();

        _applyAiWishStoryDefaults(productInfo);

        // ✅ Success message
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم استكمال البيانات الأساسية بالذكاء الاصطناعي ✅'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        debugPrint("AI parse error: $e");

        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الصورة، يرجى استكمال البيانات'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('AI error: $e');

      if (!mounted) return;

      // ✅ Hide processing snack on error too
      messenger.hideCurrentSnackBar();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('تم إضافة الصورة، يرجى استكمال البيانات'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _aiInFlight = false;
    }
  }


  Future<void> _saveWishTagsToDb({
    required String wishId,
    required List<String> tagsAr,
    required List<String> tagsEn,
    required String source,
    String? confidence,
  }) async
  {
    if (_itemEntryProvider == null) return;
    if (wishId.isEmpty) return;
    if (tagsAr.isEmpty && tagsEn.isEmpty) return;

    final Map<dynamic, dynamic> jsonMap = <dynamic, dynamic>{
      'entity_type': 'wish',
      'entity_id': wishId,
      'source': source,
      'confidence': (confidence ?? '').toString(),
      'tags_ar': tagsAr,
      'tags_en': tagsEn,
    };

    try {
      await _itemEntryProvider!.postSaveTags(jsonMap);
    } catch (e) {
      debugPrint('save_tags error: $e');
    }
  }


  // ===========================================================================
  // Bottom sheet success
  // ===========================================================================
  Future<void> _showWishSubmittedSheetThenGoHome({
    Product? createdProduct,
    String? shareImageUrl,
  }) async {
    if (!mounted) return;

    bool goHomeAfterSheet = true;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      isDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext ctx) {
        final ThemeData theme = Theme.of(ctx);
        final bool isArabic = Directionality.of(ctx) == TextDirection.rtl;
        final bool canShare = createdProduct != null;

        return TaapdeelGlassBottomSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Color(0xFF075985),
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isArabic ? 'تمت إضافة المنتج المطلوب' : 'Story wish added',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isArabic
                    ? 'تم حفظ الحاجة اللي نفسك فيها بنجاح.\nتقدر تشاركها كمنتج مطلوب.'
                    : 'Your wish has been saved.\nYou can share it as a story or as a wanted item.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withOpacity(0.65),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (canShare) ...<Widget>[
                TaapdeelButton(
                  label: isArabic ? 'شارك' : 'Share as story',
                  isPrimary: true,
                  isExpanded: true,
                  onPressed: () async {
                    goHomeAfterSheet = false;
                    Navigator.of(ctx).pop();

                    await Future<void>.delayed(const Duration(milliseconds: 120));
                    if (!mounted || createdProduct == null) return;

                    await WishProductShareOptions.show(
                      context: context,
                      product: createdProduct!,
                      dynamicLink: _buildWishShareLink(createdProduct!),
                      imageUrl: _resolveWishShareImage(
                        createdProduct!,
                        explicitImageUrl: shareImageUrl,
                      ),
                    );

                    if (!mounted) return;
                    _goHome();
                  },
                ),
                const SizedBox(height: 10),
              ],
              TaapdeelButton(
                label: isArabic
                    ? (canShare ? 'الرجوع للرئيسية' : 'تمام')
                    : (canShare ? 'Back to home' : 'OK'),
                isPrimary: !canShare,
                isExpanded: true,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    if (goHomeAfterSheet) _goHome();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      RoutePaths.home,
          (Route<dynamic> route) => false,
    );
  }

  String _buildWishShareLink(Product product) {
    return TaapdeelShareLinks.wish(product.id);
  }

  String _resolveLocalWishImageForShare() {
    for (final XFile? image in galleryImageAsset) {
      final String path = (image?.path ?? '').trim();
      if (path.isNotEmpty) return path;
    }

    for (final String? path in cameraImagePath) {
      final String clean = (path ?? '').trim();
      if (clean.isNotEmpty) return clean;
    }

    for (final DefaultPhoto? photo in uploadedImages) {
      final String path = (photo?.imgPath ?? '').trim();
      if (path.isNotEmpty) return path;
    }

    return '';
  }

  String _resolveWishShareImage(
      Product product, {
        String? explicitImageUrl,
      }) {
    String normalize(dynamic value) => (value ?? '').toString().trim();

    final String explicit = normalize(explicitImageUrl);
    if (explicit.isNotEmpty) return explicit;

    final dynamic dynamicProduct = product;

    try {
      final String fromDefaultPhotoPath = normalize(dynamicProduct.defaultPhoto?.imgPath);
      if (fromDefaultPhotoPath.isNotEmpty) return fromDefaultPhotoPath;
    } catch (_) {}

    try {
      final String fromDefaultPhotoPath = normalize(dynamicProduct.defaultPhoto?.path);
      if (fromDefaultPhotoPath.isNotEmpty) return fromDefaultPhotoPath;
    } catch (_) {}

    try {
      final String fromDefaultPhotoUrl = normalize(dynamicProduct.defaultPhoto?.url);
      if (fromDefaultPhotoUrl.isNotEmpty) return fromDefaultPhotoUrl;
    } catch (_) {}

    try {
      final String fromDefaultPhotoOriginal = normalize(dynamicProduct.defaultPhoto?.originalImgPath);
      if (fromDefaultPhotoOriginal.isNotEmpty) return fromDefaultPhotoOriginal;
    } catch (_) {}

    try {
      final String fromDefaultPhotoThumbnail = normalize(dynamicProduct.defaultPhoto?.thumbnail);
      if (fromDefaultPhotoThumbnail.isNotEmpty) return fromDefaultPhotoThumbnail;
    } catch (_) {}

    try {
      final String fromProductImage = normalize(dynamicProduct.image);
      if (fromProductImage.isNotEmpty) return fromProductImage;
    } catch (_) {}

    try {
      final String fromProductImagePath = normalize(dynamicProduct.imagePath);
      if (fromProductImagePath.isNotEmpty) return fromProductImagePath;
    } catch (_) {}

    return _resolveLocalWishImageForShare();
  }

  // ✅ Mint gradient background for the whole page (same premium card vibe)
  Widget _mintGradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF8FC5E8),
            Color(0xFFEFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFF8FC5E8),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Soft blobs (subtle, no extra packages)
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    Color(0xFF8FC5E8).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFF7DD3FC).withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Light glass wash
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          child,
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------------
  //  Images/Video Helpers (كما هي)
  // ---------------------------------------------------------------------------

  void _showRetryDialog(String description, Function retry) {
    if (PsProgressDialog.isShowing()) PsProgressDialog.dismissDialog();
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return RetryDialogView(
          description: description,
          rightButtonText: Utils.getString(context, 'item_entry__retry'),
          onAgreeTap: () {
            Navigator.pop(context);
            retry();
          },
        );
      },
    );
  }

  Future<dynamic> _uploadImage(
      String itemId, {
        Product? createdProduct,
        String? shareImageUrl,
      }) async {
    bool isVideoDone = isSelectedVideoImagePath;
    DefaultPhoto? firstUploadedWishPhoto;
    final List<ImageReorderParameterHolder> reorderObjList =
    <ImageReorderParameterHolder>[];

    for (int i = 0;
    i < widget.maxImageCount && isImageSelected.contains(true);
    i++) {
      if (!isImageSelected[i]) continue;

      if (galleryImageAsset[i] != null || cameraImagePath[i] != null) {
        if (!PsProgressDialog.isShowing()) {
          await PsProgressDialog.showDialog(
            context,
            message: 'Image ${i + 1} uploading',
          );
        }

        final dynamic apiStatus = await galleryProvider!.postwishItemImageUpload(
          itemId,
          uploadedImages[i]!.imgId,
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

        PsProgressDialog.dismissDialog();

        if (apiStatus != null &&
            apiStatus.data is DefaultPhoto &&
            apiStatus.data != null) {
          final DefaultPhoto uploadedPhoto = apiStatus.data as DefaultPhoto;
          uploadedImages[i] = uploadedPhoto;
          firstUploadedWishPhoto ??= uploadedPhoto;
          isImageSelected[i] = false;
        } else if (apiStatus != null) {
          showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) =>
                ErrorDialog(message: apiStatus.message),
          );
        }
      } else if (uploadedImages[i]!.imgPath != '') {
        reorderObjList.add(
          ImageReorderParameterHolder(
            imgId: uploadedImages[i]!.imgId,
            ordering: (i + 1).toString(),
          ),
        );
      }
    }

    if (reorderObjList.isNotEmpty) {
      await PsProgressDialog.showDialog(context);

      final List<Map<String, dynamic>> reorderMapList =
      <Map<String, dynamic>>[
        for (final ImageReorderParameterHolder d in reorderObjList) d.toMap(),
      ];

      final PsResource<ApiStatus>? apiStatus =
      await galleryProvider!.postReorderImages(
        reorderMapList,
        valueHolder!.loginUserId!,
      );

      PsProgressDialog.dismissDialog();

      if (apiStatus?.data != null && apiStatus!.status == PsStatus.SUCCESS) {
        isImageSelected = isImageSelected.map<bool>((bool v) => false).toList();
        reorderObjList.clear();
      } else {
        showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) =>
              ErrorDialog(message: apiStatus?.message),
        );
      }
    }

    if (isSelectedVideoImagePath) {
      await PsProgressDialog.showDialog(
        context,
        message: Utils.getString(context, 'progressloading_video_uploading'),
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
        PsProgressDialog.dismissDialog();
        isSelectedVideoImagePath = false;
        isVideoDone = isSelectedVideoImagePath;
      } else {
        PsProgressDialog.dismissDialog();
        _showRetryDialog(
          Utils.getString(context, 'item_entry__fail_to_upload_video'),
              () => _uploadImage(
            itemId,
            createdProduct: createdProduct,
            shareImageUrl: shareImageUrl,
          ),
        );
        return;
      }
    }

    if (!(isImageSelected.contains(true) || isVideoDone)) {
      final String effectiveShareImageUrl =
      (shareImageUrl ?? '').trim().isNotEmpty
          ? shareImageUrl!.trim()
          : _resolveLocalWishImageForShare();

      if (createdProduct != null) {
        _attachWishDefaultPhotoForImmediateUse(
          createdProduct,
          firstUploadedWishPhoto,
        );
      }

      await _notifyWishUploaded();

      // ✅ بدل SuccessDialog → Taapdeel BottomSheet + Home
      await _showWishSubmittedSheetThenGoHome(
        createdProduct: createdProduct,
        shareImageUrl: effectiveShareImageUrl,
      );
    }
  }

  void _attachWishDefaultPhotoForImmediateUse(
      Product product,
      DefaultPhoto? uploadedPhoto,
      ) {
    if (uploadedPhoto == null) return;

    // The add API returns the wish before its image-upload request finishes.
    // Attach the uploaded photo to the same in-memory object when the model
    // allows it, so the immediate share flow does not depend on a second reload.
    try {
      final dynamic dynamicProduct = product;
      dynamicProduct.defaultPhoto = uploadedPhoto;
    } catch (_) {}
  }

  Future<void> _notifyWishUploaded() async {
    final Function? callback = widget.onItemUploaded;
    if (callback == null) return;

    try {
      final dynamic result = callback();
      if (result is Future) await result;
    } catch (e) {
      debugPrint('wish onItemUploaded callback error: $e');
    }
  }

  void _updateImagesFromVideo(String imagePath, int index) {
    if (!mounted) return;
    setState(() {
      if (index == -2 && imagePath.isNotEmpty) {
        videoFilePath = imagePath;
        isSelectedVideoImagePath = true;
      }
    });
  }

  Future<dynamic> _getImageFromVideo(String videoPathUrl) async {
    videoFileThumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPathUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 120,
      quality: 25,
    );
    return videoFileThumbnailPath;
  }

  void _onReorder(int oldIndex, int newIndex) {
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
      } else if (uploadedImages[newIndex]!.imgPath != '' &&
          uploadedImages[newIndex]!.imgId != '') {
        setState(() {
          uploadedImages[oldIndex] = uploadedImages[newIndex];
          uploadedImages[newIndex] = DefaultPhoto(imgId: '', imgPath: '');
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
      } else if (uploadedImages[newIndex]!.imgPath != '' &&
          uploadedImages[newIndex]!.imgId != '') {
        setState(() {
          uploadedImages[oldIndex] = uploadedImages[newIndex];
          uploadedImages[newIndex] = DefaultPhoto(imgId: '', imgPath: '');
          cameraImagePath[newIndex] = cameraImagePath[oldIndex];
          cameraImagePath[oldIndex] = null;

          isImageSelected[newIndex] = true;
          isImageSelected[oldIndex] = true;
        });
      }
    } else if (uploadedImages[oldIndex]!.imgPath != '' &&
        uploadedImages[oldIndex]!.imgId != '') {
      if (galleryImageAsset[newIndex] != null) {
        setState(() {
          uploadedImages[newIndex] = uploadedImages[oldIndex];
          uploadedImages[oldIndex] = DefaultPhoto(imgId: '', imgPath: '');
          galleryImageAsset[oldIndex] = galleryImageAsset[newIndex];
          galleryImageAsset[newIndex] = null;

          isImageSelected[newIndex] = true;
          isImageSelected[oldIndex] = true;
        });
      } else if (cameraImagePath[newIndex] != null &&
          cameraImagePath[newIndex] != '') {
        setState(() {
          uploadedImages[newIndex] = uploadedImages[oldIndex];
          uploadedImages[oldIndex] = DefaultPhoto(imgId: '', imgPath: '');
          cameraImagePath[oldIndex] = cameraImagePath[newIndex];
          cameraImagePath[newIndex] = null;

          isImageSelected[newIndex] = true;
          isImageSelected[oldIndex] = true;
        });
      } else if (uploadedImages[newIndex]!.imgPath != '' &&
          uploadedImages[newIndex]!.imgId != '') {
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

  void _updateImages(List<XFile> resultList, int index, int currentIndex) {
    setState(() {
      images = resultList;

      if (index != -1 && resultList.isNotEmpty) {
        galleryImageAsset[currentIndex] = resultList[0];
        isImageSelected[currentIndex] = true;
      }

      if (index == -1) {
        int indexToStart = 0;
        for (indexToStart = 0; indexToStart < currentIndex; indexToStart++) {
          if (!isImageSelected[indexToStart] &&
              indexToStart > galleryProvider!.selectedImageList!.length - 1) {
            break;
          }
        }
        for (int i = 0;
        i < resultList.length && indexToStart < widget.maxImageCount;
        i++, indexToStart++) {
          galleryImageAsset[indexToStart] = resultList[i];
          isImageSelected[indexToStart] = true;
        }
      }
    });

    // Run AI on first image after setState to ensure state is updated.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryRunAiOnFirstImageIfNeeded();
    });
  }



  Map<String, dynamic> _buildHawadeetHighlightMap() {
    final String shareThemeId = _selectedShareThemeId.trim().isEmpty
        ? (WishShareThemes.themes.isNotEmpty ? WishShareThemes.themes.first.id : '')
        : _selectedShareThemeId.trim();
    final String themeId = _selectedStoryThemeId.trim().isEmpty
        ? WishStoryCardThemes.defaultThemeId
        : _selectedStoryThemeId.trim();
    final WishStoryCardTheme selectedTheme = WishStoryCardThemes.byId(themeId);
    final String cardTitle = _storyCardTitleController.text.trim();
    final String productTitle = userInputListingTitle.text.trim();
    final String sceneOne = _hawadeetHookController.text.trim().isNotEmpty
        ? _hawadeetHookController.text.trim()
        : (productTitle.isEmpty ? '' : 'بدور على $productTitle ومش لازم أشتري جديد.');
    final String sceneTwo = _hawadeetStoryController.text.trim();
    final bool hasStory = cardTitle.isNotEmpty || sceneOne.isNotEmpty || sceneTwo.isNotEmpty;

    return <String, dynamic>{
      'story_type': hasStory ? 'template' : 'wish_only',
      'story_title': cardTitle,
      'story_card_title': cardTitle,
      'hook_phrase': sceneOne,
      'story_text': sceneTwo,
      'dialogue_one': sceneOne,
      'dialogue_two': sceneTwo,
      'scene_1': sceneOne,
      'scene_2': sceneTwo,
      'narrator_comment': hasStory
          ? 'كل حاجة نفسنا فيها ليها حدوتة، ويمكن حد غيرك يكون عنده الحل.'
          : '',
      'persona_type': _selectedPersonaType,
      'need_reason': _selectedNeedReason,
      'template_id': _selectedHookTemplateId,
      'story_theme_id': shareThemeId,
      'theme_id': shareThemeId,
      'share_theme_id': shareThemeId,
      'legacy_story_theme_id': selectedTheme.id,
      'role_one_label': selectedTheme.roleOne,
      'role_two_label': selectedTheme.roleTwo,
      'tags_csv': '',
      'me_too_count': '0',
      'happened_like_me_count': '0',
      'share_count': '0',
      'offer_count': '0',
      'hawadeet_status': hasStory ? 'pending' : 'draft',
      'user_reacted_me_too': '0',
      'user_reacted_happened_like_me': '0',
    };
  }

  String _buildHawadeetHighlightJson() {
    return jsonEncode(_buildHawadeetHighlightMap());
  }

  Widget _buildImagePickerBlock({required bool compact}) {
    return Consumer<GalleryProvider>(
      builder: (BuildContext context, GalleryProvider gProvider, Widget? _) {
        if (bindImageFirstTime &&
            gProvider.galleryList.data != null &&
            gProvider.galleryList.data!.isNotEmpty) {
          for (int i = 0;
          i < widget.maxImageCount && i < gProvider.galleryList.data!.length;
          i++) {
            if (gProvider.galleryList.data![i].imgId != null) {
              uploadedImages[i] = gProvider.galleryList.data![i];
            }
          }
          bindImageFirstTime = false;
        }

        return ImageUploadHorizontalList(
          flag: widget.flag,
          images: images,
          selectedImageList: uploadedImages,
          updateImages: _updateImages,
          updateImagesFromCustomCamera: _updateImagesFromVideo,
          videoFilePath: videoFilePath,
          videoFileThumbnailPath: videoFileThumbnailPath,
          selectedVideoImagePath: selectedVideoImagePath,
          updateImagesFromVideo: _updateImagesFromVideo,
          selectedVideoPath: selectedVideoPath,
          getImageFromVideo: _getImageFromVideo,
          imageDesc1Controller: gProvider.imageDesc1Controller,
          provider: _itemEntryProvider,
          galleryProvider: gProvider,
          onReorder: _onReorder,
          cameraImagePath: cameraImagePath,
          galleryImagePath: galleryImageAsset,
          enableOrbit: true,
          ringCount: compact ? 1 : 2,
          orbitPadding: compact ? const EdgeInsets.all(6) : const EdgeInsets.all(10),
          orbitCategoryLabel: categoryController.text,
          orbitSubCategoryLabel: subCategoryController.text,
          orbitTags: _itemEntryProvider?.tags ?? <String>[],
        );
      },
    );
  }


  void _bindItemDataOnce(ItemEntryProvider provider) {
    if (!bindDataFirstTime) return;

    final Product? item = provider.item;
    if (item == null || item.id == null) return;

    userInputListingTitle.text = item.title ?? '';
    userInputDescription.text = item.description ?? '';

    categoryController.text = item.category?.catName ?? '';
    subCategoryController.text = item.subCategory?.name ?? '';

    provider.categoryId = item.category?.catId;
    provider.subCategoryId = item.subCategory?.id;

    if (valueHolder?.isSubLocation == PsConst.ONE) {
      provider.itemLocationTownshipId = item.itemLocationTownship?.id;
    }

    provider.itemLocationId = item.itemLocation?.id;

    selectedVideoImagePath = item.videoThumbnail?.imgPath;
    selectedVideoPath = item.video?.imgPath;

    bindDataFirstTime = false;
  }

  Widget _buildWishEntryComposer(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildEntryThemeChooser(isArabic),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: _isThemedWishEntry
              ? _buildThemedWishEntryForm(isArabic)
              : _buildProductDataEntryForm(isArabic),
        ),
      ],
    );
  }

  Widget _buildEntryThemeChooser(bool isArabic) {
    final List<ShareThemeDefinition> themes = WishShareThemes.themes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF24A9C4).withOpacity(0.18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF043757).withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            isArabic ? 'اختار شكل كارت الشير' : 'Choose the share card design',
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF043757),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isArabic
                ? 'أي ثيم تختاره هنا سيظهر بنفس تصميم ملف WishShareThemes في المعاينة والشير.'
                : 'The selected theme is rendered using the exact WishShareThemes builder used for sharing.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PsColors.textPrimary.withOpacity(0.62),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: themes.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, int index) {
                if (index == 0) {
                  final bool selected = _selectedEntryModeId == _productDataEntryModeId;
                  return _EntryThemeChoiceCard(
                    selected: selected,
                    label: isArabic ? 'بيانات المنتج' : 'Product data',
                    subtitle: isArabic ? 'إدخال سريع وبسيط' : 'Fast plain entry',
                    icon: Icons.inventory_2_outlined,
                    accent: const Color(0xFF0C587A),
                    gradient: const <Color>[Color(0xFF043757), Color(0xFF24A9C4)],
                    onTap: () => setState(() => _selectedEntryModeId = _productDataEntryModeId),
                  );
                }

                final ShareThemeDefinition theme = themes[index - 1];
                final List<Color> gradient = theme.gradient.isNotEmpty
                    ? theme.gradient
                    : const <Color>[Color(0xFF043757), Color(0xFF24A9C4)];
                final bool selected = _selectedEntryModeId == theme.id;

                return _EntryThemeChoiceCard(
                  selected: selected,
                  label: theme.label,
                  subtitle: theme.subtitle,
                  icon: _iconForShareTheme(theme.id),
                  accent: gradient.last,
                  gradient: gradient,
                  onTap: () {
                    setState(() {
                      _selectedEntryModeId = theme.id;
                      _selectedShareThemeId = theme.id;



                      if (_hawadeetHookController.text.trim().isEmpty &&
                          userInputListingTitle.text.trim().isNotEmpty) {
                        _hawadeetHookController.text =
                        'بدور على ${userInputListingTitle.text.trim()} ومش لازم أشتري جديد.';
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForShareTheme(String id) {
    switch (id) {
      case 'wish_dream_ticket':
        return Icons.confirmation_number_outlined;
      case 'wish_search_radar':
        return Icons.radar_rounded;
      case 'wish_empty_shelf':
        return Icons.shelves;
      case 'wish_swap_recipe':
        return Icons.receipt_long_rounded;
      case 'wish_mission_card':
        return Icons.flag_outlined;
      case 'wish_gift_hint':
        return Icons.card_giftcard_rounded;
      case 'wish_market_note':
        return Icons.checklist_rtl_rounded;
      case 'wish_missing_piece':
        return Icons.extension_outlined;
      case 'wish_clean_request':
        return Icons.auto_awesome_rounded;
      case 'wish_chat_request':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.favorite_border_rounded;
    }
  }

  ShareThemeDefinition _selectedWishShareTheme() {
    final List<ShareThemeDefinition> themes = WishShareThemes.themes;
    if (themes.isEmpty) {
      throw StateError('WishShareThemes.themes is empty.');
    }

    final String selectedId = _selectedShareThemeId.trim();
    for (final ShareThemeDefinition theme in themes) {
      if (theme.id == selectedId) return theme;
    }
    return themes.first;
  }

  String _currentLocalWishImagePath() {
    for (final XFile? image in galleryImageAsset) {
      final String path = (image?.path ?? '').trim();
      if (path.isNotEmpty) return path;
    }

    for (final String? path in cameraImagePath) {
      final String clean = (path ?? '').trim();
      if (clean.isNotEmpty) return clean;
    }

    for (final DefaultPhoto? photo in uploadedImages) {
      final String path = (photo?.imgPath ?? '').trim();
      if (path.isNotEmpty) return path;
    }

    return '';
  }


  bool get _hasThemeHeroImage => _currentLocalWishImagePath().trim().isNotEmpty;

  Future<void> _showThemeImagePickerSheet() async {
    if (!mounted) return;
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isArabic ? 'اختار صورة المنتج للثيم' : 'Choose product image',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF043757),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'الصورة ستظهر داخل مكان الصورة في كارت الشير، وسيستخدمها AI لاستكمال البيانات.'
                        : 'The image appears inside the share card image area and AI will complete the data.',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.58),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF0C587A)),
                    title: Text(isArabic ? 'اختيار من المعرض' : 'Choose from gallery'),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _pickThemeHeroImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera_rounded, color: Color(0xFF0C587A)),
                    title: Text(isArabic ? 'التقاط صورة بالكاميرا' : 'Take a photo'),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _pickThemeHeroImage(ImageSource.camera);
                    },
                  ),
                  if (_hasThemeHeroImage)
                    ListTile(
                      leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB42318)),
                      title: Text(isArabic ? 'حذف الصورة الحالية' : 'Remove current image'),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _clearThemeHeroImage();
                      },
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickThemeHeroImage(ImageSource source) async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1800,
      );
      if (picked == null) return;
      if (!mounted) return;

      setState(() {
        images = <XFile>[picked];
        galleryImageAsset[0] = source == ImageSource.gallery ? picked : null;
        cameraImagePath[0] = source == ImageSource.camera ? picked.path : null;
        uploadedImages[0] = DefaultPhoto(imgId: '', imgPath: '');
        isImageSelected[0] = true;

        // Keep only the first image for themed wish cards to avoid duplicate image UI.
        for (int i = 1; i < widget.maxImageCount; i++) {
          galleryImageAsset[i] = null;
          cameraImagePath[i] = null;
          uploadedImages[i] = DefaultPhoto(imgId: '', imgPath: '');
          isImageSelected[i] = false;
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryRunAiOnFirstImageIfNeeded();
      });
    } catch (e) {
      debugPrint('theme image pick error: $e');
      if (!mounted) return;
      final bool isArabic = Directionality.of(context) == TextDirection.rtl;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'لم نتمكن من اختيار الصورة.' : 'Could not pick the image.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearThemeHeroImage() {
    if (!mounted) return;
    setState(() {
      images = <XFile>[];
      for (int i = 0; i < widget.maxImageCount; i++) {
        galleryImageAsset[i] = null;
        cameraImagePath[i] = null;
        uploadedImages[i] = DefaultPhoto(imgId: '', imgPath: '');
        isImageSelected[i] = false;
      }
      _lastAiImagePath = null;
    });
  }

  ShareProductData _buildWishPreviewShareData() {
    final String title = userInputListingTitle.text.trim().isEmpty
        ? 'اسم المنتج المطلوب'
        : userInputListingTitle.text.trim();

    final String description = _hawadeetStoryController.text.trim().isNotEmpty
        ? _hawadeetStoryController.text.trim()
        : userInputDescription.text.trim();

    return ShareProductData.from(
      _WishEntryPreviewProduct(
        previewTitle: title,
        previewDescription: description,
        previewCategory: categoryController.text.trim(),
        previewSubCategory: subCategoryController.text.trim(),
        previewHighlightInfo: _buildHawadeetHighlightJson(),
      ),
      _currentLocalWishImagePath(),
      '',
    );
  }

  Widget _buildExactShareThemePreview({
    required bool isArabic,
    required ShareThemeDefinition shareTheme,
  }) {
    final Color accent = shareTheme.gradient.isNotEmpty
        ? shareTheme.gradient.last
        : const Color(0xFF24A9C4);
    final bool hasImage = _hasThemeHeroImage;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accent.withOpacity(0.22)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF043757).withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double height = (width * 1.33).clamp(420.0, 560.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.touch_app_rounded, color: accent, size: 17),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'اضغط على الكارت لإضافة أو تغيير صورة المنتج'
                            : 'Tap the card to add or change the product image',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF043757),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _showThemeImagePickerSheet,
                  child: SizedBox(
                    width: double.infinity,
                    height: height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: shareTheme.builder(
                              context,
                              _buildWishPreviewShareData(),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.54),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.36)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    hasImage ? Icons.edit_rounded : Icons.add_photo_alternate_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    hasImage
                                        ? (isArabic ? 'تغيير الصورة' : 'Change image')
                                        : (isArabic ? 'أضف الصورة هنا' : 'Add image here'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductDataEntryForm(bool isArabic) {
    return Container(
      key: const ValueKey<String>('product_data_form'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF24A9C4).withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildImagePickerBlock(compact: false),
          const SizedBox(height: 12),
          TaapdeelTextField(
            controller: userInputListingTitle,
            label: isArabic ? 'اسم المنتج' : 'Product name',
            hint: isArabic
                ? 'مثال: فستان، روب تخرج، كتب خارجية، شنطة مدرسة'
                : 'Example: dress, graduation robe, books, school bag',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TaapdeelTextField(
            controller: userInputDescription,
            label: isArabic ? 'تفاصيل المنتج المطلوب (اختياري)' : 'Requested item details (optional)',
            hint: isArabic
                ? 'اكتب المقاس، اللون، الحالة، أو أي تفاصيل تساعد في التبديل…'
                : 'Size, color, condition, or any details that help the swap…',
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            minLines: 3,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  Widget _buildThemedWishEntryForm(bool isArabic) {
    final WishStoryCardTheme theme = WishStoryCardThemes.byId(_selectedStoryThemeId);
    final ShareThemeDefinition shareTheme = _selectedWishShareTheme();
    final String productTitle = userInputListingTitle.text.trim();
    final String storyTitle = _storyCardTitleController.text.trim();
    final String story = _hawadeetStoryController.text.trim();

    return Container(
      key: ValueKey<String>('themed_form_${theme.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[
            theme.cardBackground,
            Color.lerp(theme.cardBackground, theme.accent, 0.08)!,
          ],
        ),
        border: Border.all(color: theme.accent.withOpacity(0.28), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.accent.withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: theme.headerGradient),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(theme.icon, color: Colors.white, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        storyTitle.isEmpty ? theme.label : storyTitle,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${theme.roleOne}  •  ${theme.roleTwo}',
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildExactShareThemePreview(
            isArabic: isArabic,
            shareTheme: shareTheme,
          ),
          const SizedBox(height: 10),
          _ThemedInputField(
            controller: userInputListingTitle,
            label: isArabic ? 'اسم المنتج' : 'Product name',
            hint: isArabic ? 'مثال: فستان أحمر' : 'Example: red dress',
            theme: theme,
            maxLines: 1,
          ),
          const SizedBox(height: 10),
          _ThemedInputField(
            controller: userInputDescription,
            label: isArabic ? 'وصف المنتج من الذكاء الاصطناعي' : 'AI product description',
            hint: isArabic
                ? 'سيتم ملء الوصف هنا تلقائياً عند إضافة صورة، ويمكن تعديله يدوياً…'
                : 'This description is filled by AI when an image is added, and can be edited…',
            theme: theme,
            maxLines: 3,
            minLines: 2,
            maxLength: 260,
          ),
          const SizedBox(height: 12),
          _ThemedInputField(
            controller: _storyCardTitleController,
            label: isArabic ? 'عنوان الاعلان' : 'Story title (5 words)',
            hint: isArabic ? 'مثال: الفستان اللي محتاجاه بجد' : 'Example: The dress I really need',
            theme: theme,
            maxLines: 1,
            inputFormatters: const <TextInputFormatter>[
              _MaxWordsTextInputFormatter(10)
            ],
          ),
          const SizedBox(height: 8),
          _buildSuggestedStoryTitleChips(
            isArabic: isArabic,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _ThemedInputField(
            controller: _hawadeetStoryController,
            label: isArabic ? 'الوصف' : 'Description (2 lines)',
            hint: isArabic
                ? 'اكتب وصف الحاجه اللي تتمناها…'
                : 'Write the story in only two lines…',
            theme: theme,
            maxLines: 2,
            minLines: 2,
            maxLength: 150,
          ),



        ],
      ),
    );
  }



  // ---------------------------------------------------------------------------
  //  SUBMIT
  // ---------------------------------------------------------------------------
  Future<void> _submitWishItem() async {
    if (_submittingWish) return;

    final bool isArabic = Directionality.of(context) == TextDirection.rtl;

    if (_itemEntryProvider == null || valueHolder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'الصفحة لم تكتمل بعد، حاول مرة أخرى.' : 'The page is still loading. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ItemEntryProvider provider = _itemEntryProvider!;
    final PsValueHolder vh = valueHolder!;
    final String loginUserId = (vh.loginUserId ?? '').trim();
    provider.itemLocationId ??= vh.locationId;
    provider.itemLocationTownshipId ??=
    (vh.isSubLocation == PsConst.ONE) ? vh.locationTownshipId : '';

    if (loginUserId.isEmpty || loginUserId == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'يجب تسجيل الدخول قبل الحفظ.' : 'Please login before saving the wish.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final String lat = (vh.isSubLocation == PsConst.ONE
        ? vh.locationTownshipLat
        : vh.locationLat) ??
        '';
    final String lng = (vh.isSubLocation == PsConst.ONE
        ? vh.locationTownshipLng
        : vh.locationLng) ??
        '';


    // ============================
    // رغبة مخصصة فقط
    // ============================
        {
      if (userInputListingTitle.text.trim().isEmpty) {
        showDialog<dynamic>(
          context: context,
          builder: (_) => ErrorDialog(
            message:
            isArabic ? 'اكتب اسم المنتج اللي بتتمناه.' : 'Please enter what you need.',
          ),
        );
        return;
      }

      if (_isThemedWishEntry) {
        if (_storyCardTitleController.text.trim().isEmpty) {
          showDialog<dynamic>(
            context: context,
            builder: (_) => ErrorDialog(
              message: isArabic ? 'اكتب عنوان.' : 'Please enter the  title.',
            ),
          );
          return;
        }
        if (_wordCount(_storyCardTitleController.text) > 5) {
          showDialog<dynamic>(
            context: context,
            builder: (_) => ErrorDialog(
              message: isArabic ? 'العنوان يجب ألا يزيد عن 10 كلمات.' : 'Story title must not exceed 5 words.',
            ),
          );
          return;
        }
        if (_hawadeetStoryController.text.trim().isEmpty) {
          showDialog<dynamic>(
            context: context,
            builder: (_) => ErrorDialog(
              message: isArabic ? 'اكتب الوصف في سطرين.' : 'Please write the two-line story.',
            ),
          );
          return;
        }
        final int storyLines = _hawadeetStoryController.text.trim().split(RegExp(r'\n+')).length;
        if (storyLines > 2) {
          showDialog<dynamic>(
            context: context,
            builder: (_) => ErrorDialog(
              message: isArabic ? 'الوصف يجب ألا تزيد عن سطرين.' : 'Story must not exceed two lines.',
            ),
          );
          return;
        }
      }
    }

    if (mounted) {
      setState(() => _submittingWish = true);
    } else {
      _submittingWish = true;
    }

    final ItemEntryParameterHolder param = ItemEntryParameterHolder(
      id: widget.flag == PsConst.EDIT_ITEM ? (widget.item?.id ?? '') : '',
      title: userInputListingTitle.text.trim(),
      description: userInputDescription.text.trim(),
      catId: provider.categoryId ?? '',
      subCatId: provider.subCategoryId ?? '',
      addedUserId: loginUserId,
      itemLocationId: provider.itemLocationId ?? '',
      itemLocationTownshipId: provider.itemLocationTownshipId ?? '',
      latitude: lat,
      longitude: lng,
      itemTypeId: provider.itemTypeId ?? '',
      itemPriceTypeId: provider.itemPriceTypeId ?? '',
      conditionOfItemId: provider.itemConditionId ?? '',
      dealOptionId: provider.itemDealOptionId ?? '',
      price: '',
      discountRate: '',
      address: '',
      dealOptionRemark: '',
      highlightInfomation: _buildHawadeetHighlightJson(),
      businessMode: provider.isCheckBoxSelect ? PsConst.ONE : PsConst.ZERO,
    );

    try {
      await PsProgressDialog.showDialog(
        context,
        message: Utils.getString(context, 'progressloading_item_uploading'),
      );

      final PsResource<Product> itemData =
      await provider.postWishItemEntry(param.toMap(), loginUserId);

      PsProgressDialog.dismissDialog();

      if (itemData.status == PsStatus.SUCCESS && itemData.data != null) {
        final Product createdWishProduct = itemData.data!;
        final String shareImageUrl = _resolveLocalWishImageForShare();
        final String wishId = createdWishProduct.id ?? '';
        provider.itemId = wishId;

        // ✅ NEW: save_tags after wish created
        // Priority:
        // 1) AI tags stored in provider.tags / provider.tags_en
        // 2) If user selected catalog tags, store their labels
        final List<String> tagsArFromAi = provider.tags;
        final List<String> tagsEnFromAi = provider.tags_en;

        if (tagsArFromAi.isNotEmpty || tagsEnFromAi.isNotEmpty) {
          await _saveWishTagsToDb(
            wishId: wishId,
            tagsAr: tagsArFromAi,
            tagsEn: tagsEnFromAi,
            source: 'ai',
            confidence: provider.tags_confidence,
          );
        }

        if (galleryProvider != null && provider.itemId != null) {
          await _uploadImage(
            provider.itemId!,
            createdProduct: createdWishProduct,
            shareImageUrl: shareImageUrl,
          );
        } else {
          await _showWishSubmittedSheetThenGoHome(
            createdProduct: createdWishProduct,
            shareImageUrl: shareImageUrl,
          );
        }
      } else {
        showDialog<dynamic>(
          context: context,
          builder: (_) => ErrorDialog(message: itemData.message),
        );
      }
    } catch (e) {
      PsProgressDialog.dismissDialog();
      showDialog<dynamic>(
        context: context,
        builder: (_) => ErrorDialog(message: e.toString()),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingWish = false);
      } else {
        _submittingWish = false;
      }
    }
  }

  // ---------------------------------------------------------------------------
  //  UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    valueHolder = Provider.of<PsValueHolder>(context);

    repo1 = Provider.of<ProductRepository>(context);
    galleryRepository = Provider.of<GalleryRepository>(context);
    userRepository = Provider.of<UserRepository>(context);
    categoryRepository = Provider.of<CategoryRepository>(context);
    subCategoryRepository = Provider.of<SubCategoryRepository>(context);


    final bool isArabic = Directionality.of(context) == TextDirection.rtl;

    return PsWidgetWithMultiProvider(
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ItemEntryProvider>(
            lazy: false,
            create: (BuildContext context) {
              _itemEntryProvider =
                  ItemEntryProvider(repo: repo1, psValueHolder: valueHolder);
              _itemEntryProvider!.item = widget.item;
              _itemEntryProvider!.itemLocationId = valueHolder!.locationId;

              if (valueHolder!.isSubLocation == PsConst.ONE &&
                  (valueHolder!.locationTownshipLat ?? '').isNotEmpty) {
                latlng = LatLng(
                  double.parse(valueHolder!.locationTownshipLat),
                  double.parse(valueHolder!.locationTownshipLng),
                );
                _itemEntryProvider!.itemLocationTownshipId =
                    valueHolder!.locationTownshipId;
              } else {
                latlng = LatLng(
                  double.parse(valueHolder!.locationLat!),
                  double.parse(valueHolder!.locationLng!),
                );
              }
              final String? itemId = widget.item?.id;
              if (itemId != null && itemId.isNotEmpty) {
                _itemEntryProvider!.getItemFromDB(itemId);
              }

              return _itemEntryProvider!;
            },
          ),
          ChangeNotifierProvider<GalleryProvider>(
            lazy: false,
            create: (BuildContext context) {
              galleryProvider = GalleryProvider(repo: galleryRepository!);
              if (widget.flag == PsConst.EDIT_ITEM &&
                  widget.item?.defaultPhoto?.imgParentId != null) {
                galleryProvider!.loadImageList(
                  widget.item!.defaultPhoto!.imgParentId,
                  PsConst.ITEM_TYPE,
                );
              }
              return galleryProvider!;
            },
          ),
          ChangeNotifierProvider<UserProvider>(
            lazy: false,
            create: (BuildContext context) {
              userProvider =
                  UserProvider(repo: userRepository, psValueHolder: valueHolder);
              userProvider!.getUser(valueHolder!.loginUserId);
              return userProvider!;
            },
          ),
          ChangeNotifierProvider<CategoryProvider>(
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
          ChangeNotifierProvider<SubCategoryProvider>(
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
          builder: (BuildContext context, UserProvider provider, Widget? child) {
            final bool canPost = widget.flag == PsConst.EDIT_ITEM ||
                (valueHolder!.isPaidApp != PsConst.ONE ||
                    provider.user.data != null);

            final String bottomLabel = _submittingWish
                ? (isArabic ? 'جاري الحفظ...' : 'Saving...')
                : (isArabic ? 'حفظ' : 'Save wish');

            return TaapdeelScaffold(
              safeTop: true,
              safeBottom: false,
              padding: EdgeInsets.zero,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: Text(
                  isArabic ? 'احكي أمنيتك' : 'Tell Your Wish',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: PsColors.textPrimary,
                  ),
                ),
              ),
              bottom: canPost
                  ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: TaapdeelButton(
                    label: bottomLabel,
                    isPrimary: true,
                    isExpanded: true,
                    onPressed: () {
                      if (_submittingWish) return;
                      _submitWishItem();
                    },
                  ),
                ),
              )
                  : null,
              body: Builder(
                builder: (_) {
                  if (widget.flag == PsConst.ADD_NEW_ITEM &&
                      valueHolder!.isPaidApp == PsConst.ONE &&
                      provider.user.data == null) {
                    return const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (!canPost) {
                    return InAppPurchaseBuyPackageDialog(
                      onInAppPurchaseTap: () async {
                        final dynamic returnData = await Navigator.pushNamed(
                          context,
                          RoutePaths.buyPackage,
                          arguments: <String, dynamic>{
                            'android': valueHolder?.packageAndroidKeyList,
                            'ios': valueHolder?.packageIOSKeyList,
                          },
                        );

                        if (returnData != null) {
                          setState(() {
                            userProvider!.user.data!.remainingPost = returnData;
                          });
                        } else {
                          provider.getUser(valueHolder!.loginUserId);
                        }
                      },
                    );
                  }

                  // ✅ Single custom Wish Item composer only.
                  return _mintGradientBackground(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: PsDimens.space16,
                        end: PsDimens.space16,
                        top: PsDimens.space16,
                        bottom: 12,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 110),
                        physics: const BouncingScrollPhysics(),
                        child: Consumer<ItemEntryProvider>(
                          builder: (BuildContext context,
                              ItemEntryProvider iProvider, Widget? _) {
                            _bindItemDataOnce(iProvider);
                            return _buildWishEntryComposer(isArabic);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}


class _WishEntryPreviewProduct extends Product {
  _WishEntryPreviewProduct({
    required this.previewTitle,
    required this.previewDescription,
    required this.previewCategory,
    required this.previewSubCategory,
    required this.previewHighlightInfo,
  }) : super();

  final String previewTitle;
  final String previewDescription;
  final String previewCategory;
  final String previewSubCategory;
  final String previewHighlightInfo;

  @override
  String? get id => 'wish_entry_preview';

  @override
  String? get title => previewTitle;

  @override
  String? get description => previewDescription;

  @override
  String? get price => '';

  // ShareProductData.from uses dynamic access to match API Product fields.
  // The entry-screen preview object is local, so these getters prevent
  // NoSuchMethodError while keeping the exact share-theme renderer.
  String? get highlight_info => previewHighlightInfo;
  String? get highlightInfomation => previewHighlightInfo;
  String? get highlightInformation => previewHighlightInfo;
  String? get highlight_info_json => previewHighlightInfo;
  String? get itemHighlightInfo => previewHighlightInfo;

  String? get categoryName => previewCategory;
  String? get subCategoryName => previewSubCategory;
  String? get catName => previewCategory;
  String? get subCatName => previewSubCategory;
  String? get category_name => previewCategory;
  String? get sub_category_name => previewSubCategory;

  String? get catId => '';
  String? get subCatId => '';
  String? get cat_id => '';
  String? get sub_cat_id => '';
  String? get lowPrice => '';
  String? get highPrice => '';
  String? get low_price => '';
  String? get high_price => '';
  String? get originalPrice => '';
  String? get original_price => '';
  String? get discountRate => '';
  String? get discount_rate => '';
  String? get currencySymbol => '';
  String? get currency_symbol => '';
  String? get itemLocationName => '';
  String? get itemLocationTownshipName => '';
  String? get item_location_name => '';
  String? get item_location_township_name => '';
  String? get conditionOfItemName => '';
  String? get condition_of_item_name => '';
  String? get itemTypeName => '';
  String? get item_type_name => '';
  String? get brand => '';
  String? get dealOptionRemark => '';
  String? get deal_option_remark => '';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) return null;
    return super.noSuchMethod(invocation);
  }
}


class _EntryThemeChoiceCard extends StatelessWidget {
  const _EntryThemeChoiceCard({
    required this.selected,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.gradient,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 152,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : accent.withOpacity(0.20),
            width: selected ? 2 : 1.1,
          ),
          boxShadow: selected
              ? <BoxShadow>[
            BoxShadow(
              color: accent.withOpacity(0.16),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ]
              : const <BoxShadow>[],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: LinearGradient(colors: gradient),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const Spacer(),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: accent, size: 19),
              ],
            ),
            const Spacer(),
            Text(
              label,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF043757),
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withOpacity(0.52),
                fontWeight: FontWeight.w700,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemedInputField extends StatelessWidget {
  const _ThemedInputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.theme,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final WishStoryCardTheme theme;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: theme.accent,
            fontWeight: FontWeight.w900,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
          style: TextStyle(
            color: theme.titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            height: 1.35,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            counterText: '',
            filled: true,
            fillColor: Colors.white.withOpacity(0.84),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.accent.withOpacity(0.18)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.accent, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _MaxWordsTextInputFormatter extends TextInputFormatter {
  const _MaxWordsTextInputFormatter(this.maxWords);

  final int maxWords;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final String text = newValue.text;
    final List<String> words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.trim().isNotEmpty)
        .toList();

    if (words.length <= maxWords) return newValue;

    final String limited = words.take(maxWords).join(' ');
    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

