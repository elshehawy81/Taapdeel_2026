import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:taapdeel/utils/taapdeel_share_links.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/product.dart';

import 'core/share_product_data.dart';
import 'core/share_theme_definition.dart';
import 'core/share_theme_registry.dart';
import 'widgets/share_preview_card.dart';
import 'widgets/share_theme_selector.dart';

class ProductShareOptions {
  const ProductShareOptions._();

  static Future<void> show({
    required BuildContext context,
    required Product product,
    required String dynamicLink,
    required String imageUrl,
  }) async {
    final String resolvedImageUrl = _resolveShareImageUrl(product, imageUrl);
    final String referralCode = _resolveReferralCode(context);
    final String resolvedDynamicLink =
    TaapdeelShareLinks.productOrFallbackWithReferral(
      productId: product.id,
      existingLink: dynamicLink,
      referralCode: referralCode,
      source: 'product_share',
    );

    assert(() {
      debugPrint('SHARE_IMAGE_URL_INPUT => $imageUrl');
      debugPrint('SHARE_IMAGE_URL_RESOLVED => $resolvedImageUrl');
      debugPrint('SHARE_LINK_INPUT => $dynamicLink');
      debugPrint('SHARE_LINK_RESOLVED => $resolvedDynamicLink');
      debugPrint('SHARE_REFERRAL_CODE => $referralCode');
      return true;
    }());

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _ShareSheet(
        product: product,
        dynamicLink: resolvedDynamicLink,
        imageUrl: resolvedImageUrl,
        referralCode: referralCode,
      ),
    );
  }

  static String _resolveReferralCode(BuildContext context) {
    try {
      final PsValueHolder valueHolder = Provider.of<PsValueHolder>(
        context,
        listen: false,
      );

      final String code = (valueHolder.referralCode ?? '').trim();
      if (code.isEmpty || code.toLowerCase() == 'null') return '';

      return code;
    } catch (_) {
      return '';
    }
  }

  static String _resolveShareImageUrl(Product product, String imageUrl) {
    String clean(dynamic value) {
      final String text = (value ?? '').toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return '';
      return text;
    }

    String normalize(dynamic value) {
      String url = clean(value);
      if (url.isEmpty) return '';

      url = url.replaceAll(r'\', '/');

      // During product creation, the share sheet may be opened before the
      // uploaded image has a server URL. In that case we can receive the local
      // compressed image path from ItemEntryView. Keep local paths unchanged.
      if (url.startsWith('file://') ||
          url.startsWith('/data/') ||
          url.startsWith('/storage/')) {
        return url;
      }

      if (url.startsWith('//')) {
        url = 'https:$url';
      }

      // Some existing product images are stored under /uploads/, while older
      // card/image widgets may pass /uploads/thumbnail/. If the thumbnail file
      // is missing on the server, using the original uploaded image path avoids
      // the 404 placeholder in the share card.
      if (url.startsWith('http://') || url.startsWith('https://')) {
        if (url.contains('/uploads/thumbnail/')) {
          return url.replaceAll('/uploads/thumbnail/', '/uploads/');
        }
        return url;
      }

      if (url.startsWith('/')) {
        if (url.contains('/uploads/thumbnail/')) {
          return 'https://taapdeel.com${url.replaceAll('/uploads/thumbnail/', '/uploads/')}';
        }
        return 'https://taapdeel.com$url';
      }

      if (url.startsWith('thumbnail/')) {
        url = url.replaceFirst('thumbnail/', '');
      }

      if (url.startsWith('uploads/thumbnail/')) {
        url = url.replaceFirst('uploads/thumbnail/', 'uploads/');
      }

      if (url.startsWith('uploads/')) {
        return 'https://taapdeel.com/$url';
      }

      return 'https://taapdeel.com/uploads/$url';
    }

    final String fromParam = normalize(imageUrl);
    if (fromParam.isNotEmpty) return fromParam;

    final dynamic dynamicProduct = product;

    try {
      final String fromDefaultPhotoImgPath =
      normalize(dynamicProduct.defaultPhoto?.imgPath);
      if (fromDefaultPhotoImgPath.isNotEmpty) return fromDefaultPhotoImgPath;
    } catch (_) {}

    try {
      final String fromDefaultPhotoImg =
      normalize(dynamicProduct.defaultPhoto?.img);
      if (fromDefaultPhotoImg.isNotEmpty) return fromDefaultPhotoImg;
    } catch (_) {}

    try {
      final String fromDefaultPhotoPath =
      normalize(dynamicProduct.defaultPhoto?.path);
      if (fromDefaultPhotoPath.isNotEmpty) return fromDefaultPhotoPath;
    } catch (_) {}

    try {
      final String fromDefaultPhotoUrl =
      normalize(dynamicProduct.defaultPhoto?.url);
      if (fromDefaultPhotoUrl.isNotEmpty) return fromDefaultPhotoUrl;
    } catch (_) {}

    try {
      final String fromDefaultPhotoOriginal =
      normalize(dynamicProduct.defaultPhoto?.originalImgPath);
      if (fromDefaultPhotoOriginal.isNotEmpty) return fromDefaultPhotoOriginal;
    } catch (_) {}

    try {
      final String fromDefaultPhotoThumbnail =
      normalize(dynamicProduct.defaultPhoto?.thumbnail);
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

    try {
      final String fromProductPhoto = normalize(dynamicProduct.photo);
      if (fromProductPhoto.isNotEmpty) return fromProductPhoto;
    } catch (_) {}

    try {
      final List<dynamic> images = dynamicProduct.images as List<dynamic>;

      for (final dynamic item in images) {
        final String fromImgPath = normalize(item?.imgPath);
        if (fromImgPath.isNotEmpty) return fromImgPath;

        final String fromImg = normalize(item?.img);
        if (fromImg.isNotEmpty) return fromImg;

        final String fromPath = normalize(item?.path);
        if (fromPath.isNotEmpty) return fromPath;

        final String fromUrl = normalize(item?.url);
        if (fromUrl.isNotEmpty) return fromUrl;

        final String fromOriginal = normalize(item?.originalImgPath);
        if (fromOriginal.isNotEmpty) return fromOriginal;

        final String fromThumbnail = normalize(item?.thumbnail);
        if (fromThumbnail.isNotEmpty) return fromThumbnail;
      }
    } catch (_) {}

    return '';
  }
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({
    required this.product,
    required this.dynamicLink,
    required this.imageUrl,
    required this.referralCode,
  });

  final Product product;
  final String dynamicLink;
  final String imageUrl;
  final String referralCode;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}
class _CompactDotsPager extends StatelessWidget {
  const _CompactDotsPager({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    const int maxDots = 5;

    int start = currentIndex - 2;
    int end = currentIndex + 2;

    if (start < 0) {
      end += -start;
      start = 0;
    }

    if (end > count - 1) {
      start -= end - (count - 1);
      end = count - 1;
    }

    if (start < 0) start = 0;

    final List<int> visibleIndexes = <int>[];
    for (int i = start; i <= end && visibleIndexes.length < maxDots; i++) {
      visibleIndexes.add(i);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: visibleIndexes.map((int index) {
        final bool active = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF24A9C4)
                : const Color(0xFFC9DBE7),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }).toList(),
    );
  }
}

class _PagerArrowButton extends StatelessWidget {
  const _PagerArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.32,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD5E7F1),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF0C587A).withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF0C587A),
          ),
        ),
      ),
    );
  }
}


