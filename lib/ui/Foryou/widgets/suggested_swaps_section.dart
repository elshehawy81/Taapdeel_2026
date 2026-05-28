import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/category/list/category_list_view.dart';
import 'package:provider/provider.dart';

import '../widgets/swap_rating.dart';
import '../widgets/swap_whatsapp_share_service.dart';

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

String _subtitleForSuggestedSwapTab(_SuggestedSwapInterestTab tab) {
  switch (tab) {
    case _SuggestedSwapInterestTab.self:
      return 'حسب اهتماماتك';
    case _SuggestedSwapInterestTab.family:
      return 'الأكثر ثقة';
    case _SuggestedSwapInterestTab.other:
      return 'فرص جديدة';
  }
}

String _compactTitleForSuggestedSwapTab(_SuggestedSwapTabMeta meta) {
  switch (meta.tab) {
    case _SuggestedSwapInterestTab.self:
      return 'ترشيحات \n مناسبة لاهتماماتك';
    case _SuggestedSwapInterestTab.family:
      return 'ترشيحات\n مناسبة لعائلتك';
    case _SuggestedSwapInterestTab.other:
      return 'ترشيحات\n لتصنيفات اخري';
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
      setState(() {
        _selectedTab = _SuggestedSwapInterestTab.self;
        _currentIndex = 0;
        _didInitSync = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        final List<Product> allProducts =
        _removeRequestedSuggestions(home.recProducts);
        final bool hasItems = allProducts.isNotEmpty;

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
                        onPrevSuggestion: () => _goPrev(home, visibleProducts),
                        onNextSuggestion: () => _goNext(home, visibleProducts),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _SwapWhatsAppShareButton(
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
      height: 96,
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
          width: 132,
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
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: _SuggestedSwapCountBadge(
                        count: meta.items.length,
                        accent: palette.accent,
                      ),
                    ),
                    if (editAction != null)
                      PositionedDirectional(
                        top: 8,
                        end: 8,
                        child: _InterestChipEditIcon(
                          selected: selected,
                          accent: palette.accent,
                          onTap: editAction,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 9, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          const SizedBox(height: 22),
                          Expanded(
                            child: Center(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.45,
                                  fontSize: 11.5,
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

class _SuggestedSwapCountBadge extends StatelessWidget {
  const _SuggestedSwapCountBadge({
    required this.count,
    required this.accent,
  });

  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 25),
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        maxLines: 1,
        softWrap: false,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

class _InterestChipEditIcon extends StatelessWidget {
  const _InterestChipEditIcon({
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'تعديل الاهتمامات',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: selected ? 0.98 : 0.90),
            border: Border.all(
              color: accent.withValues(alpha: selected ? 0.22 : 0.16),
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.edit_rounded,
            size: 15.5,
            color: accent,
          ),
        ),
      ),
    );
  }
}

class _SectionFancyHeader extends StatelessWidget {
  const _SectionFancyHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF072D56),
            Color(0xFF0D5E7B),
            Color(0xFF63CAD6),
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
      child: const Row(
        children: [
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أفضل ترشيحات التبديل',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
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
    this.tabsBar,
    required this.onTapCard,
    required this.onTapSuggestedProduct,
    required this.onTapMyProduct,
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
  final Widget? tabsBar;
  final VoidCallback onTapCard;
  final VoidCallback onTapSuggestedProduct;
  final VoidCallback onTapMyProduct;
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
                  const SizedBox(height: 12),
                ],
                _CompareCardTopBar(
                  vm: vm,
                  currentIndex: index,
                  totalCount: totalCount,
                ),
                const SizedBox(height: 10),
                _SwapCompareRow(
                  myProduct: myProduct,
                  suggestedProduct: product,
                  compact: compact,
                  smallLayout: smallLayout,
                  onTapMyProduct: onTapMyProduct,
                  onTapSuggestedProduct: onTapSuggestedProduct,
                  currentIndex: index,
                  totalCount: totalCount,
                  onPrevSuggestion: onPrevSuggestion,
                  onNextSuggestion: onNextSuggestion,
                ),
                const SizedBox(height: 20),
                SuggestedSwapReasonsGrid(
                  items: criteriaToShow,
                  compact: compact,
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
    required this.onTapMyProduct,
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
  final VoidCallback onTapMyProduct;
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
            child: _CompareMiniProductCard(
              product: myProduct,
              isMine: true,
              width: cardWidth,
              height: cardHeight,
              onTap: onTapMyProduct,
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
              enabled: canPrev,
              onTap: onPrev,
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
              enabled: canNext,
              onTap: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallSuggestedArrow extends StatelessWidget {
  const _SmallSuggestedArrow({
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
      opacity: enabled ? 1 : 0.35,
      child: IgnorePointer(
        ignoring: !enabled,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: enabled
                  ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF24A9C4),
                  Color(0xFF0C587A),
                ],
              )
                  : null,
              color: enabled ? null : const Color(0xFFD8E1E8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
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
    required this.onTap,
  }) : super(key: key);

  final Product? product;
  final bool isMine;
  final double width;
  final double height;
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
    final double size = smallLayout ? 52 : 60;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: 55,
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

// =============================================================
// _SwapWhatsAppShareButton
// زرار "استشير صحابك/قرايبك" — يفتح اختيار المنتجات والثيم قبل الشير
// =============================================================
class _SwapWhatsAppShareButton extends StatefulWidget {
  const _SwapWhatsAppShareButton({
    required this.myProduct,
    required this.suggestions,
  });

  final Product? myProduct;
  final List<Product> suggestions;

  @override
  State<_SwapWhatsAppShareButton> createState() =>
      _SwapWhatsAppShareButtonState();
}

class _SwapWhatsAppShareButtonState extends State<_SwapWhatsAppShareButton> {
  bool _loading = false;

  Future<void> _onTap() async {
    if (_loading) return;

    final _SwapShareSelectionResult? result = await showSwapSharePickerSheet(
      context: context,
      myProduct: widget.myProduct,
      suggestions: widget.suggestions,
    );

    if (result == null || result.products.isEmpty) return;

    if (mounted) setState(() => _loading = true);

    try {
      await SwapWhatsAppShareService.share(
        context: context,
        myProduct: widget.myProduct,
        suggestions: result.products,
        theme: result.theme,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 50,
          width: 240,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: <Color>[
                Color(0xFF25D366),
                Color(0xFF128C7E),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x3025D366),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('💬', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  'استشير صحابك/قرايبك',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '↗',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwapShareSelectionResult {
  const _SwapShareSelectionResult({
    required this.products,
    required this.theme,
  });

  final List<Product> products;
  final SwapShareTheme theme;
}

Future<_SwapShareSelectionResult?> showSwapSharePickerSheet({
  required BuildContext context,
  required Product? myProduct,
  required List<Product> suggestions,
}) {
  return showModalBottomSheet<_SwapShareSelectionResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return _SwapSharePickerSheet(
        myProduct: myProduct,
        suggestions: suggestions,
      );
    },
  );
}

class _SwapSharePickerSheet extends StatefulWidget {
  const _SwapSharePickerSheet({
    required this.myProduct,
    required this.suggestions,
  });

  final Product? myProduct;
  final List<Product> suggestions;

  @override
  State<_SwapSharePickerSheet> createState() => _SwapSharePickerSheetState();
}

class _SwapSharePickerSheetState extends State<_SwapSharePickerSheet> {
  static const int _maxProducts = 5;

  late final Set<int> _selectedIndexes;
  int _selectedThemeIndex = 0;

  @override
  void initState() {
    super.initState();
    final int initialCount = widget.suggestions.length < 3
        ? widget.suggestions.length
        : 3;
    _selectedIndexes = Set<int>.from(
      List<int>.generate(initialCount, (int index) => index),
    );
  }

  void _toggleProduct(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
        return;
      }

      if (_selectedIndexes.length >= _maxProducts) {
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
                  'يمكنك اختيار 5 منتجات كحد أقصى حتى تظل صورة الشير واضحة.',
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

      _selectedIndexes.add(index);
    });
  }

  void _share() {
    if (_selectedIndexes.isEmpty) {
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
                'اختار منتج واحد على الأقل عشان تسأل عليه.',
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

    final List<int> orderedIndexes = _selectedIndexes.toList()..sort();
    final List<Product> selectedProducts = orderedIndexes
        .where((int index) => index >= 0 && index < widget.suggestions.length)
        .map((int index) => widget.suggestions[index])
        .toList(growable: false);

    Navigator.of(context).pop(
      _SwapShareSelectionResult(
        products: selectedProducts,
        theme: SwapShareTheme.presets[_selectedThemeIndex],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;
    final double sheetMaxH = screenH * 0.88;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: sheetMaxH),
        decoration: const BoxDecoration(
          color: Color(0xFFF6FBFD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
              child: _SharePickerHeader(
                selectedCount: _selectedIndexes.length,
                maxProducts: _maxProducts,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _SharePickerSectionTitle(
                      icon: Icons.inventory_2_rounded,
                      title: 'اختار المنتجات اللي تحب تسأل عنها',
                      subtitle: 'تم اختيار أول 3 تلقائيًا، ويمكنك التعديل قبل الشير.',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 104,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsetsDirectional.only(end: 2),
                        itemCount: widget.suggestions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final Product product = widget.suggestions[index];

                          return SizedBox(
                            width: MediaQuery.of(context).size.width * 0.78,
                            child: _ShareProductSelectCard(
                              product: product,
                              index: index,
                              selected: _selectedIndexes.contains(index),
                              onTap: () => _toggleProduct(index),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _SharePickerSectionTitle(
                      icon: Icons.palette_rounded,
                      title: 'اختار ثيم الاستشارة',
                      subtitle: 'الثيم يغير شكل الصورة ونص السؤال في واتساب.',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 106,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: SwapShareTheme.presets.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final SwapShareTheme theme =
                          SwapShareTheme.presets[index];
                          return _ShareThemeCard(
                            theme: theme,
                            selected: index == _selectedThemeIndex,
                            onTap: () => setState(() {
                              _selectedThemeIndex = index;
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _SharePickerBottomBar(
              selectedCount: _selectedIndexes.length,
              theme: SwapShareTheme.presets[_selectedThemeIndex],
              onCancel: () => Navigator.of(context).pop(),
              onShare: _share,
            ),
          ],
        ),
      ),
    );
  }
}

class _SharePickerHeader extends StatelessWidget {
  const _SharePickerHeader({
    required this.selectedCount,
    required this.maxProducts,
  });

  final int selectedCount;
  final int maxProducts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.ios_share_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'اسأل الناس قبل ما تبدّل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'مختار $selectedCount من $maxProducts منتجات كحد أقصى',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.2,
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

class _SharePickerSectionTitle extends StatelessWidget {
  const _SharePickerSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0A7EA0),
            size: 17,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF123B52),
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6C8391),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.6,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShareProductSelectCard extends StatelessWidget {
  const _ShareProductSelectCard({
    required this.product,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final Product product;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  ImageProvider _imageProviderFor(Product p) {
    final String? raw = p.defaultPhoto?.imgPath;
    if (raw == null || raw.trim().isEmpty) {
      return const AssetImage('assets/images/img_placeholder.png');
    }

    final String path = raw.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    return NetworkImage('${PsConfig.ps_app_image_url}$path');
  }

  int _scoreOf(Product p) {
    return int.tryParse((p.swapScorePercent ?? '').toString().trim()) ?? 0;
  }

  String _priceOf(Product p) {
    final String low = (p.lowPrice ?? '').trim();
    final String high = (p.highPrice ?? '').trim();
    final String price = (p.price ?? '').trim();

    if (low.isNotEmpty && high.isNotEmpty && low != '0' && high != '0') {
      if (low == high) return '$low جنيه';
      return '$low - $high جنيه';
    }

    if (price.isNotEmpty && price != '0') return '$price جنيه';
    if (low.isNotEmpty && low != '0') return '$low جنيه';
    if (high.isNotEmpty && high != '0') return '$high جنيه';
    return 'السعر غير محدد';
  }

  @override
  Widget build(BuildContext context) {
    final int score = _scoreOf(product);
    final String label = product.title ?? 'منتج';
    final String price = _priceOf(product);
    final String condition = (product.conditionOfItem?.name ?? '').trim();
    final int safeLetterIndex = index < 0 ? 0 : (index > 4 ? 4 : index);
    final String letter = <String>['أ', 'ب', 'ج', 'د', 'هـ'][safeLetterIndex];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? const Color(0xFF24A9C4) : const Color(0xFFDCE8EE),
              width: selected ? 1.8 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: selected
                    ? const Color(0x3324A9C4)
                    : Colors.black.withValues(alpha: 0.035),
                blurRadius: selected ? 14 : 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? const Color(0xFF24A9C4)
                      : const Color(0xFFEAF4F7),
                ),
                alignment: Alignment.center,
                child: selected
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 19,
                )
                    : Text(
                  letter,
                  style: const TextStyle(
                    color: Color(0xFF526E7B),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image(
                  image: _imageProviderFor(product),
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 58,
                      height: 58,
                      color: const Color(0xFFE8F4F8),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF8AA6B8),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF123B52),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: <Widget>[
                        _ShareMiniChip(
                          text: price,
                          icon: Icons.payments_rounded,
                        ),
                        if (condition.isNotEmpty)
                          _ShareMiniChip(
                            text: condition,
                            icon: Icons.verified_rounded,
                          ),
                        if (score > 0)
                          _ShareMiniChip(
                            text: '$score%',
                            icon: Icons.auto_awesome_rounded,
                            highlighted: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareMiniChip extends StatelessWidget {
  const _ShareMiniChip({
    required this.text,
    required this.icon,
    this.highlighted = false,
  });

  final String text;
  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFF7E6) : const Color(0xFFF1F7FA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlighted ? const Color(0xFFFFD47A) : const Color(0xFFD8E8EF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 12,
            color: highlighted ? const Color(0xFF9A6200) : const Color(0xFF587381),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: highlighted ? const Color(0xFF8A5700) : const Color(0xFF526E7B),
              fontWeight: FontWeight.w800,
              fontSize: 10.3,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareThemeCard extends StatelessWidget {
  const _ShareThemeCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final SwapShareTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1.0 : 0.96,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 148,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: theme.gradient,
            ),
            border: Border.all(
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.42),
              width: selected ? 3 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.accentColor.withValues(alpha: selected ? 0.26 : 0.10),
                blurRadius: selected ? 16 : 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      theme.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: selected
                        ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: theme.primaryColor,
                    )
                        : null,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                theme.question,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SharePickerBottomBar extends StatelessWidget {
  const _SharePickerBottomBar({
    required this.selectedCount,
    required this.theme,
    required this.onCancel,
    required this.onShare,
  });

  final int selectedCount;
  final SwapShareTheme theme;
  final VoidCallback onCancel;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Color(0xFFD7E6EE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Color(0xFF526E7B),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: selectedCount == 0 ? null : onShare,
              icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
              label: Text(
                'شير $selectedCount منتجات',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: theme.accentColor,
                disabledBackgroundColor: const Color(0xFFB8CBD5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
