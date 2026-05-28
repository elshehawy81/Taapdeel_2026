import 'package:flutter/material.dart';
import 'package:taapdeel/provider/product/recent_product_provider.dart';
import '../../../../viewobject/product.dart';
import '../../Product/product_widget.dart';
import '../section_base_sliver.dart';

class FamilySectionSliver extends StatelessWidget {
  const FamilySectionSliver({
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
      sectionHeight: 220,
      sectionWrapper: (ctx, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: _MintFamilyBackgroundSection(
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
          variant: TaapdeelProductCardVariant.family,
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

/// ✅ MintGlass Premium Wrapper (زي Premium بالظبط لكن Mint Gradient لطيف)
class _MintFamilyBackgroundSection extends StatelessWidget {
  const _MintFamilyBackgroundSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ====== Mint Palette (Premium + Glass) ======
    final Color mintDark = const Color(0xFF0E8F7E);
    final Color mintMid  = const Color(0xFF20BFA9);
    final Color mintLite = const Color(0xFFEAF7F5);

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
            Colors.white.withAlpha(5),
            Colors.white.withAlpha(20),
            Colors.white.withAlpha(20),
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
            // ================= MINT GLASS HEADER STRIP =================
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    mintMid.withAlpha(70),
                    mintLite.withAlpha(30),
                    Colors.white.withAlpha(100),
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
                          color: mintMid.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      size: 18,
                      color: mintDark,
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
                            color: mintDark,
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
