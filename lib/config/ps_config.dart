import 'package:taapdeel/viewobject/common/language.dart';

/// Global app configuration.
/// --------------------------------------------------
/// IMPORTANT:
/// - Values here are used by backend, Firebase, and other services.
/// - Do NOT change them production
/// - Use `// Future Improvement:` comments to track ideas for later.
///
class PsConfig {
  PsConfig._();

  // --------------------------------------------------
  // App Version
  // --------------------------------------------------

  /// App version shown in the app.
  /// Future Improvement: Sync this with pubspec.yaml automatically (CI step).
  static const String app_version = '1.0';

  // --------------------------------------------------
  // API Key & Base URLs
  // --------------------------------------------------

  /// API key used to authenticate with the backend.
  ///
  /// Production vs Testing:
  /// - Production (commented in original):
  /// - Testing (currently used):
  static const String ps_api_key = 'teampsisthebest1';

  /// Backend base URL.
  ///
  /// Future Improvement: Move this to environment-based config
  /// (dev / staging / prod) instead of hardcoding.
   //static const String ps_core_url = 'http://10.0.2.2/taapdeel';
  //static const String ps_core_url = 'http://192.168.1.7/taapdeel';
  static const String ps_core_url = 'https://taapdeel.com';
  /// API base URL (PHP endpoint root).
  static const String ps_app_url = ps_core_url + '/index.php/';

  /// Base URL for uploaded images.
  static const String ps_app_image_url = ps_core_url + '/uploads/';

  /// Thumbnail image URLs.
  static const String ps_app_image_thumbs_url =
      ps_core_url + '/uploads/thumbnail/';
  /*static const String ps_app_image_thumbs_2x_url =
      ps_core_url + '/uploads/thumbnail2x/';
  static const String ps_app_image_thumbs_3x_url =
      ps_core_url + '/uploads/thumbnail3x/';*/
  static const String ps_app_image_thumbs_2x_url = ps_app_image_thumbs_url;
  static const String ps_app_image_thumbs_3x_url = ps_app_image_thumbs_url;
  // Future Improvement: Consider centralizing image URL building
  // in a helper class instead of concatenating strings everywhere.

  // --------------------------------------------------
  // Store URLs (commented for now)
  // --------------------------------------------------
  // static const String GOOGLE_PLAY_STORE_URL =
  //     'https://play.google.com/store/apps';
  //
  // static const String APPLE_APP_STORE_URL =
  //     'https://www.apple.com/app-store';

  // --------------------------------------------------
  // Firebase / Chat Settings
  // --------------------------------------------------

  /// iOS Firebase configuration.
  static const String iosGoogleAppId =
      '1:100595475287:ios:f639604e4ed072fd4fd412';
  static const String iosGcmSenderId = '502301723301';
  static const String iosProjectId = 'Taapdeel';
  static const String iosDatabaseUrl =
      'https://tapdeal2024-default-rtdb.firebaseio.com';
  static const String iosApiKey = 'AIzaSyAp5-64h6jgjdggATIog22niMgTKpIeJaE';

  /// Android Firebase configuration.
  /// Android Firebase configuration.
  static const String androidGoogleAppId =
      '1:464009555844:android:8d1331be3a06b88bb0b7d1';

  static const String androidGcmSenderId = '464009555844';

  static const String androidProjectId = 'taapdeel-2026';

  static const String androidApiKey =
      'AIzaSyCX7w4AdTQ13zp7K7w3jJAdHxBoNbnjWrs';

  static const String androidDatabaseUrl =
      'https://tapdeal2024-default-rtdb.firebaseio.com';

  // Future Improvement: Move secrets (API keys, App IDs) to a secure
  // config mechanism or environment variables, not in source code.

  // --------------------------------------------------
  // Facebook Config (currently disabled)
  // --------------------------------------------------
  // static const String fbKey = '3014689782122267';
  // static const String fbKey = '000000000000000';



  // --------------------------------------------------
  // Demo / Feature Flags
  // --------------------------------------------------

  /// When true, app may use demo behaviors / sample data.
  static bool isDemo = false;

  // ////showloginuifirst
  // static bool isShowLoginFirst = true;

  // ////showlanguageuifirst
  // static bool isShowLanguageFirst = true;

  // --------------------------------------------------
  // iOS App Store ID (currently commented)
  // --------------------------------------------------
  // static const String iOSAppStoreId = '000000000';
  // static const String iOSAppStoreId = '789135275';

  // --------------------------------------------------
  // Animation
  // --------------------------------------------------

  /// Global default animation duration for transitions, etc.
  static const Duration animation_duration = Duration(milliseconds: 500);

  // --------------------------------------------------
  // Fonts
  // --------------------------------------------------

  /// Default font family used in the app.
  ///
  /// Steps to change:
  /// 1) Add font under assets/fonts/
  /// 2) Declare it in pubspec.yaml
  /// 3) Update this value with the new font family name.
  static const String ps_default_font_family = 'Cairo';

  // --------------------------------------------------
  // Local Database
  // --------------------------------------------------

  /// SQLite database file name.
  static const String ps_app_db_name = 'ps_db.db';

  // --------------------------------------------------
  // Language Configuration
  // --------------------------------------------------

  /// Default language for the app.
  ///
  /// Current: Arabic (Algeria).
  /// Future Improvement: Make this configurable from server or first-launch UI.
  static final Language defaultLanguage =
  // Language(languageCode: 'en', countryCode: 'US', name: 'English US');
  Language(languageCode: 'ar', countryCode: 'DZ', name: 'Arabic');


