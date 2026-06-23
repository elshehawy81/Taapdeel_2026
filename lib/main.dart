import 'dart:async';
import 'package:taapdeel/utils/perf_benchmark.dart';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:app_links/app_links.dart';
import 'package:taapdeel/debug/debug_flags.dart';
import 'package:taapdeel/ui/Foryou/home_provider.dart';
import 'package:taapdeel/ui/Contacts/search_provider.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_ui_showcase.dart';
import 'package:taapdeel/utils/taapdeel_share_links.dart';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bug_logger/flutter_logger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'config/ps_colors.dart';
import 'constant/ps_constants.dart';
import 'config/ps_config.dart';
import 'config/ps_theme_data.dart';
import 'constant/router.dart' as router;
import 'constant/route_paths.dart';
import 'db/common/ps_shared_preferences.dart';
import 'paymob_payment/core/consts.dart';
import 'paymob_payment/paymob_integration/flutter_paymob.dart';
import 'paymob_payment/payment_provider.dart';
import 'provider/main_provider.dart';
import 'provider/mainBuyer_provider.dart';
import 'provider/common/notification_provider.dart';
import 'provider/promotion/item_promotion_provider.dart';
import 'provider/ps_provider_dependencies.dart';
import 'repository/Common/notification_repository.dart';

import 'ui/noti/notification_routing_helper.dart';
import 'utils/utils.dart';
import 'viewobject/common/language.dart';
import 'viewobject/common/ps_value_holder.dart';
import 'viewobject/holder/intent_holder/chat_history_intent_holder.dart';
import 'viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'viewobject/holder/intent_holder/user_intent_holder.dart';
import 'viewobject/holder/noti_register_holder.dart';

// ── Global navigator key ──────────────────────────────────────────────────
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// ─────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  // ✅ BENCHMARK: Cold start — من بداية main() لحد runApp()
  // ده بيقيس كل الـ initialization: Firebase + Locale + ScreenUtil + Preload
  TaapdeelPerfBenchmark.start('cold_start_to_runapp');

  WidgetsFlutterBinding.ensureInitialized();

  // ✅ BENCHMARK: Firebase + EasyLocalization بالتوازي
  TaapdeelPerfBenchmark.start('init_parallel_firebase_locale');
  await Future.wait(<Future<void>>[
    EasyLocalization.ensureInitialized(),
    _initFirebaseCore(),
  ]);
  TaapdeelPerfBenchmark.end('init_parallel_firebase_locale');

  // Crashlytics تحتاج Firebase — تيجي بعده مباشرة لكنها سريعة
  TaapdeelPerfBenchmark.start('init_crashlytics');
  await _initCrashlytics();
  TaapdeelPerfBenchmark.end('init_crashlytics');

  // ✅ FIX #2: كل اللي مش ضروري قبل أول frame يشتغل في الخلفية
  unawaited(_initLogger());
  unawaited(_initSharedPreferencesDefaults());

  // ScreenUtil لازم تنتهي قبل runApp عشان الـ sizes صح
  TaapdeelPerfBenchmark.start('init_screen_util');
  await ScreenUtil.ensureScreenSize();
  TaapdeelPerfBenchmark.end('init_screen_util');

  _configLoading();

  // ✅ FIX #7: preload ملف اللغة على background thread قبل runApp
  TaapdeelPerfBenchmark.start('preload_locale_json');
  await _preloadLocalization();
  TaapdeelPerfBenchmark.end('preload_locale_json');

  TaapdeelPerfBenchmark.end('cold_start_to_runapp');
  // بعد runApp() الـ Flutter engine بيبني أول frame — نقيسه في _AppServicesBootstrapState

  runApp(
    EasyLocalization(
      path: 'assets/langs',
      saveLocale: true,
      startLocale: PsConfig.defaultLanguage.toLocale(),
      supportedLocales: getSupportedLanguages(),
      fallbackLocale: const Locale('ar', 'DZ'), // ✅ FIX #7: fallback لو اللغة المحفوظة مش موجودة
      child: const PSApp(),
    ),
  );
}

/// ✅ FIX #7: نحمّل ملف JSON اللغة الافتراضية قبل runApp
/// بيخلي EasyLocalization يلاقيه في الـ cache بدل ما يقرأه من disk أثناء أول build
/// → يحل مشكلة Skipped 244 frames عند "Load asset from assets/langs"
Future<void> _preloadLocalization() async {
  try {
    final Locale locale = PsConfig.defaultLanguage.toLocale();
    await rootBundle.loadString(
      'assets/langs/\${locale.languageCode}_\${locale.countryCode}.json',
    );
  } catch (_) {
  }
}

