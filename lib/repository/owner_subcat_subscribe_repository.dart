import '../api/common/ps_resource.dart';
import '../api/ps_api_service.dart';
import '../repository/Common/ps_repository.dart';
import '../viewobject/owner_subcat_subscribe_response.dart';

class OwnerSubcatSubscribeRepository extends PsRepository {
  OwnerSubcatSubscribeRepository({required PsApiService psApiService})
      : _psApiService = psApiService;

  final PsApiService _psApiService;

  Future<PsResource<OwnerSubcatSubscribeResponse>> getOwnerSubcatSubscribes(
      Map<dynamic, dynamic> jsonMap,
      ) async {
    return _psApiService.getOwnerSubcatSubscribes(jsonMap);
  }
}