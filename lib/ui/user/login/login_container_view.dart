import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/dialog/confirm_dialog_view.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

import 'login_view.dart';

class LoginContainerView extends StatefulWidget {
  @override
  _CityLoginContainerViewState createState() => _CityLoginContainerViewState();
}

class _CityLoginContainerViewState extends State<LoginContainerView>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserProvider? userProvider;
  UserRepository? userRepo;

  @override
  Widget build(BuildContext context) {
    final PsValueHolder valueHolder = Provider.of<PsValueHolder>(context);
    Future<bool> _requestPop() {
      if (valueHolder.isForceLogin!) {
        return showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialogView(
                  description:
                      Utils.getString(context, 'home__quit_dialog_description'),
                  leftButtonText: Utils.getString(context, 'dialog__cancel'),
                  rightButtonText: Utils.getString(context, 'dialog__ok'),
                  onAgreeTap: () {
                    Navigator.pop(context);
                  });
            }).then((dynamic value) {
          SystemNavigator.pop();
          return value;
        });
      } else {
        animationController!.reverse().then<dynamic>(
          (void data) {
            if (!mounted) {
              return Future<bool>.value(false);
            }
            Navigator.pop(context, true);
            return Future<bool>.value(true);
          },
        );
        return Future<bool>.value(false);
      }
    }

    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: animationController!,
            curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));

    print(
        '............................Build UI Again ............................');
    userRepo = Provider.of<UserRepository>(context);
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              color: PsColors.baseColor,
              width: double.infinity,
              height: double.maxFinite,
            ),
            CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: <Widget>[
                _SliverAppbar(
                  title: Utils.getString(context, 'login__title'),
                  scaffoldKey: scaffoldKey,
                ),

                SliverToBoxAdapter(
                  child: LoginView(
                    animationController: animationController,
                    animation: animation,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SliverAppbar extends StatefulWidget {
  const _SliverAppbar({
    Key? key,
    required this.title,
    this.scaffoldKey,
  }) : super(key: key);
  final String title;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  // final Drawer? menuDrawer;
  @override
  _SliverAppbarState createState() => _SliverAppbarState();
}

class _SliverAppbarState extends State<_SliverAppbar> {
  static const Color _kTitleColor = Color(0xFF002851);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      iconTheme: const IconThemeData(
        color: _kTitleColor,
      ),
      backgroundColor: const Color(0xFFF4F7FA),
      foregroundColor: _kTitleColor,
      centerTitle: true,
      elevation: 0,
      pinned: true,
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: _kTitleColor,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }
}