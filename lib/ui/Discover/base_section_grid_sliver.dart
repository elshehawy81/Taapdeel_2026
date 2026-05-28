import 'package:flutter/material.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:provider/provider.dart';

import '../../../constant/ps_constants.dart';
import '../../../constant/route_paths.dart';
import '../Contacts/search_provider.dart';

/// ✅ Card Builder
typedef GridCardBuilder = Widget Function({
required BuildContext context,
required Product product,
required String coreTagKey,
required VoidCallback onTap,
});

// ✅ Helper class للـ Selector — بيتحكم في متى يحصل rebuild
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
          other.loading == loading &&
          other.loadingMore == loadingMore &&
          other.hasMore == hasMore &&
          other.selectedSubCat == selectedSubCat &&
          other.items == items &&
          other.subCats == subCats;

  @override
  int get hashCode =>
      Object.hash(loading, loadingMore, hasMore, items, subCats, selectedSubCat);
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

/// ======================================================
/// ✅ BaseSectionGridSliver (Tabs Mode) — مع Pagination + Sub-Category Chips
/// ======================================================
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
    this.loadMorePageSize = 20,
    this.showSubCategoryChips = true,
    this.leadingSubCategoryChip,
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

  /// ✅ تحكم في إظهار الـ sub-category chips
  final bool showSubCategoryChips;

  /// ✅ Widget اختياري يظهر داخل نفس سطر التصنيفات قبل Chip "الكل".
  /// يستخدم هنا لزر "تعديل" الخاص بتعديل الاهتمامات.
  final Widget? leadingSubCategoryChip;

  @override
  State<BaseSectionGridSliver> createState() => _BaseSectionGridSliverState();
}

class _BaseSectionGridSliverState extends State<BaseSectionGridSliver> {
  bool _requestedMore = false;

  // ✅ FIX: throttle الـ scroll check — لا يتنفذ أكثر من مرة كل 500ms
  DateTime? _lastLoadMoreCheck;

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

    _requestedMore = true;
    sp
        .loadMoreSection(
      filterUrl: widget.url,
      catId: widget.catId(),
      pageSize: widget.loadMorePageSize,
    )
        .whenComplete(() {
      _requestedMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<SearchProvider, _SectionData>(
        selector: (_, sp) {
          final rawSubCats = sp.sectionSubCats(widget.url);
          final chips = rawSubCats
              .map((s) => _SubCatChipData(id: s.id, name: s.name))
              .toList();

          return _SectionData(
            items: sp.sectionFilteredProducts(widget.url),
            loading: sp.sectionLoading(widget.url),
            loadingMore: sp.sectionLoadingMore(widget.url),
            hasMore: sp.sectionHasMore(widget.url),
            subCats: chips,
            selectedSubCat: sp.sectionSelectedSubCat(widget.url),
          );
        },
        shouldRebuild: (prev, next) => prev != next,
        builder: (context, data, _) {
          final List<Product> items = data.items;
          final bool loading = data.loading;
          final bool loadingMore = data.loadingMore;
          final bool hasMore = data.hasMore;
          final List<_SubCatChipData> subCats = data.subCats;
          final String selectedSubCat = data.selectedSubCat;

          if (!loading && items.isEmpty && subCats.isEmpty) {
            return const SizedBox.shrink();
          }

          Widget inner = Padding(
            padding: EdgeInsetsDirectional.only(
              start: widget.horizontalPadding,
              end: widget.horizontalPadding,
              bottom: widget.bottomPadding,
              top: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showHeader) ...[
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // ✅ Chips loading shimmer أو الـ chips الفعلية
                if (widget.showSubCategoryChips) ...[
                  if (loading && subCats.isEmpty)
                    const _ChipsShimmer()
                  else if (subCats.isNotEmpty)
                    _SubCatChipsBar(
                      chips: subCats,
                      selectedId: selectedSubCat,
                      leadingWidget: widget.leadingSubCategoryChip,
                      onSelect: (id) {
                        final sp = SearchProvider.of(context, listen: false);
                        sp.selectSectionSubCat(widget.url, id);
                      },
                    ),
                  const SizedBox(height: 10),
                ],

                // ✅ الـ Grid الأساسي
                if (loading && items.isEmpty)
                  _GridLoading(
                    crossAxisCount: widget.crossAxisCount,
                    mainAxisSpacing: widget.mainAxisSpacing,
                    crossAxisSpacing: widget.crossAxisSpacing,
                    childAspectRatio: widget.childAspectRatio,
                    itemCount: widget.loadingItemCount,
                  )
                else if (items.isEmpty)
                  const SizedBox.shrink()
                else
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        final metrics = notification.metrics;
                        if (metrics.pixels >= metrics.maxScrollExtent * 0.80) {
                          if (!context.mounted) return false;

                          // ✅ FIX: throttle — لا يشتغل أكثر من مرة كل 500ms
                          final now = DateTime.now();
                          if (_lastLoadMoreCheck == null ||
                              now.difference(_lastLoadMoreCheck!) >
                                  const Duration(milliseconds: 500)) {
                            _lastLoadMoreCheck = now;
                            final sp = SearchProvider.of(context, listen: false);
                            _maybeLoadMore(sp, items, loading, loadingMore);
                          }
                        }
                      }
                      return false;
                    },
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length + (loadingMore ? 2 : 0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.crossAxisCount,
                        mainAxisSpacing: widget.mainAxisSpacing,
                        crossAxisSpacing: widget.crossAxisSpacing,
                        childAspectRatio: widget.childAspectRatio,
                      ),
                      itemBuilder: (ctx, index) {
                        if (index >= items.length) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.black.withAlpha(6),
                              border: Border.all(
                                color: Colors.black.withAlpha(12),
                              ),
                            ),
                          );
                        }

                        final Product product = items[index];
                        final String coreTagKey =
                            '${widget.recentProvider().hashCode}_${widget.url}_${(product.id ?? 'p')}_$index';

                        void onTap() {
                          final String productId = (product.id ?? '').toString();
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
                        }

                        return widget.cardBuilder(
                          context: ctx,
                          product: product,
                          coreTagKey: coreTagKey,
                          onTap: onTap,
                        );
                      },
                    ),
                  ),

                // ✅ "تحميل المزيد" indicator
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

                // ✅ "وصلت لآخر المنتجات"
                if (!loading && !loadingMore && !hasMore && items.isNotEmpty)
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

          inner = widget.sectionWrapper?.call(context, inner) ?? inner;
          return inner;
        },
      ),
    );
  }
}

