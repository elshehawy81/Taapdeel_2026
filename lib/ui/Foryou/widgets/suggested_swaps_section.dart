import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/category/list/category_list_view.dart';
import 'package:taapdeel/ui/Contacts/contact_network_bottom_sheet.dart';
import 'package:taapdeel/ui/Contacts/contact_network_provider.dart';
import 'package:provider/provider.dart';

import '../../Product/product_widget.dart';
import '../widgets/swap_rating.dart';
import '../widgets/swap_consult_share_sheet.dart';

import '../../../../../api/ps_url.dart';
import '../../../../../constant/ps_constants.dart';
import '../../../../../constant/route_paths.dart';
import '../../../../../viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import '../../../../../viewobject/product.dart';

import '../home_provider.dart';

final ValueNotifier<Set<String>> suggestedSwapHiddenRequestedIdsNotifier =
ValueNotifier<Set<String>>(<String>{});

String _safeProductId(Product? product) {
  return (product?.id ?? '').toString().trim();
}

void hideSuggestedSwapAfterRequest(Product? product) {
  final String id = _safeProductId(product);
  if (id.isEmpty) return;

  final Set<String> updatedIds = Set<String>.from(
    suggestedSwapHiddenRequestedIdsNotifier.value,
  )..add(id);

  suggestedSwapHiddenRequestedIdsNotifier.value = updatedIds;
}

void showSwapRequestSentSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
        duration: const Duration(seconds: 5),
        backgroundColor: const Color(0xFF073B5A),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        content: const Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF67E8F9),
                size: 26,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تم إرسال طلب التبديل بنجاح ✅\nيمكنك متابعة حالة الطلب من قائمة التبديلات.',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

void notifySuggestedSwapRequestSent({
  required BuildContext context,
  required Product? requestedProduct,
}) {
  hideSuggestedSwapAfterRequest(requestedProduct);
  showSwapRequestSentSnackBar(context);
}

String? _getRelationCode(Product p) {
  try {
    final String typed = (p.relationCode ?? '').toString().trim();
    if (typed.isNotEmpty && typed.toLowerCase() != 'null') return typed;

    final d = p as dynamic;
    final v = (d.relation_code ?? d.relationCode ?? '').toString().trim();
    return v.isEmpty || v.toLowerCase() == 'null' ? null : v;
  } catch (_) {
    return null;
  }
}

enum _SuggestedSwapInterestTab {
  self,
  family,
  other,
}

class SectionPalette {
  const SectionPalette({
    required this.gradient,
    required this.softBackground,
    required this.accent,
  });

  final List<Color> gradient;
  final Color softBackground;
  final Color accent;
}

SectionPalette _paletteForSuggestedSwapTab(_SuggestedSwapInterestTab tab) {
  switch (tab) {
    case _SuggestedSwapInterestTab.self:
      return const SectionPalette(
        gradient: <Color>[
          Color(0xFFB8F4FF),
          Color(0xFF0A7EA0),
          Color(0xFF055A76),
        ],
        softBackground: Color(0xFFEFFBFD),
        accent: Color(0xFF055A76),
      );

    case _SuggestedSwapInterestTab.family:
      return const SectionPalette(
        gradient: <Color>[
          Color(0xFF4FACFE),
          Color(0xFF00F2FE),
        ],
        softBackground: Color(0xFFEFF6FF),
        accent: Color(0xFF011934),
      );

    case _SuggestedSwapInterestTab.other:
      return const SectionPalette(
        gradient: <Color>[
          Color(0xFFFF6A6A),
          Color(0xFFFF8E8E),
        ],
        softBackground: Color(0xFFFFF1F1),
        accent: Color(0xFF7A2430),
      );
  }
}

IconData _iconForSuggestedSwapTab(_SuggestedSwapInterestTab tab) {
  switch (tab) {
    case _SuggestedSwapInterestTab.family:
      return Icons.diversity_3_rounded;
    case _SuggestedSwapInterestTab.self:
      return Icons.explore_rounded;
    case _SuggestedSwapInterestTab.other:
      return Icons.rocket_launch_rounded;
  }
}


String _compactTitleForSuggestedSwapTab(_SuggestedSwapTabMeta meta) {
  switch (meta.tab) {
    case _SuggestedSwapInterestTab.self:
      return 'ترشيحات مناسبة لاهتماماتك';
    case _SuggestedSwapInterestTab.family:
      return 'ترشيحات مناسبة لعائلتك';
    case _SuggestedSwapInterestTab.other:
      return 'ترشيحات \nمن اقارب واصدقاء';
  }
}

class _SuggestedSwapTabMeta {
  const _SuggestedSwapTabMeta({
    required this.tab,
    required this.label,
    required this.items,
  });

  final _SuggestedSwapInterestTab tab;
  final String label;
  final List<Product> items;
}

class SuggestedSwapsSection extends StatefulWidget {
  const SuggestedSwapsSection({
    Key? key,
    required this.homeProvider,
  }) : super(key: key);

  final HomeProvider homeProvider;

  @override
  State<SuggestedSwapsSection> createState() => SuggestedSwapsSectionState();
}

class SuggestedSwapsSectionState extends State<SuggestedSwapsSection> {
  late final PageController _pageController;

