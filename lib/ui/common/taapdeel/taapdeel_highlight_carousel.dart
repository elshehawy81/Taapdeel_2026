import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

import 'taapdeel_highlight_card.dart';

/// Data model لكل Slide
class TaapdeelHighlightItem {
  TaapdeelHighlightItem({
    required this.backgroundImage,
    required this.headerTitle,
    this.headerIcon,
    required this.label,
    required this.title,
    this.onTap,
    this.onHeaderTap,
    this.accentColor,
  });

  final ImageProvider backgroundImage;
  final String headerTitle;
  final IconData? headerIcon;
  final String label;
  final String title;

  final VoidCallback? onTap;
  final VoidCallback? onHeaderTap;

  final Color? accentColor;
}

/// TaapdeelHighlightCarousel – Premium Hero Carousel
///
/// - PageView مع viewportFraction 0.88 لعمل "peek" للكارت التالي.
/// - Scale خفيف للكروت الجانبية.
/// - AutoPlay اختياري.
/// - Dots جوه كل كارت (dotsCount / currentDot).
class TaapdeelHighlightCarousel extends StatefulWidget {
  const TaapdeelHighlightCarousel({
    Key? key,
    required this.items,
    this.height,
    this.initialPage = 0,
    this.enableAutoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 6),
  }) : super(key: key);

  final List<TaapdeelHighlightItem> items;
  final double? height;
  final int initialPage;
  final bool enableAutoPlay;
  final Duration autoPlayInterval;

  @override
  State<TaapdeelHighlightCarousel> createState() =>
      _TaapdeelHighlightCarouselState();
}

class _TaapdeelHighlightCarouselState
    extends State<TaapdeelHighlightCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  static const BoxDecoration _layer1Decoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(28)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xFFE0F1FF),
        Color(0xFFC3EFE7),
      ],
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Color(0x203167B0),
        blurRadius: 26,
        offset: Offset(0, 14),
      ),
    ],
  );

  static const BoxDecoration _layer2Decoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(24)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xF7FFFFFF),
        Color(0xE6E0F1FF),
      ],
    ),
    border: Border.all(color: Color(0xE6FFFFFF), width: 0.8),
  );

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(0, widget.items.length - 1);
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.88,
    );

    if (widget.enableAutoPlay && widget.items.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || widget.items.length <= 1) return;
      int next = _currentPage + 1;
      if (next >= widget.items.length) next = 0;

      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final double height =
        widget.height ?? MediaQuery.of(context).size.height * 0.45;

    return SizedBox(
      height: height + PsDimens.space16,
      child: Stack(
        children: <Widget>[
          // ===========================
          // الخلفية Layer 1 (Mint / Ice)
          // ===========================
          Positioned.fill(
            top: PsDimens.space12,
            child: IgnorePointer(
              ignoring: true,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: PsDimens.space20,
                  ),
                  height: height,
                  decoration: _layer1Decoration,
                ),
              ),
            ),
          ),

          // ===========================
          // الخلفية Layer 2 (أفتح وأصغر)
          // ===========================
          Positioned.fill(
            top: PsDimens.space24,
            child: IgnorePointer(
              ignoring: true,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: PsDimens.space28,
                  ),
                  height: height - 10,
                  decoration: _layer2Decoration,
                ),
              ),
            ),
          ),

          // ===========================
          // الكاروسيل نفسه
          // ===========================
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (int index) {
              setState(() => _currentPage = index);
              if (widget.enableAutoPlay && widget.items.length > 1) {
                _startAutoPlay(); // نرجّع التوقيت بعد سوايب يدوي
              }
            },
            itemBuilder: (BuildContext context, int index) {
              final TaapdeelHighlightItem item = widget.items[index];

              // تأثير Scale للكروت الجانبية
              return AnimatedBuilder(
                animation: _pageController,
                builder: (BuildContext context, Widget? child) {
                  double scale = 1.0;

                  if (_pageController.position.hasContentDimensions) {
                    final double page = _pageController.page ?? _currentPage.toDouble();
                    final double diff = (page - index).abs();
                    scale = (1 - diff * 0.08).clamp(0.9, 1.0);
                  }

                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: TaapdeelHighlightCard(
                  backgroundImage: item.backgroundImage,
                  headerTitle: item.headerTitle,
                  headerIcon: item.headerIcon,
                  label: item.label,
                  title: item.title,
                  accentColor: item.accentColor,
                  onTap: item.onTap,
                  onHeaderTap: item.onHeaderTap,
                  dotsCount: widget.items.length,
                  currentDot: _currentPage,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
