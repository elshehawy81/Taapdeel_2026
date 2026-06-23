import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/offer/offer_provider.dart';
import 'package:taapdeel/repository/offer_repository.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/offer/item/offer_sent_list_item.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/chat_history_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/offer_parameter_holder.dart';
import 'package:provider/provider.dart';

class OfferSentListView extends StatefulWidget {
  const OfferSentListView({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  final AnimationController? animationController;
  @override
  _OfferSentListViewState createState() => _OfferSentListViewState();
}

class _OfferSentListViewState extends State<OfferSentListView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late OfferListProvider _offerListProvider;
  bool _initialized = false;

  late AnimationController animationController;
  Animation<double>? animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      offerRepository = Provider.of<OfferRepository>(context, listen: false);
      psValueHolder = Provider.of<PsValueHolder>(context, listen: false);
      holder = OfferParameterHolder().getOfferSentList();
      holder!.getOfferSentList().userId = psValueHolder.loginUserId;
      _offerListProvider = OfferListProvider(repo: offerRepository);
      _offerListProvider.loadOfferList(holder!);
    }
  }

  @override
  void dispose() {
    _offerListProvider.dispose();
    animationController.dispose();
    animation = null;
    super.dispose();
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        holder!.getOfferSentList().userId = psValueHolder.loginUserId;
        _offerListProvider.nextOfferList(holder);
      }
    });

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    super.initState();
  }

  OfferRepository? offerRepository;
  late PsValueHolder psValueHolder;
  OfferParameterHolder? holder;
  dynamic data;
  @override
  Widget build(BuildContext context) {
    psValueHolder = Provider.of<PsValueHolder>(context);
    holder = OfferParameterHolder().getOfferSentList();
    holder!.getOfferSentList().userId = psValueHolder.loginUserId;

    return ChangeNotifierProvider<OfferListProvider>.value(
      value: _offerListProvider,
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
                  child: Stack(
                    children: <Widget>[
                      Container(
                        child: RefreshIndicator(
                          child: MediaQuery.removePadding(
                            removeTop: true,
                            context: context,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: provider.offerList.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                final int count =
                                    provider.offerList.data!.length;
                                widget.animationController!.forward();
                                return OfferSentListItem(
                                  animationController:
                                      widget.animationController,
                                  animation: Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(
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
                        ),
                      ),
                      PSProgressIndicator(provider.offerList.status)
                    ],
                  ),
                ),
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
