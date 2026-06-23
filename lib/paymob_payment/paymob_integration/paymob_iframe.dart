import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../modle/paymob_response.dart';
import '../payment_provider.dart';
import '../ui/pakages_screen/packages_screen.dart';

class PaymobIFrame extends StatefulWidget {
   PaymobIFrame({
    Key? key,
    required this.redirectURL,
    this.onPayment,
    required this.fromPromoteScreen
  }) : super(key: key);
bool fromPromoteScreen  ;
  final String redirectURL;
  final void Function(PaymentPaymobResponse)? onPayment;

  static Future<PaymentPaymobResponse?> show({
    required BuildContext context,
    required String redirectURL,
    required bool fromPromoteScreen,
    void Function(PaymentPaymobResponse)? onPayment,
  }) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return PaymobIFrame(
              onPayment: onPayment,
              redirectURL: redirectURL,
              fromPromoteScreen:fromPromoteScreen ,
            );
          },
        ),
      );

  @override
  State<PaymobIFrame> createState() => _PaymobIFrameState();
}

class _PaymobIFrameState extends State<PaymobIFrame> {
  WebViewController? controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('txn_response_code') &&
                request.url.contains('success') &&
                request.url.contains('id')) {
              final params = _getParamFromURL(request.url);
              final response = PaymentPaymobResponse.fromJson(params);
              if (widget.onPayment != null) {
                widget.onPayment!(response);
              }

              if( widget.fromPromoteScreen==false){
                Navigator.of(context).
                pushAndRemoveUntil<Widget>(
                    MaterialPageRoute(
                        builder: (context) =>

                            PackagesScreen(
                              afterPayment: response.success ? true : false,
                            )
                    ),
                        (route) => false);
              }else{
                Navigator.pop(context, response);


                // Navigator.of(context).pop();
                // Navigator.of(context).
                // pushAndRemoveUntil<Widget>(
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             PackagesScreen(
                //               afterPayment: response.success ? true : false,
                //             )
                //     ),
                //         (route) => false);

              }

              //Navigator.pop(context, response);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectURL));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: const Text(
          'payment',style: TextStyle(color:Colors.black),
        ).tr(),
      ),
      body: controller == null
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : WebViewWidget(
              controller: controller!,
            ),
    );
  }

  Map<String, dynamic> _getParamFromURL(String url) {
    final uri = Uri.parse(url);
    Map<String, dynamic> data = <String, dynamic>{};
    uri.queryParameters.forEach((key, value) {
      data[key] = value;
    });
    return data;
  }
}

Widget backButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.arrow_back,color:Colors.black),
    onPressed: () {
      Provider.of<PaymentProvider>(context, listen: false).changeLoading(false);
      Navigator.of(context).pop();
    },
  );
}
