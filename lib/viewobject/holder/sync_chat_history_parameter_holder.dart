

import 'dart:developer';

import 'package:taapdeel/viewobject/common/ps_holder.dart'
    show PsHolder;

class SyncChatHistoryParameterHolder
    extends PsHolder<SyncChatHistoryParameterHolder> {
  SyncChatHistoryParameterHolder({
    required this.itemId,
    required this.buyerUserId,
    required this.sellerUserId,
    required this.type,
    required this.isUserOnline,
     this.buyerItemId,
    required this.message,
  });

  final String? itemId;
  final String? buyerUserId;
  final String? sellerUserId;
  final String? type;
  final String? isUserOnline;
  final String? message;
  final String? buyerItemId;

  @override
  Map<String, dynamic> toMap() {

    final Map<String, dynamic> map = <String, dynamic>{};
    map['item_id'] = itemId;
    map['buyer_user_id'] = buyerUserId;
    map['seller_user_id'] = sellerUserId;
    map['buyer_item_id'] = buyerItemId;
    map['nego_price'] = '0';
    map['type'] = type;
    map['is_user_online'] = isUserOnline;
    map['message'] = message;
    log('map -> $map');
    return map;
  }

  @override
  SyncChatHistoryParameterHolder fromMap(dynamic dynamicData) {
    return SyncChatHistoryParameterHolder(
      itemId: dynamicData['item_id'],
      buyerUserId: dynamicData['buyer_user_id'],
      sellerUserId: dynamicData['seller_user_id'],
      type: dynamicData['type'],
      isUserOnline: dynamicData['is_user_online'],
      message: dynamicData['message'],
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
    if (type != '') {
      key += type!;
    }
    if (isUserOnline != '') {
      key += isUserOnline ?? '';
    }
    if (message != '') {
      key += message ?? '';
    }

    return key;
  }
}
