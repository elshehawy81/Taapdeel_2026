import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingView extends StatefulWidget {
  @override
  _NotificationSettingViewState createState() =>
      _NotificationSettingViewState();
}

NotificationRepository? notiRepository;
late NotificationProvider notiProvider;
PsValueHolder? _psValueHolder;
final FirebaseMessaging _fcm = FirebaseMessaging.instance;

class _NotificationSettingViewState extends State<NotificationSettingView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    notiRepository = Provider.of<NotificationRepository>(context);
    _psValueHolder = Provider.of<PsValueHolder>(context);

    return PsWidgetWithAppBar<NotificationProvider>(
      appBarTitle: Utils.getString(context, 'noti_setting__toolbar_name'),
      initProvider: () => NotificationProvider(
          repo: notiRepository, psValueHolder: _psValueHolder),
      onProviderReady: (NotificationProvider provider) {
        notiProvider = provider;
      },
      builder: (BuildContext context, NotificationProvider provider,
          Widget? child) {
        return _NotificationSettingWidget(notiProvider: provider);
      },
    );
  }
}

// ── Main settings widget ──────────────────────────────────────────────────────
class _NotificationSettingWidget extends StatefulWidget {
  const _NotificationSettingWidget({this.notiProvider});
  final NotificationProvider? notiProvider;

  @override
  __NotificationSettingWidgetState createState() =>
      __NotificationSettingWidgetState();
}

