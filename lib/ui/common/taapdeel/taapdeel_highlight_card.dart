import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

/// TaapdeelHighlightCard – Hero Taapdeel Style
///
/// - Background image + blue/mint overlay.
/// - Header capsule مع أيقونة + عنوان.
/// - Glass hero card بأسفل مع cut-corner + dots.
/// - يطابق هوية Taapdeel (Blue + Mint + Glass).
class TaapdeelHighlightCard extends StatelessWidget {
  const TaapdeelHighlightCard({
    Key? key,
    required this.backgroundImage,
    required this.headerTitle,
    this.headerIcon,
    this.onHeaderTap,
    required this.label,
    required this.title,
    this.trailingIcon,
    this.onTap,
    this.dotsCount = 0,
    this.currentDot = 0,
    this.height,
    this.accentColor,
  }) : super(key: key);

  final ImageProvider backgroundImage;

  final String headerTitle;
  final IconData? headerIcon;
  final VoidCallback? onHeaderTap;

  final String label;
  final String title;

  final IconData? trailingIcon;
  final VoidCallback? onTap;

  final int dotsCount;
  final int currentDot;

  final double? height;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    // Taapdeel Brand Blue + Mint
    const Color brandBlue = Color(0xFF3167B0);
    final Color accent = accentColor ?? brandBlue;

    final double cardHeight =
        height ?? MediaQuery.of(context).size.height * 0.42;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: PsDimens.space12,
        vertical: PsDimens.space8,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      height: cardHeight,
      child: Stack(
        children: <Widget>[
          // ==== الخلفية (صورة + Overlay) ====
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: backgroundImage,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0x26000000), // أسود @ ~15%
                      Color(0x803167B0), // Blue overlay @ 50%
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==== Header (Highlights) ====
          Positioned(
            top: PsDimens.space12,
            left: PsDimens.space12,
            right: PsDimens.space12,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _HeaderCutCorner(
                title: headerTitle,
                icon: headerIcon ?? Icons.auto_awesome_rounded,
                accent: accent,
                onTap: onHeaderTap,
              ),
            ),
          ),

          // ==== زر جانبي أعلى اليمين ====
          Positioned(
            top: PsDimens.space8,
            right: PsDimens.space8,
            child: _RoundIconButton(
              icon: trailingIcon ?? Icons.north_east_rounded,
              onTap: onTap,
            ),
          ),

          // ==== Glass Hero Card في الأسفل ====
          Positioned(
            left: PsDimens.space12,
            right: PsDimens.space12,
            bottom: PsDimens.space16,
            child: _GlassHeroCard(
              label: label,
              title: title,
              accent: accent,
              dotsCount: dotsCount,
              currentDot: currentDot,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header bar مع cut-corner خفيفة
class _HeaderCutCorner extends StatelessWidget {
  const _HeaderCutCorner({
    required this.title,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final BorderRadius radius = const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(8),
    );

    final Widget content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsDimens.space12,
        vertical: PsDimens.space8,
      ),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xF5FFFFFF), // white @ ~96%
            Color(0xE0E0F1FF), // Ice blue hint
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.90),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  accent.withValues(alpha: 0.20),
                  accent.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: accent,
            ),
          ),
          const SizedBox(width: PsDimens.space8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2443),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.15),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: content,
      ),
    );
  }
}

/// زر دائري أعلى اليمين
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(
              icon, // ← هنا استخدمنا المتغيّر بدل الأيقونة الثابتة
              size: 18,
              color: const Color(0xFF283355),
            ),
          ),
        ),
      ),
    );
  }
}

/// الكارت الزجاجي الكبير مع Cut-Corner و Dots
class _GlassHeroCard extends StatelessWidget {
  const _GlassHeroCard({
    required this.label,
    required this.title,
    required this.accent,
    required this.dotsCount,
    required this.currentDot,
    this.onTap,
  });

  final String label;
  final String title;
  final Color accent;
  final int dotsCount;
  final int currentDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final BorderRadius borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(28),
      topRight: Radius.circular(28),
      bottomLeft: Radius.circular(28),
      bottomRight: Radius.circular(12),
    );

    Widget card = ClipPath(
      clipper: _CutCornerClipper(cornerSize: 34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PsDimens.space20,
            vertical: PsDimens.space16,
          ),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xE6E0F1FF), // Ice Blue
                Color(0xFF3D77C2), // Taapdeel Blue
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
              width: 1.1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accent.withValues(alpha: 0.38),
                blurRadius: 22,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: PsDimens.space8),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: PsDimens.space16),
                    if (dotsCount > 0)
                      Row(
                        children: List.generate(dotsCount, (int index) {
                          final bool active = index == currentDot;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsetsDirectional.only(
                              end: PsDimens.space4,
                            ),
                            width: active ? 16 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.40),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: PsDimens.space16),

              // أيقونة جانبية (Orbit / Target)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.2,
                  ),
                  gradient: RadialGradient(
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.95),
                      accent.withValues(alpha: 0.16),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.track_changes_rounded,
                  size: 28,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      card = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.18),
          borderRadius: borderRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// ClipPath لعمل Cut-Corner في أعلى يمين الكارت
class _CutCornerClipper extends CustomClipper<Path> {
  _CutCornerClipper({this.cornerSize = 40});

  final double cornerSize;

  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - cornerSize, 0)
      ..lineTo(size.width, cornerSize)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_CutCornerClipper oldClipper) =>
      oldClipper.cornerSize != cornerSize;
}
