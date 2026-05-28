import 'package:taapdeel/viewobject/common/ps_object.dart';
import 'package:taapdeel/viewobject/default_photo.dart';

class Noti extends PsObject<Noti> {
  Noti({
    this.id,
    this.userId,
    this.deviceToken,
    this.message,
    this.description,
    this.defaultPhoto,
    this.addedDate,
    this.addedDateStr,
    this.updatedDate,
    this.updatedUserId,
    this.notiType,
    this.title,
    this.body,
    this.targetUserId,
    this.senderUserId,
    this.senderName,
    this.requestId,
    this.chatId,
    this.productId,
    this.senderId,
    this.wishId,
    this.itemId,
    this.relationId,
    this.route,
    this.payload,
    this.isRead,
    this.isPushSent,
  });

  // Legacy fields
  String? id;
  String? userId;
  String? deviceToken;
  String? message;
  String? description;
  DefaultPhoto? defaultPhoto;
  String? addedDate;
  String? addedDateStr;
  String? updatedDate;
  String? updatedUserId;

  // New bs_app_notifications fields
  String? notiType;
  String? title;
  String? body;
  String? targetUserId;
  String? senderUserId;
  String? senderName;
  String? requestId;
  String? chatId;
  String? productId;
  String? senderId;
  String? wishId;
  String? itemId;
  String? relationId;
  String? route;
  String? payload;
  String? isRead;
  String? isPushSent;

  String get displayTitle {
    final String value = (title ?? message ?? '').trim();
    return value.isNotEmpty ? value : 'تنبيه';
  }

  String get displayBody {
    final String value = (body ?? description ?? message ?? '').trim();
    return value;
  }

  Noti copyWith({
    String? id,
    String? userId,
    String? deviceToken,
    String? message,
    String? description,
    DefaultPhoto? defaultPhoto,
    String? addedDate,
    String? addedDateStr,
    String? updatedDate,
    String? updatedUserId,
    String? notiType,
    String? title,
    String? body,
    String? targetUserId,
    String? senderUserId,
    String? senderName,
    String? requestId,
    String? chatId,
    String? productId,
    String? senderId,
    String? wishId,
    String? itemId,
    String? relationId,
    String? route,
    String? payload,
    String? isRead,
    String? isPushSent,
  }) {
    return Noti(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceToken: deviceToken ?? this.deviceToken,
      message: message ?? this.message,
      description: description ?? this.description,
      defaultPhoto: defaultPhoto ?? this.defaultPhoto,
      addedDate: addedDate ?? this.addedDate,
      addedDateStr: addedDateStr ?? this.addedDateStr,
      updatedDate: updatedDate ?? this.updatedDate,
      updatedUserId: updatedUserId ?? this.updatedUserId,
      notiType: notiType ?? this.notiType,
      title: title ?? this.title,
      body: body ?? this.body,
      targetUserId: targetUserId ?? this.targetUserId,
      senderUserId: senderUserId ?? this.senderUserId,
      senderName: senderName ?? this.senderName,
      requestId: requestId ?? this.requestId,
      chatId: chatId ?? this.chatId,
      productId: productId ?? this.productId,
      senderId: senderId ?? this.senderId,
      wishId: wishId ?? this.wishId,
      itemId: itemId ?? this.itemId,
      relationId: relationId ?? this.relationId,
      route: route ?? this.route,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
      isPushSent: isPushSent ?? this.isPushSent,
    );
  }

  @override
  String getPrimaryKey() => id ?? '';

  @override
  Noti fromMap(dynamic dynamicData) {
    if (dynamicData == null) return Noti();

    final String? type = dynamicData['type']?.toString() ??
        dynamicData['noti_type']?.toString() ??
        dynamicData['notification_type']?.toString();

    final String? targetUserId = dynamicData['target_user_id']?.toString() ??
        dynamicData['user_id']?.toString();

    final String? senderUserId = dynamicData['sender_user_id']?.toString() ??
        dynamicData['sender_id']?.toString();

    final String? itemId = dynamicData['item_id']?.toString();
    final String? productId = dynamicData['product_id']?.toString() ?? itemId;

    return Noti(
      id: dynamicData['id']?.toString(),
      userId: dynamicData['user_id']?.toString(),
      deviceToken: dynamicData['device_token']?.toString(),
      message: dynamicData['message']?.toString() ?? dynamicData['title']?.toString(),
      description: dynamicData['description']?.toString() ?? dynamicData['body']?.toString(),
      defaultPhoto: dynamicData['default_photo'] != null
          ? DefaultPhoto().fromMap(dynamicData['default_photo'])
          : null,
      addedDate: dynamicData['added_date']?.toString(),
      addedDateStr: dynamicData['added_date_str']?.toString(),
      updatedDate: dynamicData['updated_date']?.toString(),
      updatedUserId: dynamicData['updated_user_id']?.toString(),
      notiType: type,

      title: dynamicData['title']?.toString() ?? dynamicData['message']?.toString(),
      body: dynamicData['body']?.toString() ?? dynamicData['description']?.toString(),
      targetUserId: targetUserId,
      senderUserId: senderUserId,
      senderName: dynamicData['sender_name']?.toString(),
      requestId: dynamicData['request_id']?.toString(),
      chatId: dynamicData['chat_id']?.toString(),
      productId: productId,
      senderId: senderUserId,
      wishId: dynamicData['wish_id']?.toString(),
      itemId: itemId,
      relationId: dynamicData['relation_id']?.toString(),
      route: dynamicData['route']?.toString(),
      payload: dynamicData['payload']?.toString(),
      isRead: dynamicData['is_read']?.toString() ?? dynamicData['isRead']?.toString() ?? '0',
      isPushSent: dynamicData['is_push_sent']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toMap(dynamic object) {
    if (object == null) return <String, dynamic>{};
    final Noti n = object as Noti;

    return <String, dynamic>{
      'id': n.id,
      'user_id': n.userId,
      'device_token': n.deviceToken,
      'message': n.message,
      'description': n.description,
      'default_photo': n.defaultPhoto != null ? DefaultPhoto().toMap(n.defaultPhoto) : null,
      'added_date': n.addedDate,
      'added_date_str': n.addedDateStr,
      'updated_date': n.updatedDate,
      'updated_user_id': n.updatedUserId,
      'type': n.notiType,
      'noti_type': n.notiType,
      'title': n.title,
      'body': n.body,
      'target_user_id': n.targetUserId,
      'sender_user_id': n.senderUserId,
      'sender_name': n.senderName,
      'request_id': n.requestId,
      'chat_id': n.chatId,
      'product_id': n.productId,
      'sender_id': n.senderId ?? n.senderUserId,
      'wish_id': n.wishId,
      'item_id': n.itemId,
      'relation_id': n.relationId,
      'route': n.route,
      'payload': n.payload,
      'is_read': n.isRead,
      'is_push_sent': n.isPushSent,
    };
  }

  @override
  List<Noti> fromMapList(dynamic dynamicDataList) {
    final List<Noti> notiList = <Noti>[];
    if (dynamicDataList == null) return notiList;

    for (final dynamic data in dynamicDataList) {
      notiList.add(fromMap(data));
    }
    return notiList;
  }

  @override
  List<Map<String, dynamic>?> toMapList(List<Noti> objectList) {
    return objectList.map((Noti n) => toMap(n)).toList();
  }
}
