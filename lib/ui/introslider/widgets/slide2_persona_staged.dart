import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';

import '../content/intro_slide2_content.dart';
import '../logic/persona_resolver.dart';
import '../models/intro_models.dart';

/// Slide 2 — AI product understanding + best swap recommendation.
/// Depends only on Slide 2 content.
class Slide2PersonaStaged extends StatefulWidget {
  const Slide2PersonaStaged({
    Key? key,
    required this.psValueHolder,
    required this.playKey,
  }) : super(key: key);

  final PsValueHolder? psValueHolder;
  final int playKey;

  @override
  State<Slide2PersonaStaged> createState() => _Slide2PersonaStagedState();
}

// ── Palette ─────────────────────────────────────────────────────────────────
const Color _kPrimaryNavy = Color(0xFF3B5B86);
const Color _kDeepNavy = Color(0xFF3B5B86);

const Color _kIndigo = Color(0xFF3B5B86);
const Color _kViolet = Color(0xFF3B5B86);

const Color _kSoftLavender = Color(0xFFEAF8FF);
const Color _kLavenderBorder = Color(0xFFCDEFFF);

const Color _kMutedText = Color(0xFF5A6A7A);
const Color _kImageFallback = Color(0xFFEAF8FF);

// ── Animation timeline (normalized 0.0 → 1.0 over 5600ms total) ─────────────
// 0.00 – 0.08  logo fades in
// 0.08 – 0.20  header fades in
// 0.20 – 0.32  card image fades in
// 0.32 – 0.52  scan line sweeps top→bottom
// 0.52 – 0.84  tags pop in one by one (each ~0.08 wide)
// 0.86 – 0.93  swap header (title + badge) fades in
// 0.91 – 1.00  swap body (products + chips) slides in
const double _kScanBegin = 0.32;
const double _kScanEnd = 0.52;

// Each tag starts after the previous one, staggered by 0.08
const List<double> _kTagBegins = <double>[0.52, 0.60, 0.68, 0.76];

// Swap section timing
const double _kSwapHeaderBegin = 0.86;
const double _kSwapHeaderEnd = 0.93;
const double _kSwapBodyBegin = 0.91;
const double _kSwapBodyEnd = 1.00;

class _Slide2PersonaStagedState extends State<Slide2PersonaStaged>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
      animationBehavior: AnimationBehavior.preserve,
    )..forward();
  }

  @override
  void didUpdateWidget(covariant Slide2PersonaStaged oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.playKey != widget.playKey) {
      _c
        ..stop()
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _fade({
    required Widget child,
    required double begin,
    required double end,
    double dy = 12,
  }) {
    final Animation<double> anim = CurvedAnimation(
      parent: _c,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: anim,
      child: AnimatedBuilder(
        animation: anim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, (1 - anim.value) * dy),
          child: child,
        ),
      ),
    );
  }

  IntroPersonaKey _resolvePersonaKey() {
    return PersonaResolver.resolve(widget.psValueHolder, debugLogs: false);
  }

  IntroSlide2Model _resolveModel(IntroPersonaKey key) {
    return slide2NewContent[key] ??
        slide2NewContent[IntroPersonaKey.male23Plus]!;
  }

  @override
  Widget build(BuildContext context) {
    final IntroPersonaKey personaKey = _resolvePersonaKey();
    final IntroSlide2Model model = _resolveModel(personaKey);

    final Size size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    final bool compact = height < 760 || width < 380;
    final double reservedBottom = 148 + bottomInset;

    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(bottom: reservedBottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: compact ? 8 : 14),

            _fade(
              begin: 0.00,
              end: 0.10,
              child: const _TaapdeelLogoBadge(),
            ),

            SizedBox(height: compact ? 6 : 10),

            _fade(
              begin: 0.08,
              end: 0.20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: <Widget>[
                    Text(
                      model.headerTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: _kPrimaryNavy,
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 22 : 27,
                        height: 1.16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: compact ? 5 : 7),
                    Text(
                      model.headerSubtitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: _kMutedText,
                        fontSize: compact ? 13 : 14.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: compact ? 12 : 16),

            _fade(
              begin: 0.20,
              end: 0.32,
              dy: 14,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
                child: _AiProductUnderstandingSection(
                  personaKey: personaKey,
                  imageAsset: model.myProductImageAsset,
                  title: model.myProductTitle,
                  controller: _c,
                  compact: compact,
                ),
              ),
            ),

            SizedBox(height: compact ? 12 : 16),

            _fade(
              begin: _kSwapHeaderBegin,
              end: 1.00,
              dy: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
                child: _SwapRecommendationSection(
                  model: model,
                  compact: compact,
                  controller: _c,
                ),
              ),
            ),

            SizedBox(height: compact ? 8 : 10),
          ],
        ),
      ),
    );
  }
}

