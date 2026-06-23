class SweetMessageMarkReadRequest {
  SweetMessageMarkReadRequest({
    required this.loginUserId,
    required this.sweetMessageId,
  });

  final String loginUserId;
  final String sweetMessageId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'login_user_id': loginUserId,
      'sweet_message_id': sweetMessageId,
    };
  }
}