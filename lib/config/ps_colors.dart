// Copyright (c) 2019, the PS Project authors.
// All rights reserved. Use of this source code is governed by a
// PS license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:taapdeel/utils/utils.dart';

/// Global color configuration for the whole app.
///
/// This class exposes a set of static colors that are adjusted based on
/// the current theme (light / dark) via [loadColor] / [loadColor2].
///
/// Usage:
/// - Always call `PsColors.loadColor(context)` early in app startup
///   (before building UI that depends on PsColors).
/// - Use `PsColors.*` instead of hardcoding colors in widgets.
///
/// Future Improvement:
/// - Move to a more type-safe theme system instead of mutable static fields.
/// - Group colors into semantic roles (primary, surface, error, success…)
///   rather than low-level palette names.
class PsColors {
  PsColors._();

  // --------------------------------------------------
  // Main / Base Colors (Theme-dependent)
  // --------------------------------------------------

  /// Base surface color for many components (initialized with dark base).
  static Color mainLightColorWithBlack = _d_base_color;

  /// Main shadow colors.
  static Color mainShadowColor = Colors.black.withValues(alpha: 0.5);
  static Color mainLightShadowColor = Colors.black.withValues(alpha: 0.5);

  /// Divider color used across the app.
  static Color mainDividerColor = _d_divider_color;

  // --------------------------------------------------
  // Primary Color Palette (TaapdeeL Navy)
  // --------------------------------------------------

  static Color primary50 = _c_primary_50;
  static Color primary100 = _c_primary_100;
  static Color primary200 = _c_primary_200;
  static Color primary300 = _c_primary_300;
  static Color primary400 = _c_primary_400;
  static Color primary500 = _c_primary_500; // ✅ used widely (bottom nav, etc.)
  static Color primary600 = _c_primary_600;
  static Color primary700 = _c_primary_700;
  static Color primary800 = _c_primary_800;
  static Color primary900 = _c_primary_900;

  /// Primary dark variants.
  static Color primaryDarkDark = _c_primary_dark_dark;
  static Color primaryDarkAccent = _c_primary_dark_accent;
  static Color primaryDarkWhite = _c_primary_dark_white;
  static Color primaryDarkGrey = _c_primary_dark_grey;

  // --------------------------------------------------
  // Secondary Color Palette (TaapdeeL Teal)
  // --------------------------------------------------

  static Color secondary50 = _c_secondary_50;
  static Color secondary100 = _c_secondary_100;
  static Color secondary200 = _c_secondary_200;
  static Color secondary300 = _c_secondary_300;
  static Color secondary400 = _c_secondary_400;
  static Color secondary500 = _c_secondary_500;
  static Color secondary600 = _c_secondary_600;
  static Color secondary700 = _c_secondary_700;
  static Color secondary800 = _c_secondary_800;
  static Color secondary900 = _c_secondary_900;

  /// Secondary dark variants.
  static Color secondaryDarkDark = _c_secondary_dark_dark;
  static Color secondaryDarkAccent = _c_secondary_dark_accent;
  static Color secondaryDarkWhite = _c_secondary_dark_white;
  static Color secondaryDarkGrey = _c_secondary_dark_grey;

  /// Accent orange/gold (يمكن تستخدمه لميزة "لُقْطَة" / Premium)
  static Color orangeColor = _orange_color;

  // --------------------------------------------------
  // Base / Background Colors
  // --------------------------------------------------

  static Color baseColor = _d_base_color;
  static Color baseDarkColor = _d_base_dark_color;
  static Color baseLightColor = _d_base_light_color;

  // Button / status colors
  static Color greenColor = _green_color;
  static Color redColor = _red_color;

  // --------------------------------------------------
  // Text Colors
  // --------------------------------------------------

  static Color textPrimaryColor = _d_text_primary_color;
  static Color textPrimaryDarkColor = _d_text_primary_dark_color;
  static Color textPrimaryLightColor = _d_text_primary_light_color;

