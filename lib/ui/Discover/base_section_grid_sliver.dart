import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/product.dart';

import '../../../constant/ps_constants.dart';
import '../../../constant/route_paths.dart';
import '../Contacts/search_provider.dart';

typedef GridCardBuilder = Widget Function({
  required BuildContext context,
  required Product product,
  required String coreTagKey,
  required VoidCallback onTap,
});

class BaseSectionCategoryChip {
  const BaseSectionCategoryChip({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class _SubCatChipData {
  const _SubCatChipData({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is _SubCatChipData && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

class _SectionData {
  const _SectionData({
    required this.items,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.subCats,
    required this.selectedSubCat,
  });

  final List<Product> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final List<_SubCatChipData> subCats;
  final String selectedSubCat;

  @override
  bool operator ==(Object other) =>
      other is _SectionData &&
      other.items == items &&
      other.loading == loading &&
      other.loadingMore == loadingMore &&
      other.hasMore == hasMore &&
      other.subCats == subCats &&
      other.selectedSubCat == selectedSubCat;

  @override
  int get hashCode => Object.hash(
        items,
        loading,
        loadingMore,
        hasMore,
        subCats,
        selectedSubCat,
      );
}

class BaseSectionGridSliver extends StatefulWidget {
  const BaseSectionGridSliver({
    Key? key,
    required this.title,
    required this.url,
    required this.catId,
    required this.recentProvider,
    required this.cardBuilder,
    this.showHeader = true,
    this.sectionWrapper,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 5,
    this.crossAxisSpacing = 5,
    this.childAspectRatio = 0.72,
    this.loadingItemCount = 6,
    this.horizontalPadding = 12,
    this.bottomPadding = 12,
    this.loadMorePageSize = 10,
    this.showSubCategoryChips = true,
    this.showAllCategoryChip = true,
    this.leadingSubCategoryChip,
    this.categoryChips,
    this.selectedCategoryChipId,
    this.onCategoryChipSelected,
    this.scrollController,
  }) : super(key: key);

  final String title;
  final String url;
  final String Function() catId;
  final RecentProductProvider Function() recentProvider;
  final GridCardBuilder cardBuilder;
  final bool showHeader;
  final Widget Function(BuildContext context, Widget child)? sectionWrapper;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final int loadingItemCount;
  final double horizontalPadding;
  final double bottomPadding;
  final int loadMorePageSize;
  final bool showSubCategoryChips;
  final bool showAllCategoryChip;
  final Widget? leadingSubCategoryChip;
  final List<BaseSectionCategoryChip>? categoryChips;
  final String? selectedCategoryChipId;
  final ValueChanged<String>? onCategoryChipSelected;
  final ScrollController? scrollController;

  @override
  State<BaseSectionGridSliver> createState() => _BaseSectionGridSliverState();
}

class _BaseSectionGridSliverState extends State<BaseSectionGridSliver> {
  bool _requestedMore = false;
  DateTime? _lastLoadMoreCheck;

  static const double _loadMoreExtentAfter = 220;
  static const Duration _loadMoreThrottle = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onParentScroll);
  }

  @override
  void didUpdateWidget(covariant BaseSectionGridSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onParentScroll);
      widget.scrollController?.addListener(_onParentScroll);
      _requestedMore = false;
      _lastLoadMoreCheck = null;
    }

    if (oldWidget.url != widget.url || oldWidget.catId() != widget.catId()) {
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
      sp.sectionProducts(widget.url),
      sp.sectionLoading(widget.url),
      sp.sectionLoadingMore(widget.url),
    );
  }

  void _maybeLoadMore(
    SearchProvider sp,
    List<Product> items,
    bool loading,
    bool loadingMore,
  ) {
    if (loading || loadingMore || _requestedMore || items.isEmpty) return;
    if (!sp.sectionHasMore(widget.url)) return;

    _requestedMore = true;
    sp
        .loadMoreSection(
          filterUrl: widget.url,
          catId: widget.catId(),
          pageSize: widget.loadMorePageSize,
        )
        .whenComplete(() => _requestedMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<SearchProvider, _SectionData>(
      selector: (_, SearchProvider sp) {
        final bool useExternalCategoryChips = widget.categoryChips != null;
        final List<_SubCatChipData> chips = useExternalCategoryChips
            ? widget.categoryChips!
                .map((BaseSectionCategoryChip c) =>
                    _SubCatChipData(id: c.id, name: c.name))
                .toList(growable: false)
            : sp
                .sectionSubCats(widget.url)
                .map((s) => _SubCatChipData(id: s.id, name: s.name))
                .toList(growable: false);

        return _SectionData(
          items: useExternalCategoryChips
              ? sp.sectionProducts(widget.url)
              : sp.sectionFilteredProducts(widget.url),
          loading: sp.sectionLoading(widget.url),
          loadingMore: sp.sectionLoadingMore(widget.url),
          hasMore: sp.sectionHasMore(widget.url),
          subCats: chips,
          selectedSubCat: useExternalCategoryChips
              ? (widget.selectedCategoryChipId ?? '')
              : sp.sectionSelectedSubCat(widget.url),
        );
      },
      shouldRebuild: (prev, next) => prev != next,
      builder: (BuildContext context, _SectionData data, _) {
        final List<Product> items = data.items;
        final bool loading = data.loading;
        final bool loadingMore = data.loadingMore;
        final bool hasMore = data.hasMore;
        final List<_SubCatChipData> subCats = data.subCats;
        final String selectedSubCat = data.selectedSubCat;

        if (!loading && items.isEmpty && subCats.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final List<Widget> slivers = <Widget>[
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: widget.title,
              showHeader: widget.showHeader,
              horizontalPadding: widget.horizontalPadding,
              showSubCategoryChips: widget.showSubCategoryChips,
              loading: loading,
              subCats: subCats,
              selectedSubCat: selectedSubCat,
              showAllCategoryChip: widget.showAllCategoryChip,
              leadingSubCategoryChip: widget.leadingSubCategoryChip,
              onSelect: _onSelectSubCat,
            ),
          ),
        ];

        if (loading && items.isEmpty) {
          slivers.add(
            SliverPadding(
              padding: EdgeInsetsDirectional.only(
                start: widget.horizontalPadding,
                end: widget.horizontalPadding,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.crossAxisCount,
                  mainAxisSpacing: widget.mainAxisSpacing,
                  crossAxisSpacing: widget.crossAxisSpacing,
                  childAspectRatio: widget.childAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const _LightSkeletonCard(),
                  childCount: widget.loadingItemCount,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                ),
              ),
            ),
          );
        } else if (items.isNotEmpty) {
          final int providerHash = widget.recentProvider().hashCode;
          slivers.add(
            SliverPadding(
              padding: EdgeInsetsDirectional.only(
                start: widget.horizontalPadding,
                end: widget.horizontalPadding,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.crossAxisCount,
                  mainAxisSpacing: widget.mainAxisSpacing,
                  crossAxisSpacing: widget.crossAxisSpacing,
                  childAspectRatio: widget.childAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext ctx, int index) {
                    final Product product = items[index];
                    final String productId = (product.id ?? '').toString();
                    final String coreTagKey =
                        '${providerHash}_${widget.url}_${productId.isEmpty ? 'p' : productId}_$index';

                    void onTap() {
                      if (productId.isEmpty) return;
                      Navigator.pushNamed(
                        context,
                        RoutePaths.productDetail,
                        arguments: ProductDetailIntentHolder(
                          productId: productId,
                          heroTagImage: '$coreTagKey${PsConst.HERO_TAG__IMAGE}',
                          heroTagTitle: '$coreTagKey${PsConst.HERO_TAG__TITLE}',
                        ),
                      );
                    }

                    return RepaintBoundary(
                      child: widget.cardBuilder(
                        context: ctx,
                        product: product,
                        coreTagKey: coreTagKey,
                        onTap: onTap,
                      ),
                    );
                  },
                  childCount: items.length,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  addSemanticIndexes: false,
                ),
              ),
            ),
          );
        }

        slivers.add(
          SliverToBoxAdapter(
            child: _SectionFooter(
              loading: loading,
              loadingMore: loadingMore,
              hasMore: hasMore,
              hasItems: items.isNotEmpty,
              horizontalPadding: widget.horizontalPadding,
              bottomPadding: widget.bottomPadding,
            ),
          ),
        );

        final Widget combined = SliverMainAxisGroup(slivers: slivers);

        if (widget.sectionWrapper == null) {
          return combined;
        }

        return SliverToBoxAdapter(
          child: widget.sectionWrapper!(
            context,
            CustomScrollView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              slivers: slivers,
            ),
          ),
        );
      },
    );
  }

  void _onSelectSubCat(String id) {
    final ValueChanged<String>? externalHandler = widget.onCategoryChipSelected;
    if (externalHandler != null) {
      externalHandler(id);
      return;
    }

    SearchProvider.of(context, listen: false).selectSectionSubCat(widget.url, id);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.showHeader,
    required this.horizontalPadding,
    required this.showSubCategoryChips,
    required this.loading,
    required this.subCats,
    required this.selectedSubCat,
    required this.showAllCategoryChip,
    required this.leadingSubCategoryChip,
    required this.onSelect,
  });

  final String title;
  final bool showHeader;
  final double horizontalPadding;
  final bool showSubCategoryChips;
  final bool loading;
  final List<_SubCatChipData> subCats;
  final String selectedSubCat;
  final bool showAllCategoryChip;
  final Widget? leadingSubCategoryChip;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: horizontalPadding,
        end: horizontalPadding,
        top: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showHeader) ...<Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: 10),
          ],
          if (showSubCategoryChips) ...<Widget>[
            if (loading && subCats.isEmpty)
              const _StaticChipsSkeleton()
            else if (subCats.isNotEmpty)
              _SubCatChipsBar(
                chips: subCats,
                selectedId: selectedSubCat,
                showAllChip: showAllCategoryChip,
                leadingWidget: leadingSubCategoryChip,
                onSelect: onSelect,
              ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SectionFooter extends StatelessWidget {
  const _SectionFooter({
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.hasItems,
    required this.horizontalPadding,
    required this.bottomPadding,
  });

  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final bool hasItems;
  final double horizontalPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: horizontalPadding,
        end: horizontalPadding,
        bottom: bottomPadding,
      ),
      child: Column(
        children: <Widget>[
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
          if (!loading && !loadingMore && !hasMore && hasItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  'وصلت لآخر المنتجات',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black.withAlpha(100),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubCatChipsBar extends StatelessWidget {
  const _SubCatChipsBar({
    required this.chips,
    required this.selectedId,
    required this.onSelect,
    this.showAllChip = true,
    this.leadingWidget,
  });

  final List<_SubCatChipData> chips;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final bool showAllChip;
  final Widget? leadingWidget;

  @override
  Widget build(BuildContext context) {
    final int leadingCount = leadingWidget == null ? 0 : 1;
    final int allCount = showAllChip ? 1 : 0;

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: chips.length + allCount + leadingCount,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (BuildContext ctx, int i) {
          if (leadingWidget != null && i == 0) return leadingWidget!;

          final int chipIndex = leadingWidget == null ? i : i - 1;
          final String id;
          final String name;

          if (showAllChip && chipIndex == 0) {
            id = '';
            name = 'الكل';
          } else {
            final int realIndex = showAllChip ? chipIndex - 1 : chipIndex;
            final _SubCatChipData chip = chips[realIndex];
            id = chip.id;
            name = chip.name;
          }

          return _SubCatChip(
            label: name,
            selected: selectedId == id,
            onTap: () => onSelect(id),
          );
        },
      ),
    );
  }
}

class _SubCatChip extends StatelessWidget {
  const _SubCatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color primary = selected
        ? const Color(0xFF0A7EA0)
        : Colors.black.withAlpha(12);
    final Color textColor = selected ? Colors.white : Colors.black.withAlpha(180);
    final Color borderColor = selected
        ? const Color(0xFF0A7EA0)
        : Colors.black.withAlpha(20);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  fontSize: 12,
                ),
          ),
        ),
      ),
    );
  }
}

class _StaticChipsSkeleton extends StatelessWidget {
  const _StaticChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        children: const <Widget>[
          _SkeletonPill(width: 72),
          SizedBox(width: 6),
          _SkeletonPill(width: 56),
          SizedBox(width: 6),
          _SkeletonPill(width: 80),
          SizedBox(width: 6),
          _SkeletonPill(width: 64),
        ],
      ),
    );
  }
}

class _SkeletonPill extends StatelessWidget {
  const _SkeletonPill({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(8),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _LightSkeletonCard extends StatelessWidget {
  const _LightSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(7),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(7),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 11,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(8),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 10,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(7),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
