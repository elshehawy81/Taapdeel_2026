// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/product.dart';

class ProfileFamilyItemsProvider extends ChangeNotifier {
  ProfileFamilyItemsProvider({
    required ProductRepository repo,
    required PsValueHolder psValueHolder,
    required int limit,
  })  : _repo = repo,
        _psValueHolder = psValueHolder,
        _limit = limit {
    debugPrint('🟦 [FAMILY] Provider CREATED limit=$_limit');
  }

  final ProductRepository _repo;
  final PsValueHolder _psValueHolder;

  final int _limit;
  int get limit => _limit;

  int offset = 0;

  String? _profileUserId;

  // Guards
  bool _loadingNow = false;
  String? _lastKey;
  bool _disposed = false;

  // ✅ pagination helpers
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// نفس naming بتاع باقي providers
  PsResource<List<Product>> itemList =
  PsResource<List<Product>>(PsStatus.NOACTION, '', <Product>[]);

  StreamSubscription<PsResource<List<Product>>>? _subscription;
  StreamController<PsResource<List<Product>>>? _controller;

  // ---------- Helpers ----------

  bool _isRecordNotFound(String? msg) {
    if (msg == null) return false;
    final m = msg.toLowerCase();
    return m.contains('record not found') ||
        m.contains('10001') ||
        m.contains('sorry, record not found');
  }

  /// ✅ ONLY normalize if the incoming resource itself has data (not our old cache)
  PsResource<List<Product>> _normalizeStatusIfHasData(PsResource<List<Product>> res) {
    final int len = (res.data ?? <Product>[]).length;

    // لو الريسبونس نفسه فيه داتا وجاي بحالة Loading → خليها SUCCESS
    if (len > 0 &&
        (res.status == PsStatus.PROGRESS_LOADING ||
            res.status == PsStatus.BLOCK_LOADING ||
            res.status == PsStatus.NOACTION ||
            res.status == PsStatus.LOADING)) {
      return PsResource<List<Product>>(PsStatus.SUCCESS, res.message, res.data);
    }

    return res;
  }

  void _updateItemList(PsResource<List<Product>> res) {
    // ✅ convert "record not found" to empty success
    if (res.status == PsStatus.ERROR && _isRecordNotFound(res.message)) {
      res = PsResource<List<Product>>(PsStatus.SUCCESS, res.message, <Product>[]);
    }

    final PsResource<List<Product>> normalized = _normalizeStatusIfHasData(res);
    itemList = normalized;

    debugPrint(
      '🟩 [FAMILY] updateItemList '
          'status=${normalized.status} '
          'len=${normalized.data?.length ?? 0} '
          'msg=${normalized.message}',
    );

    if (!_disposed) {
      notifyListeners();
    }
  }

  // ✅ FIX: كان بيستخدم _profileUserId/offset بدل params
  String _makeKey(String? loginUserId, String profileUserId, int off) {
    return '${loginUserId ?? ''}::$profileUserId::$off';
  }

  Future<void> _cleanupStream() async {
    try {
      await _subscription?.cancel();
    } catch (_) {}
    _subscription = null;

    try {
      await _controller?.close();
    } catch (_) {}
    _controller = null;
  }

  void _finalizeSuccessIfNeeded() {
    final int len = (itemList.data ?? <Product>[]).length;

    // ✅ لو status لسه loading (وبدون داتا جديدة) خليها SUCCESS (بس لو فعلاً خلصنا)
    if (itemList.status == PsStatus.PROGRESS_LOADING ||
        itemList.status == PsStatus.BLOCK_LOADING ||
        itemList.status == PsStatus.LOADING ||
        itemList.status == PsStatus.NOACTION) {
      _updateItemList(
        PsResource<List<Product>>(PsStatus.SUCCESS, itemList.message, itemList.data ?? <Product>[]),
      );
    }

    // ✅ hasMore: لو أقل من limit يبقى غالباً خلصت
    _hasMore = len >= _limit;
    debugPrint('🟦 [FAMILY] finalize hasMore=$_hasMore len=$len limit=$_limit');
  }

  // ---------- Public API ----------