  int _currentIndex = 0;
  bool _didInitSync = false;
  bool _didAutoSelectLastMyProduct = false;
  _SuggestedSwapInterestTab? _selectedTab;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    suggestedSwapHiddenRequestedIdsNotifier.addListener(
      _handleHiddenRequestedSuggestionsChanged,
    );
  }

  @override
  void dispose() {
    suggestedSwapHiddenRequestedIdsNotifier.removeListener(
      _handleHiddenRequestedSuggestionsChanged,
    );
    _pageController.dispose();
    super.dispose();
  }

  void _handleHiddenRequestedSuggestionsChanged() {
    if (!mounted) return;

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
    });
  }

  List<Product> _removeRequestedSuggestions(List<Product> products) {
    final Set<String> hiddenIds = suggestedSwapHiddenRequestedIdsNotifier.value;
    if (hiddenIds.isEmpty) return products;

    return products.where((Product p) {
      final String id = _safeProductId(p);
      return id.isNotEmpty && !hiddenIds.contains(id);
    }).toList(growable: false);
  }

  void markSwapRequestSent(Product? requestedProduct) {
    hideSuggestedSwapAfterRequest(requestedProduct);

    if (!mounted) return;
    showSwapRequestSentSnackBar(context);
  }

  String _interestTypeOf(Product p) {
    try {
      final dynamic d = p as dynamic;

      final String direct =
      (d.interestMatchType ?? '').toString().trim().toLowerCase();
      if (direct.isNotEmpty && direct != 'null') return direct;

      final String snake =
      (d.interest_match_type ?? '').toString().trim().toLowerCase();
      if (snake.isNotEmpty && snake != 'null') return snake;

      return 'none';
    } catch (_) {
      return 'none';
    }
  }

  List<Product> _filterProductsByTab(
      List<Product> products,
      _SuggestedSwapInterestTab tab,
      ) {
    return products.where((Product p) {
      final String type = _interestTypeOf(p);

      switch (tab) {
        case _SuggestedSwapInterestTab.self:
          return type == 'self';

        case _SuggestedSwapInterestTab.family:
          return type == 'family';

        case _SuggestedSwapInterestTab.other:
          return type != 'self' && type != 'family';
      }
    }).toList();
  }

  List<_SuggestedSwapTabMeta> _buildTabs(List<Product> allProducts) {
    final List<Product> selfItems = _filterProductsByTab(
      allProducts,
      _SuggestedSwapInterestTab.self,
    );
    final List<Product> familyItems = _filterProductsByTab(
      allProducts,
      _SuggestedSwapInterestTab.family,
    );
    final List<Product> otherItems = _filterProductsByTab(
      allProducts,
      _SuggestedSwapInterestTab.other,
    );

    final List<_SuggestedSwapTabMeta> tabs = <_SuggestedSwapTabMeta>[];

    if (selfItems.isNotEmpty) {
      tabs.add(
        _SuggestedSwapTabMeta(
          tab: _SuggestedSwapInterestTab.self,
          label: 'مناسب لاهتماماتك',
          items: selfItems,
        ),
      );
    }
    if (familyItems.isNotEmpty) {
      tabs.add(
        _SuggestedSwapTabMeta(
          tab: _SuggestedSwapInterestTab.family,
          label: 'مناسب لعائلتك',
          items: familyItems,
        ),
      );
    }
    if (otherItems.isNotEmpty) {
      tabs.add(
        _SuggestedSwapTabMeta(
          tab: _SuggestedSwapInterestTab.other,
          label: 'تصنيفات اخري',
          items: otherItems,
        ),
      );
    }





    return tabs;
  }

  _SuggestedSwapInterestTab? _resolveSelectedTab(
      List<_SuggestedSwapTabMeta> tabs,
      ) {
    if (tabs.isEmpty) return null;

    if (_selectedTab != null) {
      final bool exists = tabs.any((e) => e.tab == _selectedTab);
      if (exists) return _selectedTab;
    }

    for (final _SuggestedSwapTabMeta meta in tabs) {
      if (meta.tab == _SuggestedSwapInterestTab.self) {
        return meta.tab;
      }
    }

    return tabs.first.tab;
  }

  List<Product> _productsForSelectedTab(
      List<_SuggestedSwapTabMeta> tabs,
      _SuggestedSwapInterestTab? selectedTab,
      ) {
    if (tabs.isEmpty || selectedTab == null) return <Product>[];

    final _SuggestedSwapTabMeta? meta = tabs.cast<_SuggestedSwapTabMeta?>().firstWhere(
          (_SuggestedSwapTabMeta? e) => e?.tab == selectedTab,
      orElse: () => null,
    );

    return meta?.items ?? <Product>[];
  }

  void _syncSelectedSwapFromVisible(
      HomeProvider home,
      List<Product> visibleProducts,
      int index, {
        bool animate = false,
      }) {
    if (visibleProducts.isEmpty) return;
    if (index < 0 || index >= visibleProducts.length) return;

    final Product p = visibleProducts[index];

    if (home.selectedSwapProduct?.id != p.id) {
      home.setSelectedSwapProduct(p);
    }

    if (_currentIndex != index && mounted) {
      setState(() => _currentIndex = index);
    }

    if (animate && _pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _jumpToCurrentIndexIfPossible() {
    if (!_pageController.hasClients) return;
    try {
      _pageController.jumpToPage(_currentIndex);
    } catch (_) {}
  }

  void _changeTab(
      HomeProvider home,
      _SuggestedSwapInterestTab newTab,
      List<_SuggestedSwapTabMeta> tabs,
      ) {
    final List<Product> newVisibleProducts = _productsForSelectedTab(tabs, newTab);
    if (newVisibleProducts.isEmpty) return;

    setState(() {
      _selectedTab = newTab;
      _currentIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncSelectedSwapFromVisible(home, newVisibleProducts, 0);
      _jumpToCurrentIndexIfPossible();
    });
  }

  void _goNext(HomeProvider home, List<Product> visibleProducts) {
    if (_currentIndex >= visibleProducts.length - 1) return;
    _syncSelectedSwapFromVisible(
      home,
      visibleProducts,
      _currentIndex + 1,
      animate: true,
    );
  }

  void _goPrev(HomeProvider home, List<Product> visibleProducts) {
    if (_currentIndex <= 0) return;
    _syncSelectedSwapFromVisible(
      home,
      visibleProducts,
      _currentIndex - 1,
      animate: true,
    );
  }

  InlineSwapVM _buildVm(Product p) {
    final int percent =
        int.tryParse((p.swapScorePercent ?? '').toString().trim()) ?? 0;
    final breakdown = castSwapBreakdown(p.swapScoreBreakdown);
    return buildInlineSwapVM(percent: percent, breakdown: breakdown);
  }

  int? _parsePositiveIntValue(String? value) {
    final String v = (value ?? '').trim();
    final int? parsed = int.tryParse(v);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  num _resolveProductValue(Product p) {
    final int? low = _parsePositiveIntValue(p.lowPrice);
    final int? high = _parsePositiveIntValue(p.highPrice);
    final int? price = _parsePositiveIntValue(p.price);

    if (low != null && high != null) return (low + high) / 2;
    if (price != null) return price;
    if (high != null) return high;
    if (low != null) return low;

    return 0;
  }

  num _totalProductsValue(List<Product> products) {
    num total = 0;
    for (final Product product in products) {
      total += _resolveProductValue(product);
    }
    return total;
  }

  String _formatMoneyValue(num value) {
    if (value >= 1000000) {
      final num v = value / 1000000;
      final String text =
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
      return '$text مليون جنيه';
    }

    if (value >= 1000) {
      final num v = value / 1000;
      final String text =
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
      return '$text ألف جنيه';
    }

    return '${value.toStringAsFixed(0)} جنيه';
  }

  String _resolveSuggestedProductName(Product? p) {
    if (p == null) return '';

    try {
      final dynamic d = p;
      final List<String> candidates = <String>[
        (d.title ?? '').toString().trim(),
        (d.name ?? '').toString().trim(),
        (d.itemTitle ?? '').toString().trim(),
        (d.item_title ?? '').toString().trim(),
      ];

      for (final String value in candidates) {
        if (value.isNotEmpty && value.toLowerCase() != 'null') {
          return value;
        }
      }
    } catch (_) {}

    return '';
  }

  String _currentVisibleProductName(List<Product> visibleProducts) {
    if (visibleProducts.isEmpty) return '';

    final int safeIndex = _currentIndex < 0
        ? 0
        : (_currentIndex >= visibleProducts.length
        ? visibleProducts.length - 1
        : _currentIndex);

    return _resolveSuggestedProductName(visibleProducts[safeIndex]);
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
      final HomeProvider home = context.read<HomeProvider>();

      setState(() {
        _selectedTab = _SuggestedSwapInterestTab.self;
        _currentIndex = 0;
        _didInitSync = false;
      });

      if (home.myItemId.trim().isNotEmpty) {
        await home.topRecProduct(PsUrl.ps_top_recom_url);
      }
    }
  }

  Future<void> _openRecommendationNetworkSheet() async {
    if (!mounted) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await ContactNetworkBottomSheet.show(context);

    if (!mounted) return;

    final HomeProvider home = context.read<HomeProvider>();
    if (home.myItemId.trim().isEmpty) return;

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
      _selectedTab = null;
    });

    await home.topRecProduct(PsUrl.ps_top_recom_url);
  }

  void _openProductDetails(BuildContext context, Product p) {
    if (p.id == null) return;

    final holder = ProductDetailIntentHolder(
      productId: p.id!,
      heroTagImage: '${p.hashCode}${p.id}${PsConst.HERO_TAG__IMAGE}',
      heroTagTitle: '${p.hashCode}${p.id}${PsConst.HERO_TAG__TITLE}',
    );

    Navigator.pushNamed(
      context,
      RoutePaths.productDetail,
      arguments: holder,
    );
  }


  Future<void> _autoSelectLastMyProductIfNeeded(HomeProvider home) async {
    if (_didAutoSelectLastMyProduct) return;
    if (home.myProducts.isEmpty) return;

    // ✅ مهم: لو المستخدم اختار منتج بالفعل من الـ Bottom Sheet
    // لا نرجع نغيّره تلقائيًا لآخر منتج.
    final String currentProductId =
    (home.myProduct?.id ?? '').toString().trim();
    if (currentProductId.isNotEmpty) {
      _didAutoSelectLastMyProduct = true;
      return;
    }

    // آخر منتج في قائمة منتجات المستخدم هو الذي سيتم اختياره تلقائيًا.
    final Product lastProduct = home.myProducts.last;
    final String lastProductId = (lastProduct.id ?? '').toString().trim();
    if (lastProductId.isEmpty) return;

    _didAutoSelectLastMyProduct = true;

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
      _selectedTab = null;
    });

    await home.setSelectedMyProduct(
      lastProduct,
      fetchRecommendations: true,
    );
  }


  Future<void> _openMyProductsBottomSheet(HomeProvider home) async {
    if (!mounted) return;

    final List<Product> products = home.myProducts;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF073B5A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: const Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'لا يوجد منتجات أخرى للاختيار منها.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      return;
    }

    final Product? selected = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _MyProductChangeBottomSheet(
          products: products,
          selectedProductId: home.myProduct?.id,
          totalValueText: _formatMoneyValue(_totalProductsValue(products)),
        );
      },
    );

    if (!mounted || selected == null) return;

    final String selectedId = (selected.id ?? '').toString().trim();
    final String currentId = (home.myProduct?.id ?? '').toString().trim();

    if (selectedId.isEmpty || selectedId == currentId) return;

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
      _selectedTab = null;
      _didAutoSelectLastMyProduct = true;
    });

    await home.setSelectedMyProduct(
      selected,
      fetchRecommendations: true,
    );

    if (!mounted) return;

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
      _selectedTab = null;
      _didAutoSelectLastMyProduct = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF073B5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: const Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF67E8F9),
                  size: 22,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم تغيير المنتج وجاري تحديث الترشيحات.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        final List<Product> allProducts =
        _removeRequestedSuggestions(home.recProducts);
        final bool hasItems = allProducts.isNotEmpty;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _autoSelectLastMyProductIfNeeded(home);
        });

        final String loginUserId =
            PsSharedPreferences.instance.shared.getString(
              PsConst.VALUE_HOLDER__USER_ID,
            ) ??
                '';
        final _ = loginUserId;

        final List<_SuggestedSwapTabMeta> tabs = _buildTabs(allProducts);
        final _SuggestedSwapInterestTab? effectiveSelectedTab =
        _resolveSelectedTab(tabs);
        final List<Product> visibleProducts =
        _productsForSelectedTab(tabs, effectiveSelectedTab);

        if (_selectedTab != effectiveSelectedTab) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedTab = effectiveSelectedTab;
            });
          });
        }

        final bool hasVisibleItems = visibleProducts.isNotEmpty;

        if (!hasItems || !hasVisibleItems) {
          _didInitSync = false;
          if (_currentIndex != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _currentIndex = 0);
              }
            });
          }
        } else if (!_didInitSync) {
          _didInitSync = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || visibleProducts.isEmpty) return;

            int startIndex = 0;
            final String? selectedId = home.selectedSwapProduct?.id;
            if (selectedId != null) {
              final int i =
              visibleProducts.indexWhere((Product e) => e.id == selectedId);
              if (i >= 0) {
                startIndex = i;
              }
            }

            _syncSelectedSwapFromVisible(home, visibleProducts, startIndex);
            _jumpToCurrentIndexIfPossible();
          });
        } else if (hasVisibleItems) {
          final String? selectedId = home.selectedSwapProduct?.id;
          final bool selectedStillVisible = selectedId != null &&
              visibleProducts.any((Product e) => e.id == selectedId);

          if (!selectedStillVisible && _currentIndex == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || visibleProducts.isEmpty) return;
              _syncSelectedSwapFromVisible(home, visibleProducts, 0);
            });
          }

          if (_currentIndex >= visibleProducts.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || visibleProducts.isEmpty) return;
              final int fixedIndex = visibleProducts.length - 1;
              _syncSelectedSwapFromVisible(home, visibleProducts, fixedIndex);
              _jumpToCurrentIndexIfPossible();
            });
          }
        }

        final double screenW = MediaQuery.of(context).size.width;
        final bool smallLayout = screenW < 390;
        final bool compact = MediaQuery.of(context).size.height < 760;

        double? pageHeight;
        if (hasVisibleItems) {
          final int safeIndex = _currentIndex < 0
              ? 0
              : (_currentIndex >= visibleProducts.length
              ? visibleProducts.length - 1
              : _currentIndex);

          final Product currentProduct = visibleProducts[safeIndex];
          final InlineSwapVM currentVm = _buildVm(currentProduct);

          pageHeight = estimateSuggestedSwapPageHeight(
            context: context,
            recProducts: visibleProducts,
            vmBuilder: _buildVm,
            smallLayout: smallLayout,
            compact: compact,
            currentProduct: currentProduct,
            currentVm: currentVm,
            myProduct: home.myProduct,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            if (!hasItems || !hasVisibleItems)
              Center(
                child: home.recLoading
                    ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(),
                )
                    : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(Utils.getString(context, 'no__suggestions')),
                ),
              )
            else
              Column(
                children: [
                  Builder(
                    builder: (BuildContext context) {
                      final int safeIndex = _currentIndex < 0
                          ? 0
                          : (_currentIndex >= visibleProducts.length
                          ? visibleProducts.length - 1
                          : _currentIndex);

                      final Product p = visibleProducts[safeIndex];
                      final InlineSwapVM vm = _buildVm(p);

                      return _SuggestionCompareCard(
                        myProduct: home.myProduct,
                        product: p,
                        vm: vm,
                        compact: compact,
                        smallLayout: smallLayout,
                        isActive: true,
                        relationBackendCode: _getRelationCode(p),
                        index: safeIndex,
                        totalCount: visibleProducts.length,
                        headerProductsCount: home.myProducts.length,
                        tabsBar: tabs.isNotEmpty
                            ? _SuggestedSwapTabsBar(
                          tabs: tabs,
                          selectedTab: effectiveSelectedTab,
                          onTabSelected: (_SuggestedSwapInterestTab tab) {
                            _changeTab(home, tab, tabs);
                          },
                          onEditInterests: _openEditInterests,
                        )
                            : null,
                        onTapCard: () {},
                        onTapSuggestedProduct: () =>
                            _openProductDetails(context, p),
                        onTapMyProduct: () {
                          final Product? my = home.myProduct;
                          if (my != null) {
                            _openProductDetails(context, my);
                          }
                        },
                        headerTotalValueText: _formatMoneyValue(
                          _totalProductsValue(home.myProducts),
                        ),
                        onEditInterests: _openEditInterests,
                        onOpenNetworkSheet: _openRecommendationNetworkSheet,
                        onChangeMyProduct: () => _openMyProductsBottomSheet(home),
                        onPrevSuggestion: () => _goPrev(home, visibleProducts),
                        onNextSuggestion: () => _goNext(home, visibleProducts),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SwapWhatsAppShareButton(
                    myProduct: home.myProduct,
                    suggestions: visibleProducts,
                  ),
                  const SizedBox(height: 6),
                ],
              ),
          ],
        );
      },
    );
  }
}


