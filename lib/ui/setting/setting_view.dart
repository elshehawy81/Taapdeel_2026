import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/common/notification_provider.dart';
import 'package:taapdeel/repository/Common/notification_repository.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/noti_register_holder.dart';
import 'package:taapdeel/viewobject/holder/noti_unregister_holder.dart';

class SettingView extends StatefulWidget {
  const SettingView({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  final AnimationController? animationController;

  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  void initState() {
    super.initState();
    widget.animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = widget.animationController == null
        ? const AlwaysStoppedAnimation<double>(1.0)
        : Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController!,
        curve: const Interval(
          0.15,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      child: const _SettingContent(),
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              40 * (1.0 - animation.value),
              0.0,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _SettingContent extends StatelessWidget {
  const _SettingContent();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLight
                ? const <Color>[
              Color(0xFFEAF7F1),
              Color(0xFFF7FBF9),
              Color(0xFFFFFFFF),
            ]
                : const <Color>[
              Color(0xFF061B15),
              Color(0xFF0B1411),
              Color(0xFF0B0F0D),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            PsDimens.space16,
            PsDimens.space16,
            PsDimens.space16,
            PsDimens.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _SettingsHeroCard(),
              const SizedBox(height: PsDimens.space16),

              _SettingSection(
                title: 'إعدادات التطبيق',
                children: const <Widget>[
                  _SettingNotificationSwitchTile(),
                  _SettingDivider(),
                  _IntroSliderTile(),
                ],
              ),

              const SizedBox(height: PsDimens.space16),

              _SettingSection(
                title: 'الدعم والمساعدة',
                children: <Widget>[
                  _SettingTile(
                    icon: Icons.help_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: Utils.getString(context, 'setting__faq'),
                    subtitle: Utils.getString(
                      context,
                      'setting__faq_statement',
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, RoutePaths.faq);
                    },
                  ),
                  const _SettingDivider(),
                  _SettingTile(
                    icon: Icons.privacy_tip_rounded,
                    iconColor: const Color(0xFF2563EB),
                    title: Utils.getString(
                      context,
                      'setting__privacy_policy',
                    ),
                    subtitle: Utils.getString(
                      context,
                      'setting__policy_statement',
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.privacyPolicy,
                        arguments: 1,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: PsDimens.space16),

              _SettingSection(
                title: 'عن تبديل',
                children: <Widget>[
                  _SettingTile(
                    icon: Icons.info_rounded,
                    iconColor: const Color(0xFF0E8F65),
                    title: Utils.getString(context, 'setting__app_info'),
                    subtitle: 'معلومات عن التطبيق وطريقة استخدامه',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.appinfo,
                        arguments: 1,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: PsDimens.space16),
              const _SettingAppVersionWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingNotificationSwitchTile extends StatelessWidget {
  const _SettingNotificationSwitchTile();

  @override
  Widget build(BuildContext context) {
    final NotificationRepository notiRepository =
    Provider.of<NotificationRepository>(context, listen: false);

    final PsValueHolder psValueHolder =
    Provider.of<PsValueHolder>(context, listen: false);

    return ChangeNotifierProvider<NotificationProvider>(
      lazy: false,
      create: (_) => NotificationProvider(
        repo: notiRepository,
        psValueHolder: psValueHolder,
      ),
      child: Consumer<NotificationProvider>(
        builder: (
            BuildContext context,
            NotificationProvider provider,
            Widget? child,
            ) {
          return _NotificationSwitchBody(
            notiProvider: provider,
          );
        },
      ),
    );
  }
}

class _NotificationSwitchBody extends StatefulWidget {
  const _NotificationSwitchBody({
    required this.notiProvider,
  });

  final NotificationProvider notiProvider;

  @override
  State<_NotificationSwitchBody> createState() =>
      _NotificationSwitchBodyState();
}

class _NotificationSwitchBodyState extends State<_NotificationSwitchBody> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  late bool _enabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.notiProvider.psValueHolder?.notiSetting ?? true;
  }

  Future<void> _toggleNotification(bool value) async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _enabled = value;
      _isSaving = true;
    });

    try {
      widget.notiProvider.psValueHolder?.notiSetting = value;
      await widget.notiProvider.replaceNotiSetting(value);

      if (value) {
        await _fcm.subscribeToTopic('broadcast');
        _tryRegisterToken();
      } else {
        await _fcm.unsubscribeFromTopic('broadcast');
        _tryUnregisterToken();
      }

      _showSnackBar(
        value ? 'تم تشغيل كل التنبيهات' : 'تم إيقاف كل التنبيهات',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _enabled = !value;
        });
      }

      _showSnackBar('حدث خطأ أثناء حفظ إعدادات التنبيهات');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _tryRegisterToken() {
    final PsValueHolder? valueHolder = widget.notiProvider.psValueHolder;
    final String? deviceToken = valueHolder?.deviceToken;

    if (valueHolder == null || deviceToken == null || deviceToken.isEmpty) {
      Utils.psPrint(
        '[TAAPDEEL_FCM] register skipped from settings: empty token',
      );
      return;
    }

    final String? loginUserId = Utils.checkUserLoginId(valueHolder);

    if (loginUserId == null ||
        loginUserId.isEmpty ||
        loginUserId == 'nologinuser') {
      Utils.psPrint(
        '[TAAPDEEL_FCM] register skipped from settings: user is not logged in',
      );
      return;
    }

    final NotiRegisterParameterHolder holder = NotiRegisterParameterHolder(
      platformName: PsConst.PLATFORM,
      deviceId: deviceToken,
      loginUserId: loginUserId,
    );

    widget.notiProvider.rawRegisterNotiToken(holder.toMap());
  }

  void _tryUnregisterToken() {
    final PsValueHolder? valueHolder = widget.notiProvider.psValueHolder;
    final String? deviceToken = valueHolder?.deviceToken;

    if (valueHolder == null || deviceToken == null || deviceToken.isEmpty) {
      Utils.psPrint(
        '[TAAPDEEL_FCM] unregister skipped from settings: empty token',
      );
      return;
    }

    final String? loginUserId = Utils.checkUserLoginId(valueHolder);

    if (loginUserId == null ||
        loginUserId.isEmpty ||
        loginUserId == 'nologinuser') {
      Utils.psPrint(
        '[TAAPDEEL_FCM] unregister skipped from settings: user is not logged in',
      );
      return;
    }

    final NotiUnRegisterParameterHolder holder = NotiUnRegisterParameterHolder(
      platformName: PsConst.PLATFORM,
      deviceId: deviceToken,
      userId: loginUserId,
    );

    widget.notiProvider.rawUnRegisterNotiToken(holder.toMap());
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0E8F65),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Padding(
      padding: const EdgeInsets.all(PsDimens.space14),
      child: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _enabled
                  ? const Color(0xFF0E8F65).withOpacity(isLight ? 0.12 : 0.18)
                  : Colors.grey.withOpacity(isLight ? 0.12 : 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: _enabled ? const Color(0xFF0E8F65) : Colors.grey,
              size: 25,
            ),
          ),
          const SizedBox(width: PsDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'التنبيهات',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF15221D) : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _enabled
                      ? 'كل تنبيهات التطبيق تعمل الآن'
                      : 'كل تنبيهات التطبيق متوقفة الآن',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLight
                        ? Colors.black.withOpacity(0.52)
                        : Colors.white.withOpacity(0.62),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PsDimens.space8),
          if (_isSaving)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
              ),
            )
          else
            Switch.adaptive(
              value: _enabled,
              onChanged: _toggleNotification,
              activeColor: const Color(0xFF0E8F65),
              activeTrackColor: const Color(0xFF0E8F65).withOpacity(0.35),
            ),
        ],
      ),
    );
  }
}

