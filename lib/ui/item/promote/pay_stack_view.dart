import 'package:flutter/material.dart';
import 'package:taapdeel/provider/promotion/item_promotion_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/viewobject/product.dart';

class PayStackView extends StatelessWidget {
  const PayStackView({
    Key? key,
    required this.product,
    required this.amount,
    required this.howManyDay,
    required this.paymentMethod,
    required this.stripePublishableKey,
    required this.startDate,
    required this.startTimeStamp,
    required this.itemPaidHistoryProvider,
    required this.userProvider,
    required this.payStackKey,
  }) : super(key: key);

  final Product product;
  final String? amount;
  final String? howManyDay;
  final String paymentMethod;
  final String? stripePublishableKey;
  final String? startDate;
  final String startTimeStamp;
  final ItemPromotionProvider itemPaidHistoryProvider;
  final UserProvider userProvider;
  final String? payStackKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paystack (disabled)'),
      ),
      body: const Center(
        child: Text('Paystack integration is disabled in this build.'),
      ),
    );
  }
}
