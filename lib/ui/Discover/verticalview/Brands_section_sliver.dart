import 'package:flutter/material.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import '../../Product/product_widget.dart';
import '../section_base_sliver.dart';

class BrandsSectionSliver extends StatelessWidget {
  const BrandsSectionSliver({
    Key? key,
    required this.title,
    required this.url,
    required this.catId,
    required this.recentProvider,
  }) : super(key: key);

  final String title;
  final String url;
  final String Function() catId;
  final RecentProductProvider Function() recentProvider;

  @override
  Widget build(BuildContext context) {
    return BaseSectionSliver(
      title: title,
      url: url,
      catId: catId,
      recentProvider: recentProvider,

      // ✅ زي Latest: هيدر داخلي
      showHeader: false,

      // ✅ wrapper بنفس فكرة Latest لكن Silver
      sectionWrapper: (ctx, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: _SilverBackgroundSection(
            title: title,
            child: child,
          ),
        );
      },

      // ✅ خلّيها قريبة من Latest (أو أقل شوية لو عايزه أخف)
      sectionHeight: 220,

      cardBuilder: ({
        required context,
        required product,
        required coreTagKey,
        required onTap,
      }) {
        return TaapdeelProductCardItem(
          coreTagKey: coreTagKey,
          product: product,
          onTap: onTap,
          variant: TaapdeelProductCardVariant.normal,
          showRotatingBanner: true,
          showRelationPanel: false,
          showConditionChip: false,
          onTapFav: null,
          selectedFav: false,
        );
      },
    );
  }
}

class _SilverBackgroundSection extends StatelessWidget {
  const _SilverBackgroundSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ✅ Silver palette (معدني)
    final Color silverLight = const Color(0xFFF8FAFC);
    final Color silverMid   = const Color(0xFF1F4F75);
    final Color silverDark  = const Color(0xFF475569);


    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white.withAlpha(50),
            Colors.white.withAlpha(50),
            Colors.white.withAlpha(100),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SILVER HEADER STRIP =================
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    silverMid.withAlpha(100),
                    silverMid.withAlpha(30),
                    Colors.white.withAlpha(100),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(245),
                      border: Border.all(color: silverMid.withAlpha(160)),
                    ),
                    child: Icon(
                      Icons.card_giftcard_rounded, // ✅ free icon
                      size: 18,
                      color: silverDark,
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: silverDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ================= PRODUCTS =================
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8, bottom: 12),
              child: Transform.translate(
                offset: const Offset(0, 0),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
