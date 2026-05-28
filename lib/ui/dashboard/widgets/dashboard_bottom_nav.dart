import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:fluttericon/font_awesome_icons.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    Key? key,
    required this.currentIndex,
    required this.getBottomNavIndex,
    required this.onTabSelected,
    required this.onAddPressed,
    this.profileUnreadCount = 0,
  }) : super(key: key);

  final int profileUnreadCount;

  final int? currentIndex;
  final int Function(int? param) getBottomNavIndex;
  final Function(int index) onTabSelected;
  final VoidCallback onAddPressed;

  bool _visibleFor(int? idx) {
    return idx == PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT ||
        idx == PsConst.REQUEST_CODE__DASHBOARD_CATEGORY_FRAGMENT ||
        idx == PsConst.REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT ||
        idx == PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT ||
        idx == PsConst.REQUEST_CODE__DASHBOARD_ITEM_UPLOAD_FRAGMENT ||
        idx == PsConst.REQUEST_CODE__DASHBOARD_SEARCH_FRAGMENT ||
        idx == PsConst.REQUEST_CODE__DASHBOARD_MESSAGE_FRAGMENT ||
        idx == PsConst.REQUEST_CODE__DASHBOARD_NOTI_FRAGMENT ||
        idx == PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT;
  }

  // ==========================
  // Glow Item Builder
  // ==========================
  BottomNavigationBarItem _buildItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
        int badgeCount = 0,
      }) {
    final bool isSelected = getBottomNavIndex(currentIndex) == index;

    const Color glowColor = Color(0xFF0FA3A6);

    return BottomNavigationBarItem(
      label: label,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? <BoxShadow>[
                BoxShadow(
                  color: glowColor.withOpacity(0.55),
                  blurRadius: 14,
                  spreadRadius: 1.2,
                ),
              ]
                  : const <BoxShadow>[],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
          if (badgeCount > 0)
            PositionedDirectional(
              top: -2,
              end: -4,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visibleFor(currentIndex)) return const SizedBox.shrink();

    // ==========================
    // Logo-like gradient colors
    // ==========================
    const Color navy1 = Color(0xFF0C2345);
    const Color navy2 = Color(0xFF102E5C);
    const Color teal1 = Color(0xFF0FA3A6);

    const double totalHeight = 80;

    const double barHeight = 70;

    const double addBtnSize = 65;
    const double addBtnRadius = addBtnSize / 2;
    const double addBtnBottom = barHeight - addBtnRadius-10; // 64 - 35 = 29

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ==========================
          // Gradient background (ONLY barHeight at the bottom)
          // ==========================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: <double>[0.0, 0.55, 1.0],
                  colors: <Color>[
                    navy1,
                    navy2,
                    teal1,
                  ],
                ),
              ),
            ),
          ),

          // ==========================
          // BottomNavigationBar (ONLY barHeight at the bottom)
          // ==========================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: getBottomNavIndex(currentIndex),
              showUnselectedLabels: true,

              backgroundColor: Colors.transparent,
              elevation: 0,

              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,

              onTap: onTabSelected,
              items: <BottomNavigationBarItem>[
                _buildItem(
                  context,
                  icon: Icons.storefront_outlined,
                  label: Utils.getString(context, 'inventory'),
                  index: 0,
                ),
                _buildItem(
                  context,
                  icon: Icons.auto_awesome,
                  label: Utils.getString(context, 'Discover'),
                  index: 1,
                ),
                BottomNavigationBarItem(icon: const SizedBox(height:35),
                    label: Utils.getString(context, 'add_product')),
                _buildItem(
                  context,
                  icon: Icons.swap_horiz,
                  label: Utils.getString(context, 'my_requests'),
                  index: 3,
                ),
                _buildItem(
                  context,
                  icon: Icons.account_circle_outlined,
                  label: Utils.getString(context, 'profile'),
                  index: 4,
                  badgeCount: profileUnreadCount,
                ),
              ],
            ),
          ),

          // ==========================
          // Floating Add Button (stays OUTSIDE bar)
          // ==========================
          Positioned(
            bottom: addBtnBottom,
            child: GestureDetector(
              onTap: onAddPressed,
              child: Container(
                height: addBtnSize,
                width: addBtnSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0FA3A6).withOpacity(0.35),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: const Icon(
                  FontAwesome.plus_circled,
                  color: Color(0xFF0FA3A6),
                  size: addBtnSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}