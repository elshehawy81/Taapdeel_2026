import 'dart:developer' as dev;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/provider/category/category_provider.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import 'package:taapdeel/repository/Common/notification_repository.dart';
import 'package:taapdeel/repository/category_repository.dart';
import 'package:taapdeel/repository/item_location_repository.dart';
import 'package:taapdeel/repository/paid_ad_item_repository.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/ui/Discover/verticalview/Premium_section_sliver.dart';
import 'package:taapdeel/ui/Discover/verticalview/explore_section_sliver.dart';
import 'package:taapdeel/ui/Discover/verticalview/wish_items_section_sliver.dart';
import 'package:taapdeel/ui/category/list/category_list_view.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/utils/taapdeel_share_links.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../api/ps_url.dart';
import '../../../db/common/ps_shared_preferences.dart';
import '../../../viewobject/product.dart';
import '../Contacts/search_provider.dart';
import '../Product/product_widget.dart';
import '../item/share_theme/product_share_options.dart';
import '../common/taapdeel/taapdeel_scaffold.dart';
import '../wish_Items/wish_item_entry_container_view.dart';
import '../wish_Items/wish_product_share_options.dart';
import 'base_section_grid_sliver.dart';
import 'verticalview/Brands_section_sliver.dart';
import 'verticalview/family_section_sliver.dart';


const List<String> _addWishItemRouteCandidates = <String>[
  '/wishItemEntry',
  '/wish-item-entry',
  '/wish_item_entry',
  'wishItemEntry',
  'wish_item_entry',
];

class HomeDashboardViewWidget extends StatefulWidget {
  const HomeDashboardViewWidget(
      this.scrollController,
      this.animationController,
      this.animationControllerForFab,
      );

  final ScrollController scrollController;
  final AnimationController animationController;
  final AnimationController animationControllerForFab;

  @override
  State<HomeDashboardViewWidget> createState() => _HomeDashboardViewWidgetState();
}

enum HomeSectionsViewMode { sections, chips }

class _HomeDashboardViewWidgetState extends State<HomeDashboardViewWidget> {
  PsValueHolder? valueHolder;

  late final CategoryRepository _repo1;
  late final ProductRepository _repo2;
  // ignore: unused_field
  late final ItemLocationRepository _repo4;
  // ignore: unused_field
  late final NotificationRepository _notificationRepository;

  CategoryProvider? _categoryProvider;
  RecentProductProvider? _recentProductProvider;
  // ignore: unused_field
  PaidAdItemRepository? paidAdItemRepository;

  String _chipsSelectedKey = 'prefcat';
  String _chipsSelectedTitle = 'لك انت';
  String _chipsSelectedUrl = PsUrl.ps_Prefcat_bulk_url;

  final int count = 30;

  final TextEditingController userInputItemNameTextEditingController =
  TextEditingController();
  final TextEditingController useraddressTextEditingController =
  TextEditingController();

  // ignore: unused_field
  String _authStatus = 'Unknown';
  String _catId = '';

  bool _depsReady = false;

  // ✅ FIX: ValueNotifier بدل setState لمنع rebuild الصفحة كلها عند الـ scroll
  final ValueNotifier<bool> _showScrollToTop = ValueNotifier<bool>(false);
  static const double _scrollToTopThreshold = 450.0;

  HomeSectionsViewMode _viewMode = HomeSectionsViewMode.chips;

  final ScrollController _worldCardsController = ScrollController();
  final WishItemsProvider _wishItemsProvider = WishItemsProvider();

  final Map<String, GlobalKey> _worldCardKeys = <String, GlobalKey>{
    'prefcat': GlobalKey(),
    'family': GlobalKey(),
    'premium': GlobalKey(),
    'explore': GlobalKey(),
    'wish': GlobalKey(),
  };

  // ✅ FIX: cache للـ worldCards
  List<_WorldCardData>? _cachedWorldCards;
  bool? _cachedLoggedIn;

  List<_WorldCardData> _getWorldCards(bool loggedIn) {
    if (_cachedWorldCards != null && _cachedLoggedIn == loggedIn) {
      return _cachedWorldCards!;
    }
    _cachedLoggedIn = loggedIn;
    _cachedWorldCards = _buildWorldCards(loggedIn);
    return _cachedWorldCards!;
  }

