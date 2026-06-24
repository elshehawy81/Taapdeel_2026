import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/provider/common/notification_provider.dart';
import 'package:taapdeel/repository/Common/notification_repository.dart';
import 'package:taapdeel/ui/common/base/ps_widget_with_appbar.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/noti_register_holder.dart';
import 'package:taapdeel/viewobject/holder/noti_unregister_holder.dart';

class NotificationSettingView extends StatefulWidget {
  const NotificationSettingView({Key? key}) : super(key: key);

  @override
  _NotificationSettingViewState createState() =>
      _NotificationSettingViewState();
}

NotificationRepository? notiRepository;
PsValueHolder? _psValueHolder;
final FirebaseMessaging _fcm = FirebaseMessaging.instance;

class _NotificationSettingViewState extends State<NotificationSettingView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    notiRepository = Provider.of<NotificationRepository>(context);
    _psValueHolder = Provider.of<PsValueHolder>(context);

    return PsWidgetWithAppBar<NotificationProvider>(
      appBarTitle: 'إعدادات التنبيهات',
      initProvider: () => NotificationProvider(
        repo: notiRepository,
        psValueHolder: _psValueHolder,
      ),
      onProviderReady: (NotificationProvider provider) {},
      builder: (
          BuildContext context,
          NotificationProvider provider,
          Widget? child,
          ) {
        return _NotificationSettingWidget(
          notiProvider: provider,
        );
      },
    );
  }
}

class _NotificationSettingWidget extends StatefulWidget {
  const _NotificationSettingWidget({
    required this.notiProvider,
  });

  final NotificationProvider notiProvider;

  @override
  __NotificationSettingWidgetState createState() =>
      __NotificationSettingWidgetState();
}

