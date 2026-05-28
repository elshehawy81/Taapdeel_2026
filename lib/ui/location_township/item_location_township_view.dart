import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/item_location_township/item_location_township_provider.dart';
import 'package:taapdeel/repository/item_location_township_repository.dart';
import 'package:taapdeel/ui/common/base/ps_widget_with_appbar_no_app_bar_title.dart';
import 'package:taapdeel/ui/common/ps_textfield_widget_with_icon.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/location_township/item_location_township_list_item.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/location_parameter_holder.dart';
import 'package:taapdeel/viewobject/item_location_township.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:provider/provider.dart';

class ItemLocationTownshipView extends StatefulWidget {
  const ItemLocationTownshipView(
      {Key? key, required this.cityId, required this.animationController})
      : super(key: key);

  final String cityId;
  final AnimationController? animationController;
  @override
  _ItemLocationTownshipViewState createState() =>
      _ItemLocationTownshipViewState();
}

class _ItemLocationTownshipViewState extends State<ItemLocationTownshipView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late ItemLocationTownshipProvider _itemLocationProvider;
  PsValueHolder? valueHolder;
  // Animation<double> animation;
  int i = 0;
  @override
  void dispose() {
    // animation = null;
    super.dispose();
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _itemLocationProvider.nextItemLocationTownshipListByCityId(
            _itemLocationProvider.latestLocationParameterHolder.toMap(),
            _itemLocationProvider.psValueHolder!.loginUserId,
            widget.cityId);
      }
    });

    super.initState();
  }

  ItemLocationTownshipRepository? repo1;
  dynamic data;

  @override
  Widget build(BuildContext context) {
    // data = EasyLocalizationProvider.of(context).data;
    repo1 = Provider.of<ItemLocationTownshipRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);
    print(
        '............................Build Item Location Townshisssp UI Again ............................');

    return PsWidgetWithAppBarNoAppBarTitle<ItemLocationTownshipProvider>(
        initProvider: () {
      return ItemLocationTownshipProvider(
          repo: repo1, psValueHolder: valueHolder);
    }, onProviderReady: (ItemLocationTownshipProvider provider) {
      provider.latestLocationParameterHolder.keyword =
          searchNameController.text;
      provider.loadItemLocationTownshipListByCityId(
          provider.latestLocationParameterHolder.toMap(),
          Utils.checkUserLoginId(provider.psValueHolder!),
          widget.cityId);
      _itemLocationProvider = provider;
    }, builder: (BuildContext context, ItemLocationTownshipProvider provider,
            Widget? child) {
      return ItemLocationListViewWidget(
        cityId: widget.cityId,
        scrollController: _scrollController,
        animationController: widget.animationController,
      );
    });
  }
}

class ItemLocationListViewWidget extends StatefulWidget {
  const ItemLocationListViewWidget(
      {Key? key,
      required this.cityId,
      required this.scrollController,
      required this.animationController})
      : super(key: key);

  final String cityId;
  final ScrollController scrollController;
  final AnimationController? animationController;

  @override
  _ItemLocationListViewWidgetState createState() =>
      _ItemLocationListViewWidgetState();
}

LocationParameterHolder locationParameterHolder =
    LocationParameterHolder().getDefaultParameterHolder();
final TextEditingController searchNameController = TextEditingController();

