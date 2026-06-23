class TaapdeelShareLinks {
  const TaapdeelShareLinks._();

  static const String appHost = 'taapdeel.com';
  static const String webBaseUrl = 'https://taapdeel.com';
  static const String linkBaseUrl = '$webBaseUrl/l';
  static const String downloadUrl = '$webBaseUrl/download';

  // ─────────────────────────────────────────────────────────────
  // Public builders - plain deep links
  // ─────────────────────────────────────────────────────────────

  static String product(String? productId) {
    final String id = _cleanId(productId);
    if (id.isEmpty) return downloadUrl;

    return '$linkBaseUrl/product/$id';
  }

  static String wish(String? wishId) {
    final String id = _cleanId(wishId);
    if (id.isEmpty) return downloadUrl;

    return '$linkBaseUrl/wish/$id';
  }

  static String profile(String? userId) {
    final String id = _cleanId(userId);
    if (id.isEmpty) return downloadUrl;

    return '$linkBaseUrl/profile/$id';
  }

  static String myProducts(String? userId) {
    final String id = _cleanId(userId);
    if (id.isEmpty) return downloadUrl;

    return '$linkBaseUrl/profile/$id?tab=items';
  }

  static String familyGallery(String? userId) {
    final String id = _cleanId(userId);
    if (id.isEmpty) return downloadUrl;

    return '$linkBaseUrl/profile/$id?family=1';
  }

  static String shareGallery({
    required String? userId,
    required bool family,
  }) {
    return family ? familyGallery(userId) : myProducts(userId);
  }

  static String swapAdvice({
    required String? myProductId,
    List<String?> suggestionIds = const <String?>[],
  }) {
    final String mine = _cleanId(myProductId);
    if (mine.isEmpty) return downloadUrl;

    final List<String> safeSuggestions = suggestionIds
        .map(_cleanId)
        .where((String id) => id.isNotEmpty)
        .toList(growable: false);

    if (safeSuggestions.isEmpty) {
      return product(mine);
    }

    final String suggestionsParam = Uri.encodeComponent(
      safeSuggestions.join(','),
    );

    return '$linkBaseUrl/swap-advice?mine=$mine&s=$suggestionsParam';
  }

  // ─────────────────────────────────────────────────────────────
  // Public builders - referral-aware share links
  // ─────────────────────────────────────────────────────────────

  static String productWithReferral({
    required String? productId,
    required String? referralCode,
    String source = 'product_share',
  }) {
    return withReferral(
      product(productId),
      referralCode: referralCode,
      source: source,
      entityType: 'product',
      entityId: productId,
    );
  }

  static String wishWithReferral({
    required String? wishId,
    required String? referralCode,
    String source = 'wish_share',
  }) {
    return withReferral(
      wish(wishId),
      referralCode: referralCode,
      source: source,
      entityType: 'wish',
      entityId: wishId,
    );
  }

  static String profileWithReferral({
    required String? userId,
    required String? referralCode,
    String source = 'profile_share',
  }) {
    return withReferral(
      profile(userId),
      referralCode: referralCode,
      source: source,
      entityType: 'profile',
      entityId: userId,
    );
  }

  static String myProductsWithReferral({
    required String? userId,
    required String? referralCode,
    String source = 'my_products_share',
  }) {
    return withReferral(
      myProducts(userId),
      referralCode: referralCode,
      source: source,
      entityType: 'profile',
      entityId: userId,
    );
  }

  static String familyGalleryWithReferral({
    required String? userId,
    required String? referralCode,
    String source = 'family_gallery_share',
  }) {
    return withReferral(
      familyGallery(userId),
      referralCode: referralCode,
      source: source,
      entityType: 'profile',
      entityId: userId,
    );
  }

  static String shareGalleryWithReferral({
    required String? userId,
    required bool family,
    required String? referralCode,
  }) {
    return family
        ? familyGalleryWithReferral(
      userId: userId,
      referralCode: referralCode,
    )
        : myProductsWithReferral(
      userId: userId,
      referralCode: referralCode,
    );
  }

  static String downloadWithReferral({
    required String? referralCode,
    String source = 'app_share',
  }) {
    return withReferral(
      downloadUrl,
      referralCode: referralCode,
      source: source,
      entityType: 'app',
    );
  }

  static String withReferral(
      String link, {
        required String? referralCode,
        String? source,
        String? entityType,
        String? entityId,
      }) {
    final String cleanLink = _cleanLink(link);
    final String ref = _cleanReferralCode(referralCode);

    if (cleanLink.isEmpty) return downloadUrl;
    if (ref.isEmpty) return cleanLink;

    final Uri? uri = tryParse(cleanLink);
    if (uri == null) return cleanLink;

    final Map<String, String> query = Map<String, String>.from(
      uri.queryParameters,
    );

    query['ref'] = ref;

    final String cleanSource = _cleanQueryValue(source);
    if (cleanSource.isNotEmpty) {
      query['source'] = cleanSource;
    }

    final String cleanEntityType = _cleanQueryValue(entityType);
    if (cleanEntityType.isNotEmpty) {
      query['entity_type'] = cleanEntityType;
    }

    final String cleanEntityId = _cleanQueryValue(entityId);
    if (cleanEntityId.isNotEmpty) {
      query['entity_id'] = cleanEntityId;
    }

    return uri.replace(queryParameters: query).toString();
  }

  // ─────────────────────────────────────────────────────────────
  // Fallback / migration helpers
  // ─────────────────────────────────────────────────────────────

  static String productOrFallback({
    required String? productId,
    String? existingLink,
  }) {
    final String generated = product(productId);
    final String existing = _cleanLink(existingLink);

    if (_isValidTaapdeelLink(existing)) return existing;
    return generated;
  }

  static String productOrFallbackWithReferral({
    required String? productId,
    String? existingLink,
    required String? referralCode,
    String source = 'product_share',
  }) {
    final String resolved = productOrFallback(
      productId: productId,
      existingLink: existingLink,
    );

    return withReferral(
      resolved,
      referralCode: referralCode,
      source: source,
      entityType: 'product',
      entityId: productId,
    );
  }

  static String wishOrFallback({
    required String? wishId,
    String? existingLink,
  }) {
    final String generated = wish(wishId);
    final String existing = _cleanLink(existingLink);

    if (_isValidTaapdeelLink(existing)) return existing;
    return generated;
  }

  static String wishOrFallbackWithReferral({
    required String? wishId,
    String? existingLink,
    required String? referralCode,
    String source = 'wish_share',
  }) {
    final String resolved = wishOrFallback(
      wishId: wishId,
      existingLink: existingLink,
    );

    return withReferral(
      resolved,
      referralCode: referralCode,
      source: source,
      entityType: 'wish',
      entityId: wishId,
    );
  }

  static String profileOrFallback({
    required String? userId,
    String? existingLink,
  }) {
    final String generated = profile(userId);
    final String existing = _cleanLink(existingLink);

    if (_isValidTaapdeelLink(existing)) return existing;
    return generated;
  }

  static String profileOrFallbackWithReferral({
    required String? userId,
    String? existingLink,
    required String? referralCode,
    String source = 'profile_share',
  }) {
    final String resolved = profileOrFallback(
      userId: userId,
      existingLink: existingLink,
    );

    return withReferral(
      resolved,
      referralCode: referralCode,
      source: source,
      entityType: 'profile',
      entityId: userId,
    );
  }

  static bool isOldFirebaseDynamicLink(String? link) {
    final String value = _cleanLink(link).toLowerCase();

    if (value.isEmpty) return false;

    return value.contains('page.link') ||
        value.contains('buyse11.page.link') ||
        value.contains('firebaseapp.com') ||
        value.contains('app.goo.gl');
  }

  static bool isTaapdeelDeepLink(String? link) {
    final Uri? uri = tryParse(link);
    if (uri == null) return false;

    return uri.scheme == 'https' &&
        uri.host == appHost &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == 'l';
  }

  static bool needsReplacement(String? link) {
    final String value = _cleanLink(link);

    if (value.isEmpty) return true;
    if (isOldFirebaseDynamicLink(value)) return true;
    if (!isTaapdeelDeepLink(value)) return true;

    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // Parsing helpers for incoming deep links
  // ─────────────────────────────────────────────────────────────

  static Uri? tryParse(String? link) {
    final String value = _cleanLink(link);
    if (value.isEmpty) return null;

    try {
      return Uri.parse(value);
    } catch (_) {
      return null;
    }
  }

  static TaapdeelLinkTarget parseTarget(Uri uri) {
    final String referralCode = _cleanReferralCode(uri.queryParameters['ref']);
    final String source = _cleanQueryValue(uri.queryParameters['source']);
    final String entityType = _cleanQueryValue(
      uri.queryParameters['entity_type'],
    );
    final String entityId = _cleanQueryValue(uri.queryParameters['entity_id']);

    if (uri.scheme != 'https' || uri.host != appHost) {
      return TaapdeelLinkTarget.unknown(
        uri: uri,
        referralCode: referralCode,
        source: source,
        entityType: entityType,
        entityId: entityId,
      );
    }

    final List<String> segments = uri.pathSegments;

    if (segments.isEmpty || segments.first != 'l') {
      return TaapdeelLinkTarget.unknown(
        uri: uri,
        referralCode: referralCode,
        source: source,
        entityType: entityType,
        entityId: entityId,
      );
    }

    if (segments.length >= 3 && segments[1] == 'product') {
      return TaapdeelLinkTarget.product(
        uri: uri,
        id: segments[2],
        referralCode: referralCode,
        source: source,
        entityType: entityType.isEmpty ? 'product' : entityType,
        entityId: entityId.isEmpty ? segments[2] : entityId,
      );
    }

    if (segments.length >= 3 && segments[1] == 'wish') {
      return TaapdeelLinkTarget.wish(
        uri: uri,
        id: segments[2],
        referralCode: referralCode,
        source: source,
        entityType: entityType.isEmpty ? 'wish' : entityType,
        entityId: entityId.isEmpty ? segments[2] : entityId,
      );
    }

    if (segments.length >= 3 && segments[1] == 'profile') {
      return TaapdeelLinkTarget.profile(
        uri: uri,
        id: segments[2],
        openFamilyGallery: uri.queryParameters['family'] == '1',
        openMyProducts: uri.queryParameters['tab'] == 'items',
        referralCode: referralCode,
        source: source,
        entityType: entityType.isEmpty ? 'profile' : entityType,
        entityId: entityId.isEmpty ? segments[2] : entityId,
      );
    }

    if (segments.length >= 2 && segments[1] == 'swap-advice') {
      final String mine = _cleanId(uri.queryParameters['mine']);
      final String rawSuggestions = uri.queryParameters['s'] ?? '';

      final List<String> suggestions = rawSuggestions
          .split(',')
          .map(_cleanId)
          .where((String id) => id.isNotEmpty)
          .toList(growable: false);

      return TaapdeelLinkTarget.swapAdvice(
        uri: uri,
        myProductId: mine,
        suggestionIds: suggestions,
        referralCode: referralCode,
        source: source,
        entityType: entityType.isEmpty ? 'swap_advice' : entityType,
        entityId: entityId,
      );
    }

    return TaapdeelLinkTarget.unknown(
      uri: uri,
      referralCode: referralCode,
      source: source,
      entityType: entityType,
      entityId: entityId,
    );
  }

  static TaapdeelLinkTarget parseLink(String? link) {
    final Uri? uri = tryParse(link);
    if (uri == null) {
      return TaapdeelLinkTarget.empty();
    }

    return parseTarget(uri);
  }

  // ─────────────────────────────────────────────────────────────
  // Google Play Install Referrer helpers
  // ─────────────────────────────────────────────────────────────

  static String googlePlayUrlWithReferral({
    required String packageName,
    required String? referralCode,
    String source = 'app_share',
    String? entityType,
    String? entityId,
  }) {
    final String safePackage = _cleanQueryValue(packageName);
    if (safePackage.isEmpty) return downloadWithReferral(
      referralCode: referralCode,
      source: source,
    );

    final String ref = _cleanReferralCode(referralCode);
    final Uri base = Uri.https(
      'play.google.com',
      '/store/apps/details',
      <String, String>{'id': safePackage},
    );

    if (ref.isEmpty) return base.toString();

    final Map<String, String> referrerParams = <String, String>{
      'ref': ref,
      'source': _cleanQueryValue(source),
    };

    final String cleanEntityType = _cleanQueryValue(entityType);
    if (cleanEntityType.isNotEmpty) {
      referrerParams['entity_type'] = cleanEntityType;
    }

    final String cleanEntityId = _cleanQueryValue(entityId);
    if (cleanEntityId.isNotEmpty) {
      referrerParams['entity_id'] = cleanEntityId;
    }

    return base.replace(
      queryParameters: <String, String>{
        ...base.queryParameters,
        'referrer': Uri(queryParameters: referrerParams).query,
      },
    ).toString();
  }

  // ─────────────────────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────────────────────

  static String _cleanId(String? value) {
    final String text = (value ?? '').trim();

    if (text.isEmpty || text.toLowerCase() == 'null') return '';

    return Uri.encodeComponent(text);
  }

  static String _cleanLink(String? value) {
    final String text = (value ?? '').trim();

    if (text.isEmpty || text.toLowerCase() == 'null') return '';

    return text;
  }

  static String _cleanReferralCode(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';

    return Uri.encodeComponent(text);
  }

  static String _cleanQueryValue(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';

    return text;
  }

  static bool _isValidTaapdeelLink(String link) {
    if (link.isEmpty) return false;
    return isTaapdeelDeepLink(link);
  }
}

enum TaapdeelLinkTargetType {
  empty,
  product,
  wish,
  profile,
  swapAdvice,
  unknown,
}

class TaapdeelLinkTarget {
  const TaapdeelLinkTarget._({
    required this.type,
    this.uri,
    this.id,
    this.myProductId,
    this.suggestionIds = const <String>[],
    this.openFamilyGallery = false,
    this.openMyProducts = false,
    this.referralCode,
    this.source,
    this.entityType,
    this.entityId,
  });

  final TaapdeelLinkTargetType type;
  final Uri? uri;

  /// Used by product / wish / profile targets.
  final String? id;

  /// Used by swap-advice target.
  final String? myProductId;
  final List<String> suggestionIds;

  /// Used by profile target.
  final bool openFamilyGallery;
  final bool openMyProducts;

  /// Referral tracking metadata carried by ?ref=...&source=...
  final String? referralCode;
  final String? source;
  final String? entityType;
  final String? entityId;

  bool get isEmpty => type == TaapdeelLinkTargetType.empty;
  bool get isUnknown => type == TaapdeelLinkTargetType.unknown;
  bool get isProduct => type == TaapdeelLinkTargetType.product;
  bool get isWish => type == TaapdeelLinkTargetType.wish;
  bool get isProfile => type == TaapdeelLinkTargetType.profile;
  bool get isSwapAdvice => type == TaapdeelLinkTargetType.swapAdvice;
  bool get hasReferral => (referralCode ?? '').trim().isNotEmpty;

  factory TaapdeelLinkTarget.empty() {
    return const TaapdeelLinkTarget._(
      type: TaapdeelLinkTargetType.empty,
    );
  }

  factory TaapdeelLinkTarget.product({
    required Uri uri,
    required String id,
    String? referralCode,
    String? source,
    String? entityType,
    String? entityId,
  }) {
    return TaapdeelLinkTarget._(
      type: TaapdeelLinkTargetType.product,
      uri: uri,
      id: id,
      referralCode: referralCode,
      source: source,
      entityType: entityType,
      entityId: entityId,
    );
  }

  factory TaapdeelLinkTarget.wish({
    required Uri uri,
    required String id,
    String? referralCode,
    String? source,
    String? entityType,
    String? entityId,
  }) {
    return TaapdeelLinkTarget._(
      type: TaapdeelLinkTargetType.wish,
      uri: uri,
      id: id,
      referralCode: referralCode,
      source: source,
      entityType: entityType,
      entityId: entityId,
    );
  }

  factory TaapdeelLinkTarget.profile({
    required Uri uri,
    required String id,
    bool openFamilyGallery = false,
    bool openMyProducts = false,
    String? referralCode,
    String? source,
    String? entityType,
    String? entityId,
  }) {
    return TaapdeelLinkTarget._(
      type: TaapdeelLinkTargetType.profile,
      uri: uri,
      id: id,
      openFamilyGallery: openFamilyGallery,
      openMyProducts: openMyProducts,
      referralCode: referralCode,
      source: source,
      entityType: entityType,
      entityId: entityId,
    );
  }

  factory TaapdeelLinkTarget.swapAdvice({
    required Uri uri,
    required String myProductId,
    List<String> suggestionIds = const <String>[],
    String? referralCode,
    String? source,
    String? entityType,
    String? entityId,
  }) {
    return TaapdeelLinkTarget._(
      type: TaapdeelLinkTargetType.swapAdvice,
      uri: uri,
      myProductId: myProductId,
      suggestionIds: suggestionIds,
      referralCode: referralCode,
      source: source,
      entityType: entityType,
      entityId: entityId,
    );
  }

  factory TaapdeelLinkTarget.unknown({
    required Uri uri,
    String? referralCode,
    String? source,
    String? entityType,
    String? entityId,
  }) {
    return TaapdeelLinkTarget._(
      type: TaapdeelLinkTargetType.unknown,
      uri: uri,
      referralCode: referralCode,
      source: source,
      entityType: entityType,
      entityId: entityId,
    );
  }

  @override
  String toString() {
    return 'TaapdeelLinkTarget('
        'type: $type, '
        'id: $id, '
        'myProductId: $myProductId, '
        'suggestionIds: $suggestionIds, '
        'openFamilyGallery: $openFamilyGallery, '
        'openMyProducts: $openMyProducts, '
        'referralCode: $referralCode, '
        'source: $source, '
        'entityType: $entityType, '
        'entityId: $entityId, '
        'uri: $uri'
        ')';
  }
}
