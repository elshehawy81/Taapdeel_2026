import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:taapdeel/viewobject/product.dart';


enum ProductBadgeTier { none, featured, deal, superDeal }

enum TaapdeelBadgeVisualStyle { auto, gold, glass }

class ProductBadgeVM {
  final ProductBadgeTier tier;

  /// ✅ slides = features only (الشريط ثابت على قد الصورة)
  final List<BadgeSlide> slides;

  const ProductBadgeVM({required this.tier, required this.slides});

  ProductBadgeVM copyWithTier(ProductBadgeTier t) => ProductBadgeVM(tier: t, slides: slides);
}

class BadgeSlide {
  final IconData icon;
  final String text;
  const BadgeSlide(this.icon, this.text);
}

class BadgeStyle {
  final Color bg;
  final Color border;
  final Color fg;

  final String tierLabel;
  final IconData tierIcon;

  const BadgeStyle({
    required this.bg,
    required this.border,
    required this.fg,
    required this.tierLabel,
    required this.tierIcon,
  });

  // ✅ Gold/Ambers
  static const Color _goldBgStart = Color(0xFFFFF3C4);
  static const Color _goldBgEnd = Color(0xFFFFE19A);
  static const Color _goldBorder = Color(0xFFE6B65C);
  static const Color _goldText = Color(0xFF8C6A03);

  static BadgeStyle fromTier(ProductBadgeTier t) {
    switch (t) {
      case ProductBadgeTier.featured: // Glass
        return BadgeStyle(
          tierLabel: 'مميز',
          tierIcon: Icons.auto_awesome_rounded,
          bg: const Color(0xffffffff).withAlpha(22),
          border: const Color(0xffffffff).withAlpha(70),
          fg: Colors.white,
        );

      case ProductBadgeTier.deal: // Gold
        return const BadgeStyle(
          tierLabel: 'لُقْطَة',
          tierIcon: Icons.local_fire_department_rounded,
          bg: Colors.transparent,
          border: _goldBorder,
          fg: _goldText,
        );

      case ProductBadgeTier.superDeal: // Gold
        return const BadgeStyle(
          tierLabel: 'سوبر',
          tierIcon: Icons.bolt_rounded,
          bg: Colors.transparent,
          border: _goldBorder,
          fg: _goldText,
        );

      case ProductBadgeTier.none:
        return BadgeStyle(
          tierLabel: '',
          tierIcon: Icons.circle,
          bg: const Color(0xffffffff).withAlpha(22), // ✅ خليها glass-friendly
          border: const Color(0xffffffff).withAlpha(70),
          fg: Colors.white,
        );
    }
  }
}

ProductBadgeVM buildProductBadgeVM(Product p) {
  final int dealOptionId = _toInt(p.dealOptionId);

  ProductBadgeTier tier;
  switch (dealOptionId) {
    case 1:
      tier = ProductBadgeTier.featured;
      break;
    case 2:
      tier = ProductBadgeTier.deal;
      break;
    case 3:
      tier = ProductBadgeTier.superDeal;
      break;
    default:
      tier = ProductBadgeTier.none;
  }

  final List<BadgeSlide> slides = [];

  final String? brandName = (p.brand )?.trim();

  if (brandName!.isNotEmpty ) {
    slides.add(
      BadgeSlide(
        Icons.local_offer_rounded, // أو Icons.star_rounded
        brandName,
      ),
    );
  }

  // --------------------------------------------------
  // 2️⃣ Usage duration
  // --------------------------------------------------
  final int itemTypeId = _toInt(p.itemTypeId);
  if (itemTypeId == 2) {
    slides.add(const BadgeSlide(Icons.schedule_rounded, 'أقل من 3 شهور'));
  } else if (itemTypeId == 3) {
    slides.add(const BadgeSlide(Icons.schedule_rounded, 'أقل من 6 شهور'));
  }

  // --------------------------------------------------
  // 3️⃣ Condition
  // --------------------------------------------------
  final int condId = _toInt(p.conditionOfItemId);
  final String condName = (p.conditionOfItem?.name ?? '').trim();

  final bool isOtherDealOption =
  (dealOptionId != 1 && dealOptionId != 2 && dealOptionId != 3);

  if (condName.isNotEmpty) {
    if (isOtherDealOption) {
      slides.add(BadgeSlide(Icons.verified_rounded, condName));
    } else if (condId == 4 || condId == 5 || condId == 6) {
      slides.add(BadgeSlide(Icons.verified_rounded, condName));
    }
  }

  // --------------------------------------------------
  // 4️⃣ Imported
  // --------------------------------------------------
  final int businessMode = _toInt(p.businessMode);
  if (businessMode == 2) {
    slides.add(const BadgeSlide(Icons.public_rounded, 'مستورد'));
  }

  return ProductBadgeVM(
    tier: tier,
    slides: slides,
  );
}