  Future<void> loadFamilyItems(
      String? loginUserId, // headers / analytics
      String profileUserId, // user_id بتاع البروفايل
      ) async {
    final String key = _makeKey(loginUserId, profileUserId, 0);

    // ✅ guard ضد التكرار
    if (_loadingNow && _lastKey == key) {
      debugPrint('🟡 [FAMILY] loadFamilyItems SKIP duplicate key=$key');
      return;
    }

    debugPrint(
      '🟦 [FAMILY] loadFamilyItems START '
          'loginUserId=$loginUserId '
          'profileUserId=$profileUserId '
          'key=$key',
    );

    _loadingNow = true;
    _lastKey = key;

    _profileUserId = profileUserId;
    offset = 0;
    _hasMore = true;

    // ✅ نظّف أي stream قديم قبل ما تبدأ
    await _cleanupStream();

    // ✅ IMPORTANT: امسح أي بيانات قديمة فوراً (عشان مايعرضش cache)
    _updateItemList(
      PsResource<List<Product>>(PsStatus.BLOCK_LOADING, '', <Product>[]),
    );

    final StreamController<PsResource<List<Product>>> sc =
    StreamController<PsResource<List<Product>>>();
    _controller = sc;

    _subscription = sc.stream.listen(
          (PsResource<List<Product>> res) {
        debugPrint(
          '🟦 [FAMILY] STREAM EVENT '
              'status=${res.status} '
              'len=${res.data?.length ?? 0} '
              'msg=${res.message}',
        );

        // ✅ لو "record not found" اعتبرها empty success
        if ((res.data == null || (res.data?.isEmpty ?? true)) &&
            _isRecordNotFound(res.message)) {
          _updateItemList(PsResource<List<Product>>(PsStatus.SUCCESS, res.message, <Product>[]));
          offset = 0;
          _hasMore = false;
          return;
        }

        _updateItemList(res);

        // ✅ offset من طول الداتا الحالية
        offset = (itemList.data ?? <Product>[]).length;
        debugPrint('🟦 [FAMILY] offset updated to $offset');

        final int len = (itemList.data ?? <Product>[]).length;
        if (len < _limit) {
          _hasMore = false;
          debugPrint('🟦 [FAMILY] hasMore=false (len<$limit)');
        }
      },
      onError: (e, st) {
        debugPrint('❌ [FAMILY] STREAM ERROR: $e');
        debugPrint('$st');

        // لو error نصه "record not found" -> empty success
        final msg = e.toString();
        if (_isRecordNotFound(msg)) {
          _updateItemList(PsResource<List<Product>>(PsStatus.SUCCESS, msg, <Product>[]));
          offset = 0;
          _hasMore = false;
          return;
        }

        _updateItemList(
          PsResource<List<Product>>(PsStatus.ERROR, msg, <Product>[]),
        );
      },
    );

    try {
      debugPrint('🟦 [FAMILY] CALL repo.getFamilyItemsByUserId');

      await _repo.getFamilyItemsByUserId(
        sc,
        true,
        loginUserId,
        profileUserId,
        _limit,
        offset,
        PsStatus.PROGRESS_LOADING,
      );

      debugPrint('🟦 [FAMILY] repo.getFamilyItemsByUserId DONE');

      // ✅ finalize (لو الريبو ما بعَتش SUCCESS صريح)
      _finalizeSuccessIfNeeded();

      await _cleanupStream();
    } catch (e, st) {
      debugPrint('❌ [FAMILY] API ERROR: $e');
      debugPrint('$st');

      final msg = e.toString();
      if (_isRecordNotFound(msg)) {
        _updateItemList(PsResource<List<Product>>(PsStatus.SUCCESS, msg, <Product>[]));
        offset = 0;
        _hasMore = false;
      } else {
        _updateItemList(PsResource<List<Product>>(PsStatus.ERROR, msg, <Product>[]));
      }

      await _cleanupStream();
    } finally {
      _loadingNow = false;
    }
  }

