import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

class _C
{
  static const Color navy = Color(0xFF061F3A);
  static const Color deepNavy = Color(0xFF082B49);
  static const Color petrol = Color(0xFF0B5471);
  static const Color teal = Color(0xFF0E989B);
  static const Color cyan = Color(0xFF24A9C4);
  static const Color softText = Color(0xFF3E6078);
  static const Color softBorder = Color(0xFFDCEEF5);
  static const String font = 'Cairo';
}

class _FeatureData {
  const _FeatureData(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
}

class TaapdeelSingleIntroView extends StatefulWidget {
  const TaapdeelSingleIntroView({
    Key? key,
    this.logoAsset = 'assets/images/Taapdeel_logo.png',
    this.heroAsset = 'assets/images/taapdeel_intro_center_illustration.png',
    this.aiScanAsset = 'assets/images/taapdeel_intro_ai_scan_phone.png',
    this.buttonText = 'ابدأ مع تبديل',
    this.onStart,
  }) : super(key: key);

  final String logoAsset;
  final String heroAsset;
  final String aiScanAsset;
  final String buttonText;
  final VoidCallback? onStart;

  @override
  State<TaapdeelSingleIntroView> createState() => _TaapdeelSingleIntroViewState();
}

class _TaapdeelSingleIntroViewState extends State<TaapdeelSingleIntroView>
    with TickerProviderStateMixin {
  late final AnimationController _seq;
  late final AnimationController _shimmer;
  late final AnimationController _logoPulse;

  late final Animation<double> _logoAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _subAnim;
  late final Animation<double> _heroAnim;
  late final Animation<double> _benefitsAnim;
  late final Animation<double> _timelineAnim;
  late final Animation<double> _featuresAnim;
  late final Animation<double> _buttonAnim;

  @override
  void initState() {
    super.initState();

    _seq = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    );

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    )..repeat();

