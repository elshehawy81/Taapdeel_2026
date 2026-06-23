import 'dart:convert';

import 'package:taapdeel/api/ps_url.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/viewobject/user.dart';
import 'package:http/http.dart' as http;

class SwapWebServices {
  Future<String?> getSwapBalance(String userId) async {
    try {
      print('SWAP START');
      const String url =
          '${PsConfig.ps_app_url}${PsUrl.ps_check_swap_balance_url}';

      print('SWAP User: ');
      print(User().userId);
      final http.Response response = await http.post(Uri.parse(url),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          },
          //body: jsonEncode({'user_id': 'usra6e7e52ec3b508776151d6b3c6b1164e'}));
          body: jsonEncode({'user_id': userId}));

      return jsonDecode(response.body)['status'];
    } catch (e) {
      print('SWAP ' + e.toString());
    }
    return null;
  }

  Future<String?> decrementSwapBalance(String userId) async {
    try {
      print('SWAP START');
      const String url =
          '${PsConfig.ps_app_url}${PsUrl.ps_swap_balance_decrease_url}';

      print('SWAP User: ');
      print(User().userId);
      final http.Response response = await http.post(Uri.parse(url),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          },
          //body: jsonEncode({'user_id': 'usra6e7e52ec3b508776151d6b3c6b1164e'}));
          body: jsonEncode({'user_id': userId}));
      print('Decrement Swap');
      print(jsonDecode(response.body));
      return jsonDecode(response.body)['status'];
    } catch (e) {
      print('SWAP ' + e.toString());
    }
    return null;
  }

  Future<String?> incrementSwapBalance(String userId) async {
    try {
      print('SWAP START');
      const String url =
          '${PsConfig.ps_app_url}${PsUrl.ps_swap_balance_increase_url}';

      print('SWAP User: ');
      print(User().userId);
      final http.Response response = await http.post(Uri.parse(url),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          },
          //body: jsonEncode({'user_id': 'usra6e7e52ec3b508776151d6b3c6b1164e'}));
          body: jsonEncode({'user_id': userId}));
      return jsonDecode(response.body)['status'];
    } catch (e) {
      print('SWAP ' + e.toString());
    }
    return null;
  }

  Future<String?> incrementSwapNumber(String userId) async {
    try {
      print('SWAP START');
      const String url =
          '${PsConfig.ps_app_url}${PsUrl.ps_swap_no_increase_url}';

      print('SWAP User: ');
      print(User().userId);
      final http.Response response = await http.post(Uri.parse(url),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          },
          //body: jsonEncode({'user_id': 'usra6e7e52ec3b508776151d6b3c6b1164e'}));
          body: jsonEncode({'user_id': userId}));

      return jsonDecode(response.body)['status'];
    } catch (e) {
      print('SWAP ' + e.toString());
    }
  }
}
