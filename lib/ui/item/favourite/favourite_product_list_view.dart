import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/product/favourite_item_provider.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../Product/product_widget.dart';


class FavouriteProductListView extends StatefulWidget {
  const FavouriteProductListView({Key? key, required this.animationController})
      : super(key: key);

  final AnimationController? animationController;

  @override
  _FavouriteProductListView createState() => _FavouriteProductListView();
}

class _FavouriteProductListView extends State<FavouriteProductListView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  FavouriteItemProvider? _favouriteItemProvider;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _favouriteItemProvider!.nextFavouriteItemList();
      }
    });

    super.initState();
  }

  ProductRepository? repo1;
  PsValueHolder? psValueHolder;
  dynamic data;
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;

    });
  }

  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<ProductRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);


    // ignore: avoid_print
    print('............................Build UI Again ............................');

    return ChangeNotifierProvider<FavouriteItemProvider?>(
      lazy: false,
      create: (BuildContext context) {
        final FavouriteItemProvider provider =
        FavouriteItemProvider(repo: repo1, psValueHolder: psValueHolder);
        provider.loadFavouriteItemList();
        _favouriteItemProvider = provider;
        return _favouriteItemProvider;
      },
      child: Consumer<FavouriteItemProvider>(
        builder: (BuildContext context, FavouriteItemProvider provider,
            Widget? child) {
          return Column(
            children: <Widget>[

              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                        left: PsDimens.space4,
                        right: PsDimens.space4,
                        top: PsDimens.space4,
                        bottom: PsDimens.space4,
                      ),
                      child: RefreshIndicator(
                        onRefresh: () {
                          return provider.resetFavouriteItemList();
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          slivers: <Widget>[
                            SliverGrid(
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 233,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  // ✅ fix: لازم null-check صح
                                  final list = provider.favouriteItemList.data;

                                  if (list != null && list.isNotEmpty) {
                                    final Product product = list[index];

                                    final String tagKey = provider.hashCode.toString() + product.id!;

                                    return TaapdeelProductCardItem(
                                      coreTagKey: tagKey,
                                      product: product,

                                      onTap: () async {
                                        final ProductDetailIntentHolder holder = ProductDetailIntentHolder(
                                          productId: product.id,
                                          heroTagImage: '$tagKey${PsConst.HERO_TAG__IMAGE}',
                                          heroTagTitle: '$tagKey${PsConst.HERO_TAG__TITLE}',
                                        );

                                        await Navigator.pushNamed(
                                          context,
                                          RoutePaths.productDetail,
                                          arguments: holder,
                                        );

                                        await provider.resetFavouriteItemList();
                                      },

                                      // ✅ Favourite list: خلي الشكل "عادي" واضح
                                      variant: TaapdeelProductCardVariant.normal,
                                      showRotatingBanner: false,
                                      showRelationPanel: false,
                                      showConditionChip: true,

                                      // fav icon فوق يمين الصورة: هنا انت أصلًا في favourites
                                      // فالأفضل تبقى selectedFav=true ويشيل/يرجع من المفضلة
                                      selectedFav: true,
                                      onTapFav: () async {
                                        // لو عندك method لإزالة/تبديل المفضلة، حطها هنا
                                        // مثال (حسب اللي عندك):
                                        // await provider.removeFromFavourite(product.id);
                                        // await provider.resetFavouriteItemList();
                                      },
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                                childCount:
                                provider.favouriteItemList.data?.length ??
                                    0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PSProgressIndicator(provider.favouriteItemList.status),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
