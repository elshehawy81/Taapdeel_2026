

import 'dart:async';

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/api/ps_api_service.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/db/package_dao.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/package.dart';

import 'Common/ps_repository.dart';

class PackageBoughtRepository extends PsRepository {
  PackageBoughtRepository({
    required PsApiService psApiService, required PackageDao packageDao
  }) {
    _psApiService = psApiService;
    _packageDao = packageDao;
  }
  String primaryKey = 'package_id';
  late PsApiService _psApiService;
  late PackageDao _packageDao;


    Future<dynamic> insert(Package package) async {
    return _packageDao.insert(primaryKey, package);
  }

  Future<dynamic> update(Package package) async {
    return _packageDao.update(package);
  }

  Future<dynamic> delete(Package package) async {
    return _packageDao.delete(package);
  }

  Future<dynamic> getAllPackages(
      StreamController<PsResource<List<Package>>> packageListStream,
      bool isConnectedToInternet,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    packageListStream.sink.add(await _packageDao.getAll(status: status));

    if (isConnectedToInternet) {
      final PsResource<List<Package>> _resource =
          await _psApiService.getPackages();

      if (_resource.status == PsStatus.SUCCESS) {
        await _packageDao.deleteAll();
        await _packageDao.insertAll(primaryKey, _resource.data!);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          await _packageDao.deleteAll();
        }
      }
      packageListStream.sink.add(await _packageDao.getAll());
    }
  }

  Future<PsResource<ApiStatus>> buyAdPackage(
      Map<dynamic, dynamic> jsonMap,
      bool isConnectedToInternet,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<ApiStatus> _resource =
        await _psApiService.buyAdPackage(jsonMap);
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