  static Color? textPrimaryColorForLight;
  static Color? textPrimaryDarkColorForLight;
  static Color? textPrimaryLightColorForLight;

  static Color? lightBlue;

  static Color? textColor1;
  static Color? textColor2;
  static Color? textColor3;
  static Color? textColor4;
  static Color? textColor5;
  static Color? textColor6;

  // --------------------------------------------------
  // Button / Navigation / State Colors
  // --------------------------------------------------

  static Color? buttonColor;
  static Color? bottomNavigationSelectedColor;
  static Color? backArrowColor;

  /// General active / accent color.
  static Color? activeColor;

  // --------------------------------------------------
  // Icon / Background
  // --------------------------------------------------

  static Color iconColor = _d_icon_color;

  static Color coreBackgroundColor = _d_base_color;
  static Color backgroundColor = _d_base_dark_color;

  // --------------------------------------------------
  // General Utility Colors
  // --------------------------------------------------

  static Color white = _c_white_color;
  static Color black = _c_black_color;
  static Color grey = _c_grey_color;
  static Color transparent = _c_transparent_color;

  // --------------------------------------------------
  // Custom / Brand-Specific Colors
  // --------------------------------------------------

  static Color facebookLoginButtonColor = _c_facebook_login_color;
  static Color googleLoginButtonColor = _c_google_login_color;
  static Color phoneLoginButtonColor = _c_phone_login_color;
  static Color appleLoginButtonColor = _c_apple_login_color;

  static Color disabledFacebookLoginButtonColor = _c_grey_color;
  static Color disabledGoogleLoginButtonColor = _c_grey_color;
  static Color disabledPhoneLoginButtonColor = _c_grey_color;
  static Color disabledAppleLoginButtonColor = _c_grey_color;


  static Color? categoryBackgroundColor;
  static Color? cardBackgroundColor;
  static Color? loadingCircleColor;
  static Color? ratingColor;

  /// ✅ TaapdeeL Accent (used in many places previously as "soldOut")
  static Color? soldOutUIColor;
  static Color? itemTypeColor;

  static Color? paidAdsColor;
  static Color? bluemarkColor;

  // --------------------------------------------------
  // Light Theme Palette (constants)
  // --------------------------------------------------

  static const Color _l_base_color = Color(0xFFFFFFFF);
  static const Color _l_base_dark_color = Color(0xFFFFFFFF);
  static const Color _l_base_light_color = Color(0xFFF2F5F8);

  /// Accent used in some light theme widgets.
  static const Color yellowAccent = Color(0xffFFD35A);

  /// Bottom navigation background (light theme).
  /// (لو فيه أماكن بتستخدم bottomNav مباشرة)
  static const Color bottomNav = _c_primary_500;

  static const Color _l_text_primary_color = Color(0xFF243B53);
  static const Color _l_text_primary_light_color = Color(0xFF8A9AAE);
  static const Color _l_text_primary_dark_color = Color(0xFF0C2345);

  /// In light mode we tie the icon color to the primary500 tone.
  static const Color _l_icon_color = PsColors._c_primary_500;

  static const Color _l_divider_color = Color(0x15505050);

  static const Color _red_color = Color(0xffa82328);
  static const Color _green_color = Color(0xff066a10);

  // --------------------------------------------------
  // Dark Theme Palette (constants)
  // --------------------------------------------------

  static const Color _d_base_color = Color(0xFF121A24);
  static const Color _d_base_dark_color = Color(0xFF0E1520);
  static const Color _d_base_light_color = Color(0xFF1B2736);

  static const Color _d_text_primary_color = Color(0xFFFFFFFF);
  static const Color _d_text_primary_light_color = Color(0xFFBFD3E6);
  static const Color _d_text_primary_dark_color = Color(0xFFFFFFFF);

  static const Color _d_icon_color = PsColors._c_secondary_300; // teal-ish

  static const Color _d_divider_color = Color(0x1FFFFFFF);

