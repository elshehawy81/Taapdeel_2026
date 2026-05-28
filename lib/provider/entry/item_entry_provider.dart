import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/provider/common/ps_provider.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:http/http.dart' as http;

class ItemEntryProvider extends PsProvider {
  ItemEntryProvider({
    required ProductRepository? repo,
    required this.psValueHolder,
    int limit = 0,
  }) : super(repo, limit) {
    _repo = repo;
    isDispose = false;
    print('Item Entry Provider: $hashCode');

    itemListStream = StreamController<PsResource<Product>>.broadcast();
    subscription = itemListStream.stream.listen((PsResource<Product> resource) {
      if (resource.data != null) {
        _itemResource = resource;
        item = resource.data;
      }

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
  }

  ProductRepository? _repo;
  PsValueHolder? psValueHolder;
  PsResource<Product> _itemResource = PsResource<Product>(
    PsStatus.NOACTION,
    '',
    null,
  );
  PsResource<Product> get itemResource => _itemResource;

  late StreamSubscription<PsResource<Product>> subscription;
  late StreamController<PsResource<Product>> itemListStream;

  Product? item;

  String? categoryId = '';
  String? subCategoryId = '';
  String? itemTypeId = '';
  String? itemConditionId = '';
  String? itemPriceTypeId = '';
  String? itemDealOptionId = '';
  String? itemLocationId = '';
  String? itemLocationTownshipId = '';
  bool isCheckBoxSelect = true;
  String checkOrNotShop = '1';
  String? itemId = '';
  String? avgPrice = "";
  List<String> tags = [];
  List<String> tags_en = [];
  String? tags_confidence = "";
  String? brand = "";

  @override
  void dispose() {
    subscription.cancel();
    isDispose = true;
    print('Item Entry Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> postItemEntry(
      Map<dynamic, dynamic> jsonMap,
      String loginUserId,
      ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _itemResource = await _repo!.postItemEntry(
      jsonMap,
      loginUserId,
      isConnectedToInternet,
      PsStatus.PROGRESS_LOADING,
    );

    return _itemResource;
  }

  Future<dynamic> postSaveTags(
      Map<dynamic, dynamic> jsonMap,
      ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    final saveTagsResp = await _repo!.postSaveTags(
      jsonMap,
      isConnectedToInternet,
      PsStatus.PROGRESS_LOADING,
    );

    return saveTagsResp;
  }


  Future<dynamic> postWishItemEntry(
      Map<dynamic, dynamic> jsonMap,
      String loginUserId,
      ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _itemResource = await _repo!.postWishItemEntry(
      jsonMap,
      loginUserId,
      isConnectedToInternet,
      PsStatus.PROGRESS_LOADING,
    );

    return _itemResource;
  }

  Future<dynamic> getItemFromDB(String? itemId) async {
    isLoading = true;

    await _repo!.getItemFromDB(
      itemId,
      itemListStream,
      PsStatus.PROGRESS_LOADING,
    );
  }

  Future<AiSuggestionResponse> getAiSuggestion(File image) async {
    //const String baseUrl = "http://192.168.1.7:8000";
    const String baseUrl = "https://taapdeel.com/ai";
    final uri = Uri.parse("$baseUrl/product_info");

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final decodedBody = utf8.decode(response.bodyBytes);

      final Map<String, dynamic> jsonData = jsonDecode(decodedBody);

      return AiSuggestionResponse.fromJson(jsonData);
    }
    catch (e, stackTrace) {
      print("UPLOAD ERROR: $e");
      print("STACK TRACE: $stackTrace");
      return AiSuggestionResponse(
        success: false,
        error: ApiError(
          error: "Network error",
          message: "Unable to connect to server.",
          details: [],
        ),
      );
    }
  }
}
class ApiError {
  final String error;
  final String message;
  final List<dynamic> details;

  ApiError({required this.error, required this.message, required this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      error: json['error'] ?? '',
      message: json['message'] ?? '',
      details: json['details'] ?? [],
    );
  }
}

class AiSuggestionResponse {
  final bool success;
  final dynamic productInfo;
  final ApiError? error;

  AiSuggestionResponse({required this.success, this.productInfo, this.error});

  factory AiSuggestionResponse.fromJson(Map<String, dynamic> json) {
    return AiSuggestionResponse(
      success: json['success'] ?? false,
      productInfo: json['product_info'],
      error: json['success'] == false ? ApiError.fromJson(json) : null,
    );
  }
}