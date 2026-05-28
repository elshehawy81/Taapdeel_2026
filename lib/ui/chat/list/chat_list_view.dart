import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/provider/chat/buyer_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/seller_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/user_unread_message_provider.dart';
import 'package:taapdeel/ui/chat/list/chat_buyer_list_view.dart';
import 'package:taapdeel/ui/chat/list/chat_seller_list_view.dart';
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

  ChatBuyerListView? chatBuyerListView;
  ChatSellerListView? chatSellerListView;

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
    chatBuyerListView = ChatBuyerListView(
      animationController: widget.animationController,
      provider: widget.buyerChatHistoryListProvider,
    );

    chatSellerListView = ChatSellerListView(
      animationController: widget.animationController,
      provider: widget.sellerChatHistoryListProvider,
    );

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
                  chatSellerListView!,
                  chatBuyerListView!,
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: PsColors.baseColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: 130,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.94),
                width: 1.4,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _SwapRequestTabCard(
                    selected: selectedIndex == 0,
                    title: 'عروض التبديل المستلمة',
                    subtitle: 'وصلتك عروض علي منتجاتك',
                    count: _safeUnreadCount(
                      unreadMessageProvider,
                      PsConst.CHAT_FROM_SELLER,
                    ),
                    gradient: const <Color>[
                      Color(0xFFB8F4FF),
                      Color(0xFF0A7EA0),
                      Color(0xFF055A76),

                    ],
                    accent: const Color(0xFF055A76),

                    onTap: () => onItemSelected(0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SwapRequestTabCard(
                    selected: selectedIndex == 1,
                    title: 'طلبات التبديل المرسلة',
                    subtitle: 'طلباتك على منتجات الاخرين',
                    count: _safeUnreadCount(
                      unreadMessageProvider,
                      PsConst.CHAT_FROM_BUYER,
                    ),
                    gradient: const <Color>[
                      Color(0xFF4FACFE),
                      Color(0xFF00F2FE),
                    ],
                    accent: const Color(0xFF011934),
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

class _SwapRequestTabCard extends StatelessWidget {
  const _SwapRequestTabCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.gradient,
    required this.accent,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final int count;
  final List<Color> gradient;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(22);

    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.0 : 0.94,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: selected ? 1.0 : 0.82,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            border: Border.all(
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
              width: selected ? 4.0 : 1.0,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: selected
                    ? accent.withValues(alpha: 0.28)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: selected ? 18 : 7,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected
                    ? const Color(0xFF8BA3AD).withValues(alpha: 0.70)
                    : Colors.transparent,
                width: selected ? 2.0 : 0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    if (count > 0)
                      PositionedDirectional(
                        top: 8,
                        start: 8,
                        child: _SwapRequestCountBadge(
                          count: count,
                          accent: accent,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 8),
                          Expanded(
                            child: Center(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                  fontSize: 12.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              fontSize: 10.4,
                              height: 1.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            height: selected ? 5 : 3,
                            width: selected ? 52 : 22,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
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