class _ThemeCategorySpec {
  const _ThemeCategorySpec({
    required this.id,
    required this.label,
    required this.themeIds,
  });

  final String id;
  final String label;
  final List<String> themeIds;
}

class _ThemeCategory {
  const _ThemeCategory({
    required this.id,
    required this.label,
    required this.themes,
  });

  final String id;
  final String label;
  final List<ShareThemeDefinition> themes;
}

class _ShareSheetState extends State<_ShareSheet> {
  final GlobalKey _cardKey = GlobalKey();

  late final ShareProductData _data;
  late final ShareThemeSections _sections;
  late final List<_ThemeCategory> _generalThemeCategories;
  late final List<_ThemeCategory> _suitableThemeCategories;
  late final PageController _pageController;
  late ShareThemeSectionType _activeSection;
  late ShareThemeDefinition _selectedTheme;
  String _activeGeneralCategoryId = '';
  String _activeSuitableCategoryId = '';

  bool _busy = false;
  int _currentIndex = 0;

  List<ShareThemeDefinition> get _activeThemes {
    if (_activeSection == ShareThemeSectionType.suitable &&
        _sections.suitableThemes.isNotEmpty) {
      return _activeSuitableThemes;
    }

    if (_sections.generalThemes.isNotEmpty) {
      return _activeGeneralThemes;
    }

    return _activeSuitableThemes;
  }

