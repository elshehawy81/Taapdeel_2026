import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:provider/provider.dart';

import '../Contacts/search_provider.dart';

typedef SectionCardBuilder = Widget Function({
required BuildContext context,
required Product product,
required String coreTagKey,
required VoidCallback onTap,
});

// ✅ Helper class للـ Selector
class _CarouselSectionData {
  const _CarouselSectionData({
    required this.items,
    required this.loading,
    required this.loadingMore,
  });

  final List<Product> items;
  final bool loading;
  final bool loadingMore;

  @override
  bool operator ==(Object other) =>
      other is _CarouselSectionData &&
          other.loading == loading &&
          other.loadingMore == loadingMore &&
          other.items == items;

  @override
  int get hashCode => Object.hash(loading, loadingMore, items);
}

/// ======================================================
/// ✅ BaseSectionCarouselSliver
/// ✅ FIX: استخدام Selector بدل Consumer لتحديد rebuild بدقة
/// ======================================================
class BaseSectionCarouselSliver extends StatefulWidget {
  const BaseSectionCarouselSliver({
    Key? key,
    required this.title,
    required this.url,
    required this.catId,
    required this.recentProvider,
    required this.cardBuilder,
    this.sectionHeight = 220,
    this.visibleCards = 2.09,
    this.showHeader = true,
    this.sectionWrapper,
  }) : super(key: key);

  final String title;
  final String url;
  final String Function() catId;
  final RecentProductProvider Function() recentProvider;
  final SectionCardBuilder cardBuilder;
  final double sectionHeight;
  final double visibleCards;
  final bool showHeader;
  final Widget Function(BuildContext context, Widget child)? sectionWrapper;

  @override
  State<BaseSectionCarouselSliver> createState() =>
      _BaseSectionCarouselSliverState();
}

class _BaseSectionCarouselSliverState extends State<BaseSectionCarouselSliver> {
  static const int _pageSize = 8;

  PageController? _controller;
  bool _requestedMore = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _maybeLoadMore(
      SearchProvider sp,
      List<Product> items,
      bool loading,
      bool loadingMore,
      ) {
    if (loading) return;
    if (loadingMore) return;
    if (_requestedMore) return;
    if (items.isEmpty) return;
    if (!sp.sectionHasMore(widget.url)) return;

    final c = _controller;
    if (c == null || !c.hasClients) return;

    final double page = c.page ?? 0;
    final int lastIndex = items.length - 1;

    if (page >= (lastIndex - 1.2)) {
      _requestedMore = true;
      sp
          .loadMoreSection(
        filterUrl: widget.url,
        catId: widget.catId(),
        pageSize: _pageSize,
      )
          .whenComplete(() {
        _requestedMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      // ✅ FIX: Selector بدل Consumer
      child: Selector<SearchProvider, _CarouselSectionData>(
        selector: (_, sp) => _CarouselSectionData(
          items: sp.sectionProducts(widget.url),
          loading: sp.sectionLoading(widget.url),
          loadingMore: sp.sectionLoadingMore(widget.url),
        ),
        shouldRebuild: (prev, next) => prev != next,
        builder: (context, data, _) {
          final bool loading = data.loading;
          final bool loadingMore = data.loadingMore;
          final List<Product> items = data.items;

          if (!loading && items.isEmpty) return const SizedBox.shrink();

          final Widget inner = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 10, 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withAlpha(180),
                              Colors.purple.withAlpha(160),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                height: widget.sectionHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double w = constraints.maxWidth;
                    const double gap = 3;

                    final double cardW = (w - (gap * 2)) / widget.visibleCards;
                    final double vf = (cardW + gap) / w;

                    _controller ??= PageController(
                      viewportFraction: vf,
                      initialPage: 0,
                    );

                    final int itemCount = loading
                        ? _pageSize
                        : items.length + (loadingMore ? _pageSize : 0);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // ✅ FIX: قرأنا الـ sp مباشرة بـ listen:false بدل ما نمرره من الـ Selector
                      if (!context.mounted) return;
                      final sp = SearchProvider.of(context, listen: false);
                      _maybeLoadMore(sp, items, loading, loadingMore);
                    });

                    return Directionality(
                      textDirection: Directionality.of(context),
                      child: PageView.builder(
                        controller: _controller,
                        padEnds: false,
                        physics: const BouncingScrollPhysics(),
                        itemCount: itemCount,
                        onPageChanged: (_) {
                          if (!context.mounted) return;
                          final sp = SearchProvider.of(context, listen: false);
                          _maybeLoadMore(sp, items, loading, loadingMore);
                        },
                        itemBuilder: (context, index) {
                          if (loading || index >= items.length) {
                            return const Padding(
                              padding: EdgeInsetsDirectional.only(end: gap),
                              child: SizedBox.shrink(),
                            );
                          }

                          final Product product = items[index];

                          final String coreTagKey =
                              '${widget.recentProvider().hashCode}_${widget.url}_${product.id}_$index';

                          return Padding(
                            padding: const EdgeInsetsDirectional.only(end: gap),
                            child: widget.cardBuilder(
                              context: context,
                              product: product,
                              coreTagKey: coreTagKey,
                              onTap: () {
                                final String productId =
                                (product.id ?? '').toString();
                                if (productId.isEmpty) return;

                                Navigator.pushNamed(
                                  context,
                                  RoutePaths.productDetail,
                                  arguments: ProductDetailIntentHolder(
                                    productId: productId,
                                    heroTagImage:
                                    '$coreTagKey${PsConst.HERO_TAG__IMAGE}',
                                    heroTagTitle:
                                    '$coreTagKey${PsConst.HERO_TAG__TITLE}',
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );

          final Widget wrapped =
              widget.sectionWrapper?.call(context, inner) ?? inner;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: wrapped,
          );
        },
      ),
    );
  }
}

class BaseSectionSliver extends BaseSectionCarouselSliver {
  const BaseSectionSliver({
    Key? key,
    required String title,
    required String url,
    required String Function() catId,
    required RecentProductProvider Function() recentProvider,
    required SectionCardBuilder cardBuilder,
    double sectionHeight = 220,
    double visibleCards = 2.09,
    bool showHeader = true,
    Widget Function(BuildContext context, Widget child)? sectionWrapper,
  }) : super(
    key: key,
    title: title,
    url: url,
    catId: catId,
    recentProvider: recentProvider,
    cardBuilder: cardBuilder,
    sectionHeight: sectionHeight,
    visibleCards: visibleCards,
    showHeader: showHeader,
    sectionWrapper: sectionWrapper,
  );
}
