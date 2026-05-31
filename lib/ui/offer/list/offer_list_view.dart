import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/ui/offer/list/offer_list_view_app_bar.dart';
import 'package:taapdeel/ui/offer/list/offer_receive_list_view.dart';
import 'package:taapdeel/ui/offer/list/offer_sent_list_view.dart';
import 'package:taapdeel/utils/utils.dart';

import '../../../constant/ps_dimens.dart';

class OfferListView extends StatefulWidget {
  const OfferListView({
    Key? key,
    required this.animationController,
  }) : super(key: key);
  final AnimationController? animationController;
  @override
  _OfferListViewState createState() => _OfferListViewState();
}

class _OfferListViewState extends State<OfferListView> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final OfferListViewAppBar pageviewAppBar = OfferListViewAppBar(
      selectedIndex: _selectedIndex,
      onItemSelected: (int index) => setState(() {
        _selectedIndex = index;
        _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      }),
      items: <OfferListViewAppBarItem>[
        OfferListViewAppBarItem(
            title: Utils.getString(context, 'offer_list__offer_receive'),
            activeColor: PsColors.activeColor),

        OfferListViewAppBarItem(
            title: Utils.getString(context, 'offer_list__offer_sent'),
            activeColor: PsColors.activeColor),

      ],
    );
    return WillPopScope(
      onWillPop: () async {
        return Future<bool>.value(false);
      },
      child: Scaffold(
        backgroundColor: PsColors.baseColor,
        body: Column(children: <Widget>[
          pageviewAppBar,
          Expanded(
              child: PageView(
                  controller: _pageController,
                  children: <Widget>[
                    OfferReceivedListView(
                      animationController: widget.animationController,
                    ),
                    OfferSentListView(
                      animationController: widget.animationController,
                    ),
                  ],
                  onPageChanged: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  })),
        ]),
      ),
    );
  }
}
