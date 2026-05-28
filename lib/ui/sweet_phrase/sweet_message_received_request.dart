class SweetMessageReceivedRequest {
  SweetMessageReceivedRequest({
    required this.loginUserId,
    this.limit = 10,
    this.offset = 0,
    this.messageCategory = '',
  });

  final String loginUserId;
  final int limit;
  final int offset;
  final String messageCategory;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'login_user_id': loginUserId,
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (messageCategory.isNotEmpty) 'message_category': messageCategory,
    };
  }
}