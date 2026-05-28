import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/product/paid_id_item_provider.dart';
import 'package:taapdeel/repository/paid_ad_item_repository.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/item/paid_ad/paid_ad_item_horizontal_list_item.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:provider/provider.dart';

import '../../../utils/utils.dart';

class PaidAdItemListView extends StatefulWidget {
  const PaidAdItemListView({Key? key, required this.animationController})
      : super(key: key);

  final AnimationController? animationController;

  @override
  _PaidAdItemListView createState() => _PaidAdItemListView();
}

class _PaidAdItemListView extends State<PaidAdItemListView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  PaidAdItemProvider? _paidAdItemProvider;
  PaidAdItemRepository? repo1;
  PsValueHolder? psValueHolder;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // ✅ safe guards
      if (_paidAdItemProvider == null || psValueHolder == null) return;

      // ✅ threshold قبل النهاية بشوية عشان pagination يبقى سلس
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _paidAdItemProvider!.nextPaidAdItemList(psValueHolder!.loginUserId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<PaidAdItemRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    return ChangeNotifierProvider<PaidAdItemProvider?>(
      lazy: false,
      create: (BuildContext context) {
        final PaidAdItemProvider provider =
        PaidAdItemProvider(repo: repo1, psValueHolder: psValueHolder);

        provider.loadPaidAdItemList(psValueHolder!.loginUserId);
        _paidAdItemProvider = provider;

        return _paidAdItemProvider;
      },
      child: Consumer<PaidAdItemProvider>(
        builder: (BuildContext context, PaidAdItemProvider provider,
            Widget? child) {
          final list = provider.paidAdItemList.data ?? <dynamic>[];

          return Container(
            color: PsColors.baseColor,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(PsDimens.space8),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      return _paidAdItemProvider!.resetPaidAdItemList(
                          provider.psValueHolder!.loginUserId);
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        if (list.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                Utils.getString(context, 'no_data'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: PsColors.textColor3),
                              ),
                            ),
                          ),

                        if (list.isNotEmpty)
                          SliverGrid(
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,

                              // ✅ اتحكم في ارتفاع الكارت:
                              // 1.05 = أقل ارتفاع
                              // 0.95 = متوسط
                              // 0.85 = أعلى
                              childAspectRatio: 0.82,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                final item = list[index];

                                return PaidAdItemHorizontalListItem(
                                  paidAdItem: item,
                                  onTap: () {
                                    final ProductDetailIntentHolder holder =
                                    ProductDetailIntentHolder(
                                      productId: item.item!.id,
                                      heroTagImage: provider.hashCode.toString() +
                                          item.item!.id! +
                                          PsConst.HERO_TAG__IMAGE,
                                      heroTagTitle: provider.hashCode.toString() +
                                          item.item!.id! +
                                          PsConst.HERO_TAG__TITLE,
                                    );

                                    Navigator.pushNamed(
                                      context,
                                      RoutePaths.productDetail,
                                      arguments: holder,
                                    );
                                  },
                                );
                              },
                              childCount: list.length,
                            ),
                          ),

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 90),
                        ),
                      ],
                    ),
                  ),
                ),
                PSProgressIndicator(provider.paidAdItemList.status),
              ],
            ),
          );
        },
      ),
    );
  }
}