class _CompactPickerHeader extends StatelessWidget {
  const _CompactPickerHeader({
    required this.title,
    required this.count,
    required this.totalValueText,
  });

  final String title;
  final int count;
  final String totalValueText;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD8EDF3),
            width: 1,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x120C587A),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: <Color>[
                          Color(0xFF072D56),
                          Color(0xFF0D5E7B),
                          Color(0xFF24A9C4),
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),

                ],
              ),
            ),
            if (count > 0) ...<Widget>[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: <Color>[
                      Color(0xFFFFFFFF),
                      Color(0xFFEAF8FC),
                      Color(0xFFDDF4FA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFBFE3EC),
                    width: 1,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x120C587A),
                      blurRadius: 7,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$count  منتج - $totalValueText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF0C587A),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestedSwapTabsBar extends StatelessWidget {
  const _SuggestedSwapTabsBar({
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
    required this.onEditInterests,
  });

  final List<_SuggestedSwapTabMeta> tabs;
  final _SuggestedSwapInterestTab? selectedTab;
  final ValueChanged<_SuggestedSwapInterestTab> onTabSelected;
  final VoidCallback onEditInterests;

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 75,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 9),
          itemBuilder: (BuildContext context, int index) {
            final _SuggestedSwapTabMeta meta = tabs[index];
            final bool selected = meta.tab == selectedTab;

            return _SuggestedSwapWorldCard(
              meta: meta,
              selected: selected,
              onTap: () => onTabSelected(meta.tab),
              onEdit: meta.tab == _SuggestedSwapInterestTab.self
                  ? onEditInterests
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _SuggestedSwapWorldCard extends StatelessWidget {
  const _SuggestedSwapWorldCard({
    required this.meta,
    required this.selected,
    required this.onTap,
    this.onEdit,
  });

  final _SuggestedSwapTabMeta meta;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final SectionPalette palette = _paletteForSuggestedSwapTab(meta.tab);
    final IconData icon = _iconForSuggestedSwapTab(meta.tab);
    final String title = _compactTitleForSuggestedSwapTab(meta);
    final BorderRadius radius = BorderRadius.circular(20);
    final VoidCallback? editAction = onEdit;

    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.0 : 0.94,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: selected ? 1.0 : 0.82,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 140,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette.gradient,
            ),
            border: Border.all(
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.45),
              width: selected ? 4.0 : 1.0,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: selected
                    ? palette.accent.withValues(alpha: 0.28)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: selected ? 18 : 7,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected
                    ? const Color(0xFF8BA3AD).withValues(alpha: 0.70)
                    : Colors.transparent,
                width: selected ? 2.0 : 0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1.50,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: selected ? 4 : 3,
                          width: selected ? 46 : 20,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999),
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
        ),
      ),
    );
  }
}


