class SweetMessageUnreadCountRequest {
  SweetMessageUnreadCountRequest({
    required this.loginUserId,
    this.messageCategory = '',
  });

  final String loginUserId;
  final String messageCategory;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'login_user_id': loginUserId,
      if (messageCategory.isNotEmpty) 'message_category': messageCategory,
    };
  }
}