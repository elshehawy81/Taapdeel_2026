import 'dart:async';

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/provider/common/ps_provider.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/product.dart';

class SimilarItemsByTagsProvider extends PsProvider {
  SimilarItemsByTagsProvider({
    required ProductRepository? repo,
    required this.psValueHolder,
    int limit = 10,
  }) : super(repo, limit) {
    _repo = repo;

    print('SimilarItemsByTagsProvider : $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    similarItemsStream =
    StreamController<PsResource<List<Product>>>.broadcast();

    subscription = similarItemsStream!.stream
        .listen((PsResource<List<Product>> resource) {
      _similarItems = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      final int count = resource.data?.length ?? 0;
      if (count < limit) {
        isReachMaxData = true;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }

  ProductRepository? _repo;
  PsValueHolder? psValueHolder;

  PsResource<List<Product>> _similarItems =
  PsResource<List<Product>>(PsStatus.NOACTION, '', <Product>[]);

  PsResource<List<Product>> get similarItems => _similarItems;

  late StreamSubscription<PsResource<List<Product>>> subscription;
  StreamController<PsResource<List<Product>>>? similarItemsStream;

  dynamic daoSubscription;

  String? _itemId;
  String? get itemId => _itemId;

  @override
  void dispose() {
    subscription.cancel();

    if (daoSubscription != null) {
      daoSubscription.cancel();
    }

    isDispose = true;
    print('SimilarItemsByTagsProvider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadSimilarItems(
      String itemId,
      String? loginUserId,
      ) async {
    _itemId = itemId;
    offset = 0;
    isReachMaxData = false;
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    daoSubscription = await _repo!.getSimilarItemsByTags(
      similarItemsStream,
      isConnectedToInternet,
      loginUserId,
      itemId,
      limit,
      offset,
      PsStatus.PROGRESS_LOADING,
    );
  }

  Future<dynamic> nextSimilarItems(
      String itemId,
      String? loginUserId,
      ) async {
    if (!isLoading && !isReachMaxData) {
      isLoading = true;
      isConnectedToInternet = await Utils.checkInternetConnectivity();

      offset = (offset ?? 0) + limit;

      daoSubscription = await _repo!.getNextPageSimilarItemsByTags(
        similarItemsStream,
        isConnectedToInternet,
        loginUserId,
        itemId,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
      );
    }
  }

  Future<void> resetSimilarItems(
      String itemId,
      String? loginUserId,
      ) async {
    _itemId = itemId;
    offset = 0;
    isReachMaxData = false;
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    daoSubscription = await _repo!.getSimilarItemsByTags(
      similarItemsStream,
      isConnectedToInternet,
      loginUserId,
      itemId,
      limit,
      offset,
      PsStatus.BLOCK_LOADING,
    );

    isLoading = false;
  }
}