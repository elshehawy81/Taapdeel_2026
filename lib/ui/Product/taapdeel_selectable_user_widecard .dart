import 'package:flutter/material.dart';

import '../../config/ps_colors.dart';
import '../../constant/ps_constants.dart';
import '../common/ps_ui_widget.dart';


class TaapdeelSelectableUserWidecard extends StatelessWidget {
  const TaapdeelSelectableUserWidecard({
    Key? key,
    required this.userId,
    required this.name,
    required this.photoHeroTag,
    required this.imagePath,
    this.gender,
    this.ageRange,
    required this.selected,
    required this.onTap,
    this.itemsCount,

    // sizing
    this.width,
    this.compact = true,
  }) : super(key: key);

  final String userId;
  final String name;
  final String photoHeroTag;
  final String? imagePath;

  final String? gender;
  final String? ageRange;

  final bool selected;
  final VoidCallback onTap;

  final int? itemsCount;

  /// If null -> caller decides.
  final double? width;

  /// compact = smaller padding/radius/chips for 3 cards row
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color accent = PsColors.bottomNav;

    // --- Compact tokens (tune here once, used everywhere) ---
    final double outerRadius = compact ? 18 : 22;
    final double innerRadius = compact ? 14 : 18;

    final EdgeInsets padding =
    compact ? const EdgeInsets.all(8) : const EdgeInsets.all(10);

    final double checkSize = compact ? 12 : 14;
    final EdgeInsets checkPadding =
    compact ? const EdgeInsets.all(5) : const EdgeInsets.all(6);

    final EdgeInsets namePad = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    final double nameRadius = compact ? 14 : 16;

    // ✅ Aspect ratio: tuned for compact in grids/horizontal
    final double ar = compact ? 0.98 : 0.88;

    // ✅ safe image path (avoid '' causing default always)
    final String? safeImagePath =
    (imagePath != null && imagePath!.trim().isNotEmpty) ? imagePath : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(outerRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius),
          color: Colors.white.withOpacity(0.92),
          border: Border.all(
            color: selected
                ? accent.withOpacity(0.42)
                : Colors.black.withOpacity(0.08),
            width: selected ? (compact ? 1.4 : 1.6) : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(compact ? 0.06 : 0.08),
              blurRadius: compact ? 18 : 22,
              offset: Offset(0, compact ? 10 : 14),
            ),
            if (selected)
              BoxShadow(
                color: accent.withOpacity(0.16),
                blurRadius: compact ? 18 : 24,
                offset: Offset(0, compact ? 12 : 16),
              ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(innerRadius),
              child: AspectRatio(
                aspectRatio: ar,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // subtle background
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withOpacity(0.04),
                            Colors.black.withOpacity(0.02),
                            accent.withOpacity(0.04),
                          ],
                        ),
                      ),
                    ),

                    // ✅ image: use LayoutBuilder to provide REAL width/height
                    LayoutBuilder(
                      builder: (context, c) {
                        final double w = c.maxWidth;
                        final double h = c.maxHeight;

                        return PsNetworkImageWithUrlForUser(
                          photoKey: photoHeroTag,
                          imagePath: safeImagePath,
                          width: w,
                          height: h,
                          boxfit: BoxFit.cover,
                          imageAspectRation: PsConst.Aspect_Ratio_2x,
                          gender: gender,
                          ageRange: ageRange,
                        );
                      },
                    ),

                    // bottom gradient for readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.00),
                              Colors.black.withOpacity(0.00),
                              Colors.black.withOpacity(0.26),
                              Colors.black.withOpacity(0.62),
                            ],
                            stops: const [0.0, 0.55, 0.78, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // name + mini stats
                    Positioned(
                      left: compact ? 1 : 10,
                      right: compact ? 1 : 10,
                      bottom: compact ? 8 : 10,
                      child: Container(
                        padding: namePad,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(nameRadius),
                          color: Colors.black.withOpacity(0.42),
                          border:
                          Border.all(color: Colors.white.withOpacity(0.18)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: compact ? 14 : 18,
                              offset: Offset(0, compact ? 8 : 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'مستخدم' : name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withOpacity(0.98),
                                height: 1.0,
                              ),
                            ),
                            if (itemsCount != null ) ...[
                              SizedBox(height: compact ? 5 : 6),
                              Wrap(
                                spacing: compact ? 6 : 8,
                                runSpacing: compact ? 5 : 6,
                                children: [
                                  if (itemsCount != null)
                                    _MiniStatChip(
                                      compact: compact,
                                      icon: Icons.inventory_2_rounded,
                                      text: '$itemsCount',
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // selected check
            Positioned(
              top: compact ? 6 : 8,
              left: compact ? 6 : 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: selected ? 1 : 0,
                child: Container(
                  padding: checkPadding,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.55)),
                  ),
                  child: Icon(Icons.check_rounded,
                      size: checkSize, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.icon,
    required this.text,
    required this.compact,
  });

  final IconData icon;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: compact ? 12 : 14, color: Colors.white.withOpacity(0.96)),
          SizedBox(width: compact ? 5 : 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.98),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