class __NotificationSettingWidgetState
    extends State<_NotificationSettingWidget> {
  bool _globalEnabled = true;
  bool _isSavingGlobal = false;

  final Map<String, bool> _granular = <String, bool>{};

  static const String _prefPrefix = 'noti_type_';

  static const List<_NotificationSection> _sections =
  <_NotificationSection>[
    _NotificationSection(
      title: 'طلبات التبديل',
      subtitle: 'تنبيهات الطلبات والعروض وحالة التبديل',
      icon: Icons.swap_horiz_rounded,
      color: Color(0xFF0E8F65),
      items: <_NotificationItem>[
        _NotificationItem(
          'swap_request_received',
          'طلب تبديل جديد',
          'عندما يطلب شخص تبديل منتج معك',
          Icons.call_received_rounded,
          Color(0xFF0E8F65),
        ),
        _NotificationItem(
          'swap_request_accepted',
          'قبول طلب تبديل',
          'عندما يتم قبول طلب التبديل الخاص بك',
          Icons.check_circle_outline_rounded,
          Color(0xFF0E8F65),
        ),
        _NotificationItem(
          'swap_request_rejected',
          'رفض طلب تبديل',
          'عندما يتم رفض طلب التبديل',
          Icons.cancel_outlined,
          Color(0xFFE24B4A),
        ),
        _NotificationItem(
          'swap_request_completed',
          'اكتمال التبديل',
          'عندما تكتمل عملية التبديل بنجاح',
          Icons.celebration_outlined,
          Color(0xFF0E8F65),
        ),
        _NotificationItem(
          'swap_status_changed',
          'تغيير حالة التبديل',
          'عند حدوث أي تحديث على حالة طلب التبديل',
          Icons.update_rounded,
          Color(0xFF0E8F65),
        ),
        _NotificationItem(
          'offer_received',
          'عرض جديد',
          'عندما يصلك عرض على أحد منتجاتك',
          Icons.local_offer_outlined,
          Color(0xFFBA7517),
        ),
        _NotificationItem(
          'offer_accepted',
          'قبول عرض',
          'عندما يتم قبول العرض الخاص بك',
          Icons.price_check_rounded,
          Color(0xFF0E8F65),
        ),
        _NotificationItem(
          'offer_rejected',
          'رفض عرض',
          'عندما يتم رفض العرض الخاص بك',
          Icons.money_off_csred_outlined,
          Color(0xFFE24B4A),
        ),
      ],
    ),
    _NotificationSection(
      title: 'الرسائل والدردشة',
      subtitle: 'تنبيهات الرسائل الجديدة والمحادثات',
      icon: Icons.chat_bubble_outline_rounded,
      color: Color(0xFF378ADD),
      items: <_NotificationItem>[
        _NotificationItem(
          'chat_message',
          'رسالة دردشة جديدة',
          'عندما تصلك رسالة من مستخدم آخر',
          Icons.mark_chat_unread_outlined,
          Color(0xFF378ADD),
        ),
      ],
    ),
    _NotificationSection(
      title: 'رسائل اللطافة',
      subtitle: 'تنبيهات الرسائل اللطيفة والردود عليها',
      icon: Icons.favorite_outline_rounded,
      color: Color(0xFFD4537E),
      items: <_NotificationItem>[
        _NotificationItem(
          'sweet_message_received',
          'رسالة لطيفة جديدة',
          'عندما يرسل لك شخص رسالة لطيفة',
          Icons.favorite_outline_rounded,
          Color(0xFFD4537E),
        ),
        _NotificationItem(
          'sweet_message_replied',
          'رد على رسالة لطيفة',
          'عندما يرد شخص على رسالتك اللطيفة',
          Icons.reply_rounded,
          Color(0xFFD4537E),
        ),
      ],
    ),
    _NotificationSection(
      title: 'العلاقات والعائلة',
      subtitle: 'تنبيهات المتابعة ومنتجات العائلة',
      icon: Icons.people_alt_outlined,
      color: Color(0xFF7F77DD),
      items: <_NotificationItem>[
        _NotificationItem(
          'follow_request_received',
          'طلب متابعة جديد',
          'عندما يطلب شخص إضافتك أو متابعتك',
          Icons.person_add_alt_1_outlined,
          Color(0xFF7F77DD),
        ),
        _NotificationItem(
          'follow_request_accepted',
          'قبول طلب متابعة',
          'عندما يتم قبول طلب المتابعة الخاص بك',
          Icons.how_to_reg_outlined,
          Color(0xFF7F77DD),
        ),
        _NotificationItem(
          'family_product_added',
          'منتج جديد من العائلة',
          'عندما يضيف أحد أفراد العائلة منتجًا جديدًا',
          Icons.home_outlined,
          Color(0xFF7F77DD),
        ),
      ],
    ),
    _NotificationSection(
      title: 'المنتجات والفرص',
      subtitle: 'تنبيهات المنتجات المطلوبة وفرص التبديل',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFFBA7517),
      items: <_NotificationItem>[
        _NotificationItem(
          'wish_match_found',
          'تطابق مع منتج مطلوب',
          'عندما يظهر منتج مناسب لما تتمناه',
          Icons.star_outline_rounded,
          Color(0xFFBA7517),
        ),
        _NotificationItem(
          'swap_opportunity',
          'فرصة تبديل جديدة',
          'عندما تظهر لك فرصة تبديل مناسبة',
          Icons.emoji_events_outlined,
          Color(0xFFBA7517),
        ),
        _NotificationItem(
          'badge_earned',
          'شارة جديدة',
          'عندما تحصل على شارة أو إنجاز جديد',
          Icons.military_tech_outlined,
          Color(0xFFBA7517),
        ),
        _NotificationItem(
          'promotion_expiring',
          'قرب انتهاء ترويج',
          'عندما يقترب انتهاء ترويج أحد منتجاتك',
          Icons.timer_outlined,
          Color(0xFFBA7517),
        ),
      ],
    ),
    _NotificationSection(
      title: 'التقييمات',
      subtitle: 'تنبيهات التقييم والتذكير به',
      icon: Icons.rate_review_outlined,
      color: Color(0xFF378ADD),
      items: <_NotificationItem>[
        _NotificationItem(
          'rating_received',
          'تقييم جديد',
          'عندما تحصل على تقييم من مستخدم آخر',
          Icons.star_half_outlined,
          Color(0xFF378ADD),
        ),
        _NotificationItem(
          'rating_reminder',
          'تذكير بالتقييم',
          'عندما تحتاج لتقييم تجربة تبديل مكتملة',
          Icons.rate_review_outlined,
          Color(0xFF378ADD),
        ),
      ],
    ),
  ];

  int get _totalGranularCount {
    int count = 0;
    for (final _NotificationSection section in _sections) {
      count += section.items.length;
    }
    return count;
  }

  int get _enabledGranularCount {
    if (_granular.isEmpty) {
      return _totalGranularCount;
    }

    return _granular.values.where((bool value) => value).length;
  }

  bool get _allGranularEnabled {
    if (_granular.isEmpty) {
      return true;
    }

    return _granular.values.every((bool value) => value);
  }

  @override
  void initState() {
    super.initState();
    _globalEnabled = widget.notiProvider.psValueHolder?.notiSetting ?? true;
    _loadGranular();
  }

  Future<void> _loadGranular() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, bool> loaded = <String, bool>{};

    for (final _NotificationSection section in _sections) {
      for (final _NotificationItem item in section.items) {
        loaded[item.key] = prefs.getBool('$_prefPrefix${item.key}') ?? true;
      }
    }

    if (mounted) {
      setState(() {
        _granular
          ..clear()
          ..addAll(loaded);
      });
    }
  }

  Future<void> _setGranular(String key, bool value) async {
    setState(() {
      _granular[key] = value;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefPrefix$key', value);
  }

  Future<void> _toggleAllGranular(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, bool> updated = <String, bool>{};

    for (final _NotificationSection section in _sections) {
      for (final _NotificationItem item in section.items) {
        updated[item.key] = value;
        await prefs.setBool('$_prefPrefix${item.key}', value);
      }
    }

    if (mounted) {
      setState(() {
        _granular.addAll(updated);
      });
    }

    _showArabicToast(
      value ? 'تم تفعيل كل أنواع التنبيهات' : 'تم إيقاف كل أنواع التنبيهات',
    );
  }

  Future<void> _setGlobal(bool value) async {
    if (_isSavingGlobal) {
      return;
    }

    setState(() {
      _isSavingGlobal = true;
      _globalEnabled = value;
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

      _showArabicToast(
        value ? 'تم تفعيل التنبيهات' : 'تم إيقاف التنبيهات',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _globalEnabled = !value;
        });
      }

      _showArabicToast('حدث خطأ أثناء حفظ إعدادات التنبيهات');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingGlobal = false;
        });
      }
    }
  }

  void _tryRegisterToken() {
    final String? deviceToken = widget.notiProvider.psValueHolder?.deviceToken;

    if (deviceToken == null || deviceToken.isEmpty) {
      Utils.psPrint(
        '[TAAPDEEL_FCM_V3] register skipped from settings: empty token',
      );
      return;
    }

    final PsValueHolder? valueHolder = widget.notiProvider.psValueHolder;

    if (valueHolder == null) {
      return;
    }

    final String? loginUserId = Utils.checkUserLoginId(valueHolder);

    if (loginUserId == null ||
        loginUserId.isEmpty ||
        loginUserId == 'nologinuser') {
      Utils.psPrint(
        '[TAAPDEEL_FCM_V3] register skipped from settings: user is not logged in',
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
    final String? deviceToken = widget.notiProvider.psValueHolder?.deviceToken;

    if (deviceToken == null || deviceToken.isEmpty) {
      Utils.psPrint(
        '[TAAPDEEL_FCM_V3] unregister skipped from settings: empty token',
      );
      return;
    }

    final PsValueHolder? valueHolder = widget.notiProvider.psValueHolder;

    if (valueHolder == null) {
      return;
    }

    final String? loginUserId = Utils.checkUserLoginId(valueHolder);

    if (loginUserId == null ||
        loginUserId.isEmpty ||
        loginUserId == 'nologinuser') {
      Utils.psPrint(
        '[TAAPDEEL_FCM_V3] unregister skipped from settings: user is not logged in',
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

  void _showArabicToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: PsColors.primary500,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);
    final String latestMessage =
        PsSharedPreferences.instance.getNotiMessage() ?? '-';

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
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            PsDimens.space16,
            PsDimens.space16,
            PsDimens.space16,
            PsDimens.space24,
          ),
          children: <Widget>[
            _NotificationHeroCard(
              enabled: _globalEnabled,
              enabledCount: _enabledGranularCount,
              totalCount: _totalGranularCount,
            ),
            const SizedBox(height: PsDimens.space16),
            _GlobalToggleCard(
              enabled: _globalEnabled,
              isSaving: _isSavingGlobal,
              onToggle: _setGlobal,
            ),
            const SizedBox(height: PsDimens.space14),
            _LatestMessageCard(
              message: latestMessage,
            ),
            const SizedBox(height: PsDimens.space16),
            if (_globalEnabled) ...<Widget>[
              _NotificationQuickActionsCard(
                allEnabled: _allGranularEnabled,
                enabledCount: _enabledGranularCount,
                totalCount: _totalGranularCount,
                onToggleAll: () {
                  _toggleAllGranular(!_allGranularEnabled);
                },
              ),
              const SizedBox(height: PsDimens.space16),
              for (final _NotificationSection section in _sections) ...<Widget>[
                _NotificationSectionCard(
                  section: section,
                  granularValues: _granular,
                  onChanged: _setGranular,
                ),
                const SizedBox(height: PsDimens.space14),
              ],
            ] else
              const _NotificationsDisabledCard(),
            if (widget.notiProvider.psValueHolder?.isShowTokenId == true) ...<Widget>[
              const SizedBox(height: PsDimens.space8),
              _TokenIdCard(
                notiProvider: widget.notiProvider,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationHeroCard extends StatelessWidget {
  const _NotificationHeroCard({
    required this.enabled,
    required this.enabledCount,
    required this.totalCount,
  });

  final bool enabled;
  final int enabledCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsDimens.space18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: enabled
              ? const <Color>[
            Color(0xFF0E8F65),
            Color(0xFF13B981),
          ]
              : const <Color>[
            Color(0xFF5B6570),
            Color(0xFF2F3842),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (enabled ? const Color(0xFF0E8F65) : Colors.black)
                .withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            top: -34,
            end: -28,
            child: _HeroCircle(
              size: 118,
              opacity: 0.10,
            ),
          ),
          PositionedDirectional(
            bottom: -46,
            start: -36,
            child: _HeroCircle(
              size: 132,
              opacity: 0.08,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.22),
                      ),
                    ),
                    child: Icon(
                      enabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
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
                          'تنبيهات تبديل',
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
                          enabled
                              ? 'تابع طلبات التبديل والرسائل والفرص المهمة لحظة بلحظة.'
                              : 'التنبيهات متوقفة الآن، ويمكنك تفعيلها في أي وقت.',
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
              const SizedBox(height: PsDimens.space16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PsDimens.space12,
                  vertical: PsDimens.space10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: PsDimens.space8),
                    Expanded(
                      child: Text(
                        enabled
                            ? 'مفعل $enabledCount من $totalCount نوع تنبيه'
                            : 'كل أنواع التنبيهات متوقفة',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
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

class _HeroCircle extends StatelessWidget {
  const _HeroCircle({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _GlobalToggleCard extends StatelessWidget {
  const _GlobalToggleCard({
    required this.enabled,
    required this.isSaving,
    required this.onToggle,
  });

  final bool enabled;
  final bool isSaving;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return _ModernCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFF0E8F65).withOpacity(0.12)
                  : Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: enabled ? const Color(0xFF0E8F65) : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: PsDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'تشغيل التنبيهات',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF15221D) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  enabled
                      ? 'ستصلك التنبيهات المهمة على جهازك'
                      : 'لن تصلك تنبيهات حتى تقوم بتفعيلها',
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
          if (isSaving)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            )
          else
            Switch.adaptive(
              value: enabled,
              onChanged: onToggle,
              activeColor: const Color(0xFF0E8F65),
              activeTrackColor: const Color(0xFF0E8F65).withOpacity(0.35),
            ),
        ],
      ),
    );
  }
}

class _LatestMessageCard extends StatelessWidget {
  const _LatestMessageCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);
    final bool hasMessage = message.trim().isNotEmpty && message.trim() != '-';

    return _ModernCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF378ADD).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Color(0xFF378ADD),
              size: 25,
            ),
          ),
          const SizedBox(width: PsDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'آخر تنبيه وصل لك',
                  style: TextStyle(
                    color: isLight ? const Color(0xFF15221D) : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasMessage ? message : 'لا توجد رسالة حديثة حتى الآن',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLight
                        ? Colors.black.withOpacity(0.55)
                        : Colors.white.withOpacity(0.62),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationQuickActionsCard extends StatelessWidget {
  const _NotificationQuickActionsCard({
    required this.allEnabled,
    required this.enabledCount,
    required this.totalCount,
    required this.onToggleAll,
  });

  final bool allEnabled;
  final int enabledCount;
  final int totalCount;
  final VoidCallback onToggleAll;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Container(
      padding: const EdgeInsets.all(PsDimens.space14),
      decoration: BoxDecoration(
        color: isLight
            ? const Color(0xFF0E8F65).withOpacity(0.08)
            : Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLight
              ? const Color(0xFF0E8F65).withOpacity(0.14)
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
              Icons.done_all_rounded,
              color: Color(0xFF0E8F65),
              size: 23,
            ),
          ),
          const SizedBox(width: PsDimens.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'أنواع التنبيهات',
                  style: TextStyle(
                    color: isLight ? const Color(0xFF15221D) : Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'مفعل $enabledCount من $totalCount',
                  style: TextStyle(
                    color: isLight
                        ? Colors.black.withOpacity(0.52)
                        : Colors.white.withOpacity(0.62),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onToggleAll,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0E8F65),
              padding: const EdgeInsets.symmetric(
                horizontal: PsDimens.space12,
                vertical: PsDimens.space8,
              ),
            ),
            child: Text(
              allEnabled ? 'إيقاف الكل' : 'تفعيل الكل',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSectionCard extends StatelessWidget {
  const _NotificationSectionCard({
    required this.section,
    required this.granularValues,
    required this.onChanged,
  });

  final _NotificationSection section;
  final Map<String, bool> granularValues;
  final Future<void> Function(String key, bool value) onChanged;

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
                  color: section.color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: PsDimens.space8),
              Expanded(
                child: Text(
                  section.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF15221D) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        _ModernCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(PsDimens.space14),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: section.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(
                        section.icon,
                        color: section.color,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: PsDimens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            section.title,
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF15221D)
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            section.subtitle,
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
                  ],
                ),
              ),
              for (int index = 0; index < section.items.length; index++) ...<Widget>[
                if (index != 0) const _SoftDivider(),
                _GranularNotificationTile(
                  item: section.items[index],
                  value: granularValues[section.items[index].key] ?? true,
                  onChanged: (bool value) {
                    onChanged(section.items[index].key, value);
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GranularNotificationTile extends StatelessWidget {
  const _GranularNotificationTile({
    required this.item,
    required this.value,
    required this.onChanged,
  });

  final _NotificationItem item;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onChanged(!value);
        },
        child: Padding(
          padding: const EdgeInsets.all(PsDimens.space14),
          child: Row(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(value ? 0.13 : 0.06),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: value ? item.color : Colors.grey,
                ),
              ),
              const SizedBox(width: PsDimens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.2,
                        fontWeight: FontWeight.w800,
                        color: value
                            ? (isLight ? const Color(0xFF15221D) : Colors.white)
                            : (isLight
                            ? Colors.black.withOpacity(0.38)
                            : Colors.white.withOpacity(0.36)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: value
                            ? (isLight
                            ? Colors.black.withOpacity(0.50)
                            : Colors.white.withOpacity(0.58))
                            : (isLight
                            ? Colors.black.withOpacity(0.30)
                            : Colors.white.withOpacity(0.30)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PsDimens.space8),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: item.color,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsDisabledCard extends StatelessWidget {
  const _NotificationsDisabledCard();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Container(
      padding: const EdgeInsets.all(PsDimens.space20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF14211C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? Colors.black.withOpacity(0.045)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              color: Colors.grey,
              size: 38,
            ),
          ),
          const SizedBox(height: PsDimens.space14),
          Text(
            'التنبيهات متوقفة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLight ? const Color(0xFF15221D) : Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: PsDimens.space8),
          Text(
            'قم بتفعيل التنبيهات من الزر بالأعلى حتى تصلك طلبات التبديل والرسائل والفرص المهمة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLight
                  ? Colors.black.withOpacity(0.52)
                  : Colors.white.withOpacity(0.62),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenIdCard extends StatelessWidget {
  const _TokenIdCard({
    required this.notiProvider,
  });

  final NotificationProvider notiProvider;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);
    final String token = notiProvider.psValueHolder?.deviceToken ?? '';

    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.key_rounded,
                  color: Color(0xFF7C3AED),
                  size: 23,
                ),
              ),
              const SizedBox(width: PsDimens.space10),
              Expanded(
                child: Text(
                  'رمز الجهاز للتنبيهات',
                  style: TextStyle(
                    color: isLight ? const Color(0xFF15221D) : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: token),
                  );
                  Fluttertoast.showToast(
                    msg: 'تم نسخ رمز الجهاز',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: PsColors.primary500,
                    textColor: Colors.white,
                  );
                },
                child: const Text(
                  'نسخ',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PsDimens.space10),
          Text(
            token.isEmpty ? 'لا يوجد رمز جهاز حاليًا' : token,
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isLight
                  ? Colors.black.withOpacity(0.52)
                  : Colors.white.withOpacity(0.62),
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernCard extends StatelessWidget {
  const _ModernCard({
    required this.child,
    this.padding = const EdgeInsets.all(PsDimens.space14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Container(
      padding: padding,
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
      child: child,
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 68,
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

class _NotificationSection {
  const _NotificationSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<_NotificationItem> items;
}

class _NotificationItem {
  const _NotificationItem(
      this.key,
      this.title,
      this.subtitle,
      this.icon,
      this.color,
      );

  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}