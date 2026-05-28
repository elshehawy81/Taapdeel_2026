import 'dart:ui';
import 'package:flutter/material.dart';

class TaapdeelCircularProductFrame extends StatelessWidget {
  const TaapdeelCircularProductFrame({
    Key? key,
    required this.imageProvider,
    required this.title,
    this.subtitle,
    this.circleColor = const Color(0xFFF3F4F6),
    this.size = 120,
    this.onTap,
    this.compact = false,

    // ✅ Look
    this.circleBorderColor,
    this.circleBorderWidth = 1.0,
    this.elevation = 10,

    // ✅ inner padding for image
    this.imagePaddingPercent = 0.02,

    // ✅ NEW: control below text
    this.showTitleBelow = true,
    this.showSubtitleBelow = true,
  }) : super(key: key);

  final ImageProvider imageProvider;
  final String title;
  final String? subtitle;

  final Color circleColor;
  final Color? circleBorderColor;
  final double circleBorderWidth;

  final double size;
  final VoidCallback? onTap;
  final bool compact;

  final double elevation;
  final double imagePaddingPercent;

  // ✅ NEW
  final bool showTitleBelow;
  final bool showSubtitleBelow;

  @override
  Widget build(BuildContext context) {
    final int titleLines = compact ? 1 : 2;
    final double titleFont = compact ? 10 : 12;

    final Color border = circleBorderColor ??
        (circleColor.computeLuminance() > 0.92
            ? Colors.black.withOpacity(0.08)
            : Colors.white.withOpacity(0.18));

    final double padding = size * imagePaddingPercent;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size,
              width: size,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                  border: Border.all(color: border, width: circleBorderWidth),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: elevation,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                      color: Colors.black.withOpacity(0.10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: ClipOval(
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),

            // ✅ show title only if allowed
            if (showTitleBelow) ...[
              SizedBox(height: compact ? 3 : 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: titleLines,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: titleFont,
                    height: 1.05,
                  ),
                ),
              ),
            ],

            // ✅ subtitle
            if (showSubtitleBelow &&
                !compact &&
                subtitle != null &&
                subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}