import 'dart:async';

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/api/ps_api_service.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/db/noti_dao.dart';
import 'package:taapdeel/repository/Common/ps_repository.dart';
import 'package:taapdeel/viewobject/noti.dart';

class NotiRepository extends PsRepository {
  NotiRepository({
    required PsApiService psApiService,
    required NotiDao notiDao,
  }) {
    _psApiService = psApiService;
    _notiDao = notiDao;
  }

  late PsApiService _psApiService;
  late NotiDao _notiDao;
  final String _primaryKey = 'id';

  Future<dynamic> insert(Noti noti) async => _notiDao.insert(_primaryKey, noti);
  Future<dynamic> update(Noti noti) async => _notiDao.update(noti);
  Future<dynamic> delete(Noti noti) async => _notiDao.delete(noti);

  Future<dynamic> getNotiList(
      StreamController<PsResource<List<Noti>>> notiListStream,
      bool isConnectedToInternet,
      int limit,
      int? offset,
      PsStatus status,
      Map<dynamic, dynamic> paramMap, {
        bool isLoadFromServer = true,
      }) async {
    notiListStream.sink.add(await _notiDao.getAll(status: status));

    if (isConnectedToInternet) {
      final int safeLimit = limit <= 0 ? 30 : limit;
      final int safeOffset = offset ?? 0;

      final PsResource<List<Noti>> _resource =
      await _psApiService.getNotificationList(paramMap, safeLimit, safeOffset);

      if (_resource.status == PsStatus.SUCCESS) {
        final List<Noti> serverList = _resource.data ?? <Noti>[];

        // Important: show server data immediately.
        // This avoids an empty screen if the old local notification table
        // schema is missing any new bs_app_notifications columns.
        notiListStream.sink.add(PsResource<List<Noti>>(
          PsStatus.SUCCESS,
          _resource.message,
          serverList,
        ));

        try {
          await _notiDao.deleteAll();
          if (serverList.isNotEmpty) {
            await _notiDao.insertAll(_primaryKey, serverList);
          }
        } catch (e) {
          print('[NotiRepo] cache insert skipped: $e');
        }
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          await _notiDao.deleteAll();
          notiListStream.sink.add(PsResource<List<Noti>>(
            PsStatus.SUCCESS,
            _resource.message,
            <Noti>[],
          ));
        } else {
          notiListStream.sink.add(_resource);
        }
      }
    }
  }

  Future<dynamic> getNextPageNotiList(
      StreamController<PsResource<List<Noti>>> notiListStream,
      bool isConnectedToInternet,
      int limit,
      int? offset,
      PsStatus status,
      Map<dynamic, dynamic> paramMap, {
        bool isLoadFromServer = true,
      }) async {
    final PsResource<List<Noti>> cached = await _notiDao.getAll(status: status);
    notiListStream.sink.add(cached);

    if (isConnectedToInternet) {
      final int safeLimit = limit <= 0 ? 30 : limit;
      final int safeOffset = offset ?? 0;

      final PsResource<List<Noti>> _resource =
      await _psApiService.getNotificationList(paramMap, safeLimit, safeOffset);

      if (_resource.status == PsStatus.SUCCESS) {
        final List<Noti> oldList = cached.data ?? <Noti>[];
        final List<Noti> nextList = _resource.data ?? <Noti>[];
        final List<Noti> merged = <Noti>[...oldList, ...nextList];

        notiListStream.sink.add(PsResource<List<Noti>>(
          PsStatus.SUCCESS,
          _resource.message,
          merged,
        ));

        try {
          if (nextList.isNotEmpty) {
            await _notiDao.insertAll(_primaryKey, nextList);
          }
        } catch (e) {
          print('[NotiRepo] next cache insert skipped: $e');
        }
      } else {
        notiListStream.sink.add(_resource);
      }
    }
  }

  Future<PsResource<Noti>> postNoti(
      StreamController<PsResource<List<Noti>>>? ratingListStream,
      Map<dynamic, dynamic> jsonMap,
      bool isConnectedToInternet, {
        bool isLoadFromServer = true,
      }) async {
    final PsResource<Noti> _resource = await _psApiService.postNoti(jsonMap);
    ratingListStream!.sink
        .add(await _notiDao.getAll(status: PsStatus.SUCCESS));
    if (_resource.status != PsStatus.SUCCESS) {
      final Completer<PsResource<Noti>> completer =
      Completer<PsResource<Noti>>();
      completer.complete(_resource);
      return completer.future;
    }
    return _resource;
  }


  Future<void> markNotiRead(
      bool isConnectedToInternet, {
        required String userId,
        required Noti noti,
      }) async {
    if ((noti.id ?? '').isEmpty) return;

    final Noti updated = noti.copyWith(isRead: '1');
    await _notiDao.update(updated);

    if (isConnectedToInternet) {
      try {
        await _psApiService.markNotificationRead(
          userId: userId,
          notiId: noti.id!,
        );
      } catch (e) {
        print('[NotiRepo] markRead server error: $e');
      }
    }
  }

  // ── markAllNotiRead — now accepts userId for the API call ─────────────────
  Future<void> markAllNotiRead(
      bool isConnectedToInternet, {
        String userId = '',
      }) async {
    // 1. Update local DB first for instant UI feedback
    final List<Noti> allCached = (await _notiDao.getAll()).data ?? <Noti>[];
    for (final Noti n in allCached) {
      final Noti updated = n.copyWith(isRead: '1');
      await _notiDao.update(updated);
    }

    // 2. Sync with server
    if (isConnectedToInternet) {
      try {
        await _psApiService.markAllNotificationsRead(userId: userId);
      } catch (e) {
        print('[NotiRepo] markAllRead server error: $e');
        // Non-fatal — local DB is already updated
      }
    }
  }

  // ── getUnreadNotiCount ────────────────────────────────────────────────────
  Future<int> getUnreadNotiCount({
    required String userId,
    required String deviceToken,
  }) async {
    try {
      final int count = await _psApiService.getUnreadNotificationCount(
        userId: userId,
        deviceToken: deviceToken,
      );
      return count;
    } catch (e) {
      print('[NotiRepo] getUnreadCount error: $e');
      final List<Noti> cached = (await _notiDao.getAll()).data ?? <Noti>[];
      return cached.where((Noti n) => n.isRead == '0').length;
    }
  }
}