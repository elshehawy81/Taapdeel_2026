import 'dart:async';

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/provider/common/ps_provider.dart';
import 'package:taapdeel/repository/noti_repository.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/noti.dart';

class NotiProvider extends PsProvider {
  NotiProvider({
    required NotiRepository? repo,
    this.psValueHolder,
    int limit = 30,
  }) : super(repo, limit) {
    _repo = repo;

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    notiListStream = StreamController<PsResource<List<Noti>>>.broadcast();
    subscription = notiListStream!.stream.listen((dynamic resource) {
      final List<Noti> data = (resource.data as List<Noti>?) ?? <Noti>[];
      updateOffset(data.length);
      _notiList = resource;

      _unreadCount = data
          .where((Noti n) => n.isRead == '0')
          .length;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) notifyListeners();
    });
  }

  NotiRepository? _repo;
  PsValueHolder? psValueHolder;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  PsResource<Noti?> _noti = PsResource<Noti>(PsStatus.NOACTION, '', null);
  PsResource<Noti?> get user => _noti;

  PsResource<List<Noti>> _notiList =
  PsResource<List<Noti>>(PsStatus.NOACTION, '', <Noti>[]);
  PsResource<List<Noti>> get notiList => _notiList;

  late StreamSubscription<dynamic> subscription;
  StreamController<PsResource<List<Noti>>>? notiListStream;

  String get _safeUserId {
    final String userId = (psValueHolder?.loginUserId ?? '').toString().trim();
    if (userId.isEmpty || userId == 'nologinuser') return '';
    return userId;
  }

  String get _safeDeviceToken {
    return (psValueHolder?.deviceToken ?? '').toString().trim();
  }

  bool get _hasValidUser => _safeUserId.isNotEmpty;

  @override
  void dispose() {
    subscription.cancel();
    isDispose = true;
    super.dispose();
  }

  Future<dynamic> getNotiList(Map<dynamic, dynamic> paramMap) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;
    await _repo!.getNotiList(
      notiListStream!,
      isConnectedToInternet,
      limit,
      offset,
      PsStatus.BLOCK_LOADING,
      paramMap,
    );
  }

  Future<dynamic> nextNotiList(Map<dynamic, dynamic> paramMap) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;
      await _repo!.getNextPageNotiList(
        notiListStream!,
        isConnectedToInternet,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        paramMap,
      );
    }
  }

  Future<void> resetNotiList(Map<dynamic, dynamic> paramMap) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;
    updateOffset(0);
    await _repo!.getNotiList(
      notiListStream!,
      isConnectedToInternet,
      limit,
      offset,
      PsStatus.BLOCK_LOADING,
      paramMap,
    );
    isLoading = false;
  }

  Future<dynamic> postNoti(Map<dynamic, dynamic> jsonMap) async {
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    _noti = await _repo!.postNoti(
      notiListStream,
      jsonMap,
      isConnectedToInternet,
    );
    return _noti;
  }

  Future<void> markAllRead() async {
    if (_unreadCount == 0) return;

    final String userId = _safeUserId;
    if (userId.isEmpty) {
      Utils.psPrint('[TAAPDEEL_NOTI] markAllRead skipped: invalid user_id');
      _unreadCount = 0;
      if (!isDispose) notifyListeners();
      return;
    }

    isConnectedToInternet = await Utils.checkInternetConnectivity();
    await _repo!.markAllNotiRead(
      isConnectedToInternet,
      userId: userId,
    );
    _unreadCount = 0;
    if (!isDispose) notifyListeners();
  }


  Future<void> markRead(Noti noti) async {
    final String userId = _safeUserId;

    if (userId.isEmpty) {
      Utils.psPrint('[TAAPDEEL_NOTI] markRead skipped: invalid user_id');
      return;
    }

    if ((noti.id ?? '').isEmpty) {
      Utils.psPrint('[TAAPDEEL_NOTI] markRead skipped: empty noti id');
      return;
    }

    if (noti.isRead == '1') {
      return;
    }

    final List<Noti> currentList = _notiList.data ?? <Noti>[];
    final List<Noti> updatedList = currentList.map((Noti item) {
      if (item.id == noti.id) {
        return item.copyWith(isRead: '1');
      }
      return item;
    }).toList();

    _notiList = PsResource<List<Noti>>(
      PsStatus.SUCCESS,
      '',
      updatedList,
    );

    if (_unreadCount > 0) {
      _unreadCount--;
    }

    if (!isDispose) {
      notifyListeners();
    }

    try {
      isConnectedToInternet = await Utils.checkInternetConnectivity();
      await _repo!.markNotiRead(
        isConnectedToInternet,
        userId: userId,
        noti: noti,
      );
    } catch (e) {
      Utils.psPrint('[TAAPDEEL_NOTI] markRead error: $e');
    }
  }

  Future<void> loadUnreadCount() async {
    final String userId = _safeUserId;
    final String deviceToken = _safeDeviceToken;

    if (userId.isEmpty) {
      Utils.psPrint('[TAAPDEEL_NOTI] loadUnreadCount skipped: invalid user_id');
      return;
    }

    if (deviceToken.isEmpty) {
      Utils.psPrint('[TAAPDEEL_NOTI] loadUnreadCount skipped: empty token');
      return;
    }

    isConnectedToInternet = await Utils.checkInternetConnectivity();
    if (!isConnectedToInternet) return;

    final int count = await _repo!.getUnreadNotiCount(
      userId: userId,
      deviceToken: deviceToken,
    );
    if (_unreadCount != count) {
      _unreadCount = count;
      if (!isDispose) notifyListeners();
    }
  }

  void incrementUnread() {
    _unreadCount++;
    if (!isDispose) notifyListeners();
  }

  void clearUnread() {
    if (_unreadCount == 0) return;
    _unreadCount = 0;
    if (!isDispose) notifyListeners();
  }
}
