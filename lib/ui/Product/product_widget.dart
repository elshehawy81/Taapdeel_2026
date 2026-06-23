import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/ps_hero.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/product.dart';

import '../common/ps_ui_widget.dart';
import 'taapdeel_product_badge.dart';
import 'taapdeel_product_relation.dart';

/// ======================================================
/// ✅ Product Card Variants
/// ======================================================
enum TaapdeelProductCardVariant {
  deal,
  family,
  friend,
  brand,
  imported,
  normal,
  free,
  swap,
}

/// ======================================================
/// ✅ Main Wrapper
/// ======================================================
class TaapdeelProductCardItem extends StatelessWidget {
  const TaapdeelProductCardItem({
    Key? key,
    required this.product,
    required this.coreTagKey,
    required this.onTap,
    this.onTapFav,
    this.selectedFav = false,

    // sizing
    this.cardWidth = PsDimens.space140,
    this.cardHeight,
    this.outerMargin = const EdgeInsets.only(
      left: PsDimens.space2,
      right: PsDimens.space4,
      bottom: PsDimens.space4,
    ),

    this.variant = TaapdeelProductCardVariant.normal,

    this.showRotatingBanner = true,
    this.badgeVMOverride,

    this.conditionTextOverride,
    this.showConditionChip = true,

    this.brandText,

    this.showRelationPanel = true,

    this.relationType,
    this.relationBackendCode,
  }) : super(key: key);

  final Product product;
  final String coreTagKey;
  final VoidCallback onTap;

  final VoidCallback? onTapFav;
  final bool selectedFav;

  final double cardWidth;
  final double? cardHeight;
  final EdgeInsets outerMargin;

  final TaapdeelProductCardVariant variant;

  final bool showRotatingBanner;
  final ProductBadgeVM? badgeVMOverride;

  final String? conditionTextOverride;
  final bool showConditionChip;

  final String? brandText;

  final bool showRelationPanel;

  final int? relationType;
  final String? relationBackendCode;

  @override
  Widget build(BuildContext context) {
    final card = TaapdeelProductCard(
      product: product,
      coreTagKey: coreTagKey,
      onTap: onTap,
      onTapFav: onTapFav,
      selectedFav: selectedFav,
      variant: variant,
      showRotatingBanner: showRotatingBanner,
      badgeVMOverride: badgeVMOverride,
      conditionTextOverride: conditionTextOverride,
      showConditionChip: showConditionChip,
      brandText: brandText,
      showRelationPanel: showRelationPanel,
      relationType: relationType,
      relationBackendCode: relationBackendCode,
    );

    return Container(
      margin: outerMargin,
      width: cardWidth,
      child: cardHeight == null
          ? card
          : SizedBox(width: cardWidth, height: cardHeight, child: card),
    );
  }
}

/// ======================================================
/// ✅ TaapdeelProductCard
/// ======================================================
class TaapdeelProductCard extends StatelessWidget {
  const TaapdeelProductCard({
    Key? key,
    required this.product,
    required this.coreTagKey,
    required this.onTap,
    this.onTapFav,
    this.selectedFav = false,
    this.variant = TaapdeelProductCardVariant.normal,
    this.showRotatingBanner = true,
    this.badgeVMOverride,
    this.conditionTextOverride,
    this.showConditionChip = true,
    this.brandText,
    this.showRelationPanel = true,
    this.relationType,
    this.relationBackendCode,
  }) : super(key: key);

  final Product product;
  final String coreTagKey;
  final VoidCallback onTap;

  final VoidCallback? onTapFav;
  final bool selectedFav;

  final TaapdeelProductCardVariant variant;

  final bool showRotatingBanner;
  final ProductBadgeVM? badgeVMOverride;

  final String? conditionTextOverride;
  final bool showConditionChip;

  final String? brandText;

  final bool showRelationPanel;

  final int? relationType;
  final String? relationBackendCode;

