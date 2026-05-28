import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/provider/chat/user_unread_message_provider.dart';

class ChatListViewAppBar extends StatefulWidget {
  const ChatListViewAppBar({
    Key? key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24,
    required this.items,
    required this.onItemSelected,
  })  : assert(items.length >= 2 && items.length <= 5),
        super(key: key);

  final int selectedIndex;
  final double iconSize;
  final bool showElevation;
  final List<ChatListViewAppBarItem> items;
  final ValueChanged<int> onItemSelected;

  @override
  _ChatListViewAppBarState createState() => _ChatListViewAppBarState(
    selectedIndexNo: selectedIndex,
    items: items,
    iconSize: iconSize,
    onItemSelected: onItemSelected,
  );
}

class _ChatListViewAppBarState extends State<ChatListViewAppBar> {
  _ChatListViewAppBarState({
    required this.items,
    this.iconSize,
    this.selectedIndexNo,
    required this.onItemSelected,
  });

  final double? iconSize;
  List<ChatListViewAppBarItem> items;
  int? selectedIndexNo;
  ValueChanged<int> onItemSelected;

  int _unreadCountFor(ChatListViewAppBarItem item) {
    final data = item.unreadMessageProvider?.userUnreadMessage.data;
    if (data == null) {
      return 0;
    }

    if (item.flag == PsConst.CHAT_FROM_SELLER) {
      return int.tryParse(data.buyerUnreadCount ?? '0') ?? 0;
    }

    if (item.flag == PsConst.CHAT_FROM_BUYER) {
      return int.tryParse(data.sellerUnreadCount ?? '0') ?? 0;
    }

    return 0;
  }

  Widget _buildItem(ChatListViewAppBarItem item, bool isSelected) {
    final int unreadCount = _unreadCountFor(item);
    final bool hasUnread = unreadCount > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            item.activeBackgroundColor ?? const Color(0xFF18AEBB),
            item.activeBackgroundColor2 ?? const Color(0xFF0F6E76),
          ],
        )
            : null,
        color: isSelected
            ? null
            : (item.inactiveBackgroundColor ?? Colors.transparent),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected
              ? (item.activeBorderColor ?? const Color(0xFF18AEBB))
              : (item.inactiveBorderColor ?? const Color(0xFFD5DAE1)),
          width: 1.1,
        ),
        boxShadow: isSelected
            ? <BoxShadow>[
          BoxShadow(
            color: (item.activeBackgroundColor ?? const Color(0xFF18AEBB))
                .withOpacity(0.20),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ]
            : <BoxShadow>[],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              item.title,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isSelected
                    ? (item.activeColor ?? Colors.white)
                    : (item.inactiveColor ?? PsColors.textColor1),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (hasUnread) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 22),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.96)
                    : (item.badgeIdleBackgroundColor ??
                    (item.activeBackgroundColor ?? const Color(0xFF18AEBB))),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: isSelected
                        ? (item.activeBackgroundColor ??
                        const Color(0xFF18AEBB))
                        : (item.badgeIdleForegroundColor ?? Colors.white),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    selectedIndexNo = widget.selectedIndex;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        PsDimens.space12,
        PsDimens.space14,
        PsDimens.space12,
        0,
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List<Widget>.generate(items.length, (int index) {
          final ChatListViewAppBarItem item = items[index];
          final bool isSelected = selectedIndexNo == index;

          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: index == 0 ? 0 : 4,
                end: index == items.length - 1 ? 0 : 4,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  onItemSelected(index);
                  setState(() {
                    selectedIndexNo = index;
                  });
                },
                child: _buildItem(item, isSelected),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ChatListViewAppBarItem {
  ChatListViewAppBarItem({
    required this.title,
    this.unreadMessageProvider,
    required this.flag,
    Color? activeColor,
    Color? activeBackgroundColor,
    Color? activeBackgroundColor2,
    Color? activeBorderColor,
    Color? inactiveColor,
    Color? inactiveBackgroundColor,
    Color? inactiveBorderColor,
    Color? badgeIdleBackgroundColor,
    Color? badgeIdleForegroundColor,
  })  : activeColor = activeColor ?? PsColors.white,
        activeBackgroundColor =
            activeBackgroundColor ?? const Color(0xFF18AEBB),
        activeBackgroundColor2 =
            activeBackgroundColor2 ?? const Color(0xFF0F6E76),
        activeBorderColor = activeBorderColor ?? const Color(0xFF18AEBB),
        inactiveColor = inactiveColor ?? PsColors.textColor1,
        inactiveBackgroundColor =
            inactiveBackgroundColor ?? Colors.transparent,
        inactiveBorderColor =
            inactiveBorderColor ?? const Color(0xFFD5DAE1),
        badgeIdleBackgroundColor =
            badgeIdleBackgroundColor ?? const Color(0xFF18AEBB),
        badgeIdleForegroundColor = badgeIdleForegroundColor ?? Colors.white;

  final String title;
  final UserUnreadMessageProvider? unreadMessageProvider;
  final String flag;
  final Color? activeColor;
  final Color? activeBackgroundColor;
  final Color? activeBackgroundColor2;
  final Color? activeBorderColor;
  final Color? inactiveColor;
  final Color inactiveBackgroundColor;
  final Color inactiveBorderColor;
  final Color badgeIdleBackgroundColor;
  final Color badgeIdleForegroundColor;
}