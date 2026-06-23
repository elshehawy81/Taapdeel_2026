import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';

/// TaapdeelBaseDialog
///
/// Dialog زجاجي موحّد (Warning / Error / Confirm / Info)
/// - Glassmorphism + ظل Neo-Brutal خفيف
/// - يستخدم TaapdeelButton في الأزرار
class TaapdeelBaseDialog extends StatelessWidget {
  const TaapdeelBaseDialog({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.iconBackground,
    required this.primaryButtonLabel,
    required this.onPrimaryTap,
    this.secondaryButtonLabel,
    this.onSecondaryTap,
  }) : super(key: key);

  final String title;
  final String message;

  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackground;

  final String primaryButtonLabel;
  final VoidCallback onPrimaryTap;

  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Brand Blue موحّد (نفس الأزرار والـchips)
    const Color brandBlue = Color(0xFF3167B0);

    // لون الزجاج الأساسي
    final Color baseGlassColor = isDark
        ? const Color(0xE61F2933) // رمادي غامق شفاف في الـDark
        : const Color(0xE6FFFFFF); // أبيض شفاف في الـLight

    const BorderRadius dialogRadius = BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(10), // cut-corner خفيفة
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: PsDimens.space24,
        vertical: PsDimens.space24,
      ),
      elevation: 0,
      child: Stack(
        children: <Widget>[
          // ظل سفلي (Neo-Brutal Layer)
          Positioned.fill(
            top: 6,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: dialogRadius,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: brandBlue.withValues(alpha: 0.22),
                    blurRadius: 26,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
            ),
          ),

          // جسم الديالوج الزجاجي
          ClipRRect(
            borderRadius: dialogRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: dialogRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      baseGlassColor,
                      const Color(0xFFE0F1FF), // Ice Blue خفيف
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(PsDimens.space20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // ===== Icon دائرة زجاجية (اختياري) =====
                    if (icon != null) ...<Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              (iconBackground ?? brandBlue)
                                  .withValues(alpha: 0.96),
                              (iconBackground ?? brandBlue)
                                  .withValues(alpha: 0.78),
                            ],
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: (iconBackground ?? brandBlue)
                                  .withValues(alpha: 0.45),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: iconColor ?? Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: PsDimens.space16),
                    ],

                    // ===== Title =====
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: PsDimens.space12),

                    // ===== Message (Scrollable لو طويل) =====
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        // ارتفاع أقصى عشان ما يغطيش الشاشة
                        maxHeight: 340,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF111827),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: PsDimens.space24),

                    // ===== Primary Button (Filled) =====
                    TaapdeelButton(
                      label: primaryButtonLabel,
                      onPressed: onPrimaryTap,
                      isPrimary: true,
                      isExpanded: true,
                    ),

                    // ===== Secondary Button (Outlined) – اختياري =====
                    if (secondaryButtonLabel != null &&
                        secondaryButtonLabel!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: PsDimens.space12),
                      TaapdeelButton(
                        label: secondaryButtonLabel!,
                        onPressed: onSecondaryTap ??
                                () => Navigator.of(context).maybePop(),
                        isPrimary: false,
                        isExpanded: true,
                        outlined: true,
                        backgroundColorOverride: Colors.white,
                        foregroundColorOverride: brandBlue,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
