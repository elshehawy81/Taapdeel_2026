import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
import 'package:taapdeel/ui/common/dialog/version_update_dialog.dart';
import 'package:taapdeel/ui/common/dialog/warning_dialog_view.dart';
import 'package:taapdeel/ui/common/ps_square_progress_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/language.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/app_info_parameter_holder.dart';
import 'package:taapdeel/viewobject/ps_app_info.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// ✅ Taapdeel shared scaffold background
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

class AppLoadingView extends StatelessWidget {
  AppLoadingView({Key? key}) : super(key: key);

  /// ✅ Route بتاع Profile Setup
  static const String _profileSetupRoute = RoutePaths.taapdeelProfileSetup;

  /// ✅ Guard عشان callDateFunction ما تتناديش كل rebuild
  static bool _didInit = false;

  /// =========================
  /// ✅ Check if user finished profile setup
  /// (gender + age + locationId + townshipId)
  /// =========================
  bool _isProfileSetupComplete(
      PsValueHolder valueHolder,
      bool isSubLocationEnabled,
      ) {
    final String? locId = valueHolder.locationId;
    final String? townId = valueHolder.locationTownshipId;

    final bool hasLocation = (locId != null && locId.isNotEmpty);
    final bool hasTownship = (townId != null && townId.isNotEmpty);

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

  void _goNextAfterLoading(
      BuildContext context,
      AppInfoProvider appInfoProvider,
      ) {
    final PsValueHolder valueHolder =
    Provider.of<PsValueHolder>(context, listen: false);

    // 1) Force login
    if (valueHolder.isForceLogin == true &&
        Utils.checkUserLoginId(valueHolder) == 'nologinuser') {
      Navigator.pushReplacementNamed(context, RoutePaths.login_container);
      return;
    }

    // 2) Profile setup
    final bool complete = _isProfileSetupComplete(
      valueHolder,
      appInfoProvider.isSubLocation,
    );

    if (!complete) {
      Navigator.pushReplacementNamed(context, _profileSetupRoute);
      return;
    }

    // 3) Categories onboarding
    if (valueHolder.hasFavCategories != true) {
      Navigator.pushReplacementNamed(
        context,
        RoutePaths.CategoryView,
        arguments: <String, dynamic>{
          'onTap': null,
          'onBoarding': true,
          'Discover': false,
        },
      );
      return;
    }

    // 4) Home
    Navigator.pushReplacementNamed(context, RoutePaths.home);
  }

  Future<dynamic> callDateFunction(
      AppInfoProvider provider,
      ClearAllDataProvider? clearAllDataProvider,
      LanguageProvider languageProvider,
      BuildContext context,
      ) async {
    String? realStartDate = '0';
    String realEndDate = '0';

    if (await Utils.checkInternetConnectivity()) {
      if (provider.psValueHolder == null ||
          provider.psValueHolder!.startDate == null) {
        realStartDate =
            DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
      } else {
        realStartDate = provider.psValueHolder!.endDate;
      }

      realEndDate =
          DateFormat('yyyy-MM-dd hh:mm:ss', 'en_US').format(DateTime.now());

      final AppInfoParameterHolder appInfoParameterHolder =
      AppInfoParameterHolder(
        startDate: realStartDate,
        endDate: realEndDate,
        userId: Utils.checkUserLoginId(provider.psValueHolder!),
      );

      final PsResource<PSAppInfo> psAppInfo =
      await provider.loadDeleteHistory(appInfoParameterHolder.toMap());

      if (psAppInfo.status == PsStatus.SUCCESS) {
        if (psAppInfo.data != null &&
            (psAppInfo.data!.packageInAppPurchaseKeyInAndroid != null ||
                psAppInfo.data!.packageInAppPurchaseKeyInIOS != null)) {
          await provider.replacePackageIAPKeys(
            psAppInfo.data!.packageInAppPurchaseKeyInAndroid ?? '',
            psAppInfo.data!.packageInAppPurchaseKeyInIOS ?? '',
          );
        }

        if (psAppInfo.data!.appSetting!.isSubLocation != null &&
            psAppInfo.data!.appSetting!.isSubLocation == PsConst.ONE) {
          provider.isSubLocation = true;
        } else {
          provider.isSubLocation = false;
        }

        await provider.replaceDate(realStartDate!, realEndDate);

        if (psAppInfo.data!.itemUploadConfig != null) {
          await provider.replaceItemUploadConfig(
            psAppInfo.data!.itemUploadConfig!.address ?? '',
            psAppInfo.data!.itemUploadConfig!.brand ?? '',
            psAppInfo.data!.itemUploadConfig!.latitude ?? '',
            psAppInfo.data!.itemUploadConfig!.longitude ?? '',
            psAppInfo.data!.itemUploadConfig!.businessMode ?? '',
            psAppInfo.data!.itemUploadConfig!.subCatId ?? '',
            psAppInfo.data!.itemUploadConfig!.typeId ?? '',
            psAppInfo.data!.itemUploadConfig!.priceTypeId ?? '',
            psAppInfo.data!.itemUploadConfig!.conditionOfItemId ?? '',
            psAppInfo.data!.itemUploadConfig!.dealOptionId ?? '0',
            psAppInfo.data!.itemUploadConfig!.dealOptionRemark ?? '0',
            psAppInfo.data!.itemUploadConfig!.highlightInfo ?? '0',
            psAppInfo.data!.itemUploadConfig!.video ?? '0',
            psAppInfo.data!.itemUploadConfig!.videoIcon ?? '0',
            psAppInfo.data!.itemUploadConfig!.discountRateByPercentage ?? '',
          );
        }

        if (psAppInfo.data!.psMobileConfigSetting != null) {
          await provider.replaceMobileConfigSetting(
              psAppInfo.data!.psMobileConfigSetting!);

          if (provider.psValueHolder!.isUserAlradyChoose != true) {
            if (!languageProvider.isUserChangesLocalLanguage() &&
                psAppInfo.data!.psMobileConfigSetting!.defaultLanguage != null) {
              final Language languageFromApi =
              psAppInfo.data!.psMobileConfigSetting!.defaultLanguage!;
              await languageProvider.addLanguage(languageFromApi);
              await context.setLocale(Locale(
                languageFromApi.languageCode!,
                languageFromApi.countryCode,
              ));
            }
          }

          if (psAppInfo.data!.psMobileConfigSetting!.excludedLanguages != null) {
            await languageProvider.replaceExcludedLanguages(
                psAppInfo.data!.psMobileConfigSetting!.excludedLanguages!);
          }
        }

        if (psAppInfo.data!.appSetting != null) {
          if (psAppInfo.data!.appSetting!.isBlockedDisabled != null) {
            await provider.replaceIsBlockeFeatureDisabled(
                psAppInfo.data!.appSetting!.isBlockedDisabled!);
          }

          if (psAppInfo.data!.appSetting!.isPaidApp != null) {
            await provider.replaceIsPaidApp(
                psAppInfo.data!.appSetting!.isPaidApp!);
          }

          if (psAppInfo.data!.appSetting!.isSubCatSubscribe != null) {
            await provider.replaceIsSubCatSubscribe(
                psAppInfo.data!.appSetting!.isSubCatSubscribe!);
          }

          if (psAppInfo.data!.appSetting!.isSubLocation != null) {
            await provider.replaceIsSubLocation(
                psAppInfo.data!.appSetting!.isSubLocation!);
          }

          if (psAppInfo.data!.appSetting!.maxImageCount != null) {
            await provider.replaceMaxImageCount(
                int.parse(psAppInfo.data!.appSetting!.maxImageCount!));
          }

          if (psAppInfo.data!.appSetting!.promoCellNo != null) {
            await provider.replacePromoCellNo(
                psAppInfo.data!.appSetting!.promoCellNo!);
          }
        }

        // user status checks
        if (psAppInfo.data!.userInfo!.userStatus == PsConst.USER_BANNED) {
          callLogout(provider, PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT, context);
          showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return WarningDialog(
                message: Utils.getString(context, 'user_status__banned'),
                onPressed: () {
                  checkVersionNumber(
                      context, psAppInfo.data!, provider, clearAllDataProvider);
                },
              );
            },
          );
        } else if (psAppInfo.data!.userInfo!.userStatus ==
            PsConst.USER_DELECTED) {
          callLogout(provider, PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT, context);
        } else if (psAppInfo.data!.userInfo!.userStatus ==
            PsConst.USER_UN_PUBLISHED) {
          callLogout(provider, PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT, context);
          showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return WarningDialog(
                message: Utils.getString(context, 'user_status__unpublished'),
                onPressed: () {
                  checkVersionNumber(
                      context, psAppInfo.data!, provider, clearAllDataProvider);
                },
              );
            },
          );
        } else {
          checkVersionNumber(
              context, psAppInfo.data!, provider, clearAllDataProvider);
        }
      } else {
        _goNextAfterLoading(context, provider);
      }
    } else {
      _goNextAfterLoading(context, provider);
    }
  }

  dynamic callLogout(
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

  dynamic checkVersionNumber(
      BuildContext context,
      PSAppInfo psAppInfo,
      AppInfoProvider appInfoProvider,
      ClearAllDataProvider? clearAllDataProvider,
      ) async {
    if (PsConfig.app_version != psAppInfo.psAppVersion!.versionNo) {
      if (psAppInfo.psAppVersion!.versionNeedClearData == PsConst.ONE) {
        await clearAllDataProvider!.clearAllData();
        checkForceUpdate(context, psAppInfo, appInfoProvider);
      } else {
        checkForceUpdate(context, psAppInfo, appInfoProvider);
      }
    } else {
      await appInfoProvider.replaceVersionForceUpdateData(false);
      _goNextAfterLoading(context, appInfoProvider);
    }
  }

  dynamic checkForceUpdate(
      BuildContext context,
      PSAppInfo psAppInfo,
      AppInfoProvider appInfoProvider,
      ) async {
    if (psAppInfo.psAppVersion!.versionForceUpdate == PsConst.ONE) {
      await appInfoProvider.replaceAppInfoData(
        psAppInfo.psAppVersion!.versionNo!,
        true,
        psAppInfo.psAppVersion!.versionTitle!,
        psAppInfo.psAppVersion!.versionMessage!,
      );

      Navigator.pushReplacementNamed(
        context,
        RoutePaths.force_update,
        arguments: psAppInfo.psAppVersion,
      );
    } else if (psAppInfo.psAppVersion!.versionForceUpdate == PsConst.ZERO) {
      await appInfoProvider.replaceVersionForceUpdateData(false);
      callVersionUpdateDialog(context, psAppInfo, appInfoProvider);
    } else {
      _goNextAfterLoading(context, appInfoProvider);
    }
  }

  dynamic callVersionUpdateDialog(
      BuildContext context,
      PSAppInfo psAppInfo,
      AppInfoProvider appInfoProvider,
      ) {
    showDialog<dynamic>(
      barrierDismissible: false,
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return VersionUpdateDialog(
          title: psAppInfo.psAppVersion!.versionTitle,
          description: psAppInfo.psAppVersion!.versionMessage,
          leftButtonText: Utils.getString(context, 'app_info__cancel_button_name'),
          rightButtonText: Utils.getString(context, 'app_info__update_button_name'),
          onCancelTap: () => _goNextAfterLoading(context, appInfoProvider),
          onUpdateTap: () async {
            _goNextAfterLoading(context, appInfoProvider);

            final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);

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
                color: isLight ? PsColors.primary800 : PsColors.primaryDarkWhite,
              ),
              textAlign: TextAlign.center,
            ),
           /* const SizedBox(height: PsDimens.space16),
             Text(
              Utils.getString(context, 'app_name_hint'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isLight ? PsColors.primary800 : PsColors.primaryDarkWhite,
              ),
            ),*/
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
      return const SizedBox.shrink();
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
          create: (_) => AppInfoProvider(repo: repo1, psValueHolder: valueHolder),
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
            Future.microtask(() {
              callDateFunction(
                appInfoProvider,
                clearAllProvider,
                langProvider,
                innerContext,
              );
            });
          }

          // ✅ هنا التغيير: بدل Container بلون ثابت/ارتفاع 400
          // نستخدم TaapdeelScaffold علشان نفس الخلفية المشتركة
          return TaapdeelScaffold(
            safeTop: true,
            safeBottom: true,
            padding: EdgeInsets.zero, // loading centered
            body: _buildLoadingBody(innerContext),
          );
        },
      ),
    );
  }
}
