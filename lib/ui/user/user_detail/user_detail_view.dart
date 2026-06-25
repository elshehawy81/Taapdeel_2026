import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/product/added_item_provider.dart';
import 'package:taapdeel/provider/product/product_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/common/smooth_star_rating_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/product_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/user.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:taapdeel/ui/common/taapdeel/taapdeel_info_card_shell.dart';

// ✅ Family provider
import '../../../provider/product/family_items_provider.dart';

// ✅ reuse profile wishlist tab + cards bar
import '../../Foryou/home_provider.dart';
import '../../Product/product_widget.dart';
import '../../common/ps_frame_loading_widget.dart';
import '../../common/taapdeel/taapdeel_scaffold.dart';
import '../profile/widgets/profile_cards_bar.dart';
import '../profile/widgets/profile_wishlist_tab.dart';

class UserDetailView extends StatefulWidget {
  const UserDetailView({
    required this.userId,
    required this.userName,
  });

  final String? userId;
  final String? userName;

  @override
  _UserDetailViewState createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  // ✅ main scroll (NestedScrollView)
  final ScrollController _mainScrollController = ScrollController();

  // ✅ cards bar controller
  final ScrollController _cardsController = ScrollController();

  // ✅ active grid controller (load more)
  final ScrollController _activeScrollController = ScrollController();

  // ✅ family grid controller (load more optional)
  final ScrollController _familyScrollController = ScrollController();

  // ✅ expanded type
  ProfileTabType _expandedType = ProfileTabType.active;

  // ✅ prime wishlist once
  bool _wishPrimed = false;

  // ✅ prime family once
  bool _familyPrimed = false;

  // providers / repos
  UserProvider? userProvider;
  UserRepository? userRepository;
  PsValueHolder? psValueHolder;
  ProductRepository? itemRepository;

  AddedItemProvider? itemProvider;
  ItemDetailProvider? itemDetailProvider;
  late ProductParameterHolder parameterHolder;

  // ✅ cache counts (stable while loading)
  int _familyCountCache = 0;

  // ✅ Keep a stable provider instance so initState scroll listeners do not
  // read from a BuildContext that is above MultiProvider.
  ProfileFamilyItemsProvider? _familyItemsProvider;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    // ✅ load more for active products
    _activeScrollController.addListener(() {
      if (!_activeScrollController.hasClients) return;

      if (_activeScrollController.position.pixels >=
          _activeScrollController.position.maxScrollExtent - 200) {
        final String? loginUserId = (psValueHolder == null)
            ? null
            : Utils.checkUserLoginId(psValueHolder!);

        if (loginUserId == null) return;
        itemProvider?.nextItemList(loginUserId, parameterHolder);
      }
    });

