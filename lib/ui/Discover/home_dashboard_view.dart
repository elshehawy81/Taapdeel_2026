import 'dart:developer' as dev;
import 'package:taapdeel/utils/perf_benchmark.dart';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/category/category_provider.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import 'package:taapdeel/repository/Common/notification_repository.dart';
import 'package:taapdeel/repository/category_repository.dart';
import 'package:taapdeel/repository/item_location_repository.dart';
import 'package:taapdeel/repository/paid_ad_item_repository.dart';
import 'package:taapdeel/repository/product_repository.dart';

import 'package:taapdeel/ui/Discover/verticalview/wish_items_section_sliver.dart';
import 'package:taapdeel/ui/category/list/category_list_view.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/utils/taapdeel_share_links.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/item_entry_intent_holder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../api/ps_url.dart';
import '../../../db/common/ps_shared_preferences.dart';
import '../../../viewobject/product.dart';
import '../../../viewobject/category.dart';
import '../Contacts/contact_network_bottom_sheet.dart';
import '../Contacts/search_provider.dart';
import '../Product/product_widget.dart';
import '../category/category_personalization.dart';
import '../item/share_theme/product_share_options.dart';
import '../common/taapdeel/taapdeel_scaffold.dart';
import '../wish_Items/wish_item_entry_container_view.dart';
import '../wish_Items/wish_product_share_options.dart';
import 'base_section_grid_sliver.dart';



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

  String _chipsSelectedKey = 'explore';
  String _chipsSelectedTitle = 'الأحدث';
  String _chipsSelectedUrl = PsUrl.ps_explore_url;

  final int count = 20;

  final TextEditingController userInputItemNameTextEditingController =
  TextEditingController();
  final TextEditingController useraddressTextEditingController =
  TextEditingController();

  // ignore: unused_field
  String _authStatus = 'Unknown';
  String _catId = '';

  String _exploreSelectedCatId = '';
  List<Category> _exploreCategoriesWithProducts = <Category>[];
  int _exploreCategoriesProbeToken = 0;

  String _brandsSelectedCatId = '';
  List<Category> _brandsCategoriesWithProducts = <Category>[];
  int _brandsCategoriesProbeToken = 0;

  bool _depsReady = false;
  int _homeReloadSerial = 0;

  // ✅ FIX: ValueNotifier بدل setState لمنع rebuild الصفحة كلها عند الـ scroll
  final ValueNotifier<bool> _showScrollToTop = ValueNotifier<bool>(false);
  static const double _scrollToTopThreshold = 450.0;

  HomeSectionsViewMode _viewMode = HomeSectionsViewMode.chips;

  final ScrollController _worldCardsController = ScrollController();
  final WishItemsProvider _wishItemsProvider = WishItemsProvider();

  final Map<String, GlobalKey> _worldCardKeys = <String, GlobalKey>{
    'family': GlobalKey(),
    'premium': GlobalKey(),
    'brands': GlobalKey(),
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
      keyName: 'explore',
      title: 'الأحدث',
      subtitle: 'أحدث الإضافات',
      url: PsUrl.ps_explore_url,
      icon: Icons.rocket_launch_rounded,
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
      keyName: 'brands',
      title: 'براندز',
      subtitle: 'علامات عالمية',
      url: PsUrl.ps_brands_url,
      icon: Icons.verified_rounded,
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
        Color(0xFF5B21B6),
        Color(0xFFFF6B9A),
      ],
      accent: Color(0xFFFFD166),
    ),
  ];

  List<_WorldCardData> _buildWorldCards(bool loggedIn) {
    if (!loggedIn) return _guestWorldCards;

    return const <_WorldCardData>[
      _WorldCardData(
        keyName: 'explore',
        title: 'الأحدث',
        subtitle: 'أحدث الإضافات',
        url: PsUrl.ps_explore_url,
        icon: Icons.rocket_launch_rounded,
        gradient: <Color>[Color(0xFFB8F4FF), Color(0xFF0A7EA0)],
        accent: Color(0xFF0C587A),
      ),
      _WorldCardData(
        keyName: 'family',
        title: 'العائلة والأصدقاء',
        subtitle: 'الاكثر ثقة',
        url: PsUrl.ps_family_network_items_url,
        icon: Icons.diversity_3_rounded,
        gradient: <Color>[Color(0xFF4FACFE), Color(0xFF00F2FE)],
        accent: Color(0xFF011934),
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
        keyName: 'brands',
        title: 'براندز',
        subtitle: 'علامات عالمية',
        url: PsUrl.ps_brands_url,
        icon: Icons.verified_rounded,
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
          Color(0xFF5B21B6),
          Color(0xFFFF6B9A),
        ],
        accent: Color(0xFFFFD166),
      ),
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
    bool valid(dynamic value) {
      final String s = (value ?? '').toString().trim().toLowerCase();
      return s.isNotEmpty &&
          s != 'null' &&
          s != '0' &&
          s != 'nologinuser' &&
          s != 'no_login_user';
    }

    if (valid(
      PsSharedPreferences.instance.shared
          .getString(PsConst.VALUE_HOLDER__USER_ID),
    )) {
      return true;
    }

    try {
      final dynamic holder = valueHolder;
      return valid(holder?.loginUserId) ||
          valid(holder?.userId) ||
          valid(holder?.user?.userId) ||
          valid(holder?.user?.id);
    } catch (_) {
      return false;
    }
  }

  void _onChipSelected(String key, String title, String url) {
    // ✅ BENCHMARK: وقت استجابة اختيار تاب جديد (setState + API load)
    TaapdeelPerfBenchmark.start('chip_select_$key');

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
          .then((_) => TaapdeelPerfBenchmark.end('chip_select_$key'))
          .catchError((Object _) {
        TaapdeelPerfBenchmark.end('chip_select_$key');
      });
    } else {
      final bool loading = sp.sectionLoading(_chipsSelectedUrl);
      final List<Product> items = sp.sectionProducts(_chipsSelectedUrl);

      if (!loading && items.isEmpty) {
        sp.loadSection(
          filterUrl: _chipsSelectedUrl,
          catId: _activeProductCatId(),
          pageSize: 20,
        ).then((_) {
          TaapdeelPerfBenchmark.end('chip_select_$key');
        }).catchError((e, st) {
          TaapdeelPerfBenchmark.end('chip_select_$key');
        });
      } else {
        // already cached — tab switch is instant
        TaapdeelPerfBenchmark.end('chip_select_$key');
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
      setState(() {
        _chipsSelectedKey = 'explore';
        _chipsSelectedTitle = 'الاحدث';
        _chipsSelectedUrl = PsUrl.ps_explore_url;
      });
      await _reloadHomeSections();
    }
  }



  Future<void> _openContactNetworkSheet() async {
    if (!mounted) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await ContactNetworkBottomSheet.show(context);

    if (!mounted) return;

    // بعد إغلاق الـ Bottom Sheet نعيد تحميل قائمة العائلة والأصدقاء
    // عشان لو المستخدم أضاف علاقات جديدة تظهر المنتجات بدون ما يقفل الهوم.
    if (_chipsSelectedKey == 'family') {
      await SearchProvider.of(context, listen: false).loadSection(
        filterUrl: PsUrl.ps_family_network_items_url,
        catId: '',
        pageSize: 20,
      );
    }
  }

  String _activeProductCatId() {
    if (_chipsSelectedKey == 'explore') {
      return _exploreSelectedCatId;
    }

    if (_chipsSelectedKey == 'brands') {
      return _brandsSelectedCatId;
    }

    return _catId;
  }

  String _readUserGender() {
    try {
      final dynamic v = (valueHolder as dynamic).userGender;
      if (v is String) return v.trim();
    } catch (_) {}
    return '';
  }

  String _readUserAgeRange() {
    try {
      final dynamic v = (valueHolder as dynamic).userAgeRange;
      if (v is String) return v.trim();
    } catch (_) {}
    return '';
  }

  List<BaseSectionCategoryChip> _exploreCategoryChips() {
    return _exploreCategoriesWithProducts
        .map((Category category) {
      final String id = (category.catId ?? '').toString().trim();
      final String name = (category.catName ?? '').toString().trim();
      if (id.isEmpty || name.isEmpty) return null;
      return BaseSectionCategoryChip(id: id, name: name);
    })
        .whereType<BaseSectionCategoryChip>()
        .toList();
  }

  List<BaseSectionCategoryChip> _brandsCategoryChips() {
    return _brandsCategoriesWithProducts
        .map((Category category) {
      final String id = (category.catId ?? '').toString().trim();
      final String name = (category.catName ?? '').toString().trim();
      if (id.isEmpty || name.isEmpty) return null;
      return BaseSectionCategoryChip(id: id, name: name);
    })
        .whereType<BaseSectionCategoryChip>()
        .toList();
  }

  List<Category> _sortedMainCategoriesForExplore() {
    final List<Category> categories = List<Category>.from(
      _categoryProvider?.categoryList.data ?? <Category>[],
    );

    categories.removeWhere((Category category) {
      final String id = (category.catId ?? '').toString().trim();
      final String name = (category.catName ?? '').toString().trim();
      return id.isEmpty || id == '0' || name.isEmpty;
    });

    sortCategoriesByProfile(
      categories: categories,
      gender: _readUserGender(),
      ageRange: _readUserAgeRange(),
    );

    return categories;
  }

  Future<void> _refreshExploreCategoryChips() async {
    if (!mounted) return;
    if (_categoryProvider == null) return;

    final List<Category> sortedCategories = _sortedMainCategoriesForExplore();
    final int token = ++_exploreCategoriesProbeToken;

    // PERF + UX: لا نفحص كل category بـ API منفصل.
    // اللوج الأخير أظهر أكثر من 10 probe requests بالتوازي وبعضها يعمل timeout،
    // وهذا أخفى تصنيفات بها منتجات مثل الألعاب. لذلك نعرض كل التصنيفات
    // المرتبة، والفلترة الحقيقية تحصل عند اختيار المستخدم للتصنيف.
    TaapdeelPerfBenchmark.start('probe_explore_cats');

    if (!mounted || token != _exploreCategoriesProbeToken) {
      TaapdeelPerfBenchmark.end('probe_explore_cats');
      return;
    }

    TaapdeelPerfBenchmark.end('probe_explore_cats');

    setState(() {
      _exploreCategoriesWithProducts = sortedCategories;

      // Explore يبدأ دائمًا بـ Chip "الكل". لا نختار أول تصنيف تلقائيًا.
      if (_exploreSelectedCatId.isNotEmpty &&
          !sortedCategories.any(
                (Category c) =>
            (c.catId ?? '').toString().trim() == _exploreSelectedCatId,
          )) {
        _exploreSelectedCatId = '';
      }
    });
  }


  Future<void> _refreshBrandsCategoryChips() async {
    if (!mounted) return;
    if (_categoryProvider == null) return;

    final List<Category> sortedCategories = _sortedMainCategoriesForExplore();
    final int token = ++_brandsCategoriesProbeToken;

    // نفس مبدأ Explore: لا نعمل probe لكل category لأن هذا يسبب burst كبير
    // وtimeouts متقطعة. نعرض التصنيفات، والـ section نفسه يحدد النتائج عند الاختيار.
    if (!mounted || token != _brandsCategoriesProbeToken) return;

    setState(() {
      _brandsCategoriesWithProducts = sortedCategories;

      if (_brandsSelectedCatId.isNotEmpty &&
          !sortedCategories.any(
                (Category c) =>
            (c.catId ?? '').toString().trim() == _brandsSelectedCatId,
          )) {
        _brandsSelectedCatId = '';
      }
    });
  }

  Future<void> _onExploreCategorySelected(String catId) async {
    final String cleanCatId = catId.trim();
    final SearchProvider sp = SearchProvider.of(context, listen: false);

    if (_exploreSelectedCatId == cleanCatId &&
        !sp.sectionLoading(PsUrl.ps_explore_url)) {
      return;
    }

    setState(() {
      _exploreSelectedCatId = cleanCatId;
      _chipsSelectedKey = 'explore';
      _chipsSelectedTitle = 'الأحدث';
      _chipsSelectedUrl = PsUrl.ps_explore_url;
    });

    // ✅ مهم: امسح نتائج الأحدث القديمة عشان اختيار الـ category يجيب صفحة جديدة من السيرفر.
    sp.clearSection(PsUrl.ps_explore_url);

    await sp.loadSection(
      filterUrl: PsUrl.ps_explore_url,
      catId: cleanCatId,
      pageSize: 20,
    );

    // ✅ ارجع لأول القائمة بعد تغيير الـ category، لكن بعد نزول البيانات لتجنب مشاكل extent.
    if (mounted && widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }


  Future<void> _onBrandsCategorySelected(String catId) async {
    final String cleanCatId = catId.trim();
    final SearchProvider sp = SearchProvider.of(context, listen: false);

    if (_brandsSelectedCatId == cleanCatId &&
        !sp.sectionLoading(PsUrl.ps_brands_url)) {
      return;
    }

    setState(() {
      _brandsSelectedCatId = cleanCatId;
      _chipsSelectedKey = 'brands';
      _chipsSelectedTitle = 'براندز';
      _chipsSelectedUrl = PsUrl.ps_brands_url;
    });

    // مهم: امسح نتائج براندز القديمة عشان اختيار الـ category يجيب صفحة جديدة من السيرفر.
    sp.clearSection(PsUrl.ps_brands_url);

    await sp.loadSection(
      filterUrl: PsUrl.ps_brands_url,
      catId: cleanCatId,
      pageSize: 20,
    );

    if (mounted && widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<bool> _openLoginBeforeWishAction() async {
    if (_isLoggedIn()) return true;
    if (!mounted) return false;

    Fluttertoast.showToast(
      msg: 'سجل الدخول أولًا لإكمال الخطوة',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blueGrey,
      textColor: Colors.white,
    );

    try {
      await Navigator.of(context).pushNamed<dynamic>(RoutePaths.login_container);
    } catch (_) {
      if (!mounted) return false;
      Fluttertoast.showToast(
        msg: 'لم يتم فتح صفحة تسجيل الدخول',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
      );
      return false;
    }

    if (!mounted) return false;

    // بعض شاشات اللوجين تحدث SharedPreferences/ValueHolder بعد pop مباشرة.
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return false;

    final bool loggedInNow = _isLoggedIn();
    if (loggedInNow) {
      setState(() {
        _cachedWorldCards = null;
        _cachedLoggedIn = null;
      });
    }

    return loggedInNow;
  }

  Future<void> _openAddWishItem() async {
    if (!mounted) return;

    final bool canContinue = await _openLoginBeforeWishAction();
    if (!mounted || !canContinue) return;

    await _openAddWishItemFlow();
  }

  Future<void> _openAddWishItemFlow() async {
    if (!mounted) return;

    Object? result;
    bool opened = false;

    try {
      result = await Navigator.of(context).pushNamed<dynamic>(
        RoutePaths.wishItemEntry,
      );
      opened = true;
    } catch (_) {
      try {
        result = await Navigator.of(context).push<dynamic>(
          MaterialPageRoute<dynamic>(
            builder: (_) => WishItemEntryContainerView(
              flag: PsConst.ADD_NEW_ITEM,
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

  Future<void> _openAddProductItem() async {
    if (!mounted) return;

    final bool canContinue = await _openLoginBeforeWishAction();
    if (!mounted || !canContinue) return;

    try {
      await Navigator.of(context).pushNamed<dynamic>(
        RoutePaths.itemEntry,
        arguments: ItemEntryIntentHolder(
          flag: PsConst.ADD_NEW_ITEM,
          item: null,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'لم يتم فتح شاشة إضافة المنتج',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
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
    final int reloadSerial = ++_homeReloadSerial;
    final SearchProvider sp = SearchProvider.of(context, listen: false);
    final bool logged = _isLoggedIn();

    TaapdeelPerfBenchmark.start('home_sections_load');

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
          catId: _activeProductCatId(),
          pageSize: 20,
        );
      }

      if (!mounted || reloadSerial != _homeReloadSerial) {
        TaapdeelPerfBenchmark.end('home_sections_load');
        return;
      }

      // حمّل السيكشن الأساسي أولاً، ثم حمّل باقي السيكشنات بالتدريج في الخلفية.
      sp.preloadOtherSections(
        currentUrl: _chipsSelectedUrl,
        catId: '',
        isLoggedIn: logged,
        pageSize: 20,
      );

      TaapdeelPerfBenchmark.end('home_sections_load');
      TaapdeelPerfBenchmark.printReport();
    } catch (e, st) {
      TaapdeelPerfBenchmark.end('home_sections_load');
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

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _refreshExploreCategoryChips();
                _refreshBrandsCategoryChips();
              });
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
                      onAddWishItem: () {
                        _openAddWishItem();
                      },
                      onAddProductItem: () {
                        _openAddProductItem();
                      },
                      onShareWishItem: _openWishProductShare,
                    )
                  else
                    BaseSectionGridSliver(
                      title: _chipsSelectedTitle,
                      url: _chipsSelectedUrl,
                      catId: () => _activeProductCatId(),
                      recentProvider: () => _recentProductProvider!,
                      showHeader: false,
                      childAspectRatio: aspectRatio,
                      loadMorePageSize: 20,
                      scrollController: widget.scrollController,
                      showAllCategoryChip: true,
                      categoryChips: _chipsSelectedKey == 'explore'
                          ? _exploreCategoryChips()
                          : _chipsSelectedKey == 'brands'
                          ? _brandsCategoryChips()
                          : null,
                      selectedCategoryChipId: _chipsSelectedKey == 'explore'
                          ? _exploreSelectedCatId
                          : _chipsSelectedKey == 'brands'
                          ? _brandsSelectedCatId
                          : null,
                      onCategoryChipSelected: _chipsSelectedKey == 'explore'
                          ? _onExploreCategorySelected
                          : _chipsSelectedKey == 'brands'
                          ? _onBrandsCategorySelected
                          : null,
                      // ✅ في تاب الأحدث وبراندز التصنيفات تأتي من CategoryProvider مرتبة حسب السن والنوع،
                      // وChip "الكل" يحمّل أحدث المنتجات بدون cat_id.
                      cardBuilder: ({
                        required BuildContext context,
                        required Product product,
                        required String coreTagKey,
                        required VoidCallback onTap,
                      }) {
                        switch (_chipsSelectedKey) {
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
                                relationType: _getRelationType(product),
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
                  if (_chipsSelectedKey == 'family')
                    Consumer<SearchProvider>(
                      builder: (BuildContext context, SearchProvider sp, _) {
                        final bool shouldShowInvite =
                            sp.sectionRequested(PsUrl.ps_family_network_items_url) &&
                                !sp.sectionLoading(PsUrl.ps_family_network_items_url) &&
                                sp.sectionProducts(PsUrl.ps_family_network_items_url).isEmpty;

                        if (!shouldShowInvite) {
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        }

                        return SliverToBoxAdapter(
                          child: _FamilyNetworkEmptyInviteCard(
                            onTap: _openContactNetworkSheet,
                          ),
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

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



class _FamilyNetworkEmptyInviteCard extends StatelessWidget {
  const _FamilyNetworkEmptyInviteCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[
                Color(0xFFFFFFFF),
                Color(0xFFEFFBFF),
                Color(0xFFE8F3FF),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFBFEAF0),
              width: 1.2,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x160A7EA0),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: <Color>[
                          Color(0xFF4FACFE),
                          Color(0xFF00F2FE),
                        ],
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x334FACFE),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.diversity_3_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'أضف أصحابك وأقاربك لعرض منتجاتهم وفرص تبديل أوثق.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF5F7480),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onTap,
                  child: Ink(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: <Color>[
                          Color(0xFF63CAD6),
                          Color(0xFF007D98),
                          Color(0xFF06365E),
                        ],
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x33007D98),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.person_search_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'اكتشف منتجات أصدقاءك وأقاربك',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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

    // ✅ PERF FIX: بدل 4 animated widgets متداخلة (AnimatedScale → AnimatedOpacity → AnimatedContainer → Container)
    // دلوقتي 2 فقط: AnimatedScale + AnimatedContainer واحد يغطي كل الـ decoration
    // - حذف AnimatedOpacity: الـ scale بيعطي نفس الـ visual cue بدونها
    // - دمج inner Container (كان بيضيف selected border منفصل) في outer AnimatedContainer
    // النتيجة: -50% في عدد الـ animated widgets في الـ world cards bar
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.0 : 0.94,
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
          // ✅ inner Container's selected border متدمج هنا
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

int? _getRelationType(Product p) {
  String clean(dynamic value) {
    final String text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  try {
    final String rawType = clean(p.relationType);
    final int? parsed = int.tryParse(rawType);
    if (parsed != null && parsed > 0) return parsed;
  } catch (_) {}

  return null;
}

