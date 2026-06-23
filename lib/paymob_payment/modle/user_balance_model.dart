class UserBalanceModel {
  final String userId;
  final String phoneId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final int points;
  final int swapBalance;
  UserBalanceModel({
    required this.userId,
    required this.phoneId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.points,
    required this.swapBalance,
  });

  factory UserBalanceModel.fromJson(Map<String, dynamic> json) {

    return UserBalanceModel(
      userId: json['user_id'] ?? '',
      phoneId: json['phone_id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userPhone: json['user_phone'] ?? '',
      points: json['points'] == null ? 0 : int.parse(json['points']),
      swapBalance:
          json['swap_balance'] == null ? 0 : int.parse(json['swap_balance']),
    );
  }
}
