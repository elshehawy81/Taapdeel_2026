import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/provider/common/ps_provider.dart';
import 'package:taapdeel/repository/app_info_repository.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/app_info_parameter_holder.dart';
import 'package:taapdeel/viewobject/ps_app_info.dart';

class AppInfoProvider extends PsProvider {
  static const Duration _deleteHistoryTimeout = Duration(milliseconds: 700);

  AppInfoProvider(
      {required AppInfoRepository? repo, this.psValueHolder, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    print('App Info Provider: $hashCode');
    isDispose = false;
  }

  AppInfoRepository? _repo;
  PsValueHolder? psValueHolder;

  PsResource<PSAppInfo> _psAppInfo =
  PsResource<PSAppInfo>(PsStatus.NOACTION, '', null);

  PsResource<PSAppInfo> get appInfo => _psAppInfo;
  String? realStartDate = '0';
  String realEndDate = '0';
  bool isSubLocation = false;

  @override
  void dispose() {
    isDispose = true;
    print('App Info Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadDeleteHistory(Map<dynamic, dynamic> jsonMap) async {
    isLoading = true;

    try {
      final PsResource<PSAppInfo> psAppInfo =
      await _repo!.postDeleteHistory(jsonMap).timeout(_deleteHistoryTimeout);
      isLoading = false;
      return psAppInfo;
    } catch (_) {
      isLoading = false;
      return _psAppInfo;
    }
  }

  Future<void> loadDeleteHistorywithNotifier() async {
    isLoading = true;

    if (psValueHolder == null || psValueHolder!.startDate == null) {
      realStartDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
      isLoading = false;
      return;
    }

    realStartDate = psValueHolder!.endDate;
    realEndDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());

    final AppInfoParameterHolder appInfoParameterHolder = AppInfoParameterHolder(
      startDate: realStartDate,
      endDate: realEndDate,
      userId: Utils.checkUserLoginId(psValueHolder!),
    );

    try {
      final PsResource<PSAppInfo> psAppInfo = await _repo!
          .postDeleteHistory(appInfoParameterHolder.toMap())
          .timeout(_deleteHistoryTimeout);

      _psAppInfo = psAppInfo;

      if (!isDispose) {
        notifyListeners();
      }
    } on TimeoutException {
      // لا نوقف الـ Splash أو الصفحة بسبب طلب appinfo بطيء.
    } catch (_) {
      // طلب غير حرج؛ التطبيق يكمل طبيعيًا.
    } finally {
      isLoading = false;
    }
  }
}
