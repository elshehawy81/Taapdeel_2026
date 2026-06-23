import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:taapdeel/api/ps_url.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/ui/wish_Items/wish_tag_models.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';

import '../../Contacts/search_provider.dart';
import '../../user/admin/wish_ui_tabs_widgets.dart';



// ============================================================
//  WishItemsProvider
//  ChangeNotifier that acts as a bridge: the dashboard calls
//  getWishListProduct / reload, which stores load params and
//  notifies WishItemsSectionSliver to trigger SearchProvider.
// ============================================================
class WishItemsProvider extends ChangeNotifier {
  _WishLoadParams? _pendingLoad;

  /// Params requested by the last [getWishListProduct] call.
  _WishLoadParams? get pendingLoad => _pendingLoad;

  /// Called by the dashboard when the "wish" chip is selected.
  Future<void> getWishListProduct({
    String? itemLocationId,
    String? itemLocationTownshipId,
    String catId = '',
  }) async {
    _pendingLoad = _WishLoadParams(
      itemLocationId: itemLocationId,
      itemLocationTownshipId: itemLocationTownshipId,
      catId: catId,
    );
    notifyListeners();
  }

  /// Called after adding a new wish item to refresh the feed.
  Future<void> reload({
    String? itemLocationId,
    String? itemLocationTownshipId,
    String catId = '',
  }) =>
      getWishListProduct(
        itemLocationId: itemLocationId,
        itemLocationTownshipId: itemLocationTownshipId,
        catId: catId,
      );

  /// Called by [WishItemsSectionSliver] after the load is complete.
  void clearPending() {
    if (_pendingLoad != null) {
      _pendingLoad = null;
      // no notifyListeners needed — sliver already rebuilding from SearchProvider
    }
  }
}

class _WishLoadParams {
  const _WishLoadParams({
    this.itemLocationId,
    this.itemLocationTownshipId,
    this.catId = '',
  });
  final String? itemLocationId;
  final String? itemLocationTownshipId;
  final String catId;
}

// ============================================================
//  Internal data helpers
// ============================================================

class _WishSectionData {
  const _WishSectionData({
    required this.items,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
  });

  final List<Product> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;

  @override
  bool operator ==(Object other) =>
      other is _WishSectionData &&
          other.loading == loading &&
          other.loadingMore == loadingMore &&
          other.hasMore == hasMore &&
          other.items == items;

  @override
  int get hashCode => Object.hash(loading, loadingMore, hasMore, items);
}

// ============================================================
//  WishItemsSectionSliver
// ============================================================
/// Replaces the generic [BaseSectionGridSliver] for the Wish / Hawadeet tab.
///
/// Layout:
///   ▸ section header
///   ▸ "احكي أمنيتك" add-wish button
///   ▸ horizontal category filter chips
///   ▸ big [HawadeetWishCard] for items that have a story (hook_phrase / story_title)
///   ▸ 2-column mini grid for items without a story
///   ▸ "load more" + "end of list" indicators
class WishItemsSectionSliver extends StatefulWidget {
  const WishItemsSectionSliver({
    Key? key,
    required this.title,
    required this.onAddWishItem,
    this.onAddProductItem,
    required this.onShareWishItem,
    this.itemLocationId,
    this.itemLocationTownshipId,
    this.catId = '',
    this.showHeader = true,
    this.childAspectRatio = 0.72,
    this.imageBaseUrl = '',
    this.scrollController,
  }) : super(key: key);

  final String title;
  final VoidCallback onAddWishItem;

  /// Called when the user taps "عندي المنتج" / "اعمل عرض" on a wish card.
  /// This should open the normal product-entry flow, not the wish-entry flow.
  ///
  /// If the parent page does not pass this callback yet, we try to open
  /// [RoutePaths.itemEntry] directly as a safe fallback.
  final VoidCallback? onAddProductItem;

  final void Function(Product product) onShareWishItem;
  final String? itemLocationId;
  final String? itemLocationTownshipId;
  final String catId;
  final bool showHeader;
  final double childAspectRatio;

  /// Optional base-url prepended to relative image paths.
  final String imageBaseUrl;

  /// ScrollController الأب لتحميل المزيد عند قرب المستخدم من نهاية الصفحة فقط.
  final ScrollController? scrollController;

  @override
  State<WishItemsSectionSliver> createState() => _WishItemsSectionSliverState();
}