class _RecommendationBoosterBar extends StatelessWidget {
  const _RecommendationBoosterBar({
    required this.onEditInterests,
    required this.onOpenFriendsAndFamily,
    required this.onOpenFamily,
  });

  final VoidCallback onEditInterests;
  final VoidCallback onOpenFriendsAndFamily;
  final VoidCallback onOpenFamily;

  @override
  Widget build(BuildContext context) {
    final int pendingFriendsCount =
        context.watch<ContactNetworkProvider>().pendingCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 46,
        padding: const EdgeInsetsDirectional.only(
          start: 8,
          end: 7,
          top: 6,
          bottom: 6,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[
              Color(0xFFFFFFFF),
              Color(0xFFF4FCFE),
              Color(0xFFEAF8FC),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD8EFF5),
            width: 1,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0D0C587A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[

            Text(
              'حسّن الترشيحات',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF123B52),
                fontWeight: FontWeight.w900,
                fontSize: 11.4,
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (BuildContext context, int index) {
                    switch (index) {
                      case 0:
                        return _RecommendationBoosterChip(
                          label: 'أضف أصدقاءك',
                          icon: Icons.groups_2_rounded,
                          badgeCount: pendingFriendsCount,
                          onTap: onOpenFriendsAndFamily,
                        );
                      case 1:
                        return _RecommendationBoosterChip(
                          label: 'عدل اهتماماتك',
                          icon: Icons.tune_rounded,
                          onTap: onEditInterests,
                        );
                      default:
                        return _RecommendationBoosterChip(
                          label: 'أضف عائلتك',
                          icon: Icons.family_restroom_rounded,
                          onTap: onOpenFamily,
                        );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationBoosterChip extends StatelessWidget {
  const _RecommendationBoosterChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          height: 32,
          padding: const EdgeInsetsDirectional.only(
            start: 9,
            end: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFBFEAF0),
              width: 1,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0A0C587A),
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 13,
                color: const Color(0xFF0C587A),
              ),
              if (badgeCount > 0) ...<Widget>[
                const SizedBox(width: 4),
                _RecommendationBoosterCountBadge(count: badgeCount),
              ],
              const SizedBox(width: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF17425E),
                  fontWeight: FontWeight.w900,
                  fontSize: 10.6,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _RecommendationBoosterCountBadge extends StatelessWidget {
  const _RecommendationBoosterCountBadge({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final String text = count > 99 ? '99+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB020),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        style: const TextStyle(
          color: Color(0xFF231307),
          fontWeight: FontWeight.w900,
          fontSize: 9.5,
          height: 1,
        ),
      ),
    );
  }
}

class _SuggestionCompareCard extends StatelessWidget {
  const _SuggestionCompareCard({
    required this.myProduct,
    required this.product,
    required this.vm,
    required this.compact,
    required this.smallLayout,
    required this.isActive,
    required this.relationBackendCode,
    required this.index,
    required this.totalCount,
    required this.headerProductsCount,
    this.tabsBar,
    required this.onTapCard,
    required this.onTapSuggestedProduct,
    required this.onTapMyProduct,
    required this.headerTotalValueText,
    required this.onEditInterests,
    required this.onOpenNetworkSheet,
    required this.onChangeMyProduct,
    required this.onPrevSuggestion,
    required this.onNextSuggestion,
  });

  final Product? myProduct;
  final Product product;
  final InlineSwapVM vm;
  final bool compact;
  final bool smallLayout;
  final bool isActive;
  final String? relationBackendCode;
  final int index;
  final int totalCount;
  final int headerProductsCount;
  final Widget? tabsBar;
  final VoidCallback onTapCard;
  final VoidCallback onTapSuggestedProduct;
  final VoidCallback onTapMyProduct;
  final String headerTotalValueText;
  final VoidCallback onEditInterests;
  final VoidCallback onOpenNetworkSheet;
  final VoidCallback onChangeMyProduct;
  final VoidCallback onPrevSuggestion;
  final VoidCallback onNextSuggestion;

  @override
  Widget build(BuildContext context) {
    final List<SwapCriterionItem> enabledCriteria =
    buildSuggestedSwapCriteria(
      product,
      vm,
      myProduct: myProduct,
    ).where((e) => e.enabled).take(6).toList(); // ✅ الترتيب محفوظ كما هو في buildSuggestedSwapCriteria

    final List<SwapCriterionItem> criteriaToShow = enabledCriteria.isNotEmpty
        ? enabledCriteria
        : buildSuggestedSwapFallbackCriteria(vm);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: isActive
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
            ],
          )
              : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
            ],
          ),
          border: Border.all(
            color: isActive ? const Color(0xFF19D4E2) : const Color(0xFFD7E6EE),
            width: isActive ? 1 : 1,
          ),
          boxShadow: <BoxShadow>[
            if (isActive)
              const BoxShadow(
                color: Color(0x2A21C9D7),
                blurRadius: 24,
                spreadRadius: 1,
                offset: Offset(0, 9),
              )
            else
              const BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTapCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tabsBar != null) ...[
                  tabsBar!,
                  const SizedBox(height: 8),
                ] else
                  const SizedBox(height: 8),
                _RecommendationBoosterBar(
                  onEditInterests: onEditInterests,
                  onOpenFriendsAndFamily: onOpenNetworkSheet,
                  onOpenFamily: onOpenNetworkSheet,
                ),
                const SizedBox(height: 10),
                _SwapCompareRow(
                  myProduct: myProduct,
                  suggestedProduct: product,
                  compact: compact,
                  smallLayout: smallLayout,
                  relationBackendCode: relationBackendCode,
                  onTapMyProduct: onTapMyProduct,
                  onChangeMyProduct: onChangeMyProduct,
                  onTapSuggestedProduct: onTapSuggestedProduct,
                  currentIndex: index,
                  totalCount: totalCount,
                  onPrevSuggestion: onPrevSuggestion,
                  onNextSuggestion: onNextSuggestion,
                ),
                const SizedBox(height: 10),
                SuggestedSwapReasonsGrid(
                  items: criteriaToShow,
                  compact: compact,
                  vm: vm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _CompareCardTopBar extends StatelessWidget {
  const _CompareCardTopBar({
    required this.vm,
    required this.currentIndex,
    required this.totalCount,
  });

  final InlineSwapVM vm;
  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final SwapBadgeStyle style = swapBadgeStyleForBadge(vm.badge);

    return Row(
      children: [
        if (vm.percent >= 60) ...[
          const SizedBox(width: 8),
          _ModernScoreBadge(
            percent: vm.percent,
            title: vm.badge.title,
            style: style,
          ),
        ],
        const SizedBox(width: 8),
        Expanded(
          child: _ModernOpportunityBadge(vm: vm, style: style),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FBFE),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD2EAF1)),
          ),
          child: Text(
            '${currentIndex + 1}/$totalCount',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF1D5166),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModernOpportunityBadge extends StatelessWidget {
  const _ModernOpportunityBadge({
    required this.vm,
    required this.style,
  });

  final InlineSwapVM vm;
  final SwapBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final SwapBadge badge = vm.badge;

    return SizedBox(
      height: 35,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: style.border,
            width: 1.2,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          badge.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: style.textColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class _SwapCompareRow extends StatelessWidget {
  const _SwapCompareRow({
    required this.myProduct,
    required this.suggestedProduct,
    required this.compact,
    required this.smallLayout,
    this.relationBackendCode,
    required this.onTapMyProduct,
    required this.onChangeMyProduct,
    required this.onTapSuggestedProduct,
    required this.currentIndex,
    required this.totalCount,
    required this.onPrevSuggestion,
    required this.onNextSuggestion,
  });

  final Product? myProduct;
  final Product suggestedProduct;
  final bool compact;
  final bool smallLayout;
  final String? relationBackendCode;
  final VoidCallback onTapMyProduct;
  final VoidCallback onChangeMyProduct;
  final VoidCallback onTapSuggestedProduct;
  final int currentIndex;
  final int totalCount;
  final VoidCallback onPrevSuggestion;
  final VoidCallback onNextSuggestion;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = smallLayout ? 128 : 142;
    final double cardHeight = compact ? 172 : 188;
    final double connectorTopPadding =
        (cardHeight / 2) - (smallLayout ? 26 : 30);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CompareMiniProductCard(
                  product: myProduct,
                  isMine: true,
                  width: cardWidth,
                  height: cardHeight,
                  onTap: onTapMyProduct,
                ),
                const SizedBox(height: 8),
                _ChangeMyProductButton(
                  onTap: onChangeMyProduct,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 2,
            right: 2,
            top: connectorTopPadding < 0 ? 0 : connectorTopPadding,
          ),
          child: _SwapConnectorBadge(smallLayout: smallLayout),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _CompareMiniProductCard(
                    key: ValueKey<String>(
                      'suggested_${suggestedProduct.id ?? currentIndex}',
                    ),
                    product: suggestedProduct,
                    isMine: false,
                    width: cardWidth,
                    height: cardHeight,
                    relationBackendCode: relationBackendCode,
                    onTap: onTapSuggestedProduct,
                  ),
                ),
                if (totalCount > 1) ...[
                  const SizedBox(height: 8),
                  _SuggestedProductOnlyNavigator(
                    currentIndex: currentIndex,
                    total: totalCount,
                    onPrev: onPrevSuggestion,
                    onNext: onNextSuggestion,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _ChangeMyProductButton extends StatelessWidget {
  const _ChangeMyProductButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: <Color>[
                Color(0xFF043757),
                Color(0xFF0C587A),
                Color(0xFF24A9C4),
              ],
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x2219D4E2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'اختر منتج آخر',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
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


class _SuggestedProductOnlyNavigator extends StatelessWidget {
  const _SuggestedProductOnlyNavigator({
    required this.currentIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int currentIndex;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bool canPrev = currentIndex > 0;
    final bool canNext = currentIndex < total - 1;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3FBFD),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFFD2EAF1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SmallSuggestedArrow(
              icon: Icons.chevron_left_rounded,
              enabled: canNext,
              onTap: onNext,
              highlight: canNext,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${currentIndex + 1}/$total',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF1D5166),
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            _SmallSuggestedArrow(
              icon: Icons.chevron_right_rounded,
              enabled: canPrev,
              onTap: onPrev,
            ),

          ],
        ),
      ),
    );
  }
}

class _SmallSuggestedArrow extends StatefulWidget {
  const _SmallSuggestedArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  /// استخدمها مع زرار next فقط عشان تلفت نظر المستخدم
  final bool highlight;

  @override
  State<_SmallSuggestedArrow> createState() => _SmallSuggestedArrowState();
}

class _SmallSuggestedArrowState extends State<_SmallSuggestedArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _slideAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnim = Tween<double>(begin: 0, end: -3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnim = Tween<double>(begin: 0.18, end: 0.48).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _SmallSuggestedArrow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled != widget.enabled ||
        oldWidget.highlight != widget.highlight) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.enabled && widget.highlight) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _shouldAnimate => widget.enabled && widget.highlight;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1 : 0.35,
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double scale = _shouldAnimate ? _scaleAnim.value : 1.0;
            final double slide = _shouldAnimate ? _slideAnim.value : 0.0;
            final double glow = _shouldAnimate ? _glowAnim.value : 0.18;

            return Transform.translate(
              offset: Offset(slide, 0),
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final double glow = _shouldAnimate ? _glowAnim.value : 0.18;

                return Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.enabled
                        ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xFF24A9C4),
                        Color(0xFF0C587A),
                      ],
                    )
                        : null,
                    color: widget.enabled ? null : const Color(0xFFD8E1E8),
                    boxShadow: widget.enabled
                        ? <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF24A9C4)
                            .withValues(alpha: glow),
                        blurRadius: _shouldAnimate ? 12 : 6,
                        spreadRadius: _shouldAnimate ? 1.2 : 0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : const <BoxShadow>[],
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CompareMiniProductCard extends StatelessWidget {
  const _CompareMiniProductCard({
    Key? key,
    required this.product,
    required this.isMine,
    required this.width,
    required this.height,
    this.relationBackendCode,
    required this.onTap,
  }) : super(key: key);

  final Product? product;
  final bool isMine;
  final double width;
  final double height;
  final String? relationBackendCode;
  final VoidCallback onTap;

  ImageProvider _imageProviderFor(Product? p) {
    final String? raw = p?.defaultPhoto?.imgPath;

    if (raw == null || raw.trim().isEmpty) {
      return const AssetImage('assets/images/img_placeholder.png');
    }

    final String path = raw.trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    return NetworkImage('${PsConfig.ps_app_image_url}$path');
  }

  int? _parsePositiveInt(String? value) {
    final String v = (value ?? '').trim();
    final int? parsed = int.tryParse(v);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  String _resolvePriceRange(Product? p) {
    if (p == null) return 'اختر منتجًا';

    final int? low = _parsePositiveInt(p.lowPrice);
    final int? high = _parsePositiveInt(p.highPrice);
    final int? price = _parsePositiveInt(p.price);

    if (low != null && high != null) {
      if (low == high) return '$low جنيه';

      final int minValue = low < high ? low : high;
      final int maxValue = low < high ? high : low;
      return '$minValue - $maxValue جنيه';
    }

    if (low != null) return '$low جنيه';
    if (high != null) return '$high جنيه';
    if (price != null) return '$price جنيه';

    return 'السعر غير محدد';
  }

  String _resolveCondition(Product? p) {
    if (p == null) return 'غير محدد';

    final String value = (p.conditionOfItem?.name ?? '').trim();
    if (value.isEmpty) return 'حالة غير محددة';

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final Product? p = product;

    if (p != null) {
      return TaapdeelProductCardItem(
        product: p,
        coreTagKey: 'suggested_swap_${isMine ? 'my' : 'rec'}_${p.id ?? p.hashCode}',
        onTap: onTap,
        cardWidth: width,
        cardHeight: height,
        outerMargin: EdgeInsets.zero,
        variant: TaapdeelProductCardVariant.deal,
        showRotatingBanner: true,
        showRelationPanel: !isMine,
        relationBackendCode: isMine ? null : relationBackendCode,
      );
    }

    final BorderRadius radius = BorderRadius.circular(22);
    final ImageProvider image = _imageProviderFor(p);
    final String priceLabel = _resolvePriceRange(p);
    final String condition = _resolveCondition(p);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: p == null ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: isMine
                    ? const Color(0xFF85DCEC)
                    : const Color(0xFF19D4E2),
                width: 1.2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.055),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: const Color(0xFFE8F4F8),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 34,
                            color: Color(0xFF8AA6B8),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.black.withValues(alpha: 0.34),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.28),
                          ],
                          stops: const <double>[0.0, 0.46, 1.0],
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    end: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProductOverlayPill(
                          text: priceLabel,
                          icon: Icons.payments_rounded,
                          strong: true,
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.center,
                          child: _ProductOverlayPill(
                            text: condition,
                            icon: Icons.verified_rounded,
                            strong: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 8,
                    start: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                      child: Text(
                        isMine ? 'منتجك' : 'مرشح',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF0C587A),
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
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


class _MyProductChangeBottomSheet extends StatelessWidget {
  const _MyProductChangeBottomSheet({
    required this.products,
    required this.selectedProductId,
    required this.totalValueText,
  });

  final List<Product> products;
  final String? selectedProductId;
  final String totalValueText;
  bool _isPending(Product p) {
    return (p.status ?? '1').toString().trim() == '0';
  }

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;
    final double screenW = MediaQuery.of(context).size.width;
    final bool smallLayout = screenW < 390;
    final bool compact = screenH < 760;
    final double cardWidth = smallLayout ? 128 : 142;
    final double cardHeight = compact ? 172 : 188;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.66),
        decoration: const BoxDecoration(
          color: Color(0xFFF6FBFD),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFB8CBD5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: _MyProductChangeSheetHeader(
                count: products.length,
                totalValueText: totalValueText,
              ),
            ),
            SizedBox(
              height: cardHeight + 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final Product product = products[index];
                  final String id = (product.id ?? '').toString().trim();
                  final bool selected =
                      id.isNotEmpty && id == (selectedProductId ?? '').trim();
                  final bool pending = _isPending(product);

                  return _MyProductChangeMiniCard(
                    product: product,
                    width: cardWidth,
                    height: cardHeight,
                    selected: selected,
                    pending: pending,
                    onTap: () => Navigator.of(context).pop(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyProductChangeSheetHeader extends StatelessWidget {
  const _MyProductChangeSheetHeader({
    required this.count, required this.totalValueText,
  });

  final int count;
  final String totalValueText;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[
            Color(0xFF011934),
            Color(0xFF043757),
            Color(0xFF24A9C4),
          ],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x220E8FAE),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'اختار منتج لعرض ترشيحات التبديل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$count منتج متاح - $totalValueText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyProductChangeMiniCard extends StatelessWidget {
  const _MyProductChangeMiniCard({
    required this.product,
    required this.width,
    required this.height,
    required this.selected,
    required this.pending,
    required this.onTap,
  });

  final Product product;
  final double width;
  final double height;
  final bool selected;
  final bool pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          _CompareMiniProductCard(
            product: product,
            isMine: true,
            width: width,
            height: height,
            onTap: onTap,
          ),
          PositionedDirectional(
            top: -5,
            end: -5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                color: pending
                    ? const Color(0xFFF4B23E)
                    : selected
                    ? const Color(0xFF24A9C4)
                    : Colors.white.withValues(alpha: 0.94),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                pending
                    ? Icons.hourglass_top_rounded
                    : selected
                    ? Icons.check_rounded
                    : Icons.radio_button_off_rounded,
                color: pending || selected
                    ? Colors.white
                    : const Color(0xFF9CB3BF),
                size: pending || selected ? 15 : 17,
              ),
            ),
          ),
          PositionedDirectional(
            start: 8,
            end: 8,
            bottom: -2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: selected
                    ? const LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: <Color>[
                    Color(0xFF043757),
                    Color(0xFF0C587A),
                    Color(0xFF24A9C4),
                  ],
                )
                    : null,
                color: selected ? null : Colors.white.withValues(alpha: 0.92),
                border: Border.all(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.80)
                      : const Color(0xFFD8EDF3),
                  width: 1,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x140C587A),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                pending
                    ? 'بانتظار الموافقة'
                    : selected
                    ? 'المنتج الحالي'
                    : 'اختيار المنتج',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : pending
                      ? const Color(0xFFB26A00)
                      : const Color(0xFF0C587A),
                  fontWeight: FontWeight.w900,
                  fontSize: 10.2,
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


class _ProductOverlayPill extends StatelessWidget {
  const _ProductOverlayPill({
    required this.text,
    required this.icon,
    required this.strong,
  });

  final String text;
  final IconData icon;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: strong
            ? Colors.white.withValues(alpha: 0.94)
            : const Color(0xFFEFFFFF).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.96),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: strong ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 13,
            color: strong
                ? const Color(0xFF163F57)
                : const Color(0xFF0A7C88),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: strong
                    ? const Color(0xFF163F57)
                    : const Color(0xFF0A7C88),
                fontWeight: FontWeight.w900,
                fontSize: strong ? 11.2 : 10.2,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapConnectorBadge extends StatelessWidget {
  const _SwapConnectorBadge({
    required this.smallLayout,
  });

  final bool smallLayout;

  @override
  Widget build(BuildContext context) {
    final double size = smallLayout ? 30 : 40;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: 45,
          height: 48,
          child: Image.asset(
            'assets/images/Taapdeel_icon.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _SuggestionsBottomNavigator extends StatelessWidget {
  const _SuggestionsBottomNavigator({
    required this.currentIndex,
    required this.total,
    required this.currentTitle,
    required this.onPrev,
    required this.onNext,
    required this.onDotTap,
  });

  final int currentIndex;
  final int total;
  final String currentTitle;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    final bool canPrev = currentIndex > 0;
    final bool canNext = currentIndex < total - 1;
    final String title = currentTitle.trim();

    return Row(
      children: [
        _MiniNavButton(
          icon: Icons.chevron_left_rounded,
          enabled: canPrev,
          onTap: onPrev,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty) ...[
                  Flexible(
                    flex: 5,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF163F57),
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],

//////////
              ],
            ),
          ),
        ),
        _MiniNavButton(
          icon: Icons.chevron_right_rounded,
          enabled: canNext,
          onTap: onNext,
        ),
      ],
    );
  }
}


