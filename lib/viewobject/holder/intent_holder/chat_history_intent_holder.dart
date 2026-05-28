class ChatHistoryIntentHolder {
  const ChatHistoryIntentHolder({
    required this.itemId,
    required this.chatFlag,
    required this.buyerUserId,
    required this.sellerUserId,
    //required this.buyerItemId,
  });
  final String? itemId;
  final String chatFlag;
  final String? buyerUserId;
  final String? sellerUserId;
 // final String? buyerItemId;


  Map<String, dynamic> toJson() {
    return <String ,dynamic>{
      'itemId': itemId,
      'chatFlag': chatFlag,
      'buyerUserId': buyerUserId,
      'sellerUserId': sellerUserId,
      'flag':'chat'
    };
  }

  factory ChatHistoryIntentHolder.fromJson(Map<String, dynamic> json) {
    return ChatHistoryIntentHolder(
      itemId: json['itemId']??'',
      chatFlag: json['chatFlag']??'',
      buyerUserId: json['buyerUserId']??'',
      sellerUserId: json['sellerUserId']??'',
     // buyerItemId: json['buyerItemId']??'',
    );
  }
}






// class ChatHistoryIntentHolder {
//   const ChatHistoryIntentHolder({
//     @required this.itemId,
//     @required this.itemName,
//     @required this.itemImgPath,
//     @required this.itemCurrencySymbol,
//     @required this.itemPrice,
//     @required this.itemConditionName,
//     @required this.chatFlag,
//     @required this.buyerUserId,
//     @required this.sellerUserId,
//     @required this.senderName,
//     @required this.senderProflePhoto,
//   });
//   final String itemId;
//   final String itemName;
//   final String itemImgPath;
//   final String itemCurrencySymbol;
//   final String itemPrice;
//   final String itemConditionName;
//   final String chatFlag;
//   final String buyerUserId;
//   final String sellerUserId;
//   final String senderName;
//   final String senderProflePhoto;
// }