  /// List of supported languages.
  ///
  /// To enable more, uncomment / add corresponding entries.
  static final List<Language> psSupportedLanguageList = <Language>[
    Language(languageCode: 'en', countryCode: 'US', name: 'English'),
    Language(languageCode: 'ar', countryCode: 'DZ', name: 'Arabic'),
    // Language(languageCode: 'hi', countryCode: 'IN', name: 'Hindi'),
    // Language(languageCode: 'de', countryCode: 'DE', name: 'German'),
    // Language(languageCode: 'es', countryCode: 'ES', name: 'Spanish'),
    // Language(languageCode: 'fr', countryCode: 'FR', name: 'French'),
    // Language(languageCode: 'id', countryCode: 'ID', name: 'Indonesian'),
    // Language(languageCode: 'it', countryCode: 'IT', name: 'Italian'),
    // Language(languageCode: 'ja', countryCode: 'JP', name: 'Japanese'),
    // Language(languageCode: 'ko', countryCode: 'KR', name: 'Korean'),
    // Language(languageCode: 'ms', countryCode: 'MY', name: 'Malay'),
    // Language(languageCode: 'pt', countryCode: 'PT', name: 'Portuguese'),
    // Language(languageCode: 'ru', countryCode: 'RU', name: 'Russian'),
    // Language(languageCode: 'th', countryCode: 'TH', name: 'Thai'),
    // Language(languageCode: 'tr', countryCode: 'TR', name: 'Turkish'),
    // Language(languageCode: 'zh', countryCode: 'CN', name: 'Chinese'),
  ];

  // --------------------------------------------------
  // Formatting (Price / Date)
  // --------------------------------------------------
  // Examples:
  // ",##0.00"   => 2,555.00
  // "##0.00"    => 2555.00
  // ".00"       => 2555.00
  // ",##0"      => 2555
  // ",##0.0"    => 2555.0
  //
  // static const String priceFormat = ',##0.00';
  //
  // static const String dateFormat = 'dd MMM yyyy';

  // --------------------------------------------------
  // Temporary Image Folder
  // --------------------------------------------------

  /// Folder name for temporary images.
  static const String tmpImageFolderName = 'tapdealImg';

// Future Improvement: Consider renaming this in a future version
// with a migration step if you want it consistent with "Taapdeel".

// --------------------------------------------------
// Image Loading Behavior (commented configs)
// --------------------------------------------------
// - If "true": load thumbnail first then full image.
// - If "false": load full image directly with default placeholder.
//
// static const bool USE_THUMBNAIL_AS_PLACEHOLDER = false;

// --------------------------------------------------
// Token / Debug Visibility (commented configs)
// --------------------------------------------------
// static const bool isShowTokenId = true;
// static const bool isShowSubCategory = true;

// --------------------------------------------------
// Map / Google Maps (commented configs)
// --------------------------------------------------

// --------------------------------------------------
// Promote Item (commented configs)
// --------------------------------------------------
// static const String PROMOTE_FIRST_CHOICE_DAY_OR_DEFAULT_DAY = '7 ';
// static const String PROMOTE_SECOND_CHOICE_DAY = '14 ';
// static const String PROMOTE_THIRD_CHOICE_DAY = '30 ';
// static const String PROMOTE_FOURTH_CHOICE_DAY = '60 ';

// --------------------------------------------------
// Image Size (commented configs)
// --------------------------------------------------
// static const int uploadImageSize = 1024;
// static const int profileImageSize = 512;
// static const int chatImageSize = 650;

// --------------------------------------------------
// Blue Mark Size (commented configs)
// --------------------------------------------------
// static const double blueMarkSize = 15;

// --------------------------------------------------
// Default Loading Limits (commented configs)
// --------------------------------------------------
// static const int DEFAULT_LOADING_LIMIT = 30;
// static const int CATEGORY_LOADING_LIMIT = 30;
// static const int RECENT_ITEM_LOADING_LIMIT = 30;
// static const int POPULAR_ITEM_LOADING_LIMIT = 30;
// static const int DISCOUNT_ITEM_LOADING_LIMIT = 30;
// static const int FEATURE_ITEM_LOADING_LIMIT = 30;
// static const int BLOCK_SLIDER_LOADING_LIMIT = 30;
// static const int FOLLOWER_ITEM_LOADING_LIMIT = 30;
// static const int BLOCK_ITEM_LOADING_LIMIT = 30;

// --------------------------------------------------
// Login Methods Visibility (commented configs)
// --------------------------------------------------
// static bool showFacebookLogin = true;
// static bool showGoogleLogin = true;
// static bool showPhoneLogin = true;

// --------------------------------------------------
// Map Filter Settings (commented configs)
// --------------------------------------------------
// static bool noFilterWithLocationOnMap = false;


// --------------------------------------------------
// Video Settings (commented configs)
// --------------------------------------------------
// static const double videoDuration = 60000; // millisecond
// static bool showVideo = true; // show or hide video

// --------------------------------------------------
// Default Distance / Mile (commented configs)
// --------------------------------------------------
// static String mile = '8';

// --------------------------------------------------
// Owner Info (commented configs)
// --------------------------------------------------
// static bool isShowOnwnerInfo = true;

// --------------------------------------------------
// RazorPay Currency (commented configs)
// --------------------------------------------------
// static bool isRazorSupportMultiCurrency = false;
// static String defaultRazorCurrency = 'INR'; // Don't change without API check

}
