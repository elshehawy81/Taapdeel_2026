import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/ui/dashboard/core/dashboard_view.dart';
import 'package:taapdeel/ui/user/profile/profile_view.dart';

// ✅ أضف في main.dart:
//   navigatorObservers: [profileRouteObserver]
// بدون ده didPopNext مش بيشتغل ومش هيحصل refresh بعد إضافة منتج
final RouteObserver<ModalRoute<void>> profileRouteObserver =
RouteObserver<ModalRoute<void>>();

/// arguments اختياريين للروت
class ProfileRouteArgs {
  const ProfileRouteArgs({
    this.flag,
    this.userId,
  });

  final int? flag;
  final String? userId;
}

/// Wrapper: يجهّز AnimationController + scaffoldKey
class ProfileRoutePage extends StatefulWidget {
  const ProfileRoutePage({Key? key, this.args});

  final ProfileRouteArgs? args;

  @override
  State<ProfileRoutePage> createState() => _ProfileRoutePageState();
}

class _ProfileRoutePageState extends State<ProfileRoutePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _onLogout(String userId) {
    // نفس سلوكك الحالي: بعد logout يرجع للهوم (Dashboard)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => DashboardView(backToAppItem: false)),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileView(
      scaffoldKey: _scaffoldKey,
      animationController: _ac,
      flag: widget.args?.flag,
      userId: widget.args?.userId,
      callLogoutCallBack: _onLogout,
      routeObserver: profileRouteObserver,
    );
  }
}