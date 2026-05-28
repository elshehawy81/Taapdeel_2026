import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

class TaapdeelSideGlassCard extends StatelessWidget {
  const TaapdeelSideGlassCard({
    Key? key,
    required this.backgroundImage,
    required this.title,
    this.height = 220,
    this.borderRadius = 24,
    this.glassWidthFactor = 0.68,
    this.onTap,
  }) : super(key: key);

  final ImageProvider backgroundImage;
  final String title;
  final double height;
  final double borderRadius;
  final double glassWidthFactor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextDirection dir = Directionality.of(context);
    final bool isRtl = dir == TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x193167B0), // Blue shadow خفيف
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // الخلفية (صورة)
            Ink.image(
              image: backgroundImage,
              height: height,
              fit: BoxFit.cover,
              child: InkWell(onTap: onTap),
            ),

            // تظليل ناعم من الجهة البعيدة عن النص
            Align(
              alignment:
              isRtl ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                    isRtl ? Alignment.centerLeft : Alignment.centerRight,
                    end:
                    isRtl ? Alignment.centerRight : Alignment.centerLeft,
                    colors: const <Color>[
                      Color(0x263167B0),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),

            // الكارت الزجاجي
            Align(
              alignment:
              isRtl ? Alignment.centerRight : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: glassWidthFactor,
                heightFactor: 0.78,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: isRtl ? 0 : PsDimens.space16,
                    end: isRtl ? PsDimens.space16 : 0,
                    top: PsDimens.space18,
                    bottom: PsDimens.space18,
                  ),
                  child: _GlassCutCorner(
                    isRtl: isRtl,
                    child: Padding(
                      padding:
                      const EdgeInsets.all(PsDimens.space16),
                      child: Align(
                        alignment: isRtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
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

class _GlassCutCorner extends StatelessWidget {
  const _GlassCutCorner({
    required this.child,
    required this.isRtl,
  });

  final Widget child;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _InnerCutCornerClipper(isRtl: isRtl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xE6FFFFFF), // white @ ~90%
                Color(0xFF3D77C2), // ice blue / mint glass
              ],
            ),
            border: Border.all(
              color: const Color(0xF2FFFFFF),
              width: 1.0,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x143167B0),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InnerCutCornerClipper extends CustomClipper<Path> {
  _InnerCutCornerClipper({required this.isRtl});

  final bool isRtl;

  @override
  Path getClip(Size size) {
    const double cutSize = 32;
    final Path path = Path();

    if (isRtl) {
      path.moveTo(cutSize, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, cutSize);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width - cutSize, 0);
      path.lineTo(size.width, cutSize);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _InnerCutCornerClipper oldClipper) {
    return oldClipper.isRtl != isRtl;
  }
}
