
import 'common/ps_object.dart';

class OwnerSubcatSubscribe extends PsObject<OwnerSubcatSubscribe> {
  OwnerSubcatSubscribe({
    this.subcatId = '',
    this.catId = '',
    this.subcatName = '',
    this.subcatTableId = '',
  });

  final String subcatId;
  final String catId;
  final String subcatName;
  final String subcatTableId;

  @override
  OwnerSubcatSubscribe fromMap(dynamic dynamicData) {
    final Map<String, dynamic> json =
    Map<String, dynamic>.from(dynamicData as Map);

    return OwnerSubcatSubscribe(
      subcatId: (json['subcat_id'] ?? '').toString(),
      catId: (json['cat_id'] ?? '').toString(),
      subcatName: (json['subcat_name'] ?? '').toString(),
      subcatTableId: (json['subcat_table_id'] ?? '').toString(),
    );
  }

  @override
  Map<String, dynamic>? toMap(OwnerSubcatSubscribe? object) {
    if (object == null) {
      return null;
    }

    return <String, dynamic>{
      'subcat_id': object.subcatId,
      'cat_id': object.catId,
      'subcat_name': object.subcatName,
      'subcat_table_id': object.subcatTableId,
    };
  }

  @override
  List<OwnerSubcatSubscribe> fromMapList(List<dynamic> dynamicDataList) {
    final List<OwnerSubcatSubscribe> list = <OwnerSubcatSubscribe>[];
    for (final dynamic data in dynamicDataList) {
      list.add(fromMap(data));
    }
    return list;
  }

  @override
  List<Map<String, dynamic>?> toMapList(List<OwnerSubcatSubscribe>? objectList) {
    if (objectList == null) {
      return <Map<String, dynamic>?>[];
    }

    final List<Map<String, dynamic>?> list = <Map<String, dynamic>?>[];
    for (final OwnerSubcatSubscribe data in objectList) {
      list.add(toMap(data));
    }
    return list;
  }

  @override
  String? getPrimaryKey() {
    // الأفضل يكون ثابت ومميز
    // subcat_id هنا هو unique per subscription record (مع suffix _MB)
    return subcatId;
  }
}