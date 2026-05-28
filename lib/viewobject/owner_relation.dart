import 'common/ps_object.dart';

class OwnerRelation extends PsObject<OwnerRelation> {
  OwnerRelation({
    this.level,
    this.ownerId,
    this.ownerName,
    this.ownerGender,
    this.viaUserId,
    this.viaName,
    this.viaGender,
    this.viewerToOwnerType,
    this.viewerToViaType,
    this.viaToOwnerType,
    this.relationText,
  });

  int? level;
  String? ownerId;
  String? ownerName;
  String? ownerGender;

  String? viaUserId;
  String? viaName;
  String? viaGender;

  int? viewerToOwnerType;
  int? viewerToViaType;
  int? viaToOwnerType;

  String? relationText;

  @override
  OwnerRelation fromMap(dynamic data) {
    if (data == null) return OwnerRelation();

    return OwnerRelation(
      level: int.tryParse((data['level'] ?? '').toString()),
      ownerId: data['owner_id']?.toString(),
      ownerName: data['owner_name']?.toString(),
      ownerGender: data['owner_gender']?.toString(),
      viaUserId: data['via_user_id']?.toString(),
      viaName: data['via_name']?.toString(),
      viaGender: data['via_gender']?.toString(),
      viewerToOwnerType: int.tryParse((data['viewer_to_owner_type'] ?? '').toString()),
      viewerToViaType: int.tryParse((data['viewer_to_via_type'] ?? '').toString()),
      viaToOwnerType: int.tryParse((data['via_to_owner_type'] ?? '').toString()),
      relationText: data['relation_text']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toMap(OwnerRelation object) {
    return <String, dynamic>{
      'level': object.level,
      'owner_id': object.ownerId,
      'owner_name': object.ownerName,
      'owner_gender': object.ownerGender,
      'via_user_id': object.viaUserId,
      'via_name': object.viaName,
      'via_gender': object.viaGender,
      'viewer_to_owner_type': object.viewerToOwnerType,
      'viewer_to_via_type': object.viewerToViaType,
      'via_to_owner_type': object.viaToOwnerType,
      'relation_text': object.relationText,
    };
  }

  @override
  List<OwnerRelation> fromMapList(List<dynamic> dataList) {
    final List<OwnerRelation> list = <OwnerRelation>[];
    for (final dynamic d in dataList) {
      list.add(fromMap(d));
    }
    return list;
  }

  @override
  List<Map<String, dynamic>> toMapList(List<OwnerRelation> objectList) {
    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
    for (final OwnerRelation o in objectList) {
      list.add(toMap(o));
    }
    return list;
  }

  @override
  String getPrimaryKey() {
    return ownerId ?? '';
  }
}