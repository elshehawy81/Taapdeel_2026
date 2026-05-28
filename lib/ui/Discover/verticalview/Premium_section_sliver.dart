import 'package:flutter/material.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import '../../Product/product_widget.dart';
import '../section_base_sliver.dart';


class PremiumSectionSliver extends StatelessWidget {
  const PremiumSectionSliver({
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

      showHeader: false,

      sectionWrapper: (ctx, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: _DealsBackgroundSection(
            title: title,
            child: child,
          ),
        );
      },

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
          variant: TaapdeelProductCardVariant.deal,
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
class _DealsBackgroundSection extends StatelessWidget {
  const _DealsBackgroundSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {

    final Color goldLight = const Color(0xFFFFE7A3);
    final Color goldMid   = const Color(0xFFFFF4DA);
    final Color goldDark  = const Color(0xFF8C6A03);


    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.topLeft,
          colors: [
            Colors.white.withAlpha(100),
            Colors.white.withAlpha(100),
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
            // ================= GOLD HEADER STRIP =================
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    goldLight.withAlpha(150),
                    goldLight.withAlpha(30),
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
                      color: Colors.white.withAlpha(240),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: 18,
                      color: goldDark,
                    ),
                  ),
                  const SizedBox(width: 15),

                  /// TITLE + HINT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: goldDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'مدة استخدام ، جودة ،براند ،مستورد ،مغلف ، مجاني',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: goldDark,
                            fontWeight: FontWeight.w700,
                            height: 1,
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
              padding: const EdgeInsetsDirectional.only(start: 8, bottom: 5),
              child: Transform.translate(
                offset: const Offset(0, 0), // 👈 إحساس open edge
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
