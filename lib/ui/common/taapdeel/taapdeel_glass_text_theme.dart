import 'package:flutter/material.dart';

/// TextTheme مخصص لعناصر الـ Glass (BottomSheets / Panels / Cards)
class TaapdeelGlassTextTheme {
  TaapdeelGlassTextTheme(this._theme);

  final ThemeData _theme;

  // العنوان الرئيسي في الـ Glass panel (Title في الشيت)
  TextStyle get title => _theme.textTheme.titleMedium!.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B), // Slate Blue Dark
      );

  // وصف صغير تحت العنوان
  TextStyle get subtitle => _theme.textTheme.bodyMedium!.copyWith(
        fontSize: 13,
        height: 1.4,
        color: const Color(0xFF475569), // Slate Gray
      );

  // Micro-copy / Hint (سطر إرشادي صغير)
  TextStyle get hint => _theme.textTheme.bodySmall!.copyWith(
        fontSize: 12,
        height: 1.4,
        color: const Color(0xFF64748B), // Slate 500
      );

  // نص الخيارات داخل قوائم الـ Glass (Radio / ListTile)
  TextStyle option({bool selected = false}) =>
      _theme.textTheme.bodyMedium!.copyWith(
        fontSize: 15,
        height: 1.4,
        color: selected
            ? const Color(0xFF0F172A) // أغمق شوية للمختار
            : const Color(0xFF334155),
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      );

  // عناوين صغيرة (مثلاً label في Card)
  TextStyle get smallLabel => _theme.textTheme.bodySmall!.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E293B),
      );
}

/// Extension علشان نستدعيها بسهولة من أي Widget:
extension TaapdeelGlassTextThemeX on BuildContext {
  TaapdeelGlassTextTheme get glassText =>
      TaapdeelGlassTextTheme(Theme.of(this));
}