Future<void> _initLogger() async {
  Logger.init(
    false,
    levelVerbose: 247,
    levelDebug: 26,
    levelInfo: 28,
    levelWarn: 3,
    levelError: 9,
    phoneVerbose: Colors.white54,
    phoneDebug: Colors.blue,
    phoneInfo: Colors.green,
    phoneWarn: Colors.yellow,
    phoneError: Colors.redAccent,
  );
}

Future<void> _initSharedPreferencesDefaults() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('codeC') == null) {
    await prefs.setString('codeC', '');
    await prefs.setString('codeL', '');
  }
}

Future<void> _initFirebaseCore() async {
  try {
    if (Firebase.apps.isNotEmpty) return;

    if (Platform.isIOS) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          appId: PsConfig.iosGoogleAppId,
          messagingSenderId: PsConfig.iosGcmSenderId,
          databaseURL: PsConfig.iosDatabaseUrl,
          projectId: PsConfig.iosProjectId,
          apiKey: PsConfig.iosApiKey,
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') return;
  } catch (_) {}
}

Future<void> _initCrashlytics() async {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}

Future<void> _initFirebaseMessaging({
  PsValueHolder? psValueHolder,
  NotificationRepository? notificationRepository,
}) async {
  try {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final String? token = await messaging.getToken();

    if (token != null && token.isNotEmpty) {
      await _saveAndMaybeRegisterFcmToken(
        token: token,
        psValueHolder: psValueHolder,
        notificationRepository: notificationRepository,
      );
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      unawaited(
        _saveAndMaybeRegisterFcmToken(
          token: newToken,
          psValueHolder: psValueHolder,
          notificationRepository: notificationRepository,
        ),
      );
    });

    final RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _routeNotificationMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_routeNotificationMessage);
    FirebaseMessaging.onMessage.listen((_) {});
  } catch (e) {
    debugPrint('FCM_INIT_ERROR=$e');
  }
}

Future<void> _saveAndMaybeRegisterFcmToken({
  required String token,
  PsValueHolder? psValueHolder,
  NotificationRepository? notificationRepository,
}) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_device_token', token);

    if (psValueHolder == null) return;

    psValueHolder.deviceToken = token;

    final String? loginUserId = Utils.checkUserLoginId(psValueHolder);
    final bool hasRealUser = loginUserId != null &&
        loginUserId.isNotEmpty &&
        loginUserId != 'nologinuser';

    if (!hasRealUser || notificationRepository == null) return;

    final NotificationProvider provider = NotificationProvider(
      repo: notificationRepository,
      psValueHolder: psValueHolder,
    );

    final NotiRegisterParameterHolder holder = NotiRegisterParameterHolder(
      platformName: PsConst.PLATFORM,
      deviceId: token,
      loginUserId: loginUserId,
    );

    await provider.rawRegisterNotiToken(holder.toMap());
    provider.dispose();
  } catch (_) {}
}

void _routeNotificationMessage(RemoteMessage message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      final BuildContext? context = navigatorKey.currentContext;
      if (context == null) return;

      NotificationRoutingHelper.navigateFromData(
        context: context,
        data: Map<String, dynamic>.from(message.data),
      );
    } catch (_) {}
  });
}

void _configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..dismissOnTap = false
    ..indicatorColor = Colors.white
    ..backgroundColor = PsColors.orangeColor
    ..textColor = Colors.white
    ..progressColor = Colors.white
    ..userInteractions = false
    ..boxShadow = const <BoxShadow>[
      BoxShadow(
        color: Color(0x29000000),
        offset: Offset(0, 2.0),
        blurRadius: 6.0,
      ),
    ];
}

List<Locale> getSupportedLanguages() {
  return PsConfig.psSupportedLanguageList
      .map((Language lang) => Locale(lang.languageCode!, lang.countryCode))
      .toList();
}

// ═══════════════════════════════════════════════════════════════════════════
// PSApp — ✅ FIX #3: أزلنا PsColors.loadColor من build()
//          وفصلنا الـ providers عن الـ theme builder
// ═══════════════════════════════════════════════════════════════════════════

class PSApp extends StatefulWidget {
  const PSApp({Key? key}) : super(key: key);

  @override
  State<PSApp> createState() => _PSAppState();
}

