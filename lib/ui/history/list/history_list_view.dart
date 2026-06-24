import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/history/history_provider.dart';
import 'package:taapdeel/repository/history_repsitory.dart';
import 'package:taapdeel/ui/history/item/history_list_item.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/product.dart';

class HistoryListView extends StatefulWidget {
  const HistoryListView({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  final AnimationController? animationController;

  @override
  _HistoryListViewState createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView>
    with SingleTickerProviderStateMixin {
  HistoryRepository? historyRepo;

  @override
  Widget build(BuildContext context) {
    historyRepo = Provider.of<HistoryRepository>(context);

    return ChangeNotifierProvider<HistoryProvider>(
      lazy: false,
      create: (BuildContext context) {
        final HistoryProvider provider = HistoryProvider(
          repo: historyRepo,
        );
        provider.loadHistoryList();
        return provider;
      },
      child: Consumer<HistoryProvider>(
        builder: (
            BuildContext context,
            HistoryProvider provider,
            Widget? child,
            ) {
          final List<Product>? rawHistoryItems = provider.historyList.data;

          if (rawHistoryItems == null) {
            return const _HistoryLoadingView();
          }

          final List<Product> historyItems =
          _latestUniqueHistoryItems(rawHistoryItems);

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFFEAF7F1),
                    Color(0xFFF8FBFA),
                    Colors.white,
                  ],
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () {
                  return provider.resetHistoryList();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: _HistoryHeaderCard(
                        totalCount: historyItems.length,
                      ),
                    ),
                    if (historyItems.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _HistoryEmptyState(),
                      )
                    else ...<Widget>[
                      const SliverToBoxAdapter(
                        child: _HistorySectionTitle(),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          PsDimens.space16,
                          0,
                          PsDimens.space16,
                          PsDimens.space20,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: PsDimens.space12,
                            crossAxisSpacing: PsDimens.space12,
                            childAspectRatio: 0.68,
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                              final Product product = historyItems[index];
                              final int count = historyItems.length;

                              final String safeProductId =
                                  product.id ?? 'history_product_$index';

                              final String heroTagImage =
                                  'history_${provider.hashCode}_${index}_${safeProductId}_${PsConst.HERO_TAG__IMAGE}';

                              final String heroTagTitle =
                                  'history_${provider.hashCode}_${index}_${safeProductId}_${PsConst.HERO_TAG__TITLE}';

                              return HistoryListItem(
                                animationController:
                                widget.animationController,
                                animation: _buildItemAnimation(
                                  index: index,
                                  count: count,
                                ),
                                history: product,
                                heroTagImage: heroTagImage,
                                onTap: () {
                                  final ProductDetailIntentHolder holder =
                                  ProductDetailIntentHolder(
                                    productId: product.id,
                                    heroTagImage: heroTagImage,
                                    heroTagTitle: heroTagTitle,
                                  );

                                  Navigator.pushNamed(
                                    context,
                                    RoutePaths.productDetail,
                                    arguments: holder,
                                  );
                                },
                              );
                            },
                            childCount: historyItems.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Animation<double> _buildItemAnimation({
    required int index,
    required int count,
  }) {
    if (widget.animationController == null) {
      return const AlwaysStoppedAnimation<double>(1.0);
    }

    final double start = count <= 1 ? 0.0 : (index / count).clamp(0.0, 0.9);

    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController!,
        curve: Interval(
          start,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
  }

  List<Product> _latestUniqueHistoryItems(List<Product> items) {
    final Set<String> seenIds = <String>{};
    final List<Product> result = <Product>[];

    for (final Product product in items.reversed) {
      final String key = product.id ?? product.hashCode.toString();

      if (seenIds.add(key)) {
        result.add(product);
      }
    }

    return result;
  }
}

class _HistoryHeaderCard extends StatelessWidget {
  const _HistoryHeaderCard({
    required this.totalCount,
  });

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        PsDimens.space16,
        PsDimens.space16,
        PsDimens.space16,
        PsDimens.space12,
      ),
      padding: const EdgeInsets.all(PsDimens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF0E8F65).withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Color(0xFF0E8F65),
              size: 30,
            ),
          ),
          const SizedBox(width: PsDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'سجل تصفح المنتجات',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15221D),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  totalCount == 0
                      ? 'المنتجات التي تفتحها ستظهر هنا'
                      : 'منتجات شاهدتها مؤخرًا في شكل صور كبيرة',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PsDimens.space10),
          _HistoryCounterBadge(totalCount: totalCount),
        ],
      ),
    );
  }
}

class _HistoryCounterBadge extends StatelessWidget {
  const _HistoryCounterBadge({
    required this.totalCount,
  });

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0E8F65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            totalCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'منتج',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySectionTitle extends StatelessWidget {
  const _HistorySectionTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PsDimens.space16,
        PsDimens.space4,
        PsDimens.space16,
        PsDimens.space10,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 5,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF0E8F65),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'أحدث المشاهدات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15221D),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PsDimens.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFF0E8F65).withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              color: Color(0xFF0E8F65),
              size: 48,
            ),
          ),
          const SizedBox(height: PsDimens.space16),
          const Text(
            'لا يوجد سجل تصفح حتى الآن',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15221D),
            ),
          ),
          const SizedBox(height: PsDimens.space8),
          Text(
            'افتح تفاصيل أي منتج، وبعدها سيظهر هنا لتقدر ترجع له بسهولة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black.withOpacity(0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryLoadingView extends StatelessWidget {
  const _HistoryLoadingView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFFEAF7F1),
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0E8F65),
          ),
        ),
      ),
    );
  }
}