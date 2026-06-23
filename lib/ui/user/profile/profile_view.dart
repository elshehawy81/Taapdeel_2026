import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';

import 'package:taapdeel/provider/gallery/gallery_provider.dart';
import 'package:taapdeel/provider/package_bought/package_bought_transaction_provider.dart';
import 'package:taapdeel/provider/product/added_item_provider.dart';
import 'package:taapdeel/provider/product/disabled_product_provider.dart';
import 'package:taapdeel/provider/product/pending_product_provider.dart';
import 'package:taapdeel/provider/product/rejected_product_provider.dart';
import 'package:taapdeel/provider/product/sold_out_item_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';

import 'package:taapdeel/repository/gallery_repository.dart';
import 'package:taapdeel/repository/package_bought_transaction_history_repository.dart';
import 'package:taapdeel/repository/paid_ad_item_repository.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/repository/sold_out_item_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';

import 'package:taapdeel/ui/common/taapdeel/taapdeel_info_card_shell.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

import 'package:taapdeel/ui/user/profile/tabs/profile_products_tab.dart';
import 'package:taapdeel/ui/user/profile/widgets/profile_header.dart';
import 'package:taapdeel/ui/user/profile/widgets/profile_sweet_messages_section.dart';
import 'package:taapdeel/ui/user/profile/widgets/profile_wishlist_tab.dart';

import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/product.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../api/ps_api_service.dart';
import '../../../provider/product/family_items_provider.dart';
import '../../../provider/product/paid_id_item_provider.dart';
import '../../Foryou/home_provider.dart';

import '../../sweet_phrase/sweet_message_profile_provider.dart';
import '../../sweet_phrase/sweet_message_profile_repository.dart';
import 'widgets/profile_cards_bar.dart';

class _CardsBarData {
  const _CardsBarData({
    required this.wishCount,
    required this.wishLoading,
    required this.familyCount,
    required this.familyLoading,
    required this.familyStatus,
    required this.activeCount,
    required this.activeLoading,
    required this.activeTotalValue,
    required this.pendingCount,
    required this.pendingLoading,
    required this.pendingTotalValue,
    required this.pendingStatus,
    required this.soldCount,
    required this.soldLoading,
    required this.soldTotalValue,
    required this.soldStatus,
    required this.rejectedCount,
    required this.rejectedLoading,
    required this.rejectedTotalValue,
    required this.rejectedStatus,
    required this.disabledCount,
    required this.disabledLoading,
    required this.disabledTotalValue,
    required this.disabledStatus,
    required this.paidCount,
    required this.paidLoading,
    required this.paidTotalValue,
    required this.familyTotalValue,
  });

  final int wishCount;
  final bool wishLoading;
  final int familyCount;
  final bool familyLoading;
  final PsStatus familyStatus;
  final num familyTotalValue;
  final int activeCount;
  final bool activeLoading;
  final num activeTotalValue;
  final int pendingCount;
  final bool pendingLoading;
  final num pendingTotalValue;
  final PsStatus pendingStatus;
  final int soldCount;
  final bool soldLoading;
  final num soldTotalValue;
  final PsStatus soldStatus;
  final int rejectedCount;
  final bool rejectedLoading;
  final num rejectedTotalValue;
  final PsStatus rejectedStatus;
  final int disabledCount;
  final bool disabledLoading;
  final num disabledTotalValue;
  final PsStatus disabledStatus;
  final int paidCount;
  final bool paidLoading;
  final num paidTotalValue;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _CardsBarData &&
        other.wishCount == wishCount &&
        other.wishLoading == wishLoading &&
        other.familyCount == familyCount &&
        other.familyLoading == familyLoading &&
        other.familyStatus == familyStatus &&
        // ✅ FIX 1: نتحقق من familyTotalValue عشان الـ Selector يعمل rebuild
        //           لما تتغير قيمة العائلة بعد التحميل
        other.familyTotalValue == familyTotalValue &&
        other.activeCount == activeCount &&
        other.activeLoading == activeLoading &&
        other.pendingCount == pendingCount &&
        other.pendingLoading == pendingLoading &&
        other.pendingStatus == pendingStatus &&
        other.soldCount == soldCount &&
        other.soldLoading == soldLoading &&
        other.soldStatus == soldStatus &&
        other.rejectedCount == rejectedCount &&
        other.rejectedLoading == rejectedLoading &&
        other.rejectedStatus == rejectedStatus &&
        other.disabledCount == disabledCount &&
        other.disabledLoading == disabledLoading &&
        other.disabledStatus == disabledStatus &&
        other.paidCount == paidCount &&
        other.paidLoading == paidLoading;
  }

  @override
  int get hashCode {
    return wishCount.hashCode ^
    wishLoading.hashCode ^
    familyCount.hashCode ^
    familyLoading.hashCode ^
    familyStatus.hashCode ^
    // ✅ FIX 1 (cont.)
    familyTotalValue.hashCode ^
    activeCount.hashCode ^
    activeLoading.hashCode ^
    pendingCount.hashCode ^
    pendingLoading.hashCode ^
    pendingStatus.hashCode ^
    soldCount.hashCode ^
    soldLoading.hashCode ^
    soldStatus.hashCode ^
    rejectedCount.hashCode ^
    rejectedLoading.hashCode ^
    rejectedStatus.hashCode ^
    disabledCount.hashCode ^
    disabledLoading.hashCode ^
    disabledStatus.hashCode ^
    paidCount.hashCode ^
    paidLoading.hashCode;
  }
}