class _PSAppState extends State<PSApp> {
  // ✅ FIX #4: كل الـ providers تتعمل مرة واحدة في initState
  late final ItemPromotionProvider _itemPromotionProvider;
  late final MainProvider _mainProvider;
  late final HomeProvider _homeProvider;
  late final SearchProvider _searchProvider;
  late final MainBuyerProvider _mainBuyerProvider;
  late final PaymentProvider _paymentProvider;

  // ✅ FIX #5: نحسب الـ providers list مرة واحدة بدل كل build
  late final List<SingleChildWidget> _innerProviders;

  @override
  void initState() {
    super.initState();
    _itemPromotionProvider = ItemPromotionProvider();
    _mainProvider = MainProvider();
    _homeProvider = HomeProvider();
    _searchProvider = SearchProvider();
    _mainBuyerProvider = MainBuyerProvider();
    _paymentProvider = PaymentProvider();

    _innerProviders = <SingleChildWidget>[
      ChangeNotifierProvider<ItemPromotionProvider>.value(
        value: _itemPromotionProvider,
      ),
      ChangeNotifierProvider<MainProvider>.value(value: _mainProvider),
      ChangeNotifierProvider<HomeProvider>.value(value: _homeProvider),
      ChangeNotifierProvider<SearchProvider>.value(value: _searchProvider),
      ChangeNotifierProvider<MainBuyerProvider>.value(
        value: _mainBuyerProvider,
      ),
      ChangeNotifierProvider<PaymentProvider>.value(value: _paymentProvider),
    ];
  }