class _WishItemsSectionSliverState extends State<WishItemsSectionSliver> {
  String _filterKey = 'all';
  String? _openCardId;
  bool   _requestedMore = false;

  static const int _pageSize = 10;
  static const double _loadMoreExtentAfter = 220;
  static const Duration _loadMoreThrottle = Duration(milliseconds: 1200);

  DateTime? _lastLoadMoreCheck;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onParentScroll);
  }

  @override
  void didUpdateWidget(covariant WishItemsSectionSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onParentScroll);
      widget.scrollController?.addListener(_onParentScroll);
      _requestedMore = false;
      _lastLoadMoreCheck = null;
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onParentScroll);
    super.dispose();
  }

  void _onParentScroll() {
    if (!mounted) return;

    final ScrollController? controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;

    final ScrollPosition position = controller.position;
    if (position.userScrollDirection != ScrollDirection.reverse) return;
    if (position.extentAfter > _loadMoreExtentAfter) return;

    final DateTime now = DateTime.now();
    if (_lastLoadMoreCheck != null &&
        now.difference(_lastLoadMoreCheck!) < _loadMoreThrottle) {
      return;
    }
    _lastLoadMoreCheck = now;

    final SearchProvider sp = SearchProvider.of(context, listen: false);
    _maybeLoadMore(
      sp,
      sp.sectionProducts(PsUrl.ps_get_wishlist_items_url),
      sp.sectionLoading(PsUrl.ps_get_wishlist_items_url),
      sp.sectionLoadingMore(PsUrl.ps_get_wishlist_items_url),
    );
  }

  // ── filter ────────────────────────────────────────────────
  List<WishCardData> _applyFilter(List<WishCardData> all) {
    if (_filterKey == 'all') return all;
    return all.where((WishCardData item) => (item.catId ?? '').toString() == _filterKey).toList();
  }

  List<HawadeetCategoryFilter> _buildVisibleCategoryFilters({
    required List<WishCardData> models,
    required List<Product> products,
  }) {
    final Map<String, HawadeetCategoryFilter> result = <String, HawadeetCategoryFilter>{
      'all': const HawadeetCategoryFilter(
        key: 'all',
        label: 'الكل',
        iconName: 'auto_stories',
        keywords: <String>[],
      ),
    };

    for (final WishCardData model in models) {
      final String catId = (model.catId ?? '').trim();
      if (catId.isEmpty || result.containsKey(catId)) continue;

      final Product? product = products.cast<Product?>().firstWhere(
            (Product? p) => (p?.id ?? '').toString() == model.id,
        orElse: () => null,
      );

      final String label = _categoryLabelFromProduct(product, catId);
      result[catId] = HawadeetCategoryFilter(
        key: catId,
        label: label,
        iconName: _iconNameForCategory(label),
        keywords: <String>[],
      );
    }

    return result.values.toList(growable: false);
  }

  String _categoryLabelFromProduct(Product? product, String fallback) {
    if (product == null) return 'فئة $fallback';
    final dynamic dp = product;

    String read(dynamic Function() getter) {
      try {
        final String value = (getter() ?? '').toString().trim();
        if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
      } catch (_) {}
      return '';
    }

    final List<String> candidates = <String>[
      read(() => dp.category?.name),
      read(() => dp.category?.nameAr),
      read(() => dp.category?.catName),
      read(() => dp.catName),
      read(() => dp.cat_name),
      read(() => dp.categoryName),
      read(() => dp.category_name),
      read(() => dp.cat?.name),
      read(() => dp.cat?.catName),
    ];

    for (final String candidate in candidates) {
      if (candidate.isNotEmpty) return candidate;
    }

    return 'فئة $fallback';
  }

  String _iconNameForCategory(String label) {
    final String text = label.toLowerCase();
    if (text.contains('ملابس') || text.contains('فستان') || text.contains('احذية') || text.contains('أحذية') || text.contains('fashion')) return 'checkroom';
    if (text.contains('كتب') || text.contains('مدرس') || text.contains('book')) return 'menu_book';
    if (text.contains('لعب') || text.contains('أطفال') || text.contains('اطفال') || text.contains('toy')) return 'toys';
    if (text.contains('بيت') || text.contains('منزل') || text.contains('أثاث') || text.contains('اثاث') || text.contains('home')) return 'home';
    if (text.contains('إلكتر') || text.contains('الكتر') || text.contains('موبايل') || text.contains('elect')) return 'devices';
    if (text.contains('رياض') || text.contains('كرة') || text.contains('sport')) return 'sports_soccer';
    if (text.contains('هدايا') || text.contains('هدية') || text.contains('gift')) return 'card_giftcard';
    return 'auto_stories';
  }

  // ── Me Too (optimistic via SearchProvider-level logic or local only for MVP) ─
  Future<void> _handleMeToo(BuildContext ctx, String id, bool nowReacted) async {
    // For MVP: the toggle is already done optimistically inside HawadeetWishCard.
    // Production: call an API to POST /rest/hawadeet/react
    // We just fire and forget here (no-op shell that can be wired later).
    debugPrint('[WishSection] MeToo: id=$id reacted=$nowReacted');
  }

  // ── load more ─────────────────────────────────────────────
  void _maybeLoadMore(SearchProvider sp, List<Product> items, bool loading, bool loadingMore) {
    if (loading || loadingMore || _requestedMore || items.isEmpty) return;
    if (!sp.sectionHasMore(PsUrl.ps_get_wishlist_items_url)) return;

    _requestedMore = true;
    sp
        .loadMoreSection(
      filterUrl: PsUrl.ps_get_wishlist_items_url,
      catId: widget.catId,
      pageSize: _pageSize,
    )
        .whenComplete(() => _requestedMore = false);
  }

  // ── navigate to product detail ────────────────────────────
  void _openDetail(BuildContext ctx, Product product, String tagKey) {
    final String id = (product.id ?? '').toString();
    if (id.isEmpty) return;
    Navigator.pushNamed(
      ctx,
      RoutePaths.productDetail,
      arguments: ProductDetailIntentHolder(
        productId: id,
        heroTagImage: '${tagKey}${PsConst.HERO_TAG__IMAGE}',
        heroTagTitle: '${tagKey}${PsConst.HERO_TAG__TITLE}',
      ),
    );
  }

  void _openAddProductEntry(BuildContext ctx) {
    final VoidCallback? callback = widget.onAddProductItem;
    if (callback != null) {
      callback();
      return;
    }

    // Fallback for pages that have not been updated to pass
    // onAddProductItem yet. The card action is about offering an item the
    // user already has, so it must go to the normal item-entry flow.
    Navigator.pushNamed(
      ctx,
      RoutePaths.itemEntry,
      arguments: <String, dynamic>{
        'flag': PsConst.ADD_NEW_ITEM,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Listen to WishItemsProvider for load triggers ────────
    // When the dashboard calls getWishListProduct / reload,
    // WishItemsProvider stores the params. We pick them up here
    // and forward the actual load to SearchProvider.
    final wishProvider = context.watch<WishItemsProvider>();
    final pending = wishProvider.pendingLoad;
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final sp = SearchProvider.of(context, listen: false);
        sp
            .loadSection(
          filterUrl: PsUrl.ps_get_wishlist_items_url,
          catId: pending.catId,
          pageSize: _pageSize,
        )
            .whenComplete(() => wishProvider.clearPending());
      });
    }

    return SliverToBoxAdapter(
      child: Selector<SearchProvider, _WishSectionData>(
        selector: (_, sp) => _WishSectionData(
          items: sp.sectionProducts(PsUrl.ps_get_wishlist_items_url),
          loading: sp.sectionLoading(PsUrl.ps_get_wishlist_items_url),
          loadingMore: sp.sectionLoadingMore(PsUrl.ps_get_wishlist_items_url),
          hasMore: sp.sectionHasMore(PsUrl.ps_get_wishlist_items_url),
        ),
        shouldRebuild: (prev, next) => prev != next,
        builder: (ctx, data, _) {
          final bool loading     = data.loading;
          final bool loadingMore = data.loadingMore;
          final bool hasMore     = data.hasMore;
          final List<Product> raw = data.items;

          // PERF: لا نحمل صفحات إضافية تلقائيًا بمجرد بناء القائمة.
          // التحميل التالي يتم فقط من _onParentScroll عند اقتراب المستخدم من النهاية.

          // Convert + filter
          final List<WishCardData> allModels =
          raw.map((p) => WishCardData.fromProduct(p)).toList();
          final List<HawadeetCategoryFilter> visibleFilters = _buildVisibleCategoryFilters(
            models: allModels,
            products: raw,
          );
          if (!visibleFilters.any((HawadeetCategoryFilter f) => f.key == _filterKey)) {
            _filterKey = 'all';
          }
          final List<WishCardData> filtered  = _applyFilter(allModels);

          final List<WishCardData> withStory    = filtered.where((m) => m.hasHawadeet).toList();
          final List<WishCardData> withoutStory = filtered.where((m) => !m.hasHawadeet).toList();

          // Don't render if nothing at all


          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showHeader)
                WishSectionHeader(totalCount: allModels.length),

              WishAddButton(
                onTap: widget.onAddWishItem,
              ),

              const SizedBox(height: 8),

              if (!loading && filtered.isEmpty) ...[
                const SizedBox(height: 24),
                _WishEmptyState(
                  onAddWishItem: widget.onAddWishItem,
                ),
                const SizedBox(height: 24),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: HawadeetCategoryFilterBar(
                    filters: visibleFilters,
                    selectedKey: _filterKey,
                    onSelect: (key) => setState(() => _filterKey = key),
                  ),
                ),

                const SizedBox(height: 12),

                if (loading && filtered.isEmpty)
                  _WishLoadingShimmer(),

                ...withStory.asMap().entries.map((entry) {
                  final int idx = entry.key;
                  final WishCardData m = entry.value;
                  final Product? prod = raw.cast<Product?>().firstWhere(
                        (Product? p) => p?.id == m.id,
                    orElse: () => null,
                  );

                  return HawadeetWishCard(
                    key: ValueKey('hwcard_${m.id}'),
                    data: m,
                    product: prod,
                    imageBaseUrl: widget.imageBaseUrl,
                    themeIndex: idx,
                    openCardId: _openCardId,
                    onExpansionChanged: (String id, bool expanded) {
                      setState(() => _openCardId = expanded ? id : null);
                    },
                    onMeToo: (id, reacted) => _handleMeToo(ctx, id, reacted),
                    onHaveItem: () => _openAddProductEntry(ctx),
                    onShare: () {
                      if (prod != null) widget.onShareWishItem(prod);
                    },
                    onAddOffer: () => _navigateToOffer(ctx, m),
                  );
                }),

                if (withoutStory.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: withoutStory.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: widget.childAspectRatio,
                      ),
                      itemBuilder: (ctx2, i) {
                        final WishCardData m = withoutStory[i];
                        final String tagKey = 'wish_mini_${m.id}_$i';

                        return WishMiniProductCard(
                          key: ValueKey('wsmini_${m.id}'),
                          data: m,
                          imageBaseUrl: widget.imageBaseUrl,
                          onTap: () {
                            final Product? prod = raw.cast<Product?>().firstWhere(
                                  (p) => p?.id == m.id,
                              orElse: () => null,
                            );
                            if (prod != null) _openDetail(ctx2, prod, tagKey);
                          },
                        );
                      },
                    ),
                  ),

                if (loadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  void _navigateToOffer(BuildContext ctx, WishCardData m) {
    _openAddProductEntry(ctx);
  }
}

// ============================================================
//  Shimmer loading placeholder
// ============================================================
class _WishLoadingShimmer extends StatefulWidget {
  @override
  State<_WishLoadingShimmer> createState() => _WishLoadingShimmerState();
}

class _WishLoadingShimmerState extends State<_WishLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _shimmerCard(height: 180),
        const SizedBox(height: 10),
        _shimmerCard(height: 160),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(child: _shimmerCard(height: 160)),
              const SizedBox(width: 8),
              Expanded(child: _shimmerCard(height: 160)),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _shimmerCard({required double height}) {
    final Color base  = Colors.black.withAlpha(7);
    final Color shine = Colors.black.withAlpha(18);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.45, 0.55, 1.0],
              colors: [base, shine, shine, base],
              transform: _SlideTransform(_anim.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.slide);
  final double slide;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}

class _WishEmptyState extends StatelessWidget {
  const _WishEmptyState({
    required this.onAddWishItem,
  });

  final VoidCallback onAddWishItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE7F0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF043757).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: Color(0xFF0C587A),
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            ' لا يوجد منتجات مطلوبة',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF043757),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ابدأ بإضافة حاجة نفسك تلاقيها\n وتبديـــل عنده الحل.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withOpacity(0.56),
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}