part of '../profile_share_gallery.dart';

class _EnergeticPromoCanvas extends StatelessWidget {
  const _EnergeticPromoCanvas({
    required this.products,
    required this.smartText,
  });

  final List<ShareProductViewData> products;
  final String smartText;

  @override
  Widget build(BuildContext context) {
    final String headline = _shortSmartText(smartText);
    final String cuteLine = _cardCuteLineFromSmartText(smartText);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFEAF8FB),
            Color(0xFF002E5D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            top: -28,
            left: -20,
            child: _GiftPromoGlow(size: 118),
          ),
          const Positioned(
            top: 124,
            right: -34,
            child: _GiftPromoGlow(size: 92),
          ),
          const Positioned(
            bottom: 54,
            left: -28,
            child: _GiftPromoGlow(size: 104),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: const _GiftLuxuryConfettiPainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Expanded(child: _BrandMark(compact: true)),
                    _SwapIcon(size: 45),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: <Color>[
                        Color(0xFF08284F),
                        Color(0xFF0F2E57),
                        Color(0xFF136D89),
                      ],
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x24002E5D),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text(
                    'جاهز تبدّل؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
                if (headline.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x120F2E57),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      headline,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ShareGalleryColors.navy,
                        fontWeight: FontWeight.w900,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
                if (cuteLine.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Center(
                    child: _CuteLinePill(
                      text: cuteLine,
                      compact: true,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(
                  child: _LuxuryCuteGiftBoard(
                    products: products.take(5).toList(growable: false),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const <Widget>[
                    _InfoPill(
                      label: 'سهولة وأمان',
                      icon: Icons.verified_user_rounded,
                    ),
                    SizedBox(width: 6),
                    _InfoPill(
                      label: 'تبديل ذكي',
                      icon: Icons.sync_rounded,
                    ),
                    SizedBox(width: 6),
                    _InfoPill(
                      label: 'مجتمع موثوق',
                      icon: Icons.groups_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftPromoGlow extends StatelessWidget {
  const _GiftPromoGlow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              Color(0x61FFFFFF),
              Color(0x1F24A9C4),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _LuxuryCuteGiftBoard extends StatelessWidget {
  const _LuxuryCuteGiftBoard({required this.products});

  final List<ShareProductViewData> products;

  static const List<_GiftPalette> _palettes = <_GiftPalette>[
    _GiftPalette(
      main: Color(0xFF7C5CFF),
      dark: Color(0xFF5438CE),
      light: Color(0xFFE9E3FF),
      ribbon: Color(0xFFFFD166),
    ),
    _GiftPalette(
      main: Color(0xFFFFA33A),
      dark: Color(0xFFD97A08),
      light: Color(0xFFFFE7C2),
      ribbon: Color(0xFFFFFFFF),
    ),
    _GiftPalette(
      main: Color(0xFF24A9C4),
      dark: Color(0xFF08798A),
      light: Color(0xFFD9F8FF),
      ribbon: Color(0xFFFFD166),
    ),
    _GiftPalette(
      main: Color(0xFFFF6F91),
      dark: Color(0xFFD83D64),
      light: Color(0xFFFFE0E8),
      ribbon: Color(0xFFFFFFFF),
    ),
    _GiftPalette(
      main: Color(0xFF20C997),
      dark: Color(0xFF0B8D68),
      light: Color(0xFFDDFBF1),
      ribbon: Color(0xFFFFD166),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> list = products.take(5).toList(
      growable: false,
    );
    if (list.isEmpty) return const SizedBox.shrink();

    final List<ShareProductViewData> top = list.take(3).toList(
      growable: false,
    );
    final List<ShareProductViewData> bottom = list.skip(3).take(2).toList(
      growable: false,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xF5FFFFFF),
            Color(0xB3FFFFFF),
          ],
        ),
        border: Border.all(
          color: const Color(0xF5FFFFFF),
          width: 1.3,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24002E5D),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: _GiftBoardSoftPattern()),
          Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List<Widget>.generate(top.length, (int i) {
                    final bool featured = i == 1;
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: i == 0 ? 0 : 4,
                        end: i == top.length - 1 ? 0 : 4,
                        bottom: featured ? 0 : 4,
                      ),
                      child: _LuxuryCuteGiftProduct(
                        product: top[i],
                        palette: _palettes[i % _palettes.length],
                        featured: featured,
                      ),
                    );
                  }),
                ),
              ),
              if (bottom.isNotEmpty) const SizedBox(height: 8),
              if (bottom.isNotEmpty)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List<Widget>.generate(bottom.length, (int i) {
                      final int paletteIndex = i + 3;
                      return Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: i == 0 ? 0 : 8,
                          end: i == bottom.length - 1 ? 0 : 8,
                        ),
                        child: _LuxuryCuteGiftProduct(
                          product: bottom[i],
                          palette: _palettes[paletteIndex % _palettes.length],
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GiftPalette {
  const _GiftPalette({
    required this.main,
    required this.dark,
    required this.light,
    required this.ribbon,
  });

  final Color main;
  final Color dark;
  final Color light;
  final Color ribbon;
}

class _LuxuryCuteGiftProduct extends StatelessWidget {
  const _LuxuryCuteGiftProduct({
    required this.product,
    required this.palette,
    this.featured = false,
  });

  final ShareProductViewData product;
  final _GiftPalette palette;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final String? title = product.title;
    final bool showTitle = product.hasTitle && title != null && title.trim().isNotEmpty;
    final double cardWidth = featured ? 102 : 96;
    final double cardHeight = featured ? 142 : 136;
    final double bowSize = featured ? 30 : 26;
    final double verticalRibbonWidth = featured ? 14 : 12;
    final double horizontalRibbonHeight = featured ? 14 : 12;
    final double ribbonTop = featured ? 14 : 12;
    final double ribbonRight = featured ? 16 : 14;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            bottom: 2,
            left: 12,
            right: 12,
            child: IgnorePointer(
              child: Container(
                height: featured ? 14 : 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const RadialGradient(
                    colors: <Color>[
                      Color(0x380F2E57),
                      Color(0x140F2E57),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            bottom: 26,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(featured ? 25 : 22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Color.lerp(palette.light, Colors.white, 0.35) ?? palette.light,
                        Colors.white,
                        Color.lerp(palette.light, palette.main, 0.16) ?? palette.light,
                      ],
                    ),
                    border: Border.all(
                      color: Color.lerp(palette.ribbon, Colors.white, 0.18) ?? palette.ribbon,
                      width: featured ? 2.2 : 1.8,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: palette.main.withValues(alpha: 0.16),
                        blurRadius: featured ? 18 : 13,
                        offset: const Offset(0, 8),
                      ),
                      const BoxShadow(
                        color: Color(0xA6FFFFFF),
                        blurRadius: 10,
                        spreadRadius: -2,
                        offset: Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(featured ? 21 : 18),
                        border: Border.all(
                          color: palette.light.withValues(alpha: 0.75),
                          width: 1.2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(featured ? 16 : 14),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: _ProductImageView(
                                  image: product.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[
                                        Colors.white.withValues(alpha: 0.18),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.06),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                right: ribbonRight,
                                child: Container(
                                  width: verticalRibbonWidth,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[palette.main, palette.dark],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: palette.dark.withValues(alpha: 0.22),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: ribbonTop,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: horizontalRibbonHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: <Color>[palette.dark, palette.main, palette.dark],
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: palette.dark.withValues(alpha: 0.14),
                                        blurRadius: 4,
                                      ),
                                    ],
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
                Positioned(
                  top: 3,
                  right: ribbonRight - (bowSize / 2) + (verticalRibbonWidth / 2),
                  child: _GiftRibbonBow(
                    palette: palette,
                    size: bowSize,
                  ),
                ),
                Positioned(
                  top: 1,
                  right: ribbonRight + 14,
                  child: _GiftTinySparkle(
                    color: palette.ribbon,
                    size: featured ? 14 : 12,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 6,
                  child: _GiftTinySparkle(
                    color: palette.main,
                    size: featured ? 10 : 9,
                  ),
                ),
              ],
            ),
          ),
          if (showTitle)
            Positioned(
              bottom: 0,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: palette.light, width: 1.2),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x140F2E57),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  title.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ShareGalleryColors.navy,
                    fontSize: featured ? 9.4 : 8.7,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GiftRibbonBow extends StatelessWidget {
  const _GiftRibbonBow({
    required this.palette,
    required this.size,
  });

  final _GiftPalette palette;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.82,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.rotate(
            angle: 0.55,
            child: Container(
              width: size * 0.44,
              height: size * 0.66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[palette.main, palette.dark],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: palette.dark.withValues(alpha: 0.16),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Transform.rotate(
            angle: -0.55,
            child: Container(
              width: size * 0.44,
              height: size * 0.66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[palette.main, palette.dark],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: palette.dark.withValues(alpha: 0.16),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: size * 0.30,
            child: Transform.rotate(
              angle: 0.22,
              child: Container(
                width: size * 0.12,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: palette.main,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: size * 0.30,
            child: Transform.rotate(
              angle: -0.22,
              child: Container(
                width: size * 0.12,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: palette.main,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.ribbon,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: palette.ribbon.withValues(alpha: 0.34),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftTinySparkle extends StatelessWidget {
  const _GiftTinySparkle({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      color: color,
      size: size,
      shadows: <Shadow>[
        Shadow(
          color: color.withValues(alpha: 0.38),
          blurRadius: 7,
        ),
      ],
    );
  }
}

class _GiftBoardSoftPattern extends StatelessWidget {
  const _GiftBoardSoftPattern();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 12,
            right: 18,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _ShareGalleryColors.aqua.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 22,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22FFD166),
              ),
            ),
          ),
          Positioned(
            top: 82,
            left: 16,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: const Color(0xFFFFD166).withValues(alpha: 0.65),
            ),
          ),
          Positioned(
            bottom: 74,
            right: 18,
            child: Icon(
              Icons.favorite_rounded,
              size: 16,
              color: const Color(0xFFFF6F91).withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftLuxuryConfettiPainter extends CustomPainter {
  const _GiftLuxuryConfettiPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    const List<_ConfettiSpec> specs = <_ConfettiSpec>[
      _ConfettiSpec(0.12, 0.29, 3.5, Color(0x5524A9C4)),
      _ConfettiSpec(0.88, 0.31, 3.2, Color(0x55FFD166)),
      _ConfettiSpec(0.18, 0.72, 4.2, Color(0x44FFFFFF)),
      _ConfettiSpec(0.82, 0.70, 3.6, Color(0x44FFFFFF)),
      _ConfettiSpec(0.52, 0.53, 2.8, Color(0x4424A9C4)),
      _ConfettiSpec(0.36, 0.83, 2.8, Color(0x55FFD166)),
    ];

    for (final _ConfettiSpec spec in specs) {
      paint.color = spec.color;
      canvas.drawCircle(
        Offset(size.width * spec.dx, size.height * spec.dy),
        spec.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConfettiSpec {
  const _ConfettiSpec(this.dx, this.dy, this.radius, this.color);

  final double dx;
  final double dy;
  final double radius;
  final Color color;
}