    _logoPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _logoAnim = _ease(0.00, 0.14);
    _titleAnim = _ease(0.08, 0.27);
    _subAnim = _ease(0.16, 0.34);
    _heroAnim = _ease(0.25, 0.48);
    _benefitsAnim = _ease(0.38, 0.58);
    _timelineAnim = _ease(0.50, 0.84);
    _featuresAnim = _ease(0.70, 0.94);
    _buttonAnim = _ease(0.82, 1.00);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _seq.forward();
    });
  }

  Animation<double> _ease(double b, double e) => CurvedAnimation(
    parent: _seq,
    curve: Interval(b, e, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _seq.dispose();
    _shimmer.dispose();
    _logoPulse.dispose();
    super.dispose();
  }

  void _start() {
    if (widget.onStart != null) {
      widget.onStart!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final Size size = mq.size;
    final bool compact = size.height < 760;
    final bool veryCompact = size.height < 690;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: TaapdeelScaffold(
        safeTop: true,
        safeBottom: false,
        padding: EdgeInsets.zero,
        bottom: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: _FadeSlide(
            anim: _buttonAnim,
            dy: 30,
            child: _CtaButton(
              text: widget.buttonText,
              shimmer: _shimmer,
              onTap: _start,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            18,
            veryCompact ? 10 : 24,
            18,
            30,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _FadeSlide(
                    anim: _logoAnim,
                    dy: -16,
                    child: _LogoSection(
                      logoAsset: widget.logoAsset,
                      pulse: _logoPulse,
                      compact: compact,
                    ),
                  ),
                  SizedBox(height: veryCompact ? 8 : 13),
                  _FadeSlide(
                    anim: _titleAnim,
                    dy: 20,
                    child: _Headline(compact: compact),
                  ),
                  SizedBox(height: compact ? 5 : 7),
                  _FadeSlide(
                    anim: _subAnim,
                    dy: 14,
                    child: _Subtitle(compact: compact),
                  ),
                  /*SizedBox(height: compact ? 8 : 12),
                  _FadeSlide(
                    anim: _benefitsAnim,
                    dy: 18,
                    child: const _BenefitsStrip(),
                  ),*/
                  SizedBox(height: compact ? 10 : 16),
                  _FadeSlide(
                    anim: _heroAnim,
                    dy: 26,
                    child: _HeroArtwork(
                      heroAsset: widget.heroAsset,
                      compact: compact,
                    ),
                  ),

                  SizedBox(height: compact ? 14 : 20),
                  _FadeSlide(
                    anim: _timelineAnim,
                    dy: 24,
                    child: _TimelineSteps(
                      compact: compact,
                      aiScanAsset: widget.aiScanAsset,
                    ),
                  ),
                  SizedBox(height: compact ? 16 : 22),
                  _FadeSlide(
                    anim: _featuresAnim,
                    dy: 20,
                    child: const _AutoFeaturesSection(),
                  ),
                  SizedBox(height: compact ? 8 : 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.anim, required this.child, this.dy = 20});

  final Animation<double> anim;
  final Widget child;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, Widget? c) {
        final double v = anim.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * dy),
            child: Transform.scale(
              scale: 0.98 + v * 0.02,
              child: c,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection({
    required this.logoAsset,
    required this.pulse,
    required this.compact,
  });

  final String logoAsset;
  final AnimationController pulse;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double boxSize = compact ? 54 : 62;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedBuilder(
          animation: pulse,
          builder: (_, Widget? child) {
            return Transform.scale(
              scale: 1.0 + pulse.value * 0.014,
              child: child,
            );
          },
          child: Container(
            width: boxSize,
            height: boxSize,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.84),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: Colors.white.withOpacity(0.85)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _C.teal.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.70),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Image.asset(
              logoAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.swap_horiz_rounded,
                color: _C.teal,
                size: 34,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: <Color>[Color(0xFF061F3A), Color(0xFF0D7E9B)],
      ).createShader(bounds),
      child: Text(
        'أنت أغنى مما تتخيل',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: _C.font,
          color: Colors.white,
          fontSize: compact ? 22 : 25,
          fontWeight: FontWeight.w900,
          height: 1.15,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      'بدّل منتجاتك غير المستخدمة بمنتجات مناسبة لك ولعائلتك',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: _C.font,
        color: _C.deepNavy.withOpacity(0.72),
        fontSize: compact ? 15 : 17,
        fontWeight: FontWeight.w600,
        height: 1.55,
      ),
    );
  }
}

class _HeroArtwork extends StatelessWidget {
  const _HeroArtwork({required this.heroAsset, required this.compact});

  final String heroAsset;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double height = compact ? 126 : 190;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.88,
                  colors: <Color>[
                    const Color(0xFFDBF2F8).withOpacity(0.38),
                    const Color(0xFFEAF7FB).withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              heroAsset,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.swap_horiz_rounded,
                color: _C.teal,
                size: 64,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsStrip extends StatelessWidget {
  const _BenefitsStrip();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: const Row(
        children: <Widget>[
          Expanded(
            child: _Benefit(
              icon: Icons.payments_rounded,
              label: 'وفر فلوسك',
              color: Color(0xFF0B9A75),
            ),
          ),
          _Vdivider(),
          Expanded(
            child: _Benefit(
              icon: Icons.person_search_rounded,
              label: 'وفر مجهودك',
              color: Color(0xFF0E989B),
            ),
          ),
          _Vdivider(),
          Expanded(
            child: _Benefit(
              icon: Icons.lightbulb_rounded,
              label: 'جدد حياتك',
              color: Color(0xFF0D5E7B),
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: _C.font,
              color: _C.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _Vdivider extends StatelessWidget {
  const _Vdivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: _C.softBorder.withOpacity(0.72));
  }
}

class _TimelineSteps extends StatelessWidget {
  const _TimelineSteps({required this.compact, required this.aiScanAsset});

  final bool compact;
  final String aiScanAsset;

  @override
  Widget build(BuildContext context) {
    final double gap = compact ? 10 : 12;
    final double cardHeight = compact ? 150 : 166;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _StepCard(
                number: '1',
                title: 'صوّر منتجاتك',
                sub: 'تبديل هتحلل وتستكمل بيانات منتجاتك بالذكاء الاصطناعي .',
                height: cardHeight,
                visual: _AiPhoneVisual(asset: aiScanAsset),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _StepCard(
                number: '2',
                title: 'استكشف الترشيحات',
                sub: 'تبديل هتقدملك ترشيحات تبديل حسب اهتماماتك.',
                height: cardHeight,
                visual: const _RotatingRecommendationsVisual(),
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        Row(
          children: <Widget>[
            Expanded(
              child: _StepCard(
                number: '3',
                title: 'قارن واختر',
                sub: 'تبديل هنقدملك تقييم لكل فرصة لتسهيل اختيار الفرصة الأنسب.',
                height: cardHeight,
                visual: const _CompareVisual(),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _StepCard(
                number: '4',
                title: 'بدّل بأمان',
                sub: 'تبديل هتساعدك تكون دائرة موثوقة من الأصدقاء والأقارب لتبديل آمن.',
                height: cardHeight,
                visual: const _SafeSwapVisual(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepCard extends StatefulWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.sub,
    required this.height,
    required this.visual,
  });

  final String number;
  final String title;
  final String sub;
  final double height;
  final Widget visual;

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: SizedBox(
          height: widget.height,
          child: _GlassCard(
            radius: 25,
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _TimelineNumber(number: widget.number),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: _C.font,
                          color: _C.deepNavy,
                          fontSize: 14.2,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: widget.visual,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  widget.sub,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _C.font,
                    color: _C.softText.withOpacity(0.84),
                    fontSize: 10.3,
                    fontWeight: FontWeight.w700,
                    height: 1.32,
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

class _TimelineNumber extends StatelessWidget {
  const _TimelineNumber({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF24A9C4), Color(0xFF0D5E7B)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.90), width: 2.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _C.teal.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        number,
        style: const TextStyle(
          fontFamily: _C.font,
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _AiPhoneVisual extends StatelessWidget {
  const _AiPhoneVisual({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFEAF8F8).withOpacity(0.78),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _C.teal.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.camera_alt_rounded,
            color: _C.teal,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class _RotatingRecommendationsVisual extends StatefulWidget {
  const _RotatingRecommendationsVisual();

  @override
  State<_RotatingRecommendationsVisual> createState() => _RotatingRecommendationsVisualState();
}

class _RotatingRecommendationsVisualState extends State<_RotatingRecommendationsVisual> {
  static const List<String> _productAssets = <String>[
    'assets/images/products/17_headphones_closeup.jpg',
    'assets/images/products/05_white_bag_closeup.png',
    'assets/images/products/18_ps5_console_closeup.jpg',
    'assets/images/products/smartwatch.png',
  ];

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2100), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _productAssets.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String asset = _productAssets[_index];

    return SizedBox(
      width: 128,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          PositionedDirectional(
            start: 5,
            bottom: 3,
            child: _RecommendationShadowDot(
              size: 22,
              opacity: 0.10,
            ),
          ),
          PositionedDirectional(
            end: 7,
            top: 5,
            child: _RecommendationShadowDot(
              size: 17,
              opacity: 0.08,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 520),
            reverseDuration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final Animation<Offset> slide = Tween<Offset>(
                begin: const Offset(0.10, 0.00),
                end: Offset.zero,
              ).animate(animation);

              final Animation<double> scale = Tween<double>(
                begin: 0.94,
                end: 1.0,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: slide,
                  child: ScaleTransition(
                    scale: scale,
                    child: child,
                  ),
                ),
              );
            },
            child: _RecommendationProductImage(
              key: ValueKey<String>(asset),
              asset: asset,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationProductImage extends StatelessWidget {
  const _RecommendationProductImage({
    required Key? key,
    required this.asset,
  });

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.cyan.withOpacity(0.24)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _C.teal.withOpacity(0.13),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.75),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              asset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFEAF8F8),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: _C.teal,
                  size: 34,
                ),
              ),
            ),
            PositionedDirectional(
              end: 5,
              bottom: 5,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.90),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _C.teal.withOpacity(0.13),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _C.teal,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationShadowDot extends StatelessWidget {
  const _RecommendationShadowDot({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _C.cyan.withOpacity(opacity),
      ),
    );
  }
}

class _CompareVisual extends StatelessWidget {
  const _CompareVisual();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 132,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 0,
            child: _ScoreCard(
              icon: Icons.headphones_rounded,
              title: 'سماعة',
              score: '92%',
              good: true,
            ),
          ),
          Positioned(
            right: 0,
            child: _ScoreCard(
              icon: Icons.sports_esports_outlined,
              title: 'العاب',
              score: '85%',
              good: false,
            ),
          ),
          _VsBubble(),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.icon,
    required this.title,
    required this.score,
    required this.good,
  });

  final IconData icon;
  final String title;
  final String score;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final Color color = good ? const Color(0xFF0B9A75) : const Color(0xFF5B7FE8);
    return Container(
      width: 60,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: good ? const Color(0xFFB8EAD8) : const Color(0xFFCDD8F8),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontFamily: _C.font,
              color: _C.navy,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Icon(icon, color: Colors.black87, size: 22),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.verified_rounded, color: color, size: 10),
              const SizedBox(width: 2),
              Text(
                score,
                style: TextStyle(
                  fontFamily: _C.font,
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VsBubble extends StatelessWidget {
  const _VsBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFE5FBFB), Color(0xFFCBF1F1)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _C.teal.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'vs',
        style: TextStyle(
          fontFamily: _C.font,
          color: _C.petrol,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SafeSwapVisual extends StatelessWidget {
  const _SafeSwapVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          PositionedDirectional(
            start: 4,
            bottom: 2,
            child: _PersonBubble(
              icon: Icons.person_rounded,
              color: const Color(0xFF5B7FE8),
              label: 'اصدقاء',
            ),
          ),
          PositionedDirectional(
            end: 4,
            bottom: 2,
            child: _PersonBubble(
              icon: Icons.family_restroom_rounded,
              color: const Color(0xFF0B9A75),
              label: 'اقارب',
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF24A9C4), Color(0xFF0D5E7B)],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.92), width: 3),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _C.teal.withOpacity(0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 27),
          ),
        ],
      ),
    );
  }
}

class _PersonBubble extends StatelessWidget {
  const _PersonBubble({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      height: 65,
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: _C.font,
              color: _C.deepNavy,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoFeaturesSection extends StatelessWidget {
  const _AutoFeaturesSection();

  static const List<_FeatureData> _features = <_FeatureData>[
    _FeatureData(Icons.sell_rounded, 'منتجات لقطة', Color(0xFFFFAA2C)),
    _FeatureData(Icons.favorite_rounded, 'حسب اهتماماتك', Color(0xFFFF6B8A)),
    _FeatureData(Icons.groups_rounded, 'معرض لمنتجات العائلة', Color(0xFF5B7FE8)),
    _FeatureData(Icons.share_rounded, 'كروت مشاركة', Color(0xFF0D5E7B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            _GradientDividerLine(),
            SizedBox(width: 12),
            Text(
              'ومميزات أكثر',
              style: TextStyle(
                fontFamily: _C.font,
                color: _C.deepNavy,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 12),
            _GradientDividerLine(),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: _features
              .map((f) => _FeatureCircle(
            icon: f.icon,
            label: f.label,
            accent: f.color,
          ))
              .toList(),
        ),
      ],
    );
  }
}

class _GradientDividerLine extends StatelessWidget {
  const _GradientDividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 1.5,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Colors.transparent, Color(0xFF0E989B)],
        ),
      ),
    );
  }
}

class _FeatureCircle extends StatelessWidget {
  const _FeatureCircle({required this.icon, required this.label, required this.accent});

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.56),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.86)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.10),
              border: Border.all(color: accent.withOpacity(0.18)),
            ),
            child: Icon(icon, color: accent, size: 23),
          ),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _C.font,
                color: _C.navy,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatefulWidget {
  const _CtaButton({required this.text, required this.shimmer, required this.onTap});

  final String text;
  final AnimationController shimmer;
  final VoidCallback onTap;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: <Color>[Color(0xFF061F3A), Color(0xFF0D5E7B), Color(0xFF0FA3A6)],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF0D5E7B).withOpacity(_pressed ? 0.34 : 0.24),
                blurRadius: _pressed ? 32 : 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                AnimatedBuilder(
                  animation: widget.shimmer,
                  builder: (_, __) {
                    final double x = widget.shimmer.value * 1.8 - 0.4;
                    return Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: AlignmentDirectional(x - 0.3, 0),
                            end: AlignmentDirectional(x + 0.3, 0),
                            colors: <Color>[
                              Colors.transparent,
                              Colors.white.withOpacity(0.10),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const PositionedDirectional(
                  start: 20,
                  child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                ),
                Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: _C.font,
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    required this.padding,
    required this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.54),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Color(0xFF64D6CD).withOpacity(0.82)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _C.petrol.withOpacity(0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
