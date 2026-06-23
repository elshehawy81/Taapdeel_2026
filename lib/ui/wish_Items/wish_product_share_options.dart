import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'wish_share_themes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/utils/taapdeel_share_links.dart';

import '../item/share_theme/core/share_product_data.dart';
import '../item/share_theme/core/share_theme_definition.dart';
import '../item/share_theme/widgets/share_preview_card.dart';

class WishProductShareOptions {
  const WishProductShareOptions._();

  static Future<void> show({
    required BuildContext context,
    required Product product,
    required String dynamicLink,
    required String imageUrl,
  }) {
    final String referralCode = _readReferralCode(context);

    final String resolvedDynamicLink =
    TaapdeelShareLinks.wishOrFallbackWithReferral(
      wishId: product.id,
      existingLink: dynamicLink,
      referralCode: referralCode,
      source: 'wish_share',
    );

    debugPrint('WISH_SHARE_LINK_INPUT => $dynamicLink');
    debugPrint('WISH_SHARE_LINK_RESOLVED => $resolvedDynamicLink');
    debugPrint('WISH_SHARE_REFERRAL_CODE => $referralCode');

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _WishShareSheet(
        product: product,
        dynamicLink: resolvedDynamicLink,
        imageUrl: imageUrl,
        referralCode: referralCode,
      ),
    );
  }

  static String _readReferralCode(BuildContext context) {
    try {
      final PsValueHolder holder = Provider.of<PsValueHolder>(
        context,
        listen: false,
      );

      final String code = (holder.referralCode ?? '').trim();
      if (code.isEmpty || code.toLowerCase() == 'null') return '';

      return code;
    } catch (_) {
      return '';
    }
  }
}

String _resolveWishShareImageUrl(String? raw, {String imageBaseUrl = ''}) {
  String value = (raw ?? '').trim();
  if (value.isEmpty || value.toLowerCase() == 'null') return '';

  value = value.replaceAll('\\', '/');

  // Local paths are valid while the user is still inside the entry flow.
  // Do not convert them to https://taapdeel.com/uploads/data/user/...
  // because that URL will never exist on the server.
  if (value.startsWith('/data/') ||
      value.startsWith('/storage/') ||
      value.startsWith('/sdcard/') ||
      value.startsWith('/var/') ||
      value.startsWith('/tmp/')) {
    return 'file://$value';
  }

  if (value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('file://')) {
    return value;
  }

  while (value.startsWith('/')) {
    value = value.substring(1);
  }
  value = value.replaceFirst(RegExp(r'^index\.php/'), '');

  if (value.startsWith('uploads/') ||
      value.startsWith('storage/') ||
      value.startsWith('files/')) {
    return 'https://taapdeel.com/$value';
  }

  final String cleanBase = imageBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  if (cleanBase.isNotEmpty) {
    if (cleanBase.endsWith('/uploads')) return '$cleanBase/$value';
    return '$cleanBase/uploads/$value';
  }

  return 'https://taapdeel.com/uploads/$value';
}

