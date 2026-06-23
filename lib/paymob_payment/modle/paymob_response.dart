class PaymentPaymobResponse {
  bool success;
  String? transactionID;
  String? responseCode;
  String? message;
  double? amountCents;

  PaymentPaymobResponse({
    required this.success,
    this.transactionID,
    this.responseCode,
    this.message,
    this.amountCents,
  });

  factory PaymentPaymobResponse.fromJson(Map<String, dynamic> json) {
   
    return PaymentPaymobResponse(
        success: bool.parse(json['success'] ?? 'false'),
        transactionID: json['id'],
        message: json['message'],
        responseCode: json['txn_response_code'],
        amountCents: double.parse(json['amount_cents'] ?? '0'));
  }
}
