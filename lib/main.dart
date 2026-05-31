import 'dart:async';
import 'dart:io';

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
import 'package:theme_manager/theme_manager.dart';

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

// ── Global navigator key — required for FCM deep-link routing ─────────────
// Used by NotificationService.navigatorKey after it is created in lib/ui/noti/
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// ─────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await _initFirebaseCore();
    final ChatHistoryIntentHolder chatData =
    ChatHistoryIntentHolder.fromJson(message.data);
  } catch (e) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await _initFirebaseCore();
  await _initCrashlytics();

  //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  unawaited(_initLogger());
  unawaited(_initSharedPreferencesDefaults());
  unawaited(_initScreenUtil());

  _configLoading();

  runApp(
    EasyLocalization(
      path: 'assets/langs',
      saveLocale: true,
      startLocale: PsConfig.defaultLanguage.toLocale(),
      supportedLocales: getSupportedLanguages(),
      child: const PSApp(),
    ),
  );
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

Future<void> _initScreenUtil() async {
  await ScreenUtil.ensureScreenSize();
}

Future<void> _initPaymob() async {
  try {
    await FlutterPaymob.instance.initialize(
      apiKey: PaymobConsts.apiKey,
      integrationID: PaymobConsts.cardIntegrationId,
      walletIntegrationId: PaymobConsts.walletIntegrationId,
      iFrameID: PaymobConsts.iFrame,
    );
  } catch (e) {}
}

Future<void> _initFirebaseCore() async {
  try {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

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
    if (e.code == 'duplicate-app') {
      return;
    }
  } catch (e) {}
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

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _routeNotificationMessage(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

    });
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

    if (psValueHolder == null) {
      return;
    }

    // Keep old app flows working. phone_register already sends this field.
    psValueHolder.deviceToken = token;

    final String? loginUserId = Utils.checkUserLoginId(psValueHolder);
    final bool hasRealUser = loginUserId != null &&
        loginUserId.isNotEmpty &&
        loginUserId != 'nologinuser';

    if (!hasRealUser) {
      return;
    }

    if (notificationRepository == null) {
      return;
    }

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
  } catch (e) {}
}

void _routeNotificationMessage(RemoteMessage message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      final BuildContext? context = navigatorKey.currentContext;
      if (context == null) {
        return;
      }

      NotificationRoutingHelper.navigateFromData(
        context: context,
        data: Map<String, dynamic>.from(message.data),
      );
    } catch (e) {}
  });
}

Future<void> _initMobileAds() async {
  await MobileAds.instance.initialize();
}

Future<void> _checkAppleSignIn() async {
  await Utils.checkAppleSignInAvailable();
}

Future<void> _initCameras() async {
  try {
    Utils.cameras = await availableCameras();
  } catch (e) {}
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
  final List<Locale> localeList = <Locale>[];
  for (final Language lang in PsConfig.psSupportedLanguageList) {
    localeList.add(Locale(lang.languageCode!, lang.countryCode));
  }
  return localeList;
}

class PSApp extends StatefulWidget {
  const PSApp({Key? key});

  @override
  State<PSApp> createState() => _PSAppState();
}

class _PSAppState extends State<PSApp> {
  late final ItemPromotionProvider _itemPromotionProvider;
  late final MainProvider _mainProvider;
  late final HomeProvider _homeProvider;
  late final SearchProvider _searchProvider;
  late final MainBuyerProvider _mainBuyerProvider;
  late final PaymentProvider _paymentProvider;

