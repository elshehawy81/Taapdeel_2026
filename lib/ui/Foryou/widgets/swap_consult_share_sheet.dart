import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_config.dart';

import '../widgets/swap_whatsapp_share_service.dart';
import '../widgets/swap_share_image_renderer.dart';
import '../../../../../viewobject/product.dart';

// =============================================================
// SwapWhatsAppShareButton
// زرار "استشير صحابك/قرايبك" — يفتح اختيار المنتجات والثيم قبل الشير
// =============================================================
class SwapWhatsAppShareButton extends StatefulWidget {
  const SwapWhatsAppShareButton({
    required this.myProduct,
    required this.suggestions,
  });

  final Product? myProduct;
  final List<Product> suggestions;

  @override
  State<SwapWhatsAppShareButton> createState() =>
      _SwapWhatsAppShareButtonState();
}

class _SwapWhatsAppShareButtonState extends State<SwapWhatsAppShareButton> {
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
          height: 45,
          width: 160,
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
                  'إستشير أصدقاءك',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.2,
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
  bool _selectingTheme = false;

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

  List<Product> _selectedProducts() {
    final List<int> orderedIndexes = _selectedIndexes.toList()..sort();
    return orderedIndexes
        .where((int index) => index >= 0 && index < widget.suggestions.length)
        .map((int index) => widget.suggestions[index])
        .toList(growable: false);
  }

  void _goToThemes() {
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

    setState(() => _selectingTheme = true);
  }

  void _share() {
    final List<Product> selectedProducts = _selectedProducts();
    if (selectedProducts.isEmpty) {
      _goToThemes();
      return;
    }

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
                selectingTheme: _selectingTheme,
                selectedCount: _selectedIndexes.length,
                maxProducts: _maxProducts,
                onBack: _selectingTheme
                    ? () => setState(() => _selectingTheme = false)
                    : null,
              ),
            ),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _selectingTheme
                    ? _ThemeSelectionStep(
                  key: const ValueKey<String>('theme_step'),
                  myProduct: widget.myProduct,
                  selectedThemeIndex: _selectedThemeIndex,
                  selectedProducts: _selectedProducts(),
                  onThemeSelected: (int index) {
                    setState(() => _selectedThemeIndex = index);
                  },
                )
                    : _ProductSelectionStep(
                  key: const ValueKey<String>('products_step'),
                  suggestions: widget.suggestions,
                  selectedIndexes: _selectedIndexes,
                  maxProducts: _maxProducts,
                  onToggleProduct: _toggleProduct,
                ),
              ),
            ),
            _SharePickerBottomBar(
              selectingTheme: _selectingTheme,
              selectedCount: _selectedIndexes.length,
              onCancel: () {
                if (_selectingTheme) {
                  setState(() => _selectingTheme = false);
                  return;
                }
                Navigator.of(context).pop();
              },
              onPrimary: _selectingTheme ? _share : _goToThemes,
            ),
          ],
        ),
      ),
    );
  }
}

class _SharePickerHeader extends StatelessWidget {
  const _SharePickerHeader({
    required this.selectingTheme,
    required this.selectedCount,
    required this.maxProducts,
    required this.onBack,
  });

