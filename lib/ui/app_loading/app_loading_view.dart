import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/app_info/app_info_provider.dart';
import 'package:taapdeel/provider/clear_all/clear_all_data_provider.dart';
import 'package:taapdeel/provider/language/language_provider.dart';
import 'package:taapdeel/repository/app_info_repository.dart';
import 'package:taapdeel/repository/clear_all_data_repository.dart';
import 'package:taapdeel/repository/language_repository.dart';
import 'package:taapdeel/ui/category/default_interests_bootstrapper.dart';
import 'package:taapdeel/ui/common/dialog/version_update_dialog.dart';
import 'package:taapdeel/ui/common/dialog/warning_dialog_view.dart';
import 'package:taapdeel/ui/common/ps_square_progress_widget.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';
import 'package:taapdeel/utils/perf_benchmark.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/app_info_parameter_holder.dart';
import 'package:taapdeel/viewobject/ps_app_info.dart';

class AppLoadingView extends StatefulWidget {
  const AppLoadingView({Key? key}) : super(key: key);

  @override
  State<AppLoadingView> createState() => _AppLoadingViewState();
}

class _AppLoadingViewState extends State<AppLoadingView> {
  static const String _profileSetupRoute = RoutePaths.singleIntro;

  bool _didInit = false;

  // PERF: لا نترك شاشة البداية تنتظر طويلاً بسبب network probe أو API بطيء.
  static const Duration _internetCheckTimeout = Duration(milliseconds: 200);
  static const Duration _appInfoTimeout = Duration(milliseconds: 250);

  bool _isProfileSetupComplete(
    PsValueHolder valueHolder,
    bool isSubLocationEnabled,
  ) {
    final String? locId = valueHolder.locationId;
    final String? townId = valueHolder.locationTownshipId;

    final bool hasLocation = locId != null && locId.isNotEmpty;
    final bool hasTownship =
        !isSubLocationEnabled || (townId != null && townId.isNotEmpty);

    String gender = '';
    String age = '';
    try {
      gender = ((valueHolder as dynamic).userGender as String?) ?? '';
      age = ((valueHolder as dynamic).userAgeRange as String?) ?? '';
    } catch (_) {
      gender = '';
      age = '';
    }

    return hasLocation && hasTownship && gender.isNotEmpty && age.isNotEmpty;
  }

  bool _isRealLoginUser(PsValueHolder valueHolder) {
    final String userId =
        (Utils.checkUserLoginId(valueHolder) ?? '').trim().toLowerCase();
    return userId.isNotEmpty &&
        userId != 'null' &&
        userId != '0' &&
        userId != 'nologinuser' &&
        userId != 'no_login_user';
  }

  void _startDefaultInterestsBootstrapIfNeeded(
    BuildContext context,
    PsValueHolder valueHolder,
  ) {
    if (!_isRealLoginUser(valueHolder)) return;

    // PERF: لا نوقف Splash على تحميل/مزامنة الاهتمامات الافتراضية.
    // آخر لوج أظهر splash_interests_bootstrap ≈ 5.8s لأنه كان await هنا.
    // نشغلها non-blocking بعد دخول Home حتى لا تؤخر أول شاشة.
    unawaited(
      Future<void>(() async {
        await Future<void>.delayed(const Duration(seconds: 5));
        if (!context.mounted) return;

        TaapdeelPerfBenchmark.start('interests_bootstrap_bg');
        try {
          await DefaultInterestsBootstrapper.ensureDefaultInterests(
            context: context,
            valueHolder: valueHolder,
            force: false,
            syncToServerIfLoggedIn: true,
            source: 'app_loading_bg',
          ).timeout(const Duration(seconds: 2));
        } catch (_) {
          // Background-only fallback. Splash/Home must not wait for this.
        } finally {
          TaapdeelPerfBenchmark.end('interests_bootstrap_bg');
        }
      }),
    );
  }

  Future<void> _goNextAfterLoading(
    BuildContext context,
    AppInfoProvider appInfoProvider,
  ) async {
    if (!context.mounted) {
      TaapdeelPerfBenchmark.end('splash_total');
      return;
    }

    final PsValueHolder valueHolder =
        Provider.of<PsValueHolder>(context, listen: false);

    final bool complete = _isProfileSetupComplete(
      valueHolder,
      appInfoProvider.isSubLocation,
    );

    if (!complete) {
      TaapdeelPerfBenchmark.end('splash_total');
      TaapdeelPerfBenchmark.printReport();
      Navigator.pushReplacementNamed(context, _profileSetupRoute);
      return;
    }

    _startDefaultInterestsBootstrapIfNeeded(context, valueHolder);

    if (!context.mounted) {
      TaapdeelPerfBenchmark.end('splash_total');
      return;
    }

    TaapdeelPerfBenchmark.end('splash_total');
    TaapdeelPerfBenchmark.printReport();
    Navigator.pushReplacementNamed(context, RoutePaths.home);
  }

