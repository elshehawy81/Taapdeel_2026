import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/product/search_product_provider.dart';
import 'package:taapdeel/repository/product_repository.dart';

import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/common/search_bar_view.dart';
import 'package:taapdeel/ui/item/list_with_filter/product_filter_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/product_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../Product/product_widget.dart';


class ProductListWithFilterView extends StatefulWidget {
  const ProductListWithFilterView({
    Key? key,
    required this.productParameterHolder,
    required this.animationController,
    this.changeAppBarTitle,
  }) : super(key: key);

  final ProductParameterHolder productParameterHolder;
  final AnimationController? animationController;
  final String? changeAppBarTitle;

  @override
  _ProductListWithFilterViewState createState() =>
      _ProductListWithFilterViewState();
}

class _ProductListWithFilterViewState extends State<ProductListWithFilterView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TextEditingController searchTextController = TextEditingController();
  SearchProductProvider? _searchProductProvider;
  ProductRepository? repo1;
  PsValueHolder? valueHolder;
  late SearchBarWidget searchBar;

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final String? loginUserId = Utils.checkUserLoginId(valueHolder!);
      _searchProductProvider!.nextProductListByKey(
        loginUserId,
        _searchProductProvider!.productParameterHolder,
      );
    }
  }

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<ProductRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    // ignore: avoid_print
    print('............................Build UI Again ............................');

    return ChangeNotifierProvider<SearchProductProvider?>(
      lazy: false,
      create: (BuildContext context) {
        final SearchProductProvider provider = SearchProductProvider(
          repo: repo1,
          psValueHolder: valueHolder,
          limit: valueHolder!.defaultLoadingLimit!,
        );

        if (valueHolder!.isSubLocation == PsConst.ONE) {
          widget.productParameterHolder.itemLocationTownshipId =
              valueHolder!.locationTownshipId;
        }

        final String? loginUserId = Utils.checkUserLoginId(valueHolder!);
        provider.loadProductListByKey(loginUserId, widget.productParameterHolder);

        _searchProductProvider = provider;
        _searchProductProvider!.productParameterHolder =
            widget.productParameterHolder;

        return _searchProductProvider;
      },
      child: Consumer<SearchProductProvider>(
        builder: (BuildContext context, SearchProductProvider provider,
            Widget? child) {
          final list = provider.productList.data;

          return Column(
            children: <Widget>[
              ProductFilterWidget(
                searchProductProvider: _searchProductProvider,
              ),
              Expanded(
                child: Container(
                  color: PsColors.baseColor,
                  child: Stack(
                    children: <Widget>[
                      // ✅ fix: null-check الأول
                      if (list != null && list.isNotEmpty)
                        Container(
                          color: PsColors.baseColor,
                          margin: const EdgeInsets.only(
                            left: PsDimens.space8,
                            right: PsDimens.space8,
                            top: PsDimens.space4,
                            bottom: PsDimens.space4,
                          ),
                          child: RefreshIndicator(
                            onRefresh: () {
                              final String? loginUserId =
                              Utils.checkUserLoginId(valueHolder!);
                              return provider.resetLatestProductList(
                                loginUserId,
                                _searchProductProvider!.productParameterHolder,
                              );
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


                                      final Product product = list[index];

                                      final String tagKey = '${provider.hashCode}${product.id ?? ''}';

                                      return TaapdeelProductCardItem(
                                        coreTagKey: tagKey,
                                        product: product,
                                        onTap: () {
                                          if (product.id == null) return;

                                          final holder = ProductDetailIntentHolder(
                                            productId: product.id,
                                            heroTagImage: '$tagKey${PsConst.HERO_TAG__IMAGE}',
                                            heroTagTitle: '$tagKey${PsConst.HERO_TAG__TITLE}',
                                          );

                                          Navigator.pushNamed(
                                            context,
                                            RoutePaths.productDetail,
                                            arguments: holder,
                                          );
                                        },

                                        // ✅ Search grid feel
                                        variant: TaapdeelProductCardVariant.normal,
                                        showRotatingBanner: false,
                                        showRelationPanel: false,
                                        showConditionChip: true,
                                      );
                                    },
                                    childCount: list.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (provider.productList.status !=
                          PsStatus.PROGRESS_LOADING &&
                          provider.productList.status != PsStatus.BLOCK_LOADING &&
                          provider.productList.status != PsStatus.NOACTION)
                        Align(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/baseline_empty_item_grey_24.png',
                                  height: 100,
                                  width: 150,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: PsDimens.space32),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: PsDimens.space20,
                                    right: PsDimens.space20,
                                  ),
                                  child: Text(
                                    Utils.getString(context,
                                        'procuct_list__no_result_data'),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(),
                                  ),
                                ),
                                const SizedBox(height: PsDimens.space20),
                              ],
                            ),
                          ),
                        ),

                      PSProgressIndicator(provider.productList.status),
                    ],
                  ),
                ),
              ),

            ],
          );
        },
      ),
    );
  }
}
