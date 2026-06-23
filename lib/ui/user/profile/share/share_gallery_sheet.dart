part of 'profile_share_gallery.dart';

class ProfileShareGalleryBanner extends StatelessWidget {
  const ProfileShareGalleryBanner({
    Key? key,
    required this.source,
    required this.products,
    this.profileUserId,
  }) : super(key: key);

  final ShareGallerySource source;
  final List<Product> products;

  /// Optional profile owner id used to build the share URL.
  ///
  /// Pass this from the profile screen whenever possible, especially for
  /// family gallery shares where selected products may belong to different
  /// family members.
  final String? profileUserId;

  bool get _isFamily => source == ShareGallerySource.familyGallery;

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> shareable = ShareProductMapper.fromProducts(products);
    if (shareable.length < _ShareGalleryDims.minSelectedProducts) return const SizedBox.shrink();

    final String title = _isFamily ? 'شارك منتجات معرض العائلة' : 'شارك منتجاتك';
    final String subtitle = _isFamily
        ? 'اختار من منتجات العيلة وشاركها في كارت لطيف'
        : 'اختار مجموعة منتجات وشاركها على اصحابك واقاربك';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => openShareGalleryPhase1Sheet(
              context,
              source: source,
              products: products,
              profileUserId: profileUserId,
            ),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: <Color>[Color(0xFFFFFFFF), Color(0xFFEAF8FB)],
                ),
                border: Border.all(color: const Color(0x3324A9C4)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _ShareGalleryColors.teal.withOpacity(0.09),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: <Color>[_ShareGalleryColors.teal, _ShareGalleryColors.aqua]),
                    ),
                    child: Icon(
                      _isFamily ? Icons.family_restroom_rounded : Icons.ios_share_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _ShareGalleryColors.text),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: _ShareGalleryColors.text.withOpacity(0.66),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    decoration: BoxDecoration(
                      color: _ShareGalleryColors.aqua.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'شارك',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _ShareGalleryColors.teal),
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

Future<void> openShareGalleryPhase1Sheet(
  BuildContext context, {
  required ShareGallerySource source,
  required List<Product> products,
  String? profileUserId,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ShareGalleryPhase1Sheet(
      source: source,
      products: products,
      profileUserId: profileUserId,
    ),
  );
}

class ShareGalleryPhase1Sheet extends StatefulWidget {
  const ShareGalleryPhase1Sheet({
    Key? key,
    required this.source,
    required this.products,
    this.profileUserId,
  }) : super(key: key);

  final ShareGallerySource source;
  final List<Product> products;
  final String? profileUserId;

  @override
  State<ShareGalleryPhase1Sheet> createState() => _ShareGalleryPhase1SheetState();
}

class _ShareGalleryPhase1SheetState extends State<ShareGalleryPhase1Sheet> {
  final Set<String> _selectedIds = <String>{};
  ShareGalleryThemeType _theme = ShareGalleryThemeType.playfulStickers;
  bool _preview = false;
  late String _smartText;

  List<Product> get _shareableProducts => widget.products
      .where((Product product) => ShareProductMapper.safeProductId(product).isNotEmpty)
      .take(_ShareGalleryDims.maxLoadedProducts)
      .toList(growable: false);

