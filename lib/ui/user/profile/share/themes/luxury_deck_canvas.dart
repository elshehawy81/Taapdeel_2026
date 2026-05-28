part of '../profile_share_gallery.dart';

class _LuxuryDeckCanvas extends StatelessWidget {
  const _LuxuryDeckCanvas({
    required this.products,
    required this.smartText,
  });

  final List<ShareProductViewData> products;
  final String smartText;

  @override
  Widget build(BuildContext context) {
    final List<ShareProductViewData> list =
    products.take(4).toList(growable: false);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFF7FBFC),
            Color(0xFFEFF8FA),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: _LuxuryOuterDecor(),
          ),

          Positioned(
            top: 16,
            right: 16,
            left: 16,
            bottom: 18,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: const Color(0xFFE7DCC9),
                  width: 1.15,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFFFFFFF),
                    Color(0xFFFAFDFD),
                    Color(0xFFF1F8FA),
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF001E3C).withOpacity(0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Stack(
                  children: <Widget>[
                    const Positioned.fill(
                      child: _LuxuryInnerDecor(),
                    ),

                    const Positioned(
                      top: 18,
                      right: 0,
                      left: 0,
                      child: Center(
                        child: _BrandMark(compact: true),
                      ),
                    ),

                    const Positioned(
                      top: 72,
                      right: 16,
                      left: 16,
                      child: Text(
                        'اختيارات تبديل مميزة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          height: 0.98,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF001E3C),
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 164,
                      right: 0,
                      left: 0,
                      bottom: 72,
                      child: _LuxuryDeckStage(products: list),
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

class _LuxuryOuterDecor extends StatelessWidget {
  const _LuxuryOuterDecor();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 18,
          left: -60,
          child: _LuxurySoftCircle(
            size: 160,
            color: const Color(0xFF20C7C9),
            opacity: 0.08,
          ),
        ),
        Positioned(
          bottom: 60,
          right: -70,
          child: _LuxurySoftCircle(
            size: 190,
            color: const Color(0xFF001E3C),
            opacity: 0.07,
          ),
        ),
      ],
    );
  }
}

class _LuxuryInnerDecor extends StatelessWidget {
  const _LuxuryInnerDecor();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -80,
          right: -60,
          child: _LuxurySoftCircle(
            size: 210,
            color: const Color(0xFF20C7C9),
            opacity: 0.08,
          ),
        ),
        Positioned(
          bottom: -70,
          left: -80,
          child: _LuxurySoftCircle(
            size: 230,
            color: const Color(0xFF001E3C),
            opacity: 0.06,
          ),
        ),
        Positioned(
          right: -22,
          bottom: 0,
          child: Transform.rotate(
            angle: -0.32,
            child: Container(
              width: 220,
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFF006A74),
                    Color(0xFF00365C),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -40,
          bottom: -8,
          child: Transform.rotate(
            angle: 0.22,
            child: Container(
              width: 260,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70),
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFFF7F7F5),
                    Color(0xFFFFFFFF),
                  ],
                ),
                border: Border.all(
                  color: Color(0xFFE3D8C7),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LuxuryDeckStage extends StatelessWidget {
  const _LuxuryDeckStage({
    required this.products,
  });

  final List<ShareProductViewData> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;

        final double heroWidth = (w * 0.46).clamp(132.0, 190.0);
        final double sideWidth = (w * 0.38).clamp(108.0, 158.0);
        final double heroHeight = (h * 0.88).clamp(210.0, 280.0);
        final double sideHeight = (heroHeight * 0.92).clamp(188.0, 250.0);

        final double baseTop = (h - heroHeight) * 0.46;

        final List<_LuxuryDeckSpec> specs =
        _luxuryDeckSpecs(products.length);

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              right: 26,
              left: 26,
              bottom: 2,
              child: IgnorePointer(
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.elliptical(260, 40),
                    ),
                    gradient: RadialGradient(
                      colors: <Color>[
                        const Color(0xFF001E3C).withOpacity(0.18),
                        const Color(0xFF20C7C9).withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ...List<Widget>.generate(products.length, (int i) {
              final _LuxuryDeckSpec spec = specs[i];
              final bool isHero = i == 0;
              final double cardWidth = isHero ? heroWidth : sideWidth;
              final double cardHeight = isHero ? heroHeight : sideHeight;

              final double left = (w * spec.centerX) - (cardWidth / 2);
              final double top = baseTop + spec.topOffset;

              return Positioned(
                left: left,
                top: top,
                width: cardWidth,
                height: cardHeight,
                child: Transform.rotate(
                  angle: spec.rotation,
                  child: _LuxuryProductCard(
                    product: products[i],
                    index: i + 1,
                    isHero: isHero,
                    darkLevel: spec.darkLevel,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _LuxuryDeckSpec {
  const _LuxuryDeckSpec({
    required this.centerX,
    required this.topOffset,
    required this.rotation,
    required this.darkLevel,
  });

  final double centerX;
  final double topOffset;
  final double rotation;
  final double darkLevel;
}

List<_LuxuryDeckSpec> _luxuryDeckSpecs(int count) {
  switch (count) {
    case 1:
      return const <_LuxuryDeckSpec>[
        _LuxuryDeckSpec(
          centerX: 0.50,
          topOffset: 10,
          rotation: -0.035,
          darkLevel: 1,
        ),
      ];

    case 2:
      return const <_LuxuryDeckSpec>[
        _LuxuryDeckSpec(
          centerX: 0.36,
          topOffset: -35,
          rotation: -0.070,
          darkLevel: 1,
        ),
        _LuxuryDeckSpec(
          centerX: 0.62,
          topOffset: 55,
          rotation: 0.035,
          darkLevel: .88,
        ),
      ];

    case 3:
      return const <_LuxuryDeckSpec>[
        _LuxuryDeckSpec(
          centerX: 0.30,
          topOffset: -45,
          rotation: -0.075,
          darkLevel: 1,
        ),
        _LuxuryDeckSpec(
          centerX: 0.52,
          topOffset: 25,
          rotation: -0.020,
          darkLevel: .92,
        ),
        _LuxuryDeckSpec(
          centerX: 0.72,
          topOffset: 95,
          rotation: 0.055,
          darkLevel: .80,
        ),
      ];

    default:
      return const <_LuxuryDeckSpec>[
        _LuxuryDeckSpec(
          centerX: 0.25,
          topOffset: -60,
          rotation: -0.075,
          darkLevel: 1,
        ),
        _LuxuryDeckSpec(
          centerX: 0.47,
          topOffset: 10,
          rotation: -0.028,
          darkLevel: .92,
        ),
        _LuxuryDeckSpec(
          centerX: 0.66,
          topOffset: 70,
          rotation: 0.028,
          darkLevel: .82,
        ),
        _LuxuryDeckSpec(
          centerX: 0.82,
          topOffset: 140,
          rotation: 0.085,
          darkLevel: .72,
        ),
      ];
  }
}
class _LuxuryProductCard extends StatelessWidget {
  const _LuxuryProductCard({
    required this.product,
    required this.index,
    required this.isHero,
    required this.darkLevel,
  });

  final ShareProductViewData product;
  final int index;
  final bool isHero;
  final double darkLevel;

  @override
  Widget build(BuildContext context) {
    final String number = index.toString().padLeft(2, '0');
    final String title = product.hasTitle
        ? product.title!
        : product.hasCategory
        ? product.category!
        : 'منتج مميز';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isHero ? 26 : 22),
        border: Border.all(
          color: isHero
              ? const Color(0xFFE8E0D2)
              : const Color(0xFFC9D4D8),
          width: isHero ? 2.2 : 1.55,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF001E3C).withOpacity(isHero ? 0.30 : 0.22),
            blurRadius: isHero ? 24 : 18,
            offset: Offset(0, isHero ? 16 : 11),
          ),
          BoxShadow(
            color: const Color(0xFF20C7C9).withOpacity(isHero ? 0.18 : 0.10),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isHero ? 24 : 20),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color.lerp(
                        const Color(0xFF001A34),
                        const Color(0xFF003F46),
                        1 - darkLevel,
                      )!,
                      Color.lerp(
                        const Color(0xFF00101F),
                        const Color(0xFF012C32),
                        1 - darkLevel,
                      )!,
                      const Color(0xFF000A14),
                    ],
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: Opacity(
                opacity: isHero ? 0.18 : 0.12,
                child: CustomPaint(
                  painter: _LuxuryCardPatternPainter(),
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 9,
              child: _LuxuryNumberBadge(
                number: number,
                isHero: isHero,
              ),
            ),

            Positioned(
              top: isHero ? 50 : 43,
              left: 12,
              right: 12,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isHero ? 17 : 13.5,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            Positioned(
              top: isHero ? 88 : 78,
              left: 10,
              right: 10,
              bottom: product.hasCategory ? 42 : 22,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: RadialGradient(
                    colors: <Color>[
                      const Color(0xFF20C7C9).withOpacity(0.22),
                      Colors.white.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: _ProductImageView(
                    image: product.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: product.hasCategory ? 34 : 15,
              child: Container(
                height: 1.1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.transparent,
                      const Color(0xFFE8E0D2).withOpacity(0.88),
                      const Color(0xFF20C7C9).withOpacity(0.9),
                      const Color(0xFFE8E0D2).withOpacity(0.88),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            if (product.hasCategory)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  product.category!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: isHero ? 10.2 : 8.8,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isHero ? 24 : 20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Colors.white.withOpacity(0.16),
                        Colors.transparent,
                        Colors.black.withOpacity(0.10),
                      ],
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

class _LuxuryNumberBadge extends StatelessWidget {
  const _LuxuryNumberBadge({
    required this.number,
    required this.isHero,
  });

  final String number;
  final bool isHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isHero ? 42 : 34,
      height: isHero ? 48 : 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF093B70),
            Color(0xFF001E3C),
          ],
        ),
        border: Border.all(
          color: Color(0xFF6CAFC3),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF20C7C9).withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: isHero ? 19 : 15,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}


class _LuxurySoftCircle extends StatelessWidget {
  const _LuxurySoftCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.38),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _LuxuryCardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 0.65
      ..style = PaintingStyle.stroke;

    const double gap = 22;

    for (double x = -size.height; x < size.width + size.height; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        p,
      );
    }

    final Paint p2 = Paint()
      ..color = const Color(0xFF20C7C9).withOpacity(0.16)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width + size.height; x += gap * 1.45) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x - size.height, 0),
        p2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LuxuryCardPatternPainter oldDelegate) => false;
}