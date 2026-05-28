import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../api/common/ps_status.dart';
import '../../../../constant/ps_constants.dart';
import '../../../../constant/route_paths.dart';

import '../../../../provider/product/added_item_provider.dart';
import '../../../../provider/product/disabled_product_provider.dart';
import '../../../../provider/product/pending_product_provider.dart';
import '../../../../provider/product/rejected_product_provider.dart';
import '../../../../provider/product/sold_out_item_provider.dart';

// ✅ Family provider
import '../../../../provider/product/family_items_provider.dart';

import '../../../../viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import '../../../../viewobject/product.dart';
import '../../../Product/product_widget.dart';
import '../../../common/ps_frame_loading_widget.dart';

import '../share/profile_share_gallery.dart';
import '../widgets/profile_cards_bar.dart' show ProfileTabType;
import '../widgets/profile_header.dart';

class ProfileProductsTab extends StatefulWidget {
  const ProfileProductsTab({
    Key? key,
    required this.type,
  }) : super(key: key);

  final ProfileTabType type;

  @override
  State<ProfileProductsTab> createState() => _ProfileProductsTabState();
}

class _ProfileProductsTabState extends State<ProfileProductsTab>
    with AutomaticKeepAliveClientMixin {
  bool _loadMoreFired = false;

  // ──────────────────────────────────────────────────
  // FIX 1: wantKeepAlive — بس نحافظ على الـ tab لو
  //         البيانات اتحملت فعلاً (مش NOACTION/فاضي).
  //         ده بيمنع stale empty state لما يرجع من
  //         صفحة إضافة منتج.
  // ──────────────────────────────────────────────────
  @override
  bool get wantKeepAlive {
    switch (widget.type) {
      case ProfileTabType.active:
        final s = context.read<AddedItemProvider>().itemList.status;
        return s == PsStatus.SUCCESS || s == PsStatus.PROGRESS_LOADING;

      case ProfileTabType.family:
        final s = context.read<ProfileFamilyItemsProvider>().itemList.status;
        return s == PsStatus.SUCCESS || s == PsStatus.PROGRESS_LOADING;

      case ProfileTabType.pending:
        final s = context.read<PendingProductProvider>().itemList.status;
        return s == PsStatus.SUCCESS || s == PsStatus.PROGRESS_LOADING;

      case ProfileTabType.sold:
        final s = context.read<SoldOutProductProvider>().itemList.status;
        return s == PsStatus.SUCCESS || s == PsStatus.PROGRESS_LOADING;

      case ProfileTabType.rejected:
        final s = context.read<RejectedProductProvider>().itemList.status;
        return s == PsStatus.SUCCESS || s == PsStatus.PROGRESS_LOADING;

      case ProfileTabType.disabled:
        final s = context.read<DisabledProductProvider>().itemList.status;
        return s == PsStatus.SUCCESS || s == PsStatus.PROGRESS_LOADING;

      case ProfileTabType.paid:
      case ProfileTabType.wishlist:
        return true;
    }
  }

  bool _isLoadingStatus(PsStatus s) {
    return s == PsStatus.BLOCK_LOADING ||
        s == PsStatus.PROGRESS_LOADING ||
        s == PsStatus.LOADING;
  }

  void _tryLoadMore() {
    if (!mounted) return;

    switch (widget.type) {
      case ProfileTabType.active:
        final p = context.read<AddedItemProvider>();
        final items = p.itemList.data ?? <Product>[];
        final loading = _isLoadingStatus(p.itemList.status);
        if (items.isNotEmpty && !loading) {
          p.nextItemList(
              p.psValueHolder?.loginUserId, p.addedUserParameterHolder);
        }
        break;

      case ProfileTabType.family:
      // TODO: أضف pagination للـ family لو موجود
        break;

      case ProfileTabType.pending:
        final pending = context.read<PendingProductProvider>();
        final pendingItems = pending.itemList.data ?? <Product>[];
        final pendingLoading = _isLoadingStatus(pending.itemList.status);
        if (pendingItems.isNotEmpty && !pendingLoading) {
          pending.nextProductList(
              pending.psValueHolder?.loginUserId ?? '',
              pending.addedUserParameterHolder);
        }
        break;

      case ProfileTabType.sold:
        final sold = context.read<SoldOutProductProvider>();
        final soldItems = sold.itemList.data ?? <Product>[];
        final soldLoading = _isLoadingStatus(sold.itemList.status);
        if (soldItems.isNotEmpty && !soldLoading) {
          sold.nextProductList(
              sold.psValueHolder?.loginUserId ?? '',
              sold.addedUserParameterHolder);
        }
        break;

      case ProfileTabType.rejected:
        final rejected = context.read<RejectedProductProvider>();
        final rejectedItems = rejected.itemList.data ?? <Product>[];
        final rejectedLoading = _isLoadingStatus(rejected.itemList.status);
        if (rejectedItems.isNotEmpty && !rejectedLoading) {
          rejected.nextProductList(
              rejected.psValueHolder?.loginUserId ?? '',
              rejected.addedUserParameterHolder);
        }
        break;

      case ProfileTabType.disabled:
        final disabled = context.read<DisabledProductProvider>();
        final disabledItems = disabled.itemList.data ?? <Product>[];
        final disabledLoading = _isLoadingStatus(disabled.itemList.status);
        if (disabledItems.isNotEmpty && !disabledLoading) {
          disabled.nextProductList(
              disabled.psValueHolder?.loginUserId ?? '',
              disabled.addedUserParameterHolder);
        }
        break;

      case ProfileTabType.paid:
      case ProfileTabType.wishlist:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.type == ProfileTabType.paid) {
      return PaidAdsSection(
        onPromote: () => Navigator.pushNamed(context, RoutePaths.itemPromote),
      );
    }

    List<Product> items = <Product>[];
    bool isLoading = false;

    // ──────────────────────────────────────────────────
    // FIX 2: _currentStatus يُستخرج من context.watch()
    //         مباشرةً داخل الـ switch — مش في دالة
    //         منفصلة تستخدم context.read().
    //         ده يضمن إن الـ widget يعمل rebuild لما
    //         الـ status يتغيّر من NOACTION → LOADING → SUCCESS.
    // ──────────────────────────────────────────────────
    PsStatus _currentStatus = PsStatus.NOACTION;

    switch (widget.type) {
      case ProfileTabType.active:
        {
          final p = context.watch<AddedItemProvider>();
          items = p.itemList.data ?? <Product>[];
          isLoading = _isLoadingStatus(p.itemList.status);
          _currentStatus = p.itemList.status;
          break;
        }

      case ProfileTabType.family:
        {
          final p = context.watch<ProfileFamilyItemsProvider>();
          items = p.itemList.data ?? <Product>[];
          isLoading = _isLoadingStatus(p.itemList.status);
          _currentStatus = p.itemList.status;
          break;
        }

      case ProfileTabType.pending:
        {
          final p = context.watch<PendingProductProvider>();
          items = p.itemList.data ?? <Product>[];
          isLoading = _isLoadingStatus(p.itemList.status);
          _currentStatus = p.itemList.status;
          break;
        }

      case ProfileTabType.sold:
        {
          final p = context.watch<SoldOutProductProvider>();
          items = p.itemList.data ?? <Product>[];
          isLoading = _isLoadingStatus(p.itemList.status);
          _currentStatus = p.itemList.status;
          break;
        }

      case ProfileTabType.rejected:
        {
          final p = context.watch<RejectedProductProvider>();
          items = p.itemList.data ?? <Product>[];
          isLoading = _isLoadingStatus(p.itemList.status);
          _currentStatus = p.itemList.status;
          break;
        }

      case ProfileTabType.disabled:
        {
          final p = context.watch<DisabledProductProvider>();
          items = p.itemList.data ?? <Product>[];
          isLoading = _isLoadingStatus(p.itemList.status);
          _currentStatus = p.itemList.status;
          break;
        }

      case ProfileTabType.paid:
      case ProfileTabType.wishlist:
        break;
    }

    // ──────────────────────────────────────────────────
    // FIX 2 (cont.): _isNoAction مشتقّة من _currentStatus
    //         المأخوذة من context.watch() — مش context.read()
    // ──────────────────────────────────────────────────
    final bool isNotRequested = _currentStatus == PsStatus.NOACTION;

    if (isLoading && items.isEmpty) {
      return const Center(child: PsFrameUIForLoading());
    }

    if (!isLoading && items.isEmpty && !isNotRequested) {
      return const Center(child: Text('لا يوجد عناصر'));
    }

    // لو NOACTION وفارغ — نعرض placeholder بدون رسالة خطأ
    if (isNotRequested && items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('اضغط للتحميل', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final bool showFooterLoader = isLoading && items.isNotEmpty;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification n) {
        if (n is ScrollUpdateNotification || n is ScrollEndNotification) {
          final metrics = n.metrics;

          if (metrics.maxScrollExtent <= 0) return false;

          final bool nearEnd = metrics.extentAfter < 300;

          if (!nearEnd) {
            _loadMoreFired = false;
            return false;
          }

          if (_loadMoreFired) return false;
          _loadMoreFired = true;

          _tryLoadMore();
        }
        return false;
      },
      child: CustomScrollView(
        cacheExtent: 800,
        slivers: <Widget>[
          if (widget.type == ProfileTabType.active ||
              widget.type == ProfileTabType.family)
            SliverToBoxAdapter(
              child: ProfileShareGalleryBanner(
                source: widget.type == ProfileTabType.family
                    ? ShareGallerySource.familyGallery
                    : ShareGallerySource.myProducts,
                products: items,
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  if (showFooterLoader && index >= items.length) {
                    return const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final Product item = items[index];

                  if (item.adType == PsConst.GOOGLE_AD_TYPE) {
                    return const SizedBox.shrink();
                  }

                  final String tagKey =
                      'profile_${widget.type.name}_${item.id}';

                  return TaapdeelProductCardItem(
                    product: item,
                    coreTagKey: tagKey,
                    variant: TaapdeelProductCardVariant.family,
                    showRelationPanel: true,
                    showConditionChip: false,
                    showRotatingBanner: true,
                    onTap: () {
                      if (item.id == null) return;

                      final holder = ProductDetailIntentHolder(
                        productId: item.id,
                        heroTagImage: '$tagKey${PsConst.HERO_TAG__IMAGE}',
                        heroTagTitle: '$tagKey${PsConst.HERO_TAG__TITLE}',
                      );

                      Navigator.pushNamed(
                        context,
                        RoutePaths.productDetail,
                        arguments: holder,
                      );
                    },
                    relationBackendCode: _getRelationCode(item),
                    onTapFav: null,
                    selectedFav: false,
                  );
                },
                childCount: items.length + (showFooterLoader ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getRelationCode(Product p) {
    try {
      final v = (p.relationCode ?? '').toString().trim();
      return v.isEmpty ? null : v;
    } catch (_) {
      return null;
    }
  }
}