class _WishShareSheet extends StatefulWidget {
  const _WishShareSheet({
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
  State<_WishShareSheet> createState() => _WishShareSheetState();
}

class _WishShareSheetState extends State<_WishShareSheet> {
  final GlobalKey _cardKey = GlobalKey();

  late final ShareProductData _data;
  late final PageController _pageController;
  late final List<ShareThemeDefinition> _themes;
  late ShareThemeDefinition _selectedTheme;

  bool _busy = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    final String resolvedImageUrl = _resolveWishShareImageUrl(widget.imageUrl);
    final String resolvedDynamicLink =
    TaapdeelShareLinks.wishOrFallbackWithReferral(
      wishId: widget.product.id,
      existingLink: widget.dynamicLink,
      referralCode: widget.referralCode,
      source: 'wish_share',
    );

    // لا تستخدم widget.product مباشرة هنا.
    // بعض Wish Items القادمة من صفحة المنتجات المطلوبة لا تحتوي على dynamic getter
    // باسم highlight_info داخل Product، بينما ShareProductData.from يقرأه.
    // لذلك نمرر Product subtype آمن يرجّع قيم fallback بدون crash.
    _data = ShareProductData.from(
      _SafeWishProduct(widget.product),
      resolvedImageUrl,
      resolvedDynamicLink,
    );

    _themes = WishShareThemes.themes;
    if (_themes.isEmpty) {
      throw StateError('No wish share themes were registered.');
    }

    _selectedTheme = _themes.first;
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

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final double bottomInset = mediaQuery.padding.bottom;
    final double topInset = mediaQuery.padding.top;

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
            SizedBox(height: compactHeight ? 6 : 10),
            _wishHeader(compact: compactHeight),
            SizedBox(height: compactHeight ? 6 : 10),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _themes.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentIndex = index;
                          _selectedTheme = _themes[index];
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final ShareThemeDefinition theme = _themes[index];
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
                  if (_themes.length > 1) ...<Widget>[
                    SizedBox(height: compactHeight ? 3 : 6),
                    _themePagerInfo(_themes.length),
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
              'اختار شكل مشاركة منتجك المطلوب',
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

  Widget _wishHeader({required bool compact}) {
    return Container(
      height: compact ? 46 : 50,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFE7FFF5), Color(0xFFEAF7FA)],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD5E7F1)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF0C587A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ثيمات حواديت تبديل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF102A43),
                    fontSize: 12.4,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'شارك منتجك المطلوب',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF6B8798),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_currentIndex + 1}/${_themes.length}',
            style: const TextStyle(
              color: Color(0xFF0C587A),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _themePagerInfo(int count) {
    return SizedBox(
      height: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(count, (int index) {
          final bool active = index == _currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF24A9C4) : const Color(0xFFC9DBE7),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }

  Widget _shareButton(BuildContext context, {required bool compact}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        width: double.infinity,
        height: compact ? 46 : 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C587A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _busy ? null : _shareCurrentPreview,
          icon: _busy
              ? const SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Icon(Icons.ios_share_rounded, size: 19),
          label: Text(
            _busy ? 'جاري تجهيز التصميم...' : 'شارك منتجك المطلوب',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Future<void> _shareCurrentPreview() async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      final BuildContext? cardContext = _cardKey.currentContext;
      final RenderObject? renderObject = cardContext?.findRenderObject();

      if (renderObject is! RenderRepaintBoundary) {
        throw StateError('Share preview is not ready yet.');
      }

      final ui.Image image = await renderObject.toImage(pixelRatio: 3);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw StateError('Could not render share image.');
      }

      final Uint8List bytes = byteData.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File(
        '${tempDir.path}/taapdeel_wish_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        <XFile>[XFile(file.path)],
        text: _shareText(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تجهيز المشاركة: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _readWishHookText() {
    try {
      final dynamic p = widget.product;
      final String value = (p.description ?? p.item_description ?? p.note ?? p.notes ?? '').toString().trim();
      if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
    } catch (_) {}
    return '';
  }

  String _shareText() {
    final String title = _data.title.trim();
    final String hook = _readWishHookText();
    final String link = TaapdeelShareLinks.wishOrFallbackWithReferral(
      wishId: widget.product.id,
      existingLink: widget.dynamicLink,
      referralCode: widget.referralCode,
      source: 'wish_share',
    );

    final String safeTitle = title.isEmpty ? 'حاجة مناسبة' : title;
    final StringBuffer buffer = StringBuffer();

    if (hook.isNotEmpty) {
      buffer.writeln('حدوتة تبديل: “$hook”');
      buffer.writeln('أنا بدور على: $safeTitle');
      buffer.writeln('لو عندك حاجة مناسبة ومش محتاجها، اعمل عرض تبديل.');
    } else if (title.isNotEmpty) {
      buffer.writeln('أنا بدور على: $title');
      buffer.writeln('لو عندك حاجة مناسبة ومش محتاجها، اعمل عرض تبديل.');
    } else {
      buffer.writeln('حد عنده المنتج ده على تبديل؟');
      buffer.writeln('لو عندك حاجة مناسبة ومش محتاجها، افتح الرابط واعمل عرض تبديل.');
    }

    buffer.writeln();
    buffer.writeln('لو التطبيق عندك هيفتح المنتج المطلوب مباشرة، ولو مش عندك هتقدر تشوفه من الرابط:');
    buffer.write(link);

    return buffer.toString();
  }
}

/// Product subtype آمن لمشاركة Wish Items.
///
/// لا نستخدم cast على object عادي؛ هذا الكلاس يرث من Product فعلاً، لذلك يقبله
/// ShareProductData.from بدون TypeError. كما أنه يعالج dynamic getters الناقصة
/// مثل highlight_info حتى لا يحدث NoSuchMethodError.
class _SafeWishProduct extends Product {
  _SafeWishProduct(this._source) : super();

  final Product _source;

  // هذه الحقول غالباً موجودة كـ nullable String داخل Product.
  // وجودها هنا يحافظ على بيانات العنوان/السعر/الوصف لو ShareProductData.from
  // قرأها كـ product.title/product.price بدلاً من dynamic access.
  @override
  String? get id => _safeText(_read(<String>['id']));

  @override
  String? get title => _safeText(_read(<String>['title', 'item_title', 'name', 'item_name']));

  @override
  String? get description => _safeText(_read(<String>['description', 'item_description', 'note', 'notes']));

  @override
  String? get price => _safeText(_read(<String>['price', 'original_price', 'originalPrice']));

  dynamic _read(List<String> names, [dynamic fallback = '']) {
    final dynamic p = _source;

    for (final String name in names) {
      try {
        switch (name) {
          case 'id':
            final dynamic value = p.id;
            if (_hasValue(value)) return value;
            break;
          case 'title':
            final dynamic value = p.title;
            if (_hasValue(value)) return value;
            break;
          case 'item_title':
            final dynamic value = p.item_title;
            if (_hasValue(value)) return value;
            break;
          case 'name':
            final dynamic value = p.name;
            if (_hasValue(value)) return value;
            break;
          case 'item_name':
            final dynamic value = p.item_name;
            if (_hasValue(value)) return value;
            break;
          case 'description':
            final dynamic value = p.description;
            if (_hasValue(value)) return value;
            break;
          case 'item_description':
            final dynamic value = p.item_description;
            if (_hasValue(value)) return value;
            break;
          case 'note':
            final dynamic value = p.note;
            if (_hasValue(value)) return value;
            break;
          case 'notes':
            final dynamic value = p.notes;
            if (_hasValue(value)) return value;
            break;
          case 'price':
            final dynamic value = p.price;
            if (_hasValue(value)) return value;
            break;
          case 'original_price':
            final dynamic value = p.original_price;
            if (_hasValue(value)) return value;
            break;
          case 'originalPrice':
            final dynamic value = p.originalPrice;
            if (_hasValue(value)) return value;
            break;
          case 'highlight_info':
            final dynamic value = p.highlight_info;
            if (_hasValue(value)) return value;
            break;
          case 'highlightInfo':
            final dynamic value = p.highlightInfo;
            if (_hasValue(value)) return value;
            break;
          case 'highlight_information':
            final dynamic value = p.highlight_information;
            if (_hasValue(value)) return value;
            break;
          case 'highlightInformation':
            final dynamic value = p.highlightInformation;
            if (_hasValue(value)) return value;
            break;
          case 'usage_status':
            final dynamic value = p.usage_status;
            if (_hasValue(value)) return value;
            break;
          case 'usageStatus':
            final dynamic value = p.usageStatus;
            if (_hasValue(value)) return value;
            break;
          case 'business_mode':
            final dynamic value = p.business_mode;
            if (_hasValue(value)) return value;
            break;
          case 'businessMode':
            final dynamic value = p.businessMode;
            if (_hasValue(value)) return value;
            break;
          case 'is_new':
            final dynamic value = p.is_new;
            if (_hasValue(value)) return value;
            break;
          case 'isNew':
            final dynamic value = p.isNew;
            if (_hasValue(value)) return value;
            break;
        }
      } catch (_) {
        // الحقل غير موجود في Product الحالي؛ جرّب الاسم التالي.
      }
    }

    return fallback;
  }

  static bool _hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String) {
      final String text = value.trim();
      return text.isNotEmpty && text.toLowerCase() != 'null';
    }
    return true;
  }

  static String? _safeText(dynamic value) {
    if (!_hasValue(value)) return null;
    return value.toString().trim();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!invocation.isGetter) {
      return super.noSuchMethod(invocation);
    }

    final String name = _symbolName(invocation.memberName);

    switch (name) {
      case 'highlight_info':
      case 'highlightInfo':
      case 'highlight_information':
      case 'highlightInformation':
        return _read(<String>[
          'highlight_info',
          'highlightInfo',
          'highlight_information',
          'highlightInformation',
          'description',
          'item_description',
          'note',
          'notes',
        ], '');
      case 'usage_status':
      case 'usageStatus':
        return _read(<String>['usage_status', 'usageStatus'], '');
      case 'business_mode':
      case 'businessMode':
        return _read(<String>['business_mode', 'businessMode'], '');
      case 'is_new':
      case 'isNew':
        return _read(<String>['is_new', 'isNew'], false);
      default:
        return '';
    }
  }

  String _symbolName(Symbol symbol) {
    final String raw = symbol.toString();
    if (raw.startsWith('Symbol("') && raw.endsWith('")')) {
      return raw.substring(8, raw.length - 2);
    }
    if (raw.startsWith('Symbol("')) {
      return raw.substring(8).replaceAll('")', '');
    }
    return raw
        .replaceFirst('Symbol("', '')
        .replaceFirst('")', '')
        .replaceFirst('Symbol(', '')
        .replaceFirst(')', '');
  }
}