// ── Logo ─────────────────────────────────────────────────────────────────────

class _TaapdeelLogoBadge extends StatelessWidget {
  const _TaapdeelLogoBadge();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Taapdeel_logo.png',
      height: 50,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Text(
        'TaapdeeL',
        style: TextStyle(
          color: _kPrimaryNavy,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }
}

// ── Section 1: AI Product Understanding ──────────────────────────────────────

class _AiProductUnderstandingSection extends StatelessWidget {
  const _AiProductUnderstandingSection({
    required this.personaKey,
    required this.imageAsset,
    required this.title,
    required this.controller,
    required this.compact,
  });

  final IntroPersonaKey personaKey;
  final String imageAsset;
  final String title;
  final AnimationController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final double cardWidth = (screenWidth - (compact ? 58 : 72))
        .clamp(compact ? 250 : 270, 430)
        .toDouble();

    final double cardHeight = compact ? cardWidth * 0.58 : cardWidth * 0.62;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _SectionTitle(
          title: 'بنفهم منتجك بالذكاء الاصطناعي',
          icon: Icons.auto_awesome_rounded,
          compact: compact,
        ),

        SizedBox(height: compact ? 8 : 10),

        Center(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: PhysicalModel(
              color: Colors.transparent,
              elevation: compact ? 10 : 14,
              shadowColor: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    // ── Product image ────────────────────────────────────────
                    Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => Container(
                        color: _kImageFallback,
                        child: const Icon(
                          Icons.image_outlined,
                          color: _kIndigo,
                          size: 34,
                        ),
                      ),
                    ),

                    // ── Gradient overlay ─────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.black.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0.02),
                            Colors.black.withValues(alpha: 0.34),
                          ],
                        ),
                      ),
                    ),

                    // ── AI Scan overlay (sweeping lens) ──────────────────────
                    _AiScanOverlay(
                      controller: controller,
                      cardHeight: cardHeight,
                    ),

                    // ── Centre sparkle ───────────────────────────────────────
                    const Center(
                      child: _AiSparkleMark(),
                    ),

                    // ── Bottom product info ──────────────────────────────────
                    Positioned(
                      left: compact ? 12 : 14,
                      right: compact ? 12 : 14,
                      bottom: compact ? 12 : 14,
                      child: _AiProductBottomInfo(
                        title: title,
                        compact: compact,
                      ),
                    ),

                    // ── Animated tags (sequential after scan) ────────────────
                    ..._buildAnimatedTags(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAnimatedTags() {
    final List<_AiOverlayTag> tags = _aiOverlayTagsForPersona(personaKey);

    if (tags.isEmpty) return const <Widget>[];

    return List<Widget>.generate(tags.length, (int index) {
      final _AiOverlayTag tag = tags[index];
      // Each tag has its own begin; end is begin + 0.07
      final double begin =
      index < _kTagBegins.length ? _kTagBegins[index] : 0.55 + index * 0.08;
      final double end = (begin + 0.07).clamp(0.0, 1.0);

      return Align(
        alignment: tag.alignment,
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final double pop = CurvedAnimation(
              parent: controller,
              curve: Interval(begin, end, curve: Curves.easeOutBack),
            ).value;

            final double fade = CurvedAnimation(
              parent: controller,
              curve: Interval(begin, end, curve: Curves.easeOut),
            ).value;

            return Opacity(
              opacity: fade.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (1 - fade) * 14),
                child: Transform.scale(
                  scale: 0.80 + pop * 0.22,
                  child: _SolidAiTagChip(
                    icon: tag.icon,
                    text: tag.text,
                    compact: compact,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  List<_AiOverlayTag> _aiOverlayTagsForPersona(IntroPersonaKey key) {
    switch (key) {
      case IntroPersonaKey.male23Plus:
        return const <_AiOverlayTag>[
          _AiOverlayTag(
            icon: Icons.work_outline_rounded,
            text: 'إكسسوار عملي',
            alignment: Alignment(-0.84, -0.22),
          ),
          _AiOverlayTag(
            icon: Icons.laptop_mac_rounded,
            text: 'مناسب للاب توب',
            alignment: Alignment(0.84, -0.14),
          ),
          _AiOverlayTag(
            icon: Icons.inventory_2_rounded,
            text: 'سهل الحمل',
            alignment: Alignment(-0.78, 0.28),
          ),
          _AiOverlayTag(
            icon: Icons.auto_graph_rounded,
            text: 'طلبه عالي',
            alignment: Alignment(0.78, 0.34),
          ),
        ];

      case IntroPersonaKey.maleUnder23:
        return const <_AiOverlayTag>[
          _AiOverlayTag(
            icon: Icons.sports_esports_rounded,
            text: 'Gaming Gear',
            alignment: Alignment(-0.84, -0.22),
          ),
          _AiOverlayTag(
            icon: Icons.headphones_rounded,
            text: 'إكسسوار ألعاب',
            alignment: Alignment(0.84, -0.14),
          ),
          _AiOverlayTag(
            icon: Icons.bolt_rounded,
            text: 'استخدام يومي',
            alignment: Alignment(-0.78, 0.28),
          ),
          _AiOverlayTag(
            icon: Icons.trending_up_rounded,
            text: 'رائج بين الشباب',
            alignment: Alignment(0.78, 0.34),
          ),
        ];

      case IntroPersonaKey.female23Plus:
        return const <_AiOverlayTag>[
          _AiOverlayTag(
            icon: Icons.child_friendly_rounded,
            text: 'منتج أطفال',
            alignment: Alignment(-0.84, -0.22),
          ),
          _AiOverlayTag(
            icon: Icons.family_restroom_rounded,
            text: 'استخدام عائلي',
            alignment: Alignment(0.84, -0.14),
          ),
          _AiOverlayTag(
            icon: Icons.inventory_rounded,
            text: 'حجم كبير',
            alignment: Alignment(-0.78, 0.28),
          ),
          _AiOverlayTag(
            icon: Icons.restart_alt_rounded,
            text: 'قابل للتدوير',
            alignment: Alignment(0.78, 0.34),
          ),
        ];

      case IntroPersonaKey.femaleUnder23:
        return const <_AiOverlayTag>[
          _AiOverlayTag(
            icon: Icons.style_rounded,
            text: 'ستايل شبابي',
            alignment: Alignment(-0.84, -0.22),
          ),
          _AiOverlayTag(
            icon: Icons.workspace_premium_rounded,
            text: 'براند',
            alignment: Alignment(0.84, -0.14),
          ),
          _AiOverlayTag(
            icon: Icons.shopping_bag_rounded,
            text: 'بيج',
            alignment: Alignment(-0.78, 0.28),
          ),
          _AiOverlayTag(
            icon: Icons.auto_awesome_rounded,
            text: 'حقيبة ظهر',
            alignment: Alignment(0.78, 0.34),
          ),
        ];
    }
  }
}

// ── AI Scan Overlay ───────────────────────────────────────────────────────────

/// Renders a glowing horizontal scan line that sweeps from top to bottom
/// during [_kScanBegin] → [_kScanEnd], then fades out.
class _AiScanOverlay extends StatelessWidget {
  const _AiScanOverlay({
    required this.controller,
    required this.cardHeight,
  });

  final AnimationController controller;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext ctx, _) {
        // Progress of the scan (0→1 during scan window)
        final double scanProgress = CurvedAnimation(
          parent: controller,
          curve: const Interval(
            _kScanBegin,
            _kScanEnd,
            curve: Curves.easeInOut,
          ),
        ).value;

        // Fade out the scan line once scan is done
        final double scanFade = CurvedAnimation(
          parent: controller,
          curve: Interval(
            _kScanEnd,
            (_kScanEnd + 0.05).clamp(0.0, 1.0),
            curve: Curves.easeIn,
          ),
        ).value;

        if (scanProgress == 0.0) return const SizedBox.shrink();

        final double lineY = scanProgress * cardHeight;
        final double opacity = (1.0 - scanFade).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Stack(
            children: <Widget>[
              // ── Dark tint above scan line ─────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: lineY,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withValues(alpha: 0.28),
                        Colors.black.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Glowing scan line ─────────────────────────────────────────
              Positioned(
                top: lineY - 1,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.transparent,
                        Color(0xFF5DBBFF),
                        Colors.white,
                        Color(0xFF5DBBFF),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x995DBBFF),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Corner bracket: top-left ──────────────────────────────────
              const Positioned(
                top: 10,
                left: 10,
                child: _ScanCorner(flipX: false, flipY: false),
              ),

              // ── Corner bracket: top-right ─────────────────────────────────
              const Positioned(
                top: 10,
                right: 10,
                child: _ScanCorner(flipX: true, flipY: false),
              ),

              // ── Corner bracket: bottom-left ───────────────────────────────
              const Positioned(
                bottom: 10,
                left: 10,
                child: _ScanCorner(flipX: false, flipY: true),
              ),

              // ── Corner bracket: bottom-right ──────────────────────────────
              const Positioned(
                bottom: 10,
                right: 10,
                child: _ScanCorner(flipX: true, flipY: true),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// An L-shaped corner bracket used in the scan overlay.
class _ScanCorner extends StatelessWidget {
  const _ScanCorner({
    required this.flipX,
    required this.flipY,
  });

  final bool flipX;
  final bool flipY;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0),
      child: SizedBox(
        width: 18,
        height: 18,
        child: CustomPaint(
          painter: _CornerBracketPainter(),
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF5DBBFF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Vertical arm
    canvas.drawLine(
      Offset(0, size.height),
      const Offset(0, 0),
      paint,
    );
    // Horizontal arm
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Shared overlay tag model ──────────────────────────────────────────────────

class _AiOverlayTag {
  const _AiOverlayTag({
    required this.icon,
    required this.text,
    required this.alignment,
  });

  final IconData icon;
  final String text;
  final Alignment alignment;
}

// ── Sparkle mark ─────────────────────────────────────────────────────────────

class _AiSparkleMark extends StatelessWidget {
  const _AiSparkleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.32),
        ),
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: _kViolet,
        size: 25,
      ),
    );
  }
}

// ── AI product bottom info ────────────────────────────────────────────────────

class _AiProductBottomInfo extends StatelessWidget {
  const _AiProductBottomInfo({
    required this.title,
    required this.compact,
  });

  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: <Widget>[
        Container(
          width: compact ? 30 : 34,
          height: compact ? 30 : 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: _kViolet,
            size: compact ? 17 : 19,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 13 : 14.5,
              shadows: const <Shadow>[
                Shadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Solid AI tag chip ─────────────────────────────────────────────────────────

class _SolidAiTagChip extends StatelessWidget {
  const _SolidAiTagChip({
    required this.icon,
    required this.text,
    required this.compact,
  });

  final IconData icon;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: compact ? 122 : 142,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: <double>[0.0, 0.45, 1.0],
          colors: <Color>[
            _kDeepNavy,
            _kIndigo,
            _kViolet,
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _kViolet.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
            size: compact ? 12 : 13,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 9.8 : 10.8,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section 2: Swap Recommendation ──────────────────────────────────────────

class _SwapRecommendationSection extends StatefulWidget {
  const _SwapRecommendationSection({
    required this.model,
    required this.compact,
    required this.controller,
  });

  final IntroSlide2Model model;
  final bool compact;
  final AnimationController controller;

  @override
  State<_SwapRecommendationSection> createState() =>
      _SwapRecommendationSectionState();
}

class _SwapRecommendationSectionState extends State<_SwapRecommendationSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _candidateLoopController;

  @override
  void initState() {
    super.initState();
    _candidateLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8800),
      animationBehavior: AnimationBehavior.preserve,
    );

    widget.controller.addStatusListener(_handleParentStatus);
    if (widget.controller.isCompleted) {
      _startCandidateLoop();
    }
  }

  @override
  void didUpdateWidget(covariant _SwapRecommendationSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeStatusListener(_handleParentStatus);
      widget.controller.addStatusListener(_handleParentStatus);
    }

    if (oldWidget.model != widget.model) {
      _candidateLoopController
        ..stop()
        ..reset();

      if (widget.controller.isCompleted) {
        _startCandidateLoop();
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeStatusListener(_handleParentStatus);
    _candidateLoopController.dispose();
    super.dispose();
  }

  void _handleParentStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
      _candidateLoopController
        ..stop()
        ..reset();
    }

    if (status == AnimationStatus.completed) {
      _startCandidateLoop();
    }
  }

  void _startCandidateLoop() {
    if (!mounted || _candidateLoopController.isAnimating) return;
    _candidateLoopController.repeat();
  }

  Widget _animatedChild({
    required Widget child,
    required double begin,
    required double end,
    double dy = 14,
  }) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        final double t = CurvedAnimation(
          parent: widget.controller,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * dy),
            child: child,
          ),
        );
      },
    );
  }

  List<_IntroCandidateSwapOption> _candidateOptions() {
    final IntroSlide2Model model = widget.model;

    final _IntroCandidateSwapOption first = _IntroCandidateSwapOption(
      title: model.suggestedProductTitle,
      imageAsset: model.suggestedProductImageAsset,
      percent: model.compatibilityPercent,
      label: model.compatibilityLabel,
      reasons: model.reasons,
    );

    switch (model.myProductImageAsset) {
      case 'assets/images/products/business_bag_from_brother.webp':
        return <_IntroCandidateSwapOption>[
          first,
          const _IntroCandidateSwapOption(
            title: 'ساعة سمارت',
            imageAsset: 'assets/images/products/smartwatch.png',
            percent: 79,
            label: 'تبديل مناسب',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.watch_rounded,
                label: 'مناسب للشغل',
              ),
              IntroReasonChipModel(
                icon: Icons.location_on_rounded,
                label: 'نفس المنطقة',
              ),
              IntroReasonChipModel(
                icon: Icons.sell_rounded,
                label: 'فرق سعر بسيط',
              ),
              IntroReasonChipModel(
                icon: Icons.verified_rounded,
                label: 'حالة ممتازة',
              ),
            ],
          ),
          const _IntroCandidateSwapOption(
            title: 'سماعة ألعاب',
            imageAsset: 'assets/images/products/boy_page1_gaming_headset.webp',
            percent: 73,
            label: 'فرصة جيدة',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.trending_up_rounded,
                label: 'طلبه عالي',
              ),
              IntroReasonChipModel(
                icon: Icons.swap_horiz_rounded,
                label: 'سهل التبديل',
              ),
              IntroReasonChipModel(
                icon: Icons.price_check_rounded,
                label: 'قيمة قريبة',
              ),
              IntroReasonChipModel(
                icon: Icons.verified_user_rounded,
                label: 'عضو موثوق',
              ),
            ],
          ),
          const _IntroCandidateSwapOption(
            title: 'كاميرا سمارت',
            imageAsset: 'assets/images/products/instant_camera.webp',
            percent: 82,
            label: 'فرصة ممتازة',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.auto_awesome_rounded,
                label: 'ترشيح ذكي',
              ),
              IntroReasonChipModel(
                icon: Icons.interests_rounded,
                label: 'من اهتماماتك',
              ),
              IntroReasonChipModel(
                icon: Icons.sell_rounded,
                label: 'نفس السعر',
              ),
              IntroReasonChipModel(
                icon: Icons.location_on_rounded,
                label: 'قريب منك',
              ),
            ],
          ),
        ];

      case 'assets/images/products/boy_page1_gaming_headset.webp':
        return <_IntroCandidateSwapOption>[
          first,
          const _IntroCandidateSwapOption(
            title: 'كاميرا فورية',
            imageAsset: 'assets/images/products/instant_camera.webp',
            percent: 81,
            label: 'فرصة ممتازة',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.favorite_rounded,
                label: 'ستايل شبابي',
              ),
              IntroReasonChipModel(
                icon: Icons.location_on_rounded,
                label: 'قريب منك',
              ),
              IntroReasonChipModel(
                icon: Icons.verified_rounded,
                label: 'حالة كسر زيرو',
              ),
              IntroReasonChipModel(
                icon: Icons.sell_rounded,
                label: 'قيمة قريبة',
              ),
            ],
          ),
          const _IntroCandidateSwapOption(
            title: 'شنطة ظهر',
            imageAsset: 'assets/images/products/young_female_backpack_swap_alt.webp',
            percent: 76,
            label: 'تبديل مناسب',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.school_rounded,
                label: 'استخدام يومي',
              ),
              IntroReasonChipModel(
                icon: Icons.trending_up_rounded,
                label: 'مطلوبة كتير',
              ),
              IntroReasonChipModel(
                icon: Icons.location_on_rounded,
                label: 'نفس المحافظة',
              ),
              IntroReasonChipModel(
                icon: Icons.verified_user_rounded,
                label: 'عضو موثوق',
              ),
            ],
          ),
          const _IntroCandidateSwapOption(
            title: 'كرسي ألعاب',
            imageAsset: 'assets/images/products/young_female_earbuds_swap.webp',
            percent: 90,
            label: 'فرصة ذهبية',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.sports_esports_rounded,
                label: 'نفس الاهتمام',
              ),
              IntroReasonChipModel(
                icon: Icons.sell_rounded,
                label: 'نفس السعر',
              ),
              IntroReasonChipModel(
                icon: Icons.verified_rounded,
                label: 'حالة ممتازة',
              ),
              IntroReasonChipModel(
                icon: Icons.location_on_rounded,
                label: 'قريب منك',
              ),
            ],
          ),
        ];

      case 'assets/images/products/adult_female_stroller_swap.png':
        return <_IntroCandidateSwapOption>[
          first,
          const _IntroCandidateSwapOption(
            title: 'شنطة ظهر',
            imageAsset: 'assets/images/products/young_female_backpack_swap_alt.webp',
            percent: 80,
            label: 'فرصة ممتازة',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.family_restroom_rounded,
                label: 'يناسب الأسرة',
              ),
              IntroReasonChipModel(
                icon: Icons.location_on_rounded,
                label: 'قريب منك',
              ),
              IntroReasonChipModel(
                icon: Icons.verified_rounded,
                label: 'حالة ممتازة',
              ),
              IntroReasonChipModel(
                icon: Icons.swap_horiz_rounded,
                label: 'سهل التبديل',
              ),
            ],
          ),
          const _IntroCandidateSwapOption(
            title: 'ساعة سمارت',
            imageAsset: 'assets/images/products/smartwatch.png',
            percent: 74,
            label: 'تبديل مناسب',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.watch_rounded,
                label: 'استخدام يومي',
              ),
              IntroReasonChipModel(
                icon: Icons.price_check_rounded,
                label: 'قيمة قريبة',
              ),
              IntroReasonChipModel(
                icon: Icons.location_city_rounded,
                label: 'نفس المدينة',
              ),
              IntroReasonChipModel(
                icon: Icons.verified_user_rounded,
                label: 'حساب موثوق',
              ),
            ],
          ),
          const _IntroCandidateSwapOption(
            title: 'كاميرا سمارت',
            imageAsset: 'assets/images/products/instant_camera.webp',
            percent: 83,
            label: 'فرصة ممتازة',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.auto_awesome_rounded,
                label: 'ترشيح ذكي',
              ),
              IntroReasonChipModel(
                icon: Icons.favorite_rounded,
                label: 'من احتياجاتك',
              ),
              IntroReasonChipModel(
                icon: Icons.sell_rounded,
                label: 'نفس السعر',
              ),
              IntroReasonChipModel(
                icon: Icons.location_on_rounded,
                label: 'قريب منك',
              ),
            ],
          ),
        ];

      case 'assets/images/products/young_female_backpack_swap_alt.webp':
        return <_IntroCandidateSwapOption>[
          first,
          const _IntroCandidateSwapOption(
            title: 'ساعة سمارت',
            imageAsset: 'assets/images/products/smartwatch.png',
            percent: 86,
            label: 'فرصة ممتازة',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.style_rounded,
                label: 'ستايل مناسب',
              ),
              IntroReasonChipModel(
                icon: Icons.location_on_rounded,
                label: 'قريب منك',
              ),
              IntroReasonChipModel(
                icon: Icons.verified_rounded,
                label: 'حالة ممتازة',
              ),
              IntroReasonChipModel(
                icon: Icons.sell_rounded,
                label: 'قيمة قريبة',
              ),
            ],
          ),
          const _IntroCandidateSwapOption(
            title: 'سماعة ألعاب',
            imageAsset: 'assets/images/products/boy_page1_gaming_headset.webp',
            percent: 72,
            label: 'تبديل مناسب',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.headphones_rounded,
                label: 'استخدام يومي',
              ),
              IntroReasonChipModel(
                icon: Icons.trending_up_rounded,
                label: 'رائج حاليًا',
              ),
              IntroReasonChipModel(
                icon: Icons.swap_horiz_rounded,
                label: 'طلبه سريع',
              ),
              IntroReasonChipModel(
                icon: Icons.location_city_rounded,
                label: 'نفس المدينة',
              ),
            ],
          ),
          const _IntroCandidateSwapOption(
            title: 'شنطة براند',
            imageAsset: 'assets/images/products/05_white_bag_closeup.png',
            percent: 89,
            label: 'فرصة ممتازة',
            reasons: <IntroReasonChipModel>[
              IntroReasonChipModel(
                icon: Icons.workspace_premium_rounded,
                label: 'براند مناسب',
              ),
              IntroReasonChipModel(
                icon: Icons.verified_rounded,
                label: 'كسر زيرو',
              ),
              IntroReasonChipModel(
                icon: Icons.sell_rounded,
                label: 'نفس السعر',
              ),
              IntroReasonChipModel(
                icon: Icons.people_alt_rounded,
                label: 'من صديقتك',
              ),
            ],
          ),
        ];
    }

    return <_IntroCandidateSwapOption>[
      first,
      const _IntroCandidateSwapOption(
        title: 'ساعة سمارت',
        imageAsset: 'assets/images/products/smartwatch.png',
        percent: 82,
        label: 'فرصة ممتازة',
        reasons: <IntroReasonChipModel>[
          IntroReasonChipModel(
            icon: Icons.auto_awesome_rounded,
            label: 'ترشيح ذكي',
          ),
          IntroReasonChipModel(
            icon: Icons.location_on_rounded,
            label: 'قريب منك',
          ),
          IntroReasonChipModel(
            icon: Icons.verified_rounded,
            label: 'حالة ممتازة',
          ),
          IntroReasonChipModel(
            icon: Icons.sell_rounded,
            label: 'قيمة قريبة',
          ),
        ],
      ),
    ];
  }

  int _activeCandidateIndex(int length) {
    if (length <= 1) return 0;
    final double raw = _candidateLoopController.value * length;
    return raw.floor().clamp(0, length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final List<_IntroCandidateSwapOption> candidates = _candidateOptions();

    return Container(
      padding: EdgeInsets.all(widget.compact ? 12 : 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE9F2F7),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _kPrimaryNavy.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _candidateLoopController,
        builder: (_, __) {
          final int activeIndex = _activeCandidateIndex(candidates.length);
          final _IntroCandidateSwapOption activeCandidate =
          candidates[activeIndex];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ── Header: title + animated badge ───────────────────────────
              _animatedChild(
                begin: _kSwapHeaderBegin,
                end: _kSwapHeaderEnd,
                dy: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'وبنرشحلك أفضل فرص التبديل',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: _kPrimaryNavy,
                          fontWeight: FontWeight.w900,
                          fontSize: widget.compact ? 13 : 14.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (Widget child, Animation<double> anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.92, end: 1.0)
                                .animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: _SmallCompatibilityBadge(
                        key: ValueKey<String>(
                          '${activeCandidate.title}-${activeCandidate.percent}',
                        ),
                        percent: activeCandidate.percent,
                        label: activeCandidate.label,
                        compact: widget.compact,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: widget.compact ? 10 : 12),

              // ── Body: fixed own product + animated candidates/chips ──────
              _animatedChild(
                begin: _kSwapBodyBegin,
                end: _kSwapBodyEnd,
                dy: 18,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: _ProductSwapCard(
                            title: widget.model.myProductTitle,
                            imageAsset: widget.model.myProductImageAsset,
                            compact: widget.compact,
                            isHighlighted: false,
                          ),
                        ),

                        SizedBox(width: widget.compact ? 8 : 10),

                        Padding(
                          padding: EdgeInsets.only(top: widget.compact ? 48 : 56),
                          child: _AnimatedSwapIcon(
                            compact: widget.compact,
                            controller: _candidateLoopController,
                          ),
                        ),

                        SizedBox(width: widget.compact ? 8 : 10),

                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 520),
                            reverseDuration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder:
                                (Widget child, Animation<double> anim) {
                              final Animation<Offset> slide = Tween<Offset>(
                                begin: const Offset(0.18, 0),
                                end: Offset.zero,
                              ).animate(anim);

                              return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: slide,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.96, end: 1.0)
                                        .animate(anim),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: _ProductSwapCard(
                              key: ValueKey<String>(activeCandidate.title),
                              title: activeCandidate.title,
                              imageAsset: activeCandidate.imageAsset,
                              compact: widget.compact,
                              isHighlighted: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: widget.compact ? 10 : 12),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 460),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (Widget child, Animation<double> anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: Transform.translate(
                            offset: Offset(0, (1 - anim.value) * 8),
                            child: child,
                          ),
                        );
                      },
                      child: _TinyReasonChipsWrap(
                        key: ValueKey<String>(
                          '${activeCandidate.title}-${activeCandidate.percent}-reasons',
                        ),
                        reasons: activeCandidate.reasons,
                        compact: widget.compact,
                      ),
                    ),

                    SizedBox(height: widget.compact ? 7 : 8),

                    /*_CandidateProgressDots(
                      count: candidates.length,
                      activeIndex: activeIndex,
                      compact: widget.compact,
                    ),*/
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IntroCandidateSwapOption {
  const _IntroCandidateSwapOption({
    required this.title,
    required this.imageAsset,
    required this.percent,
    required this.label,
    required this.reasons,
  });

  final String title;
  final String imageAsset;
  final int percent;
  final String label;
  final List<IntroReasonChipModel> reasons;
}

class _AnimatedSwapIcon extends StatelessWidget {
  const _AnimatedSwapIcon({
    required this.compact,
    required this.controller,
  });

  final bool compact;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final double pulse = 0.5 + (controller.value - 0.5).abs();

        return Transform.scale(
          scale: 0.96 + (pulse * 0.05),
          child: Container(
            width: compact ? 34 : 38,
            height: compact ? 34 : 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: _kLavenderBorder,
                width: 1.5,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _kViolet.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/Taapdeel_icon.png',
              width: compact ? 20 : 22,
              height: compact ? 20 : 22,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

class _CandidateProgressDots extends StatelessWidget {
  const _CandidateProgressDots({
    required this.count,
    required this.activeIndex,
    required this.compact,
  });

  final int count;
  final int activeIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool active = index == activeIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: active ? (compact ? 14 : 16) : 5,
          height: 5,
          decoration: BoxDecoration(
            color: active
                ? _kViolet
                : _kLavenderBorder.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

// ── Section title pill ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.compact,
  });

  final String title;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _kLavenderBorder,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _kPrimaryNavy.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Icon(
            icon,
            color: _kViolet,
            size: compact ? 14 : 15,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: _kPrimaryNavy,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 11.5 : 12.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compatibility badge ───────────────────────────────────────────────────────

class _SmallCompatibilityBadge extends StatelessWidget {
  const _SmallCompatibilityBadge({
    Key? key,
    required this.percent,
    required this.label,
    required this.compact,
  }) : super(key: key);

  final int percent;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            _kIndigo,
            _kViolet,
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _kViolet.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Text(
            '$percent%',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 11 : 12,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 9.5 : 10.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product swap card ─────────────────────────────────────────────────────────

class _ProductSwapCard extends StatelessWidget {
  const _ProductSwapCard({
    Key? key,
    required this.title,
    required this.imageAsset,
    required this.compact,
    required this.isHighlighted,
  }) : super(key: key);

  final String title;
  final String imageAsset;
  final bool compact;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 4 : 5,
            ),
          ),
        ),

        SizedBox(height: compact ? 6 : 8),

        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Container(
                color: _kImageFallback,
                child: const Icon(
                  Icons.image_outlined,
                  color: _kIndigo,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: compact ? 6 : 8),

        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: _kPrimaryNavy,
            fontWeight: FontWeight.w900,
            fontSize: compact ? 11.5 : 13,
            height: 1.18,
          ),
        ),
      ],
    );
  }
}

// ── Tiny reason chips ─────────────────────────────────────────────────────────

class _TinyReasonChipsWrap extends StatelessWidget {
  const _TinyReasonChipsWrap({
    Key? key,
    required this.reasons,
    required this.compact,
  }) : super(key: key);

  final List<IntroReasonChipModel> reasons;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final List<IntroReasonChipModel> shown = reasons.take(4).toList();

    if (shown.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: compact ? 6 : 7,
      runSpacing: compact ? 6 : 7,
      children: shown
          .map(
            (IntroReasonChipModel reason) => _TinyReasonChip(
          chip: reason,
          compact: compact,
        ),
      )
          .toList(),
    );
  }
}

class _TinyReasonChip extends StatelessWidget {
  const _TinyReasonChip({
    required this.chip,
    required this.compact,
  });

  final IntroReasonChipModel chip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: compact ? 116 : 132,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 8,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: _kSoftLavender,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _kLavenderBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Icon(
            chip.icon,
            color: _kViolet,
            size: compact ? 12 : 13,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              chip.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: _kPrimaryNavy,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 9.3 : 10.2,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
