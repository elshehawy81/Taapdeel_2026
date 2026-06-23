import 'package:flutter/material.dart';

import '../../api/common/ps_resource.dart';
import '../../api/common/ps_status.dart';
import '../../repository/owner_subcat_subscribe_repository.dart';
import '../../viewobject/owner_subcat_subscribe.dart';
import '../../viewobject/owner_subcat_subscribe_response.dart';

class OwnerSubcatSubscribeProvider extends ChangeNotifier {
  OwnerSubcatSubscribeProvider({required OwnerSubcatSubscribeRepository repo})
      : _repo = repo;

  final OwnerSubcatSubscribeRepository _repo;

  // ✅ FIX: منع use-after-dispose
  bool _disposed = false;

  PsResource<OwnerSubcatSubscribeResponse> subcats =
  PsResource<OwnerSubcatSubscribeResponse>(
    PsStatus.NOACTION,
    '',
    OwnerSubcatSubscribeResponse(status: '', message: const <OwnerSubcatSubscribe>[]),
  );

  bool _loading = false;
  bool get loading => _loading;

  // ✅ FIX: بدل notifyListeners مباشرة — بنتأكد مش disposed أول
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadOwnerSubcats({required String ownerUserId}) async {
    if (_loading || _disposed) return;
    _loading = true;
    _safeNotify();

    subcats = PsResource<OwnerSubcatSubscribeResponse>(
      PsStatus.PROGRESS_LOADING,
      '',
      subcats.data ?? OwnerSubcatSubscribeResponse(status: '', message: const <OwnerSubcatSubscribe>[]),
    );
    _safeNotify();

    try {
      final res = await _repo.getOwnerSubcatSubscribes(<String, String>{
        'owner_user_id': ownerUserId,
      });
      if (!_disposed) subcats = res;
    } catch (_) {
      // تجاهل الأخطاء بعد الـ dispose
    }

    _loading = false;
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}