import 'package:flutter/material.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import 'package:provider/provider.dart';

import '../../../constant/ps_constants.dart';
import '../../../constant/route_paths.dart';
import '../../../viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import '../../../viewobject/product.dart';
import '../../Contacts/search_provider.dart';
import '../../Product/product_widget.dart';

// ✅ Helper class للـ Selector
class _ExploreSectionData {
  const _ExploreSectionData({required this.items, required this.loading});
  final List<Product> items;
  final bool loading;

  @override
  bool operator ==(Object other) =>
      other is _ExploreSectionData &&
          other.loading == loading &&
          other.items == items;

  @override
  int get hashCode => Object.hash(loading, items);
}

class ExploreSectionSliver extends StatelessWidget {
  const ExploreSectionSliver({
    Key? key,
    required this.title,
    required this.url,
    required this.catId,
    required this.recentProvider,
  }) : super(key: key);

  final String title;
  final String url;
  final String Function() catId;
  final RecentProductProvider Function() recentProvider;

  @override
  Widget build(BuildContext context) {
    catId();

    return SliverToBoxAdapter(
      // ✅ FIX: Selector بدل Consumer
      child: Selector<SearchProvider, _ExploreSectionData>(
        selector: (_, sp) => _ExploreSectionData(
          items: sp.sectionProducts(url).cast<Product>(),
          loading: sp.sectionLoading(url),
        ),
        shouldRebuild: (prev, next) => prev != next,
        builder: (context, data, _) {
          final List<Product> items = data.items;
          final bool loading = data.loading;

          if (!loading && items.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: _SilverBackgroundSection(
              title: title,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 12,
                  end: 12,
                  bottom: 12,
                ),
                child: loading && items.isEmpty
                    ? const _ExploreGridLoading()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (ctx, index) {
                    final Product product = items[index];

                    final String coreTagKey =
                        '${recentProvider().hashCode}_${url}_${(product.id ?? 'p')}_$index';

                    return TaapdeelProductCardItem(
                      coreTagKey: coreTagKey,
                      product: product,
                      onTap: () {
                        final String productId = (product.id ?? '').toString();
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
                      },
                      variant: TaapdeelProductCardVariant.deal,
                      showRotatingBanner: true,
                      showRelationPanel: false,
                      showConditionChip: false,
                      onTapFav: null,
                      selectedFav: false,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SilverBackgroundSection extends StatelessWidget {
  const _SilverBackgroundSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const Color silverLight = Color(0xFF2FA4A9);
    const Color silverMid   = Color(0xFF6B63C6);
    const Color silverDark  = Color(0xFF4B5563);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    silverMid.withAlpha(100),
                    silverMid.withAlpha(30),
                    Colors.white.withAlpha(100),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(245),
                      border: Border.all(color: silverMid.withAlpha(160)),
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      size: 18,
                      color: silverDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: silverDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تصفّح المزيد من المنتجات 👇',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: silverDark.withOpacity(0.75),
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ExploreGridLoading extends StatelessWidget {
  const _ExploreGridLoading();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.black.withAlpha(6),
            border: Border.all(color: Colors.black.withAlpha(12)),
          ),
        );
      },
    );
  }
}