    // ✅ (اختياري) load more for family لو provider عنده pagination.
    // Important: do not use context.read<ProfileFamilyItemsProvider>() here.
    // State.context is above the MultiProvider created in build(), so it can
    // crash with: Provider<ProfileFamilyItemsProvider> not found.
    _familyScrollController.addListener(() {
      if (!_familyScrollController.hasClients) return;
      if (_familyScrollController.position.pixels <
          _familyScrollController.position.maxScrollExtent - 200) {
        return;
      }

      final ProfileFamilyItemsProvider? famP = _familyItemsProvider;
      if (famP == null) return;

      final st = famP.itemList.status;
      final bool isLoading = st == PsStatus.BLOCK_LOADING ||
          st == PsStatus.PROGRESS_LOADING ||
          st == PsStatus.LOADING;

      if (!isLoading && famP.hasMore) {
        final String profileId = (widget.userId ?? '');
        if (profileId.isEmpty) return;
        famP.nextFamilyItems(null, profileId);
      }
    });
  }

  @override
  void dispose() {
    _cardsController.dispose();
    _activeScrollController.dispose();
    _familyScrollController.dispose();
    _mainScrollController.dispose();
    animationController?.dispose();
    _familyItemsProvider?.dispose();
    super.dispose();
  }

  Future<bool> _requestPop() async {
    await animationController?.reverse();
    if (!mounted) return false;
    Navigator.pop(context, true);
    return true;
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

  void _toggleSectionWithContext(
      BuildContext innerCtx, ProfileTabType type, int index) {
    if (type != ProfileTabType.wishlist &&
        type != ProfileTabType.active &&
        type != ProfileTabType.family) {
      return;
    }

    setState(() => _expandedType = type);

    if (type == ProfileTabType.family) {
      final String profileId = (widget.userId ?? '');
      final famP = innerCtx.read<ProfileFamilyItemsProvider>();

      final bool hasData = (famP.itemList.data ?? <Product>[]).isNotEmpty;
      final bool isLoading = famP.itemList.status == PsStatus.BLOCK_LOADING ||
          famP.itemList.status == PsStatus.PROGRESS_LOADING ||
          famP.itemList.status == PsStatus.LOADING;

      if (profileId.isNotEmpty && !hasData && !isLoading) {
        famP.loadFamilyItems(null, profileId);
      }
    }

    _scrollCards(index);
  }

  void _scrollCards(int index) {
    if (!_cardsController.hasClients) return;
    final double w = MediaQuery.of(context).size.width;
    final double cardW = (w - 5) / 2.2;
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

  Widget _buildActiveGrid(AddedItemProvider provider) {
    final List<Product> data = (provider.itemList.data ?? <Product>[]);

    if (provider.itemList.status == PsStatus.BLOCK_LOADING && data.isEmpty) {
      return const Center(child: PsFrameUIForLoading());
    }

    if (data.isEmpty) {
      return const Center(child: Text('لا توجد منتجات نشطة'));
    }

    return GridView.builder(
      controller: _activeScrollController,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300.0,
        childAspectRatio: 0.82,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        final Product product = data[index];

        if (product.adType == PsConst.GOOGLE_AD_TYPE) {
          return const SizedBox.shrink();
        }

        final String tagKey = provider.hashCode.toString() + (product.id ?? '');

        return TaapdeelProductCardItem(
          coreTagKey: tagKey,
          product: product,
          onTap: () {
            if (product.id == null) return;

            final ProductDetailIntentHolder holder = ProductDetailIntentHolder(
              productId: product.id,
              heroTagImage: '$tagKey${PsConst.HERO_TAG__IMAGE}',
              heroTagTitle: '$tagKey${PsConst.HERO_TAG__TITLE}',
            );

            Navigator.pushNamed(
              context,
              RoutePaths.productDetail,
              arguments: holder,
            );
          },
          variant: TaapdeelProductCardVariant.family,
          showRotatingBanner: false,
          showRelationPanel: true,
          showConditionChip: true,
          onTapFav: () {},
          selectedFav: false,
        );
      },
    );
  }



  String? _getRelationCode(Product p) {
    String clean(dynamic value) {
      final String text = (value ?? '').toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return '';
      return text;
    }

    final String code = clean(p.relationCode).toUpperCase();
    if (code.isNotEmpty) return code;

    final String rawType = clean(p.relationType);
    switch (rawType) {
      case '1':
        return 'FRIEND';
      case '2':
      case '3':
      case '4':
      case '5':
        return 'FAMILY';
      case '6':
        return 'BIG_FAMILY';
      default:
        return null;
    }
  }

  int _getRelationTypeForFamilyGallery(Product p) {
    String clean(dynamic value) {
      final String text = (value ?? '').toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return '';
      return text;
    }

    // مهم: نقرأ الرقم التفصيلي الأول لأن relationCode غالبًا = FAMILY فقط.
    // relationType هو الذي يحدد: 2 زوج/زوجة، 3 ابن/ابنة، 4 أب/أم، 5 أخ/أخت.
    final String rawType = clean(p.relationType);
    final int? parsedType = int.tryParse(rawType);
    if (parsedType != null && parsedType > 0) {
      return parsedType;
    }

    final String code = clean(p.relationCode).toUpperCase();
    switch (code) {
      case 'FRIEND':
        return 1;
      case 'FAMILY':
        return 4;
      case 'BIG_FAMILY':
        return 6;
      case 'SELF':
        return 777;
    }

    // User detail family gallery is already a family-network section.
    // If parsing loses relation_code, keep the relation bar visible.
    return 4;
  }

  Widget _buildFamilyGrid(ProfileFamilyItemsProvider famP) {
    final List<Product> data = (famP.itemList.data ?? <Product>[]);

    final st = famP.itemList.status;
    final bool loading = st == PsStatus.BLOCK_LOADING ||
        st == PsStatus.PROGRESS_LOADING ||
        st == PsStatus.LOADING;

    if (loading && data.isEmpty) {
      return const Center(child: PsFrameUIForLoading());
    }

    if (!loading && data.isEmpty) {
      return const Center(child: Text('لا توجد منتجات للعيلة'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        final String profileId = (widget.userId ?? '');
        if (profileId.isEmpty) return;
        await famP.loadFamilyItems(
          null,
          profileId,
        );
      },
      child: GridView.builder(
        controller: _familyScrollController,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          childAspectRatio: 0.82,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          final Product product = data[index];

          if (product.adType == PsConst.GOOGLE_AD_TYPE) {
            return const SizedBox.shrink();
          }

          final String tagKey = 'family_${famP.hashCode}_${product.id ?? ''}';
          final String? relationCodeForCard = _getRelationCode(product);
          final int relationTypeForCard = _getRelationTypeForFamilyGallery(product);

          return TaapdeelProductCardItem(
            coreTagKey: tagKey,
            product: product,
            onTap: () {
              if (product.id == null) return;

              final ProductDetailIntentHolder holder = ProductDetailIntentHolder(
                productId: product.id,
                heroTagImage: '$tagKey${PsConst.HERO_TAG__IMAGE}',
                heroTagTitle: '$tagKey${PsConst.HERO_TAG__TITLE}',
              );

              Navigator.pushNamed(
                context,
                RoutePaths.productDetail,
                arguments: holder,
              );
            },
            variant: TaapdeelProductCardVariant.family,
            showRotatingBanner: true,
            showRelationPanel: true,
            relationType: relationTypeForCard,
            relationBackendCode: relationCodeForCard,
            showConditionChip: false,
            onTapFav: () {},
            selectedFav: false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    itemRepository = Provider.of<ProductRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    _familyItemsProvider ??= ProfileFamilyItemsProvider(
      repo: itemRepository!,
      psValueHolder: psValueHolder!,
      limit: psValueHolder!.defaultLoadingLimit!,
    );

    final String profileUserId = widget.userId ?? '';

    userProvider =
        UserProvider(repo: userRepository, psValueHolder: psValueHolder);
    itemProvider = AddedItemProvider(repo: itemRepository);

    parameterHolder = itemProvider!.addedUserParameterHolder;
    parameterHolder.mile = psValueHolder!.mile;
    parameterHolder.addedUserId = widget.userId;
    parameterHolder.status = '1';

    if (!_wishPrimed) {
      _wishPrimed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final String? uid = widget.userId;
        if (!mounted) return;
        if (uid != null && uid.isNotEmpty) {
          HomeProvider.of(context, listen: false).getOwnerWishListProduct(uid);
        }
      });
    }

    return WillPopScope(
      onWillPop: _requestPop,
      child: TaapdeelScaffold(
        safeTop: false,
        padding: EdgeInsets.zero,
        body: MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<UserProvider?>(
              lazy: false,
              create: (BuildContext context) {
                userProvider!.userParameterHolder.loginUserId =
                    userProvider!.psValueHolder!.loginUserId;
                userProvider!.userParameterHolder.id = widget.userId;
                userProvider!.getOtherUserData(
                  userProvider!.userParameterHolder.toMap(),
                  userProvider!.userParameterHolder.id,
                );
                return userProvider;
              },
            ),
            ChangeNotifierProvider<ItemDetailProvider?>(
              lazy: false,
              create: (BuildContext context) {
                itemDetailProvider = ItemDetailProvider(
                  repo: itemRepository,
                  psValueHolder: psValueHolder,
                );
                return itemDetailProvider;
              },
            ),
            ChangeNotifierProvider<AddedItemProvider?>(
              lazy: false,
              create: (BuildContext context) {
                itemProvider!.loadItemList(
                  Utils.checkUserLoginId(psValueHolder!),
                  parameterHolder,
                );
                return itemProvider;
              },
            ),
            ChangeNotifierProvider<ProfileFamilyItemsProvider>.value(
              value: _familyItemsProvider!,
            ),
          ],
          child: Builder(
            builder: (context) {
              if (!_familyPrimed) {
                _familyPrimed = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (profileUserId.isEmpty) return;

                  debugPrint(
                      '🟦 [USER DETAIL] PRIME FAMILY profileUserId=$profileUserId');
                  context.read<ProfileFamilyItemsProvider>().loadFamilyItems(
                    null,
                    profileUserId,
                  );
                });
              }

              return Consumer<AddedItemProvider>(
                builder: (BuildContext context, AddedItemProvider provider,
                    Widget? child) {
                  return Stack(
                    children: <Widget>[
                      NestedScrollView(
                        controller: _mainScrollController,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverAppBar(
                              systemOverlayStyle: SystemUiOverlayStyle(
                                statusBarIconBrightness:
                                Utils.getBrightnessForAppBar(context),
                              ),
                              automaticallyImplyLeading: false,
                              leading: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: PsColors.backArrowColor,
                                ),
                                onPressed: () async {
                                  await animationController?.reverse();
                                  if (!mounted) return;

                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    RoutePaths.home,
                                        (route) => false,
                                  );
                                },
                              ),
                              title: Text(
                                widget.userName ?? '',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Consumer<UserProvider>(
                              builder: (context, up, _) {
                                if (up.user.data == null) {
                                  return const SliverToBoxAdapter(
                                    child: SizedBox.shrink(),
                                  );
                                }
                                return OtherUserPremiumHeaderSliver(
                                  provider: up,
                                  addedItemProvider: provider,
                                  status: '1',
                                  headerTitle: Utils.getString(
                                    context,
                                    'profile__listing',
                                  ),
                                );
                              },
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(16, 6, 16, 10),
                                child: TaapdeelInfoCardShell(
                                  margin: EdgeInsets.zero,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  withBlur: true,
                                  child: Builder(
                                    builder: (context) {
                                      final HomeProvider homeP =
                                      context.watch<HomeProvider>();
                                      final ProfileFamilyItemsProvider famP =
                                      context
                                          .watch<ProfileFamilyItemsProvider>();

                                      final int wishCount =
                                          homeP.wishListProducts.length;
                                      final bool wishLoading = homeP.wishLoading;

                                      final List<Product> activeList =
                                          provider.itemList.data ??
                                              <Product>[];
                                      final int activeCount = activeList.length;
                                      final bool activeLoading =
                                          provider.itemList.status ==
                                              PsStatus.BLOCK_LOADING;

                                      final List<Product> famList =
                                          famP.itemList.data ?? <Product>[];
                                      final famStatus = famP.itemList.status;

                                      final bool famLoading =
                                          famStatus == PsStatus.BLOCK_LOADING ||
                                              famStatus ==
                                                  PsStatus.PROGRESS_LOADING ||
                                              famStatus == PsStatus.LOADING;

                                      final int famRaw = famList.length;
                                      if (famRaw > 0) {
                                        _familyCountCache = famRaw;
                                      }
                                      final int famStable =
                                      (famLoading && famRaw == 0)
                                          ? _familyCountCache
                                          : famRaw;

                                      final num wishTotalValue = 0;
                                      final num activeTotalValue =
                                      _sumProductsMinPrice(activeList);
                                      final num familyTotalValue =
                                      _sumProductsMinPrice(famList);

                                      return ProfileHorizontalCardsBar(
                                        expandedType: _expandedType,
                                        controller: _cardsController,
                                        onTap: (type, index) =>
                                            _toggleSectionWithContext(
                                              context,
                                              type,
                                              index,
                                            ),
                                        wishCount: wishCount,
                                        wishLoading: wishLoading,
                                        wishTotalValue: wishTotalValue,
                                        familyCount: famStable,
                                        familyLoading: famLoading,
                                        familyTotalValue: familyTotalValue,
                                        activeCount: activeCount,
                                        activeLoading: activeLoading,
                                        activeTotalValue: activeTotalValue,
                                        pendingCount: 0,
                                        pendingLoading: false,
                                        pendingTotalValue: 0,
                                        paidCount: 0,
                                        paidLoading: false,
                                        paidTotalValue: 0,
                                        soldCount: 0,
                                        soldLoading: false,
                                        soldTotalValue: 0,
                                        rejectedCount: 0,
                                        rejectedLoading: false,
                                        rejectedTotalValue: 0,
                                        disabledCount: 0,
                                        disabledLoading: false,
                                        disabledTotalValue: 0,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ];
                        },
                        body: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: (_expandedType == ProfileTabType.wishlist)
                              ? ProfileWishlistTab(userId: widget.userId)
                              : (_expandedType == ProfileTabType.family)
                              ? _buildFamilyGrid(
                            context
                                .watch<ProfileFamilyItemsProvider>(),
                          )
                              : _buildActiveGrid(provider),
                        ),
                      ),
                      PSProgressIndicator(provider.itemList.status),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RatingWidget extends StatelessWidget {
  const _RatingWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final User? data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              RoutePaths.ratingList,
              arguments: data!.userId,
            );
          },
          child: SmoothStarRating(
            key: Key(data!.ratingDetail!.totalRatingValue!),
            rating: double.parse(data!.ratingDetail!.totalRatingValue!),
            allowHalfRating: false,
            isReadOnly: true,
            starCount: 5,
            size: PsDimens.space16,
            color: PsColors.activeColor,
            borderColor: PsColors.iconColor,
            onRated: (double? v) {},
            spacing: 0.0,
          ),
        ),
        const SizedBox(width: PsDimens.space8),
        if (data!.overallRating != '0')
          Text(
            data!.overallRating!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
      ],
    );
  }
}

class OtherUserPremiumHeaderSliver extends StatelessWidget {
  const OtherUserPremiumHeaderSliver({
    Key? key,
    required this.provider,
    required this.addedItemProvider,
    required this.status,
    required this.headerTitle,
  }) : super(key: key);

  final UserProvider provider;
  final AddedItemProvider addedItemProvider;
  final String status;
  final String headerTitle;

  @override
  Widget build(BuildContext context) {
    final u = provider.user.data;
    if (u == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: TaapdeelInfoCardShell(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          withBlur: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PsNetworkCircleImageForUser(
                    photoKey: '',
                    imagePath: u.userProfilePhoto,
                    gender: u.userGender,
                    ageRange: u.userAge,
                    width: 56,
                    height: 56,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.userName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if ((u.userAboutMe ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            u.userAboutMe!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _RatingWidget(data: u),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _JoinDateText(userProvider: provider),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JoinDateText extends StatelessWidget {
  const _JoinDateText({required this.userProvider});
  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    final u = userProvider.user.data;
    if (u == null) return const SizedBox.shrink();

    final String text =
    (u.addedDateTimeStamp != null && u.addedDateTimeStamp!.isNotEmpty)
        ? Utils.changeTimeStampToStandardDateTimeFormat(
      u.addedDateTimeStamp,
    )
        : Utils.getDateFormat(
      u.addedDate,
      userProvider.psValueHolder!.dateFormat!,
    );

    final TextStyle? style = Theme.of(context).textTheme.bodySmall;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool tight = constraints.maxWidth < 170;

        if (tight) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Utils.getString(context, 'user_detail__joined'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
              const SizedBox(height: 2),
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 0,
              child: Text(
                Utils.getString(context, 'user_detail__joined'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        );
      },
    );
  }
}