class _ItemLocationListViewWidgetState
    extends State<ItemLocationListViewWidget> {
  Widget? _widget;
  PsValueHolder? valueHolder;

  @override
  Widget build(BuildContext context) {
    valueHolder = Provider.of<PsValueHolder>(context);
    final ItemLocationTownshipProvider _provider =
        Provider.of(context, listen: false);
    _widget ??= Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(child: ItemLocationHeaderTextWidget()),
        Row(
          children: <Widget>[
            const SizedBox(
              width: PsDimens.space4,
            ),
            Flexible(
                child: PsTextFieldWidgetWithIcon(
                    hintText:
                        Utils.getString(context, 'home__bottom_app_bar_search'),
                    textEditingController: searchNameController,
                    psValueHolder: _provider.psValueHolder,
                    clickSearchButton: () {
                      _provider.latestLocationParameterHolder.keyword =
                          searchNameController.text;
                      _provider.resetItemLocationTownshipListByCityId(
                          _provider.latestLocationParameterHolder.toMap(),
                          Utils.checkUserLoginId(_provider.psValueHolder!),
                          widget.cityId);
                    },
                    clickEnterFunction: () {
                      _provider.latestLocationParameterHolder.keyword =
                          searchNameController.text;
                      _provider.resetItemLocationTownshipListByCityId(
                          _provider.latestLocationParameterHolder.toMap(),
                          Utils.checkUserLoginId(_provider.psValueHolder!),
                          widget.cityId);
                    })),
            Container(
              height: PsDimens.space44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PsColors.baseDarkColor,
                borderRadius: BorderRadius.circular(PsDimens.space4),
                border: Border.all(color: PsColors.mainDividerColor),
              ),
              child: InkWell(
                  child: Container(
                    height: double.infinity,
                    width: PsDimens.space44,
                    child: Icon(
                      Octicons.settings, //Octicons.settings,
                      color: PsColors.iconColor,
                      size: PsDimens.space20,
                    ),
                  ),
                  onTap: () async {
                    locationParameterHolder.keyword = searchNameController.text;
                    final dynamic returnData = await Navigator.pushNamed(
                        context, RoutePaths.filterLocationList,
                        arguments: locationParameterHolder);
                    if (returnData != null &&
                        returnData is LocationParameterHolder) {
                      _provider.latestLocationParameterHolder = returnData;
                      searchNameController.text = returnData.keyword!;
                      _provider.resetItemLocationTownshipListByCityId(
                          _provider.latestLocationParameterHolder.toMap(),
                          Utils.checkUserLoginId(_provider.psValueHolder!),
                          widget.cityId);
                    }

                  }),
            ),
            const SizedBox(
              width: PsDimens.space16,
            ),
          ],
        ),
        Consumer<ItemLocationTownshipProvider>(builder: (BuildContext context,
            ItemLocationTownshipProvider provider, Widget? child) {
          print('Refresh Progress Indicator');

          return PSProgressIndicator(provider.itemLocationTownshipList.status,
              message: provider.itemLocationTownshipList.message);
        }),
        Expanded(
          child: RefreshIndicator(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Selector<ItemLocationTownshipProvider,
                      List<ItemLocationTownship>?>(
                  child: Container(),
                  selector: (BuildContext context,
                      ItemLocationTownshipProvider provider) {
                    print(
                        'Selector ${provider.itemLocationTownshipList.data.hashCode}');
                    return provider.itemLocationTownshipList.data;
                  },
                  builder: (BuildContext context,
                      List<ItemLocationTownship>? dataList, Widget? child) {
                    print('Builder');
                    return GridView.builder(
                      controller: widget.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: dataList!.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // ✅ عنصرين في كل سطر
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.85,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final int count = dataList.length + 1;

                        if (dataList.isEmpty) {
                          return Container();
                        }

                        final bool isAll = index == 0;

                        final String title = isAll
                            ? Utils.getString(context, 'product_list__location_all')
                            : dataList[index - 1].townshipName ?? '';

                        return ItemLocationTownshipListItem(
                          animationController: widget.animationController,
                          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: widget.animationController!,
                              curve: Interval(
                                (1 / count) * index,
                                1.0,
                                curve: Curves.fastOutSlowIn,
                              ),
                            ),
                          ),
                          itemLocationTownship: title,
                          onTap: () async {
                            if (isAll) {
                              await _provider.replaceItemLocationTownshipData(
                                '',
                                dataList.first.cityId!,
                                Utils.getString(context, 'product_list__location_all'),
                                dataList.first.lat!,
                                dataList.first.lng!,
                              );

                              Navigator.of(context).pop();
                            } else {
                              final ItemLocationTownship township = dataList[index - 1];

                              await _provider.replaceItemLocationTownshipData(
                                township.id!,
                                township.cityId!,
                                township.townshipName!,
                                township.lat!,
                                township.lng!,
                              );

                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    );
                  }),
            ),
            onRefresh: () {
              return _provider.resetItemLocationTownshipListByCityId(
                  _provider.latestLocationParameterHolder.toMap(),
                  Utils.checkUserLoginId(_provider.psValueHolder!),
                  widget.cityId);
            },
          ),
        )
      ],
    );
    print('Widget ${_widget.hashCode}');
    return _widget!;
  }
}

class ItemLocationHeaderTextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      color: PsColors.primary500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: PsDimens.space32),
              child: Text(
                  Utils.getString(context, 'item_location__select_township'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.white)),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: PsDimens.space64, top: PsDimens.space8),
              child: Text(
                  Utils.getString(
                      context, 'item_location__change_selected_township'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
