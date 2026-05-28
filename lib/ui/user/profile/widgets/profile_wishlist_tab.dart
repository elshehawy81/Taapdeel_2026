import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:provider/provider.dart';

import '../../../Foryou/home_provider.dart';
import '../../../wish_Items/Wishlist_model.dart';

class _WishSkeletonCard extends StatelessWidget {
  const _WishSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.78),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.055),
                child: Center(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.055),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.055),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    height: 10,
                    width: 82,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.045),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 10,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.055),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileWishlistTab extends StatefulWidget {
  const ProfileWishlistTab({required this.userId});

  final String? userId;

  @override
  State<ProfileWishlistTab> createState() => _ProfileWishlistTabState();
}

class _ProfileWishlistTabState extends State<ProfileWishlistTab>
    with AutomaticKeepAliveClientMixin {
  bool _loaded = false;
  bool _loadMoreFired = false;

  @override
  bool get wantKeepAlive => true;

  String? _resolveUid() {
    final PsValueHolder vh = context.read<PsValueHolder>();
    return (vh.loginUserId == null || vh.loginUserId == '')
        ? widget.userId
        : vh.loginUserId;
  }

  void _tryLoadMore(HomeProvider hp) {
    try {
      final bool hasMore = (hp as dynamic).wishHasMore as bool;
      final bool loadingMore = (hp as dynamic).wishLoadingMore as bool;
      if (hasMore && !loadingMore) {
        (hp as dynamic).loadMoreWishlist();
      }
    } catch (_) {
      // HomeProvider may not support wishlist pagination yet.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    final String? uid = _resolveUid();
    if (uid == null || uid.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      HomeProvider.of(context, listen: false).getOwnerWishListProduct(uid);
    });
  }

  int _crossAxisCount(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    return w < 340 ? 1 : 2;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<HomeProvider>(
      builder: (BuildContext context, HomeProvider hp, _) {
        final bool isLoading = hp.wishLoading;
        final List<WishlistProductModel> items = hp.wishListProducts;

        final bool isLoadingMore = (() {
          try {
            return (hp as dynamic).wishLoadingMore as bool;
          } catch (_) {
            return false;
          }
        })();

        final bool hasMore = (() {
          try {
            return (hp as dynamic).wishHasMore as bool;
          } catch (_) {
            return false;
          }
        })();

        final int crossAxisCount = _crossAxisCount(context);
        const double childAspectRatio = 0.82;

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification n) {
            if (n is ScrollUpdateNotification || n is ScrollEndNotification) {
              final ScrollMetrics metrics = n.metrics;

              if (metrics.maxScrollExtent <= 0) return false;

              final bool nearEnd = metrics.extentAfter < 300;

              if (!nearEnd) {
                _loadMoreFired = false;
                return false;
              }

              if (_loadMoreFired) return false;
              _loadMoreFired = true;

              _tryLoadMore(hp);
            }
            return false;
          },
          child: CustomScrollView(
            cacheExtent: 800,
            slivers: <Widget>[
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              if (isLoading && items.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (_, __) => const _WishSkeletonCard(),
                      childCount: 6,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: childAspectRatio,
                    ),
                  ),
                )
              else if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                    child: _ProfileWishEmptyCard(
                      onRetry: () {
                        final String? uid = _resolveUid();
                        if (uid == null || uid.isEmpty) return;
                        HomeProvider.of(context, listen: false)
                            .getOwnerWishListProduct(uid);
                      },
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext ctx, int i) {
                        final bool showFooterLoader = isLoadingMore ||
                            (isLoading && items.isNotEmpty) ||
                            hasMore;

                        if (showFooterLoader && i >= items.length) {
                          return const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        final WishlistProductModel wish = items[i];
                        return ProfileWishItemCard(
                          wish: wish,
                          onTap: () {},
                        );
                      },
                      childCount: items.length +
                          ((isLoadingMore ||
                              (isLoading && items.isNotEmpty) ||
                              hasMore)
                              ? 1
                              : 0),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: childAspectRatio,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileWishEmptyCard extends StatelessWidget {
  const _ProfileWishEmptyCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PsColors.bottomNav.withOpacity(0.12)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.favorite_border_rounded,
            size: 48,
            color: PsColors.bottomNav.withOpacity(0.25),
          ),
          const SizedBox(height: 12),
          Text(
            'لا يوجد عناصر في قائمة الرغبات',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class ProfileWishItemCard extends StatelessWidget {
  const ProfileWishItemCard({
    Key? key,
    required this.wish,
    this.onTap,
  }) : super(key: key);

  final WishlistProductModel wish;
  final VoidCallback? onTap;

  static String _readString(dynamic source, List<String> fields) {
    for (final String field in fields) {
      try {
        final dynamic value = _readDynamic(source, field);
        final String text = (value ?? '').toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      } catch (_) {}
    }
    return '';
  }

  static dynamic _readDynamic(dynamic source, String field) {
    switch (field) {
      case 'id':
        return source.id;
      case 'title':
        return source.title;
      case 'name':
        return source.name;
      case 'itemTitle':
        return source.itemTitle;
      case 'item_title':
        return source.item_title;
      case 'wishTitle':
        return source.wishTitle;
      case 'wish_title':
        return source.wish_title;
      case 'itemName':
        return source.itemName;
      case 'item_name':
        return source.item_name;
      case 'price':
        return source.price;
      case 'itemPrice':
        return source.itemPrice;
      case 'item_price':
        return source.item_price;
      case 'lowPrice':
        return source.lowPrice;
      case 'low_price':
        return source.low_price;
      case 'highPrice':
        return source.highPrice;
      case 'high_price':
        return source.high_price;
      case 'image':
        return source.image;
      case 'imagePath':
        return source.imagePath;
      case 'image_path':
        return source.image_path;
      case 'imgPath':
        return source.imgPath;
      case 'img_path':
        return source.img_path;
      case 'defaultPhotoPath':
        return source.defaultPhotoPath;
      case 'default_photo_path':
        return source.default_photo_path;
      case 'photo':
        return source.photo;
      case 'defaultPhoto':
        return source.defaultPhoto;
      case 'default_photo':
        return source.default_photo;
      case 'thumbnail':
        return source.thumbnail;
      case 'thumb':
        return source.thumb;
      default:
        return null;
    }
  }

  static String _readNestedPhoto(dynamic source) {
    for (final String field in <String>['defaultPhoto', 'default_photo', 'photo']) {
      try {
        final dynamic photo = _readDynamic(source, field);
        if (photo == null) continue;

        final String direct = _readString(photo, <String>[
          'imgPath',
          'img_path',
          'imagePath',
          'image_path',
          'path',
          'url',
        ]);
        if (direct.isNotEmpty) return direct;
      } catch (_) {}
    }
    return '';
  }

  static String _resolveTitle(WishlistProductModel wish) {
    final dynamic d = wish;
    final String title = _readString(d, <String>[
      'title',
      'wishTitle',
      'wish_title',
      'itemTitle',
      'item_title',
      'itemName',
      'item_name',
      'name',
    ]);

    return title.isNotEmpty ? title : 'منتج مطلوب';
  }

  static int? _parsePositiveInt(String value) {
    final String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    final int? parsed = int.tryParse(cleaned);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  static String _resolvePrice(WishlistProductModel wish) {
    final dynamic d = wish;

    final int? low = _parsePositiveInt(_readString(d, <String>[
      'lowPrice',
      'low_price',
    ]));
    final int? high = _parsePositiveInt(_readString(d, <String>[
      'highPrice',
      'high_price',
    ]));

    if (low != null && high != null) {
      if (low == high) return '$low جنيه';
      final int minValue = low < high ? low : high;
      final int maxValue = low < high ? high : low;
      return '$minValue - $maxValue جنيه';
    }

    if (low != null) return '$low جنيه';
    if (high != null) return '$high جنيه';

    final String priceText = _readString(d, <String>[
      'price',
      'itemPrice',
      'item_price',
    ]);

    if (priceText.isEmpty) return '';

    final int? price = _parsePositiveInt(priceText);
    if (price != null) return '$price جنيه';

    return priceText;
  }

  static String _resolveImagePath(WishlistProductModel wish) {
    final dynamic d = wish;
    final String nested = _readNestedPhoto(d);
    if (nested.isNotEmpty) return nested;

    return _readString(d, <String>[
      'image',
      'imagePath',
      'image_path',
      'imgPath',
      'img_path',
      'defaultPhotoPath',
      'default_photo_path',
      'thumbnail',
      'thumb',
    ]);
  }

  static ImageProvider? _imageProviderFor(WishlistProductModel wish) {
    final String raw = _resolveImagePath(wish).trim();
    if (raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return NetworkImage(raw);
    }

    final String normalized = raw.startsWith('/') ? raw.substring(1) : raw;
    return NetworkImage('${PsConfig.ps_app_image_url}$normalized');
  }

  @override
  Widget build(BuildContext context) {
    final String title = _resolveTitle(wish);
    final String price = _resolvePrice(wish);
    final ImageProvider? imageProvider = _imageProviderFor(wish);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            border: Border.all(color: Colors.black.withOpacity(0.055)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: imageProvider != null
                            ? Image(
                          image: imageProvider,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const _WishImagePlaceholder(),
                        )
                            : const _WishImagePlaceholder(),
                      ),
                    ),
                    PositionedDirectional(
                      top: 7,
                      start: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFBCEAF1),
                          ),
                        ),
                        child: Text(
                          'مطلوب',
                          maxLines: 1,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF0A7C88),
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: PsColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const Spacer(),
                      if (price.isNotEmpty)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5FEFF),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFBCEAF1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                              style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF0A7C88),
                                fontWeight: FontWeight.w900,
                                fontSize: 10.5,
                                height: 1,
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
        ),
      ),
    );
  }
}

class _WishImagePlaceholder extends StatelessWidget {
  const _WishImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.025),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: Colors.black.withOpacity(0.20),
        ),
      ),
    );
  }
}