  List<ShareThemeDefinition> get _activeGeneralThemes {
    if (_generalThemeCategories.isEmpty) {
      return _sections.generalThemes;
    }

    for (final _ThemeCategory category in _generalThemeCategories) {
      if (category.id == _activeGeneralCategoryId) {
        return category.themes;
      }
    }

    return _generalThemeCategories.first.themes;
  }

  List<ShareThemeDefinition> get _activeSuitableThemes {
    if (_suitableThemeCategories.isEmpty) {
      return _sections.suitableThemes;
    }

    for (final _ThemeCategory category in _suitableThemeCategories) {
      if (category.id == _activeSuitableCategoryId) {
        return category.themes;
      }
    }

    return _suitableThemeCategories.first.themes;
  }

  String get _activeThemeListKey =>
      '$_activeSection-$_activeGeneralCategoryId-$_activeSuitableCategoryId';

  @override
  void initState() {
    super.initState();

    final String safeDynamicLink = widget.dynamicLink;

    _data = ShareProductData.from(
      widget.product,
      widget.imageUrl,
      safeDynamicLink,
    );

    _sections = ShareThemeRegistry.sectionsForProduct(
      _data,
      maxSuitableThemes: 30,
      maxGeneralThemes: 30,
    );
    _generalThemeCategories = _buildGeneralThemeCategories(
      _sections.generalThemes,
    );
    _suitableThemeCategories = _buildSuitableThemeCategories(
      _sections.suitableThemes,
    );

    if (_generalThemeCategories.isNotEmpty) {
      _activeGeneralCategoryId = _generalThemeCategories.first.id;
    }
    if (_suitableThemeCategories.isNotEmpty) {
      _activeSuitableCategoryId = _suitableThemeCategories.first.id;
    }

    if (_sections.generalThemes.isNotEmpty) {
      _activeSection = ShareThemeSectionType.general;
      _selectedTheme = _activeGeneralThemes.first;
    } else if (_sections.suitableThemes.isNotEmpty) {
      _activeSection = ShareThemeSectionType.suitable;
      _selectedTheme = _activeSuitableThemes.first;
    } else {
      throw StateError('No share themes were registered.');
    }

    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.86,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changeSection(ShareThemeSectionType section) {
    if (section == _activeSection) return;

    final List<ShareThemeDefinition> nextThemes =
    section == ShareThemeSectionType.suitable
        ? _activeSuitableThemes
        : _activeGeneralThemes;

    if (nextThemes.isEmpty) return;

    setState(() {
      _activeSection = section;
      _currentIndex = 0;
      _selectedTheme = nextThemes.first;
    });

    _jumpToFirstTheme();
  }

  void _changeThemeCategory(
    ShareThemeSectionType section,
    String categoryId,
  ) {
    final bool isGeneral = section == ShareThemeSectionType.general;
    final String activeCategoryId =
        isGeneral ? _activeGeneralCategoryId : _activeSuitableCategoryId;

    if (categoryId == activeCategoryId) return;

    final _ThemeCategory? category = _findThemeCategory(
      isGeneral ? _generalThemeCategories : _suitableThemeCategories,
      categoryId,
    );
    if (category == null || category.themes.isEmpty) return;

    setState(() {
      if (isGeneral) {
        _activeGeneralCategoryId = categoryId;
      } else {
        _activeSuitableCategoryId = categoryId;
      }
      _currentIndex = 0;
      _selectedTheme = category.themes.first;
    });

    _jumpToFirstTheme();
  }

  _ThemeCategory? _findThemeCategory(
    List<_ThemeCategory> categories,
    String categoryId,
  ) {
    for (final _ThemeCategory category in categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  void _jumpToFirstTheme() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.jumpToPage(0);
    });
  }