enum _ProfileMainTab {
  account,
  products,
}

class ProfileView extends StatefulWidget {
  const ProfileView({
    Key? key,
    required this.animationController,
    required this.flag,
    this.userId,
    required this.scaffoldKey,
    required this.callLogoutCallBack,
    this.routeObserver,
  }) : super(key: key);

  final AnimationController animationController;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int? flag;
  final String? userId;
  final Function callLogoutCallBack;
  final RouteObserver<ModalRoute<void>>? routeObserver;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileView>
    with TickerProviderStateMixin
    implements RouteAware {
  UserRepository? userRepository;
  PsValueHolder? psValueHolder;
  UserProvider? provider;

  bool showContactUser = false;
  bool _contactsLoaded = false;

  ProfileTabType? _expandedType;
  _ProfileMainTab _mainTab = _ProfileMainTab.account;
  bool _depsReady = false;

  bool _wishlistPrimed = false;
  int _wishCountCache = 0;

  bool _familyPrimed = false;
  int _familyCountCache = 0;

  late final ScrollController scrollController;
  late final ScrollController _accountScrollController;
  AnimationController? animationControllerForFab;

  final ScrollController _cardsController = ScrollController();
  final GlobalKey<NestedScrollViewState> _nestedKey =
  GlobalKey<NestedScrollViewState>();

  ProductRepository? productRepository;
  PaidAdItemRepository? paidAdItemRepository;
  late GalleryRepository galleryRepo;
  PackageTranscationHistoryRepository? packageTranscationHistoryRepository;
  SoldOutItemRepository? soldOutItemRepository;
  bool _showScrollToTop = false;

  num _activeTotalValueCache = 0;
  num _pendingTotalValueCache = 0;
  num _soldTotalValueCache = 0;
  num _rejectedTotalValueCache = 0;
  num _disabledTotalValueCache = 0;
  num _paidTotalValueCache = 0;
  num _familyTotalValueCache = 0;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    _accountScrollController = ScrollController();

    animationControllerForFab = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1,
    );

