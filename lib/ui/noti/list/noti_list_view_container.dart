import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/provider/noti/noti_provider.dart';
import 'package:taapdeel/ui/noti/list/noti_list_view.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:provider/provider.dart';

// NOTE: Class name kept as NotiListContainerView to match existing route paths.
class NotiListContainerView extends StatefulWidget {
  @override
  _NotiListContainerViewState createState() => _NotiListContainerViewState();
}

class _NotiListContainerViewState extends State<NotiListContainerView>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  Future<bool> _requestPop() {
    animationController!.reverse().then<dynamic>((void data) {
      if (!mounted) return Future<bool>.value(false);
      Navigator.pop(context, true);
      return Future<bool>.value(true);
    });
    return Future<bool>.value(false);
  }

  @override
  Widget build(BuildContext context) {
    // ── Clear notification badge when screen opens ────────────────────────
    // Uses listen: false — just a one-time side effect on build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final NotiProvider notiProvider =
        context.read<NotiProvider>();
        // Mark first, because markAllRead() depends on the current unread count.
        // Calling clearUnread() before it prevents the server sync from running.
        notiProvider.markAllRead();
      } catch (_) {
        // Provider might not be in tree in some route configurations
      }
    });

    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
          ),
          iconTheme: Theme.of(context)
              .iconTheme
              .copyWith(color: PsColors.backArrowColor),
          title: Text(
            Utils.getString(context, 'noti_list__toolbar_name'),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: Container(
          color: PsColors.baseColor,
          height: double.infinity,
          child: NotiListView(),
        ),
      ),
    );
  }
}
