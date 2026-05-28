import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

/// TaapdeelCategoryCard
///
/// كارت Neumorphic / Soft Glass لعرض فئة:
/// - أيقونة من ImageProvider (Asset / Network ...)
/// - لا يوجد + نهائيًا لو مفيش أيقونة
/// - عنوان أسفل الأيقونة
/// - Supports isSelected مع Animation (Scale + Stronger Glow)
class TaapdeelCategoryCard extends StatelessWidget {
  const TaapdeelCategoryCard({
    Key? key,
    required this.label,
    this.iconImage,
    this.onTap,
    this.isSelected = false,
    this.size = 76,
    this.showPlusWhenNoIcon = false, // لم يعد مستخدم فعليًا (للتوافق فقط)
  }) : super(key: key);

  /// نص العنوان أسفل الأيقونة
  final String label;

  /// صورة الأيقونة (AssetImage / NetworkImage / FileImage .. إلخ)
  final ImageProvider? iconImage;

  /// حدث الضغط على الكارت
  final VoidCallback? onTap;

  /// هل الكارت مختار حاليًا؟
  final bool isSelected;

  /// حجم الكارت (عرض وارتفاع)
  final double size;

  /// لم يعد يظهر + حتى لو true (محفوظ فقط عشان ما يكسّرش الكود القديم)
  final bool showPlusWhenNoIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color baseColor = const Color(0xFFE9F3FF);
    final Color selectedBorderColor = const Color(0xFF2B6CB0);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // الكارت نفسه + أنيميشن السيلكت
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: size,
            height: size,
            transform: Matrix4.identity()
              ..scale(isSelected ? 1.06 : 1.0), // Zoom بسيط عند السيلكت
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? <Color>[
                  Color(0xFFC3EFE7),
                  baseColor.withOpacity(0.9),
                ]
                    : <Color>[
                  Colors.white,
                  baseColor,
                ],
              ),
              border: isSelected
                  ? Border.all(
                color: selectedBorderColor.withOpacity(0.85),
                width: 1.4,
              )
                  : null,
              boxShadow: <BoxShadow>[
                // Light top-left
                BoxShadow(
                  color: Colors.white.withOpacity(isSelected ? 1.0 : 0.9),
                  offset: const Offset(-4, -4),
                  blurRadius: isSelected ? 14 : 10,
                ),
                // Soft bottom-right
                BoxShadow(
                  color:
                  const Color(0xFFB0C6E5).withOpacity(isSelected ? 0.8 : 0.6),
                  offset: const Offset(4, 4),
                  blurRadius: isSelected ? 18 : 14,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Center(
                  child: _buildIcon(),
                ),
              ),
            ),
          ),

          const SizedBox(height: PsDimens.space4),

          // العنوان
          SizedBox(
            width: size + 8,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF16355B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (iconImage != null) {
      return Image(
        image: iconImage!,
        width: size * 0.65,
        height: size * 0.65,
        fit: BoxFit.contain,
      );
    }

    // لا نعرض أي شيء لو مفيش أيقونة
    return const SizedBox.shrink();
  }
}
