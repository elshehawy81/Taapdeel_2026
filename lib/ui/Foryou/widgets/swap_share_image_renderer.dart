import 'dart:typed_data';

import '../../../../viewobject/product.dart';
import 'swap_share_theme.dart';
import 'swap_whatsapp_share_service.dart';

// =============================================================
// SwapShareImageRenderer
// =============================================================
// Public shared renderer facade used by:
// - SwapWhatsAppShareService when sharing the final image.
// - Swap consult bottom sheet when showing the theme preview.
//
// The actual canvas drawing remains in one path inside
// SwapWhatsAppShareService.buildShareImageBytes, so the preview is always
// generated from the same image that will be shared.
// =============================================================
class SwapShareImageRenderer {
  const SwapShareImageRenderer._();

  static final Map<String, Future<Uint8List>> _previewFutureCache =
  <String, Future<Uint8List>>{};

  static Future<Uint8List> buildImageBytes({
    required Product myProduct,
    required List<Product> suggestions,
    required SwapShareTheme theme,
    bool preview = false,
  }) {
    if (!preview) {
      return SwapWhatsAppShareService.buildShareImageBytes(
        myProduct: myProduct,
        suggestions: suggestions,
        theme: theme,
      );
    }

    final List<Product> shown = suggestions.take(5).toList(growable: false);
    final String cacheKey = _cacheKey(
      myProduct: myProduct,
      suggestions: shown,
      theme: theme,
    );

    return _previewFutureCache.putIfAbsent(
      cacheKey,
          () => SwapWhatsAppShareService.buildShareImageBytes(
        myProduct: myProduct,
        suggestions: shown,
        theme: theme,
        renderScale: 0.48,
      ),
    );
  }

  static void warmUpThemePreviews({
    required Product myProduct,
    required List<Product> suggestions,
    int selectedIndex = 0,
  }) {
    final List<Product> shown = suggestions.take(5).toList(growable: false);
    final int safeSelectedIndex = selectedIndex.clamp(
      0,
      SwapShareTheme.presets.length - 1,
    ).toInt();

    final List<int> order = <int>[
      safeSelectedIndex,
      for (int index = 0; index < SwapShareTheme.presets.length; index++)
        if (index != safeSelectedIndex) index,
    ];

    Future<void> chain = Future<void>.value();
    for (final int index in order) {
      chain = chain.then((_) {
        return buildImageBytes(
          myProduct: myProduct,
          suggestions: shown,
          theme: SwapShareTheme.presets[index],
          preview: true,
        ).then((_) => null).catchError((_) {});
      });
    }
  }

  static String _cacheKey({
    required Product myProduct,
    required List<Product> suggestions,
    required SwapShareTheme theme,
  }) {
    return <String>[
      theme.id,
      _productKey(myProduct),
      ...suggestions.map(_productKey),
    ].join('::');
  }

  static String _productKey(Product product) {
    final String id = (product.id ?? '').toString().trim();
    final String title = (product.title ?? '').trim();
    final String image = (product.defaultPhoto?.imgPath ?? '').trim();
    final String score = (product.swapScorePercent ?? '').toString().trim();
    final String low = (product.lowPrice ?? '').trim();
    final String high = (product.highPrice ?? '').trim();
    final String price = (product.price ?? '').trim();
    return '$id|$title|$image|$score|$low|$high|$price';
  }
}
