part of 'suggested_swaps_section.dart';


class _SuggestedSwapHeaderActions extends StatelessWidget {
  const _SuggestedSwapHeaderActions({
    required this.activeFilterCount,
    required this.filteredCount,
    required this.totalCount,
    required this.onOpenFilters,
    required this.onEditInterests,
    required this.showEditInterestsLabel,
    this.playEditInterestsAttention = false,
  });

  final int activeFilterCount;
  final int filteredCount;
  final int totalCount;
  final VoidCallback onOpenFilters;
  final VoidCallback onEditInterests;
  final bool showEditInterestsLabel;
  final bool playEditInterestsAttention;

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = activeFilterCount > 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _HeaderEditInterestsButton(
              highlighted: showEditInterestsLabel,
              playAttention: playEditInterestsAttention,
              onTap: onEditInterests,
            ),
            const SizedBox(width: 4),
            _SuggestedSwapFilterButton(
              activeFilterCount: activeFilterCount,
              visibleCount: filteredCount,
              totalCount: totalCount,
              hasActiveFilters: hasActiveFilters,
              onTap: onOpenFilters,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderEditInterestsButton extends StatefulWidget {
  const _HeaderEditInterestsButton({
    required this.highlighted,
    required this.playAttention,
    required this.onTap,
  });

  final bool highlighted;
  final bool playAttention;
  final VoidCallback onTap;

  // يحفظ أن المستخدم ضغط الزر خلال عمر التطبيق الحالي
  // حتى لو الصفحة اتعملها rebuild أو الزر اتبنى من جديد.
  static bool _attentionDismissed = false;

  @override
  State<_HeaderEditInterestsButton> createState() =>
      _HeaderEditInterestsButtonState();
}

class _HeaderEditInterestsButtonState
    extends State<_HeaderEditInterestsButton> {
  void _handleTap() {
    if (!_HeaderEditInterestsButton._attentionDismissed) {
      setState(() {
        _HeaderEditInterestsButton._attentionDismissed = true;
      });
    }

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldPlayAttention =
    !_HeaderEditInterestsButton._attentionDismissed;

    final Color foregroundColor =
    widget.highlighted ? const Color(0xFF231307) : Colors.white;

    final Widget button = Tooltip(
      message: 'عدل اهتماماتك',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 31,
            width: 104,
            padding: const EdgeInsetsDirectional.only(start: 8, end: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.highlighted
                  ? Colors.white.withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: widget.highlighted
                    ? Colors.white.withValues(alpha: 0.86)
                    : Colors.white.withValues(alpha: 0.28),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                if (widget.highlighted)
                  const BoxShadow(
                    color: Color(0x33FFB020),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(
                  Icons.edit_rounded,
                  size: 12,
                  color: foregroundColor,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    'عدل اهتماماتك',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 8.7,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return _OneShotAttentionPulse(
      play: shouldPlayAttention,
      maxScale: 0.055,
      repeatUntilStopped: true,
      child: button,
    );
  }
}


class _SuggestedSwapsProductsBar extends StatelessWidget {
  const _SuggestedSwapsProductsBar({
    required this.products,
    required this.selectedProductId,
    required this.selectedRecommendationsCount,
    required this.onTapProduct,
  });

  final List<Product> products;
  final String? selectedProductId;
  final int selectedRecommendationsCount;
  final ValueChanged<int> onTapProduct;

  ImageProvider _imageProviderFor(Product product) {
    final String? raw = product.defaultPhoto?.imgPath;

    if (raw == null || raw.trim().isEmpty) {
      return const AssetImage('assets/images/img_placeholder.png');
    }

    final String path = raw.trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    return NetworkImage('${PsConfig.ps_app_image_url}$path');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasProducts = products.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: hasProducts ? 66 : 44,
        margin: const EdgeInsetsDirectional.only(start: 2, end: 2),
        padding: EdgeInsetsDirectional.fromSTEB(
          10,
          hasProducts ? 7 : 9,
          9,
          hasProducts ? 7 : 9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFD8EFF5),
            width: 1,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x120C587A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              height: 34,
              padding: const EdgeInsetsDirectional.only(start: 10, end: 11),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8FC),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFBFEAF0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.touch_app_rounded,
                    color: Color(0xFF0C587A),
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'اختر منتجك',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF123B52),
                      fontWeight: FontWeight.w900,
                      fontSize: 11.8,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            if (hasProducts) ...<Widget>[
              const SizedBox(width: 10),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final Product product = products[index];
                    final String productId =
                    (product.id ?? '').toString().trim();
                    final bool selected = productId.isNotEmpty &&
                        productId == (selectedProductId ?? '').trim();

                    return _MyProductQuickImageChip(
                      imageProvider: _imageProviderFor(product),
                      selected: selected,
                      count: selected ? selectedRecommendationsCount : null,
                      isPending: isProductPendingApproval(product),
                      onTap: () => onTapProduct(index),
                    );
                  },
                ),
              ),
            ] else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _SuggestedSwapFilterButton extends StatelessWidget {
  const _SuggestedSwapFilterButton({
    required this.activeFilterCount,
    required this.visibleCount,
    required this.totalCount,
    required this.hasActiveFilters,
    required this.onTap,
  });

  final int activeFilterCount;
  final int visibleCount;
  final int totalCount;
  final bool hasActiveFilters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String tooltipMessage = totalCount > 0
        ? 'تصفية الترشيحات ($visibleCount من $totalCount)'
        : 'تصفية الترشيحات';

    return Tooltip(
      message: tooltipMessage,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: hasActiveFilters ? 74 : 70,
            height: 31,
            padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hasActiveFilters
                  ? Colors.white.withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: hasActiveFilters
                    ? Colors.white.withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Icon(
                      Icons.filter_alt_rounded,
                      size: 12.5,
                      color: hasActiveFilters
                          ? const Color(0xFF231307)
                          : Colors.white,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'تصفية',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        softWrap: false,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: hasActiveFilters
                              ? const Color(0xFF231307)
                              : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 9.0,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                if (activeFilterCount > 0)
                  PositionedDirectional(
                    top: -9,
                    end: -7,
                    child: Container(
                      height: 16,
                      constraints: const BoxConstraints(minWidth: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: Text(
                        activeFilterCount > 9 ? '9+' : '$activeFilterCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 8.4,
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
    );
  }
}

class _RecommendationBoosterBar extends StatelessWidget {
  const _RecommendationBoosterBar({
    required this.onEditInterests,
    required this.onOpenFamily,
    this.showSmartHint = false,
  });

  final VoidCallback onEditInterests;
  final VoidCallback onOpenFamily;
  final bool showSmartHint;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        height: showSmartHint ? 92 : 46,
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
            color: showSmartHint
                ? const Color(0xFF19D4E2)
                : const Color(0xFFD8EFF5),
            width: showSmartHint ? 1.4 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: showSmartHint
                  ? const Color(0x3319D4E2)
                  : const Color(0x0D0C587A),
              blurRadius: showSmartHint ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: showSmartHint
                  ? const Padding(
                key: ValueKey<String>('improve_smart_hint'),
                padding: EdgeInsetsDirectional.only(bottom: 7),
                child: _RecommendationImproveHintBanner(),
              )
                  : const SizedBox.shrink(
                key: ValueKey<String>('improve_smart_hint_empty'),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: 2,
                  separatorBuilder: (_, __) => const SizedBox(width: 15),
                  itemBuilder: (BuildContext context, int index) {
                    switch (index) {
                      case 0:
                        return _RecommendationBoosterChip(
                          label: 'عدل اهتماماتك',
                          icon: Icons.tune_rounded,
                          onTap: onEditInterests,
                        );
                      default:
                        return _RecommendationBoosterChip(
                          label: 'أضف عائلتك واصدقاءك',
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

class _TrustedNetworkHintSection extends StatefulWidget {
  const _TrustedNetworkHintSection({
    required this.onVisible,
    required this.onTap,
    this.playButtonAttention = false,
  });

  final VoidCallback onVisible;
  final VoidCallback onTap;
  final bool playButtonAttention;

  @override
  State<_TrustedNetworkHintSection> createState() =>
      _TrustedNetworkHintSectionState();
}

class _TrustedNetworkHintSectionState extends State<_TrustedNetworkHintSection> {
  bool _didNotifyVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didNotifyVisible) return;
      _didNotifyVisible = true;
      widget.onVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutBack,
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsetsDirectional.fromSTEB(13, 13, 13, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[
                Color(0xFF123B52),
                Color(0xFF0C587A),
                Color(0xFF17B8C7),
              ],
            ),
            border: Border.all(
              color: Color(0xFFB8F4FF),
              width: 1.2,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x3319D4E2),
                blurRadius: 22,
                spreadRadius: 1,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.26),
                      ),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'لترشيحات أفضل وأكثر ثقة',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'أضف أصدقاءك وعائلتك لعرض ترشيحات تبديل افضل من دايرتك القريبة.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.86),
                            fontWeight: FontWeight.w800,
                            fontSize: 11.4,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: _OneShotAttentionPulse(
                  play: widget.playButtonAttention,
                  maxScale: 0.075,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: widget.onTap,
                      child: Ink(
                        height: 38,
                        padding: const EdgeInsetsDirectional.only(
                          start: 13,
                          end: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Color(0xFF0C587A),
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'أضف أصدقاءك وعائلتك',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF0C587A),
                                fontWeight: FontWeight.w900,
                                fontSize: 10.8,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
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


class _MyProductQuickImageChip extends StatelessWidget {
  const _MyProductQuickImageChip({
    required this.imageProvider,
    required this.selected,
    required this.count,
    required this.isPending,
    required this.onTap,
  });

  final ImageProvider imageProvider;
  final bool selected;
  final int? count;
  final bool isPending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(14);
    final String? countText = count == null
        ? null
        : count! > 99
        ? '99+'
        : '$count فرصة ';

    return SizedBox(
      width: 48,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF19D4E2)
                          : const Color(0xFFD3E9F0),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: <BoxShadow>[
                      if (selected)
                        const BoxShadow(
                          color: Color(0x2A21C9D7),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      else
                        const BoxShadow(
                          color: Color(0x0D0C587A),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: const Color(0xFFE8F4F8),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF8AA6B8),
                            size: 18,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (countText != null)
            PositionedDirectional(
              top: 30,
              end: 0,
              child: Container(
                constraints: const BoxConstraints(minWidth: 22),
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 6),
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
                  countText,
                  style: const TextStyle(
                    color: Color(0xFF231307),
                    fontWeight: FontWeight.w800,
                    fontSize: 8,
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

class _RecommendationImproveHintBanner extends StatelessWidget {
  const _RecommendationImproveHintBanner();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutBack,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(9, 7, 9, 7),
        decoration: BoxDecoration(
          color: const Color(0xFFE6FAFD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBFEAF0)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0C587A),
              ),
              child: const Icon(
                Icons.auto_fix_high_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'حسّن فرص التبديل',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF123B52),
                      fontWeight: FontWeight.w900,
                      fontSize: 11.8,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'عدّل اهتماماتك أو أضف أصدقاءك وأقاربك لنتائج أدق.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF587688),
                      fontWeight: FontWeight.w800,
                      fontSize: 9.8,
                      height: 1.05,
                    ),
                  ),
                ],
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


enum _SuggestedSwapHideScope {
  allProducts,
  thisProductOnly,
}

class _SuggestedSwapHideBottomSheet extends StatefulWidget {
  const _SuggestedSwapHideBottomSheet();

  @override
  State<_SuggestedSwapHideBottomSheet> createState() =>
      _SuggestedSwapHideBottomSheetState();
}

class _SuggestedSwapHideBottomSheetState
    extends State<_SuggestedSwapHideBottomSheet> {
  _SuggestedSwapHideScope _scope = _SuggestedSwapHideScope.allProducts;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 22,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5E7EE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.visibility_off_rounded,
                      color: Color(0xFFF97316),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'إخفاء هذا الترشيح؟',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF123B52),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SuggestedSwapHideOptionTile(
                title: 'إخفاء الترشيح مع كل المنتجات',
                subtitle: 'لن يظهر هذا المنتج مرة أخرى كترشيح لأي منتج من منتجاتك.',
                value: _SuggestedSwapHideScope.allProducts,
                groupValue: _scope,
                onChanged: (value) => setState(() => _scope = value),
              ),
              const SizedBox(height: 8),
              _SuggestedSwapHideOptionTile(
                title: 'إخفاء مع هذا المنتج فقط',
                subtitle: 'سيظل المنتج ممكن يظهر كترشيح لمنتجاتك الأخرى.',
                value: _SuggestedSwapHideScope.thisProductOnly,
                groupValue: _scope,
                onChanged: (value) => setState(() => _scope = value),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        side: const BorderSide(color: Color(0xFFBFEAF0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          color: Color(0xFF0C587A),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_scope),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        backgroundColor: const Color(0xFF0C587A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'تأكيد الإخفاء',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
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

class _SuggestedSwapHideOptionTile extends StatelessWidget {
  const _SuggestedSwapHideOptionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final _SuggestedSwapHideScope value;
  final _SuggestedSwapHideScope groupValue;
  final ValueChanged<_SuggestedSwapHideScope> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool selected = value == groupValue;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 8, 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE6FAFD) : const Color(0xFFF9FCFD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? const Color(0xFF19D4E2) : const Color(0xFFE2F1F6),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Radio<_SuggestedSwapHideScope>(
                value: value,
                groupValue: groupValue,
                activeColor: const Color(0xFF0C587A),
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF123B52),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF6B8594),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 1.25,
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


class _PendingMyProductReviewNotice extends StatelessWidget {
  const _PendingMyProductReviewNotice();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(1, 0, 1, 12),
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[
              Color(0xFFFFFBEB),
              Color(0xFFFFF7D6),
              Color(0xFFFFFFFF),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFACC15).withValues(alpha: 0.62),
            width: 1.15,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x18F59E0B),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3C4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFACC15).withValues(alpha: 0.72),
                ),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFFB45309),
                size: 17,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'منتجك تحت المراجعة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF7C2D12),
                      fontWeight: FontWeight.w900,
                      fontSize: 12.8,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'يمكنك طلب التبديل بعد موافقة الأدمن على نشر المنتج.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8A5A10),
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionHideButton extends StatelessWidget {
  const _SuggestionHideButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFD6C2),
              width: 1,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 18,
            color: Color(0xFFF97316),
          ),
        ),
      ),
    );
  }
}



class _SuggestionCardRequestSwapButton extends StatelessWidget {
  const _SuggestionCardRequestSwapButton({
    required this.enabled,
    required this.pendingMyProduct,
    required this.loading,
    required this.onTap,
  });

  final bool enabled;
  final bool pendingMyProduct;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool canTap = enabled && !pendingMyProduct && !loading;
    final String label = pendingMyProduct
        ? 'اطلب التبديل'
        : canTap
        ? 'اطلب التبديل'
        : 'طلب التبديل غير متاح الآن';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: canTap ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: canTap
                ? const LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: <Color>[
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
              ],
            )
                : null,
            color: canTap ? null : const Color(0xFFE7F4F7),
            border: Border.all(
              color: canTap
                  ? const Color(0xFF19D4E2)
                  : const Color(0xFFBFEAF0),
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              if (canTap)
                const BoxShadow(
                  color: Color(0x260C587A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
            ],
          ),
          child: loading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                pendingMyProduct
                    ? Icons.hourglass_top_rounded
                    : Icons.swap_horiz_rounded,
                size: 17,
                color: canTap ? Color(0xFF0C587A) : const Color(0xFF6B8594),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: canTap ? Color(0xFF0C587A) : const Color(0xFF6B8594),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.4,
                    height: 1,
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




class _SuggestionCardDirectWhatsAppButton extends StatelessWidget {
  const _SuggestionCardDirectWhatsAppButton({
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xFFFFFFFF),
            border: Border.all(
              color: const Color(0xFF22C55E),
              width: 1.2,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0xFFFFFFFF),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 23,
                height: 23,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  'محادثة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF166534),
                    fontWeight: FontWeight.w900,
                    fontSize: 11.6,
                    height: 1,
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


class _OneShotAttentionPulse extends StatefulWidget {
  const _OneShotAttentionPulse({
    required this.child,
    required this.play,
    this.maxScale = 0.065,
    this.cycles = 3,
    this.duration = const Duration(milliseconds: 420),
    this.repeatUntilStopped = false,
  });

  final Widget child;
  final bool play;
  final double maxScale;
  final int cycles;
  final Duration duration;
  final bool repeatUntilStopped;

  @override
  State<_OneShotAttentionPulse> createState() => _OneShotAttentionPulseState();
}

class _OneShotAttentionPulseState extends State<_OneShotAttentionPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _completedCycles = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener(_handleStatusChanged);

    if (widget.play) {
      _start();
    }
  }

  @override
  void didUpdateWidget(covariant _OneShotAttentionPulse oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.play && widget.play) {
      _start();
    } else if (oldWidget.play && !widget.play) {
      _stop();
    }
  }

  void _start() {
    if (_started) return;

    _started = true;
    _completedCycles = 0;
    _controller.forward(from: 0);
  }

  void _stop() {
    _started = false;
    _completedCycles = 0;

    if (_controller.isAnimating) {
      _controller.stop();
    }

    _controller.value = 0;
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (!_started) return;

    if (status == AnimationStatus.completed) {
      _controller.reverse();
      return;
    }

    if (status == AnimationStatus.dismissed) {
      _completedCycles += 1;

      if (widget.repeatUntilStopped && widget.play) {
        _controller.forward();
        return;
      }

      if (_completedCycles >= widget.cycles) {
        _started = false;
        _controller.value = 0;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double wave = _controller.value <= 0.5
            ? _controller.value * 2
            : (1 - _controller.value) * 2;

        return Transform.scale(
          scale: 1 + (wave * widget.maxScale),
          child: child,
        );
      },
    );
  }
}



class _FloatingConsultFriendsButton extends StatelessWidget {
  const _FloatingConsultFriendsButton({
    required this.enabled,
    required this.myProduct,
    required this.suggestions,
    this.playAttention = false,
  });

  final bool enabled;
  final Product? myProduct;
  final List<Product> suggestions;
  final bool playAttention;

  @override
  Widget build(BuildContext context) {
    // يظل زر الاستشارة Active حتى لو منتج المستخدم قيد الموافقة.
    // الشرط الوحيد الفعلي هو وجود منتج وترشيحات يمكن مشاركتها.
    final bool canTap = myProduct != null && suggestions.isNotEmpty;
    final int count = suggestions.length;

    final Widget visibleButton = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      height: 38,
      padding: const EdgeInsetsDirectional.only(start: 10, end: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF22C55E),
          width: 1.6,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x2422C55E),
            blurRadius: 13,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat,
              size: 13.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'استشير أصدقاءك',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF166534),
                fontWeight: FontWeight.w900,
                fontSize: 11.2,
                height: 1,
              ),
            ),
          ),

        ],
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Opacity(
        opacity: canTap ? 1 : 0.58,
        child: SizedBox(
          height: 38,
          width: 154,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _OneShotAttentionPulse(
                    play: playAttention && canTap,
                    maxScale: 0.085,
                    child: visibleButton,
                  ),
                  if (canTap)
                    Opacity(
                      opacity: 0.001,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(
                          width: 154,
                          height: 38,
                          child: SwapWhatsAppShareButton(
                            myProduct: myProduct,
                            suggestions: suggestions,
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
    this.tabsBar,
    required this.selectionEnabled,
    required this.myProductPending,
    required this.onSelectCard,
    required this.onRequestSwap,
    required this.onHideCard,
    required this.onTapSuggestedProduct,
    required this.onTapMyProduct,
    required this.onEditInterests,
    required this.onOpenNetworkSheet,
    this.showTopControls = true,
  });

  final Product? myProduct;
  final Product product;
  final InlineSwapVM vm;
  final bool compact;
  final bool smallLayout;
  final bool isActive;
  final String? relationBackendCode;
  final int index;
  final Widget? tabsBar;
  final bool selectionEnabled;
  final bool myProductPending;
  final VoidCallback onSelectCard;
  final VoidCallback onRequestSwap;
  final VoidCallback onHideCard;
  final VoidCallback onTapSuggestedProduct;
  final VoidCallback onTapMyProduct;
  final VoidCallback onEditInterests;
  final VoidCallback onOpenNetworkSheet;
  final bool showTopControls;

  @override
  Widget build(BuildContext context) {
    final List<SwapCriterionItem> allEnabledCriteria =
    buildSuggestedSwapCriteria(
      product,
      vm,
      myProduct: myProduct,
    ).where((e) => e.enabled).toList();

    final bool hasFamilyInterest =
    allEnabledCriteria.any((SwapCriterionItem e) => e.isFamilyInterest);

    final List<SwapCriterionItem> enabledCriteria =
    allEnabledCriteria.take(6).toList(); // ✅ الترتيب محفوظ كما هو في buildSuggestedSwapCriteria

    final List<SwapCriterionItem> criteriaToShow = enabledCriteria.isNotEmpty
        ? enabledCriteria
        : buildSuggestedSwapFallbackCriteria(vm);

    final bool useOpportunityBorder =
        vm.badge.tone == SwapBadgeTone.golden ||
            vm.badge.tone == SwapBadgeTone.excellent;
    final SwapBadgeStyle badgeStyle = swapBadgeStyleForBadge(vm.badge);

    final Color cardBorderColor = hasFamilyInterest
        ? const Color(0xFF19D4E2)
        : useOpportunityBorder
        ? badgeStyle.border
        : isActive
        ? const Color(0xFF19D4E2)
        : const Color(0xFFD7E6EE);

    final double cardBorderWidth = isActive
        ? 2.6
        : hasFamilyInterest || useOpportunityBorder
        ? 2.0
        : 1.0;

    final Color cardFillColor = !selectionEnabled
        ? const Color(0xFFF8FBFC)
        : isActive
        ? const Color(0xFFE8FBFD)
        : Colors.white;

    final bool showDirectWhatsAppButton = !myProductPending &&
        _shouldShowDirectWhatsAppButton(
          product: product,
          relationBackendCode: relationBackendCode,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showTopControls) ...<Widget>[
            if (tabsBar != null) ...<Widget>[
              tabsBar!,
              const SizedBox(height: 8),
            ] else
              const SizedBox(height: 8),
            _RecommendationBoosterBar(
              onEditInterests: onEditInterests,
              onOpenFamily: onOpenNetworkSheet,
            ),
            const SizedBox(height: 10),
          ],

          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: selectionEnabled ? onSelectCard : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.fromLTRB(7, 8, 7, 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: cardFillColor,
                  border: Border.all(
                    color: cardBorderColor,
                    width: cardBorderWidth,
                  ),
                  boxShadow: <BoxShadow>[
                    if (isActive)
                      const BoxShadow(
                        color: Color(0x3A19D4E2),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      )
                    else if (hasFamilyInterest)
                      const BoxShadow(
                        color: kFamilyRecommendationShadow,
                        blurRadius: 24,
                        spreadRadius: 1,
                        offset: Offset(0, 9),
                      )
                    else if (useOpportunityBorder)
                        BoxShadow(
                          color: badgeStyle.glow,
                          blurRadius: 24,
                          spreadRadius: 1,
                          offset: const Offset(0, 9),
                        )
                      else
                        const BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _SwapCompareRow(
                          myProduct: myProduct,
                          suggestedProduct: product,
                          compact: compact,
                          smallLayout: smallLayout,
                          relationBackendCode: relationBackendCode,
                          myProductPending: myProductPending,
                          onTapMyProduct: onTapMyProduct,
                          onTapSuggestedProduct: onTapSuggestedProduct,
                          currentIndex: index,
                        ),
                        const SizedBox(height: 10),
                        SuggestedSwapReasonsGrid(
                          items: criteriaToShow,
                          compact: compact,
                          vm: vm,
                        ),
                        const SizedBox(height: 10),
                        if (showDirectWhatsAppButton)
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 11,
                                child: _SuggestionCardRequestSwapButton(
                                  enabled: selectionEnabled,
                                  pendingMyProduct: myProductPending,
                                  loading: false,
                                  onTap: onRequestSwap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 9,
                                child: _SuggestionCardDirectWhatsAppButton(
                                  onTap: () => _openDirectWhatsAppForSuggestion(
                                    myProduct: myProduct,
                                    suggestedProduct: product,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          _SuggestionCardRequestSwapButton(
                            enabled: selectionEnabled,
                            pendingMyProduct: myProductPending,
                            loading: false,
                            onTap: onRequestSwap,
                          ),
                      ],
                    ),
                    PositionedDirectional(
                      top: -2,
                      end: -2,
                      child: _SuggestionHideButton(onTap: onHideCard),
                    ),
                  ],
                ),
              ),
            ),
          ),


        ],
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
    required this.myProductPending,
    required this.onTapMyProduct,
    required this.onTapSuggestedProduct,
    required this.currentIndex,
  });

  final Product? myProduct;
  final Product suggestedProduct;
  final bool compact;
  final bool smallLayout;
  final String? relationBackendCode;
  final bool myProductPending;
  final VoidCallback onTapMyProduct;
  final VoidCallback onTapSuggestedProduct;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = smallLayout ? 146 : 158;
    final double cardHeight = compact ? 196 : 212;
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
              coreTagKey: "suggested_swap_my_${myProduct?.id ?? 'empty'}_$currentIndex",
              showPendingBadge: myProductPending,
              onTap: onTapMyProduct,
            ),
          ),
        ),

        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
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
                coreTagKey: "suggested_swap_rec_${suggestedProduct.id ?? 'empty'}_$currentIndex",
                relationBackendCode: relationBackendCode,
                onTap: onTapSuggestedProduct,
              ),
            ),
          ),
        ),
      ],
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
    required this.coreTagKey,
    this.relationBackendCode,
    this.showPendingBadge = false,
    required this.onTap,
  }) : super(key: key);

  final Product? product;
  final bool isMine;
  final double width;
  final double height;
  final String coreTagKey;
  final String? relationBackendCode;
  final bool showPendingBadge;
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

  String _resolveProductTitle(Product? p) {
    final String value = (p?.title ?? '').toString().trim();

    if (value.isNotEmpty && value.toLowerCase() != 'null') {
      return value;
    }

    return isMine ? 'منتجك' : 'منتج مرشح';
  }

  String _cleanRelationValue(dynamic value) {
    final String text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  String? _resolveRelationBackendCodeForCard(Product? p) {
    final String explicitCode = _cleanRelationValue(relationBackendCode).toUpperCase();
    if (explicitCode.isNotEmpty) return explicitCode;

    final String productCode = _cleanRelationValue(p?.relationCode).toUpperCase();
    if (productCode.isNotEmpty) return productCode;

    final String rawType = _cleanRelationValue(p?.relationType);
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

  int? _resolveRelationTypeForCard(Product? p) {
    // مهم: نقرأ الرقم التفصيلي أولاً عشان يظهر أخ/أخت أو ابن/ابنة
    // بدل ما FAMILY تتحول لعلاقة عامة.
    final String rawType = _cleanRelationValue(p?.relationType);
    final int? parsedType = int.tryParse(rawType);
    if (parsedType != null && parsedType > 0) {
      return parsedType;
    }

    final String code = (_resolveRelationBackendCodeForCard(p) ?? '').toUpperCase();
    switch (code) {
      case 'FRIEND':
        return 1;
      case 'FAMILY':
        return 4;
      case 'BIG_FAMILY':
        return 6;
      case 'SELF':
        return 777;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product? p = product;

    if (p != null) {
      final Widget productCard = TaapdeelProductCardItem(
        product: p,
        coreTagKey: coreTagKey,
        onTap: onTap,
        cardWidth: width,
        cardHeight: height,
        outerMargin: EdgeInsets.zero,
        variant: TaapdeelProductCardVariant.family,
        showRotatingBanner: true,
        showRelationPanel: !isMine,
        relationType: isMine ? null : _resolveRelationTypeForCard(p),
        relationBackendCode: isMine ? null : _resolveRelationBackendCodeForCard(p),
      );

      return Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              productCard,
              const SizedBox(height: 6),
              Text(
                _resolveProductTitle(p),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF123B52),
                  fontWeight: FontWeight.w900,
                  fontSize: 11.4,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
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

