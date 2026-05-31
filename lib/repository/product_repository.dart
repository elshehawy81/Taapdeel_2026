// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/api/ps_api_service.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/db/favourite_product_dao.dart';
import 'package:taapdeel/db/follower_item_dao.dart';
import 'package:taapdeel/db/product_dao.dart';
import 'package:taapdeel/db/product_map_dao.dart';
import 'package:taapdeel/db/related_product_dao.dart';
import 'package:taapdeel/repository/Common/ps_repository.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/favourite_product.dart';
import 'package:taapdeel/viewobject/follower_item.dart';
import 'package:taapdeel/viewobject/holder/mark_sold_out_item_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/product_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/product_map.dart';
import 'package:taapdeel/viewobject/related_product.dart';
import 'package:sembast/sembast.dart';

import '../ui/sweet_phrase/sweet_message.dart';

class ProductRepository extends PsRepository {
  ProductRepository(
      {required PsApiService psApiService, required ProductDao productDao}) {
    _psApiService = psApiService;
    _productDao = productDao;
  }
  String primaryKey = 'id';
  String mapKey = 'map_key';
  String addedUserIdKey = 'added_user_id';
  String collectionIdKey = 'collection_id';
  late PsApiService _psApiService;
  late ProductDao _productDao;

  void sinkProductListStream(
      StreamController<PsResource<List<Product>>>? productListStream,
      PsResource<List<Product>>? dataList) {
    if (productListStream != null) {
      productListStream.sink.add(dataList!);
    }
  }

  void sinkFavouriteProductListStream(
      StreamController<PsResource<List<Product>>>? favouriteProductListStream,
      PsResource<List<Product>> dataList) {
    if (favouriteProductListStream != null) {
      favouriteProductListStream.sink.add(dataList);
    }
  }

  void sinkFollowerItemListStream(
      StreamController<PsResource<List<Product>>>? followerItemListStream,
      PsResource<List<Product>> dataList) {
    if (dataList != null && followerItemListStream != null) {
      followerItemListStream.sink.add(dataList);
    }
  }

  void sinkCollectionProductListStream(
      StreamController<PsResource<List<Product>>> collectionProductListStream,
      PsResource<List<Product>> dataList) {
    if (dataList != null && collectionProductListStream != null) {
      collectionProductListStream.sink.add(dataList);
    }
  }

  void sinkItemDetailStream(
      StreamController<PsResource<Product?>>? itemDetailStream,
      PsResource<Product?> data) {
    if (data != null) {
      itemDetailStream!.sink.add(data);
    }
  }

  void sinkRelatedProductListStream(
      StreamController<PsResource<List<Product>>>? relatedProductListStream,
      PsResource<List<Product>> dataList) {
    if (dataList != null && relatedProductListStream != null) {
      relatedProductListStream.sink.add(dataList);
    }
  }

  Future<dynamic> insert(Product? product) async {
    return _productDao.insert(primaryKey, product!);
  }

  Future<dynamic> update(Product product) async {
    return _productDao.update(product);
  }

  Future<dynamic> delete(Product product) async {
    return _productDao.delete(product);
  }

  Future<dynamic> getItemFromDB(String? itemId,
      StreamController<dynamic> itemStream, PsStatus status) async {
    final Finder finder = Finder(filter: Filter.equals(primaryKey, itemId));

    itemStream.sink
        .add(await _productDao.getOne(finder: finder, status: status));
  }

  Future<dynamic> subscribeProductList(
      StreamController<PsResource<List<Product>>>? productListStream,
      PsStatus status,
      ProductParameterHolder holder,
      {bool isLoadFromServer = true}) async {
    // Prepare Holder and Map Dao
    final String paramKey = holder.getParamKey();
    print('SearchProductProvider ' + paramKey);
    final ProductMapDao productMapDao = ProductMapDao.instance;

    // Load from Db and Send to UI
    final dynamic subscription = await _productDao.getAllWithSubscriptionByMap(
        primaryKey: primaryKey,
        mapKey: mapKey,
        paramKey: paramKey,
        mapDao: productMapDao,
        mapObj: ProductMap(),
        status: PsStatus.SUCCESS,
        onDataUpdated: (PsResource<List<Product>>? resultList) {
          print('***<< Data Updated >>*** ' + paramKey);
          if (status != null && status != PsStatus.NOACTION) {
            print(status);
            if (resultList != null && productListStream != null) {
              productListStream.sink.add(resultList);
            }
          } else {
            print('No Action');
          }
        });

    return subscription;
  }