  List<_ThemeCategory> _buildGeneralThemeCategories(
    List<ShareThemeDefinition> generalThemes,
  ) {
    return _buildThemeCategories(
      generalThemes,
      specs: const <_ThemeCategorySpec>[
        _ThemeCategorySpec(
          id: 'general_neat_simple',
          label: 'شيك',
          themeIds: <String>[
            'general_product_cv',
            'general_quick_review',
            'general_elegant_warm',
            'general_luxury_gold',
            'general_cute_soft',
          ],
        ),
        _ThemeCategorySpec(
          id: 'general_fun_trend',
          label: 'ضحك',
          themeIds: <String>[
            'general_funny_newspaper',
            'general_evidence_case',
            'general_meme_mood',
            'general_hotline',
            'general_stop_notice',
            'general_movie_poster',
          ],
        ),
        _ThemeCategorySpec(
          id: 'general_product_talk',
          label: 'المنتج بيتكلم',
          themeIds: <String>[
            'general_owner_letter',
            'general_product_story_chat',
            'general_diary_note',
            'general_confession_card',
            'general_therapy_session',
            'general_emotion_meter',
          ],
        ),
        _ThemeCategorySpec(
          id: 'general_match_ads',
          label: 'إعلان',
          themeIds: <String>[
            'general_wanted_poster',
            'general_taapdeel_air',
            'general_blind_date',
            'general_matchmaker',
            'general_green_flags_board',
            'general_polaroid_memo',
          ],
        ),

      ],
    );
  }