  @override
  Widget build(BuildContext context) {
    final String priceText =
    formatPriceDisplay(_safe(product.price), currency: 'ج', useEGP: false);

    final ProductBadgeVM badgeVM =
        badgeVMOverride ?? buildProductBadgeVM(product);

    final bool isSwap = variant == TaapdeelProductCardVariant.swap;
    final bool showBannerForThisVariant = showRotatingBanner;

    // ✅ IMPORTANT: في حالة SWAP اخفي price chip
    final bool showBottomPriceChip = !isSwap;



    // ==========================================================
    // ✅ Relation Resolution
    // ==========================================================
    int resolvedRelationType = 0;

    if (isSwap) {
      if (relationType != null && relationType != 0) {
        resolvedRelationType = relationType!;
      } else {
        final String code = (relationBackendCode ?? '').trim();
        if (code.isNotEmpty) {
          resolvedRelationType = relationTypeFromBackendCode(code);
        }
      }
    } else {
      final _ResolvedRelation rel = _resolveRelation(
        product: product,
        passedType: relationType,
        passedBackendCode: relationBackendCode,
      );
      resolvedRelationType = rel.type;
    }

    final bool showRelationBar = showRelationPanel &&
        (((variant == TaapdeelProductCardVariant.family ||
            variant == TaapdeelProductCardVariant.friend) &&
            resolvedRelationType != 0) ||
            (isSwap && resolvedRelationType != 0));

    TaapdeelRelationUI? relationUI;
    if (showRelationBar) {
      final String ownerName = product.user?.userName ?? '';
      relationUI = TaapdeelRelationUI.fromType(
        resolvedRelationType,
        ownerName: ownerName,
      );
    }

    final BorderRadius radius = BorderRadius.circular(26);

    final double relationBarBottom = isSwap  ? 44 : 40;

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF60A5FA).withAlpha(140),
                      width: 4,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.white.withAlpha(220),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: PsNetworkImage(
                      photoKey: '$coreTagKey${PsConst.HERO_TAG__IMAGE}',
                      defaultPhoto: product.defaultPhoto,
                      width: double.infinity,
                      height: double.infinity,
                      boxfit: BoxFit.cover,
                      imageAspectRation: PsConst.Aspect_Ratio_2x,
                      onTap: onTap,
                    ),
                  ),
                ),
              ),
            ),

           /* Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xFF011934).withAlpha(200),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),*/



            if (showBannerForThisVariant)
              Positioned(
                top: 15,
                left: 10,
                right: 10,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: TaapdeelRotatingValueBadge(
                    vm: badgeVM,
                    forceGold: false,
                  ),
                ),
              ),

            if (showRelationBar && (relationUI?.visible ?? false))
              Positioned(
                left: 0,
                right: 0,
                bottom: relationBarBottom,
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: TaapdeelRelationBar(
                      ui: relationUI!,
                      radius: 14,
                      blur: 10,
                    ),
                  ),
                ),
              ),

            if (showBottomPriceChip)
              Positioned(
                left: 10,
                right: 10,
                bottom: 15,
                child: _DarkChip(
                  child: _PriceHeroText(
                    coreTagKey: coreTagKey,
                    text: priceText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  // ======================================================
  // ✅ Read breakdown from Product (supports different field names)
  // ======================================================
  List<Map<String, dynamic>> _readSwapBreakdown(Product p) {
    try {
      final d = p as dynamic;

      // Try common names in your project:
      final candidates = [
        'swapBreakdownList',
        'swapScoreBreakdown',
        'swap_score_breakdown',
        'swapScoreBreakdownList',
      ];

      dynamic raw;
      for (final k in candidates) {
        try {
          raw = d.toJson?[k] ?? d[k];
        } catch (_) {
          // ignore
        }
        if (raw != null) break;
      }

      // Also: sometimes stored as field directly (not map access)
      raw ??= (() {
        try {
          return d.swapBreakdownList;
        } catch (_) {}
        try {
          return d.swapScoreBreakdown;
        } catch (_) {}
        return null;
      })();

      if (raw == null) return const [];

      if (raw is List) {
        return raw
            .map((e) => (e is Map)
            ? Map<String, dynamic>.from(e)
            : <String, dynamic>{})
            .where((m) => m.isNotEmpty)
            .toList();
      }

      return const [];
    } catch (_) {
      return const [];
    }
  }

  _ResolvedRelation _resolveRelation({
    required Product product,
    required int? passedType,
    required String? passedBackendCode,
  }) {
    if (passedType != null && passedType != 0) {
      return _ResolvedRelation(type: passedType, backendCode: null);
    }

    final String code1 = (passedBackendCode ?? '').trim();
    if (code1.isNotEmpty) {
      return _ResolvedRelation(
        type: relationTypeFromBackendCode(code1),
        backendCode: code1,
      );
    }

    try {
      final dynamic d = product as dynamic;

      final int t = _tryReadInt(d, const [
        'relationType',
        'relation_type',
      ]);
      if (t != 0) return _ResolvedRelation(type: t, backendCode: null);

      final String code2 = _tryReadString(d, const [
        'relationCode',
        'relation_code',
      ]);
      if (code2.isNotEmpty) {
        return _ResolvedRelation(
          type: relationTypeFromBackendCode(code2),
          backendCode: code2,
        );
      }
    } catch (_) {}

    return const _ResolvedRelation(type: 0, backendCode: null);
  }

  int _tryReadInt(dynamic d, List<String> keys) {
    for (final k in keys) {
      try {
        final v = d.toJson?[k] ?? d[k];
        if (v is int) return v;
        if (v is String) {
          final n = int.tryParse(v.trim());
          if (n != null) return n;
        }
      } catch (_) {}
    }
    return 0;
  }

  String _tryReadString(dynamic d, List<String> keys) {
    for (final k in keys) {
      try {
        final v = d.toJson?[k] ?? d[k];
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
        }
      } catch (_) {}
    }
    return '';
  }

  String _safe(String? s) => (s == null || s.trim().isEmpty) ? '-' : s.trim();
}

class _ResolvedRelation {
  final int type;
  final String? backendCode;
  const _ResolvedRelation({required this.type, required this.backendCode});
}

class _SwapLabelVM {
  final String title;
  final Color color;
  const _SwapLabelVM({required this.title, required this.color});
}


/// ✅ Key → icon/color mapping
/// =======================
class _BreakdownMeta {
  final IconData icon;
  final Color color;
  const _BreakdownMeta(this.icon, this.color);
}


/// ======================================================
/// ✅ Center-growing fill chip + info icon
/// ======================================================

/// ======================================================
/// ✅ Chips / Hero text (unchanged)
/// ======================================================
class _DarkChip extends StatelessWidget {
  const _DarkChip({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha(100),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PriceHeroText extends StatelessWidget {
  const _PriceHeroText({required this.coreTagKey, required this.text});

  final String coreTagKey;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _SafeHero(
      tag: '$coreTagKey${PsConst.HERO_TAG__UNIT_PRICE}',
      flightShuttleBuilder: Utils.flightShuttleBuilder,
      child: Material(
        type: MaterialType.transparency,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Color(0xFF011934),
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: 0.2,
              fontSize: 13.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _SafeHero extends StatelessWidget {
  const _SafeHero({
    required this.tag,
    required this.child,
    this.flightShuttleBuilder,
  });

  final String tag;
  final Widget child;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  @override
  Widget build(BuildContext context) {
    final hasHeroAncestor = context.findAncestorWidgetOfExactType<Hero>() != null;
    if (hasHeroAncestor) return child;
    return PsHero(
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder,
      child: child,
    );
  }
}

/// ======================================================
/// ✅ Price formatting (كما هو عندك)
/// ======================================================
String formatPriceDisplay(
    String raw, {
      String currency = 'ج',
      bool useEGP = false,
    }) {
  final String cur = useEGP ? 'ج.م' : currency;

  String s = raw.trim();
  if (s.isEmpty || s == '-') return '-';

  final hasAnyDigit = RegExp(r'\d').hasMatch(s);
  if (!hasAnyDigit) return s;

  s = s
      .replaceAll(
    RegExp(r'(ج\.?م|جنيه|EGP|LE|L\.E\.|ج)', caseSensitive: false),
    '',
  )
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final match =
  RegExp(r'(\d+(?:\.\d+)?)\s*[- ]\s*(\d+(?:\.\d+)?)').firstMatch(s);

  if (match != null) {
    final a = match.group(1)!;
    final b = match.group(2)!;
    final fa = _formatThousands(a);
    final fb = _formatThousands(b);
    return '$fa – $fb $cur';
  }

  final single = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(s);
  if (single != null) {
    return '${_formatThousands(single.group(1)!)} $cur';
  }

  return raw.trim();
}

String _formatThousands(String numStr) {
  final parts = numStr.split('.');
  final intPart = parts[0];

  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    final posFromEnd = intPart.length - i;
    buf.write(intPart[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) {
      buf.write(',');
    }
  }

  if (parts.length > 1 && parts[1].isNotEmpty) {
    return '${buf.toString()}.${parts[1]}';
  }
  return buf.toString();
}
