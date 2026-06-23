import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/provider/chat/buyer_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/seller_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/user_unread_message_provider.dart';
import 'package:taapdeel/ui/chat/list/chat_buyer_list_view.dart';
import 'package:taapdeel/ui/chat/list/chat_seller_list_view.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_info_card_shell.dart';
import 'package:provider/provider.dart';

int _selectedIndex = 0;

class ChatListView extends StatefulWidget {
  const ChatListView({
    Key? key,
    required this.animationController,
    @required this.buyerChatHistoryListProvider,
    @required this.sellerChatHistoryListProvider,
    @required this.unreadMessageProvider,
  }) : super(key: key);

  final AnimationController? animationController;
  final BuyerChatHistoryListProvider? buyerChatHistoryListProvider;
  final SellerChatHistoryListProvider? sellerChatHistoryListProvider;
  final UserUnreadMessageProvider? unreadMessageProvider;

  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  late final PageController _pageController;

  late final ChatBuyerListView chatBuyerListView;
  late final ChatSellerListView chatSellerListView;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    chatBuyerListView = ChatBuyerListView(
      animationController: widget.animationController,
      provider: widget.buyerChatHistoryListProvider,
    );
    chatSellerListView = ChatSellerListView(
      animationController: widget.animationController,
      provider: widget.sellerChatHistoryListProvider,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future<bool>.value(false);
      },
      child: Scaffold(
        backgroundColor: PsColors.baseColor,
        body: Column(
          children: <Widget>[
            _SwapRequestsCardsTabBar(
              selectedIndex: _selectedIndex,
              unreadMessageProvider: widget.unreadMessageProvider,
              onItemSelected: _selectTab,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                children: <Widget>[
                  chatSellerListView,
                  chatBuyerListView,
                ],
                onPageChanged: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapRequestsCardsTabBar extends StatelessWidget {
  const _SwapRequestsCardsTabBar({
    required this.selectedIndex,
    required this.unreadMessageProvider,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final UserUnreadMessageProvider? unreadMessageProvider;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TaapdeelInfoCardShell(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(6),
            withBlur: true,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _SwapRequestTabButton(
                    selected: selectedIndex == 0,
                    title: 'المستلمة',
                    subtitle: 'عروض على منتجاتك',
                    icon: Icons.move_to_inbox_rounded,
                    count: _safeUnreadCount(
                      unreadMessageProvider,
                      PsConst.CHAT_FROM_SELLER,
                    ),
                    onTap: () => onItemSelected(0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SwapRequestTabButton(
                    selected: selectedIndex == 1,
                    title: 'المرسلة',
                    subtitle: 'طلباتك للآخرين',
                    icon: Icons.outbox_rounded,
                    count: _safeUnreadCount(
                      unreadMessageProvider,
                      PsConst.CHAT_FROM_BUYER,
                    ),
                    onTap: () => onItemSelected(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _safeUnreadCount(UserUnreadMessageProvider? provider, dynamic flag) {
    if (provider == null) return 0;

    final dynamic p = provider;
    final String flagText = (flag ?? '').toString().toLowerCase();
    final bool isSeller = flagText.contains('seller');
    final bool isBuyer = flagText.contains('buyer');

    int? parse(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString().trim());
    }

    final List<dynamic Function()> candidates = <dynamic Function()>[
          () => p.getUnreadCount(flag),
          () => p.getUnreadMessageCount(flag),
          () => p.getUnreadMessageCountByFlag(flag),
          () => p.unreadCount(flag),
          () => p.count(flag),
      if (isSeller) () => p.sellerUnreadCount,
      if (isSeller) () => p.unreadSellerCount,
      if (isSeller) () => p.sellerCount,
      if (isBuyer) () => p.buyerUnreadCount,
      if (isBuyer) () => p.unreadBuyerCount,
      if (isBuyer) () => p.buyerCount,
    ];

    for (final dynamic Function() reader in candidates) {
      try {
        final int? value = parse(reader());
        if (value != null && value > 0) return value;
      } catch (_) {}
    }

    return 0;
  }
}

class _SwapRequestTabButton extends StatelessWidget {
  const _SwapRequestTabButton({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        (PsColors.activeColor as Color?) ?? const Color(0xFF24A9C4);
    final Color bottomNavColor =
        (PsColors.bottomNav as Color?) ?? const Color(0xFF073B5A);
    final Color inactiveText = Colors.black.withValues(alpha: 0.62);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: selected
            ? LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: <Color>[
            bottomNavColor,
            activeColor,
          ],
        )
            : const LinearGradient(
          colors: <Color>[
            Colors.white,
            Color(0xFFF4FBFE),
          ],
        ),
        border: Border.all(
          color: selected
              ? Colors.white.withValues(alpha: 0.9)
              : const Color(0xFFD7EEF5),
          width: selected ? 1.2 : 1,
        ),
        boxShadow: selected
            ? <BoxShadow>[
          BoxShadow(
            color: activeColor.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ]
            : const <BoxShadow>[],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? Colors.white.withValues(alpha: 0.18)
                            : activeColor.withValues(alpha: 0.10),
                      ),
                      child: Icon(
                        icon,
                        color: selected ? Colors.white : activeColor,
                        size: 19,
                      ),
                    ),
                    if (count > 0)
                      PositionedDirectional(
                        top: -7,
                        end: -7,
                        child: _SwapRequestCountBadge(
                          count: count,
                          accent: selected ? bottomNavColor : activeColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF102E45),
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.86)
                              : inactiveText,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwapRequestCountBadge extends StatelessWidget {
  const _SwapRequestCountBadge({
    required this.count,
    required this.accent,
  });

  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 25),
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        maxLines: 1,
        softWrap: false,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

class ChatListScreenWithNewAppBar extends StatelessWidget {
  ChatListScreenWithNewAppBar({this.animationController});

  final dynamic animationController;

  @override
  Widget build(BuildContext context) {
    final BuyerChatHistoryListProvider buyerChatHistoryListProvider =
    Provider.of<BuyerChatHistoryListProvider>(context, listen: false);
    final SellerChatHistoryListProvider sellerChatHistoryListProvider =
    Provider.of<SellerChatHistoryListProvider>(context, listen: false);
    final UserUnreadMessageProvider unreadMessageProvider =
    Provider.of<UserUnreadMessageProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ChatListView(
        animationController: animationController,
        sellerChatHistoryListProvider: sellerChatHistoryListProvider,
        buyerChatHistoryListProvider: buyerChatHistoryListProvider,
        unreadMessageProvider: unreadMessageProvider,
      ),
    );
  }
}