  List<_ThemeCategory> _buildSuitableThemeCategories(
    List<ShareThemeDefinition> suitableThemes,
  ) {
    return _buildThemeCategories(
      suitableThemes,
      specs: const <_ThemeCategorySpec>[
        _ThemeCategorySpec(
          id: 'books_story_reading',
          label: 'حكايات',
          themeIds: <String>[
            'books_library_detective',
            'books_reading_passport',
            'books_book_cafe',
            'books_story_portal',
            'books_warm_story',
            'books_chapter_ticket',
          ],
        ),
        _ThemeCategorySpec(
          id: 'books_review_invite',
          label: 'مراجعة ودعوة',
          themeIds: <String>[
            'books_bookmark_review',
            'books_shelf_rescue',
            'books_quote_of_the_day',
            'books_book_club_invite',
          ],
        ),
        _ThemeCategorySpec(
          id: 'books_islamic',
          label: 'كتب دينية',
          themeIds: <String>[
            'books_islamic_arch_library',
            'books_islamic_manuscript',
            'books_islamic_knowledge_card',
          ],
        ),
        _ThemeCategorySpec(
          id: 'books_school_notes',
          label: 'مذاكرة وتنظيم',
          themeIds: <String>[
            'books_study_mission',
            'books_smart_notes',
            'school_mood',
            'school_journal_vibes',
          ],
        ),

        _ThemeCategorySpec(
          id: 'electronics_tech_gaming',
          label: 'تقني',
          themeIds: <String>[
            'electronics_smart_move',
            'electronics_neon_gaming',
            'electronics_circuit_terminal',
            'electronics_diagonal_energy',
            'electronics_glass_stack',
          ],
        ),
        _ThemeCategorySpec(
          id: 'electronics_clear_offer',
          label: 'احترافي',
          themeIds: <String>[
            'electronics_clean_catalog',
            'electronics_big_price',
            'electronics_magazine_split',
            'electronics_story_bubble',
            'electronics_photo_first',
          ],
        ),

        _ThemeCategorySpec(
          id: 'games_playstation',
          label: 'مغامرة',
          themeIds: <String>[
            'playstation_01_action_level_up',
            'playstation_02_glass_future',
            'playstation_03_luxury_collector',
          ],
        ),
        _ThemeCategorySpec(
          id: 'games_fun_trend',
          label: 'مرح',
          themeIds: <String>[
            'games_level_up_story',
            'games_teen_trend',
            'games_soft_girl_fun',
            'games_comic_pop_blast',
            'games_quick_sale_fun',
            'games_fun_market',
          ],
        ),
        _ThemeCategorySpec(
          id: 'games_show_match',
          label: 'عرض مميز',
          themeIds: <String>[
            'games_swap_poster_pro',
            'games_vip_showcase',
            'games_fresh_start_board',
            'games_collector_pick',
            'games_journal_diary',
            'games_wishlist_match',
            'games_mom_clearing_magic',
            'games_gift_ready_card',
            'games_storybook_fun',
            'games_family_play_invite',
            'games_playdate_card',
            'games_smart_mom_pick',
          ],
        ),

        _ThemeCategorySpec(
          id: 'home_warm_family',
          label: 'دافئ',
          themeIds: <String>[
            'home_dream_story',
            'home_mom_diary',
            'home_eco_choice',
            'home_family_ticket',
            'home_cute_soft',
          ],
        ),
        _ThemeCategorySpec(
          id: 'home_chic_luxury',
          label: 'أنيق',
          themeIds: <String>[
            'home_elegant_boutique',
            'home_clean_offer',
            'home_black_gold',
            'home_lifestyle_magazine',
          ],
        ),
        _ThemeCategorySpec(
          id: 'home_offer_specs',
          label: 'احترافي',
          themeIds: <String>[
            'home_quick_review',
            'home_pop_social',
            'home_info_specs',
            'home_modern_specs',
            'home_flash_deal',
          ],
        ),

        _ThemeCategorySpec(
          id: 'kids_cute_baby',
          label: 'بيبي',
          themeIds: <String>[
            'kids_playful_clouds',
            'kids_baby_soft',
            'kids_rainbow_card',
            'kids_magic_story',
            'kids_big_smile',
          ],
        ),
        _ThemeCategorySpec(
          id: 'kids_play_adventure',
          label: 'لعب',
          themeIds: <String>[
            'kids_toy_store',
            'kids_superhero',
            'kids_school_fun',
            'kids_minimal_parent',
            'kids_adventure_map',
          ],
        ),

        _ThemeCategorySpec(
          id: 'men_casual_youth',
          label: 'كاجوال',
          themeIds: <String>[
            'men_urban_denim',
            'men_streetwear_black',
            'men_sport_casual',
            'men_youth_hype',
            'men_photo_first',
          ],
        ),
        _ThemeCategorySpec(
          id: 'men_classic_accessories',
          label: 'كلاسيك',
          themeIds: <String>[
            'men_sneaker_drop',
            'men_classic_tailor',
            'men_clean_market',
            'men_premium_watch',
            'men_outdoor_gear',
          ],
        ),

        _ThemeCategorySpec(
          id: 'modest_calm_chic',
          label: 'راقي',
          themeIds: <String>[
            'modest_minimal_elegance',
            'modest_boutique_window',
            'modest_linen_neutral',
            'modest_premium_card',
            'modest_clean_market',
          ],
        ),
        _ThemeCategorySpec(
          id: 'modest_evening_accessories',
          label: 'مودرن',
          themeIds: <String>[
            'modest_luxury_evening',
            'modest_editorial_split',
            'modest_soft_pink',
            'modest_accessory_focus',
          ],
        ),
        _ThemeCategorySpec(
          id: 'sports_match_training',
          label: 'منافسه',
          themeIds: <String>[
            'sports_match_day',
            'sports_stadium_lights',
            'sports_scoreboard',
            'sports_training_card',
            'sports_champion_gold',
          ],
        ),

        _ThemeCategorySpec(
          id: 'sports_motion_photo',
          label: 'فوز',
          themeIds: <String>[
            'sports_neon_power',
            'sports_speed_lines',
            'sports_clean_shop',
            'sports_urban_court',
            'sports_photo_hero',
          ],
        ),
        _ThemeCategorySpec(
          id: 'sports_ahly',
          label: 'أهلي',
          themeIds: <String>[
            'sports_ahly_gomhoro_deh_hamah',
            'sports_ahly_talta_shemal',
            'sports_ahly_fakhr_leya',
            'sports_ahly_greatest_club',
            'sports_ahly_six_one',
          ],
        ),
        _ThemeCategorySpec(
          id: 'sports_zamalek',
          label: 'زمالك',
          themeIds: <String>[
            'sports_zamalek_fakhr_leya',
            'sports_zamalek_madraset_fan',
            'sports_zamalek_abyad_aaly',
            'sports_zamalek_royal_impossible',
            'sports_zamalek_eshq_omr',
            'sports_zamalek_fan_we_handsa',
          ],
        ),


        _ThemeCategorySpec(
          id: 'fashion_chic_luxury',
          label: 'شيك',
          themeIds: <String>[
            'fashion_luxe_reloved',
            'fashion_floral_dress_elegance',
            'fashion_minimal_modest',
            'fashion_boho_rewear',
            'fashion_nature_glow',
          ],
        ),
        _ThemeCategorySpec(
          id: 'fashion_cute_pastel',
          label: 'كيوت',
          themeIds: <String>[
            'fashion_dream_shot',
            'fashion_pastel_beats',
            'fashion_pink_dream',
            'fashion_closet_pastel_combo',
            'fashion_teen_trend',
            'fashion_journal_vibes',
          ],
        ),
        _ThemeCategorySpec(
          id: 'fashion_casual_youth',
          label: 'كاجوال',
          themeIds: <String>[
            'fashion_closet_refresh',
            'fashion_move_bold',
            'fashion_level_up',
            'fashion_casual_denim_days',
            'fashion_sneaker_refresh',
            'fashion_glow_corner',
            'fashion_closet_refresh_notes',
          ],
        ),
      ],
    );
  }