  Future<void> callDateFunction(
    AppInfoProvider provider,
    ClearAllDataProvider? clearAllDataProvider,
    LanguageProvider languageProvider,
    BuildContext context,
  ) async {
    TaapdeelPerfBenchmark.start('splash_total');

    String? realStartDate = '0';
    String realEndDate = '0';

    TaapdeelPerfBenchmark.start('splash_internet_check');
    final bool hasInternet = await Utils.checkInternetConnectivity().timeout(
      _internetCheckTimeout,
      onTimeout: () => false,
    );
    TaapdeelPerfBenchmark.end('splash_internet_check');

    if (!context.mounted) {
      return;
    }

    if (!hasInternet) {
      await _goNextAfterLoading(context, provider);
      return;
    }

    if (provider.psValueHolder == null ||
        provider.psValueHolder!.startDate == null) {
      realStartDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    } else {
      realStartDate = provider.psValueHolder!.endDate;
    }

    realEndDate = DateFormat('yyyy-MM-dd hh:mm:ss', 'en_US').format(
      DateTime.now(),
    );

    final AppInfoParameterHolder appInfoParameterHolder =
        AppInfoParameterHolder(
      startDate: realStartDate,
      endDate: realEndDate,
      userId: Utils.checkUserLoginId(provider.psValueHolder!),
    );

    PsResource<PSAppInfo>? psAppInfo;

    TaapdeelPerfBenchmark.start('splash_appinfo_api');
    try {
      psAppInfo = await provider
          .loadDeleteHistory(appInfoParameterHolder.toMap())
          .timeout(_appInfoTimeout);
    } catch (_) {
      psAppInfo = null;
    }
    TaapdeelPerfBenchmark.end('splash_appinfo_api');

    if (!context.mounted) {
      return;
    }

    if (psAppInfo == null ||
        psAppInfo.status != PsStatus.SUCCESS ||
        psAppInfo.data == null) {
      await _goNextAfterLoading(context, provider);
      return;
    }

    final PSAppInfo appInfo = psAppInfo.data!;

    if (appInfo.packageInAppPurchaseKeyInAndroid != null ||
        appInfo.packageInAppPurchaseKeyInIOS != null) {
      await provider.replacePackageIAPKeys(
        appInfo.packageInAppPurchaseKeyInAndroid ?? '',
        appInfo.packageInAppPurchaseKeyInIOS ?? '',
      );
    }

    await provider.replaceDate(realStartDate!, realEndDate);

    if (!context.mounted) {
      return;
    }

    if (appInfo.userInfo?.userStatus == PsConst.USER_BANNED) {
      await callLogout(
        provider,
        PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
        context,
      );

      if (!context.mounted) {
        return;
      }

      showDialog<dynamic>(
        context: context,
        builder: (BuildContext dialogContext) {
          return WarningDialog(
            message: Utils.getString(dialogContext, 'user_status__banned'),
            onPressed: () {
              checkVersionNumber(
                dialogContext,
                appInfo,
                provider,
                clearAllDataProvider,
              );
            },
          );
        },
      );
      return;
    }

    if (appInfo.userInfo?.userStatus == PsConst.USER_DELECTED) {
      await callLogout(
        provider,
        PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
        context,
      );

      if (!context.mounted) {
        return;
      }

      _goNextAfterLoading(context, provider);
      return;
    }

    if (appInfo.userInfo?.userStatus == PsConst.USER_UN_PUBLISHED) {
      await callLogout(
        provider,
        PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
        context,
      );

      if (!context.mounted) {
        return;
      }

      showDialog<dynamic>(
        context: context,
        builder: (BuildContext dialogContext) {
          return WarningDialog(
            message: Utils.getString(dialogContext, 'user_status__unpublished'),
            onPressed: () {
              checkVersionNumber(
                dialogContext,
                appInfo,
                provider,
                clearAllDataProvider,
              );
            },
          );
        },
      );
      return;
    }

    checkVersionNumber(context, appInfo, provider, clearAllDataProvider);
  }

