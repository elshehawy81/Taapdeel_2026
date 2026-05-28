import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../core/consts.dart';
import '../../modle/user_balance_model.dart';
import '../../payment_provider.dart';
import '../shared/my_dialog.dart';
import '../shared/packages_app_bar.dart';
import 'componants/packages_options.dart';
import 'screen_info_header.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constant/route_paths.dart';

class PackagesScreen extends StatefulWidget {
  PackagesScreen({ this.afterPayment = false});
  bool afterPayment = false;
  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize:PaymentConsts.screenUtilSize);
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
             // appBar: paymentAppBar(context),
              body: FutureBuilder<UserBalanceModel?>(
                  future: getUserData(
                      context: context,
                      apiKey: PaymentConsts.apiKey,
                      userId: PaymentConsts.userID),
                  builder: (context, snap) {
                    if (!snap.hasData || snap.hasError || snap.data == null) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: PaymentConsts.blueColor,
                      ));
                    } else {
                      return SingleChildScrollView(
                          child: Center(
                        child: Column(
                          children: [
                            SizedBox(height:70,),
                            ScreenInfoHeader(model: snap.data!),
                            buildPackagesOptions(context),
                            // FilledButton(
                            //     onPressed: () async {
                            //       try {
                            //         var response = await http.post(
                            //             headers: {
                            //               'Content-Type': 'application/json'
                            //             },
                            //             body: jsonEncode({
                            //               'user_id': PaymentConsts.testUserID,
                            //             }),
                            //
                            //             Uri.parse(
                            //                 'http://taapdeel.com/index.php/rest/Users/points_increase10/api_key/teampsisthebest1'));
                            //         if (response.statusCode == 200) {
                            //           print('Points increased successfully');
                            //         }
                            //       } catch (e) {
                            //         print('Error: $e');
                            //       }
                            //     },
                            //     child: Text('Add Points'))
                            // InkWell(onTap: (){print("To Home");
                            // Navigator.pushReplacementNamed(context,RoutePaths.home);},child:Icon(
                            //   Icons.arrow_back,
                            //   color:PaymentConsts. blueColor,
                            //   size: 34,
                            // ), ),

                          ],
                        ),
                      ));
                    }
                  })),
        ),


        widget.afterPayment == true
            ? LottieBuilder.asset(PaymentConsts.congratsAnimation,
                controller: _controller,

                repeat: false,
                onLoaded: (composition) {
                  if (widget.afterPayment) {
                    _controller
                      ..duration = composition.duration
                      ..forward().then((value) {
                        setState(() {
                          widget.afterPayment = false ;
                        });
                      });
                  }
                },
              )
            : Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox()),
        paymentAppBar(context),
      ],
    );
  }

  Future<UserBalanceModel?> getUserData(
      {required String apiKey,
      required String userId,
      required BuildContext context}) async {
    try {
      final response = await http.get(Uri.parse(
          'http://taapdeel.com/index.php/rest/users/get/api_key/$apiKey/user_id/$userId'));
      if (response.statusCode == 200) {
        UserBalanceModel? userBalanceModel;
        final List<dynamic> responseData = jsonDecode(response.body);
        userBalanceModel = UserBalanceModel.fromJson(responseData[0]);
        Provider.of<PaymentProvider>(context, listen: false)
            .setUserModel(userBalanceModel);
        setState(() {});
        return userBalanceModel;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      showMyDialog(context, const Color.fromARGB(255, 255, 169, 163), 'Error',
          'loading_user_error_msg'.tr(), () {
        Navigator.of(context).pop();
      });
      print(e);
      return null;
    }
  }
}



/*
Future<void> postData() async {
  final url = Uri.parse('http://example.com/api/endpoint');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({'name': 'John Doe', 'email': 'john@example.com'});

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    print('Data Sending Success.');
  } else {
    print('Hata: ${response.statusCode}');
  }
}

Future<void> fetchData() async {
  final url = Uri.parse('http://example.com/api/data');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // final model = MyModel.fromJson(data);
    //  print('Veriler: ${model.name}, ${model.email}');
  } else {
    print('Hata: ${response.statusCode}');
  }
}




//teampsisthebest1
//usrc4671476b2872f12ec4e5848d0619b6b

//PsConst.VALUE_HOLDER__USER_ID

*/

