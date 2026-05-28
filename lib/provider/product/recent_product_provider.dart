import 'dart:async';
import 'dart:convert';

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/provider/common/ps_provider.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/holder/product_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../../api/ps_url.dart';
import '../../config/ps_config.dart';

class RecentProductProvider extends PsProvider {
  RecentProductProvider({required ProductRepository repo, int limit = 0})
      : super(repo, limit) {
    if (limit != 0) {
      super.limit = limit;
    }
    _repo = repo;
    //isDispose = false;
    print('RecentProductProvider : $hashCode');
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    initSubscription();
  }
  late ProductRepository _repo;
  PsResource<List<Product>> _recentProductList =
      PsResource<List<Product>>(PsStatus.NOACTION, '', <Product>[]);
  List<Product> filteredProductsList = <Product>[];
  PsResource<List<Product>> _tempProductList =
      PsResource<List<Product>>(PsStatus.NOACTION, '', <Product>[]);
  final ProductParameterHolder productRecentParameterHolder =
      ProductParameterHolder().getRecentParameterHolder();
  PsResource<List<Product>> get recentProductList => _recentProductList;
  PsResource<List<Product>> get tempProductList => _tempProductList;
  StreamSubscription<PsResource<List<Product>>>? subscription;
  StreamController<PsResource<List<Product>>>? productListStream;

  dynamic daoSubscription;
  Future<void> initSubscription() async {
    if (productListStream != null) {
      await productListStream!.close();
    }

    // ignore: unnecessary_null_comparison
    // if (subscription != null) {
    await subscription?.cancel();
    // }

    productListStream = StreamController<PsResource<List<Product>>>.broadcast();
    subscription =
        productListStream!.stream.listen((PsResource<List<Product>> resource) {
      updateOffset(resource.data!.length);

      print('**** RecentProductProvider ${resource.data!.length}');
      _recentProductList =
          PsResource<List<Product>>(PsStatus.NOACTION, '', <Product>[]);
      _tempProductList = resource;

      for (int i = 0; i < _tempProductList.data!.length; i++) {
        if (_tempProductList.data![i].adType == PsConst.GOOGLE_AD_TYPE) {
          _recentProductList.data!.add(Product(
              id: i.toString() + PsConst.ADMOB_FLAG,
              adType: _tempProductList.data![i].adType));
        } else {
          _recentProductList.data!.add(_tempProductList.data![i]);
        }
      }
      _recentProductList.data =
          Product().checkDuplicate(_recentProductList.data!);

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }

  String loginUserId = PsSharedPreferences.instance.getLoggedUserId();

  Future getFilteredProducts(
      {String filterUrl = PsUrl.ps_explore_url, String catId = ''}) async {
    filteredProductsList.clear();
    notifyListeners();
    final String url =
        '${PsConfig.ps_app_url}$filterUrl/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/login_user_id/$loginUserId';
    print('start url ______ $url\n$catId');
    try {
      final Response response = await http.Client().post(Uri.parse('$url'),
          // headers: <String, String>{'content-type': 'application/json'},
          body: {
            'item_location_id': PsSharedPreferences.instance.shared
                .get(PsConst.VALUE_HOLDER__LOCATION_ID),
            'item_location_township_id': PsSharedPreferences.instance.shared
                .get(PsConst.VALUE_HOLDER__LOCATION_TOWNSHIP_ID),
            'cat_id': catId,
          });
      // body: productRecentParameterHolder.toMap());

      print('responsee => Code = ${response.statusCode} ${response.body}');
      dynamic parsed = json.decode(response.body);

      if (response.statusCode == 200) {
        for (int x = 0; x < parsed.length; x++) {
          filteredProductsList.add(Product().fromMap(parsed[x]));
        }
      } else {
        Fluttertoast.showToast(msg: parsed['message']);
      }
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }

    notifyListeners();
  }

  @override
  void dispose() {
    //_repo.cate.close();
    subscription?.cancel();

    if (daoSubscription != null) {
      daoSubscription.cancel();
    }
    isDispose = true;
    print('Recent Product Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadProductList(String? loginUserId,
      ProductParameterHolder productParameterHolder) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo.getProductList(
        productListStream,
        isConnectedToInternet,
        loginUserId,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        productParameterHolder);

    if (daoSubscription != null) {
      await daoSubscription.cancel();
    }
    await initSubscription();
    daoSubscription = await _repo.subscribeProductList(
        productListStream, PsStatus.PROGRESS_LOADING, productParameterHolder);
  }

  Future<dynamic> resetProductList(String? loginUserId,
      ProductParameterHolder productParameterHolder) async {
    isLoading = true;

    updateOffset(0);

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo.getProductList(
        productListStream,
        isConnectedToInternet,
        loginUserId,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        productParameterHolder);

    if (daoSubscription != null) {
      await daoSubscription.cancel();
    }
    await initSubscription();
    daoSubscription = await _repo.subscribeProductList(
        productListStream, PsStatus.PROGRESS_LOADING, productParameterHolder);

    isLoading = false;
  }

  Future<dynamic> nextProductList(
      String loginUserId, ProductParameterHolder productParameterHolder) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;

      // daoSubscription = await _repo.getProductList(
      //     productListStream,
      //     isConnectedToInternet,
      //     loginUserId,
      //     limit,
      //     offset,
      //     PsStatus.PROGRESS_LOADING,
      //     productParameterHolder);
      await _repo.getProductList(
          productListStream,
          isConnectedToInternet,
          loginUserId,
          limit,
          offset,
          PsStatus.PROGRESS_LOADING,
          productParameterHolder);
    }
  }
}