  Future<void> nextFamilyItems(
      String? loginUserId,
      String profileUserId,
      ) async {
    debugPrint(
      '🟨 [FAMILY] nextFamilyItems '
          'currentStatus=${itemList.status} '
          'offset=$offset hasMore=$_hasMore',
    );

    // ✅ لو لسه بيحمّل متعملش call
    if (_loadingNow ||
        itemList.status == PsStatus.PROGRESS_LOADING ||
        itemList.status == PsStatus.BLOCK_LOADING ||
        itemList.status == PsStatus.LOADING) {
      debugPrint('🟨 [FAMILY] nextFamilyItems IGNORED (already loading)');
      return;
    }

    // ✅ لو البروفايل اتغير — اعمل reload
    if (_profileUserId != null && _profileUserId != profileUserId) {
      debugPrint('🟨 [FAMILY] profile changed -> reload');
      await loadFamilyItems(loginUserId, profileUserId);
      return;
    }

    // ✅ لو مفيش المزيد خلاص
    if (!hasMore) {
      debugPrint('🟨 [FAMILY] nextFamilyItems IGNORED (no more)');
      return;
    }

    final int prevLen = (itemList.data ?? <Product>[]).length;

    _loadingNow = true;
    final String key = _makeKey(loginUserId, profileUserId, offset);
    _lastKey = key;

    await _cleanupStream();

    // ✅ خليها progress لكن احتفظ بالداتا الحالية (ده طبيعي للـpagination)
    _updateItemList(
      PsResource<List<Product>>(
        PsStatus.PROGRESS_LOADING,
        itemList.message,
        itemList.data ?? <Product>[],
      ),
    );

    final StreamController<PsResource<List<Product>>> sc =
    StreamController<PsResource<List<Product>>>();
    _controller = sc;

    _subscription = sc.stream.listen(
          (PsResource<List<Product>> res) {
        debugPrint(
          '🟨 [FAMILY] NEXT STREAM EVENT '
              'status=${res.status} '
              'len=${res.data?.length ?? 0} '
              'msg=${res.message}',
        );

        // record not found => stop
        if ((res.data == null || (res.data?.isEmpty ?? true)) &&
            _isRecordNotFound(res.message)) {
          _hasMore = false;
          _updateItemList(PsResource<List<Product>>(PsStatus.SUCCESS, res.message, itemList.data ?? <Product>[]));
          return;
        }

        _updateItemList(res);

        final int newLen = (itemList.data ?? <Product>[]).length;
        offset = newLen;

        // ✅ لو مفيش زيادة → مفيش المزيد
        if (newLen <= prevLen) {
          _hasMore = false;
          debugPrint('🟨 [FAMILY] no more data detected');
        } else {
          // لو الزيادة أقل من limit يبقى خلاص
          if ((newLen - prevLen) < _limit) {
            _hasMore = false;
          }
        }
      },
      onError: (e, st) {
        debugPrint('❌ [FAMILY] NEXT STREAM ERROR: $e');
        debugPrint('$st');

        final msg = e.toString();
        if (_isRecordNotFound(msg)) {
          _hasMore = false;
          _updateItemList(PsResource<List<Product>>(PsStatus.SUCCESS, msg, itemList.data ?? <Product>[]));
          return;
        }

        _updateItemList(
          PsResource<List<Product>>(PsStatus.ERROR, msg, itemList.data ?? <Product>[]),
        );
      },
    );

    try {
      debugPrint('🟨 [FAMILY] CALL repo.getNextPageFamilyItemsByUserId');

      await _repo.getNextPageFamilyItemsByUserId(
        sc,
        true,
        loginUserId,
        profileUserId,
        _limit,
        offset,
        PsStatus.PROGRESS_LOADING,
      );

      debugPrint('🟨 [FAMILY] repo.getNextPageFamilyItemsByUserId DONE');

      _finalizeSuccessIfNeeded();

      await _cleanupStream();
    } catch (e, st) {
      debugPrint('❌ [FAMILY] NEXT PAGE ERROR: $e');
      debugPrint('$st');

      final msg = e.toString();
      if (_isRecordNotFound(msg)) {
        _hasMore = false;
        _updateItemList(PsResource<List<Product>>(PsStatus.SUCCESS, msg, itemList.data ?? <Product>[]));
      } else {
        _updateItemList(PsResource<List<Product>>(PsStatus.ERROR, msg, itemList.data ?? <Product>[]));
      }

      await _cleanupStream();
    } finally {
      _loadingNow = false;
    }
  }

  @override
  void dispose() {
    debugPrint('🟥 [FAMILY] Provider DISPOSE');
    _disposed = true;

    _subscription?.cancel();
    _controller?.close();

    super.dispose();
  }
}