class _MiniNavButton extends StatelessWidget {
  const _MiniNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: enabled
                ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF1AB8C3),
                Color(0xFF133D75),
              ],
            )
                : const LinearGradient(
              colors: <Color>[
                Color(0xFFD8E1E8),
                Color(0xFFC5D0D9),
              ],
            ),
            boxShadow: enabled
                ? const <BoxShadow>[
              BoxShadow(
                color: Color(0x220E8FAE),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
                : const <BoxShadow>[],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernScoreBadge extends StatelessWidget {
  const _ModernScoreBadge({
    required this.percent,
    required this.title,
    required this.style,
  });

  final int percent;
  final String title;
  final SwapBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final int safePercent = percent.clamp(0, 100);
    final Color arcColor = style.textColor;
    final Color secondaryArcColor = style.innerBorder;
    final Color shadowColor = arcColor.withValues(alpha: 0.16);

    return SizedBox(
      width: 56,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _CircularScorePainter(
            percent: safePercent,
            arcColor: arcColor,
            secondaryArcColor: secondaryArcColor,
            trackColor: const Color(0xFFE8F4F7),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 7, 6, 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$safePercent',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF011934),
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        height: 0.95,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '%',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF011934),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularScorePainter extends CustomPainter {
  const _CircularScorePainter({
    required this.percent,
    required this.arcColor,
    required this.secondaryArcColor,
    required this.trackColor,
  });

  final int percent;
  final Color arcColor;
  final Color secondaryArcColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide / 2) - 4.0;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final Paint arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: <Color>[
          secondaryArcColor,
          arcColor,
          const Color(0xFF24A9C4),
          secondaryArcColor,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final double sweepAngle = (percent / 100) * math.pi * 2;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularScorePainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.secondaryArcColor != secondaryArcColor ||
        oldDelegate.trackColor != trackColor;
  }
}