  // --------------------------------------------------
  // Common Brand Palette (constants)
  // --------------------------------------------------

  // ==========================
  // ✅ PRIMARY = NAVY SCALE
  // ==========================
  static const Color _c_primary_50 = Color(0xFFF2F6FB);
  static const Color _c_primary_100 = Color(0xFFE2ECF7);
  static const Color _c_primary_200 = Color(0xFFC6DAEE);
  static const Color _c_primary_300 = Color(0xFF9EBFDF);
  static const Color _c_primary_400 = Color(0xFF3B5B86);
  static const Color _c_primary_500 = Color(0xFF0C2345); // 🔥 Deep Navy (Logo)
  static const Color _c_primary_600 = Color(0xFF102E5C);
  static const Color _c_primary_700 = Color(0xFF0B1F3B);
  static const Color _c_primary_800 = Color(0xFF081A35);
  static const Color _c_primary_900 = Color(0xFF061329);

  static const Color _c_primary_dark_dark = Color(0xFF0E1520);
  static const Color _c_primary_dark_accent = Color(0xFF0FA3A6); // teal accent in dark mode
  static const Color _c_primary_dark_white = Color(0xFFffffff);
  static const Color _c_primary_dark_grey = Color(0xFFA0A0A0);

  // ==========================
  // ✅ SECONDARY = TEAL SCALE
  // ==========================
  static const Color _c_secondary_50 = Color(0xFFE9FBFA);
  static const Color _c_secondary_100 = Color(0xFFC9F3F0);
  static const Color _c_secondary_200 = Color(0xFF9EE7E1);
  static const Color _c_secondary_300 = Color(0xFF64D6CD);
  static const Color _c_secondary_400 = Color(0xFF2CC2B7);
  static const Color _c_secondary_500 = Color(0xFF0FA3A6); // 🔥 Teal (Logo)
  static const Color _c_secondary_600 = Color(0xFF0D8D90);
  static const Color _c_secondary_700 = Color(0xFF0B777A);
  static const Color _c_secondary_800 = Color(0xFF096164);
  static const Color _c_secondary_900 = Color(0xFF074B4D);

  static const Color _c_secondary_dark_dark = Color(0xFF0E1520);
  static const Color _c_secondary_dark_accent = Color(0xFF1CC7B8); // bright teal
  static const Color _c_secondary_dark_white = Color(0xFFffffff);
  static const Color _c_secondary_dark_grey = Color(0xFFA0A0A0);

  // Premium / gold accent (optional for "لقطة")
  static const Color _orange_color = Color(0xFFDCC88F);

  static const Color _c_light_blue = Color(0xffe5feff);

  static const Color _c_white_color = Colors.white;
  static const Color _c_black_color = Colors.black;
  static const Color _c_grey_color = Colors.grey;
  static const Color _c_blue_color = Colors.blue;
  static const Color _c_transparent_color = Colors.transparent;
  static const Color _c_paid_ads_color = Colors.lightGreen;

  // Login buttons → Navy (consistent)
  static const Color _c_facebook_login_color = _c_primary_500;
  static const Color _c_google_login_color = _c_primary_500;
  static const Color _c_phone_login_color = _c_primary_500;
  static const Color _c_apple_login_color = _c_primary_500;

  // Payments (leave as original to match brand guidelines)

  static const Color _c_rating_color = Colors.yellow;

  /// ✅ Accent used in UI (was "sold out" before)
  static const Color _c_sold_out = _c_secondary_500;

  static const Color _c_item_type_color = Color(0xFFBDBDBD);

  // ----------- Modern Text Colors (Taapdeel) -----------
  static const Color textPrimary = Color(0xFF0C2345); // Navy title
  static const Color textSecondary = Color(0xFF445E76); // body text
  static const Color grey300 = Color(0xFFE0E0E0); // dots & borders

  // علشان مع الtheme الجديد
  static const Color background = Colors.white;

  // --------------------------------------------------
  // Public API: Theme Loading
  // --------------------------------------------------