/// ✅ شريط الـ Sub-Category Chips
class _SubCatChipsBar extends StatelessWidget {
  const _SubCatChipsBar({
    required this.chips,
    required this.selectedId,
    required this.onSelect,
    this.leadingWidget,
  });

  final List<_SubCatChipData> chips;
  final String selectedId;
  final void Function(String id) onSelect;
  final Widget? leadingWidget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: chips.length + 1 + (leadingWidget == null ? 0 : 1),
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          if (leadingWidget != null && i == 0) {
            return leadingWidget!;
          }

          final int chipIndex = leadingWidget == null ? i : i - 1;
          final bool isAll = chipIndex == 0;
          final String id = isAll ? '' : chips[chipIndex - 1].id;
          final String name = isAll ? 'الكل' : chips[chipIndex - 1].name;
          final bool selected = selectedId == id;

          return _SubCatChip(
            label: name,
            selected: selected,
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
          duration: const Duration(milliseconds: 180),
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

// ======================================================
// ✅ Shimmer Skeleton Loading
// ======================================================

// ✅ Shimmer للـ chips bar أثناء التحميل
class _ChipsShimmer extends StatefulWidget {
  const _ChipsShimmer();

  @override
  State<_ChipsShimmer> createState() => _ChipsShimmerState();
}

class _ChipsShimmerState extends State<_ChipsShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color base =
    isDark ? Colors.white.withAlpha(14) : Colors.black.withAlpha(8);
    final Color shine =
    isDark ? Colors.white.withAlpha(34) : Colors.black.withAlpha(20);

    return SizedBox(
      height: 34,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          return Row(
            children: [72.0, 56.0, 80.0, 64.0].map((w) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  width: w,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.0, 0.45, 0.55, 1.0],
                      colors: [base, shine, shine, base],
                      transform: _SlideGradientTransform(_anim.value),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _GridLoading extends StatelessWidget {
  const _GridLoading({
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childAspectRatio,
    required this.itemCount,
  });

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (_, __) => const _ShimmerCard(),
    );
  }
}

// ✅ Shimmer card — animation بدون أي dependency خارجية
class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color base = isDark
        ? Colors.white.withAlpha(14)
        : Colors.black.withAlpha(8);
    final Color highlight = isDark
        ? Colors.white.withAlpha(36)
        : Colors.black.withAlpha(22);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.45, 0.55, 1.0],
              colors: [base, highlight, highlight, base],
              transform: _SlideGradientTransform(_anim.value),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المنتج
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.black.withAlpha(6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // سطر العنوان
                Container(
                  height: 11,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isDark
                        ? Colors.white.withAlpha(10)
                        : Colors.black.withAlpha(6),
                  ),
                ),
                const SizedBox(height: 5),
                // سطر السعر (أقصر)
                Container(
                  height: 10,
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isDark
                        ? Colors.white.withAlpha(8)
                        : Colors.black.withAlpha(5),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ✅ Transform بيحرّك الـ gradient أفقياً عشان يعمل إحساس الـ shimmer
class _SlideGradientTransform extends GradientTransform {
  const _SlideGradientTransform(this.slidePercent);
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
