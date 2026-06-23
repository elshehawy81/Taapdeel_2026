

import 'dart:async';

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/api/ps_api_service.dart';
import 'package:taapdeel/viewobject/api_status.dart';

import 'Common/ps_repository.dart';

class ContactUsRepository extends PsRepository {
  ContactUsRepository({
    required PsApiService psApiService,
  }) {
    _psApiService = psApiService;
  }
  String primaryKey = 'id';
  late PsApiService _psApiService;

  Future<PsResource<ApiStatus>> postContactUs(Map<dynamic, dynamic> jsonMap,
      bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<ApiStatus> _resource =
        await _psApiService.postContactUs(jsonMap);
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<ApiStatus>> completer =
          Completer<PsResource<ApiStatus>>();
      completer.complete(_resource);
      return completer.future;
    }
  }
}
