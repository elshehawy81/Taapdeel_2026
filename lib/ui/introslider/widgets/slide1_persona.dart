import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import '../content/intro_persona_content.dart';
import '../logic/persona_resolver.dart';
import '../models/intro_models.dart';

class Slide1Persona extends StatefulWidget {
  const Slide1Persona({
    Key? key,
    required this.psValueHolder,
    required this.playKey,
  });

  final PsValueHolder? psValueHolder;
  final int playKey;

  @override
  State<Slide1Persona> createState() => _Slide1PersonaState();
}

class _Slide1PersonaState extends State<Slide1Persona>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant Slide1Persona oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playKey != widget.playKey) {
      _c.stop();
      _c.reset();
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _stagger({
    required Widget child,
    required double begin,
    required double end,
    double dy = 10,
  }) {
    final anim = CurvedAnimation(
      parent: _c,
      curve: Interval(begin, end, curve: Curves.easeOutSine),
    );

    return FadeTransition(
      opacity: anim,
      child: AnimatedBuilder(
        animation: anim,
        builder: (_, __) {
          final t = anim.value;
          return Transform.translate(
            offset: Offset(0, (1 - t) * dy),
            child: child,
          );
        },
      ),
    );
  }
  Widget _fade({
    required Widget child,
    required double begin,
    required double end,
    double dy = 12,
  }) {
    final anim = CurvedAnimation(
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

  @override
  Widget build(BuildContext context) {
    final IntroPersonaKey key =
    PersonaResolver.resolve(widget.psValueHolder, debugLogs: true);
    final IntroPersonaModel model = introPersonaContent[key]!;

    final Size s = MediaQuery.of(context).size;
    final double w = s.width;
    final double h = s.height;
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    final double side = w * 0.43;
    final double gap = 30;

    // مساحة محجوزة للدوتس + الأزرار السفلية في IntroSliderView
    final double reservedBottomSpace = 170 + bottomInset;

    return SafeArea(
      top: true,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              bottom: reservedBottomSpace,
            ),

            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  _fade(
                    begin: 0.00,
                    end: 0.10,
                    child: _Logo(),
                  ),
                  SizedBox(height: 10),

                  _stagger(
                    begin: 0.00,
                    end: 0.22,
                    dy: 6,
                    child: Text(
                      model.headerTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF2C5C88),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _stagger(
                    begin: 0.10,
                    end: 0.45,
                    child: SizedBox(
                      height: side,
                      child: _OverlappedCircleWithGlassText(
                        asset: model.topBlock.imageAsset,
                        size: side,
                        title: model.topBlock.title,
                        icon: null,
                        alignRight: false,
                      ),
                    ),
                  ),
                  SizedBox(height: gap),
                  _stagger(
                    begin: 0.50,
                    end: 0.80,
                    child: SizedBox(
                      height: side,
                      child: _OverlappedCircleWithGlassText(
                        asset: model.middleBlock.imageAsset,
                        size: side,
                        title: model.middleBlock.title,
                        icon: null,
                        alignRight: true,
                      ),
                    ),
                  ),
                  SizedBox(height: gap),
                  _stagger(
                    begin: 0.85,
                    end: 1.00,
                    child: SizedBox(
                      height: side,
                      child: _OverlappedCircleWithGlassText(
                        asset: model.bottomBlock.imageAsset,
                        size: side,
                        title: model.bottomBlock.title,
                        icon: null,
                        alignRight: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OverlappedCircleWithGlassText extends StatelessWidget {
  const _OverlappedCircleWithGlassText({
    required this.asset,
    required this.size,
    required this.title,
    this.icon,
    this.alignRight = false,
  });

  final String asset;
  final double size;
  final String title;
  final IconData? icon;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final double glassHeight = size * 0.66;

    return SizedBox(
      height: size + (glassHeight * 0.35),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            start: alignRight ? 0 : (size * 0.85),
            end: alignRight ? (size * 0.85) : 0,
            top: size * 0.12,
            child: _SingleGlassPanel(
              height: glassHeight,
              title: title,
              icon: icon,
              alignRight: alignRight,
            ),
          ),
          PositionedDirectional(
            start: alignRight ? null : 0,
            end: alignRight ? 0 : null,
            top: 0,
            child: _CircleHeroPhoto(
              asset: asset,
              size: size,
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleGlassPanel extends StatelessWidget {
  const _SingleGlassPanel({
    required this.height,
    required this.title,
    required this.alignRight,
    this.icon,
  });

  final double height;
  final String title;
  final bool alignRight;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: height,
          width: 220,
          padding: const EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.50),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.75),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B6FB6).withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 18, color: const Color(0xFF2C5C88)),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2C5C88),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.8,
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
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Taapdeel_logo.png',
      height: 52,
      errorBuilder: (_, __, ___) => const Text(
        'TaapdeeL',
        style: TextStyle(
          color: Color(0xFF1A3F6F),
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }
}
class _CircleHeroPhoto extends StatelessWidget {
  const _CircleHeroPhoto({
    required this.asset,
    required this.size,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.75),
        border: Border.all(color: Colors.white.withOpacity(0.95), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}