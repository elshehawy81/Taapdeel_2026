import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/about_us/about_us_provider.dart';
import 'package:taapdeel/provider/app_info/app_info_provider.dart';
import 'package:taapdeel/provider/gallery/gallery_provider.dart';
import 'package:taapdeel/provider/history/history_provider.dart';
import 'package:taapdeel/provider/product/favourite_item_provider.dart';
import 'package:taapdeel/provider/product/mark_sold_out_item_provider.dart';
import 'package:taapdeel/provider/product/product_provider.dart';
import 'package:taapdeel/provider/product/similar_items_by_tags_provider.dart';
import 'package:taapdeel/provider/product/touch_count_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/about_us_repository.dart';
import 'package:taapdeel/repository/app_info_repository.dart';
import 'package:taapdeel/repository/gallery_repository.dart';
import 'package:taapdeel/repository/history_repsitory.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/base/ps_widget_with_multi_provider.dart';
import 'package:taapdeel/ui/common/ps_back_button_with_circle_bg_widget.dart';
import 'package:taapdeel/ui/item/detail/product_detail_gallery_view.dart';
import 'package:taapdeel/ui/item/detail/widgets/action_buttons.dart';
import 'package:taapdeel/ui/item/detail/widgets/product_header.dart';
import 'package:taapdeel/ui/item/detail/widgets/seller_info_tile_view.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/default_photo.dart';
import 'package:taapdeel/viewobject/holder/mark_sold_out_item_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/touch_count_parameter_holder.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../api/ps_api_service.dart';
import '../../../provider/subcategory/owner_subcat_subscribe_provider.dart';
import '../../../repository/owner_subcat_subscribe_repository.dart';
import '../../../viewobject/product.dart';

// ✅ NEW: Taapdeel Scaffold
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