  @override
  void initState() {
    super.initState();
    _itemPromotionProvider = ItemPromotionProvider();
    _mainProvider = MainProvider();
    _homeProvider = HomeProvider();
    _searchProvider = SearchProvider();
    _mainBuyerProvider = MainBuyerProvider();
    _paymentProvider = PaymentProvider();
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
  Widget build(BuildContext context) {
    PsColors.loadColor(context);

    return MultiProvider(
      providers: <SingleChildWidget>[
        ...providers,
      ],
      child: ThemeManager(
        defaultBrightnessPreference: BrightnessPreference.system,
        data: (Brightness brightness) {
          final ThemeData baseTheme =
          brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();
          return themeData(baseTheme);
        },
        themedWidgetBuilder: (BuildContext context, ThemeData theme) {
          return MultiProvider(
            providers: <SingleChildWidget>[
              ChangeNotifierProvider<ItemPromotionProvider>.value(
                value: _itemPromotionProvider,
              ),
              ChangeNotifierProvider<MainProvider>.value(
                value: _mainProvider,
              ),
              ChangeNotifierProvider<HomeProvider>.value(
                value: _homeProvider,
              ),
              ChangeNotifierProvider<SearchProvider>.value(
                value: _searchProvider,
              ),
              ChangeNotifierProvider<MainBuyerProvider>.value(
                value: _mainBuyerProvider,
              ),
              ChangeNotifierProvider<PaymentProvider>.value(
                value: _paymentProvider,
              ),
            ],
            child: _AppServicesBootstrap(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Taapdeel',
                theme: theme,
                builder: EasyLoading.init(),
                navigatorKey: navigatorKey, // ← FCM + App Links deep-link routing
                initialRoute: kShowTaapdeelUIShowcase ? '/ui_showcase' : '/',
                onGenerateRoute: router.generateRoute,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
              ),
            ),
          );
        },
      ),
    );
  }
}

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

    // This widget is intentionally placed BELOW the root MultiProvider, so this
    // context can safely read PsValueHolder and NotificationRepository.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_startHeavyServices());
      unawaited(_initTaapdeelDeepLinks());
    });
  }

  Future<void> _initTaapdeelDeepLinks() async {
    try {
      _appLinks = AppLinks();

      // Cold start: user opened the app from a Taapdeel link while it was closed.
      final Uri? initialUri = await _appLinks!.getInitialLink();
      if (initialUri != null) {
        _handleTaapdeelDeepLink(initialUri);
      }

      // Warm start: user opened a Taapdeel link while the app was already alive.
      _deepLinkSub = _appLinks!.uriLinkStream.listen(
            (Uri uri) {
          _handleTaapdeelDeepLink(uri);
        },
        onError: (Object error) {},
      );
    } catch (_) {}
  }

  void _handleTaapdeelDeepLink(Uri uri) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? context = navigatorKey.currentContext;
      if (context == null) return;

      final TaapdeelLinkTarget target = TaapdeelShareLinks.parseTarget(uri);

      // First-touch referral attribution:
      // If the opened link contains ?ref=..., keep it only if the user has not
      // already been attributed and no pending referral exists on this device.
      unawaited(_maybeSavePendingReferralCode(context, target));

      switch (target.type) {
        case TaapdeelLinkTargetType.product:
          _openProductFromDeepLink(context, target.id);
          break;

        case TaapdeelLinkTargetType.wish:
        // Wish/Hawadeet items are Product-like records in the app flow,
        // so they currently open through the same ProductDetail route.
          _openProductFromDeepLink(context, target.id);
          break;

        case TaapdeelLinkTargetType.profile:
        // Current router expects UserIntentHolder for userDetail.
        // ProfileRoutePage needs ProfileRouteArgs, so userDetail is safer
        // until we wire a typed profile-gallery deep link route.
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
        valueHolder?.referralCode ?? PsSharedPreferences.instance.getReferralCode(),
      );

      // Prevent self-referral.
      if (myReferralCode.isNotEmpty && myReferralCode == newReferralCode) {
        return;
      }

      final String alreadyReferredBy = _cleanReferralValue(
        valueHolder?.referredByCode,
      );

      // If the logged-in/current user is already attributed, do not overwrite.
      if (alreadyReferredBy.isNotEmpty) {
        return;
      }

      final String existingPending = _cleanReferralValue(
        valueHolder?.pendingReferralCode ??
            PsSharedPreferences.instance.getPendingReferralCode(),
      );

      // First-touch wins: do not replace an existing pending referral.
      if (existingPending.isNotEmpty) {
        return;
      }

      await PsSharedPreferences.instance.savePendingReferralCode(newReferralCode);
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
      arguments: UserIntentHolder(
        userId: userId,
        userName: '',
      ),
    );
  }

  Future<void> _startHeavyServices() async {
    // اترك أول شاشة تظهر وتستقر
    await Future<void>.delayed(const Duration(seconds: 6));

    if (!mounted) return;

    PsValueHolder? psValueHolder;
    NotificationRepository? notificationRepository;

    try {
      psValueHolder = context.read<PsValueHolder>();
    } catch (e) {}

    try {
      notificationRepository = context.read<NotificationRepository>();
    } catch (e) {}

    final String? loginUserId =
    psValueHolder == null ? null : Utils.checkUserLoginId(psValueHolder);

    final bool hasRealUser = loginUserId != null &&
        loginUserId.isNotEmpty &&
        loginUserId != 'nologinuser';

    // لا تشغل FCM token/listeners للمستخدم guest في بداية التطبيق
    if (hasRealUser) {
      unawaited(
        _initFirebaseMessaging(
          psValueHolder: psValueHolder,
          notificationRepository: notificationRepository,
        ),
      );
    }

    // مش ضروري في cold start إلا لو أنت محتاجه فعلًا
    // unawaited(_checkAppleSignIn());
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
