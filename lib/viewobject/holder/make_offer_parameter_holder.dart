

import 'package:taapdeel/viewobject/common/ps_holder.dart'
    show PsHolder;

class MakeOfferParameterHolder extends PsHolder<MakeOfferParameterHolder> {
  MakeOfferParameterHolder({

    required this.itemId,
    required this.buyerUserId,
    required this.sellerUserId,
    required this.negoPrice,
     this.buyerItemId,
    required this.type,
    required this.isUserOnline,
  });

  final String? itemId;
  final String? buyerUserId;
  final String? sellerUserId;
  final String? negoPrice;
  final String? type;
  final String? isUserOnline;
  final String? buyerItemId;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['item_id'] = itemId;
    map['buyer_user_id'] = buyerUserId;
    map['buyer_item_id'] = buyerItemId;
    map['seller_user_id'] = sellerUserId;
    map['nego_price'] = negoPrice;
    map['type'] = type;
    map['is_user_online'] = isUserOnline;
    return map;
  }

  @override
  MakeOfferParameterHolder fromMap(dynamic dynamicData) {
    return MakeOfferParameterHolder(
      itemId: dynamicData['item_id'],
      buyerUserId: dynamicData['buyer_user_id'],
      sellerUserId: dynamicData['seller_user_id'],
      negoPrice: dynamicData['nego_price'],
      buyerItemId: dynamicData['buyer_item_id'],
      type: dynamicData['type'],
      isUserOnline: dynamicData['is_user_online'],
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
    if (negoPrice != '') {
      key += negoPrice!;
    }
    if (type != '') {
      key += type!;
    }
    if (isUserOnline != '') {
      key += isUserOnline ?? '';
    }

    return key;
  }
}
