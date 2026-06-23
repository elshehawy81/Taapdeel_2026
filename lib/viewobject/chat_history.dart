import 'dart:developer';

import 'package:taapdeel/viewobject/common/ps_object.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/user.dart';
import 'package:quiver/core.dart';

import 'default_photo.dart';

class ChatHistory extends PsObject<ChatHistory> {
  ChatHistory({
    this.id,
    this.itemId,
    this.buyerItemId,
    this.buyerUserId,
    this.sellerUserId,
    this.negoPrice,
    this.buyerUnreadCount,
    this.sellerUnreadCount,
    this.isAccept,
    this.addedDate,
    this.isOffer,
    this.offerAmount,
    this.offerStatus,
    this.addedDateStr,
    this.photoCount,
    this.isFavourited,
    this.isOwner,
    this.defaultPhoto,
    this.buyerItem,
    this.item,
    this.buyer,
    this.seller,
    this.relationUserId,
    this.relationCode,
    this.relationType,
  });

  String? id;
  String? itemId;
  String? buyerItemId;
  String? buyerUserId;
  String? sellerUserId;
  String? negoPrice;
  String? buyerUnreadCount;
  String? sellerUnreadCount;
  String? isAccept;
  String? addedDate;
  String? isOffer;
  String? offerAmount;
  String? offerStatus;
  String? addedDateStr;
  String? photoCount;
  String? isFavourited;
  String? isOwner;
  DefaultPhoto? defaultPhoto;
  Product? item;
  User? buyer;
  User? seller;
  Product? buyerItem;

  /// [Taapdeel] Relationship between the logged-in viewer and the other party
  /// in this swap request. These fields are returned by:
  /// chat_items/get_buyer_seller_list
  /// chat_items/get_buyer_seller_list_status
  String? relationUserId;
  String? relationCode;
  String? relationType;

  @override
  bool operator ==(dynamic other) => other is ChatHistory && id == other.id;

  @override
  int get hashCode => hash2(id.hashCode, id.hashCode);

  @override
  String getPrimaryKey() {
    return id ?? '';
  }

  String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  @override
  ChatHistory fromMap(dynamic dynamicData) {
    return ChatHistory(
      id: _stringOrNull(dynamicData['id']),
      itemId: _stringOrNull(dynamicData['item_id']),
      buyerItemId: _stringOrNull(dynamicData['buyer_item_id']),
      buyerUserId: _stringOrNull(dynamicData['buyer_user_id']),
      sellerUserId: _stringOrNull(dynamicData['seller_user_id']),
      negoPrice: _stringOrNull(dynamicData['nego_price']),
      buyerUnreadCount: _stringOrNull(dynamicData['buyer_unread_count']),
      sellerUnreadCount: _stringOrNull(dynamicData['seller_unread_count']),
      isAccept: _stringOrNull(dynamicData['is_accept']),
      addedDate: _stringOrNull(dynamicData['added_date']),
      isOffer: _stringOrNull(dynamicData['is_offer']),
      offerAmount: _stringOrNull(dynamicData['offer_amount']),
      offerStatus: _stringOrNull(dynamicData['offer_status']),
      photoCount: _stringOrNull(dynamicData['photo_count']),
      addedDateStr: _stringOrNull(dynamicData['added_date_str']),
      isFavourited: _stringOrNull(dynamicData['is_favourited']),
      isOwner: _stringOrNull(dynamicData['is_owner']),
      relationUserId: _stringOrNull(dynamicData['relation_user_id']),
      relationCode: _stringOrNull(dynamicData['relation_code'])?.toUpperCase(),
      relationType: _stringOrNull(dynamicData['relation_type']),
      defaultPhoto: dynamicData['default_photo'] != null
          ? DefaultPhoto().fromMap(dynamicData['default_photo'])
          : null,
      buyerItem: dynamicData['buyer_item'] != null
          ? Product().fromMap(dynamicData['buyer_item'])
          : null,
      item: dynamicData['item'] != null
          ? Product().fromMap(dynamicData['item'])
          : null,
      buyer: dynamicData['buyer'] != null
          ? User().fromMap(dynamicData['buyer'])
          : null,
      seller: dynamicData['seller'] != null
          ? User().fromMap(dynamicData['seller'])
          : null,
    );
  }

  @override
  Map<String, dynamic>? toMap(dynamic object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['id'] = object.id;
      data['item_id'] = object.itemId;
      data['buyer_item_id'] = object.buyerItemId;
      data['buyer_user_id'] = object.buyerUserId;
      data['seller_user_id'] = object.sellerUserId;
      data['nego_price'] = object.negoPrice;
      data['buyer_unread_count'] = object.buyerUnreadCount;
      data['seller_unread_count'] = object.sellerUnreadCount;
      data['is_accept'] = object.isAccept;
      data['added_date'] = object.addedDate;
      data['is_offer'] = object.isOffer;
      data['offer_status'] = object.offerStatus;
      data['offer_amount'] = object.offerAmount;
      data['added_date_str'] = object.addedDateStr;
      data['photo_count'] = object.photoCount;
      data['is_favourited'] = object.isFavourited;
      data['is_owner'] = object.isOwner;
      data['relation_user_id'] = object.relationUserId;
      data['relation_code'] = object.relationCode;
      data['relation_type'] = object.relationType;
      data['default_photo'] = DefaultPhoto().toMap(object.defaultPhoto);
      data['item'] = Product().toMap(object.item);
      data['buyer_item'] = Product().toMap(object.buyerItem);
      data['buyer'] = User().toMap(object.buyer);
      data['seller'] = User().toMap(object.seller);
      return data;
    } else {
      return null;
    }
  }

  @override
  List<ChatHistory> fromMapList(List<dynamic> dynamicDataList) {
    final List<ChatHistory> newFeedList = <ChatHistory>[];
    for (dynamic json in dynamicDataList) {
      if (json != null) {
        newFeedList.add(fromMap(json));
      }
    }
    return newFeedList;
  }

  @override
  List<Map<String, dynamic>?> toMapList(List<dynamic> objectList) {
    final List<Map<String, dynamic>?> dynamicList = <Map<String, dynamic>?>[];

    for (dynamic data in objectList) {
      if (data != null) {
        dynamicList.add(toMap(data));
      }
    }
    return dynamicList;
  }
}