import '../../Product/product_widget.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({
    required this.productId,
    required this.heroTagImage,
    required this.heroTagTitle,
    this.adminReviewMode = false,
  });

  final String? productId;
  final String? heroTagImage;
  final String? heroTagTitle;
  final bool adminReviewMode;

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetailView>
    with SingleTickerProviderStateMixin {
  ProductRepository? productRepo;
  HistoryRepository? historyRepo;
  HistoryProvider? historyProvider;
  ItemDetailProvider? itemDetailProvider;
  TouchCountProvider? touchCountProvider;
  AppInfoProvider? appInfoProvider;
  GalleryProvider? galleryProvider;
  late GalleryRepository galleryRepository;
  AppInfoRepository? appInfoRepository;
  PsValueHolder? psValueHolder;
  AnimationController? animationController;
  AboutUsRepository? aboutUsRepo;
  AboutUsProvider? aboutUsProvider;
  MarkSoldOutItemProvider? markSoldOutItemProvider;
  MarkSoldOutItemParameterHolder? markSoldOutItemHolder;
  UserProvider? userProvider;
  UserRepository? userRepo;
  FavouriteItemProvider? favouriteProvider;
  bool isReadyToShowAppBarIcons = false;
  bool isAddedToHistory = false;
  bool isHaveVideo = false;
  DefaultPhoto? currentDefaultPhoto;
  late final ScrollController _swapChipsController;

  // ✅ Similar-by-tags load guard
  String? _loadedSimilarForId;
  bool _similarQueued = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _swapChipsController = ScrollController();
  }

  @override
  void dispose() {
    _swapChipsController.dispose();
    super.dispose();
  }

  Widget _buildPaidStatusBadge(ItemDetailProvider provider) {
    final Product p = provider.itemDetail.data!;
    final bool isMine = p.addedUserId == provider.psValueHolder!.loginUserId;

    if (!isMine) {
      return const SizedBox.shrink();
    }

    if (p.paidStatus == PsConst.ADSPROGRESS) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: PsColors.paidAdsColor,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_in_progress'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    if (p.paidStatus == PsConst.ADS_REJECT) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: Colors.red,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_in_rejected'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    if (p.paidStatus == PsConst.ADS_WAITING_FOR_APPROVAL) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: Colors.yellow,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_waiting'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    if (p.paidStatus == PsConst.ADSFINISHED) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: PsColors.black,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_in_completed'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    if (p.paidStatus == PsConst.ADSNOTYETSTART) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: Colors.yellow,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_is_not_yet_start'),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _maybeLoadSimilarOnce({
    required BuildContext context,
    required String currentItemId,
  }) {
    if (currentItemId.trim().isEmpty) {
      return;
    }

    if (_loadedSimilarForId == currentItemId) {
      return;
    }

    if (_similarQueued) {
      return;
    }

    _similarQueued = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final SimilarItemsByTagsProvider similarProvider =
      context.read<SimilarItemsByTagsProvider>();
      final String? loginUserId = Utils.checkUserLoginId(psValueHolder!);

      similarProvider.loadSimilarItems(
        currentItemId,
        loginUserId,
      );

      _loadedSimilarForId = currentItemId;
      _similarQueued = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isReadyToShowAppBarIcons) {
      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) {
          return;
        }
        setState(() {
          isReadyToShowAppBarIcons = true;
        });
      });
    }

    psValueHolder = Provider.of<PsValueHolder>(context);

    historyRepo = Provider.of<HistoryRepository>(context);
    productRepo = Provider.of<ProductRepository>(context);
    aboutUsRepo = Provider.of<AboutUsRepository>(context);
    userRepo = Provider.of<UserRepository>(context);
    appInfoRepository = Provider.of<AppInfoRepository>(context);
    galleryRepository = Provider.of<GalleryRepository>(context);

    markSoldOutItemHolder =
        MarkSoldOutItemParameterHolder().markSoldOutItemHolder();
    markSoldOutItemHolder!.itemId = widget.productId;

    return PsWidgetWithMultiProvider(
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ItemDetailProvider?>(
            lazy: false,
            create: (BuildContext context) {
              itemDetailProvider = ItemDetailProvider(
                repo: productRepo,
                psValueHolder: psValueHolder,
              );

              final String? loginUserId = Utils.checkUserLoginId(psValueHolder!);
              itemDetailProvider!.loadProduct(widget.productId, loginUserId);

              return itemDetailProvider;
            },
          ),
          ChangeNotifierProvider<HistoryProvider?>(
            lazy: false,
            create: (BuildContext context) {
              historyProvider = HistoryProvider(repo: historyRepo);
              return historyProvider;
            },
          ),
          ChangeNotifierProvider<AboutUsProvider?>(
            lazy: false,
            create: (BuildContext context) {
              aboutUsProvider =
                  AboutUsProvider(repo: aboutUsRepo, psValueHolder: psValueHolder);
              aboutUsProvider!.loadAboutUsList();
              return aboutUsProvider;
            },
          ),
          ChangeNotifierProvider<MarkSoldOutItemProvider?>(
            lazy: false,
            create: (BuildContext context) {
              markSoldOutItemProvider = MarkSoldOutItemProvider(repo: productRepo);
              return markSoldOutItemProvider;
            },
          ),
          ChangeNotifierProvider<UserProvider?>(
            lazy: false,
            create: (BuildContext context) {
              userProvider = UserProvider(repo: userRepo, psValueHolder: psValueHolder);
              return userProvider;
            },
          ),
          ChangeNotifierProvider<TouchCountProvider?>(
            lazy: false,
            create: (BuildContext context) {
              touchCountProvider =
                  TouchCountProvider(repo: productRepo, psValueHolder: psValueHolder);

              final String? loginUserId = Utils.checkUserLoginId(psValueHolder!);

              final TouchCountParameterHolder touchCountParameterHolder =
              TouchCountParameterHolder(
                itemId: widget.productId,
                userId: loginUserId,
              );

              touchCountProvider!
                  .postTouchCount(touchCountParameterHolder.toMap());
              return touchCountProvider;
            },
          ),
          ChangeNotifierProvider<FavouriteItemProvider?>(
            lazy: false,
            create: (BuildContext context) {
              favouriteProvider =
                  FavouriteItemProvider(repo: productRepo, psValueHolder: psValueHolder);
              return favouriteProvider;
            },
          ),
          ChangeNotifierProvider<AppInfoProvider?>(
            lazy: false,
            create: (BuildContext context) {
              appInfoProvider =
                  AppInfoProvider(repo: appInfoRepository, psValueHolder: psValueHolder);
              appInfoProvider!.loadDeleteHistorywithNotifier();
              return appInfoProvider;
            },
          ),
          ChangeNotifierProvider<GalleryProvider?>(
            lazy: false,
            create: (BuildContext context) {
              galleryProvider = GalleryProvider(repo: galleryRepository);
              return galleryProvider;
            },
          ),
          ChangeNotifierProvider<SimilarItemsByTagsProvider>(
            lazy: false,
            create: (BuildContext context) {
              return SimilarItemsByTagsProvider(
                repo: productRepo!,
                psValueHolder: psValueHolder,
                limit: 10,
              );
            },
          ),
          ChangeNotifierProvider<OwnerSubcatSubscribeProvider>(
            lazy: false,
            create: (BuildContext context) {
              return OwnerSubcatSubscribeProvider(
                repo: OwnerSubcatSubscribeRepository(
                  psApiService: PsApiService(),
                ),
              );
            },
          ),
        ],
        child: Consumer<ItemDetailProvider>(
          builder:
              (BuildContext context, ItemDetailProvider provider, Widget? child) {
            if (provider.itemDetail.data != null &&
                markSoldOutItemProvider != null &&
                userProvider != null) {
              if (!isAddedToHistory) {
                historyProvider!.addHistoryList(provider.itemDetail.data);
                isAddedToHistory = true;

                if (psValueHolder != null &&
                    psValueHolder!.detailOpenCount != null &&
                    psValueHolder!.detailOpenCount! >
                        psValueHolder!.itemDetailViewCountForAds! &&
                    psValueHolder!.isShowAdsInItemDetail!) {
                  itemDetailProvider!.replaceDetailOpenCount(0);
                } else if (psValueHolder != null) {
                  if (psValueHolder!.detailOpenCount == null) {
                    itemDetailProvider!.replaceDetailOpenCount(1);
                  } else {
                    final int i = psValueHolder!.detailOpenCount! + 1;
                    itemDetailProvider!.replaceDetailOpenCount(i);
                  }
                }
              }

              if (provider.itemDetail.data!.videoThumbnail!.imgPath != '') {
                currentDefaultPhoto = provider.itemDetail.data!.videoThumbnail;
                isHaveVideo = true;
              } else {
                currentDefaultPhoto = provider.itemDetail.data!.defaultPhoto;
                isHaveVideo = false;
              }

              final String currentItemId = provider.itemDetail.data!.id ?? '';
              if (currentItemId.isNotEmpty) {
                _maybeLoadSimilarOnce(
                  context: context,
                  currentItemId: currentItemId,
                );
              }

              return Consumer<MarkSoldOutItemProvider>(
                builder: (
                    BuildContext context,
                    MarkSoldOutItemProvider markSoldOutItemProvider,
                    Widget? child,
                    ) {
                  return TaapdeelScaffold(
                    safeTop: false,
                    safeBottom: false,
                    padding: EdgeInsets.zero,
                    body: Stack(
                      children: <Widget>[
                        CustomScrollView(
                          slivers: <Widget>[
                            SliverAppBar(
                              automaticallyImplyLeading: true,
                              systemOverlayStyle: SystemUiOverlayStyle(
                                statusBarIconBrightness:
                                Utils.getBrightnessForAppBar(context),
                              ),
                              expandedHeight: PsDimens.space300,
                              iconTheme: Theme.of(context)
                                  .iconTheme
                                  .copyWith(color: PsColors.primaryDarkWhite),
                              leading: PsBackButtonWithCircleBgWidget(
                                isReadyToShow: isReadyToShowAppBarIcons,
                              ),
                              floating: false,
                              pinned: false,
                              stretch: true,
                              actions: <Widget>[
                                Visibility(
                                  visible: isReadyToShowAppBarIcons,
                                  child: PopUpMenuWidget(
                                    context: context,
                                    itemDetailProvider: provider,
                                    userProvider: userProvider,
                                    itemId: provider.itemDetail.data!.id,
                                    itemUserId: provider.itemDetail.data!.user!.userId,
                                    addedUserId: provider.itemDetail.data!.addedUserId,
                                    reportedUserId: psValueHolder!.loginUserId,
                                    loginUserId: psValueHolder!.loginUserId,
                                    itemTitle: provider.itemDetail.data!.title,
                                    itemImage:
                                    provider.itemDetail.data!.defaultPhoto!.imgPath,
                                  ),
                                ),
                              ],
                              backgroundColor: PsColors.transparent,
                              flexibleSpace: FlexibleSpaceBar(
                                background: Container(
                                  color: Colors.transparent,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: <Widget>[
                                      ProductDetailGalleryView(
                                        selectedDefaultImage: currentDefaultPhoto!,
                                        isHaveVideo: isHaveVideo,
                                        onImageTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            RoutePaths.galleryGrid,
                                            arguments: provider.itemDetail.data,
                                          );
                                        },
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            _buildPaidStatusBadge(provider),
                                            const SizedBox(
                                                height: PsDimens.space6),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              children: <Widget>[
                                                if (provider
                                                    .itemDetail.data!.isSoldOut ==
                                                    '1')
                                                  Expanded(
                                                    child: Container(
                                                      margin: const EdgeInsets.only(
                                                        right: PsDimens.space4,
                                                      ),
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          PsDimens.space4,
                                                        ),
                                                        color:
                                                        PsColors.soldOutUIColor,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                          PsDimens.space12,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                          Alignment.center,
                                                          child: Text(
                                                            Utils.getString(
                                                              context,
                                                              'dashboard__sold_out',
                                                            ),
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                              color:
                                                              PsColors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(
                                                height: PsDimens.space6),
                                            InkWell(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                    PsDimens.space4,
                                                  ),
                                                  color: Colors.black45,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  PsDimens.space12,
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Icon(
                                                      Entypo.picture,
                                                      color: PsColors.white,
                                                    ),
                                                    const SizedBox(
                                                      width: PsDimens.space12,
                                                    ),
                                                    Text(
                                                      '${provider.itemDetail.data!.photoCount}  ${Utils.getString(context, 'item_detail__photo')}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                        color: PsColors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  RoutePaths.galleryGrid,
                                                  arguments: provider.itemDetail.data,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                <Widget>[
                                  Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      children: <Widget>[
                                        HeaderBoxWidget(
                                          itemDetail: provider,
                                          galleryProvider: galleryProvider,
                                          product: provider.itemDetail.data,
                                          heroTagTitle: widget.heroTagTitle,
                                          favouriteProvider: favouriteProvider!,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                <Widget>[
                                  Container(
                                    color: PsColors.transparent,
                                    child: Column(
                                      children: <Widget>[
                                        _DetailWidget(itemDetail: provider),
                                        Column(
                                          children: <Widget>[
                                            SellerInfoTileView(itemDetail: provider),
                                            _SimilarByTagsInlineSection(
                                              itemId:
                                              provider.itemDetail.data!.id ?? '',
                                              coreTagKey: widget.heroTagTitle ??
                                                  provider.itemDetail.data!.id ??
                                                  '',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: PsDimens.space80),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!widget.adminReviewMode)
                          if (provider.itemDetail.data!.addedUserId != null &&
                              provider.itemDetail.data!.addedUserId ==
                                  psValueHolder!.loginUserId)
                            EditAndDeleteButtonWidget(
                              provider: provider,
                              markSoldOutItemProvider: markSoldOutItemProvider,
                              appInfoprovider: appInfoProvider!,
                              product: provider.itemDetail.data,
                              markSoldOutItemHolder: markSoldOutItemHolder,
                            )
                          else
                            CallAndChatButtonWidget(
                              provider: provider,
                              favouriteItemRepo: productRepo,
                              psValueHolder: psValueHolder,
                            ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}

class _SimilarByTagsInlineSection extends StatelessWidget {
  const _SimilarByTagsInlineSection({
    Key? key,
    required this.itemId,
    required this.coreTagKey,
    this.title = 'منتجات نفس الفئة',
  }) : super(key: key);

  final String itemId;
  final String coreTagKey;
  final String title;

  void _openProduct(BuildContext context, Product p) {
    Navigator.pushNamed(
      context,
      RoutePaths.productDetail,
      arguments: <String, dynamic>{
        'productId': p.id,
        'heroTagImage': p.defaultPhoto?.imgPath,
        'heroTagTitle': p.title,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (itemId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer<SimilarItemsByTagsProvider>(
      builder: (BuildContext context, SimilarItemsByTagsProvider p, _) {
        final List<Product> rawItems = p.similarItems.data ?? <Product>[];

        final List<Product> items = rawItems
            .where((Product e) => (e.id ?? '').trim() != itemId.trim())
            .toList();

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            PsDimens.space16,
            PsDimens.space12,
            PsDimens.space16,
            0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: PsColors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF9EE7E1),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(PsDimens.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PsColors.textColor1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: PsDimens.space12),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: PsDimens.space12),
                      itemBuilder: (BuildContext context, int index) {
                        final Product product = items[index];
                        return SizedBox(
                          width: 145,
                          child: TaapdeelProductCardItem(
                            coreTagKey: coreTagKey,
                            product: product,
                            onTap: () => _openProduct(context, product),
                            variant: TaapdeelProductCardVariant.deal,
                            showRotatingBanner: true,
                            showRelationPanel: false,
                            showConditionChip: false,
                            onTapFav: null,
                            selectedFav: false,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailWidget extends StatelessWidget {
  const _DetailWidget({
    Key? key,
    required this.itemDetail,
  }) : super(key: key);

  final ItemDetailProvider itemDetail;

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[],
    );
  }
}