// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/ps_colors.dart';
import '../constant/ps_constants.dart';
import '../db/common/ps_shared_preferences.dart';
import '../ui/offer/list/offer_list_view_app_bar.dart';
import '../utils/utils.dart';
import '../viewobject/chat_history.dart';
import 'chat/seller_chat_history_list_provider.dart';

class MainProvider extends ChangeNotifier {
  static MainProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<MainProvider>(context, listen: listen);
  }

  bool loading = false;

  /// Full raw list returned from provider/API
  List<ChatHistory> swapList = <ChatHistory>[];

  /// Legacy per-status lists (kept for backward compatibility)
  List<ChatHistory> swapListP = <ChatHistory>[];
  List<ChatHistory> swapListA = <ChatHistory>[];
  List<ChatHistory> swapListS = <ChatHistory>[];
  List<ChatHistory> swapListR = <ChatHistory>[];

  Future<void> getSentList(
      BuildContext context,
      SellerChatHistoryListProvider provide,
      ) async {
    loading = true;
    notifyListeners();

    swapList = <ChatHistory>[];
    swapListA = <ChatHistory>[];
    swapListP = <ChatHistory>[];
    swapListS = <ChatHistory>[];
    swapListR = <ChatHistory>[];

    swapList = await provide.getSentList();

    for (final ChatHistory element in swapList) {
      switch (element.offerStatus) {
        case PsConst.REQUEST_PENDING:
          if (element.buyerUserId !=
              PsSharedPreferences.instance.shared
                  .getString(PsConst.VALUE_HOLDER__USER_ID)) {
            swapListP.add(element);
          }
          break;

        case PsConst.REQUEST_ACCEPTED:
          swapListA.add(element);
          break;

        case PsConst.REQUEST_SWAPPED:
          swapListS.add(element);
          break;

        case PsConst.REQUEST_REJECTED:
          swapListR.add(element);
          break;
      }
    }

    log('MainProvider => full swapList: ${swapList.length}');
    log('MainProvider => pending swapListP: ${swapListP.length}');
    log('MainProvider => accepted swapListA: ${swapListA.length}');
    log('MainProvider => swapped swapListS: ${swapListS.length}');
    log('MainProvider => rejected swapListR: ${swapListR.length}');

    loading = false;
    notifyListeners();
  }

  /// New source for the new UI:
  /// returns ALL received requests without old status-tab filtering.
  List<ChatHistory> allRequests() {
    return List<ChatHistory>.from(swapList);
  }

  bool hasAnyRequests() {
    return swapList.isNotEmpty;
  }

  List<String> secondFilter = <String>[
    '1',
    '2',
    '3',
    '4',
  ];

  String statusString(BuildContext context, String type) {
    String status = '';
    log('type a $type');

    switch (type) {
      case PsConst.REQUEST_PENDING:
        status = Utils.getString(context, 'request_pending');
        break;

      case PsConst.REQUEST_ACCEPTED:
        status = Utils.getString(context, 'request_accepted');
        break;

      case PsConst.REQUEST_SWAPPED:
        status = Utils.getString(context, 'request_swapped');
        break;

      case PsConst.REQUEST_REJECTED:
        status = Utils.getString(context, 'request_rejected');
        break;
    }

    return status;
  }

  /// Legacy method:
  /// still returns one list based on old second-level tabs.
  /// Do NOT use this in the new grouped/filter-chip screens.
  List<ChatHistory> statusListLength(BuildContext context) {
    List<ChatHistory> status = <ChatHistory>[];
    log('legacy selectedIndex => ${selectedIndex + 1}');

    switch ('${selectedIndex + 1}') {
      case PsConst.REQUEST_PENDING:
        status = swapListP;
        break;

      case PsConst.REQUEST_ACCEPTED:
        status = swapListA;
        break;

      case PsConst.REQUEST_SWAPPED:
        status = swapListS;
        break;

      case PsConst.REQUEST_REJECTED:
        status = swapListR;
        break;
    }

    return status;
  }

  int selectedIndex = 0;

  void resetindex() {
    selectedIndex = 0;
    notifyListeners();
  }

  late final OfferListViewAppBar? pageviewAppBar;

  /// Legacy secondary status tabs app bar.
  /// Keep only if there are still old screens using it.
  OfferListViewAppBar pageviewAppBarWidget(
      BuildContext context,
      SellerChatHistoryListProvider provider,
      ) {
    return OfferListViewAppBar(
      selectedIndex: selectedIndex,
      onItemSelected: (int index) async {
        if (!loading) {
          selectedIndex = index;
          notifyListeners();
          await getSentList(context, provider);
        }
      },
      items: <OfferListViewAppBarItem>[
        OfferListViewAppBarItem(
          title: statusString(context, secondFilter[0]),
          activeColor: PsColors.activeColor,
          size: 0,
        ),
        OfferListViewAppBarItem(
          title: statusString(context, secondFilter[1]),
          activeColor: PsColors.activeColor,
          size: 1,
        ),
        OfferListViewAppBarItem(
          title: statusString(context, secondFilter[2]),
          activeColor: PsColors.activeColor,
          size: 2,
        ),
        OfferListViewAppBarItem(
          title: statusString(context, secondFilter[3]),
          activeColor: PsColors.activeColor,
          size: 3,
        ),
      ],
    );
  }
}