  /// Load colors - Light Mode only (Dark Mode disabled)
  ///
  /// Call this early (e.g. in your root widget) whenever the theme changes.
  static void loadColor(BuildContext context) {
    _loadLightColors(); // Always use Light Mode
  }

  /// Load colors based on a boolean flag instead of BuildContext.
  ///
  /// Useful in early initialization code where context is not available.
  static void loadColor2(bool isLightMode) {
    _loadLightColors(); // Always use Light Mode
  }

  // --------------------------------------------------
  // Internal: Light Theme Loader (Light Mode Only)
  // --------------------------------------------------

  static void _loadLightColors() {
    // Main divider
    mainDividerColor = _l_divider_color;

    // Primary
    primary50 = _c_primary_50;
    primary100 = _c_primary_100;
    primary200 = _c_primary_200;
    primary300 = _c_primary_300;
    primary400 = _c_primary_400;
    primary500 = _c_primary_500;
    primary600 = _c_primary_600;
    primary700 = _c_primary_700;
    primary800 = _c_primary_800;
    primary900 = _c_primary_900;

    // Secondary
    secondary50 = _c_secondary_50;
    secondary100 = _c_secondary_100;
    secondary200 = _c_secondary_200;
    secondary300 = _c_secondary_300;
    secondary400 = _c_secondary_400;
    secondary500 = _c_secondary_500;
    secondary600 = _c_secondary_600;
    secondary700 = _c_secondary_700;
    secondary800 = _c_secondary_800;
    secondary900 = _c_secondary_900;

    // Base
    baseColor = _l_base_color;
    baseDarkColor = _l_base_dark_color;
    baseLightColor = _l_base_light_color;

    // Text
    textPrimaryColor = _l_text_primary_color;
    textPrimaryDarkColor = _l_text_primary_dark_color;
    textPrimaryLightColor = _l_text_primary_light_color;

    textPrimaryColorForLight = _l_text_primary_color;
    textPrimaryDarkColorForLight = _l_text_primary_dark_color;
    textPrimaryLightColorForLight = _l_text_primary_light_color;

    lightBlue = _c_light_blue;

    // Text semantic colors
    textColor1 = _c_primary_500; // navy
    textColor2 = _c_primary_700;
    textColor3 = _l_text_primary_light_color;
    textColor4 = const Color(0xFFFFFFFF);
    textColor5 = const Color(0xFF000000);
    textColor6 = const Color(0xFF585858);

    // Buttons / Navigation
    buttonColor = _c_primary_500; // navy
    bottomNavigationSelectedColor = _c_secondary_500; // teal selected
    activeColor = _c_secondary_500; // teal accent
    backArrowColor = _c_secondary_500;

    // Icons
    iconColor = _l_icon_color;

    // Background
    coreBackgroundColor = _l_base_color;
    backgroundColor = _l_base_dark_color;

    // General
    white = _c_white_color;
    black = _c_black_color;
    grey = _c_grey_color;
    transparent = _c_transparent_color;

    // Custom / Brand
    facebookLoginButtonColor = _c_facebook_login_color;
    googleLoginButtonColor = _c_google_login_color;
    appleLoginButtonColor = _c_apple_login_color;
    phoneLoginButtonColor = _c_phone_login_color;

    disabledFacebookLoginButtonColor = _c_grey_color;
    disabledGoogleLoginButtonColor = _c_grey_color;
    disabledAppleLoginButtonColor = _c_grey_color;
    disabledPhoneLoginButtonColor = _c_grey_color;


    loadingCircleColor = _c_secondary_400;
    ratingColor = _c_rating_color;
    soldOutUIColor = _c_sold_out; // teal accent
    itemTypeColor = _c_item_type_color;
    paidAdsColor = _c_paid_ads_color;

    categoryBackgroundColor = _l_base_light_color;
    cardBackgroundColor = const Color(0xFFFFFFFF);

    bluemarkColor = _c_secondary_400;
  }
}