    scrollController.addListener(_onMainScroll);
    widget.animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_depsReady) {
      _depsReady = true;

      soldOutItemRepository = context.read<SoldOutItemRepository>();
      userRepository = context.read<UserRepository>();
      galleryRepo = context.read<GalleryRepository>();
      psValueHolder = context.read<PsValueHolder>();
      productRepository = context.read<ProductRepository>();
      paidAdItemRepository = context.read<PaidAdItemRepository>();
      packageTranscationHistoryRepository =
          context.read<PackageTranscationHistoryRepository>();
      provider = UserProvider(repo: userRepository, psValueHolder: psValueHolder);

      if (!_wishlistPrimed) {
        _wishlistPrimed = true;
        final String? uid = _resolveUidForLists();
        if (uid != null && uid.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            HomeProvider.of(context, listen: false).getOwnerWishListProduct(uid);
          });
        }
      }

      final route = ModalRoute.of(context);
      if (route != null) {
        widget.routeObserver?.subscribe(this, route);
      }
    }
  }

  @override
  void dispose() {
    widget.routeObserver?.unsubscribe(this);
    scrollController.removeListener(_onMainScroll);
    scrollController.dispose();
    _accountScrollController.dispose();
    _cardsController.dispose();
    animationControllerForFab?.dispose();
    super.dispose();
  }

  void _setScrollToTopVisible(bool v) {
    if (!mounted) return;
    if (v == _showScrollToTop) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (v == _showScrollToTop) return;
      setState(() => _showScrollToTop = v);
    });
  }

  void _animateScrollControllerToTop(ScrollController controller) {
    if (!controller.hasClients) return;

    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  void _jumpScrollControllerToTop(ScrollController controller) {
    if (!controller.hasClients) return;

    for (final ScrollPosition position
    in List<ScrollPosition>.from(controller.positions)) {
      if (!position.hasPixels) continue;
      position.jumpTo(position.minScrollExtent);
    }
  }

  void _jumpNestedInnerToTop() {
    final ScrollController? inner = _nestedKey.currentState?.innerController;
    if (inner == null || !inner.hasClients) return;

    for (final ScrollPosition position
    in List<ScrollPosition>.from(inner.positions)) {
      if (!position.hasPixels) continue;
      position.jumpTo(position.minScrollExtent);
    }
  }

  void _scrollToTop() {
    if (_mainTab == _ProfileMainTab.account) {
      _animateScrollControllerToTop(_accountScrollController);
    } else {
      _animateScrollControllerToTop(scrollController);

      final inner = _nestedKey.currentState?.innerController;
      if (inner != null && inner.hasClients) {
        inner.animateTo(
          0,
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _jumpToTopNow() {
    if (_mainTab == _ProfileMainTab.account) {
      _jumpScrollControllerToTop(_accountScrollController);
    } else {
      _jumpScrollControllerToTop(scrollController);
      _jumpNestedInnerToTop();
    }

    _setScrollToTopVisible(false);
  }


  void _onMainScroll() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      animationControllerForFab?.reverse();
    } else if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      animationControllerForFab?.forward();
    }
  }

  String? _resolveUidForLists() {
    final PsValueHolder vh = context.read<PsValueHolder>();
    return (vh.loginUserId == null || vh.loginUserId == '')
        ? widget.userId
        : vh.loginUserId;
  }

  num _safeParseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;

    final String cleaned = value
        .toString()
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.\-]'), '');

    return num.tryParse(cleaned) ?? 0;
  }

  num _sumProductsMinPrice(List<Product> products) {
    num total = 0;
    for (final p in products) {
      total += _safeParseNum(p.lowPrice);
    }
    return total;
  }

  num _sumPaidItemsMinPrice(List<dynamic> items) {
    num total = 0;
    for (final item in items) {
      try {
        total += _safeParseNum(item?.lowPrice);
      } catch (_) {
        try {
          total += _safeParseNum(item?.product?.lowPrice);
        } catch (_) {
          total += 0;
        }
      }
    }
    return total;
  }

  void _scrollCardsToMakeFirst(int index) {
    if (!_cardsController.hasClients) return;
    final double w = MediaQuery.of(context).size.width;
    final double cardW = (w - 5) / 3.05;
    const double sep = 10;
    const double leftPad = 16;

    final double raw = leftPad + index * (cardW + sep) - leftPad;
    final double target =
    raw.clamp(0.0, _cardsController.position.maxScrollExtent);

    _cardsController.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleSection(BuildContext ctx, ProfileTabType type, int index) {
    setState(() {
      _expandedType = (_expandedType == type) ? null : type;
    });

    _loadProviderOnDemand(ctx, type);
    _scrollCardsToMakeFirst(index);
  }

  void _changeMainTab(_ProfileMainTab tab) {
    if (_mainTab == tab) return;

    if (tab == _ProfileMainTab.products) {
      _jumpScrollControllerToTop(scrollController);
      _jumpNestedInnerToTop();
    } else {
      _jumpScrollControllerToTop(_accountScrollController);
    }

    setState(() {
      _mainTab = tab;
      if (_mainTab == _ProfileMainTab.products) {
        _expandedType ??= ProfileTabType.active;
      }
    });

  }

  void _loadProviderOnDemand(BuildContext ctx, ProfileTabType type) {
    switch (type) {
      case ProfileTabType.family:
        final String? rawLoginUserId = ctx.read<PsValueHolder>().loginUserId;
        final String loginUserId = (rawLoginUserId ?? '').trim();
        final String profileUserId =
        (widget.userId == null || widget.userId!.trim().isEmpty)
            ? loginUserId
            : widget.userId!.trim();

        // Endpoint get_family_items يحتاج user_id الخاص بالمستخدم الحالي.
        // نستخدم loginUserId أولاً، ولو الصفحة تُفتح ليوزر محدد بدون login fallback للـ profileUserId.
        final String requestUserId = loginUserId.isNotEmpty ? loginUserId : profileUserId;

        if (requestUserId.isNotEmpty) {
          final famProv = ctx.read<ProfileFamilyItemsProvider>();
          if (famProv.itemList.status != PsStatus.BLOCK_LOADING &&
              famProv.itemList.status != PsStatus.PROGRESS_LOADING &&
              famProv.itemList.status != PsStatus.LOADING) {
            famProv.loadFamilyItems(requestUserId, profileUserId);
          }
        }
        break;

      case ProfileTabType.pending:
        final pending = ctx.read<PendingProductProvider>();
        if (pending.itemList.status != PsStatus.BLOCK_LOADING &&
            pending.itemList.status != PsStatus.PROGRESS_LOADING) {
          final String? uid = _resolveUidForLists();
          pending.addedUserParameterHolder.addedUserId = uid;
          pending.addedUserParameterHolder.status = '0';
          pending.loadProductList(uid, pending.addedUserParameterHolder);
        }
        break;

      case ProfileTabType.sold:
        final sold = ctx.read<SoldOutProductProvider>();
        if (sold.itemList.status != PsStatus.BLOCK_LOADING &&
            sold.itemList.status != PsStatus.PROGRESS_LOADING) {
          final String? uid = _resolveUidForLists();
          sold.addedUserParameterHolder.addedUserId = uid;
          sold.addedUserParameterHolder.isSoldOut = '1';
          sold.loadSoldOutProductList(uid, sold.addedUserParameterHolder);
        }
        break;

      case ProfileTabType.rejected:
        final rejected = ctx.read<RejectedProductProvider>();
        if (rejected.itemList.status != PsStatus.BLOCK_LOADING &&
            rejected.itemList.status != PsStatus.PROGRESS_LOADING) {
          final String? uid = _resolveUidForLists();
          rejected.addedUserParameterHolder.addedUserId = uid;
          rejected.addedUserParameterHolder.status = '3';
          rejected.loadProductList(uid, rejected.addedUserParameterHolder);
        }
        break;

      case ProfileTabType.disabled:
        final disabled = ctx.read<DisabledProductProvider>();
        if (disabled.itemList.status != PsStatus.BLOCK_LOADING &&
            disabled.itemList.status != PsStatus.PROGRESS_LOADING) {
          final String? uid = _resolveUidForLists();
          disabled.addedUserParameterHolder.addedUserId = uid;
          disabled.addedUserParameterHolder.status = '2';
          disabled.loadProductList(uid, disabled.addedUserParameterHolder);
        }
        break;

      case ProfileTabType.paid:
        final paid = ctx.read<PaidAdItemProvider>();
        if (paid.paidAdItemList.status != PsStatus.BLOCK_LOADING &&
            paid.paidAdItemList.status != PsStatus.PROGRESS_LOADING) {
          paid.loadPaidAdItemList(_resolveUidForLists());
        }
        break;

      case ProfileTabType.active:
        break;

      case ProfileTabType.wishlist:
        break;
    }
  }

  void _refreshAfterReturn() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final active = context.read<AddedItemProvider>();
      if (active.itemList.status != PsStatus.BLOCK_LOADING &&
          active.itemList.status != PsStatus.PROGRESS_LOADING) {
        final String? uid = _resolveUidForLists();
        active.addedUserParameterHolder.addedUserId = uid;
        active.addedUserParameterHolder.status = '1';
        active.loadItemList(uid, active.addedUserParameterHolder);
      }

      if (_expandedType != null && _expandedType != ProfileTabType.active) {
        _loadProviderOnDemand(context, _expandedType!);
      }

      final String? uid = _resolveUidForLists();
      if (uid != null && uid.isNotEmpty) {
        HomeProvider.of(context, listen: false).getOwnerWishListProduct(uid);
      }
    });
  }

  @override
  void didPopNext() {
    _refreshAfterReturn();
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  void _primeFamilyGalleryIfNeeded(BuildContext ctx) {
    // ✅ FIX 3 (cont.): التحميل بيحصل الآن في create() بتاع MultiProvider مباشرةً
    //                   الدالة دي اتحولت لـ no-op عشان مش يتنادى loadFamilyItems مرتين
    //                   (المرة الأولى في create، والمرة التانية هنا)
    // نسيب _familyPrimed guard عشان لو حد استدعى الدالة من مكان تاني مش يفجر حاجة
    if (_familyPrimed) return;
    _familyPrimed = true;
    // لا نعمل حاجة — الـ provider بيحمل بنفسه
  }

  void _collapseFamilySectionIfEmpty(_CardsBarData data) {
    final bool familyRequested = data.familyStatus != PsStatus.NOACTION;
    final bool familyFinished = familyRequested && !data.familyLoading;

    if (_expandedType != ProfileTabType.family ||
        !familyFinished ||
        data.familyCount > 0) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _expandedType != ProfileTabType.family) return;
      setState(() => _expandedType = ProfileTabType.active);
    });
  }

  Widget _buildProductsCardsBar() {
    _primeFamilyGalleryIfNeeded(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TaapdeelInfoCardShell(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        withBlur: true,
        child: Selector6<
            RejectedProductProvider,
            DisabledProductProvider,
            HomeProvider,
            ProfileFamilyItemsProvider,
            AddedItemProvider,
            PendingProductProvider,
            _CardsBarData>(
          selector: (_, rejectedP, disabledP, homeP, famP, activeP, pendingP) {
            final famList = famP.itemList.data ?? <Product>[];
            // ✅ FIX 2: نحدث الـ cache دايماً (حتى لو فاضي) عشان الـ Selector
            //           يشوف التغيير ويعمل rebuild — مش بس لو isNotEmpty
            _familyTotalValueCache = _sumProductsMinPrice(famList);
            final actList = activeP.itemList.data ?? <Product>[];
            if (actList.isNotEmpty) {
              _activeTotalValueCache = _sumProductsMinPrice(actList);
            }
            final pendList = pendingP.itemList.data ?? <Product>[];
            if (pendList.isNotEmpty) {
              _pendingTotalValueCache = _sumProductsMinPrice(pendList);
            }
            final rejectedList = rejectedP.itemList.data ?? <Product>[];
            if (rejectedList.isNotEmpty) {
              _rejectedTotalValueCache = _sumProductsMinPrice(rejectedList);
            }
            final disabledList = disabledP.itemList.data ?? <Product>[];
            if (disabledList.isNotEmpty) {
              _disabledTotalValueCache = _sumProductsMinPrice(disabledList);
            }

            return _CardsBarData(
              wishCount: homeP.wishListProducts.length,
              wishLoading: homeP.wishLoading,
              familyCount: famList.length,
              familyLoading: famP.itemList.status == PsStatus.BLOCK_LOADING ||
                  famP.itemList.status == PsStatus.PROGRESS_LOADING ||
                  famP.itemList.status == PsStatus.LOADING,
              familyStatus: famP.itemList.status,
              familyTotalValue: _familyTotalValueCache,
              activeCount: actList.length,
              activeLoading: activeP.itemList.status == PsStatus.BLOCK_LOADING,
              activeTotalValue: _activeTotalValueCache,
              pendingCount: pendList.length,
              pendingLoading: pendingP.itemList.status == PsStatus.BLOCK_LOADING,
              pendingTotalValue: _pendingTotalValueCache,
              pendingStatus: pendingP.itemList.status,
              rejectedCount: rejectedList.length,
              rejectedLoading: rejectedP.itemList.status == PsStatus.BLOCK_LOADING,
              rejectedTotalValue: _rejectedTotalValueCache,
              rejectedStatus: rejectedP.itemList.status,
              disabledCount: disabledList.length,
              disabledLoading: disabledP.itemList.status == PsStatus.BLOCK_LOADING,
              disabledTotalValue: _disabledTotalValueCache,
              disabledStatus: disabledP.itemList.status,
              soldCount: 0,
              soldLoading: false,
              soldTotalValue: 0,
              soldStatus: PsStatus.NOACTION,
              paidCount: 0,
              paidLoading: false,
              paidTotalValue: 0,
            );
          },
          builder: (_, partial, __) =>
              Selector2<PaidAdItemProvider, SoldOutProductProvider,
                  _CardsBarData>(
                selector: (_, paidP, soldP) {
                  final paidList = paidP.paidAdItemList.data ?? <dynamic>[];
                  if (paidList.isNotEmpty) {
                    _paidTotalValueCache = _sumPaidItemsMinPrice(paidList);
                  }
                  final soldList = soldP.itemList.data ?? <Product>[];
                  if (soldList.isNotEmpty) {
                    _soldTotalValueCache = _sumProductsMinPrice(soldList);
                  }

                  return _CardsBarData(
                    wishCount: partial.wishCount,
                    wishLoading: partial.wishLoading,
                    familyCount: partial.familyCount,
                    familyLoading: partial.familyLoading,
                    familyStatus: partial.familyStatus,
                    familyTotalValue: partial.familyTotalValue,
                    activeCount: partial.activeCount,
                    activeLoading: partial.activeLoading,
                    activeTotalValue: partial.activeTotalValue,
                    pendingCount: partial.pendingCount,
                    pendingLoading: partial.pendingLoading,
                    pendingTotalValue: partial.pendingTotalValue,
                    pendingStatus: partial.pendingStatus,
                    rejectedCount: partial.rejectedCount,
                    rejectedLoading: partial.rejectedLoading,
                    rejectedTotalValue: partial.rejectedTotalValue,
                    rejectedStatus: partial.rejectedStatus,
                    disabledCount: partial.disabledCount,
                    disabledLoading: partial.disabledLoading,
                    disabledTotalValue: partial.disabledTotalValue,
                    disabledStatus: partial.disabledStatus,
                    soldCount: soldList.length,
                    soldLoading: soldP.itemList.status == PsStatus.BLOCK_LOADING,
                    soldTotalValue: _soldTotalValueCache,
                    soldStatus: soldP.itemList.status,
                    paidCount: paidList.length,
                    paidLoading: paidP.paidAdItemList.status == PsStatus.BLOCK_LOADING,
                    paidTotalValue: _paidTotalValueCache,
                  );
                },
                builder: (context, data, _) {
                  _collapseFamilySectionIfEmpty(data);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 18,
                              decoration: BoxDecoration(
                                color: PsColors.activeColor,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تفاصيل منتجاتك',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black.withOpacity(0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ProfileHorizontalCardsBar(
                        expandedType: _expandedType,
                        controller: _cardsController,
                        onTap: (type, index) => _toggleSection(context, type, index),
                        wishCount: data.wishCount,
                        wishLoading: data.wishLoading,
                        wishTotalValue: 0,
                        familyCount: data.familyCount,
                        familyLoading: data.familyLoading,
                        familyCountReady: data.familyStatus != PsStatus.NOACTION,
                        familyTotalValue: data.familyTotalValue,
                        activeCount: data.activeCount,
                        activeLoading: data.activeLoading,
                        activeTotalValue: data.activeTotalValue,
                        pendingCount: data.pendingCount,
                        pendingLoading: data.pendingLoading,
                        pendingTotalValue: data.pendingTotalValue,
                        pendingCountReady: data.pendingStatus != PsStatus.NOACTION,
                        paidCount: data.paidCount,
                        paidLoading: data.paidLoading,
                        paidTotalValue: data.paidTotalValue,
                        soldCount: data.soldCount,
                        soldLoading: data.soldLoading,
                        soldTotalValue: data.soldTotalValue,
                        soldCountReady: data.soldStatus != PsStatus.NOACTION,
                        rejectedCount: data.rejectedCount,
                        rejectedLoading: data.rejectedLoading,
                        rejectedTotalValue: data.rejectedTotalValue,
                        rejectedCountReady: data.rejectedStatus != PsStatus.NOACTION,
                        disabledCount: data.disabledCount,
                        disabledLoading: data.disabledLoading,
                        disabledTotalValue: data.disabledTotalValue,
                        disabledCountReady: data.disabledStatus != PsStatus.NOACTION,
                      ),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildScrollToTopButton() {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: _showScrollToTop ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !_showScrollToTop,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _scrollToTop,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withOpacity(0.85),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: PsColors.bottomNav,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTabView() {
    return CustomScrollView(
      key: const PageStorageKey<String>('profile_account_scroll_view'),
      controller: _accountScrollController,
      physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _ProfileMainTabsBar(
            selectedTab: _mainTab,
            onChanged: _changeMainTab,
          ),
        ),
        Consumer<GalleryProvider>(
          builder: (context, galleryProvider, _) {
            return ProfileDetailWidget(
              animationController: widget.animationController,
              animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: widget.animationController,
                  curve: const Interval(
                    (1 / 4) * 2,
                    1.0,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
              ),
              userId: widget.userId,
              callLogoutCallBack: widget.callLogoutCallBack,
              headerTitle: Utils.getString(context, 'profile__listing'),
              status: '1',
            );
          },
        ),
        SliverToBoxAdapter(
          child: ProfileSweetMessagesSection(
            psValueHolder: psValueHolder!,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 105)),
      ],
    );
  }

  Widget _buildProductsTabView() {
    return NestedScrollView(
      key: _nestedKey,
      controller: scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverToBoxAdapter(
            child: _ProfileMainTabsBar(
              selectedTab: _mainTab,
              onChanged: _changeMainTab,
            ),
          ),
          SliverToBoxAdapter(child: _buildProductsCardsBar()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ];
      },
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey<ProfileTabType?>(_expandedType),
          child: _ProfileExpandedSectionBody(
            type: _expandedType,
            userId: widget.userId,
          ),
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      _setScrollToTopVisible(notification.metrics.pixels > 260);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_depsReady || provider == null || psValueHolder == null) {
      return const SizedBox.shrink();
    }

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ProfileFamilyItemsProvider>(
          // ✅ FIX 3: lazy=false + نبدأ التحميل في create مباشرةً
          //           بدل _primeFamilyGalleryIfNeeded اللي بتستخدم addPostFrameCallback
          //           وبتخلي الـ Selector يبني أول مرة بـ NOACTION → familyCountReady=false → التاب مخفي
          lazy: false,
          create: (_) {
            final ProfileFamilyItemsProvider p = ProfileFamilyItemsProvider(
              repo: productRepository!,
              psValueHolder: psValueHolder!,
              limit: psValueHolder!.defaultLoadingLimit!,
            );
            final String rawLoginUserId = (psValueHolder!.loginUserId ?? '').trim();
            final String profileUserId =
            (widget.userId == null || widget.userId!.trim().isEmpty)
                ? rawLoginUserId
                : widget.userId!.trim();
            final String requestUserId =
            rawLoginUserId.isNotEmpty ? rawLoginUserId : profileUserId;
            if (requestUserId.isNotEmpty) {
              // نطلب البيانات مباشرةً بدون postFrameCallback
              Future.microtask(() {
                if (p.itemList.status == PsStatus.NOACTION) {
                  p.loadFamilyItems(requestUserId, profileUserId);
                }
              });
            }
            return p;
          },
        ),
        ChangeNotifierProvider<DisabledProductProvider>(
          lazy: false,
          create: (_) {
            final DisabledProductProvider p = DisabledProductProvider(
              repo: productRepository,
              psValueHolder: psValueHolder,
              limit: psValueHolder!.defaultLoadingLimit!,
            );
            p.addedUserParameterHolder.mile = psValueHolder!.mile;
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (p.itemList.status == PsStatus.NOACTION) {
                final String? uid = _resolveUidForLists();
                p.addedUserParameterHolder.addedUserId = uid;
                p.addedUserParameterHolder.status = '2';
                p.loadProductList(uid, p.addedUserParameterHolder);
              }
            });
            return p;
          },
        ),
        ChangeNotifierProvider<PaidAdItemProvider>(
          lazy: true,
          create: (_) => PaidAdItemProvider(
            repo: paidAdItemRepository,
            psValueHolder: psValueHolder,
            limit: psValueHolder!.defaultLoadingLimit!,
          ),
        ),
        ChangeNotifierProvider<PackageTranscationHistoryProvider>(
          lazy: true,
          create: (_) => PackageTranscationHistoryProvider(
            repo: packageTranscationHistoryRepository,
            psValueHolder: psValueHolder,
          ),
        ),
        ChangeNotifierProvider<AddedItemProvider>(
          lazy: false,
          create: (_) {
            final AddedItemProvider p = AddedItemProvider(
              repo: productRepository,
              psValueHolder: psValueHolder,
              limit: psValueHolder!.defaultLoadingLimit!,
            );
            p.addedUserParameterHolder.mile = psValueHolder!.mile;
            final String? uid = _resolveUidForLists();
            p.addedUserParameterHolder.addedUserId = uid;
            p.addedUserParameterHolder.status = '1';
            p.loadItemList(uid, p.addedUserParameterHolder);
            return p;
          },
        ),
        Provider<SweetMessageProfileRepository>(
          create: (ctx) => SweetMessageProfileRepository(
            psApiService: ctx.read<PsApiService>(),
          ),
        ),
        ChangeNotifierProvider<SweetMessageProfileProvider>(
          lazy: true,
          create: (ctx) => SweetMessageProfileProvider(
            repository: ctx.read<SweetMessageProfileRepository>(),
          ),
        ),
        ChangeNotifierProvider<GalleryProvider>(
          lazy: true,
          create: (_) => GalleryProvider(repo: galleryRepo),
        ),
        ChangeNotifierProvider<PendingProductProvider>(
          lazy: false,
          create: (_) {
            final PendingProductProvider p = PendingProductProvider(
              repo: productRepository,
              psValueHolder: psValueHolder,
              limit: psValueHolder!.defaultLoadingLimit!,
            );
            p.addedUserParameterHolder.mile = psValueHolder!.mile;
            final String? uid = _resolveUidForLists();
            p.addedUserParameterHolder.addedUserId = uid;
            p.addedUserParameterHolder.status = '0';
            p.loadProductList(uid, p.addedUserParameterHolder);
            return p;
          },
        ),
        ChangeNotifierProvider<SoldOutProductProvider>(
          lazy: false,
          create: (_) {
            final SoldOutProductProvider p = SoldOutProductProvider(
              repo: soldOutItemRepository,
              psValueHolder: psValueHolder,
              limit: psValueHolder!.defaultLoadingLimit!,
            );
            Future.delayed(const Duration(milliseconds: 600), () {
              if (p.itemList.status == PsStatus.NOACTION) {
                final String? uid = _resolveUidForLists();
                p.addedUserParameterHolder.addedUserId = uid;
                p.addedUserParameterHolder.isSoldOut = '1';
                p.loadSoldOutProductList(uid, p.addedUserParameterHolder);
              }
            });
            return p;
          },
        ),
        ChangeNotifierProvider<RejectedProductProvider>(
          lazy: false,
          create: (_) {
            final RejectedProductProvider p = RejectedProductProvider(
              repo: productRepository,
              psValueHolder: psValueHolder,
              limit: psValueHolder!.defaultLoadingLimit!,
            );
            p.addedUserParameterHolder.mile = psValueHolder!.mile;
            Future.delayed(const Duration(milliseconds: 900), () {
              if (p.itemList.status == PsStatus.NOACTION) {
                final String? uid = _resolveUidForLists();
                p.addedUserParameterHolder.addedUserId = uid;
                p.addedUserParameterHolder.status = '3';
                p.loadProductList(uid, p.addedUserParameterHolder);
              }
            });
            return p;
          },
        ),
        ChangeNotifierProvider<UserProvider>.value(value: provider!),
      ],
      builder: (context, child) {
        _expandedType ??= ProfileTabType.active;

        return TaapdeelScaffold(
          appBar: null,
          padding: EdgeInsets.zero,
          safeTop: true,
          safeBottom: true,
          body: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: _mainTab == _ProfileMainTab.account
                    ? _buildAccountTabView()
                    : _buildProductsTabView(),
              ),
              PositionedDirectional(
                start: 14,
                bottom: 18,
                child: _buildScrollToTopButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileMainTabsBar extends StatelessWidget {
  const _ProfileMainTabsBar({
    required this.selectedTab,
    required this.onChanged,
  });

  final _ProfileMainTab selectedTab;
  final ValueChanged<_ProfileMainTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TaapdeelInfoCardShell(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(6),
          withBlur: true,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _ProfileMainTabButton(
                  title: 'حسابي',
                  subtitle: 'بياناتك ورسائلك',
                  icon: Icons.account_circle_rounded,
                  selected: selectedTab == _ProfileMainTab.account,
                  onTap: () => onChanged(_ProfileMainTab.account),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileMainTabButton(
                  title: 'منتجاتي',
                  subtitle: 'كل منتجاتك وحالاتها',
                  icon: Icons.inventory_2_rounded,
                  selected: selectedTab == _ProfileMainTab.products,
                  onTap: () => onChanged(_ProfileMainTab.products),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMainTabButton extends StatelessWidget {
  const _ProfileMainTabButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        (PsColors.activeColor as Color?) ?? const Color(0xFF24A9C4);
    final Color bottomNavColor =
        (PsColors.bottomNav as Color?) ?? const Color(0xFF073B5A);
    final Color inactiveText = Colors.black.withOpacity(0.62);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: selected
            ? LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: <Color>[
            bottomNavColor,
            activeColor,
          ],
        )
            : const LinearGradient(
          colors: <Color>[
            Colors.white,
            Color(0xFFF4FBFE),
          ],
        ),
        border: Border.all(
          color:
          selected ? Colors.white.withOpacity(0.9) : const Color(0xFFD7EEF5),
          width: selected ? 1.2 : 1,
        ),
        boxShadow: selected
            ? <BoxShadow>[
          BoxShadow(
            color: activeColor.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ]
            : const <BoxShadow>[],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? Colors.white.withOpacity(0.18)
                        : activeColor.withOpacity(0.10),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? Colors.white : activeColor,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF102E45),
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected
                              ? Colors.white.withOpacity(0.86)
                              : inactiveText,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileExpandedSectionBody extends StatelessWidget {
  const _ProfileExpandedSectionBody({
    required this.type,
    required this.userId,
  });

  final ProfileTabType? type;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    if (type == null) {
      return const Center(child: Text('اختار قسم علشان يعرض العناصر'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(
        key: ValueKey(type),
        child: _buildSection(context, type!),
      ),
    );
  }

  Widget _buildSection(BuildContext context, ProfileTabType t) {
    switch (t) {
      case ProfileTabType.wishlist:
        return ProfileWishlistTab(userId: userId);
      case ProfileTabType.family:
        return ProfileProductsTab(type: ProfileTabType.family);
      case ProfileTabType.active:
      case ProfileTabType.pending:
      case ProfileTabType.paid:
      case ProfileTabType.sold:
      case ProfileTabType.rejected:
      case ProfileTabType.disabled:
        return ProfileProductsTab(type: t);
    }
  }
}

class GradientQuickActionCard extends StatelessWidget {
  const GradientQuickActionCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.badge,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 85,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 34, color: Colors.white),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (badge != null && badge! > 0)
            PositionedDirectional(
              top: -6,
              end: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 24),
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB020),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.4),
                ),
                child: Text(
                  badge! > 99 ? '99+' : '${badge!}',
                  style: const TextStyle(
                    color: Color(0xFF231307),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileQuickActionsBar extends StatefulWidget {
  const ProfileQuickActionsBar({
    Key? key,
    required this.wishCount,
    required this.onAddProduct,
    required this.onAddWish,
    required this.onShareProfile,
    required this.onFollowFriends,
    required this.onSwapRequests,
    required this.onEditPrefCategories,
    required this.onMessages,
    this.swapCount,
    this.msgCount,
  }) : super(key: key);

  final int wishCount;
  final int? swapCount;
  final int? msgCount;
  final VoidCallback onAddProduct;
  final VoidCallback onAddWish;
  final VoidCallback onShareProfile;
  final VoidCallback onFollowFriends;
  final VoidCallback onSwapRequests;
  final VoidCallback onEditPrefCategories;
  final VoidCallback onMessages;

  @override
  State<ProfileQuickActionsBar> createState() => _ProfileQuickActionsBarState();
}

class _ProfileQuickActionsBarState extends State<ProfileQuickActionsBar> {
  late final PageController _pc;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    final page1 = <Widget>[
      Expanded(
        child: GradientQuickActionCard(
          icon: Icons.star_rounded,
          label: 'تصنيفات مفضلة',
          gradient: const LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
          onTap: widget.onEditPrefCategories,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: GradientQuickActionCard(
          icon: Icons.add_shopping_cart,
          label: '+ منتجات تتمناها',
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6A6A), Color(0xFFFF8E8E)],
          ),
          onTap: widget.onAddWish,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: GradientQuickActionCard(
          icon: Icons.ios_share_rounded,
          label: 'مشاركة البروفايل',
          gradient: const LinearGradient(
            colors: [Color(0xFF6A5BFF), Color(0xFF8F84FF)],
          ),
          onTap: widget.onShareProfile,
        ),
      ),
    ];

    final page2 = <Widget>[
      Expanded(
        child: GradientQuickActionCard(
          icon: Icons.group_add_rounded,
          label: 'متابعة الأصدقاء',
          gradient: const LinearGradient(
            colors: [Color(0xFF00C6A7), Color(0xFF4FE3C1)],
          ),
          onTap: widget.onFollowFriends,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: GradientQuickActionCard(
          icon: Icons.swap_horiz_rounded,
          label: 'طلبات التبديل',
          badge: widget.swapCount,
          gradient: const LinearGradient(
            colors: [Color(0xFF7C8DB5), Color(0xFF9FB0D8)],
          ),
          onTap: widget.onSwapRequests,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: GradientQuickActionCard(
          icon: Icons.mail_outline_rounded,
          label: 'الرسائل',
          badge: widget.msgCount,
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
          onTap: widget.onMessages,
        ),
      ),
    ];

    final pages = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: page1),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: page2),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEAF4FF),
              const Color(0xFFD7ECFF).withOpacity(0.85),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 90,
              child: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: PageView(
                  controller: _pc,
                  reverse: isRtl,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: pages,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _DotsIndicator(count: pages.length, index: _page),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 8,
          height: 6,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2E5B90) : Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
