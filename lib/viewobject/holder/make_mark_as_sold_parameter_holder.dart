

import 'package:taapdeel/viewobject/common/ps_holder.dart'
    show PsHolder;

class MakeMarkAsSoldParameterHolder
    extends PsHolder<MakeMarkAsSoldParameterHolder> {
  MakeMarkAsSoldParameterHolder({
    required this.itemId,
    required this.buyerUserId,
    required this.sellerUserId,
    required this.buyerItemId,
  });

  final String? itemId;
  final String? buyerUserId;
  final String? sellerUserId;
  final String? buyerItemId;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['item_id'] = itemId;
    map['buyer_user_id'] = buyerUserId;
    map['seller_user_id'] = sellerUserId;
    map['buyer_item_id'] =buyerItemId;
    return map;
  }

  @override
  MakeMarkAsSoldParameterHolder fromMap(dynamic dynamicData) {
    return MakeMarkAsSoldParameterHolder(
      itemId: dynamicData['item_id'],
      buyerUserId: dynamicData['buyer_user_id'],
      sellerUserId: dynamicData['seller_user_id'],
      buyerItemId: dynamicData['buyer_item_id'],
    );
  }

  @override
  String getParamKey() {
    String key = '';

    if (itemId != '') {
      key += itemId!;
    }
    if (buyerUserId != '') {
      key += buyerUserId!;
    }
    if (sellerUserId != '') {
      key += sellerUserId!;
    }
    if (buyerItemId != '') {
      key += buyerItemId!;
    }

    return key;
  }
}
