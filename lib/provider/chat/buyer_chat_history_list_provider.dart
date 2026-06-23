import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/provider/common/ps_provider.dart';
import 'package:taapdeel/repository/chat_history_repository.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/chat_history.dart';
import 'package:taapdeel/viewobject/holder/chat_history_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/get_chat_history_parameter_holder.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../api/ps_url.dart';
import '../../config/ps_config.dart';
import '../../constant/ps_constants.dart';

class BuyerChatHistoryListProvider extends PsProvider {
  BuyerChatHistoryListProvider(
      {@required ChatHistoryRepository? repo, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    chatHistoryListStream =
        StreamController<PsResource<List<ChatHistory>>>.broadcast();

    subscription = chatHistoryListStream!.stream
        .listen((PsResource<List<ChatHistory>> resource) {
      updateOffset(resource.data!.length);

      _chatHistoryList = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }

  // PsResource<ChatHistory> _chatHistory =
  //     PsResource<ChatHistory>(PsStatus.NOACTION, '', null);
  // PsResource<ChatHistory> get chatHistory => _chatHistory;

  final ChatHistoryParameterHolder chatFromBuyerParameterHolder =
      ChatHistoryParameterHolder().getBuyerHistoryList();
  bool showProgress = true;
  ChatHistoryRepository? _repo;
  PsResource<List<ChatHistory>> _chatHistoryList =
      PsResource<List<ChatHistory>>(PsStatus.NOACTION, '', <ChatHistory>[]);

  PsResource<List<ChatHistory>> get chatHistoryList => _chatHistoryList;
  late StreamSubscription<PsResource<List<ChatHistory>>> subscription;
  StreamController<PsResource<List<ChatHistory>>>? chatHistoryListStream;
  dynamic daoSubscription;
  StreamController<PsResource<ChatHistory>>? chatHistoryStream;

  @override
  void dispose() {
    subscription.cancel();
    if (daoSubscription != null) {
      daoSubscription.cancel();
    }
    isDispose = true;
    super.dispose();
  }

  void resetShowProgress(bool show) {
    showProgress = show;
  }

  Future<dynamic> loadChatHistoryList(ChatHistoryParameterHolder holder) async {
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    // daoSubscription =
    await _repo!.getChatHistoryList(
        chatHistoryListStream,
        isConnectedToInternet,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        holder);
  }

  Future<dynamic> loadChatHistoryListFromDB(
      ChatHistoryParameterHolder holder) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo!.getChatHistoryListFromDB(
        chatHistoryListStream,
        isConnectedToInternet,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        holder);
  }

  Future<dynamic> nextChatHistoryList(
      ChatHistoryParameterHolder? holder) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;

      await _repo!.getNextPageChatHistoryList(
          chatHistoryListStream,
          isConnectedToInternet,
          limit,
          offset,
          PsStatus.PROGRESS_LOADING,
          holder!);
    }
  }

  Future<void> resetChatHistoryList(ChatHistoryParameterHolder holder) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;

    updateOffset(0);
    await _repo!.getChatHistoryList(
        chatHistoryListStream,
        isConnectedToInternet,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        holder);

    isLoading = false;
  }

  Future<dynamic> resetUnreadMessageCount(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;
    await _repo!.resetUnreadCount(chatHistoryListStream, jsonMap,
        isConnectedToInternet, PsStatus.PROGRESS_LOADING);
  }

  Future<dynamic> getChatHistory(
    GetChatHistoryParameterHolder holder,
  ) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;
    daoSubscription = await _repo!.getChatHistory(chatHistoryListStream, holder,
        isConnectedToInternet, PsStatus.PROGRESS_LOADING);
  }

  Future<List<ChatHistory>> getReceivedList() async {
    final List<ChatHistory> sentList = <ChatHistory>[];

    log('inside ->');
    final Response response = await http.post(
        Uri.parse(
            '${PsConfig.ps_app_url}rest/chat_items/get_buyer_seller_list/api_key/${PsConfig.ps_api_key}'),


        body: <String, String?>{
          'user_id': PsSharedPreferences.instance.shared
              .getString(PsConst.VALUE_HOLDER__USER_ID),
          'return_type': 'seller',
        });
    if(response.statusCode == 200){
      final List decode = json.decode(response.body) as List;
      log('list = $decode');
      for(int x = 0;x<decode.length;x++){
        sentList.add(ChatHistory().fromMap(decode[x]));
      }
    }
    return sentList;
  }

  Future<String> cancelRequest(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_rejected_offer_url}';

    log('JsonMap a-> $jsonMap');

    final Response response = await http
        .post(Uri.parse('${PsConfig.ps_app_url}$url'),
        headers: <String, String>{'content-type': 'application/json'},
        body: const JsonEncoder().convert(jsonMap))
    // ignore: body_might_complete_normally_catch_error
        .catchError((dynamic e) {
      print('** Error Post Data');
      print(e.error);
    });


    log('url -> ${'${PsConfig.ps_app_url}$url'} \nResponse -> ${response.body}');
    return response.statusCode == 200 ? 'success' : 'failed';

  }


}
