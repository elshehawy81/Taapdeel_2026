import 'package:flutter/material.dart';
import 'modle/user_balance_model.dart';

class PaymentProvider with ChangeNotifier {
  bool isLoading = false;
  UserBalanceModel? userModel;
  bool redeemDialogLoading = false;

  void changeRedeemDialogLoading(bool loading) {
    redeemDialogLoading = loading;
    notifyListeners();
  }

  void setUserModel(UserBalanceModel userBalanceModel) {
    this.userModel = userBalanceModel;
    notifyListeners();
  }

  UserBalanceModel? getUserModel() {
    return userModel;
  }

  void changeLoading(bool loading) {
    this.isLoading = loading;
    notifyListeners();
  }
}
