import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/provider/common/ps_provider.dart';
import 'package:taapdeel/repository/Common/notification_repository.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';

class NotificationProvider extends PsProvider {
  NotificationProvider({
    required NotificationRepository? repo,
    required this.psValueHolder,
    int limit = 0,
  }) : super(repo, limit) {
    _repo = repo;
    print('Notification Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
  }

  NotificationRepository? _repo;
  PsValueHolder? psValueHolder;

  PsResource<ApiStatus> _notification =
  PsResource<ApiStatus>(PsStatus.NOACTION, '', null);
  PsResource<ApiStatus> get user => _notification;

  String _extractUserId(Map<dynamic, dynamic> jsonMap) {
    return (jsonMap['user_id'] ??
        jsonMap['login_user_id'] ??
        jsonMap['added_user_id'] ??
        '')
        .toString()
        .trim();
  }

  bool _hasValidLoggedInUser(Map<dynamic, dynamic> jsonMap) {
    final String userId = _extractUserId(jsonMap);
    return userId.isNotEmpty && userId != 'nologinuser';
  }

  bool _hasValidDeviceToken(Map<dynamic, dynamic> jsonMap) {
    final String token = (jsonMap['device_token'] ??
        jsonMap['device_id'] ??
        jsonMap['token'] ??
        '')
        .toString()
        .trim();
    return token.isNotEmpty;
  }

  Future<dynamic> rawRegisterNotiToken(Map<dynamic, dynamic> jsonMap) async {
    if (!_hasValidLoggedInUser(jsonMap)) {
      Utils.psPrint(
        '[TAAPDEEL_FCM_V5] rawRegisterNotiToken skipped: invalid user_id=${_extractUserId(jsonMap)}',
      );
      return _notification;
    }

    if (!_hasValidDeviceToken(jsonMap)) {
      Utils.psPrint('[TAAPDEEL_FCM_V5] rawRegisterNotiToken skipped: empty token');
      return _notification;
    }

    if (_repo == null) {
      Utils.psPrint('[TAAPDEEL_FCM_V5] rawRegisterNotiToken skipped: repository is null');
      return _notification;
    }

    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _notification = await _repo!.rawRegisterNotiToken(
      jsonMap,
      isConnectedToInternet,
      PsStatus.PROGRESS_LOADING,
    );

    return _notification;
  }

  Future<dynamic> rawUnRegisterNotiToken(Map<dynamic, dynamic> jsonMap) async {
    if (!_hasValidLoggedInUser(jsonMap)) {
      Utils.psPrint(
        '[TAAPDEEL_FCM_V5] rawUnRegisterNotiToken skipped: invalid user_id=${_extractUserId(jsonMap)}',
      );
      return _notification;
    }

    if (!_hasValidDeviceToken(jsonMap)) {
      Utils.psPrint('[TAAPDEEL_FCM_V5] rawUnRegisterNotiToken skipped: empty token');
      return _notification;
    }

    if (_repo == null) {
      Utils.psPrint('[TAAPDEEL_FCM_V5] rawUnRegisterNotiToken skipped: repository is null');
      return _notification;
    }

    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _notification = await _repo!.rawUnRegisterNotiToken(
      jsonMap,
      isConnectedToInternet,
      PsStatus.PROGRESS_LOADING,
    );

    return _notification;
  }

  Future<dynamic> postChatNoti(Map<dynamic, dynamic> jsonMap) async {
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (_repo == null) {
      Utils.psPrint('[TAAPDEEL_FCM_V5] postChatNoti skipped: repository is null');
      return _notification;
    }

    _notification = await _repo!.postChatNoti(
      jsonMap,
      isConnectedToInternet,
      PsStatus.PROGRESS_LOADING,
    );

    return _notification;
  }

  @override
  void dispose() {
    isDispose = true;
    print('Notification Provider Dispose: $hashCode');
    super.dispose();
  }
}