  final bool selectingTheme;
  final int selectedCount;
  final int maxProducts;
  final VoidCallback? onBack;

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
          if (onBack != null) ...<Widget>[
            Material(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onBack,
                child: const SizedBox(
                  width: 39,
                  height: 39,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ] else ...<Widget>[
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
          ],
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  selectingTheme
                      ? 'اختار شكل الاستشارة'
                      : 'استشير إيه أنسب فرصة تبديل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectingTheme
                      ? 'الثيم هيظهر بصورة مصغرة قبل المشاركة.'
                      : 'مختار $selectedCount من $maxProducts منتجات كحد أقصى',
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

class _ProductSelectionStep extends StatelessWidget {
  const _ProductSelectionStep({
    Key? key,
    required this.suggestions,
    required this.selectedIndexes,
    required this.maxProducts,
    required this.onToggleProduct,
  }) : super(key: key);

  final List<Product> suggestions;
  final Set<int> selectedIndexes;
  final int maxProducts;
  final ValueChanged<int> onToggleProduct;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SharePickerSectionTitle(
            icon: Icons.inventory_2_rounded,
            title: 'اختار المنتجات اللي تحب تسأل عنها',
            subtitle:
            'اعرض المنتجات في كروت واضحة، ويمكنك اختيار حتى $maxProducts منتجات.',
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 9),
            itemBuilder: (BuildContext context, int index) {
              final Product product = suggestions[index];
              return _ShareProductSelectCard(
                product: product,
                index: index,
                selected: selectedIndexes.contains(index),
                onTap: () => onToggleProduct(index),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeSelectionStep extends StatefulWidget {
  const _ThemeSelectionStep({
    Key? key,
    required this.myProduct,
    required this.selectedThemeIndex,
    required this.selectedProducts,
    required this.onThemeSelected,
  }) : super(key: key);

  final Product? myProduct;
  final int selectedThemeIndex;
  final List<Product> selectedProducts;
  final ValueChanged<int> onThemeSelected;

  @override
  State<_ThemeSelectionStep> createState() => _ThemeSelectionStepState();
}

class _ThemeSelectionStepState extends State<_ThemeSelectionStep> {
  late final PageController _themePageController;
  late int _currentThemeIndex;

  @override
  void initState() {
    super.initState();
    _currentThemeIndex = widget.selectedThemeIndex.clamp(
      0,
      SwapShareTheme.presets.length - 1,
    ).toInt();
    _themePageController = PageController(initialPage: _currentThemeIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmUpPreviews());
  }

  @override
  void didUpdateWidget(covariant _ThemeSelectionStep oldWidget) {
    super.didUpdateWidget(oldWidget);

    final int safeExternalIndex = widget.selectedThemeIndex.clamp(
      0,
      SwapShareTheme.presets.length - 1,
    ).toInt();

    if (safeExternalIndex != _currentThemeIndex) {
      _currentThemeIndex = safeExternalIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_themePageController.hasClients) return;
        _themePageController.animateToPage(
          _currentThemeIndex,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
      });
    }

    final bool productsChanged = oldWidget.selectedProducts.length !=
        widget.selectedProducts.length;
    if (productsChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _warmUpPreviews());
    }
  }

  @override
  void dispose() {
    _themePageController.dispose();
    super.dispose();
  }

  void _warmUpPreviews() {
    final Product previewMyProduct = widget.myProduct ?? Product();
    final List<Product> selectedProducts = widget.selectedProducts
        .take(5)
        .toList(growable: false);
    final List<Product> safeSuggestions = selectedProducts.isEmpty
        ? <Product>[Product()]
        : selectedProducts;

    SwapShareImageRenderer.warmUpThemePreviews(
      myProduct: previewMyProduct,
      suggestions: safeSuggestions,
      selectedIndex: _currentThemeIndex,
    );
  }

  void _selectTheme(int index, {bool animate = true}) {
    if (index < 0 || index >= SwapShareTheme.presets.length) return;

    setState(() => _currentThemeIndex = index);
    widget.onThemeSelected(index);

    if (animate && _themePageController.hasClients) {
      _themePageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goNext() {
    if (_currentThemeIndex >= SwapShareTheme.presets.length - 1) return;
    _selectTheme(_currentThemeIndex + 1);
  }

  void _goPrev() {
    if (_currentThemeIndex <= 0) return;
    _selectTheme(_currentThemeIndex - 1);
  }

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;
    final double previewHeight = screenH < 760 ? 330 : 380;
    final bool canPrev = _currentThemeIndex > 0;
    final bool canNext = _currentThemeIndex < SwapShareTheme.presets.length - 1;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _SharePickerSectionTitle(
            icon: Icons.palette_rounded,
            title: 'اختار ثيم الاستشارة',
            subtitle: '',
          ),
          const SizedBox(height: 10),
          _ThemeNamesChipsBar(
            selectedIndex: _currentThemeIndex,
            onSelected: _selectTheme,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: previewHeight,
            child: Row(
              children: <Widget>[
                _ThemeArrowButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: canPrev,
                  onTap: _goPrev,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PageView.builder(
                    controller: _themePageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: SwapShareTheme.presets.length,
                    onPageChanged: (int index) {
                      setState(() => _currentThemeIndex = index);
                      widget.onThemeSelected(index);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final SwapShareTheme theme = SwapShareTheme.presets[index];
                      return _ShareThemePreviewCard(
                        theme: theme,
                        myProduct: widget.myProduct,
                        products: widget.selectedProducts,
                        selected: index == _currentThemeIndex,
                        onTap: () => _selectTheme(index, animate: false),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _ThemeArrowButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: canNext,
                  onTap: _goNext,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _ThemePagerDots(
            selectedIndex: _currentThemeIndex,
            count: SwapShareTheme.presets.length,
            onDotTap: _selectTheme,
          ),
        ],
      ),
    );
  }
}

class _ThemeNamesChipsBar extends StatelessWidget {
  const _ThemeNamesChipsBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: SwapShareTheme.presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (BuildContext context, int index) {
          final SwapShareTheme theme = SwapShareTheme.presets[index];
          final bool selected = index == selectedIndex;

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? theme.accentColor : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? theme.accentColor
                        : const Color(0xFFD8E8EF),
                    width: 1,
                  ),
                  boxShadow: selected
                      ? <BoxShadow>[
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.22),
                      blurRadius: 9,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : const <BoxShadow>[],
                ),
                child: Text(
                  theme.shortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF123B52),
                    fontWeight: FontWeight.w900,
                    fontSize: 11.2,
                    height: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThemeArrowButton extends StatelessWidget {
  const _ThemeArrowButton({
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Ink(
              width: 34,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFD8E8EF),
                  width: 1,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x120C587A),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0C587A),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemePagerDots extends StatelessWidget {
  const _ThemePagerDots({
    required this.selectedIndex,
    required this.count,
    required this.onDotTap,
  });

  final int selectedIndex;
  final int count;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool selected = index == selectedIndex;
        final SwapShareTheme theme = SwapShareTheme.presets[index];

        return GestureDetector(
          onTap: () => onDotTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 22 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: selected ? theme.accentColor : const Color(0xFFCFE0E8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
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
      return const ResizeImage(
        AssetImage('assets/images/img_placeholder.png'),
        width: 132,
        height: 132,
      );
    }

    final String path = raw.trim();
    final String url = path.startsWith('http://') || path.startsWith('https://')
        ? path
        : '${PsConfig.ps_app_image_url}$path';

    return ResizeImage(
      NetworkImage(url),
      width: 132,
      height: 132,
    );
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
    final String label = product.title ?? 'منتج';
    final String price = _priceOf(product);
    final String condition = (product.conditionOfItem?.name ?? '').trim();

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
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image(
                  image: _imageProviderFor(product),
                  width: 66,
                  height: 66,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 66,
                      height: 66,
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
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 6),
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
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                      : const Icon(
                    Icons.do_not_disturb_on_rounded,
                    color: Colors.white,
                    size: 19,
                  )
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



class _ShareThemePreviewCard extends StatefulWidget {
  const _ShareThemePreviewCard({
    required this.theme,
    required this.myProduct,
    required this.products,
    required this.selected,
    required this.onTap,
  });

  final SwapShareTheme theme;
  final Product? myProduct;
  final List<Product> products;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ShareThemePreviewCard> createState() => _ShareThemePreviewCardState();
}

class _ShareThemePreviewCardState extends State<_ShareThemePreviewCard> {
  late Future<Uint8List> _previewFuture;
  late String _signature;

  @override
  void initState() {
    super.initState();
    _signature = _buildSignature();
    _previewFuture = _buildPreview();
  }

  @override
  void didUpdateWidget(covariant _ShareThemePreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String nextSignature = _buildSignature();
    if (nextSignature != _signature) {
      _signature = nextSignature;
      _previewFuture = _buildPreview();
    }
  }

  String _buildSignature() {
    final String myId = _productIdentity(widget.myProduct);
    final String productsIds = widget.products
        .take(5)
        .map(_productIdentity)
        .join('|');
    return '${widget.theme.id}::$myId::$productsIds';
  }

  String _productIdentity(Product? product) {
    if (product == null) return 'empty';
    final String id = (product.id ?? '').toString().trim();
    if (id.isNotEmpty && id.toLowerCase() != 'null') return id;
    final String title = (product.title ?? '').trim();
    final String image = (product.defaultPhoto?.imgPath ?? '').trim();
    return '$title::$image::${product.hashCode}';
  }

  Future<Uint8List> _buildPreview() {
    final Product previewMyProduct = widget.myProduct ?? Product();
    final List<Product> selectedProducts = widget.products
        .take(5)
        .toList(growable: false);

    final List<Product> safeSuggestions = selectedProducts.isEmpty
        ? <Product>[Product()]
        : selectedProducts;

    return SwapShareImageRenderer.buildImageBytes(
      myProduct: previewMyProduct,
      suggestions: safeSuggestions,
      theme: widget.theme,
      preview: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: widget.selected ? 1.0 : 0.97,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white,
              border: Border.all(
                color: widget.selected
                    ? widget.theme.accentColor
                    : const Color(0xFFDCE8EE),
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: widget.selected
                      ? widget.theme.accentColor.withValues(alpha: 0.24)
                      : Colors.black.withValues(alpha: 0.035),
                  blurRadius: widget.selected ? 14 : 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.theme.backgroundColor,
                      ),
                      child: FutureBuilder<Uint8List>(
                        future: _previewFuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<Uint8List> snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) {
                            return _SharePreviewLoading(theme: widget.theme);
                          }

                          if (!snapshot.hasData || snapshot.hasError) {
                            return _SharePreviewFallback(theme: widget.theme);
                          }

                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            filterQuality: FilterQuality.low,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.theme.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF123B52),
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.theme.bestUseForCount(widget.products.length),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6C8391),
                              fontWeight: FontWeight.w700,
                              fontSize: 9.4,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? widget.theme.accentColor
                            : const Color(0xFFEAF4F7),
                        shape: BoxShape.circle,
                      ),
                      child: widget.selected
                          ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SharePreviewLoading extends StatelessWidget {
  const _SharePreviewLoading({required this.theme});

  final SwapShareTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      alignment: Alignment.center,
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: theme.accentColor,
        ),
      ),
    );
  }
}

class _SharePreviewFallback extends StatelessWidget {
  const _SharePreviewFallback({required this.theme});

  final SwapShareTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.image_not_supported_outlined,
            color: theme.accentColor,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            'تعذر تجهيز المعاينة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SharePickerBottomBar extends StatelessWidget {
  const _SharePickerBottomBar({
    required this.selectingTheme,
    required this.selectedCount,
    required this.onCancel,
    required this.onPrimary,
  });

  final bool selectingTheme;
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final String primaryText = selectingTheme
        ? 'مشاركة $selectedCount منتجات'
        : 'اختار الثيم';

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
              child: Text(
                selectingTheme ? 'رجوع' : 'إلغاء',
                style: const TextStyle(
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
              onPressed: selectedCount == 0 ? null : onPrimary,
              icon: Icon(
                selectingTheme
                    ? Icons.ios_share_rounded
                    : Icons.palette_rounded,
                color: Colors.white,
              ),
              label: Text(
                primaryText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFF13CFD8),
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
