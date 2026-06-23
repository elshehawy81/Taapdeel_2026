import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';

class TaapdeelSelectableUserCircleCard extends StatelessWidget {
  const TaapdeelSelectableUserCircleCard({
    Key? key,
    required this.userId,
    required this.name,
    required this.photoHeroTag,
    required this.imagePath,
    this.gender,
    this.ageRange,
    required this.selected,
    required this.onTap,
    this.subtitle,
    // sizing
    this.size = 86, // ✅ العرض/الارتفاع الأساسي للكارت
    this.avatarSize = 66, // ✅ قطر الصورة
  }) : super(key: key);

  final String userId;
  final String name;
  final String photoHeroTag;
  final String? imagePath;
  final String? gender;
  final String? ageRange;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  final double size;
  final double avatarSize;
  @override
  Widget build(BuildContext context) {
    final Color accent = PsColors.bottomNav;

    final String? safeImagePath =
    (imagePath != null && imagePath!.trim().isNotEmpty) ? imagePath : null;

    final double ring = selected ? 2.2 : 1.2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: size,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Avatar Circle only (no white card)
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: avatarSize,
                    height: avatarSize,
                    padding: EdgeInsets.all(ring),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          accent.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: selected
                            ? accent.withOpacity(0.55)
                            : Colors.black.withOpacity(0.06),
                        width: ring,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 10),
                        ),
                        if (selected)
                          BoxShadow(
                            color: accent.withOpacity(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 12),
                          ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.black.withOpacity(0.06),
                                  Colors.black.withOpacity(0.02),
                                  accent.withOpacity(0.06),
                                ],
                              ),
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, c) {
                              return PsNetworkImageWithUrlForUser(
                                photoKey: photoHeroTag,
                                imagePath: safeImagePath,
                                width: c.maxWidth,
                                height: c.maxHeight,
                                boxfit: BoxFit.cover,
                                imageAspectRation: PsConst.Aspect_Ratio_2x,
                                gender: gender,
                                ageRange: ageRange,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // ✅ Name (small + tight)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    name.isEmpty ? 'مستخدم' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black.withOpacity(0.82),
                      height: 1,
                    ),
                  ),
                ),
                if ((subtitle ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.55),
                      height: 1.0,
                    ),
                  ),
                ],
              ],
            ),

            // ✅ Selected check (top-left)
            Positioned(
              top: 2,
              left: 2,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 160),
                scale: selected ? 1 : 0.85,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: selected ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(0.55)),
                    ),
                    child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