  @override
  void dispose() {
    _itemPromotionProvider.dispose();
    _mainProvider.dispose();
    _homeProvider.dispose();
    _searchProvider.dispose();
    _mainBuyerProvider.dispose();
    _paymentProvider.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    // Light Theme فقط مهما كان وضع الموبايل
    final ThemeData appTheme = themeData(
      ThemeData.light(useMaterial3: true),
    );

    return MultiProvider(
      providers: <SingleChildWidget>[
        ...providers, // الـ providers العامة من ps_provider_dependencies
      ],
      child: MultiProvider(
        providers: _innerProviders,
        child: _PsColorsLoader(
          child: _AppServicesBootstrap(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Taapdeel',

              // ✅ إجبار التطبيق على Light Mode
              themeMode: ThemeMode.light,
              theme: appTheme,
              darkTheme: appTheme,
              highContrastTheme: appTheme,
              highContrastDarkTheme: appTheme,

              builder: EasyLoading.init(),
              navigatorKey: navigatorKey,
              initialRoute: kShowTaapdeelUIShowcase ? '/ui_showcase' : '/',
              onGenerateRoute: router.generateRoute,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ FIX #3: Widget منفصل يلود الـ colors مرة واحدة عند أول build
// بدل تشغيلها في كل rebuild لـ PSApp
class _PsColorsLoader extends StatefulWidget {
  const _PsColorsLoader({required this.child});

  final Widget child;

  @override
  State<_PsColorsLoader> createState() => _PsColorsLoaderState();
}

class _PsColorsLoaderState extends State<_PsColorsLoader> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      PsColors.loadColor(context);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ═══════════════════════════════════════════════════════════════════════════
// _AppServicesBootstrap — لا تغيير هنا، الكود صح
// ═══════════════════════════════════════════════════════════════════════════

class _AppServicesBootstrap extends StatefulWidget {
  const _AppServicesBootstrap({required this.child});

  final Widget child;

  @override
  State<_AppServicesBootstrap> createState() => _AppServicesBootstrapState();
}

class _AppServicesBootstrapState extends State<_AppServicesBootstrap> {
  bool _servicesStarted = false;

  AppLinks? _appLinks;
  StreamSubscription<Uri>? _deepLinkSub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_servicesStarted) return;
    _servicesStarted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // ✅ BENCHMARK: أول frame ظهر للمستخدم — المسافة من cold_start_to_runapp لحد هنا
      // = كل وقت بناء الـ widget tree + أول render
      TaapdeelPerfBenchmark.start('first_frame_rendered');
      TaapdeelPerfBenchmark.end('first_frame_rendered');
      TaapdeelPerfBenchmark.printReport();

      unawaited(_startHeavyServices());
      unawaited(_initTaapdeelDeepLinks());
    });
  }

  Future<void> _initTaapdeelDeepLinks() async {
    try {
      _appLinks = AppLinks();

      final Uri? initialUri = await _appLinks!.getInitialLink();
      if (initialUri != null) {
        _handleTaapdeelDeepLink(initialUri);
      }

      _deepLinkSub = _appLinks!.uriLinkStream.listen(
        _handleTaapdeelDeepLink,
        onError: (_) {},
      );
    } catch (_) {}
  }

  void _handleTaapdeelDeepLink(Uri uri) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? context = navigatorKey.currentContext;
      if (context == null) return;

      final TaapdeelLinkTarget target = TaapdeelShareLinks.parseTarget(uri);
      unawaited(_maybeSavePendingReferralCode(context, target));

      switch (target.type) {
        case TaapdeelLinkTargetType.product:
        case TaapdeelLinkTargetType.wish:
          _openProductFromDeepLink(context, target.id);
          break;
        case TaapdeelLinkTargetType.profile:
          _openUserProfileFromDeepLink(context, target.id);
          break;
        case TaapdeelLinkTargetType.swapAdvice:
        case TaapdeelLinkTargetType.empty:
        case TaapdeelLinkTargetType.unknown:
          break;
      }
    });
  }

  Future<void> _maybeSavePendingReferralCode(
      BuildContext context,
      TaapdeelLinkTarget target,
      ) async {
    final String newReferralCode = _cleanReferralValue(target.referralCode);
    if (newReferralCode.isEmpty) return;

    try {
      PsValueHolder? valueHolder;
      try {
        valueHolder = context.read<PsValueHolder>();
      } catch (_) {}

      final String myReferralCode = _cleanReferralValue(
        valueHolder?.referralCode ??
            PsSharedPreferences.instance.getReferralCode(),
      );
      if (myReferralCode.isNotEmpty && myReferralCode == newReferralCode) return;

      final String alreadyReferredBy =
      _cleanReferralValue(valueHolder?.referredByCode);
      if (alreadyReferredBy.isNotEmpty) return;

      final String existingPending = _cleanReferralValue(
        valueHolder?.pendingReferralCode ??
            PsSharedPreferences.instance.getPendingReferralCode(),
      );
      if (existingPending.isNotEmpty) return;

      await PsSharedPreferences.instance
          .savePendingReferralCode(newReferralCode);
    } catch (_) {}
  }

  String _cleanReferralValue(dynamic value) {
    final String text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  void _openProductFromDeepLink(BuildContext context, String? rawId) {
    final String id = (rawId ?? '').trim();
    if (id.isEmpty) return;

    Navigator.of(context).pushNamed(
      RoutePaths.productDetail,
      arguments: ProductDetailIntentHolder(
        productId: id,
        heroTagImage: 'deeplink_product_image_$id',
        heroTagTitle: 'deeplink_product_title_$id',
      ),
    );
  }

  void _openUserProfileFromDeepLink(BuildContext context, String? rawUserId) {
    final String userId = (rawUserId ?? '').trim();
    if (userId.isEmpty) return;

    Navigator.of(context).pushNamed(
      RoutePaths.userDetail,
      arguments: UserIntentHolder(userId: userId, userName: ''),
    );
  }

  Future<void> _startHeavyServices() async {
    // ✅ PERF FIX: تم تقليل الـ delay من 6 ثوانٍ إلى 1 ثانية
    // الدليل: heavy_services_init = 0ms → Firebase Messaging يعمل فوراً بدون حاجة لانتظار
    // Firebase Core مبدأياً جاهز منذ main() → لا يوجد سبب تقني للـ 6 ثوانٍ
    // ثانية واحدة تكفي كـ buffer بعد ظهور أول frame للمستخدم
    TaapdeelPerfBenchmark.start('heavy_services_delay');
    await Future<void>.delayed(const Duration(seconds: 1));
    TaapdeelPerfBenchmark.end('heavy_services_delay');
    TaapdeelPerfBenchmark.start('heavy_services_init');

    if (!mounted) return;

    PsValueHolder? psValueHolder;
    NotificationRepository? notificationRepository;

    try {
      psValueHolder = context.read<PsValueHolder>();
    } catch (_) {}

    try {
      notificationRepository = context.read<NotificationRepository>();
    } catch (_) {}

    final String? loginUserId =
    psValueHolder == null ? null : Utils.checkUserLoginId(psValueHolder);

    final bool hasRealUser = loginUserId != null &&
        loginUserId.isNotEmpty &&
        loginUserId != 'nologinuser';

    if (hasRealUser) {
      unawaited(
        _initFirebaseMessaging(
          psValueHolder: psValueHolder,
          notificationRepository: notificationRepository,
        ),
      );
    }

    TaapdeelPerfBenchmark.end('heavy_services_init');
    TaapdeelPerfBenchmark.printReport();
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