class __NotificationSettingWidgetState
    extends State<_NotificationSettingWidget> {
  // ── Global switch ────────────────────────────────────────────────────────
  bool _globalEnabled = true;

  // ── Granular settings (key → enabled) ───────────────────────────────────
  final Map<String, bool> _granular = {};

  static const String _prefPrefix = 'noti_type_';

  // Section / item definitions
  static const List<_Section> _sections = [
    _Section(titleKey: 'noti_setting__section_swap', items: [
      _Item('swap_request_received',   'noti_setting__swap_request',    Icons.swap_horiz_rounded,        Color(0xFF1D9E75)),
      _Item('swap_request_accepted',   'noti_setting__swap_accepted',   Icons.check_circle_outline,      Color(0xFF1D9E75)),
      _Item('swap_request_rejected',   'noti_setting__swap_rejected',   Icons.cancel_outlined,           Color(0xFFE24B4A)),
      _Item('swap_request_completed',  'noti_setting__swap_completed',  Icons.celebration_outlined,      Color(0xFF1D9E75)),
      _Item('swap_status_changed',     'noti_setting__swap_status',     Icons.update,                    Color(0xFF1D9E75)),
      _Item('offer_received',          'noti_setting__offer_received',  Icons.local_offer_outlined,      Color(0xFFBA7517)),
      _Item('offer_accepted',          'noti_setting__offer_accepted',  Icons.local_offer_outlined,      Color(0xFF1D9E75)),
      _Item('offer_rejected',          'noti_setting__offer_rejected',  Icons.local_offer_outlined,      Color(0xFFE24B4A)),
    ]),
    _Section(titleKey: 'noti_setting__section_chat', items: [
      _Item('chat_message', 'noti_setting__chat_message', Icons.chat_bubble_outline, Color(0xFF378ADD)),
    ]),
    _Section(titleKey: 'noti_setting__section_sweet', items: [
      _Item('sweet_message_received', 'noti_setting__sweet_received', Icons.favorite_outline,  Color(0xFFD4537E)),
      _Item('sweet_message_replied',  'noti_setting__sweet_replied',  Icons.reply_outlined,    Color(0xFFD4537E)),
    ]),
    _Section(titleKey: 'noti_setting__section_social', items: [
      _Item('follow_request_received', 'noti_setting__follow_request',   Icons.person_add_outlined,   Color(0xFF7F77DD)),
      _Item('follow_request_accepted', 'noti_setting__follow_accepted',  Icons.how_to_reg_outlined,   Color(0xFF7F77DD)),
      _Item('family_product_added',    'noti_setting__family_product',   Icons.home_outlined,         Color(0xFF7F77DD)),
    ]),
    _Section(titleKey: 'noti_setting__section_products', items: [
      _Item('wish_match_found',   'noti_setting__wish_match',   Icons.star_outline,              Color(0xFFBA7517)),
      _Item('swap_opportunity',   'noti_setting__opportunity',  Icons.emoji_events_outlined,     Color(0xFFBA7517)),
      _Item('badge_earned',       'noti_setting__badge',        Icons.military_tech_outlined,    Color(0xFFBA7517)),
      _Item('promotion_expiring', 'noti_setting__promotion',    Icons.timer_outlined,            Color(0xFFBA7517)),
    ]),
    _Section(titleKey: 'noti_setting__section_rating', items: [
      _Item('rating_received', 'noti_setting__rating_received', Icons.star_half_outlined,    Color(0xFF378ADD)),
      _Item('rating_reminder', 'noti_setting__rating_reminder', Icons.rate_review_outlined,  Color(0xFF378ADD)),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _globalEnabled = notiProvider.psValueHolder!.notiSetting ?? true;
    _loadGranular();
  }

  Future<void> _loadGranular() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, bool> loaded = {};
    for (final _Section s in _sections) {
      for (final _Item i in s.items) {
        loaded[i.key] = prefs.getBool('$_prefPrefix${i.key}') ?? true;
      }
    }
    if (mounted) setState(() => _granular.addAll(loaded));
  }

  Future<void> _setGranular(String key, bool value) async {
    setState(() => _granular[key] = value);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefPrefix$key', value);
    // TODO: sync to backend — PATCH /api/users/notification-preferences
  }

  Future<void> _setGlobal(bool value) async {
    setState(() => _globalEnabled = value);
    notiProvider.psValueHolder!.notiSetting = value;
    await notiProvider.replaceNotiSetting(value);

    if (value) {
      _fcm.subscribeToTopic('broadcast');
      _tryRegisterToken();
    } else {
      _fcm.unsubscribeFromTopic('broadcast');
      _tryUnregisterToken();
    }
  }

  void _tryRegisterToken() {
    final String? deviceToken = notiProvider.psValueHolder?.deviceToken;
    if (deviceToken == null || deviceToken.isEmpty) {
      Utils.psPrint('[TAAPDEEL_FCM_V3] register skipped from settings: empty token');
      return;
    }

    final String? loginUserId = Utils.checkUserLoginId(notiProvider.psValueHolder!);
    if (loginUserId == null ||
        loginUserId.isEmpty ||
        loginUserId == 'nologinuser') {
      Utils.psPrint('[TAAPDEEL_FCM_V3] register skipped from settings: user is not logged in');
      return;
    }

    final NotiRegisterParameterHolder holder = NotiRegisterParameterHolder(
      platformName: PsConst.PLATFORM,
      deviceId: deviceToken,
      loginUserId: loginUserId,
    );
    notiProvider.rawRegisterNotiToken(holder.toMap());
  }

  void _tryUnregisterToken() {
    final String? deviceToken = notiProvider.psValueHolder?.deviceToken;
    if (deviceToken == null || deviceToken.isEmpty) {
      Utils.psPrint('[TAAPDEEL_FCM_V3] unregister skipped from settings: empty token');
      return;
    }

    final String? loginUserId = Utils.checkUserLoginId(notiProvider.psValueHolder!);
    if (loginUserId == null ||
        loginUserId.isEmpty ||
        loginUserId == 'nologinuser') {
      Utils.psPrint('[TAAPDEEL_FCM_V3] unregister skipped from settings: user is not logged in');
      return;
    }

    final NotiUnRegisterParameterHolder holder = NotiUnRegisterParameterHolder(
      platformName: PsConst.PLATFORM,
      deviceId: deviceToken,
      userId: loginUserId,
    );
    notiProvider.rawUnRegisterNotiToken(holder.toMap());
  }

  bool get _allGranularEnabled =>
      _granular.values.every((v) => v);

  Future<void> _toggleAllGranular(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, bool> updated = {};
    for (final _Section s in _sections) {
      for (final _Item i in s.items) {
        updated[i.key] = value;
        await prefs.setBool('$_prefPrefix${i.key}', value);
      }
    }
    setState(() => _granular.addAll(updated));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: PsDimens.space8),
      children: [
        // ── Global on/off (original behaviour preserved) ──────────────
        _GlobalToggleWidget(
          enabled: _globalEnabled,
          onToggle: _setGlobal,
        ),

        const Divider(height: PsDimens.space1),

        // ── Last FCM message (original feature) ───────────────────────
        Padding(
          padding: const EdgeInsets.only(
              top: PsDimens.space20,
              bottom: PsDimens.space8,
              left: PsDimens.space8),
          child: Row(
            children: [
              const Icon(ModernPictograms.bullhorn, size: PsDimens.space16),
              const SizedBox(width: PsDimens.space16),
              Text(
                Utils.getString(context, 'noti__latest_message'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              bottom: PsDimens.space16,
              left: PsDimens.space44,
              right: PsDimens.space16),
          child: Text(
            PsSharedPreferences.instance.getNotiMessage() ?? '-',
            style: Theme.of(context).textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),

        const Divider(height: PsDimens.space1),
        const SizedBox(height: PsDimens.space8),

        // ── Granular settings (only when global is ON) ────────────────
        if (_globalEnabled) ...[
          // "تفعيل الكل / إيقاف الكل" shortcut
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: PsDimens.space16, vertical: PsDimens.space4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Utils.getString(context, 'noti_setting__granular_title'),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => _toggleAllGranular(!_allGranularEnabled),
                  child: Text(
                    _allGranularEnabled
                        ? Utils.getString(
                        context, 'noti_setting__disable_all')
                        : Utils.getString(
                        context, 'noti_setting__enable_all'),
                    style: TextStyle(
                      color: PsColors.primary500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          for (final _Section section in _sections) ...[
            _SectionHeader(
              title: Utils.getString(context, section.titleKey),
            ),
            for (final _Item item in section.items)
              _GranularTile(
                item: item,
                value: _granular[item.key] ?? true,
                onChanged: (v) => _setGranular(item.key, v),
                labelText: Utils.getString(context, item.labelKey),
              ),
            const SizedBox(height: PsDimens.space8),
          ],
        ],

        // ── Token ID (debug — original feature) ───────────────────────
        if (notiProvider.psValueHolder!.isShowTokenId!) _TokenIdWidget(),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _GlobalToggleWidget extends StatelessWidget {
  const _GlobalToggleWidget(
      {required this.enabled, required this.onToggle});
  final bool enabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space8,
          top: PsDimens.space8,
          bottom: PsDimens.space8,
          right: PsDimens.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Utils.getString(context, 'noti_setting__onof'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onToggle,
            activeTrackColor: PsColors.activeColor,
            activeColor: PsColors.activeColor,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          PsDimens.space16, PsDimens.space12, PsDimens.space16, PsDimens.space4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GranularTile extends StatelessWidget {
  const _GranularTile({
    required this.item,
    required this.value,
    required this.onChanged,
    required this.labelText,
  });

  final _Item item;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: item.color.withOpacity(value ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(PsDimens.space8),
        ),
        child: Icon(
          item.icon,
          size: 18,
          color: value ? item.color : Colors.grey,
        ),
      ),
      title: Text(
        labelText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: value
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: item.color,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _TokenIdWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: PsDimens.space1),
        Padding(
          padding: const EdgeInsets.only(
              top: PsDimens.space20,
              left: PsDimens.space16,
              right: PsDimens.space16),
          child: Text(
            'Token Id',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(
                text: notiProvider.psValueHolder!.deviceToken ?? ''));
            Fluttertoast.showToast(
              msg: 'Token copied.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: PsColors.primary500,
              textColor: PsColors.white,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(PsDimens.space16),
            child: Text(
              '${notiProvider.psValueHolder!.deviceToken}',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        const Divider(height: PsDimens.space1),
      ],
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _Section {
  const _Section({required this.titleKey, required this.items});
  final String titleKey;
  final List<_Item> items;
}

class _Item {
  const _Item(this.key, this.labelKey, this.icon, this.color);
  final String key;
  final String labelKey;
  final IconData icon;
  final Color color;
}
