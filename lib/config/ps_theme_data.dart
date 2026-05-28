import 'package:flutter/material.dart';
import 'ps_colors.dart';
import 'ps_config.dart';

/// Central Theme builder for the Taapdeel app.
ThemeData themeData(ThemeData baseTheme) {
  const bool isDark = false;

  // Sync PsColors with current brightness.
  PsColors.loadColor2(true);
  // Core colors.
  final Color primary = PsColors.primary500;
  final Color secondary = PsColors.secondary500;

// Force clean light surfaces.
  final Color background = PsColors.baseColor;
  final Color surface = PsColors.baseLightColor;

// Text on primary buttons must be white, not light grey.
  final Color onPrimary = Colors.white;

// Normal text on white/light surfaces.
  final Color onSurface = PsColors.textPrimaryColor;

  final Color error = PsColors.redColor;

  // ColorScheme – surfaceTint = transparent to avoid pink tint
  final ColorScheme colorScheme = baseTheme.colorScheme.copyWith(
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onPrimary,
    surface: surface,
    onSurface: onSurface,
    error: error,
    brightness: isDark ? Brightness.dark : Brightness.light,
    surfaceTint: Colors.transparent,
  );

  // Typography
  final TextTheme baseTextTheme = baseTheme.textTheme;

  /// ✅ fallback مهم جداً للعربي (حتى لو fontFamily الأساسي مش مثالي)
  const List<String> fontFallback = <String>[
    'Cairo', // لو انت ضايفه كـ asset
    'IBM Plex Sans Arabic', // لو ضايفه كـ asset
    'Noto Sans Arabic',
    'Arial',
  ];

  TextStyle? _withFamily(TextStyle? s) {
    if (s == null) return null;
    return s.copyWith(
      fontFamily: PsConfig.ps_default_font_family,
      fontFamilyFallback: fontFallback,
    );
  }

  final TextTheme textTheme = baseTextTheme
      .apply(
    fontFamily: PsConfig.ps_default_font_family,
    bodyColor: onSurface,
    displayColor: onSurface,
  )
      .copyWith(
    // Screen titles
    displayLarge: _withFamily(baseTextTheme.displayLarge)?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    ),
    displayMedium: _withFamily(baseTextTheme.displayMedium)?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    ),
    displaySmall: _withFamily(baseTextTheme.displaySmall)?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.1,
    ),

    // Section titles
    headlineMedium: _withFamily(baseTextTheme.headlineMedium)?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w800,
    ),
    headlineSmall: _withFamily(baseTextTheme.headlineSmall)?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w800,
    ),

    // AppBar / card titles
    titleLarge: _withFamily(baseTextTheme.titleLarge)?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w800,
    ),
    titleMedium: _withFamily(baseTextTheme.titleMedium)?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w800,
    ),
    titleSmall: _withFamily(baseTextTheme.titleSmall)?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w800,
    ),

    // Main body text
    bodyLarge: _withFamily(baseTextTheme.bodyLarge)?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500, // ✅ العربي بيبان أفخم مع 500 بدل 400
      height: 1.35,
    ),
    bodyMedium: _withFamily(baseTextTheme.bodyMedium)?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
    bodySmall: _withFamily(baseTextTheme.bodySmall)?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: isDark ? PsColors.primaryDarkGrey : PsColors.secondary400,
      height: 1.30,
    ),

    // Buttons / chips / labels
    labelLarge: _withFamily(baseTextTheme.labelLarge)?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w800,
    ),
    labelMedium: _withFamily(baseTextTheme.labelMedium)?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
    labelSmall: _withFamily(baseTextTheme.labelSmall)?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
  );

  // AppBar
  final AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: surface,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(
      color: isDark ? PsColors.primaryDarkWhite : PsColors.secondary500,
    ),
    titleTextStyle: textTheme.titleLarge,
  );

  // Buttons
  final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: onPrimary,
      backgroundColor: primary,
      textStyle: textTheme.labelLarge,
      minimumSize: const Size(64, 44),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: isDark ? 0 : 1,
    ),
  );

  final OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primary,
      textStyle: textTheme.labelLarge,
      side: BorderSide(color: primary, width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );

  final TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primary,
      textStyle: textTheme.labelMedium?.copyWith(
        decoration: TextDecoration.underline,
      ),
    ),
  );

  // TextFields / inputs
  final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: isDark ? PsColors.baseDarkColor : PsColors.baseLightColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? PsColors.secondary300 : PsColors.secondary200,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? PsColors.secondary300 : PsColors.secondary200,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: primary,
        width: 1.6,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: error,
        width: 1.2,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: error,
        width: 1.4,
      ),
    ),
    labelStyle: textTheme.bodyMedium?.copyWith(
      color: PsColors.textPrimaryLightColor,
    ),
    hintStyle: textTheme.bodyMedium?.copyWith(
      color: PsColors.textPrimaryLightColor.withValues(alpha: 0.85),
    ),
  );

  // Bottom navigation bar
  final BottomNavigationBarThemeData bottomNavTheme =
  BottomNavigationBarThemeData(
    backgroundColor: surface,
    selectedItemColor: PsColors.bottomNavigationSelectedColor ?? primary,
    unselectedItemColor: PsColors.textColor3,
    selectedIconTheme: const IconThemeData(size: 24),
    unselectedIconTheme: const IconThemeData(size: 22),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  );

  // Cards
  final CardThemeData cardTheme = CardThemeData(
    color: PsColors.cardBackgroundColor ?? surface,
    elevation: isDark ? 1 : 2,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  );

  // Dialogs
  final DialogThemeData dialogTheme = DialogThemeData(
    backgroundColor: isDark ? PsColors.baseColor : Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    titleTextStyle: textTheme.titleMedium,
    contentTextStyle: textTheme.bodyMedium,
  );

  /// ✅ NEW: BottomSheet theme (ده اللي بيخلي الشكل Premium)
  final BottomSheetThemeData bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    modalBackgroundColor: Colors.white,
    elevation: 18,
    shadowColor: Colors.black.withValues(alpha: 0.25),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    clipBehavior: Clip.antiAlias,
  );

  /// ✅ NEW: ListTile theme (قوائم المحافظات/المناطق)
  final ListTileThemeData listTileTheme = ListTileThemeData(
    dense: false,
    iconColor: PsColors.secondary500,
    textColor: onSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  );

  /// ✅ NEW: Divider theme (فواصل أنيقة بدل ما تكون تقيلة)
  final DividerThemeData dividerTheme = DividerThemeData(
    thickness: 1,
    space: 1,
    color: Colors.black.withValues(alpha: 0.06),
  );

  return baseTheme.copyWith(
    primaryColor: primary,
    primaryColorDark: PsColors.primary900,
    primaryColorLight: PsColors.primary50,

    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    dividerColor: PsColors.mainDividerColor,
    dividerTheme: dividerTheme,
    iconTheme: IconThemeData(color: PsColors.iconColor),

    textTheme: textTheme,
    appBarTheme: appBarTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    textButtonTheme: textButtonTheme,
    inputDecorationTheme: inputDecorationTheme,
    bottomNavigationBarTheme: bottomNavTheme,
    cardTheme: cardTheme,
    dialogTheme: dialogTheme,

    /// ✅ أهم سطرين لتجميل الـ BottomSheet والقوائم
    bottomSheetTheme: bottomSheetTheme,
    listTileTheme: listTileTheme,

    snackBarTheme: _buildSnackBarTheme(baseTheme.snackBarTheme),
  );
}

SnackBarThemeData _buildSnackBarTheme(SnackBarThemeData base) {
  return base.copyWith(
    backgroundColor: PsColors.black.withValues(alpha: 0.9),
    contentTextStyle: const TextStyle(
      fontFamily: PsConfig.ps_default_font_family,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