  Future<void> callLogout(
    AppInfoProvider appInfoProvider,
    int index,
    BuildContext context,
  ) async {
    await appInfoProvider.replaceLoginUserId('');
    await appInfoProvider.replaceLoginUserName('');
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  final Widget _imageWidget = SizedBox(
    width: 300,
    height: 240,
    child: Image.asset('assets/images/Taapdeel_logo.png'),
  );

  Future<void> checkVersionNumber(
    BuildContext context,
    PSAppInfo psAppInfo,
    AppInfoProvider appInfoProvider,
    ClearAllDataProvider? clearAllDataProvider,
  ) async {
    if (!context.mounted) {
      return;
    }

    if (PsConfig.app_version != psAppInfo.psAppVersion!.versionNo) {
      if (psAppInfo.psAppVersion!.versionNeedClearData == PsConst.ONE) {
        await clearAllDataProvider?.clearAllData();

        if (!context.mounted) {
          return;
        }

        checkForceUpdate(context, psAppInfo, appInfoProvider);
      } else {
        checkForceUpdate(context, psAppInfo, appInfoProvider);
      }
    } else {
      await appInfoProvider.replaceVersionForceUpdateData(false);

      if (!context.mounted) {
        return;
      }

      _goNextAfterLoading(context, appInfoProvider);
    }
  }

  Future<void> checkForceUpdate(
    BuildContext context,
    PSAppInfo psAppInfo,
    AppInfoProvider appInfoProvider,
  ) async {
    if (!context.mounted) {
      return;
    }

    if (psAppInfo.psAppVersion!.versionForceUpdate == PsConst.ONE) {
      await appInfoProvider.replaceAppInfoData(
        psAppInfo.psAppVersion!.versionNo!,
        true,
        psAppInfo.psAppVersion!.versionTitle!,
        psAppInfo.psAppVersion!.versionMessage!,
      );

      if (!context.mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        RoutePaths.force_update,
        arguments: psAppInfo.psAppVersion,
      );
    } else if (psAppInfo.psAppVersion!.versionForceUpdate == PsConst.ZERO) {
      await appInfoProvider.replaceVersionForceUpdateData(false);

      if (!context.mounted) {
        return;
      }

      callVersionUpdateDialog(context, psAppInfo, appInfoProvider);
    } else {
      _goNextAfterLoading(context, appInfoProvider);
    }
  }

  void callVersionUpdateDialog(
    BuildContext context,
    PSAppInfo psAppInfo,
    AppInfoProvider appInfoProvider,
  ) {
    if (!context.mounted) {
      return;
    }

    showDialog<dynamic>(
      barrierDismissible: false,
      useRootNavigator: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return VersionUpdateDialog(
          title: psAppInfo.psAppVersion!.versionTitle,
          description: psAppInfo.psAppVersion!.versionMessage,
          leftButtonText: Utils.getString(
            dialogContext,
            'app_info__cancel_button_name',
          ),
          rightButtonText: Utils.getString(
            dialogContext,
            'app_info__update_button_name',
          ),
          onCancelTap: () => _goNextAfterLoading(
            dialogContext,
            appInfoProvider,
          ),
          onUpdateTap: () async {
            final PsValueHolder valueHolder =
                Provider.of<PsValueHolder>(dialogContext, listen: false);

            _goNextAfterLoading(dialogContext, appInfoProvider);

            if (Platform.isIOS) {
              Utils.launchAppStoreURL(iOSAppId: valueHolder.iosAppStoreId);
            } else if (Platform.isAndroid) {
              Utils.launchURL();
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingBody(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PsDimens.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: PsDimens.space16),
            _imageWidget,
            Text(
              Utils.getString(context, 'app_name'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: isLight
                        ? PsColors.primary800
                        : PsColors.primaryDarkWhite,
                  ),
              textAlign: TextAlign.center,
            ),
            const Padding(
              padding: EdgeInsets.all(PsDimens.space16),
              child: PsSquareProgressWidget(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    PsColors.loadColor(context);

    final AppInfoRepository repo1 = Provider.of<AppInfoRepository>(context);
    final ClearAllDataRepository clearAllDataRepository =
        Provider.of<ClearAllDataRepository>(context);
    final LanguageRepository languageRepository =
        Provider.of<LanguageRepository>(context);

    final PsValueHolder? valueHolder = Provider.of<PsValueHolder?>(context);
    if (valueHolder == null) {
      return TaapdeelScaffold(
        safeTop: true,
        safeBottom: true,
        padding: EdgeInsets.zero,
        body: _buildLoadingBody(context),
      );
    }

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ClearAllDataProvider?>(
          lazy: false,
          create: (_) => ClearAllDataProvider(
            repo: clearAllDataRepository,
            psValueHolder: valueHolder,
          ),
        ),
        ChangeNotifierProvider<LanguageProvider>(
          lazy: false,
          create: (_) => LanguageProvider(repo: languageRepository),
        ),
        ChangeNotifierProvider<AppInfoProvider>(
          lazy: false,
          create: (_) => AppInfoProvider(
            repo: repo1,
            psValueHolder: valueHolder,
          ),
        ),
      ],
      child: Builder(
        builder: (BuildContext innerContext) {
          final AppInfoProvider appInfoProvider =
              Provider.of<AppInfoProvider>(innerContext, listen: false);
          final ClearAllDataProvider? clearAllProvider =
              Provider.of<ClearAllDataProvider?>(innerContext, listen: false);
          final LanguageProvider langProvider =
              Provider.of<LanguageProvider>(innerContext, listen: false);

          if (!_didInit) {
            _didInit = true;

            // PERF: ابدأ فحص الـ splash بعد أول frame، حتى لا يزاحم أول رسم للشاشة.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }

              unawaited(
                callDateFunction(
                  appInfoProvider,
                  clearAllProvider,
                  langProvider,
                  innerContext,
                ),
              );
            });
          }

          return TaapdeelScaffold(
            safeTop: true,
            safeBottom: true,
            padding: EdgeInsets.zero,
            body: _buildLoadingBody(innerContext),
          );
        },
      ),
    );
  }
}
