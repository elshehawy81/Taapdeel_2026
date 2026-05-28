import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/product/search_product_provider.dart';
import 'package:taapdeel/provider/user/search_user_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/repository/search_user_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/common/search_bar_view.dart';
import 'package:taapdeel/ui/item/list_with_filter/product_filter_widget.dart';
import 'package:taapdeel/ui/user/search_user/search_user_list_item.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/user_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/product_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/user_follow_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/user.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../Product/product_widget.dart';


class NearestProductListView extends StatefulWidget {
  const NearestProductListView({
    required this.productParameterHolder,
    required this.appBarTitle,
    required this.tabTitleItem,
    required this.tabTitleAccount,
  });

  final ProductParameterHolder productParameterHolder;
  final String? appBarTitle;
  final String? tabTitleItem;
  final String? tabTitleAccount;

  @override
  _NearestProductListViewViewState createState() =>
      _NearestProductListViewViewState(tabTitleItem, tabTitleAccount);
}

class _NearestProductListViewViewState extends State<NearestProductListView>
    with TickerProviderStateMixin {
  _NearestProductListViewViewState(this.tabTitleItem, this.tabTitleAccount) {
    tabBar = TabBar(
      labelStyle: const TextStyle(fontSize: 16),
      labelColor: PsColors.activeColor,
      unselectedLabelColor: PsColors.grey,
      indicatorColor: PsColors.activeColor,
      tabs: <Tab>[
        Tab(text: tabTitleItem),
        Tab(text: tabTitleAccount),
      ],
    );

    searchBar = SearchBarWidget(
      inBar: true,
      controller: searchTextController,
      buildDefaultAppBar: buildAppBar,
      tabBar: tabBar,
      setState: setState,
      onSubmitted: onSubmitted,
      onCleared: () {
        print('cleared');
      },
      closeOnSubmit: false,
      onClosed: () {
        if (tabController!.index == 0 && _searchProductProvider != null) {
          widget.productParameterHolder.searchTerm = '';
          _searchProductProvider!.resetLatestProductList(
            Utils.checkUserLoginId(valueHolder!),
            widget.productParameterHolder,
          );
        } else if (_searchUserProvider != null) {
          _searchUserProvider!.searchUserParameterHolder.keyword = '';
          _searchUserProvider!.resetSearchUserList(
            _searchUserProvider!.searchUserParameterHolder.toMap(),
            Utils.checkUserLoginId(valueHolder!),
          );
        }
      },
    );
  }

  String? tabTitleItem, tabTitleAccount;

  AnimationController? animationController;
  late TextEditingController searchTextController = TextEditingController();
  late SearchBarWidget searchBar;
  late TabBar tabBar;

  PsValueHolder? valueHolder;
  SearchProductProvider? _searchProductProvider;
  SearchUserProvider? _searchUserProvider;
  UserProvider? _userProvider;

  UserRepository? userRepository;
  ProductRepository? repo1;
  SearchUserRepository? repo2;

  final ScrollController _scrollController = ScrollController();
  TabController? tabController;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (tabController!.index == 0 && _searchProductProvider != null) {
          _searchProductProvider!.nextProductListByKey(
            Utils.checkUserLoginId(valueHolder!),
            widget.productParameterHolder,
          );
        } else if (_searchUserProvider != null) {
          _searchUserProvider!.nextSearchUserList(
            _searchUserProvider!.searchUserParameterHolder.toMap(),
            Utils.checkUserLoginId(valueHolder!),
          );
        }
      }
    });

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  AppBar buildAppBar(BuildContext context) {
    if (_searchProductProvider != null && _searchProductProvider!.needReset) {
      widget.productParameterHolder.searchTerm = '';
      _searchUserProvider!.searchUserParameterHolder.keyword = '';
      _searchProductProvider!.resetLatestProductList(
        Utils.checkUserLoginId(valueHolder!),
        widget.productParameterHolder,
      );
    }
    if (_searchUserProvider != null) {
      _searchUserProvider!.resetSearchUserList(
        _searchUserProvider!.searchUserParameterHolder.toMap(),
        Utils.checkUserLoginId(valueHolder!),
      );
    }

    searchTextController.clear();

    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
      ),
      backgroundColor: PsColors.baseColor,
      iconTheme: Theme.of(context).iconTheme.copyWith(color: PsColors.iconColor),
      bottom: tabBar,
      title: Text(
        widget.appBarTitle ?? '',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold)
            .copyWith(color: PsColors.textColor2),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search, color: PsColors.iconColor),
          onPressed: () {
            searchBar.beginSearch(context);
          },
        ),
      ],
      elevation: 0,
    );
  }

  void onSubmitted(String value) {
    if (tabController!.index == 0) {
      if (!_searchProductProvider!.needReset) {
        _searchProductProvider!.needReset = true;
      }
      widget.productParameterHolder.searchTerm = value;
      _searchProductProvider!.resetLatestProductList(
        Utils.checkUserLoginId(valueHolder!),
        widget.productParameterHolder,
      );
    } else {
      _searchUserProvider!.searchUserParameterHolder.keyword = value;
      _searchUserProvider!.resetSearchUserList(
        _searchUserProvider!.searchUserParameterHolder.toMap(),
        Utils.checkUserLoginId(valueHolder!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    valueHolder = Provider.of<PsValueHolder>(context);

    repo1 = Provider.of<ProductRepository>(context);
    repo2 = Provider.of<SearchUserRepository>(context);
    userRepository = Provider.of<UserRepository>(context);

    _userProvider = UserProvider(repo: userRepository, psValueHolder: valueHolder);

    print('............................Build UI Again ............................');

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<SearchProductProvider?>(
          lazy: false,
          create: (BuildContext context) {
            final SearchProductProvider provider = SearchProductProvider(
              repo: repo1,
              psValueHolder: valueHolder,
              limit: valueHolder!.defaultLoadingLimit!,
            );

            final String? loginUserId = Utils.checkUserLoginId(valueHolder!);
            provider.loadProductListByKey(loginUserId, widget.productParameterHolder);

            _searchProductProvider = provider;
            _searchProductProvider!.productParameterHolder = widget.productParameterHolder;

            if (widget.appBarTitle ==
                Utils.getString(context, 'home_search__app_bar_title')) {
              _searchProductProvider!.needReset = false;
            }

            return _searchProductProvider;
          },
        ),
        ChangeNotifierProvider<SearchUserProvider?>(
          lazy: false,
          create: (BuildContext context) {
            final SearchUserProvider provider = SearchUserProvider(
              repo: repo2,
              psValueHolder: valueHolder,
              limit: valueHolder!.defaultLoadingLimit!,
            );

            _searchUserProvider = provider;
            _searchUserProvider!.loadSearchUserList(
              _searchUserProvider!.searchUserParameterHolder.toMap(),
              Utils.checkUserLoginId(valueHolder!),
            );
            return _searchUserProvider;
          },
        ),
        ChangeNotifierProvider<UserProvider?>(
          lazy: false,
          create: (BuildContext context) {
            _userProvider!.userParameterHolder.loginUserId =
                Utils.checkUserLoginId(valueHolder!);
            return _userProvider;
          },
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (BuildContext context) {
            tabController = DefaultTabController.of(context);

            return Scaffold(
              appBar: searchBar.build(context),
              body: TabBarView(
                children: <Widget>[
                  // ---------------------------
                  // TAB 1: Products
                  // ---------------------------
                  Consumer<SearchProductProvider>(
                    builder: (BuildContext context, SearchProductProvider provider, Widget? child) {
                      return Column(
                        children: <Widget>[
                          ProductFilterWidget(searchProductProvider: provider),
                          Expanded(
                            child: Container(
                              color: PsColors.baseColor,
                              child: Stack(
                                children: <Widget>[
                                  if (provider.productList.data != null &&
                                      provider.productList.data!.isNotEmpty)
                                    Container(
                                      color: PsColors.baseColor,
                                      margin: const EdgeInsets.only(
                                        left: PsDimens.space8,
                                        right: PsDimens.space8,
                                        top: PsDimens.space4,
                                        bottom: PsDimens.space4,
                                      ),
                                      child: RefreshIndicator(
                                        onRefresh: () {
                                          final String? loginUserId =
                                          Utils.checkUserLoginId(valueHolder!);
                                          return provider.resetLatestProductList(
                                            loginUserId,
                                            _searchProductProvider!.productParameterHolder,
                                          );
                                        },
                                        child: CustomScrollView(
                                          controller: _scrollController,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          slivers: <Widget>[
                                            SliverGrid(
                                              gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                maxCrossAxisExtent: 280.0,
                                                childAspectRatio: 0.70,
                                              ),
                                              delegate: SliverChildBuilderDelegate(
                                                    (BuildContext context, int index) {
                                                  final list = provider.productList.data ?? <Product>[];
                                                  if (list.isEmpty) return const SizedBox.shrink();

                                                  final int count = list.length;
                                                  final Product item = list[index];


                                                  final String tagKey = provider.hashCode.toString() + (item.id ?? '');

                                                  return TaapdeelProductCardItem(
                                                    coreTagKey: tagKey,
                                                    product: item,
                                                    onTap: () {
                                                      if (item.id == null) return;

                                                      final ProductDetailIntentHolder holder = ProductDetailIntentHolder(
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

                                                    // ✅ Search screen: خليها Normal (Condition فوق + Price تحت)
                                                    variant: TaapdeelProductCardVariant.normal,
                                                    showRotatingBanner: false,
                                                    showRelationPanel: false,
                                                    showConditionChip: true,
                                                    // fav optional
                                                    selectedFav: false,
                                                    onTapFav: () {
                                                      // TODO: toggle favourite إذا عندك API هنا
                                                    },
                                                  );
                                                },
                                                childCount: provider.productList.data!.length,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else if (provider.productList.status != PsStatus.PROGRESS_LOADING &&
                                      provider.productList.status != PsStatus.BLOCK_LOADING &&
                                      provider.productList.status != PsStatus.NOACTION)
                                    Align(
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Image.asset(
                                              'assets/images/baseline_empty_item_grey_24.png',
                                              height: 100,
                                              width: 150,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(height: PsDimens.space32),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: PsDimens.space20,
                                                right: PsDimens.space20,
                                              ),
                                              child: Text(
                                                Utils.getString(context, 'procuct_list__no_result_data'),
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme.titleLarge!.copyWith(),
                                              ),
                                            ),
                                            const SizedBox(height: PsDimens.space20),
                                          ],
                                        ),
                                      ),
                                    ),

                                  PSProgressIndicator(provider.productList.status),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // ---------------------------
                  // TAB 2: Users
                  // ---------------------------
                  Consumer<SearchUserProvider>(
                    builder: (BuildContext context, SearchUserProvider provider, Widget? child) {
                      return Container(
                        color: PsColors.baseColor,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(top: PsDimens.space18),
                                    child: RefreshIndicator(
                                      onRefresh: () {
                                        return provider.resetSearchUserList(
                                          _searchUserProvider!.searchUserParameterHolder.toMap(),
                                          Utils.checkUserLoginId(valueHolder!),
                                        );
                                      },
                                      child: CustomScrollView(
                                        controller: _scrollController,
                                        scrollDirection: Axis.vertical,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: false,
                                        slivers: <Widget>[
                                          SliverList(
                                            delegate: SliverChildBuilderDelegate(
                                                  (BuildContext context, int index) {
                                                if (provider.searchUserList.data == null ||
                                                    provider.searchUserList.data!.isEmpty) {
                                                  return null;
                                                }

                                                final int count = provider.searchUserList.data!.length;

                                                return SearchUserVerticalListItem(
                                                  animationController: animationController,
                                                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                                                    CurvedAnimation(
                                                      parent: animationController!,
                                                      curve: Interval((1 / count) * index, 1.0,
                                                          curve: Curves.fastOutSlowIn),
                                                    ),
                                                  ),
                                                  user: provider.searchUserList.data![index],
                                                  currentUser: Utils.checkUserLoginId(valueHolder!),
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      RoutePaths.userDetail,
                                                      arguments: UserIntentHolder(
                                                        userId: provider.searchUserList.data![index].userId,
                                                        userName: provider.searchUserList.data![index].userName,
                                                      ),
                                                    );
                                                  },
                                                  onFollowBtnTap: () async {
                                                    if (await Utils.checkInternetConnectivity()) {
                                                      Utils.navigateOnUserVerificationView(
                                                        _userProvider,
                                                        context,
                                                            () async {
                                                          if (provider.searchUserList.data![index].isFollowed ==
                                                              PsConst.ZERO) {
                                                            setState(() {
                                                              provider.searchUserList.data![index].isFollowed =
                                                                  PsConst.ONE;
                                                            });

                                                            final UserFollowHolder userFollowHolder =
                                                            UserFollowHolder(
                                                              userId: Utils.checkUserLoginId(valueHolder!),
                                                              followedUserId: provider.searchUserList.data![index].userId,
                                                            );

                                                            final PsResource<User> _user =
                                                            await _userProvider!.postUserFollow(
                                                              userFollowHolder.toMap(),
                                                            );

                                                            if (_user.data != null) {
                                                              if (_user.data!.isFollowed == PsConst.ONE) {
                                                                _userProvider!.user.data!.isFollowed = PsConst.ONE;
                                                              }
                                                            }
                                                          }
                                                        },
                                                      );
                                                    } else {
                                                      showDialog<dynamic>(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return ErrorDialog(
                                                            message: Utils.getString(
                                                              context,
                                                              'error_dialog__no_internet',
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                              childCount: provider.searchUserList.data?.length ?? 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PSProgressIndicator(provider.searchUserList.status),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
