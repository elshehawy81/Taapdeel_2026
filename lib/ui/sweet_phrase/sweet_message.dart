import 'dart:convert';

class SweetMessage {
  SweetMessage({
    required this.sweetMessageId,
    required this.senderUserId,
    required this.senderUserName,
    required this.senderUserImage,
    required this.receiverUserId,
    required this.itemId,
    required this.relationType,
    required this.phraseGroupId,
    required this.phraseId,
    required this.messageCategory,
    required this.messageText,
    required this.messageSource,
    required this.isRead,
    required this.createdAt,
    required this.readAt,
  });

  final String sweetMessageId;
  final String senderUserId;
  final String senderUserName;
  final String senderUserImage;
  final String receiverUserId;
  final String itemId;
  final int relationType;
  final String phraseGroupId;
  final String phraseId;
  final String messageCategory;
  final String messageText;
  final String messageSource;
  final int isRead;
  final String createdAt;
  final String readAt;

  bool get unread => isRead == 0;

  SweetMessage copyWith({
    String? sweetMessageId,
    String? senderUserId,
    String? senderUserName,
    String? senderUserImage,
    String? receiverUserId,
    String? itemId,
    int? relationType,
    String? phraseGroupId,
    String? phraseId,
    String? messageCategory,
    String? messageText,
    String? messageSource,
    int? isRead,
    String? createdAt,
    String? readAt,
  }) {
    return SweetMessage(
      sweetMessageId: sweetMessageId ?? this.sweetMessageId,
      senderUserId: senderUserId ?? this.senderUserId,
      senderUserName: senderUserName ?? this.senderUserName,
      senderUserImage: senderUserImage ?? this.senderUserImage,
      receiverUserId: receiverUserId ?? this.receiverUserId,
      itemId: itemId ?? this.itemId,
      relationType: relationType ?? this.relationType,
      phraseGroupId: phraseGroupId ?? this.phraseGroupId,
      phraseId: phraseId ?? this.phraseId,
      messageCategory: messageCategory ?? this.messageCategory,
      messageText: messageText ?? this.messageText,
      messageSource: messageSource ?? this.messageSource,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  factory SweetMessage.fromMap(Map<String, dynamic> map) {
    return SweetMessage(
      sweetMessageId: (map['sweet_message_id'] ?? '').toString(),
      senderUserId: (map['sender_user_id'] ?? '').toString(),
      senderUserName: (map['sender_user_name'] ?? '').toString(),
      senderUserImage: (map['sender_user_image'] ?? '').toString(),
      receiverUserId: (map['receiver_user_id'] ?? '').toString(),
      itemId: (map['item_id'] ?? '').toString(),
      relationType: int.tryParse((map['relation_type'] ?? '0').toString()) ?? 0,
      phraseGroupId: (map['phrase_group_id'] ?? '').toString(),
      phraseId: (map['phrase_id'] ?? '').toString(),
      messageCategory: (map['message_category'] ?? '').toString(),
      messageText: (map['message_text'] ?? '').toString(),
      messageSource: (map['message_source'] ?? '').toString(),
      isRead: int.tryParse((map['is_read'] ?? '0').toString()) ?? 0,
      createdAt: (map['created_at'] ?? '').toString(),
      readAt: (map['read_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sweet_message_id': sweetMessageId,
      'sender_user_id': senderUserId,
      'sender_user_name': senderUserName,
      'sender_user_image': senderUserImage,
      'receiver_user_id': receiverUserId,
      'item_id': itemId,
      'relation_type': relationType,
      'phrase_group_id': phraseGroupId,
      'phrase_id': phraseId,
      'message_category': messageCategory,
      'message_text': messageText,
      'message_source': messageSource,
      'is_read': isRead,
      'created_at': createdAt,
      'read_at': readAt,
    };
  }

  factory SweetMessage.fromJson(String source) =>
      SweetMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}