class _IntroSliderTile extends StatelessWidget {
  const _IntroSliderTile();

  @override
  Widget build(BuildContext context) {
    return _SettingTile(
      icon: Icons.slideshow_rounded,
      iconColor: const Color(0xFF7C3AED),
      title: Utils.getString(
        context,
        'intro_slider_setting',
      ),
      subtitle: Utils.getString(
        context,
        'intro_slider_setting_description',
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutePaths.introSlider,
          arguments: 1,
        );
      },
    );
  }
}

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsDimens.space18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[
            Color(0xFF0E8F65),
            Color(0xFF12B981),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0E8F65).withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            top: -28,
            end: -24,
            child: Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -36,
            start: -32,
            child: Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: PsDimens.space14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'الإعدادات',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: PsDimens.space8),
                    Text(
                      'تحكم في التنبيهات، الخصوصية، وطريقة استخدام التطبيق.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.86),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: PsDimens.space4,
            bottom: PsDimens.space10,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 5,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E8F65),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: PsDimens.space8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isLight ? const Color(0xFF15221D) : Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF14211C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight
                  ? Colors.black.withOpacity(0.045)
                  : Colors.white.withOpacity(0.07),
            ),
            boxShadow: isLight
                ? <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.055),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ]
                : <BoxShadow>[],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(PsDimens.space14),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(isLight ? 0.12 : 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: PsDimens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF15221D) : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLight
                            ? Colors.black.withOpacity(0.52)
                            : Colors.white.withOpacity(0.62),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PsDimens.space8),
              Icon(
                Icons.chevron_left_rounded,
                color: isLight
                    ? Colors.black.withOpacity(0.32)
                    : Colors.white.withOpacity(0.42),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 72,
        end: PsDimens.space14,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isLight
            ? Colors.black.withOpacity(0.055)
            : Colors.white.withOpacity(0.07),
      ),
    );
  }
}

class _SettingAppVersionWidget extends StatelessWidget {
  const _SettingAppVersionWidget();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Container(
      padding: const EdgeInsets.all(PsDimens.space16),
      decoration: BoxDecoration(
        color: isLight
            ? const Color(0xFF0E8F65).withOpacity(0.08)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? const Color(0xFF0E8F65).withOpacity(0.16)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0E8F65).withOpacity(0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFF0E8F65),
              size: 24,
            ),
          ),
          const SizedBox(width: PsDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Utils.getString(context, 'setting__app_version'),
                  style: TextStyle(
                    color: isLight ? const Color(0xFF15221D) : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  PsConfig.app_version,
                  style: TextStyle(
                    color: isLight
                        ? Colors.black.withOpacity(0.55)
                        : Colors.white.withOpacity(0.62),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Taapdeel',
            style: TextStyle(
              color: const Color(0xFF0E8F65).withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}