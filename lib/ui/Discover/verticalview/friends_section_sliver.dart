import 'package:flutter/material.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import '../../../viewobject/product.dart';
import '../../Product/product_widget.dart';
import '../section_base_sliver.dart';


class FriendsSectionSliver extends StatelessWidget {
  const FriendsSectionSliver({
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

      // ✅ زي Premium/Family: الهيدر يبقى بتاعنا
      showHeader: false,

      // ✅ كروت أعرض شوية زي ما انت عايز
      sectionHeight: 200,
      //visibleCards: 1.85,

      // ✅ Wrapper موحد مع Premium/Family
      sectionWrapper: (ctx, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: _BlueFriendsBackgroundSection(
            title: title,
            child: child,
          ),
        );
      },

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
          variant: TaapdeelProductCardVariant.friend,
          showRotatingBanner: true,
          showRelationPanel: true,
          showConditionChip: false,
          relationBackendCode: _getRelationCode(product), // "BIG_FAMILY"
          onTapFav: null,
          selectedFav: false,
        );
      },

    );
  }
}
String? _getRelationCode(Product p) {
  try {
    final d = p as dynamic;
    final v = (d.relationCode ?? d.relation_code ?? '').toString().trim();
    return v.isEmpty ? null : v;
  } catch (_) {
    return null;
  }
}
/// ✅ Friends Wrapper بنفس Premium feel لكن Blue Glass Gradient
class _BlueFriendsBackgroundSection extends StatelessWidget {
  const _BlueFriendsBackgroundSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ====== Blue Palette (Premium + Glass) ======
    final Color blueDark = const Color(0xFF155EAA);
    final Color blueMid  = const Color(0xFF2F8CFF);
    final Color blueLite = const Color(0xFFCFE6FF);

    // Glass overlays
    final Color glassA = Colors.white.withAlpha(170);
    final Color glassB = Colors.white.withAlpha(110);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white.withAlpha(90),
            Colors.white.withAlpha(90),
            Colors.white.withAlpha(90),

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
            // ================= BLUE GLASS HEADER STRIP =================
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    blueMid.withAlpha(100),
                    blueLite.withAlpha(30),
                    Colors.white.withAlpha(90),

                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon bubble (glass)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [glassA, glassB],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: blueMid.withAlpha(55),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      size: 18,
                      color: blueDark,
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// TITLE + HINT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: blueDark,
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
                offset: const Offset(0, 0), // open edge
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