  static const List<_WorldCardData> _guestWorldCards = [
    _WorldCardData(
      keyName: 'prefcat',
      title: 'لك انت',
      subtitle: 'حسب اهتماماتك',
      url: PsUrl.ps_Prefcat_bulk_url,
      icon: Icons.explore_rounded,
      gradient: <Color>[Color(0xFFB8F4FF), Color(0xFF0A7EA0)],
      accent: Color(0xFF0C587A),
    ),
    _WorldCardData(
      keyName: 'premium',
      title: 'لُقْطَة',
      subtitle: 'أفضل الاختيارات',
      url: PsUrl.ps_premium_url,
      icon: Icons.local_offer_rounded,
      gradient: <Color>[Color(0xFFFFDE79), Color(0xFFE0A100)],
      accent: Color(0xFFE0A100),
    ),
    _WorldCardData(
      keyName: 'explore',
      title: 'الأحدث',
      subtitle: 'أحدث الإضافات',
      url: PsUrl.ps_explore_url,
      icon: Icons.rocket_launch_rounded,
      gradient: <Color>[Color(0xFFFF6A6A), Color(0xFFFF8E8E)],
      accent: Color(0xFF011934),
    ),
    _WorldCardData(
      keyName: 'wish',
      title: 'منتجات مطلوبه',
      subtitle: 'طلبات وراها حواديت',
      url: PsUrl.ps_get_wishlist_items_url,
      icon: Icons.favorite_border_rounded,
      gradient: <Color>[
        Color(0xFF5B21B6), // deep royal purple
        Color(0xFFFF6B9A), // warm story pink // playful pink-lilac // bright turquoise
      ],
      accent: Color(0xFFFFD166),
    ),
  ];

  List<_WorldCardData> _buildWorldCards(bool loggedIn) {
    if (!loggedIn) return _guestWorldCards;
    return <_WorldCardData>[
      ..._guestWorldCards.sublist(0, 1),
      const _WorldCardData(
        keyName: 'family',
        title: 'العائلة والأصدقاء',
        subtitle: 'الاكثر ثقة',
        url: PsUrl.ps_family_network_items_url,
        icon: Icons.diversity_3_rounded,
        gradient: <Color>[Color(0xFF4FACFE), Color(0xFF00F2FE)],
        accent: Color(0xFF011934),
      ),
      ..._guestWorldCards.sublist(1),
    ];
  }

