import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../viewobject/common/ps_value_holder.dart';
import '../../Foryou/home_provider.dart';

class HomeHeaderWidget extends StatefulWidget {
  const HomeHeaderWidget({
    required this.animationController,
    required this.animation,
    required this.psValueHolder,
    required this.itemNameTextEditingController,
    Key? key,
  }) : super(key: key);

  final AnimationController? animationController;
  final Animation<double> animation;
  final PsValueHolder? psValueHolder;
  final TextEditingController itemNameTextEditingController;

  @override
  State<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends State<HomeHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: widget.animationController!,
        child: const Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _HomeTopCarousel(),
          ],
        ),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
            opacity: widget.animation,
            child: Transform(
              transform: Matrix4.translationValues(
                0.0,
                30 * (1.0 - widget.animation.value),
                0.0,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// ======================================================
/// ✅ Full-Section Carousel (3 Pages)
/// 0) Promo
/// 1) حواديت تبديل (STATIC)
/// 2) تبديلات ناجحه (STATIC mini-carousel 3 pages)
/// ======================================================
class _HomeTopCarousel extends StatefulWidget {
  const _HomeTopCarousel();

  @override
  State<_HomeTopCarousel> createState() => _HomeTopCarouselState();
}

class _HomeTopCarouselState extends State<_HomeTopCarousel> {
  static const int _pagesCount = 3;
  static const double _sectionHeight = 220;

  late final PageController _pc;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: 1.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startAutoRotate();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  void _startAutoRotate() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pc.hasClients) return;
      final int next = (_page + 1) % _pagesCount;
      _pc.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Column(
        children: [
          SizedBox(
            height: _sectionHeight,
            child: PageView.builder(
              controller: _pc,
              itemCount: _pagesCount,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) {
                setState(() => _page = i);
                _startAutoRotate();
              },
              itemBuilder: (_, i) {
                return _HeroPageWrapper(
                  controller: _pc,
                  index: i,
                  fallbackPage: _page,
                  // ✅ NEW: glass frame like attached screenshot
                  child: _CarouselGlassPanel(
                    child: _buildHeroPage(i),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _PremiumDots(activeIndex: _page, count: _pagesCount),
        ],
      ),
    );
  }

  Widget _buildHeroPage(int i) {
    if (i == 0) return const _HeroPromoSection(height: _sectionHeight);

    // ✅ Static wanted
    if (i == 1) return const _HeroWantedProductsStatic(height: _sectionHeight);

    // ✅ Static successful swaps
    return const _HeroSuccessfulSwapsStatic(height: _sectionHeight);
  }
}

/// ✅ Wrapper handles scale+opacity based on page distance
class _HeroPageWrapper extends StatelessWidget {
  const _HeroPageWrapper({
    required this.controller,
    required this.index,
    required this.fallbackPage,
    required this.child,
  });

  final PageController controller;
  final int index;
  final int fallbackPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double page = fallbackPage.toDouble();
        if (controller.hasClients && controller.position.haveDimensions) {
          page = (controller.page ?? fallbackPage.toDouble());
        }

        final double dist = (page - index).abs().clamp(0.0, 1.0);
        final double scale = 1.0 - (dist * 0.06);
        final double opacity = 1.0 - (dist * 0.20);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _PremiumDots extends StatelessWidget {
  const _PremiumDots({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: active ? const  Color(0xFF0FA3A6) : Colors.black.withAlpha(30),
            boxShadow: active
                ? [
              BoxShadow(
                color: const Color(0xFF0FA3A6
                ).withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
                : null,
          ),
        );
      }),
    );
  }
}

/// ======================================================
/// ✅ NEW: Glass Panel (Frame) like attached screenshot
/// - blur + gradient + border + soft shadow
/// - subtle blue glow circles
/// - inner padding
/// ======================================================
class _CarouselGlassPanel extends StatelessWidget {
  const _CarouselGlassPanel({
    required this.child,
    this.radius = 26,
    this.padding = const EdgeInsets.fromLTRB(14, 14, 14, 14),
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: radius,
      blur: 18,
      padding: padding,
      withBorder: true,
      withShadow: true,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -55,
            left: -35,
            child: Container(
              width: 190,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF60A5FA).withOpacity(0.10),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// ======================================================
/// ✅ SECTION 0: Promo
/// ======================================================
class _HeroPromoSection extends StatelessWidget {
  const _HeroPromoSection({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Taapdeel_logo.png',
                width: 150,
                height: 100,
                fit: BoxFit.fill,
                //errorBuilder: (_, __, ___) => const SizedBox(height: 72),
              ),
              Text(
                'وفّر فلوسك… جدد حياتك… فرّح عيلتك',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2C5C88),
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              /*Text(
                'اختار منتج… وشوف أنسب تبديلات ليه',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5A6A7A),
                  fontWeight: FontWeight.w700,
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

/// ======================================================
/// ✅ SECTION 1: Hawadeet Taapdeel (STATIC)
/// ======================================================
class _HeroWantedProductsStatic extends StatelessWidget {
  const _HeroWantedProductsStatic({required this.height});
  final double height;

  static const List<_MiniModel> _items = [
    _MiniModel(title: 'فستان ليوم واحد', image: 'assets/images/intro/m23_c2.png'),
    _MiniModel(title: 'كتب خلصت مهمتها', image: 'assets/images/intro/m23_c1.png'),
    _MiniModel(title: 'موبايل في الدرج', image: 'assets/images/intro/s3_m23_c4.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Row(
              children: [
                _HeroTitleText(title: 'حواديت تبديل'),
                Spacer(),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 40,
            bottom: 0,
            child: _TopThreeQuickCirclesRow(items: _items),
          ),
        ],
      ),
    );
  }
}

/// ======================================================
/// ✅ SECTION 2: Successful Swaps (STATIC mini-carousel)
/// ======================================================
class _HeroSuccessfulSwapsStatic extends StatefulWidget {
  const _HeroSuccessfulSwapsStatic({required this.height});
  final double height;

  @override
  State<_HeroSuccessfulSwapsStatic> createState() =>
      _HeroSuccessfulSwapsStaticState();
}

class _HeroSuccessfulSwapsStaticState extends State<_HeroSuccessfulSwapsStatic> {
  late final PageController _pc;
  Timer? _t;
  int _p = 0;

  static const List<_MiniModel> _pool = [
    _MiniModel(
        title: 'iPhone ↔ PlayStation', image: 'assets/images/intro/m23_c4.png'),
    _MiniModel(
        title: 'Laptop ↔ iPad', image: 'assets/images/intro/m23_c5.png'),
    _MiniModel(
        title: 'Camera ↔ Phone', image: 'assets/images/intro/m23_c4.png'),
    _MiniModel(
        title: 'Sneakers ↔ Watch', image: 'assets/images/intro/m23_c5.png'),
    _MiniModel(
        title: 'Bike ↔ Tablet', image: 'assets/images/intro/m23_c4.png'),
    _MiniModel(
        title: 'Headset ↔ Console', image: 'assets/images/intro/m23_c5.png'),
  ];

  static final List<List<_MiniModel>> _pages = [
    [_pool[0], _pool[1]],
    [_pool[2], _pool[3]],
    [_pool[4], _pool[5]],
  ];

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: 1.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _start();
    });
  }

  void _start() {
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pc.hasClients) return;
      final next = (_p + 1) % 3;
      _pc.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Row(
              children: [
                _HeroTitleText(title: 'تبديلات ناجحه'),
                Spacer(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 48,
            bottom: 0,
            child: PageView.builder(
              controller: _pc,
              itemCount: 3,
              onPageChanged: (i) => setState(() => _p = i),
              itemBuilder: (_, i) => _RecommendationCardsRow(items: _pages[i]),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================================================
/// ✅ Shared models
/// ======================================================
class _MiniModel {
  final String title;
  final String? image;
  const _MiniModel({required this.title, required this.image});
}

/// ======================================================
/// ✅ Wanted UI (3 circles + glass shelf)
/// ======================================================
class _TopThreeQuickCirclesRow extends StatelessWidget {
  const _TopThreeQuickCirclesRow({required this.items});
  final List<_MiniModel> items;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bool wrap = w < 350;

    const double circleSize = 70;
    const double titleGap = 6;
    const double approxTitleHeight = 16;
    const double bottomPadding = 0;

    final double contentHeight =
        circleSize + titleGap + approxTitleHeight + bottomPadding;
    final double glassTop = circleSize * 0.50;
    final double glassHeight = contentHeight - glassTop;

    final children = List.generate(3, (i) {
      final m = items[i];
      return _CircleItem(title: m.title, imageUrlOrAsset: m.image, size: circleSize);
    });

    final Widget rowOrWrap = wrap
        ? Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 5,
      spacing: 12,
      children: children
          .map((e) => SizedBox(width: (w - 18 * 2 - 12) / 2, child: e))
          .toList(),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children
          .map((e) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: e,
        ),
      ))
          .toList(),
    );

    return SizedBox(
      height: contentHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -25,
            right: -25,
            top: glassTop,
            height: glassHeight,
            child: const _GlassShelf(radius: 22),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: rowOrWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassShelf extends StatelessWidget {
  const _GlassShelf({this.radius = 22});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // ✅ خفيفة
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.85),
                  const Color(0xFFEAF2FF).withOpacity(0.70),
                  Colors.white.withOpacity(0.82),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.75),
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleItem extends StatelessWidget {
  const _CircleItem({
    required this.title,
    required this.imageUrlOrAsset,
    required this.size,
  });

  final String title;
  final String? imageUrlOrAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhysicalModel(
          color: Colors.transparent,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.12),
          shape: BoxShape.circle,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: size,
            height: size,
            child: ClipOval(
              child: _ImageOrPlaceholder(urlOrAsset: imageUrlOrAsset, iconSize: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C5C88),
          ),
        ),
      ],
    );
  }
}

/// ======================================================
/// ✅ Recommendations UI
/// ======================================================
class _RecommendationCardsRow extends StatelessWidget {
  const _RecommendationCardsRow({required this.items});
  final List<_MiniModel> items;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bool wrap = w < 380;

    final cards = [
      _RecCard(title: items[0].title, imageUrlOrAsset: items[0].image),
      _RecCard(title: items[1].title, imageUrlOrAsset: items[1].image),
    ];

    if (wrap) {
      return Column(
        children: cards
            .map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: e,
        ))
            .toList(),
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 15),
        Expanded(child: cards[1]),
      ],
    );
  }
}

class _RecCard extends StatelessWidget {
  const _RecCard({
    required this.title,
    required this.imageUrlOrAsset,
  });

  final String title;
  final String? imageUrlOrAsset;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.12),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: _ImageOrPlaceholder(urlOrAsset: imageUrlOrAsset, iconSize: 28),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.10),
                        Colors.white.withOpacity(0.06),
                        Colors.white.withOpacity(0.10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 5,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================================================
/// ✅ Shared image helper
/// ======================================================
class _ImageOrPlaceholder extends StatelessWidget {
  const _ImageOrPlaceholder({required this.urlOrAsset, required this.iconSize});

  final String? urlOrAsset;
  final double iconSize;

  bool _isNetwork(String? v) => (v ?? '').startsWith('http');

  @override
  Widget build(BuildContext context) {
    final v = urlOrAsset;
    if (v == null || v.isEmpty) {
      return Container(
        color: Colors.black.withOpacity(0.04),
        child: Center(
          child: Icon(
            CupertinoIcons.photo,
            color: const Color(0xFF8AA0B5),
            size: iconSize,
          ),
        ),
      );
    }

    if (_isNetwork(v)) {
      return Image.network(
        v,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.black.withOpacity(0.04),
          child: Center(
            child: Icon(
              CupertinoIcons.photo,
              color: const Color(0xFF8AA0B5),
              size: iconSize,
            ),
          ),
        ),
      );
    }

    return Image.asset(
      v,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.black.withOpacity(0.04),
        child: Center(
          child: Icon(
            CupertinoIcons.photo,
            color: const Color(0xFF8AA0B5),
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

/// ======================================================
/// ✅ Glass Card (UPDATED) — real glass like screenshot
/// ======================================================
class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.radius = 22,
    this.blur = 16,
    this.padding,
    this.withBorder = true,
    this.withShadow = true,
  });

  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final bool withBorder;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.90),
                const Color(0xFFEAF2FF).withOpacity(0.55),
                Colors.white.withOpacity(0.62),
              ],
            ),
            border: withBorder
                ? Border.all(
              color: Color(0xFF0FA3A6),
              width: 1.5,
            )
                : null,
            boxShadow: withShadow
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ======================================================
/// ✅ Title
/// ======================================================
class _HeroTitleText extends StatelessWidget {
  const _HeroTitleText({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: const Color(0xFF2C5C88),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