  List<_ThemeCategory> _buildThemeCategories(
    List<ShareThemeDefinition> themes, {
    required List<_ThemeCategorySpec> specs,
  }) {
    if (themes.isEmpty) return <_ThemeCategory>[];

    final Map<String, ShareThemeDefinition> byId = <String, ShareThemeDefinition>{
      for (final ShareThemeDefinition theme in themes) theme.id: theme,
    };
    final Set<String> usedIds = <String>{};
    final List<_ThemeCategory> categories = <_ThemeCategory>[];

    for (final _ThemeCategorySpec spec in specs) {
      final List<ShareThemeDefinition> categoryThemes = <ShareThemeDefinition>[];

      for (final String themeId in spec.themeIds) {
        final ShareThemeDefinition? theme = byId[themeId];
        if (theme == null || usedIds.contains(theme.id)) continue;

        categoryThemes.add(theme);
        usedIds.add(theme.id);
      }

      if (categoryThemes.isNotEmpty) {
        categories.add(
          _ThemeCategory(
            id: spec.id,
            label: spec.label,
            themes: categoryThemes,
          ),
        );
      }
    }

    final List<ShareThemeDefinition> remainingThemes = themes
        .where((ShareThemeDefinition theme) => !usedIds.contains(theme.id))
        .toList();

    for (int i = 0; i < remainingThemes.length; i += 6) {
      final int end = (i + 6) > remainingThemes.length
          ? remainingThemes.length
          : i + 6;
      final int chunkNumber = (i ~/ 6) + 1;
      categories.add(
        _ThemeCategory(
          id: 'more_$chunkNumber',
          label: remainingThemes.length <= 6
              ? 'ثيمات أخرى'
              : 'ثيمات أخرى $chunkNumber',
          themes: remainingThemes.sublist(i, end),
        ),
      );
    }

    if (categories.length <= 1) {
      return themes.length <= 6
          ? <_ThemeCategory>[
              _ThemeCategory(
                id: 'all',
                label: 'الكل',
                themes: themes,
              ),
            ]
          : categories;
    }

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final double bottomInset = mediaQuery.padding.bottom;
    final double topInset = mediaQuery.padding.top;
    final List<ShareThemeDefinition> themes = _activeThemes;

    final bool compactHeight = screenSize.height < 720;
    final bool veryCompactHeight = screenSize.height < 650;

    final double sheetHeight = (screenSize.height - topInset) *
        (veryCompactHeight
            ? 0.96
            : compactHeight
            ? 0.94
            : 0.91);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FCFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: <Widget>[
            _dragHandle(compact: compactHeight),
            _topBar(context, compact: compactHeight),
            SizedBox(height: compactHeight ? 5 : 8),
            ShareThemeSelector(
              sections: _sections,
              activeSection: _activeSection,
              onSectionChanged: _changeSection,
            ),
            if (_activeSection == ShareThemeSectionType.general &&
                _generalThemeCategories.length > 1) ...<Widget>[
              SizedBox(height: compactHeight ? 6 : 8),
              _themeCategoryChips(
                categories: _generalThemeCategories,
                activeCategoryId: _activeGeneralCategoryId,
                section: ShareThemeSectionType.general,
                compact: compactHeight,
              ),
            ],
            if (_activeSection == ShareThemeSectionType.suitable &&
                _suitableThemeCategories.length > 1) ...<Widget>[
              SizedBox(height: compactHeight ? 6 : 8),
              _themeCategoryChips(
                categories: _suitableThemeCategories,
                activeCategoryId: _activeSuitableCategoryId,
                section: ShareThemeSectionType.suitable,
                compact: compactHeight,
              ),
            ],
            SizedBox(height: compactHeight ? 6 : 10),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: PageView.builder(
                      key: ValueKey<String>(_activeThemeListKey),
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: themes.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentIndex = index;
                          _selectedTheme = themes[index];
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final ShareThemeDefinition theme = themes[index];
                        final bool isActive = index == _currentIndex;

                        return AnimatedPadding(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.fromLTRB(
                            isActive ? 4 : 10,
                            isActive ? 0 : 12,
                            isActive ? 4 : 10,
                            isActive ? 4 : 14,
                          ),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            scale: isActive ? 1 : 0.95,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 180),
                              opacity: isActive ? 1 : 0.86,
                              child: SharePreviewCard(
                                repaintKey: isActive ? _cardKey : GlobalKey(),
                                theme: theme,
                                data: _data,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (themes.length > 1) ...<Widget>[
                    SizedBox(height: compactHeight ? 3 : 6),
                    _themePagerInfo(themes.length),
                  ],
                  SizedBox(height: compactHeight ? 5 : 10),
                ],
              ),
            ),
            _shareButton(context, compact: compactHeight),
            SizedBox(height: bottomInset + (compactHeight ? 6 : 10)),
          ],
        ),
      ),
    );
  }

  Widget _dragHandle({required bool compact}) {
    return Container(
      margin: EdgeInsets.only(
        top: compact ? 8 : 12,
        bottom: compact ? 4 : 6,
      ),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFB9CFDB),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _topBar(BuildContext context, {required bool compact}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: compact ? 0 : 2,
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(compact ? 7 : 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1F8),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFF426173),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'اختار تصميم المشاركة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF102A43),
                fontSize: compact ? 16.5 : 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _themeCategoryChips({
    required List<_ThemeCategory> categories,
    required String activeCategoryId,
    required ShareThemeSectionType section,
    required bool compact,
  }) {
    return SizedBox(
      height: compact ? 34 : 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final _ThemeCategory category = categories[index];
          final bool selected = category.id == activeCategoryId;

          return GestureDetector(
            onTap: () => _changeThemeCategory(section, category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 11 : 13,
                vertical: compact ? 7 : 8,
              ),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0C587A) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF0C587A)
                      : const Color(0xFFD5E7F1),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF0C587A).withOpacity(
                      selected ? 0.13 : 0.05,
                    ),
                    blurRadius: selected ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    category.label,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xFF426173),
                      fontSize: compact ? 12.5 : 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withOpacity(0.18)
                          : const Color(0xFFEAF5FA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${category.themes.length}',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF0C587A),
                        fontSize: compact ? 10.5 : 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _themePagerInfo(int count) {
    if (count <= 1) {
      return const SizedBox(height: 8);
    }

    final int current = _currentIndex + 1;
    final bool canGoPrev = _currentIndex > 0;
    final bool canGoNext = _currentIndex < count - 1;

    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _PagerArrowButton(
            icon: Icons.chevron_left_rounded,
            enabled: canGoPrev,
            onTap: () {
              if (!canGoPrev || !_pageController.hasClients) return;
              _pageController.previousPage(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
              );
            },
          ),
          const SizedBox(width: 8),

          _CompactDotsPager(
            count: count,
            currentIndex: _currentIndex,
          ),


          const SizedBox(width: 8),
          _PagerArrowButton(
            icon: Icons.chevron_right_rounded,
            enabled: canGoNext,
            onTap: () {
              if (!canGoNext || !_pageController.hasClients) return;
              _pageController.nextPage(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _shareButton(BuildContext context, {required bool compact}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GestureDetector(
        onTap: _busy ? null : () => _doShare(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: compact ? 13 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _busy
                  ? const <Color>[Color(0xFF7796A7), Color(0xFF5D7F94)]
                  : const <Color>[Color(0xFF24A9C4), Color(0xFF0C587A)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF0C587A).withOpacity(0.16),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 19,
                ),
              const SizedBox(width: 10),
              Text(
                _busy ? 'جاري التحضير...' : 'شارك بطاقة المنتج',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 14.5 : 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _cleanShareValue(dynamic value) {
    final String text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  String _readProductValue(List<dynamic Function(dynamic product)> readers) {
    final dynamic product = widget.product;

    for (final dynamic Function(dynamic product) reader in readers) {
      try {
        final String value = _cleanShareValue(reader(product));
        if (value.isNotEmpty) return value;
      } catch (_) {}
    }

    return '';
  }

  String _buildShareSubject() {
    final String title = _readProductValue(<dynamic Function(dynamic product)>[
          (dynamic product) => product.title,
          (dynamic product) => product.name,
          (dynamic product) => product.itemTitle,
    ]);

    if (title.isEmpty) return 'منتج على تبديل';
    return 'منتج على تبديل: $title';
  }

  String _buildShareMessage() {
    final String title = _readProductValue(<dynamic Function(dynamic product)>[
          (dynamic product) => product.title,
          (dynamic product) => product.name,
          (dynamic product) => product.itemTitle,
    ]);

    final String description = _readProductValue(<dynamic Function(dynamic product)>[
          (dynamic product) => product.description,
          (dynamic product) => product.desc,
          (dynamic product) => product.itemDescription,
    ]);

    final String lowPrice = _readProductValue(<dynamic Function(dynamic product)>[
          (dynamic product) => product.lowPrice,
          (dynamic product) => product.low_price,
          (dynamic product) => product.minPrice,
          (dynamic product) => product.price,
    ]);

    final String highPrice = _readProductValue(<dynamic Function(dynamic product)>[
          (dynamic product) => product.highPrice,
          (dynamic product) => product.high_price,
          (dynamic product) => product.maxPrice,
    ]);

    final String township = _readProductValue(<dynamic Function(dynamic product)>[
          (dynamic product) => product.itemLocationTownship?.townshipName,
          (dynamic product) => product.itemLocationTownship?.name,
          (dynamic product) => product.itemLocationTownship?.title,
          (dynamic product) => product.itemLocationTownshipName,
          (dynamic product) => product.item_location_township_name,
    ]);

    final String city = _readProductValue(<dynamic Function(dynamic product)>[
          (dynamic product) => product.itemLocation?.name,
          (dynamic product) => product.itemLocation?.cityName,
          (dynamic product) => product.itemLocation?.title,
          (dynamic product) => product.itemLocationName,
          (dynamic product) => product.item_location_name,
    ]);

    final String link = _cleanShareValue(_data.link).isNotEmpty
        ? _cleanShareValue(_data.link)
        : TaapdeelShareLinks.productOrFallback(
      productId: widget.product.id,
      existingLink: widget.dynamicLink,
    );

    String priceText = '';
    if (lowPrice.isNotEmpty &&
        highPrice.isNotEmpty &&
        lowPrice != highPrice) {
      priceText = '$lowPrice - $highPrice جنيه';
    } else if (lowPrice.isNotEmpty) {
      priceText = '$lowPrice جنيه';
    } else if (highPrice.isNotEmpty) {
      priceText = '$highPrice جنيه';
    }

    String locationText = '';
    if (township.isNotEmpty && city.isNotEmpty) {
      locationText = '$township، $city';
    } else if (township.isNotEmpty) {
      locationText = township;
    } else if (city.isNotEmpty) {
      locationText = city;
    }

    String shortDescription = description;
    if (shortDescription.length > 120) {
      shortDescription = '${shortDescription.substring(0, 117)}...';
    }

    final StringBuffer buffer = StringBuffer();

    buffer.writeln('شوف المنتج ده على تبديل 👀');
    buffer.writeln();

    if (title.isNotEmpty) {
      buffer.writeln('📦 $title');
    }

    if (shortDescription.isNotEmpty) {
      buffer.writeln('📝 $shortDescription');
    }

    if (priceText.isNotEmpty) {
      buffer.writeln('💰 القيمة التقريبية: $priceText');
    }

    if (locationText.isNotEmpty) {
      buffer.writeln('📍 المكان: $locationText');
    }

    buffer.writeln();
    buffer.writeln('افتح المنتج من هنا:');
    buffer.writeln(link);

    return buffer.toString().trim();
  }

  Future<void> _doShare(BuildContext context) async {
    setState(() => _busy = true);

    File? shareFile;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));

      if (!mounted || !context.mounted) return;

      final RenderRepaintBoundary? boundary =
      _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('لم يتم العثور على كارت المشاركة');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('فشل تحويل التصميم إلى صورة');
      }

      final Directory tempDir = await getTemporaryDirectory();
      shareFile = File(
        '${tempDir.path}/taapdeel_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await shareFile.writeAsBytes(byteData.buffer.asUint8List());

      if (!mounted || !context.mounted) return;

      final Size size = MediaQuery.of(context).size;

      await Share.shareXFiles(
        <XFile>[XFile(shareFile.path)],
        text: _buildShareMessage(),
        subject: _buildShareSubject(),
        sharePositionOrigin: Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height / 2,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في المشاركة: $e')),
      );
    } finally {
      final File? fileToDelete = shareFile;
      if (fileToDelete != null) {
        try {
          if (await fileToDelete.exists()) {
            await fileToDelete.delete();
          }
        } catch (_) {
          // Temp cleanup must never block the user flow.
        }
      }

      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

}