  Future<dynamic> getProductList(
      StreamController<PsResource<List<Product>>>? productListStream,
      bool isConnectedToInternet,
      String? loginUserId,
      int limit,
      int? offset,
      PsStatus status,
      ProductParameterHolder holder,
      {bool isLoadFromServer = true}) async {
    // Prepare Holder and Map Dao
    final String paramKey = holder.getParamKey();
    final ProductMapDao productMapDao = ProductMapDao.instance;

    // Load from Db and Send to UI
    sinkProductListStream(
        productListStream,
        await _productDao.getAllByMap(
            primaryKey, mapKey, paramKey, productMapDao, ProductMap(),
            status: status));

    // Server Call
    if (isConnectedToInternet) {
      final PsResource<List<Product>> _resource = await _psApiService
          .getProductList(holder.toMap(), loginUserId, limit, offset);

      print('Param Key $paramKey');
      if (_resource.status == PsStatus.SUCCESS) {
        // Create Map List
        final List<ProductMap> productMapList = <ProductMap>[];
        int i = 0;
        for (Product data in _resource.data!) {
          productMapList.add(ProductMap(
              id: data.id! + paramKey + i.toString(),
              mapKey: paramKey,
              productId: data.id,
              sorting: i++,
              addedDate: '2019'));
        }

        // Delete and Insert Map Dao
        print('Delete Key $paramKey');

        await productMapDao
            .deleteWithFinder(Finder(filter: Filter.equals(mapKey, paramKey)));
        print('Insert All Key $paramKey');
        await productMapDao.insertAll(primaryKey, productMapList);

        // Insert Product
        await _productDao.insertAll(primaryKey, _resource.data!);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          print('delete all');
          await productMapDao.deleteWithFinder(
              Finder(filter: Filter.equals(mapKey, paramKey)));
        }
      }

      sinkProductListStream(
          productListStream,
          await _productDao.getAllByMap(
              primaryKey, mapKey, paramKey, productMapDao, ProductMap()));

      // // Load updated Data from Db and Send to UI
      // // sinkProductListStream(
      // //     productListStream,
      // //     await _productDao.getAllByMap(
      // //         primaryKey, mapKey, paramKey, productMapDao, ProductMap()));
      // final dynamic subscription =
      //     await _productDao.getAllWithSubscriptionByMap(
      //         primaryKey: primaryKey,
      //         mapKey: mapKey,
      //         paramKey: paramKey,
      //         mapDao: productMapDao,
      //         mapObj: ProductMap(),
      //         status: PsStatus.SUCCESS,
      //         onDataUpdated: (PsResource<List<Product>> resultList) {
      //           print('***<< Data Updated >>***');
      //           if (status != null && status != PsStatus.NOACTION) {
      //             print(status);
      //             productListStream.sink.add(resultList);
      //           } else {
      //             print('No Action');
      //           }
      //         });

      // return subscription;
    }
  }

  Future<dynamic> getNextPageProductList(
      StreamController<PsResource<List<Product>>>? productListStream,
      bool isConnectedToInternet,
      String? loginUserId,
      int limit,
      int? offset,
      PsStatus status,
      ProductParameterHolder holder,
      {bool isLoadFromServer = true}) async {
    final String paramKey = holder.getParamKey();
    final ProductMapDao productMapDao = ProductMapDao.instance;
    // Load from Db and Send to UI
    sinkProductListStream(
        productListStream,
        await _productDao.getAllByMap(
            primaryKey, mapKey, paramKey, productMapDao, ProductMap(),
            status: status));
    if (isConnectedToInternet) {
      final PsResource<List<Product>> _resource = await _psApiService
          .getProductList(holder.toMap(), loginUserId, limit, offset);

      if (_resource.status == PsStatus.SUCCESS) {
        // Create Map List
        final List<ProductMap> productMapList = <ProductMap>[];
        final PsResource<List<ProductMap>> existingMapList = await productMapDao
            .getAll(finder: Finder(filter: Filter.equals(mapKey, paramKey)));

        int i = 0;
        if (existingMapList != null) {
          i = existingMapList.data!.length;
        }
        for (Product data in _resource.data!) {
          productMapList.add(ProductMap(
              id: data.id! + paramKey + i.toString(),
              mapKey: paramKey,
              productId: data.id,
              sorting: i++,
              addedDate: '2019'));
        }

        await productMapDao.insertAll(primaryKey, productMapList);

        // Insert Product
        await _productDao.insertAll(primaryKey, _resource.data!);
      }
      sinkProductListStream(
          productListStream,
          await _productDao.getAllByMap(
              primaryKey, mapKey, paramKey, productMapDao, ProductMap()));
    }
  }

  Future<dynamic> getItemDetail(
      StreamController<PsResource<Product>>? itemDetailStream,
      String? itemId,
      String? loginUserId,
      bool isConnectedToInternet,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    final Finder finder = Finder(filter: Filter.equals(primaryKey, itemId));
    sinkItemDetailStream(itemDetailStream,
        await _productDao.getOne(status: status, finder: finder));

    if (isConnectedToInternet) {
      final PsResource<Product> _resource =
          await _psApiService.getItemDetail(itemId, loginUserId);

      if (_resource.status == PsStatus.SUCCESS) {
        // await _productDao.deleteWithFinder(finder);
        await _productDao.insert(primaryKey, _resource.data!);
      }
      // sinkItemDetailStream(
      //     itemDetailStream, await _productDao.getOne(finder: finder));

      final dynamic subscription = _productDao.getOneWithSubscription(
          status: PsStatus.SUCCESS,
          finder: finder,
          onDataUpdated: (Product? product) {
            if (status != null && status != PsStatus.NOACTION) {
              print(status);
              itemDetailStream!.sink
                  .add(PsResource<Product>(status, '', product));
            } else {
              print('No Action');
            }
          });

      return subscription;
    }
  }

  Future<dynamic> deleteLocalProductCacheById(
      StreamController<PsResource<Product>>? itemDetailStream,
      String? itemId,
      String? loginUserId,
      bool isConnectedToInternet,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    // Prepare Holder and Map Dao
    final Finder finder = Finder(filter: Filter.equals(primaryKey, itemId));

    await _productDao.deleteWithFinder(finder);

    sinkItemDetailStream(
        itemDetailStream, await _productDao.getOne(finder: finder));
  }

  Future<dynamic> deleteLocalProductCacheByUserId(
      StreamController<PsResource<Product>>? itemDetailStream,
      String? loginUserId,
      String? addedUserId,
      bool isConnectedToInternet,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    // Prepare Holder and Map Dao
    final Finder finder =
        Finder(filter: Filter.equals(addedUserIdKey, addedUserId));

    await _productDao.deleteWithFinder(finder);

    sinkItemDetailStream(
        itemDetailStream, await _productDao.getOne(finder: finder));
  }

  Future<dynamic> getItemDetailForFav(
      StreamController<PsResource<Product>>? productDetailStream,
      String? itemId,
      String? loginUserId,
      bool isConnectedToInternet,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    final Finder finder = Finder(filter: Filter.equals(primaryKey, itemId));

    if (isConnectedToInternet) {
      final PsResource<Product> _resource =
          await _psApiService.getItemDetail(itemId, loginUserId);

      if (_resource.status == PsStatus.SUCCESS) {
        // await _productDao.deleteWithFinder(finder);
        await _productDao.insert(primaryKey, _resource.data!);
        sinkItemDetailStream(
            productDetailStream, await _productDao.getOne(finder: finder));
      }
    }
  }

  Future<dynamic> getAllFavouritesList(
      StreamController<PsResource<List<Product>>>? favouriteProductListStream,
      String? loginUserId,
      bool isConnectedToInternet,
      int limit,
      int? offset,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    // Prepare Holder and Map Dao
    // final String paramKey = holder.getParamKey();
    final FavouriteProductDao favouriteProductDao =
        FavouriteProductDao.instance;

    // Load from Db and Send to UI
    sinkFavouriteProductListStream(
        favouriteProductListStream,
        await _productDao.getAllByJoin(
            primaryKey, favouriteProductDao, FavouriteProduct(),
            status: status));

    // Server Call
    if (isConnectedToInternet) {
      final PsResource<List<Product>> _resource =
          await _psApiService.getFavouritesList(loginUserId, limit, offset);

      if (_resource.status == PsStatus.SUCCESS) {
        // Create Map List
        final List<FavouriteProduct> favouriteProductMapList =
            <FavouriteProduct>[];
        int i = 0;
        for (Product data in _resource.data!) {
          favouriteProductMapList.add(FavouriteProduct(
            id: data.id,
            sorting: i++,
          ));
        }

        // Delete and Insert Map Dao
        await favouriteProductDao.deleteAll();
        await favouriteProductDao.insertAll(
            primaryKey, favouriteProductMapList);

        // Insert Product
        await _productDao.insertAll(primaryKey, _resource.data!);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          // Delete and Insert Map Dao
          await favouriteProductDao.deleteAll();
        }
      }
      // Load updated Data from Db and Send to UI
      sinkFavouriteProductListStream(
          favouriteProductListStream,
          await _productDao.getAllByJoin(
              primaryKey, favouriteProductDao, FavouriteProduct()));
    }
  }

  Future<dynamic> getNextPageFavouritesList(
      StreamController<PsResource<List<Product>>>? favouriteProductListStream,
      String? loginUserId,
      bool isConnectedToInternet,
      int limit,
      int? offset,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    final FavouriteProductDao favouriteProductDao =
        FavouriteProductDao.instance;
    // Load from Db and Send to UI
    sinkFavouriteProductListStream(
        favouriteProductListStream,
        await _productDao.getAllByJoin(
            primaryKey, favouriteProductDao, FavouriteProduct(),
            status: status));

    if (isConnectedToInternet) {
      final PsResource<List<Product>> _resource =
          await _psApiService.getFavouritesList(loginUserId, limit, offset);

      if (_resource.status == PsStatus.SUCCESS) {
        // Create Map List
        final List<FavouriteProduct> favouriteProductMapList =
            <FavouriteProduct>[];
        final PsResource<List<FavouriteProduct>> existingMapList =
            await favouriteProductDao.getAll();

        int i = 0;
        if (existingMapList != null) {
          i = existingMapList.data!.length;
        }
        for (Product data in _resource.data!) {
          favouriteProductMapList.add(FavouriteProduct(
            id: data.id,
            sorting: i++,
          ));
        }

        await favouriteProductDao.insertAll(
            primaryKey, favouriteProductMapList);

        // Insert Product
        await _productDao.insertAll(primaryKey, _resource.data!);
      }
      sinkFavouriteProductListStream(
          favouriteProductListStream,
          await _productDao.getAllByJoin(
              primaryKey, favouriteProductDao, FavouriteProduct()));
    }
  }

  Future<PsResource<Product>> postFavourite(Map<dynamic, dynamic> jsonMap,
      bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<Product> _resource =
        await _psApiService.postFavourite(jsonMap);
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<Product>> completer =
          Completer<PsResource<Product>>();
      completer.complete(_resource);
      return completer.future;
    }
  }

  Future<PsResource<ApiStatus>> postTouchCount(Map<dynamic, dynamic> jsonMap,
      bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<ApiStatus> _resource =
        await _psApiService.postTouchCount(jsonMap);
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<ApiStatus>> completer =
          Completer<PsResource<ApiStatus>>();
      completer.complete(_resource);
      return completer.future;
    }
  }

  Future<dynamic> getSimilarItemsByTags(
      StreamController<PsResource<List<Product>>>? productListStream,
      bool isConnectedToInternet,
      String? loginUserId,
      String itemId,
      int limit,
      int? offset,
      PsStatus status, {
        bool isLoadFromServer = true,
      }) async {
    final String paramKey = 'SIMILAR_TAGS_$itemId';
    final ProductMapDao productMapDao = ProductMapDao.instance;

    final int safeOffset = offset ?? 0;
    final bool isFirstPage = safeOffset == 0;

    // 1) Load cached DB first
    sinkProductListStream(
      productListStream,
      await _productDao.getAllByMap(
        primaryKey,
        mapKey,
        paramKey,
        productMapDao,
        ProductMap(),
        status: status,
      ),
    );

    if (isConnectedToInternet && isLoadFromServer) {
      final PsResource<List<Product>> res =
      await _psApiService.getSimilarItemsByTags(
        <String, dynamic>{
          'item_id': itemId,
        },
        loginUserId,
        limit,
        safeOffset,
      );

      final String msg = (res.message ?? '').toLowerCase();
      final bool recordNotFound =
          msg.contains('record not found') || msg.contains('10001');
      final List<Product> serverList = (res.data ?? <Product>[]);
      final bool serverEmpty = serverList.isEmpty || recordNotFound;

      if (res.status == PsStatus.SUCCESS || serverEmpty) {
        if (isFirstPage) {
          await productMapDao.deleteWithFinder(
            Finder(filter: Filter.equals(mapKey, paramKey)),
          );
        }

        if (serverEmpty) {
          sinkProductListStream(
            productListStream,
            PsResource<List<Product>>(
              PsStatus.SUCCESS,
              res.message,
              <Product>[],
            ),
          );
          return;
        }

        final List<ProductMap> maps = <ProductMap>[];
        int i = 0;

        for (final Product p in serverList) {
          maps.add(ProductMap(
            id: '${p.id}$paramKey${i.toString()}',
            mapKey: paramKey,
            productId: p.id,
            sorting: i++,
            addedDate: '2019',
          ));
        }

        await productMapDao.insertAll(primaryKey, maps);
        await _productDao.insertAll(primaryKey, serverList);
      }

      sinkProductListStream(
        productListStream,
        await _productDao.getAllByMap(
          primaryKey,
          mapKey,
          paramKey,
          productMapDao,
          ProductMap(),
        ),
      );
    }
  }

  Future<dynamic> getNextPageSimilarItemsByTags(
      StreamController<PsResource<List<Product>>>? productListStream,
      bool isConnectedToInternet,
      String? loginUserId,
      String itemId,
      int limit,
      int? offset,
      PsStatus status, {
        bool isLoadFromServer = true,
      }) async {
    final String paramKey = 'SIMILAR_TAGS_$itemId';
    final ProductMapDao productMapDao = ProductMapDao.instance;

    final int safeOffset = offset ?? 0;

    // 1) Keep current DB list on UI
    sinkProductListStream(
      productListStream,
      await _productDao.getAllByMap(
        primaryKey,
        mapKey,
        paramKey,
        productMapDao,
        ProductMap(),
        status: status,
      ),
    );

    if (isConnectedToInternet && isLoadFromServer) {
      final PsResource<List<Product>> res =
      await _psApiService.getSimilarItemsByTags(
        <String, dynamic>{
          'item_id': itemId,
        },
        loginUserId,
        limit,
        safeOffset,
      );

      final String msg = (res.message ?? '').toLowerCase();
      final bool recordNotFound =
          msg.contains('record not found') || msg.contains('10001');
      final List<Product> serverList = (res.data ?? <Product>[]);
      final bool serverEmpty = serverList.isEmpty || recordNotFound;

      if (serverEmpty) {
        sinkProductListStream(
          productListStream,
          await _productDao.getAllByMap(
            primaryKey,
            mapKey,
            paramKey,
            productMapDao,
            ProductMap(),
          ),
        );
        return;
      }

      if (res.status == PsStatus.SUCCESS) {
        final PsResource<List<ProductMap>> existing = await productMapDao.getAll(
          finder: Finder(filter: Filter.equals(mapKey, paramKey)),
        );

        int i = (existing.data?.length ?? 0);
        final List<ProductMap> maps = <ProductMap>[];

        for (final Product p in serverList) {
          maps.add(ProductMap(
            id: '${p.id}$paramKey${i.toString()}',
            mapKey: paramKey,
            productId: p.id,
            sorting: i++,
            addedDate: '2019',
          ));
        }

        await productMapDao.insertAll(primaryKey, maps);
        await _productDao.insertAll(primaryKey, serverList);
      }

      sinkProductListStream(
        productListStream,
        await _productDao.getAllByMap(
          primaryKey,
          mapKey,
          paramKey,
          productMapDao,
          ProductMap(),
        ),
      );
    }
  }

  Future<dynamic> getRelatedProductList(
      StreamController<PsResource<List<Product>>>? relatedProductListStream,
      String productId,
      String categoryId,
      String loginUserId,
      bool isConnectedToInternet,
      int limit,
      int? offset,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    // Prepare Holder and Map Dao
    final RelatedProductDao relatedProductDao = RelatedProductDao.instance;

    // Load from Db and Send to UI
    sinkRelatedProductListStream(
        relatedProductListStream,
        await _productDao.getAllByJoin(
            primaryKey, relatedProductDao, RelatedProduct(),
            status: status));

    // Server Call
    if (isConnectedToInternet) {
      final PsResource<List<Product>> _resource =
          await _psApiService.getRelatedProductList(
              productId, categoryId, loginUserId, limit, offset);

      if (_resource.status == PsStatus.SUCCESS) {
        // Create Map List
        final List<RelatedProduct> relatedProductMapList = <RelatedProduct>[];
        int i = 0;
        for (Product data in _resource.data!) {
          relatedProductMapList.add(RelatedProduct(
            id: data.id,
            sorting: i++,
          ));
        }

        // Delete and Insert Map Dao
        await relatedProductDao.deleteAll();
        await relatedProductDao.insertAll(primaryKey, relatedProductMapList);

        // Insert Product
        await _productDao.insertAll(primaryKey, _resource.data!);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          // Delete and Insert Map Dao
          await relatedProductDao.deleteAll();
        }
      }
      // Load updated Data from Db and Send to UI
      sinkRelatedProductListStream(
          relatedProductListStream,
          await _productDao.getAllByJoin(
              primaryKey, relatedProductDao, RelatedProduct()));
    }
  }

  Future<dynamic> getAllItemListFromFollower(
      StreamController<PsResource<List<Product>>>? itemListFromFollowersStream,
      Map<dynamic, dynamic> jsonMap,
      bool isConnectedToInternet,
      String? loginUserId,
      int limit,
      int? offset,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    // Prepare Holder and Map Dao
    final FollowerItemDao followerItemDao = FollowerItemDao.instance;

    // Load from Db and Send to UI
    sinkFollowerItemListStream(
        itemListFromFollowersStream,
        await _productDao.getAllByJoin(
            primaryKey, followerItemDao, FollowerItem(),
            status: status));

    // Server Call
    if (isConnectedToInternet) {
      final PsResource<List<Product>> _resource = await _psApiService
          .getAllItemListFromFollower(jsonMap, loginUserId, limit, offset);

      if (_resource.status == PsStatus.SUCCESS) {
        // Create Map List
        final List<FollowerItem> followerItemMapList = <FollowerItem>[];
        int i = 0;
        for (Product data in _resource.data!) {
          followerItemMapList.add(FollowerItem(
            id: data.id,
            sorting: i++,
          ));
        }

        // Delete and Insert Map Dao
        await followerItemDao.deleteAll();
        await followerItemDao.insertAll(primaryKey, followerItemMapList);

        // Insert Product
        await _productDao.insertAll(primaryKey, _resource.data!);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          // Delete and Insert Map Dao
          await followerItemDao.deleteAll();
        }
      }
      // Load updated Data from Db and Send to UI
      // sinkFollowerItemListStream(
      //     itemListFromFollowersStream,
      //     await _productDao.getAllByJoin(
      //         primaryKey, followerItemDao, FollowerItem()));

      final dynamic subscription =
          await _productDao.getAllWithSubscriptionByJoin(
              primaryKey: primaryKey,
              mapDao: followerItemDao,
              mapObj: FollowerItem(),
              status: PsStatus.SUCCESS,
              onDataUpdated: (PsResource<List<Product>> resultList) {
                print('***<< Data Updated >>***');
                if (status != null && status != PsStatus.NOACTION) {
                  print(status);
                  itemListFromFollowersStream!.sink.add(resultList);
                } else {
                  print('No Action');
                }
              });

      return subscription;
    }
  }

  Future<dynamic> getNextPageItemListFromFollower(
      StreamController<PsResource<List<Product>>>? itemListFromFollowersStream,
      Map<dynamic, dynamic> jsonMap,
      bool isConnectedToInternet,
      String loginUserId,
      int limit,
      int? offset,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    final FollowerItemDao followerItemDao = FollowerItemDao.instance;
    // Load from Db and Send to UI
    sinkFollowerItemListStream(
        itemListFromFollowersStream,
        await _productDao.getAllByJoin(
            primaryKey, followerItemDao, FollowerItem(),
            status: status));

    if (isConnectedToInternet) {
      final PsResource<List<Product>> _resource = await _psApiService
          .getAllItemListFromFollower(jsonMap, loginUserId, limit, offset);

      if (_resource.status == PsStatus.SUCCESS) {
        // Create Map List
        final List<FollowerItem> followerItemMapList = <FollowerItem>[];
        final PsResource<List<FollowerItem>> existingMapList =
            await followerItemDao.getAll();

        int i = 0;
        if (existingMapList != null) {
          i = existingMapList.data!.length;
        }
        for (Product data in _resource.data!) {
          followerItemMapList.add(FollowerItem(
            id: data.id,
            sorting: i++,
          ));
        }

        await followerItemDao.insertAll(primaryKey, followerItemMapList);

        // Insert Product
        await _productDao.insertAll(primaryKey, _resource.data!);
      }
      sinkFavouriteProductListStream(
          itemListFromFollowersStream,
          await _productDao.getAllByJoin(
              primaryKey, followerItemDao, FollowerItem()));
    }
  }
  Future<dynamic> getFamilyItems(
      StreamController<PsResource<List<Product>>>? productListStream,
      bool isConnectedToInternet,
      String? loginUserId,
      int limit,
      int? offset,
      PsStatus status, {
        bool isLoadFromServer = true,
      }) async
  {
    final String paramKey = 'FAMILY_${loginUserId ?? ''}';
    final ProductMapDao productMapDao = ProductMapDao.instance;

    // Load from DB
    sinkProductListStream(
      productListStream,
      await _productDao.getAllByMap(
        primaryKey, mapKey, paramKey, productMapDao, ProductMap(),
        status: status,
      ),
    );

    if (isConnectedToInternet && loginUserId != null && loginUserId.isNotEmpty) {
      final Map<String, dynamic> jsonMap = <String, dynamic>{
        'user_id': loginUserId,
      };

      final PsResource<List<Product>> resource =
      await _psApiService.getFamilyItems(jsonMap, loginUserId, limit, offset);

      if (resource.status == PsStatus.SUCCESS) {
        // Replace maps (first page)
        final List<ProductMap> productMapList = <ProductMap>[];
        int i = 0;
        for (final Product p in resource.data ?? <Product>[]) {
          productMapList.add(ProductMap(
            id: '${p.id}$paramKey${i.toString()}',
            mapKey: paramKey,
            productId: p.id,
            sorting: i++,
            addedDate: '2019',
          ));
        }

        await productMapDao.deleteWithFinder(
          Finder(filter: Filter.equals(mapKey, paramKey)),
        );
        await productMapDao.insertAll(primaryKey, productMapList);

        await _productDao.insertAll(primaryKey, resource.data ?? <Product>[]);
      }

      // send updated DB to stream
      sinkProductListStream(
        productListStream,
        await _productDao.getAllByMap(
          primaryKey, mapKey, paramKey, productMapDao, ProductMap(),
        ),
      );
    }
  }

  Future<dynamic> getItemListByUserId(
      StreamController<PsResource<List<Product>>>? productListStream,
      String? loginUserId,
      bool isConnectedToInternet,
      int limit,
      int? offset,
      PsStatus status,
      ProductParameterHolder holder,
      {bool isLoadFromServer = true}) async
  {
    // Prepare Holder and Map Dao
    final String paramKey = holder.getParamKey();
    final ProductMapDao productMapDao = ProductMapDao.instance;

    // Load from Db and Send to UI
    sinkProductListStream(
        productListStream,
        await _productDao.getAllByMap(
            primaryKey, mapKey, paramKey, productMapDao, ProductMap(),
            status: status));

    // Server Call
    if (isConnectedToInternet) {
      final PsResource<List<Product>> _resource = await _psApiService
          .getItemListByUserId(holder.toMap(), loginUserId, limit, offset);

      print('Param Key $paramKey');
      if (_resource.status == PsStatus.SUCCESS) {
        // Create Map List
        final List<ProductMap> productMapList = <ProductMap>[];
        int i = 0;
        for (Product data in _resource.data!) {
          productMapList.add(ProductMap(
              id: data.id! + paramKey,
              mapKey: paramKey,
              productId: data.id,
              sorting: i++,
              addedDate: '2019'));
        }

        // Delete and Insert Map Dao
        print('Delete Key $paramKey');
        await productMapDao
            .deleteWithFinder(Finder(filter: Filter.equals(mapKey, paramKey)));
        print('Insert All Key $paramKey');

        await productMapDao.insertAll(primaryKey, productMapList);

        // Insert Product
        await _productDao.insertAll(primaryKey, _resource.data!);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          // Delete and Insert Map Dao
          await productMapDao.deleteWithFinder(
              Finder(filter: Filter.equals(mapKey, paramKey)));
        }
      }

      final dynamic subscription =
          await _productDao.getAllWithSubscriptionByMap(
              primaryKey: primaryKey,
              mapKey: mapKey,
              paramKey: paramKey,
              mapDao: productMapDao,
              mapObj: ProductMap(),
              status: PsStatus.SUCCESS,
              onDataUpdated: (PsResource<List<Product>> resultList) {
                print('***<< Data Updated >>***');
                if (status != null && status != PsStatus.NOACTION) {
                  print(status);
                  productListStream!.sink.add(resultList);
                } else {
                  print('No Action');
                }
              });

      return subscription;
    }
  }

  Future<dynamic> getFamilyItemsByUserId(
      StreamController<PsResource<List<Product>>>? productListStream,
      bool isConnectedToInternet,
      String? loginUserId, // headers/analytics
      String profileUserId, // ✅ body user_id
      int limit,
      int? offset,
      PsStatus status, {
        bool isLoadFromServer = true,
      }) async
  {
    final String paramKey = 'FAMILY_$profileUserId';
    final ProductMapDao productMapDao = ProductMapDao.instance;

    final int safeOffset = offset ?? 0;
    final bool isFirstPage = safeOffset == 0;

    // 1) Load from DB (optional: show cached first)
    sinkProductListStream(
      productListStream,
      await _productDao.getAllByMap(
        primaryKey,
        mapKey,
        paramKey,
        productMapDao,
        ProductMap(),
        status: status,
      ),
    );

    if (isConnectedToInternet && isLoadFromServer) {
      final PsResource<List<Product>> res = await _psApiService.getFamilyItems(
        <String, dynamic>{'user_id': profileUserId},
        loginUserId ?? '',
        limit,
        safeOffset,
      );

      // ✅ treat "record not found" as empty
      final String msg = (res.message ?? '').toLowerCase();
      final bool recordNotFound = msg.contains('record not found') || msg.contains('10001');
      final List<Product> serverList = (res.data ?? <Product>[]);
      final bool serverEmpty = serverList.isEmpty || recordNotFound;

      if (res.status == PsStatus.SUCCESS || serverEmpty) {
        // ✅ IMPORTANT: on first page, ALWAYS replace DB map with server result (even if empty)
        if (isFirstPage) {
          await productMapDao.deleteWithFinder(
            Finder(filter: Filter.equals(mapKey, paramKey)),
          );
        }

        if (serverEmpty) {
          final dbRes = await _productDao.getAllByMap(
            primaryKey,
            mapKey,
            paramKey,
            productMapDao,
            ProductMap(),
          );

          // ✅ server says empty => ensure UI becomes empty too
          sinkProductListStream(
            productListStream,
            PsResource<List<Product>>(PsStatus.SUCCESS, res.message, <Product>[]),
          );
          return;
        }

        // Build maps from server data
        final List<ProductMap> maps = <ProductMap>[];
        int i = 0;

        for (final Product p in serverList) {
          maps.add(ProductMap(
            id: '${p.id}$paramKey${i.toString()}',
            mapKey: paramKey,
            productId: p.id,
            sorting: i++,
            addedDate: '2019',
          ));
        }

        // Replace maps (first page) or append (not expected here normally)
        await productMapDao.insertAll(primaryKey, maps);
        await _productDao.insertAll(primaryKey, serverList);
      }

      // 3) Send updated DB result
      sinkProductListStream(
        productListStream,
        await _productDao.getAllByMap(
          primaryKey,
          mapKey,
          paramKey,
          productMapDao,
          ProductMap(),
        ),
      );
    }
  }

  Future<dynamic> getNextPageFamilyItemsByUserId(
      StreamController<PsResource<List<Product>>>? productListStream,
      bool isConnectedToInternet,
      String? loginUserId,
      String profileUserId, // ✅ body user_id
      int limit,
      int? offset,
      PsStatus status, {
        bool isLoadFromServer = true,
      }) async {
    final String paramKey = 'FAMILY_$profileUserId';
    final ProductMapDao productMapDao = ProductMapDao.instance;

    final int safeOffset = offset ?? 0;

    // 1) Load from DB first (keep current list in UI)
    sinkProductListStream(
      productListStream,
      await _productDao.getAllByMap(
        primaryKey,
        mapKey,
        paramKey,
        productMapDao,
        ProductMap(),
        status: status,
      ),
    );

    if (isConnectedToInternet && isLoadFromServer) {
      final PsResource<List<Product>> res = await _psApiService.getFamilyItems(
        <String, dynamic>{'user_id': profileUserId},
        loginUserId ?? '',
        limit,
        safeOffset,
      );

      final String msg = (res.message ?? '').toLowerCase();
      final bool recordNotFound = msg.contains('record not found') || msg.contains('10001');
      final List<Product> serverList = (res.data ?? <Product>[]);
      final bool serverEmpty = serverList.isEmpty || recordNotFound;

      // ✅ if server empty => stop pagination without changing current DB list
      if (serverEmpty) {
        sinkProductListStream(
          productListStream,
          await _productDao.getAllByMap(
            primaryKey,
            mapKey,
            paramKey,
            productMapDao,
            ProductMap(),
          ),
        );
        return;
      }

      if (res.status == PsStatus.SUCCESS) {
        final PsResource<List<ProductMap>> existing = await productMapDao.getAll(
          finder: Finder(filter: Filter.equals(mapKey, paramKey)),
        );

        int i = (existing.data?.length ?? 0);
        final List<ProductMap> maps = <ProductMap>[];

        for (final Product p in serverList) {
          maps.add(ProductMap(
            id: '${p.id}$paramKey${i.toString()}',
            mapKey: paramKey,
            productId: p.id,
            sorting: i++,
            addedDate: '2019',
          ));
        }

        await productMapDao.insertAll(primaryKey, maps);
        await _productDao.insertAll(primaryKey, serverList);
      }

      sinkProductListStream(
        productListStream,
        await _productDao.getAllByMap(
          primaryKey,
          mapKey,
          paramKey,
          productMapDao,
          ProductMap(),
        ),
      );
    }
  }



  Future<dynamic> getNextPageItemListByUserId(
      StreamController<PsResource<List<Product>>>? productListStream,
      String? loginUserId,
      bool isConnectedToInternet,
      int limit,
      int? offset,
      PsStatus status,
      ProductParameterHolder holder,
      {bool isLoadFromServer = true}) async {
    final String paramKey = holder.getParamKey();
    final ProductMapDao productMapDao = ProductMapDao.instance;
    // Load from Db and Send to UI
    sinkProductListStream(
        productListStream,
        await _productDao.getAllByMap(
            primaryKey, mapKey, paramKey, productMapDao, ProductMap(),
            status: status));
    if (isConnectedToInternet) {
      final PsResource<List<Product>> _resource = await _psApiService
          .getItemListByUserId(holder.toMap(), loginUserId, limit, offset);

      if (_resource.status == PsStatus.SUCCESS) {
        // Create Map List
        final List<ProductMap> productMapList = <ProductMap>[];
        final PsResource<List<ProductMap>> existingMapList = await productMapDao
            .getAll(finder: Finder(filter: Filter.equals(mapKey, paramKey)));

        int i = 0;
        if (existingMapList != null) {
          i = existingMapList.data!.length;
        }
        for (Product data in _resource.data!) {
          productMapList.add(ProductMap(
              id: data.id! + paramKey,
              mapKey: paramKey,
              productId: data.id,
              sorting: i++,
              addedDate: '2019'));
        }

        await productMapDao.insertAll(primaryKey, productMapList);

        // Insert Product
        await _productDao.insertAll(primaryKey, _resource.data!);
      }
      sinkProductListStream(
          productListStream,
          await _productDao.getAllByMap(
              primaryKey, mapKey, paramKey, productMapDao, ProductMap()));
    }
  }

  /// Mark As sold
  Future<dynamic> markSoldOutItem(
      StreamController<PsResource<Product>>? markSoldOutStream,
      String? loginUserId,
      bool isConnectedToInternet,
      PsStatus status,
      MarkSoldOutItemParameterHolder? holder,
      {bool isLoadFromServer = true}) async {
    sinkItemDetailStream(
        markSoldOutStream, await _productDao.getOne(status: status));

    if (isConnectedToInternet) {
      final PsResource<Product> _resource =
          await _psApiService.markSoldOutItem(holder!.toMap(), loginUserId);

      if (_resource.status == PsStatus.SUCCESS) {
        //await _productDao.deleteAll();
        await _productDao.update(_resource.data!);
        sinkItemDetailStream(markSoldOutStream, await _productDao.getOne());
      }
    }
  }

  Future<PsResource<Product>> postItemEntry(Map<dynamic, dynamic> jsonMap,
      String loginUserId, bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<Product> _resource =
        await _psApiService.postItemEntry(jsonMap, loginUserId);

    if (_resource.status == PsStatus.SUCCESS) {
      await insert(_resource.data);
      return _resource;
    } else {
      final Completer<PsResource<Product>> completer =
          Completer<PsResource<Product>>();
      completer.complete(_resource);
      return completer.future;
    }
  }

  Future<PsResource<ApiStatus>> postSaveTags(Map<dynamic, dynamic> jsonMap, bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<ApiStatus> _resource =
    await _psApiService.postSaveTags(jsonMap);

    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<ApiStatus>> completer =
      Completer<PsResource<ApiStatus>>();
      completer.complete(_resource);
      return completer.future;
    }
  }

  Future<PsResource<Product>> postWishItemEntry(Map<dynamic, dynamic> jsonMap,
      String loginUserId, bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<Product> _resource =
        await _psApiService.postWishItemEntry(jsonMap, loginUserId);

    if (_resource.status == PsStatus.SUCCESS) {
      await insert(_resource.data);
      return _resource;
    } else {
      final Completer<PsResource<Product>> completer =
          Completer<PsResource<Product>>();
      completer.complete(_resource);
      return completer.future;
    }
  }

  ///
  /// For Delete item
  ///
  Future<PsResource<ApiStatus>> userDeleteItem(Map<dynamic, dynamic> jsonMap,
      bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<ApiStatus> _resource =
        await _psApiService.deleteItem(jsonMap);
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<ApiStatus>> completer =
          Completer<PsResource<ApiStatus>>();
      completer.complete(_resource);
      return completer.future;
    }
  }

  /// Swap Products
  Future getSwapProducts() async {}
}
