import 'dart:convert';

class SweetPhrase {
  SweetPhrase({
    required this.phraseId,
    required this.groupId,
    required this.relationType,
    required this.directionKey,
    required this.tone,
    required this.messageCategory,
    required this.phraseText,
    required this.weight,
    this.senderGender,
    this.receiverGender,
    this.senderAgeBand,
    this.receiverAgeBand,
    this.sortOrder,
  });

  final String phraseId;
  final String groupId;
  final int relationType;
  final String directionKey;
  final String tone;
  final String messageCategory;
  final String phraseText;
  final int weight;
  final String? senderGender;
  final String? receiverGender;
  final String? senderAgeBand;
  final String? receiverAgeBand;
  final int? sortOrder;

  factory SweetPhrase.fromMap(Map<String, dynamic> map) {
    return SweetPhrase(
      phraseId: (map['phrase_id'] ?? '').toString(),
      groupId: (map['group_id'] ?? '').toString(),
      relationType: int.tryParse((map['relation_type'] ?? '0').toString()) ?? 0,
      directionKey: (map['direction_key'] ?? '').toString(),
      tone: (map['tone'] ?? '').toString(),
      messageCategory: (map['message_category'] ?? '').toString(),
      phraseText: (map['phrase_text'] ?? '').toString(),
      weight: int.tryParse((map['weight'] ?? '1').toString()) ?? 1,
      senderGender: map['sender_gender']?.toString(),
      receiverGender: map['receiver_gender']?.toString(),
      senderAgeBand: map['sender_age_band']?.toString(),
      receiverAgeBand: map['receiver_age_band']?.toString(),
      sortOrder: int.tryParse((map['sort_order'] ?? '').toString()),
    );
  }

  factory SweetPhrase.fromJson(String source) =>
      SweetPhrase.fromMap(json.decode(source) as Map<String, dynamic>);
}