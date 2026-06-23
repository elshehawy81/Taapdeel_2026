part of 'profile_share_gallery.dart';

class ShareGalleryController {
  const ShareGalleryController._();

  static _SafeShareTarget? _currentTarget;

  static void registerPreview({
    required GlobalKey key,
    required List<Product> products,
    required String smartText,
    required ShareGallerySource source,
    String? profileUserId,
    String? referralCode,
  }) {
    _currentTarget = _SafeShareTarget(
      key: key,
      products: List<Product>.unmodifiable(products),
      smartText: smartText,
      source: source,
      profileUserId: _cleanText(profileUserId),
      referralCode: _cleanText(referralCode),
    );
  }

  static void clearPreview(GlobalKey key) {
    if (_currentTarget?.key == key) {
      _currentTarget = null;
    }
  }

  static Future<void> maybeShareCurrentPreview(BuildContext context) async {
    final _SafeShareTarget? target = _currentTarget;
    if (target == null) return;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!context.mounted) return;

      final BuildContext? previewContext = target.key.currentContext;
      if (previewContext == null) {
        _showShareError(context);
        return;
      }

      final RenderObject? renderObject = previewContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        _showShareError(context);
        return;
      }

      if (renderObject.debugNeedsPaint) {
        await Future<void>.delayed(const Duration(milliseconds: 48));
      }

      final ui.Image image = await renderObject.toImage(
        pixelRatio: _ShareGalleryDims.previewPixelRatio.toDouble(),
      );
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (context.mounted) _showShareError(context);
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/taapdeel_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes, flush: true);

      if (!context.mounted) return;
      await Share.shareXFiles(
        <XFile>[XFile(file.path)],
        text: _buildShareText(
          products: target.products,
          smartText: target.smartText,
          source: target.source,
          profileUserId: target.profileUserId,
          referralCode: target.referralCode,
        ),
      );
    } catch (_) {
      if (context.mounted) _showShareError(context);
    }
  }

  static void _showShareError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تعذر إنشاء صورة المشاركة. حاول مرة أخرى.')),
    );
  }

  static String _buildShareText({
    required List<Product> products,
    required String smartText,
    required ShareGallerySource source,
    String? profileUserId,
    String? referralCode,
  }) {
    final List<ShareProductViewData> mapped = ShareProductMapper.fromProducts(products);
    final bool isFamilyGallery = source == ShareGallerySource.familyGallery;

    final String intro = smartText.trim().isNotEmpty
        ? smartText.trim()
        : SmartShareTextResolver.resolveFromViewData(products: mapped, source: source);

    final String safeProfileUserId = _cleanText(profileUserId).isNotEmpty
        ? _cleanText(profileUserId)
        : _resolveProfileUserIdFromProducts(products);

    final String link = TaapdeelShareLinks.shareGalleryWithReferral(
      userId: safeProfileUserId,
      family: isFamilyGallery,
      referralCode: referralCode,
    );

    final StringBuffer buffer = StringBuffer();

    if (intro.isNotEmpty) {
      buffer.writeln(intro);
      buffer.writeln();
    }

    buffer.writeln(
      isFamilyGallery
          ? 'شوف معرض العائلة على تبديل:'
          : 'شوف منتجاتي على تبديل:',
    );

    int written = 0;
    for (final ShareProductViewData product in mapped.take(_ShareGalleryDims.maxSelectedProducts)) {
      final String title = (product.title ?? '').trim();
      if (title.isEmpty) continue;

      written++;
      buffer.writeln('$written. $title');
    }

    if (written == 0) {
      buffer.writeln(
        isFamilyGallery
            ? 'مجموعة منتجات من معرض العائلة جاهزة للتبديل.'
            : 'مجموعة منتجات جاهزة للتبديل.',
      );
    }

    buffer.writeln();
    buffer.writeln(
      isFamilyGallery
          ? 'لو التطبيق عندك هيفتح معرض العائلة مباشرة، ولو مش عندك هتقدر تشوفه من الرابط:'
          : 'لو التطبيق عندك هيفتح صفحة المنتجات مباشرة، ولو مش عندك هتقدر تشوفها من الرابط:',
    );
    buffer.writeln(link);
    buffer.writeln();
    buffer.write('Taapdeel - تبديل أذكى، امتلاك أقل');

    return buffer.toString();
  }

  static String _resolveProfileUserIdFromProducts(List<Product> products) {
    for (final Product product in products) {
      final String id = _extractUserId(product);
      if (id.isNotEmpty) return id;
    }

    return '';
  }

  static String _extractUserId(Product product) {
    final dynamic p = product;

    final List<dynamic Function()> readers = <dynamic Function()>[
          () => p.addedUserId,
          () => p.added_user_id,
          () => p.userId,
          () => p.user_id,
          () => p.ownerUserId,
          () => p.owner_user_id,
          () => p.sellerUserId,
          () => p.seller_user_id,
          () => p.addedUser?.userId,
          () => p.addedUser?.id,
          () => p.added_user?.user_id,
          () => p.added_user?.id,
          () => p.user?.userId,
          () => p.user?.id,
          () => p.owner?.userId,
          () => p.owner?.id,
          () => p.seller?.userId,
          () => p.seller?.id,
    ];

    for (final dynamic Function() reader in readers) {
      try {
        final String value = _cleanText(reader());
        if (value.isNotEmpty) return value;
      } catch (_) {}
    }

    return '';
  }

  static String _cleanText(Object? value) {
    final String text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }
}
