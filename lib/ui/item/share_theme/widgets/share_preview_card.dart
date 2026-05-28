import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';

class SharePreviewCard extends StatelessWidget {
  const SharePreviewCard({
    Key? key,
    required this.repaintKey,
    required this.theme,
    required this.data,
  }) : super(key: key);

  final GlobalKey repaintKey;
  final ShareThemeDefinition theme;
  final ShareProductData data;

  static const double _designWidth = 360;
  static const double _designHeight = 612;
  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;

        if (maxWidth <= 0 || maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        final double widthScale = maxWidth / _designWidth;
        final double heightScale = maxHeight / _designHeight;
        final double scale = widthScale < heightScale ? widthScale : heightScale;

        return Center(
          child: SizedBox(
            width: _designWidth * scale,
            height: _designHeight * scale,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: RepaintBoundary(
                key: repaintKey,
                child: SizedBox(
                  width: _designWidth,
                  height: _designHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_radius),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFF102A43).withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_radius),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const _TaapdeelBrandStrip(),
                          Expanded(
                            child: theme.builder(context, data),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TaapdeelBrandStrip extends StatelessWidget {
  const _TaapdeelBrandStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE4EEF4)),
        ),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/Taapdeel_icon.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _TaapdeelFallbackIcon(),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: const <InlineSpan>[
                    TextSpan(
                      text: 'Taapdee',
                      style: TextStyle(
                        color: Color(0xFF18386B),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: 'L',
                      style: TextStyle(
                        color: Color(0xFF35BFB8),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: '  —  بدّلها بقصة أحلى ✨',
                      style: TextStyle(
                        color: Color(0xFF365C73),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.0,
                  letterSpacing: -0.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaapdeelFallbackIcon extends StatelessWidget {
  const _TaapdeelFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0A3E73),
            Color(0xFF1184C8),
            Color(0xFF35D1D0),
          ],
        ),
      ),
      child: const Icon(
        Icons.swap_horiz_rounded,
        color: Colors.white,
        size: 21,
      ),
    );
  }
}