  List<Product> get _selectedProducts => _shareableProducts
      .where((Product product) => _selectedIds.contains(ShareProductMapper.safeProductId(product)))
      .take(_ShareGalleryDims.maxSelectedProducts)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    for (final Product product in _shareableProducts.take(math.min(
      _ShareGalleryDims.initialSelectedProducts,
      _shareableProducts.length,
    ))) {
      _selectedIds.add(ShareProductMapper.safeProductId(product));
    }
    _smartText = SmartShareTextResolver.resolve(products: _selectedProducts, source: widget.source);
  }

  void _refreshSmartText() {
    _smartText = SmartShareTextResolver.resolve(products: _selectedProducts, source: widget.source);
  }

  void _toggle(Product product) {
    final String id = ShareProductMapper.safeProductId(product);
    if (id.isEmpty) return;

    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        if (_selectedIds.length >= _ShareGalleryDims.maxSelectedProducts) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يمكنك اختيار حتى 8 منتجات فقط')),
          );
          return;
        }
        _selectedIds.add(id);
      }
      _refreshSmartText();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> selected = _selectedProducts;
    final double maxHeight = MediaQuery.of(context).size.height * 0.93;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: _ShareGalleryColors.softBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(color: const Color(0xFFB8CAD5), borderRadius: BorderRadius.circular(999)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _preview ? 'معاينة كارت المشاركة' : 'اختار منتجات المشاركة',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _ShareGalleryColors.text),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _preview
                      ? _PreviewStep(
                          key: const ValueKey<String>('preview'),
                          source: widget.source,
                          products: selected,
                          profileUserId: widget.profileUserId,
                          theme: _theme,
                          smartText: _smartText,
                          onThemeChanged: (ShareGalleryThemeType theme) => setState(() => _theme = theme),
                          onSmartTextChanged: (String value) => _smartText = value,
                        )
                      : _SelectStep(
                          key: const ValueKey<String>('select'),
                          products: _shareableProducts,
                          selectedIds: _selectedIds,
                          onToggle: _toggle,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: <Widget>[
                    if (_preview)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _preview = false),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('رجوع'),
                        ),
                      ),
                    if (_preview) const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _ShareGalleryColors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: selected.length < _ShareGalleryDims.minSelectedProducts
                            ? null
                            : () {
                                if (_preview) {
                                  ShareGalleryController.maybeShareCurrentPreview(context);
                                } else {
                                  setState(() => _preview = true);
                                }
                              },
                        icon: Icon(_preview ? Icons.ios_share_rounded : Icons.visibility_rounded),
                        label: Text(
                          _preview ? 'مشاركة الآن' : 'التالي (${selected.length})',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
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

class _SelectStep extends StatelessWidget {
  const _SelectStep({
    Key? key,
    required this.products,
    required this.selectedIds,
    required this.onToggle,
  }) : super(key: key);

  final List<Product> products;
  final Set<String> selectedIds;
  final ValueChanged<Product> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'اختار من 2 إلى 5 منتجات. سيتم إنشاء صورة جاهزة للمشاركة.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: _ShareGalleryColors.text.withOpacity(0.66),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _SelectionCounter(count: selectedIds.length),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (BuildContext context, int index) {
              final Product product = products[index];
              final String id = ShareProductMapper.safeProductId(product);
              return _PickProductCard(
                product: ShareProductMapper.fromProduct(product),
                selected: selectedIds.contains(id),
                onTap: () => onToggle(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SelectionCounter extends StatelessWidget {
  const _SelectionCounter({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: _ShareGalleryColors.teal, borderRadius: BorderRadius.circular(999)),
      child: Text('$count / 8', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class _PickProductCard extends StatelessWidget {
  const _PickProductCard({required this.product, required this.selected, required this.onTap});

  final ShareProductViewData? product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ShareProductViewData? item = product;
    if (item == null) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: selected ? 2 : 1,
              color: selected ? _ShareGalleryColors.aqua : const Color(0xFFE0EAF0),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: selected ? _ShareGalleryColors.aqua.withOpacity(0.18) : Colors.black.withOpacity(0.04),
                blurRadius: selected ? 14 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: _ProductImageView(image: item.imageUrl),
                    ),
                  ),
                  if (item.hasTitle)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                      child: Text(
                        item.title!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: _ShareGalleryColors.text,
                        ),
                      ),
                    ),
                ],
              ),
              PositionedDirectional(
                top: 6,
                end: 6,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? _ShareGalleryColors.aqua : Colors.white.withOpacity(0.92),
                    border: Border.all(color: _ShareGalleryColors.aqua),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.add_rounded,
                    color: selected ? Colors.white : _ShareGalleryColors.aqua,
                    size: 17,
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

class _PreviewStep extends StatefulWidget {
  const _PreviewStep({
    Key? key,
    required this.source,
    required this.products,
    this.profileUserId,
    required this.theme,
    required this.smartText,
    required this.onThemeChanged,
    required this.onSmartTextChanged,
  }) : super(key: key);

  final ShareGallerySource source;
  final List<Product> products;
  final String? profileUserId;
  final ShareGalleryThemeType theme;
  final String smartText;
  final ValueChanged<ShareGalleryThemeType> onThemeChanged;
  final ValueChanged<String> onSmartTextChanged;

  @override
  State<_PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<_PreviewStep> {
  final GlobalKey _previewKey = GlobalKey();
  late final TextEditingController _textController;
  late final PageController _themePageController;
  late int _currentThemeIndex;

  @override
  void initState() {
    super.initState();
    _currentThemeIndex = _themeIndexOf(widget.theme);
    _themePageController = PageController(initialPage: _currentThemeIndex, viewportFraction: 0.74);
    _textController = TextEditingController(text: widget.smartText);
    _registerPreview();
  }

  @override
  void didUpdateWidget(covariant _PreviewStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int newThemeIndex = _themeIndexOf(widget.theme);
    if (newThemeIndex != _currentThemeIndex) {
      _currentThemeIndex = newThemeIndex;
      if (_themePageController.hasClients) {
        _themePageController.animateToPage(_currentThemeIndex, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
      }
    }
    if (oldWidget.smartText != widget.smartText && _textController.text != widget.smartText) {
      _textController.text = widget.smartText;
    }
    _registerPreview();
  }

  @override
  void dispose() {
    ShareGalleryController.clearPreview(_previewKey);
    _themePageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _registerPreview() {
    ShareGalleryController.registerPreview(
      key: _previewKey,
      products: widget.products,
      smartText: _textController.text,
      source: widget.source,
      profileUserId: widget.profileUserId,
    );
  }

  int _themeIndexOf(ShareGalleryThemeType type) {
    final int index = kShareGalleryThemes.indexWhere((ShareGalleryThemeConfig e) => e.type == type);
    return index < 0 ? 0 : index;
  }

  void _changeThemeByPage(int index) {
    if (index < 0 || index >= kShareGalleryThemes.length) return;
    setState(() => _currentThemeIndex = index);
    widget.onThemeChanged(kShareGalleryThemes[index].type);
    _registerPreview();
  }

  void _jumpToTheme(int index) {
    if (index < 0 || index >= kShareGalleryThemes.length) return;
    _themePageController.animateToPage(index, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    _changeThemeByPage(index);
  }

  double _previewViewportHeight(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight >= 920) return 560;
    if (screenHeight >= 850) return 525;
    if (screenHeight >= 780) return 490;
    return 445;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 14),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'اسحب يمين أو يسار لتغيير شكل كارت المشاركة',
                  style: TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w700, color: _ShareGalleryColors.text.withOpacity(0.62)),
                ),
              ),
              const Icon(Icons.swipe_rounded, size: 19, color: _ShareGalleryColors.aqua),
              const SizedBox(width: 6),
              Text(
                '${_currentThemeIndex + 1}/${kShareGalleryThemes.length}',
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _ShareGalleryColors.teal),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _previewViewportHeight(context),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              PageView.builder(
                controller: _themePageController,
                clipBehavior: Clip.none,
                physics: const BouncingScrollPhysics(),
                itemCount: kShareGalleryThemes.length,
                onPageChanged: _changeThemeByPage,
                itemBuilder: (BuildContext context, int index) {
                  final ShareGalleryThemeType theme = kShareGalleryThemes[index].type;
                  final bool selected = index == _currentThemeIndex;
                  return AnimatedScale(
                    scale: selected ? 1.0 : 0.90,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: selected ? 1.0 : 0.42,
                      duration: const Duration(milliseconds: 180),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: RepaintBoundary(
                            key: selected ? _previewKey : null,
                            child: ShareGalleryCanvas(
                              source: widget.source,
                              products: widget.products,
                              theme: theme,
                              smartText: _textController.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              PositionedDirectional(
                start: 7,
                child: _ThemeNavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _jumpToTheme(_currentThemeIndex - 1),
                  enabled: _currentThemeIndex > 0,
                ),
              ),
              PositionedDirectional(
                end: 7,
                child: _ThemeNavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _jumpToTheme(_currentThemeIndex + 1),
                  enabled: _currentThemeIndex < kShareGalleryThemes.length - 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _ThemeDots(count: kShareGalleryThemes.length, index: _currentThemeIndex, onTap: _jumpToTheme),
      ],
    );
  }
}

class _ThemeNavButton extends StatelessWidget {
  const _ThemeNavButton({required this.icon, required this.onTap, required this.enabled});
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.22,
      child: Material(
        color: Colors.white.withOpacity(0.92),
        shape: const CircleBorder(),
        elevation: 5,
        shadowColor: _ShareGalleryColors.teal.withOpacity(0.18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(width: 34, height: 34, child: Icon(icon, color: _ShareGalleryColors.teal, size: 25)),
        ),
      ),
    );
  }
}

class _ThemeDots extends StatelessWidget {
  const _ThemeDots({required this.count, required this.index, required this.onTap});
  final int count;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: List<Widget>.generate(count, (int i) {
        final bool selected = i == index;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: selected ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: selected ? _ShareGalleryColors.aqua : const Color(0xFFC9D8DF),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
