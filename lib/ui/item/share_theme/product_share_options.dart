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

  static void show({
    required BuildContext context,
    required Product product,
    required String dynamicLink,
    required String imageUrl,
  }) {
    final String resolvedImageUrl = _resolveShareImageUrl(product, imageUrl);
    final String referralCode = _resolveReferralCode(context);
    final String resolvedDynamicLink =
    TaapdeelShareLinks.productOrFallbackWithReferral(
      productId: product.id,
      existingLink: dynamicLink,
      referralCode: referralCode,
      source: 'product_share',
    );

    debugPrint('SHARE_IMAGE_URL_INPUT => $imageUrl');
    debugPrint('SHARE_IMAGE_URL_RESOLVED => $resolvedImageUrl');
    debugPrint('SHARE_LINK_INPUT => $dynamicLink');
    debugPrint('SHARE_LINK_RESOLVED => $resolvedDynamicLink');
    debugPrint('SHARE_REFERRAL_CODE => $referralCode');

    showModalBottomSheet<void>(
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

class _ShareSheetState extends State<_ShareSheet> {
  final GlobalKey _cardKey = GlobalKey();

  late final ShareProductData _data;
  late final ShareThemeSections _sections;
  late final PageController _pageController;
  late ShareThemeSectionType _activeSection;
  late ShareThemeDefinition _selectedTheme;

  bool _busy = false;
  int _currentIndex = 0;

  List<ShareThemeDefinition> get _activeThemes {
    if (_activeSection == ShareThemeSectionType.suitable &&
        _sections.suitableThemes.isNotEmpty) {
      return _sections.suitableThemes;
    }

    if (_sections.generalThemes.isNotEmpty) {
      return _sections.generalThemes;
    }

    return _sections.suitableThemes;
  }

  @override
  void initState() {
    super.initState();

    final String safeDynamicLink =
    TaapdeelShareLinks.productOrFallbackWithReferral(
      productId: widget.product.id,
      existingLink: widget.dynamicLink,
      referralCode: widget.referralCode,
      source: 'product_share',
    );

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

    if (_sections.generalThemes.isNotEmpty) {
      _activeSection = ShareThemeSectionType.general;
      _selectedTheme = _sections.generalThemes.first;
    } else if (_sections.suitableThemes.isNotEmpty) {
      _activeSection = ShareThemeSectionType.suitable;
      _selectedTheme = _sections.suitableThemes.first;
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
        ? _sections.suitableThemes
        : _sections.generalThemes;

    if (nextThemes.isEmpty) return;

    setState(() {
      _activeSection = section;
      _currentIndex = 0;
      _selectedTheme = nextThemes.first;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
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
            SizedBox(height: compactHeight ? 6 : 10),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: PageView.builder(
                      key: ValueKey<ShareThemeSectionType>(_activeSection),
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
            icon: Icons.chevron_right_rounded,
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
            icon: Icons.chevron_left_rounded,
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
                  Icons.ios_share_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              const SizedBox(width: 10),
              Text(
                _busy ? 'جاري التحضير...' : 'شارك بطاقة منتجك',
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

    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));

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
      final File file = File(
        '${tempDir.path}/taapdeel_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(byteData.buffer.asUint8List());

      final Size size = MediaQuery.of(context).size;

      await Share.shareXFiles(
        <XFile>[XFile(file.path)],
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
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

}
