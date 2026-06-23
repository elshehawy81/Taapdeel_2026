import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/offer/offer_provider.dart';
import 'package:taapdeel/repository/offer_repository.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/offer/item/offer_received_list_item.dart';
import 'package:taapdeel/ui/offer/list/offer_list_view_app_bar.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/chat_history_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/offer_parameter_holder.dart';
import 'package:provider/provider.dart';

class OfferReceivedListView extends StatefulWidget {
  const OfferReceivedListView({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  final AnimationController? animationController;

  @override
  _OfferReceivedListViewState createState() => _OfferReceivedListViewState();
}

class _OfferReceivedListViewState extends State<OfferReceivedListView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late OfferListProvider _offerProvider;

  late AnimationController animationController;
  Animation<double>? animation;

  @override
  void dispose() {
    animationController.dispose();
    animation = null;
    super.dispose();
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        holder!.getOfferReceivedList().userId = psValueHolder.loginUserId;
        _offerProvider.nextOfferList(holder);
      }
    });

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    super.initState();
  }

  List<String> secondFilter = [
    "pending",
    "Accepted",
    "swapped",
    "Rejected/canceled",
  ];
  int _selectedIndex = 0;
  OfferRepository? offerRepository;
  OfferListProvider? offerReceiveProvider;
  late PsValueHolder psValueHolder;
  OfferParameterHolder? holder;
  dynamic data;

  @override
  Widget build(BuildContext context) {
    final OfferListViewAppBar pageviewAppBar = OfferListViewAppBar(
      selectedIndex: _selectedIndex,
      onItemSelected: (int index) => setState(() {
        _selectedIndex = index;
      }),
      items: <OfferListViewAppBarItem>[
        OfferListViewAppBarItem(
            title: secondFilter[0], activeColor: PsColors.activeColor),
        OfferListViewAppBarItem(
            title: secondFilter[1], activeColor: PsColors.activeColor),
        OfferListViewAppBarItem(
            title: secondFilter[2], activeColor: PsColors.activeColor),
        OfferListViewAppBarItem(
            title: secondFilter[3], activeColor: PsColors.activeColor),
      ],
    );

    psValueHolder = Provider.of<PsValueHolder>(context);
    holder = OfferParameterHolder().getOfferReceivedList();
    holder!.getOfferReceivedList().userId = psValueHolder.loginUserId;

    offerRepository = Provider.of<OfferRepository>(context);

    return ChangeNotifierProvider<OfferListProvider>(
      lazy: false,
      create: (BuildContext context) {
        final OfferListProvider provider =
            OfferListProvider(repo: offerRepository);
        provider.loadOfferList(holder!);
        return provider;
      },
      child: Consumer<OfferListProvider>(builder:
          (BuildContext context, OfferListProvider provider, Widget? child) {
        if (provider.offerList.data != null &&
            provider.offerList.data!.isNotEmpty &&
            psValueHolder.loginUserId != null) {
          return Scaffold(
            backgroundColor: PsColors.baseColor,
            body: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                      child: RefreshIndicator(
                    child: MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.offerList.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final int count = provider.offerList.data!.length;
                          widget.animationController!.forward();
                          return OfferReceivedListItem(
                            animationController: widget.animationController,
                            animation:
                                Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: widget.animationController!,
                                curve: Interval((1 / count) * index, 1.0,
                                    curve: Curves.fastOutSlowIn),
                              ),
                            ),
                            offer: provider.offerList.data![index],

                          );
                        },
                      ),
                    ),
                    onRefresh: () {
                      return provider.resetOfferList(holder!);
                    },
                  )),
                ),
                PSProgressIndicator(provider.offerList.status)
              ],
            ),
          );
        } else {
          widget.animationController!.forward();
          return Container();
        }
      }),
      // )
    );
  }
}
