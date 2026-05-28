import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/provider/chat/buyer_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/seller_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/user_unread_message_provider.dart';
import 'package:taapdeel/ui/chat/list/chat_buyer_list_view.dart';
import 'package:taapdeel/ui/chat/list/chat_seller_list_view.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../config/ps_colors.dart';
import '../../../config/ps_config.dart';
import '../../../repository/chat_history_repository.dart';
import '../../../repository/user_unread_message_repository.dart';
import '../../../utils/utils.dart';
import '../../../viewobject/common/ps_value_holder.dart';
import '../../../viewobject/holder/chat_history_parameter_holder.dart';
import '../../dashboard/core/dashboard_view.dart';
import 'chat_list_view.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  ChatHistoryRepository? chatHistoryRepository;
  BuyerChatHistoryListProvider? buyerListProvider;
  SellerChatHistoryListProvider? sellerListProvider;
  UserUnreadMessageProvider? userUnreadMessageProvider;
  UserUnreadMessageRepository? userUnreadMessageRepository;
  ChatBuyerListView? chatBuyerListView;
  ChatSellerListView? chatSellerListView;
  PsValueHolder? valueHolder;
  PsValueHolder? psValueHolder;
  ChatHistoryParameterHolder? buyerHolder;
  ChatHistoryParameterHolder? sellerHolder;
  int? sellerCount;
  int? buyerCount;
  late AnimationController animationController;
  late AnimationController animationControllerForFab;

  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));
  }

  @override
  Widget build(BuildContext context) {
    valueHolder = Provider.of<PsValueHolder>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);
    chatHistoryRepository = Provider.of<ChatHistoryRepository>(context);
    userUnreadMessageRepository =
        Provider.of<UserUnreadMessageRepository>(context);
    userUnreadMessageProvider =
        UserUnreadMessageProvider(repo: userUnreadMessageRepository);

    return valueHolder!.loginUserId != null && valueHolder!.loginUserId != ''
          ? MultiProvider(
              providers: <SingleChildWidget>[
                // ChangeNotifierProvider<UserUnreadMessageProvider>(
                //   create: (BuildContext context) {
                //       userUnreadMessageCountProvider =
                //             UserUnreadMessageProvider(
                //                 repo: userUnreadMessageRepository);

                //         if (psValueHolder!.loginUserId != null &&
                //             psValueHolder!.loginUserId != '') {
                //           userUnreadMessageHolder =
                //               UserUnreadMessageParameterHolder(
                //                   userId: psValueHolder!.loginUserId,
                //                   deviceToken: psValueHolder!.deviceToken);
                //           userUnreadMessageProvider!
                //               .userUnreadMessageCount(
                //                   userUnreadMessageHolder);
                //         }
                //         return userUnreadMessageCountProvider!;
                //   },
                // )
                //,
                ChangeNotifierProvider<BuyerChatHistoryListProvider>(
                  create: (BuildContext context) {
                    buyerListProvider = BuyerChatHistoryListProvider(
                        repo: chatHistoryRepository);
                    buyerHolder =
                        ChatHistoryParameterHolder().getBuyerHistoryList();
                    buyerHolder!.getBuyerHistoryList().userId =
                        psValueHolder!.loginUserId;
                    buyerListProvider!.resetShowProgress(true);
                    buyerListProvider!.loadChatHistoryList(buyerHolder!);
                    return buyerListProvider!;
                  },
                ),
                ChangeNotifierProvider<SellerChatHistoryListProvider>(
                  create: (BuildContext context) {
                    sellerListProvider = SellerChatHistoryListProvider(
                        repo: chatHistoryRepository);
                    sellerHolder =
                        ChatHistoryParameterHolder().getSellerHistoryList();
                    sellerHolder!.getSellerHistoryList().userId =
                        psValueHolder!.loginUserId;
                    sellerListProvider!.resetShowProgress(true);
                    sellerListProvider!.loadChatHistoryList(sellerHolder!);
                    return sellerListProvider!;
                  },
                ),
              ],
              child: Consumer2<BuyerChatHistoryListProvider,
                  SellerChatHistoryListProvider>(
                builder: (BuildContext context,
                    BuyerChatHistoryListProvider buyer,
                    SellerChatHistoryListProvider seller,
                    Widget? child) {
                  return ChatListView(
                      animationController: animationController,
                      sellerChatHistoryListProvider: seller,
                      buyerChatHistoryListProvider: buyer,
                      unreadMessageProvider: userUnreadMessageProvider);
                },
              ),
            )
          : CallLoginWidget(
              currentIndex: 2,
              animationController: animationController,
              animation: animation,
              updateCurrentIndex: (String title, int index) {},
              updateUserCurrentIndex:
                  (String title, int index, String userId) {});
  }
}
