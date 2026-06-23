import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

/// TaapdeelTabBar
///
/// - في الحالة العادية (isScrollable = false):
///   • Row مخصّصة + AnimatedPositioned لكبسولة الـ indicator
///   • AnimatedDefaultTextStyle لتغيير لون/وزن النص
///   • دعم RTL بشكل صحيح (index 0 = التاب اللي على اليمين بصريًا)
///
/// - لو isScrollable = true:
///   • نستخدم TabBar العادي مع LegacyIndicator (بدون أنيميشن موضع).
class TaapdeelTabBar extends StatefulWidget
    implements PreferredSizeWidget {
  const TaapdeelTabBar({
    Key? key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.onTap,
    this.backgroundColor,
    this.padding =
    const EdgeInsets.symmetric(horizontal: PsDimens.space16),
  }) : super(key: key);

  final List<Widget> tabs;
  final TabController? controller;
  final bool isScrollable;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  State<TaapdeelTabBar> createState() => _TaapdeelTabBarState();
}

class _TaapdeelTabBarState extends State<TaapdeelTabBar> {
  TabController? _controller;
  int _currentIndex = 0;

  static const Duration _animDuration = Duration(milliseconds: 240);
  static const Curve _curve = Curves.easeOutCubic;
  static const Color _brandBlue = Color(0xFF3167B0);
  static const Color _brandBlueDark = Color(0xFF274F8C);

  TabController? get _effectiveController =>
      widget.controller ?? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initController();
  }

  @override
  void didUpdateWidget(covariant TaapdeelTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _initController();
    }
  }

  void _initController() {
    final TabController? newController =
        widget.controller ?? DefaultTabController.maybeOf(context);

    if (newController == null) {
      return;
    }
    if (_controller == newController) {
      return;
    }

    _controller?.removeListener(_handleControllerTick);
    _controller = newController;
    _controller!.addListener(_handleControllerTick);

    setState(() {
      _currentIndex = _controller!.index;
    });
  }

  void _handleControllerTick() {
    if (!mounted || _controller == null) {
      return;
    }
    if (_currentIndex != _controller!.index) {
      setState(() {
        _currentIndex = _controller!.index;
      });
    }
  }

  void _onTabTap(int index) {
    final TabController? c = _effectiveController;
    if (c != null && index < c.length) {
      c.animateTo(
        index,
        duration: _animDuration,
        curve: _curve,
      );
    }
    widget.onTap?.call(index);
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isRtl =
        Directionality.of(context) == TextDirection.rtl;

    final Color bg =
        widget.backgroundColor ?? Colors.white.withValues(alpha:0.10);

    // ============================
    // Scrollable mode → TabBar العادي
    // ============================
    if (widget.isScrollable) {
      return Container(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: bg,
          ),
          child: TabBar(
            controller: _effectiveController,
            isScrollable: true,
            padding: EdgeInsets.zero,
            tabAlignment: TabAlignment.start,


            onTap: widget.onTap,
            indicator: const _TaapdeelLegacyIndicator(
              color: _brandBlueDark,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsetsDirectional.only(
              start: 10,
              end: 10,
            ),
            labelColor: Colors.white,
            unselectedLabelColor:
            colorScheme.onSurface.withValues(alpha:0.55),
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
            unselectedLabelStyle:
            theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            tabs: widget.tabs,
            dividerColor: Colors.transparent,
            splashBorderRadius: BorderRadius.circular(999),
            overlayColor:
            WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withValues(alpha:0.10);
                }
                if (states.contains(WidgetState.hovered)) {
                  return Colors.white.withValues(alpha:0.04);
                }
                return null;
              },
            ),
          ),
        ),
      );
    }

    // ============================
    // Non-scrollable → Indicator يتحرك بـ AnimatedPositioned
    // ============================
    final int tabCount = widget.tabs.length;
    if (tabCount == 0) {
      return const SizedBox.shrink();
    }

    final TextStyle baseStyle =
        theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ) ??
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            );

    return Container(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double totalWidth = constraints.maxWidth;
          final double tabWidth = totalWidth / tabCount;

          // حساب موضع الكبسولة حسب RTL
          final int visualIndex =
          isRtl ? (tabCount - 1 - _currentIndex) : _currentIndex;
          final double left = visualIndex * tabWidth;

          return Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: bg,
            ),
            child: Stack(
              children: <Widget>[
                // Indicator Capsule المتحرك
                AnimatedPositioned(
                  duration: _animDuration,
                  curve: _curve,
                  top: 4,
                  bottom: 4,
                  left: left + 2,
                  width: tabWidth - 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          _brandBlueDark,
                          _brandBlue,
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color:
                          _brandBlueDark.withValues(alpha:0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tabs
                Row(
                  children: List.generate(tabCount, (int index) {
                    final bool selected =
                        index == _currentIndex;

                    return Expanded(
                      child: InkWell(
                        borderRadius:
                        BorderRadius.circular(999),
                        onTap: () => _onTabTap(index),
                        splashColor:
                        Colors.white.withValues(alpha:0.12),
                        highlightColor:
                        Colors.white.withValues(alpha:0.06),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: _animDuration,
                            curve: _curve,
                            style: baseStyle.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : colorScheme.onSurface
                                  .withValues(alpha:0.65),
                            ),
                            child: _buildTabLabel(
                              widget.tabs[index],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// نحاول نستخرج النص من Tab(text: '...') لو موجود
  Widget _buildTabLabel(Widget tab) {
    if (tab is Tab && tab.text != null && tab.icon == null) {
      return Text(tab.text!);
    }
    return tab;
  }
}

/// Legacy indicator للـ isScrollable = true
class _TaapdeelLegacyIndicator extends Decoration {
  const _TaapdeelLegacyIndicator({required this.color});
  final Color color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TaapdeelLegacyIndicatorPainter(color: color);
  }
}

class _TaapdeelLegacyIndicatorPainter extends BoxPainter {
  _TaapdeelLegacyIndicatorPainter({required this.color});
  final Color color;

  @override
  void paint(
      Canvas canvas,
      Offset offset,
      ImageConfiguration configuration,
      ) {
    if (configuration.size == null) return;

    final Size size = configuration.size!;
    final Rect rect = offset & size;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.left + 2,
        rect.top + 3,
        rect.width - 4,
        rect.height - 6,
      ),
      const Radius.circular(999),
    );

    final Paint shadowPaint = Paint()
      ..color = color.withValues(alpha:0.35)
      ..maskFilter =
      const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.save();
    canvas.translate(0, 3);
    canvas.drawRRect(rRect, shadowPaint);
    canvas.restore();

    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          color.withValues(alpha:0.98),
          color.withValues(alpha:0.82),
        ],
      ).createShader(rRect.outerRect);

    canvas.drawRRect(rRect, paint);
  }
}