class TaapdeelRotatingValueBadge extends StatefulWidget {
  const TaapdeelRotatingValueBadge({
    Key? key,
    required this.vm,
    this.interval = const Duration(milliseconds: 2400),
    this.height = 28,
    this.radius = 999,
    this.blur = 10,
    this.forceGold = false,
    this.visualStyle = TaapdeelBadgeVisualStyle.auto,
  }) : super(key: key);

  final ProductBadgeVM vm;
  final Duration interval;
  final double height;
  final double radius;
  final double blur;

  final bool forceGold;
  final TaapdeelBadgeVisualStyle visualStyle;

  @override
  State<TaapdeelRotatingValueBadge> createState() => _TaapdeelRotatingValueBadgeState();
}

class _TaapdeelRotatingValueBadgeState extends State<TaapdeelRotatingValueBadge> {
  int index = 0;
  late final Ticker _ticker;
  Duration _acc = Duration.zero;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration now) {
    if (!mounted) return;
    if (_last == Duration.zero) {
      _last = now;
      return;
    }

    final delta = now - _last;
    _last = now;

    _acc += delta;
    if (_acc >= widget.interval) {
      _acc = Duration.zero;

      final slides = widget.vm.slides;
      if (slides.length <= 1) return;

      setState(() => index = (index + 1) % slides.length);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  static const Color _goldBgStart = Color(0xFFFFF3C4);
  static const Color _goldBgEnd = Color(0xFFFFE19A);
  static const Color _goldBorder = Color(0xFFE6B65C);
  static const Color _goldText = Color(0xFF8C6A03);

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    if (vm.slides.isEmpty) return const SizedBox.shrink();

    final int safeIndex = index.clamp(0, vm.slides.length - 1);
    final slide = vm.slides[safeIndex];

    // ✅ label/colors tier (forceGold keeps label gold if you want)
    final ProductBadgeTier effectiveTier = widget.forceGold ? ProductBadgeTier.deal : vm.tier;

    // ✅ visuals:
    // - auto => deal/superDeal = gold, everything else = glass (NEW)
    final bool isGold = _isGoldVisual(vm.tier);
    final bool isGlass = !isGold;

    final style = BadgeStyle.fromTier(effectiveTier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: Container(
            width: double.infinity,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: isGold
                  ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_goldBgStart, _goldBgEnd],
              )
                  : null,
              color: isGold ? null : (isGlass ? Colors.white.withAlpha(22) : style.bg),
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(
                color: isGold ? _goldBorder : (isGlass ? Colors.white.withAlpha(70) : style.border),
                width: isGold ? 1.2 : 1.0,
              ),
              boxShadow: [
                if (isGold)
                  BoxShadow(
                    color: _goldBorder.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 0.5,
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(isGold ? 0.18 : 0.12),
                  blurRadius: isGold ? 10 : 16,
                  offset: Offset(0, isGold ? 6 : 8),
                ),
              ],
            ),
            foregroundDecoration: isGold
                ? BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            )
                : null,
            child: Row(
              children: [
                Icon(
                  slide.icon,
                  size: 14,
                  color: isGold ? _goldText : style.fg,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.20),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      slide.text,
                      key: ValueKey('${effectiveTier.name}-$safeIndex-${slide.text}-${isGold ? "gold" : "glass"}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isGold ? _goldText : style.fg,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isGoldVisual(ProductBadgeTier tier) {
    if (widget.forceGold) return true;

    switch (widget.visualStyle) {
      case TaapdeelBadgeVisualStyle.gold:
        return true;
      case TaapdeelBadgeVisualStyle.glass:
        return false;
      case TaapdeelBadgeVisualStyle.auto:
      // ✅ 2/3 => gold فقط
        return tier == ProductBadgeTier.deal || tier == ProductBadgeTier.superDeal;
    }
  }
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  final s = v.toString().trim();
  return int.tryParse(s) ?? 0;
}
