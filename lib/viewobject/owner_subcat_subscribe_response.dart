import 'common/ps_object.dart';
import 'owner_subcat_subscribe.dart';

class OwnerSubcatSubscribeResponse
    extends PsObject<OwnerSubcatSubscribeResponse> {
  OwnerSubcatSubscribeResponse({
    this.status = '',
    this.message = const <OwnerSubcatSubscribe>[],
  });

  final String status;
  final List<OwnerSubcatSubscribe> message;

  @override
  OwnerSubcatSubscribeResponse fromMap(dynamic dynamicData) {
    final Map<String, dynamic> json =
    Map<String, dynamic>.from(dynamicData as Map);

    final List<OwnerSubcatSubscribe> list =
    OwnerSubcatSubscribe().fromMapList((json['message'] ?? <dynamic>[]) as List<dynamic>);

    return OwnerSubcatSubscribeResponse(
      status: (json['status'] ?? '').toString(),
      message: list,
    );
  }

  @override
  Map<String, dynamic>? toMap(OwnerSubcatSubscribeResponse? object) {
    if (object == null) {
      return null;
    }

    return <String, dynamic>{
      'status': object.status,
      'message': OwnerSubcatSubscribe().toMapList(object.message),
    };
  }

  @override
  List<OwnerSubcatSubscribeResponse> fromMapList(List<dynamic> dynamicDataList) {
    final List<OwnerSubcatSubscribeResponse> list =
    <OwnerSubcatSubscribeResponse>[];
    for (final dynamic data in dynamicDataList) {
      list.add(fromMap(data));
    }
    return list;
  }

  @override
  List<Map<String, dynamic>?> toMapList(
      List<OwnerSubcatSubscribeResponse>? objectList) {
    if (objectList == null) {
      return <Map<String, dynamic>?>[];
    }

    final List<Map<String, dynamic>?> list = <Map<String, dynamic>?>[];
    for (final OwnerSubcatSubscribeResponse data in objectList) {
      list.add(toMap(data));
    }
    return list;
  }

  @override
  String? getPrimaryKey() {
    // response object مش entity حقيقية في DB
    // ندي أي key ثابت عشان abstract method
    return status;
  }
}