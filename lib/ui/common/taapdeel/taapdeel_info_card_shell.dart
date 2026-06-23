import 'dart:ui';
import 'package:flutter/material.dart';

class TaapdeelInfoCardShell extends StatelessWidget {
  const TaapdeelInfoCardShell({
    Key? key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.radius = 26,
    this.blurSigma = 14,
    this.withBlur = true,
    this.borderWidth = 1.2,
  }) : super(key: key);

  final Widget child;
  final double? height;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final double radius;
  final double blurSigma;
  final bool withBlur;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);

    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xF2FFFFFF),
            Color(0xD9F3FFFE),
          ],
        ),
        border: Border.all(
          color: const Color(0xE6FFFFFF),
          width: borderWidth,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ✅ قصّ البلور فقط
          if (withBlur)
            ClipRRect(
              borderRadius: r,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

          // ✅ المحتوى بدون قص (عشان الشادو/التمدد مايتقصوش)
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
