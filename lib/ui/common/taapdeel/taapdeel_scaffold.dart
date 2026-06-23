import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

/// TaapdeelScaffold – Bright Background (No Gray/No Black) + subtle blobs
/// ✅ NO withOpacity() anywhere (ARGB colors only)
class TaapdeelScaffold extends StatefulWidget {
  const TaapdeelScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.bottom,
    this.safeTop = true,
    this.safeBottom = true,
    this.padding = const EdgeInsets.symmetric(horizontal: PsDimens.space16),

    /// overlay floating widget
    this.floatingTopLeft,
    this.floatingTopLeftMargin =
    const EdgeInsetsDirectional.only(start: 12, top: 10),
  }) : super(key: key);

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottom;
  final bool safeTop;
  final bool safeBottom;
  final EdgeInsets padding;

  final Widget? floatingTopLeft;
  final EdgeInsetsDirectional floatingTopLeftMargin;

  @override
  State<TaapdeelScaffold> createState() => _TaapdeelScaffoldState();
}

class _TaapdeelScaffoldState extends State<TaapdeelScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // ✅ Palette (No gray / No black)
  static const Color _bg = Color(0xFFF9FCFF); // bright sky-white
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _primaryBlue = Color(0xFF3B6FB6);
  static const Color _softGold = Color(0xFFFFE7A3);
  static const Color _mintTeal = Color(0xFFEAF7F5);

  // ✅ ARGB tints (no withOpacity)
  // PrimaryBlue tints:
  static const Color _blue09 = Color(0x173B6FB6); // ~9%
  static const Color _blue05 = Color(0x0D3B6FB6); // ~5%
  static const Color _blue04 = Color(0x0A3B6FB6); // ~4%
  static const Color _blue10 = Color(0x1A3B6FB6); // ~10%

  // Mint tints:
  static const Color _mint62 = Color(0xFFFFFFFF); // ~62%
  static const Color _mint32 = Color(0xFFFFFFFF); // ~32%

  // White tints:
  static const Color _white22 = Color(0x38FFFFFF); // ~22%
  static const Color _white42 = Color(0x6BFFFFFF); // ~42%

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _wave(double phase, double amplitude) {
    final double t = _controller.value;
    return math.sin((t * 2 * math.pi) + phase) * amplitude;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // ✅ force base background (important)
      backgroundColor: _bg,

      // Glass AppBar
      appBar: widget.appBar != null
          ? PreferredSize(
        preferredSize: widget.appBar!.preferredSize,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0x1FFFFFFF), // 12% white
                border: Border(
                  bottom: BorderSide(
                    color: Color(0x4DFFFFFF), // 30% white
                    width: 0.6,
                  ),
                ),
              ),
              child: widget.appBar,
            ),
          ),
        ),
      )
          : null,

      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double topBlobDy = _wave(0.0, 14);
          final double midBlobDx = _wave(1.2, 12);
          final double bottomBlobDy = _wave(2.4, 16);

          final bool hasBottomBar = widget.bottom != null;
          final bool effectiveSafeBottom =
          hasBottomBar ? false : widget.safeBottom;

          final double statusTop = MediaQuery.of(context).padding.top;
          final double appBarH = widget.appBar?.preferredSize.height ?? 0;

          final double floatTop = (widget.safeTop ? statusTop : 0) +
              appBarH +
              widget.floatingTopLeftMargin.top;

          return Stack(
            children: <Widget>[
              // 1) Bright base gradient
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        _bg,
                        _bg,
                        _card,
                      ],
                      stops: <double>[0.0, 0.78, 1.0],
                    ),
                  ),
                ),
              ),

              // 2) Top-right blue glow
              Positioned(
                top: -150 + topBlobDy,
                right: -90,
                child: Container(
                  width: 440,
                  height: 330,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(260),
                    gradient: RadialGradient(
                      radius: 1.22 + _wave(0.6, 0.04),
                      center: Alignment(
                        0.35,
                        -0.25 + _wave(0.3, 0.06),
                      ),
                      colors: const <Color>[
                        _blue09,
                        _blue05,
                      ],
                    ),
                  ),
                ),
              ),

              // 3) Middle mint haze
              Positioned(
                top: 90,
                left: -50 + midBlobDx,
                right: -90 - midBlobDx,
                child: Container(
                  height: 270,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(220),
                    gradient: RadialGradient(
                      radius: 1.18 + _wave(1.8, 0.04),
                      center: Alignment(
                        -0.25 + _wave(1.0, 0.08),
                        -0.15,
                      ),
                      colors: const <Color>[
                        _blue05,
                        _blue05,
                      ],
                    ),
                  ),
                ),
              ),

              // 4) Bottom-left faint mix
              Positioned(
                bottom: -140 + bottomBlobDy,
                left: -95,
                child: Container(
                  width: 440,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(260),
                    gradient: RadialGradient(
                      radius: 1.28 + _wave(2.6, 0.05),
                      center: Alignment(
                        -0.35,
                        0.85 + _wave(2.0, 0.06),
                      ),
                      colors: <Color>[
                        const Color(0xFFCFE6FF).withAlpha(100),
                        const Color(0xFF2F8CFF).withAlpha(10),
                      ],
                    ),
                  ),
                ),
              ),

              // 5) Small white highlight
              Positioned(
                top: 210,
                right: -45 + _wave(0.9, 9),
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(180),
                    gradient: RadialGradient(
                      radius: 0.92 + _wave(1.4, 0.03),
                      center: Alignment(
                        0.5,
                        -0.3 + _wave(1.1, 0.05),
                      ),
                      colors: const <Color>[
                        _white42,
                        Color(0xFFD0E8E2),
                      ],
                    ),
                  ),
                ),
              ),

              // 6) Bottom depth (no black)
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[
                        _blue04,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 7) Main content
              SafeArea(
                top: widget.safeTop,
                bottom: effectiveSafeBottom,
                child: Padding(
                  padding: widget.padding,
                  child: widget.body,
                ),
              ),

              // 8) Floating overlay
              if (widget.floatingTopLeft != null)
                PositionedDirectional(
                  top: floatTop,
                  start: widget.floatingTopLeftMargin.start,
                  child: widget.floatingTopLeft!,
                ),
            ],
          );
        },
      ),

      bottomNavigationBar: widget.bottom != null
          ? SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          PsDimens.space8,
          0,
          PsDimens.space8,
          PsDimens.space8,
        ),
        child: widget.bottom!,
      )
          : null,

    );
  }
}