  Future<void> _bringSelectedWorldCardIntoView() async {
    if (!mounted) return;
    if (!_worldCardsController.hasClients) return;

    final BuildContext? cardCtx =
        _worldCardKeys[_chipsSelectedKey]?.currentContext;
    if (cardCtx == null) return;

    await Scrollable.ensureVisible(
      cardCtx,
      alignment: 0.12,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == HomeSectionsViewMode.sections
          ? HomeSectionsViewMode.chips
          : HomeSectionsViewMode.sections;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_viewMode == HomeSectionsViewMode.chips) {
        await _bringSelectedWorldCardIntoView();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  // ✅ FIX: _onScroll بدون setState — يستخدم ValueNotifier
  void _onScroll() {
    final dir = widget.scrollController.position.userScrollDirection;

    if (dir == ScrollDirection.reverse) {
      widget.animationControllerForFab.reverse();
    } else if (dir == ScrollDirection.forward) {
      widget.animationControllerForFab.forward();
    }

    final bool shouldShow = widget.scrollController.hasClients &&
        widget.scrollController.offset > _scrollToTopThreshold;

    if (_showScrollToTop.value != shouldShow) {
      _showScrollToTop.value = shouldShow;
    }
  }

  bool _isLoggedIn() {
    final String uid = PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__USER_ID) ??
        '';
    final String s = uid.trim().toLowerCase();
    return s.isNotEmpty && s != 'nologinuser';
  }

  void _onChipSelected(String key, String title, String url) {
    setState(() {
      _chipsSelectedKey = key;
      _chipsSelectedTitle = title;
      _chipsSelectedUrl = url;

    });

    final SearchProvider sp = SearchProvider.of(context, listen: false);

    if (key == 'wish') {
      _wishItemsProvider
          .getWishListProduct(
        itemLocationId: valueHolder?.locationId,
        itemLocationTownshipId: valueHolder?.locationTownshipId,
        catId: _catId,
      )
          .catchError((Object _) {});
    } else {
      final bool loading = sp.sectionLoading(_chipsSelectedUrl);
      final List<Product> items = sp.sectionProducts(_chipsSelectedUrl);

      if (!loading && items.isEmpty) {
        sp.loadSection(
          filterUrl: _chipsSelectedUrl,
          catId: _catId,
          pageSize: 50,
        ).catchError((e, st) {});
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_viewMode != HomeSectionsViewMode.chips) return;
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;
      await _bringSelectedWorldCardIntoView();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_depsReady) return;
    _depsReady = true;

    valueHolder = context.read<PsValueHolder>();
    _repo1 = context.read<CategoryRepository>();
    _repo2 = context.read<ProductRepository>();
    _repo4 = context.read<ItemLocationRepository>();
    _notificationRepository = context.read<NotificationRepository>();

  }

  @override
  void dispose() {
    _showScrollToTop.dispose();
    _worldCardsController.dispose();
    _wishItemsProvider.dispose();
    widget.scrollController.removeListener(_onScroll);
    userInputItemNameTextEditingController.dispose();
    useraddressTextEditingController.dispose();
    super.dispose();
  }

  Future<void> initPlugin() async {
    try {
      final TrackingStatus status =
      await AppTrackingTransparency.trackingAuthorizationStatus;
      if (mounted) {
        setState(() => _authStatus = '$status');
      }

      if (status == TrackingStatus.notDetermined) {
        final TrackingStatus newStatus =
        await AppTrackingTransparency.requestTrackingAuthorization();
        if (mounted) {
          setState(() => _authStatus = '$newStatus');
        }
      }
    } on PlatformException {
      if (mounted) {
        setState(() => _authStatus = 'PlatformException was thrown');
      }
    }

    final String uuid =
    await AppTrackingTransparency.getAdvertisingIdentifier();
    print('UUID: $uuid');
  }

  Future<void> _openEditInterests() async {
    if (!mounted) return;

    final bool? changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) {
          return const CategoryListView(home: true);
        },
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      // ✅ FIX: invalidate الـ prefcat cache لما المستخدم يغير اهتماماته
      SearchProvider.of(context, listen: false).invalidatePrefCatCache();

      setState(() {
        _chipsSelectedKey = 'prefcat';
        _chipsSelectedTitle = 'لك انت';
        _chipsSelectedUrl = PsUrl.ps_Prefcat_bulk_url;
      });
      await _reloadHomeSections();
    }
  }

  Future<void> _openAddWishItem() async {
    if (!mounted) return;

    Object? result;
    bool opened = false;

    for (final String routeName in _addWishItemRouteCandidates) {
      try {
        result = await Navigator.of(context).pushNamed<dynamic>(routeName);
        opened = true;
        break;
      } catch (_) {
        opened = false;
      }
    }

    if (!mounted) return;

    if (!opened) {
      try {
        result = await Navigator.of(context).push<dynamic>(
          MaterialPageRoute<dynamic>(
            builder: (_) => WishItemEntryContainerView(
              flag: 'add',
              item: Product(),
              onItemUploaded: () => Navigator.of(context).pop(true),
            ),
          ),
        );
        opened = true;
      } catch (_) {
        opened = false;
      }
    }

    if (!mounted) return;

    if (!opened) {
      Fluttertoast.showToast(
        msg: 'لم يتم فتح شاشة احكي أمنيتك',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
      );
      return;
    }

    if (result == true || result == null) {
      await _wishItemsProvider.reload(
        itemLocationId: valueHolder?.locationId,
        itemLocationTownshipId: valueHolder?.locationTownshipId,
        catId: _catId,
      );
    }
  }

  void _openNormalProductShare(Product product) {
    if (!mounted) return;

    ProductShareOptions.show(
      context: context,
      product: product,
      dynamicLink: _buildProductShareLink(product),
      imageUrl: _resolveProductShareImage(product),
    );
  }

  void _openWishProductShare(Product product) {
    if (!mounted) return;

    WishProductShareOptions.show(
      context: context,
      product: product,
      dynamicLink: _buildWishShareLink(product),
      imageUrl: _resolveProductShareImage(product),
    );
  }

  String _buildProductShareLink(Product product) {
    return TaapdeelShareLinks.product(product.id);
  }

  String _buildWishShareLink(Product product) {
    return TaapdeelShareLinks.wish(product.id);
  }

  // ✅ Safe image resolver: لا تستخدم defaultPhoto.path لأنه غير موجود في DefaultPhoto.
  String _resolveProductShareImage(Product product) {
    final dynamic dynamicProduct = product;

    String normalize(dynamic value) => (value ?? '').toString().trim();

    bool hasValue(String value) {
      return value.isNotEmpty && value.toLowerCase() != 'null';
    }

    String read(dynamic Function() getter) {
      try {
        final String value = normalize(getter());
        return hasValue(value) ? value : '';
      } catch (_) {
        return '';
      }
    }

    final List<String> candidates = <String>[
      read(() => dynamicProduct.defaultPhoto?.imgPath),
      read(() => dynamicProduct.defaultPhoto?.url),
      read(() => dynamicProduct.defaultPhoto?.originalImgPath),
      read(() => dynamicProduct.defaultPhoto?.thumbnail),
      read(() => dynamicProduct.defaultPhoto?.fullPath),
      read(() => dynamicProduct.image),
      read(() => dynamicProduct.imagePath),
      read(() => dynamicProduct.fullPath),
      read(() => dynamicProduct.imgPath),
      read(() => dynamicProduct.image_url),
      read(() => dynamicProduct.imageUrl),
    ];

    for (final String candidate in candidates) {
      if (hasValue(candidate)) return candidate;
    }

    return '';
  }

  Widget _withShareButton({
    required Product product,
    required Widget child,
    bool isWishItem = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(child: child),
        PositionedDirectional(
          top: 8,
          end: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                if (isWishItem) {
                  _openWishProductShare(product);
                } else {
                  _openNormalProductShare(product);
                }
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(238),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0A7EA0).withAlpha(80),
                    width: 1.1,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x24000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.share,
                  color: Color(0xFF0A7EA0),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _reloadHomeSections() async {
    if (!mounted) return;
    final SearchProvider sp = SearchProvider.of(context, listen: false);
    final bool logged = _isLoggedIn();

    try {
      if (!logged) {
        sp.clearSections();
      }

      if (_chipsSelectedKey == 'wish') {
        await _wishItemsProvider.reload(
          itemLocationId: valueHolder?.locationId,
          itemLocationTownshipId: valueHolder?.locationTownshipId,
          catId: _catId,
        );
      } else {
        await sp.loadInitialSection(
          filterUrl: _chipsSelectedUrl,
          catId: _catId,
          pageSize: 50,
        );
      }

      if (!mounted) return;

      // ✅ FIX: بدون delay — preload فوري في الخلفية
      sp.preloadOtherSections(
        currentUrl: _chipsSelectedKey == 'wish'
            ? PsUrl.ps_Prefcat_bulk_url
            : _chipsSelectedUrl,
        catId: _catId,
        isLoggedIn: logged,
        pageSize: 50,
      );
    } catch (e, st) {
      dev.log('_reloadHomeSections error', error: e, stackTrace: st);
    }
  }

  List<String> _buildIds(List<dynamic> data) {
    final List<String> ids = <String>[''];
    for (final dynamic c in data) {
      final String id = (c.catId ?? c.id ?? '').toString();
      if (id.isEmpty) continue;
      ids.add(id);
    }
    return ids;
  }



  double _tabsChildAspectRatio(double screenWidth) {
    const double horizontalPadding = 20;
    const double crossAxisSpacing = 12;
    const int crossAxisCount = 2;

    final double gridW = screenWidth - (horizontalPadding * 2);
    final double itemW =
        (gridW - (crossAxisSpacing * (crossAxisCount - 1))) / crossAxisCount;

    const double targetH = 220;
    return itemW / targetH;
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = _isLoggedIn();

    // ✅ مهم: worldCards لازم تتعرّف هنا عشان _WorldCardsSelector تشوفها
    final List<_WorldCardData> worldCards = _getWorldCards(loggedIn);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double aspectRatio = _tabsChildAspectRatio(screenWidth);

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<WishItemsProvider>.value(
          value: _wishItemsProvider,
        ),
        ChangeNotifierProvider<CategoryProvider>(
          lazy: false,
          create: (BuildContext context) {
            _categoryProvider ??= CategoryProvider(
              repo: _repo1,
              psValueHolder: valueHolder,
              limit: valueHolder!.categoryLoadingLimit!,
            );

            _categoryProvider!
                .loadCategoryList(
              _categoryProvider!.categoryParameterHolder.toMap(),
              Utils.checkUserLoginId(_categoryProvider!.psValueHolder!),
            )
                .then((dynamic value) {
              final bool? isConnected = value is bool ? value : null;
              if (isConnected == false) {
                Fluttertoast.showToast(
                  msg: 'No Internet Connection. Please try again !',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.blueGrey,
                  textColor: Colors.white,
                );
              }
            });

            return _categoryProvider!;
          },
        ),
        ChangeNotifierProvider<RecentProductProvider>(
          lazy: false,
          create: (BuildContext context) {
            _recentProductProvider = RecentProductProvider(
              repo: _repo2,
              limit: valueHolder!.recentItemLoadingLimit!,
            );

            _recentProductProvider!.productRecentParameterHolder.mile =
                valueHolder!.mile;
            _recentProductProvider!.productRecentParameterHolder.itemLocationId =
                valueHolder!.locationId;
            _recentProductProvider!.productRecentParameterHolder.itemLocationName =
                valueHolder!.locactionName;

            if (valueHolder!.isSubLocation == PsConst.ONE) {
              _recentProductProvider!
                  .productRecentParameterHolder.itemLocationTownshipId =
                  valueHolder!.locationTownshipId;
              _recentProductProvider!
                  .productRecentParameterHolder.itemLocationTownshipName =
                  valueHolder!.locationTownshipName;
            }

            Utils.checkUserLoginId(valueHolder!);

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              _catId = '';
              await _reloadHomeSections();
            });

            return _recentProductProvider!;
          },
        ),
      ],
      child: TaapdeelScaffold(
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                if (!mounted) return;

                final String? loginUserId =
                Utils.checkUserLoginId(valueHolder!);

                _recentProductProvider!.resetProductList(
                  loginUserId,
                  _recentProductProvider!.productRecentParameterHolder,
                );

                await _categoryProvider!
                    .resetCategoryList(
                  _categoryProvider!.categoryParameterHolder.toMap(),
                  Utils.checkUserLoginId(_categoryProvider!.psValueHolder!),
                )
                    .then((dynamic value) {
                  final bool isConnectedToInternet = (value as bool?) ?? false;
                  if (!isConnectedToInternet) {
                    Fluttertoast.showToast(
                      msg: 'No Internet Connection. Please try again !',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blueGrey,
                      textColor: Colors.white,
                    );
                  }
                });

                await _reloadHomeSections();
              },
              child: CustomScrollView(
                controller: widget.scrollController,
                scrollDirection: Axis.vertical,
                slivers: <Widget>[
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  if (_viewMode == HomeSectionsViewMode.sections) ...[
                    PremiumSectionSliver(
                      title: Utils.getString(context, 'SpecialProducts'),
                      url: PsUrl.ps_premium_url,
                      catId: () => _catId,
                      recentProvider: () => _recentProductProvider!,
                    ),
                    if (loggedIn)
                      FamilySectionSliver(
                        title: Utils.getString(context, 'FamilyProducts'),
                        url: PsUrl.ps_family_network_items_url,
                        catId: () => _catId,
                        recentProvider: () => _recentProductProvider!,
                      ),
                    BrandsSectionSliver(
                      title: Utils.getString(context, 'Brands'),
                      url: PsUrl.ps_brands_url,
                      catId: () => _catId,
                      recentProvider: () => _recentProductProvider!,
                    ),
                    ExploreSectionSliver(
                      title: Utils.getString(context, 'Explore'),
                      url: PsUrl.ps_explore_url,
                      catId: () => _catId,
                      recentProvider: () => _recentProductProvider!,
                    ),
                    WishItemsSectionSliver(
                      title: 'حواديت تبديل',
                      itemLocationId: valueHolder?.locationId,
                      itemLocationTownshipId: valueHolder?.locationTownshipId,
                      catId: _catId,
                      onAddWishItem: _openAddWishItem,
                      onShareWishItem: _openWishProductShare,
                    )
                  ] else ...[
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _PinnedWorldCardsHeaderDelegate(
                        height: 168,
                        child: Container(
                          color: const Color(0xFFF7F9FB),
                          padding: const EdgeInsets.fromLTRB(0, 6, 5, 4),
                          child: _WorldCardsSelector(
                            controller: _worldCardsController,
                            cards: worldCards,
                            selectedKey: _chipsSelectedKey,
                            cardKeys: _worldCardKeys,
                            onSelect: (String key, String title, String url) {
                              _onChipSelected(key, title, url);
                            },
                          ),
                        ),
                      ),
                    ),
                    if (_chipsSelectedKey == 'wish')
                      WishItemsSectionSliver(
                        title: _chipsSelectedTitle,
                        showHeader: true,
                        childAspectRatio: aspectRatio,
                        itemLocationId: valueHolder?.locationId,
                        itemLocationTownshipId: valueHolder?.locationTownshipId,
                        catId: _catId,
                        onAddWishItem: _openAddWishItem,
                        onShareWishItem: _openWishProductShare,
                      )
                    else
                      BaseSectionGridSliver(
                        title: _chipsSelectedTitle,
                        url: _chipsSelectedUrl,
                        catId: () => _catId,
                        recentProvider: () => _recentProductProvider!,
                        showHeader: false,
                        childAspectRatio: aspectRatio,
                        leadingSubCategoryChip: _chipsSelectedKey == 'prefcat'
                            ? _EditInterestsButton(
                          onTap: _openEditInterests,
                        )
                            : null,
                        // ✅ الـ chips تظهر تلقائياً — showSubCategoryChips: true (default)
                        cardBuilder: ({
                          required BuildContext context,
                          required Product product,
                          required String coreTagKey,
                          required VoidCallback onTap,
                        }) {
                          switch (_chipsSelectedKey) {
                            case 'prefcat':
                              return _withShareButton(
                                product: product,
                                child: TaapdeelProductCardItem(
                                  coreTagKey: coreTagKey,
                                  product: product,
                                  onTap: onTap,
                                  variant: TaapdeelProductCardVariant.family,
                                  showRotatingBanner: true,
                                  showRelationPanel: true,
                                  showConditionChip: true,
                                  onTapFav: null,
                                  selectedFav: false,
                                ),
                              );

                            case 'explore':
                              return _withShareButton(
                                product: product,
                                child: TaapdeelProductCardItem(
                                  coreTagKey: coreTagKey,
                                  product: product,
                                  onTap: onTap,
                                  variant: TaapdeelProductCardVariant.deal,
                                  showRotatingBanner: true,
                                  showRelationPanel: false,
                                  showConditionChip: true,
                                  onTapFav: null,
                                  selectedFav: false,
                                ),
                              );

                            case 'brands':
                              return _withShareButton(
                                product: product,
                                child: TaapdeelProductCardItem(
                                  coreTagKey: coreTagKey,
                                  product: product,
                                  onTap: onTap,
                                  variant: TaapdeelProductCardVariant.deal,
                                  showRotatingBanner: true,
                                  showRelationPanel: false,
                                  showConditionChip: false,
                                  onTapFav: null,
                                  selectedFav: false,
                                ),
                              );

                            case 'family':
                              return _withShareButton(
                                product: product,
                                child: TaapdeelProductCardItem(
                                  coreTagKey: coreTagKey,
                                  product: product,
                                  onTap: onTap,
                                  variant: TaapdeelProductCardVariant.family,
                                  showRotatingBanner: true,
                                  showRelationPanel: true,
                                  showConditionChip: false,
                                  relationBackendCode: _getRelationCode(product),
                                  onTapFav: null,
                                  selectedFav: false,
                                ),
                              );

                            case 'free':
                              return _withShareButton(
                                product: product,
                                child: TaapdeelProductCardItem(
                                  coreTagKey: coreTagKey,
                                  product: product,
                                  onTap: onTap,
                                  variant: TaapdeelProductCardVariant.deal,
                                  showRotatingBanner: true,
                                  showRelationPanel: false,
                                  showConditionChip: false,
                                  onTapFav: null,
                                  selectedFav: false,
                                ),
                              );

                            case 'premium':
                            default:
                              return _withShareButton(
                                product: product,
                                child: TaapdeelProductCardItem(
                                  coreTagKey: coreTagKey,
                                  product: product,
                                  onTap: onTap,
                                  variant: TaapdeelProductCardVariant.deal,
                                  showRotatingBanner: true,
                                  showRelationPanel: false,
                                  showConditionChip: false,
                                  onTapFav: null,
                                  selectedFav: false,
                                ),
                              );
                          }
                        },
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  ],
                ],
              ),
            ),

            // ✅ FIX: ValueListenableBuilder بدل setState
            Positioned(
              left: 5,
              bottom: 20,
              child: SafeArea(
                top: false,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showScrollToTop,
                  builder: (_, show, child) {
                    return AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: show ? 1 : 0.0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: show ? 1 : 0.0,
                        child: child,
                      ),
                    );
                  },
                  child: Material(
                    color: Colors.white,
                    elevation: 10,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        widget.scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 26,
                          color: Colors.black.withAlpha(210),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _EditInterestsButton extends StatelessWidget {
  const _EditInterestsButton({required this.onTap});

  static const Color _kNavy = Color(0xFF043757);
  static const Color _kBlue = Color(0xFF0C587A);
  static const Color _kTeal = Color(0xFF24A9C4);
  static const Color _kwhite = Color(0xFFFFFFF);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            height: 34,
            padding: const EdgeInsetsDirectional.only(
              start: 9,
              end: 11,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: <Color>[_kNavy, _kNavy,_kNavy],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _kwhite,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'تعديل اهتماماتك',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1,
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

// =============================
// Helper classes — unchanged from original
// =============================

class _WorldCardData {
  const _WorldCardData({
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.icon,
    required this.gradient,
    required this.accent,
  });

  final String keyName;
  final String title;
  final String subtitle;
  final String url;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;
}

class _PinnedWorldCardsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedWorldCardsHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Material(
      color: const Color(0xFFF7F9FB),
      elevation: overlapsContent ? 6 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedWorldCardsHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _WorldCardsSelector extends StatelessWidget {
  const _WorldCardsSelector({
    required this.controller,
    required this.cards,
    required this.selectedKey,
    required this.cardKeys,
    required this.onSelect,
  });

  final ScrollController controller;
  final List<_WorldCardData> cards;
  final String selectedKey;
  final Map<String, GlobalKey> cardKeys;
  final void Function(String key, String title, String url) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withAlpha(230),
          width: 1.4,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 140,
        child: ListView.separated(
          controller: controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (BuildContext context, int index) {
            final _WorldCardData item = cards[index];
            final bool selected = item.keyName == selectedKey;

            return KeyedSubtree(
              key: cardKeys[item.keyName],
              child: _WorldCardItem(
                data: item,
                selected: selected,
                onTap: () => onSelect(
                  item.keyName,
                  item.title.replaceAll('\n', ' '),
                  item.url,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WorldCardItem extends StatelessWidget {
  const _WorldCardItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _WorldCardData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(22);

    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.0 : 0.94,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: selected ? 1.0 : 0.78,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 140,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: data.gradient,
            ),
            border: Border.all(
              color: selected ? Colors.white : Colors.white.withAlpha(70),
              width: selected ? 4 : 1.0,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: selected
                    ? data.accent.withAlpha(95)
                    : Colors.black.withAlpha(8),
                blurRadius: selected ? 18 : 6,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected
                    ? Colors.grey.withAlpha(210)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(selected ? 255 : 225),
                          border: Border.all(
                            color: selected
                                ? data.accent
                                : data.accent.withAlpha(60),
                            width: selected ? 2.2 : 1,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: data.accent.withAlpha(selected ? 55 : 25),
                              blurRadius: selected ? 14 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          data.icon,
                          color: data.accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          data.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: selected ? 5 : 3,
                        width: selected ? 52 : 20,
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white
                              : Colors.white.withAlpha(110),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// =============================
// Utility functions
// =============================

String? _getRelationCode(Product p) {
  try {
    final dynamic d = p;
    final String v = (d.relationCode ?? d.relation_code ?? '').toString().trim();
    return v.isEmpty ? null : v;
  } catch (_) {
    return null;
  }
}

