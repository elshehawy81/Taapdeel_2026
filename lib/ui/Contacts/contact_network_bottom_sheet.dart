import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../config/ps_config.dart';
import '../../constant/ps_constants.dart';
import '../../constant/route_paths.dart';
import '../../db/common/ps_shared_preferences.dart';
import '../../viewobject/common/ps_value_holder.dart';
import '../common/ps_ui_widget.dart';
import '../common/taapdeel/taapdeel_glass_bottom_sheet.dart';
import 'contact_network_provider.dart';
import 'pending_follows_cache.dart';
import 'user_phone_model.dart';

class ContactNetworkBottomSheet {
  static Future<void> show(BuildContext context) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.42),
      builder: (_) => ChangeNotifierProvider<ContactNetworkProvider>.value(
        value: context.read<ContactNetworkProvider>(),
        child: const _ContactNetworkSheetBody(),
      ),
    );
  }
}

class _C {
  static const Color deep = Color(0xFF06365E);
  static const Color navy = Color(0xFF082A4A);
  static const Color teal = Color(0xFF007D98);
  static const Color aqua = Color(0xFF63CAD6);
  static const Color softAqua = Color(0xFFE9FBFF);
  static const Color text = Color(0xFF102A43);
  static const Color muted = Color(0xFF667085);
  static const Color border = Color(0xFFE4EEF2);

  static const Color family = Color(0xFFFF9F1C);
  static const Color family2 = Color(0xFFFF7A00);
  static const Color network = Color(0xFF2F80ED);
  static const Color network2 = Color(0xFF20A4F3);
  static const Color trust = Color(0xFF0A7EA0);
  static const Color trust2 = Color(0xFF14B8A6);
}

enum _GenderKind { male, female, unknown }

class _ContactNetworkSheetBody extends StatefulWidget {
  const _ContactNetworkSheetBody();

  @override
  State<_ContactNetworkSheetBody> createState() => _ContactNetworkSheetBodyState();
}

class _ContactNetworkSheetBodyState extends State<_ContactNetworkSheetBody> {
  final Map<String, int> _selectedRelationByUserId = <String, int>{};
  bool _sending = false;

  List<_RelationOption> get _relations => const <_RelationOption>[
    _RelationOption(
      1,
      'صديق/زميل',
      Icons.group_rounded,
      Color(0xFF3B82F6),
      Color(0xFFEFF6FF),
      'الأكثر شيوعًا للمعارف والزملاء',
    ),
    _RelationOption(
      2,
      'زوج/زوجة',
      Icons.favorite_rounded,
      Color(0xFFFB7185),
      Color(0xFFFFF1F2),
      'للزوجين فقط ويؤثر على الثقة',
    ),
    _RelationOption(
      3,
      'ابن/ابنة',
      Icons.child_care_rounded,
      Color(0xFF22C55E),
      Color(0xFFECFDF3),
      'عندما يكون الشخص أحد الأبناء',
    ),
    _RelationOption(
      4,
      'أم/أب',
      Icons.account_circle_rounded,
      Color(0xFFF59E0B),
      Color(0xFFFFF7E6),
      'عندما يكون الشخص أحد الوالدين',
    ),
    _RelationOption(
      5,
      'أخ/أخت',
      Icons.people_alt_rounded,
      Color(0xFF8B5CF6),
      Color(0xFFF5F3FF),
      'لإضافة الإخوة والأخوات',
    ),
    _RelationOption(
      6,
      'عائلة',
      Icons.family_restroom_rounded,
      Color(0xFF14B8A6),
      Color(0xFFE6FFFB),
      'أقاربك ومعارف العائلة',
    ),
  ];

  _UserMeta _currentUserMeta() {
    try {
      final PsValueHolder vh = context.read<PsValueHolder>();
      final dynamic dyn = vh;
      final String gender = ((dyn.userGender as String?) ?? '').trim();
      final String age = ((dyn.userAgeRange as String?) ?? '').trim();
      return _UserMeta(gender: _parseGender(gender), age: _parseAge(age));
    } catch (_) {
      return const _UserMeta();
    }
  }

  List<_RelationOption> _smartRelationsFor(UsersPhoneModel user) {
    return _relations;
  }

  Future<int?> _pickRelation(UsersPhoneModel user) async {
    final List<_RelationOption> options = _smartRelationsFor(user);
    final String name = _displayName(user);

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.32),
      builder: (_) => TaapdeelGlassBottomSheet(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: <Color>[_C.aqua, _C.teal],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: _C.teal.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العلاقات المقترحة مع $name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _C.text,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'اختر العلاقة المناسبة بينك وبين هذا الشخص.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _C.muted,
                          fontSize: 11.4,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (_, i) {
                final _RelationOption r = options[i];
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context, r.id);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[Colors.white, r.bg.withOpacity(0.88)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: r.color.withOpacity(0.25), width: 1.2),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: r.color.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: r.bg,
                          ),
                          child: Icon(r.icon, color: r.color, size: 19),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11.0,
                            color: r.color,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.hint,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 8.5,
                            color: Colors.black.withOpacity(0.45),
                            height: 1.08,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleUser(UsersPhoneModel user) async {
    final String userId = (user.userId ?? '').trim();
    if (userId.isEmpty) return;

    if (_selectedRelationByUserId.containsKey(userId)) {
      setState(() => _selectedRelationByUserId.remove(userId));
      return;
    }

    final int? rel = await _pickRelation(user);
    if (!mounted || rel == null) return;
    setState(() => _selectedRelationByUserId[userId] = rel);
  }

  Future<bool> _sendFollowRequest({
    required String fromUserId,
    required String toUserId,
    required int relationType,
  }) async {
    final String base = PsConfig.ps_app_url.trim().endsWith('/')
        ? PsConfig.ps_app_url.trim()
        : '${PsConfig.ps_app_url.trim()}/';
    final Uri uri = Uri.parse('${base}rest/follow_request/send');

    final http.Response res = await http.post(
      uri,
      headers: const <String, String>{'Accept': 'application/json'},
      body: <String, String>{
        'user_id': fromUserId,
        'followed_user_id': toUserId,
        'relation_type': relationType.toString(),
      },
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) return false;
    final dynamic decoded = jsonDecode(res.body);
    return decoded is Map && decoded['status'] == 'success';
  }

  Future<void> _sendSelected(ContactNetworkProvider provider) async {
    if (_selectedRelationByUserId.isEmpty || _sending) return;

    final String uid = (PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__USER_ID) ??
        '')
        .trim();

    final bool loggedIn = uid.isNotEmpty && uid.toLowerCase() != 'nologinuser';

    if (!loggedIn) {
      final Map<String, int> pending = PendingFollowsCache.read();
      pending.addAll(_selectedRelationByUserId);
      await PendingFollowsCache.save(pending);

      if (!mounted) return;

      final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

      Navigator.pop(context);

      messenger.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('تم حفظ الاختيارات. سجّل الدخول لإرسال طلبات الإضافة تلقائيًا.'),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 180));
      rootNavigator.pushNamed(RoutePaths.login_container);
      return;
    }

    setState(() => _sending = true);
    final Set<String> successIds = <String>{};

    for (final MapEntry<String, int> e in _selectedRelationByUserId.entries) {
      try {
        final bool ok = await _sendFollowRequest(
          fromUserId: uid,
          toUserId: e.key,
          relationType: e.value,
        );
        if (ok) successIds.add(e.key);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _sending = false);

    if (successIds.isNotEmpty) {
      await provider.markUsersHandled(successIds);
      if (!mounted) return;
      setState(() {
        for (final String id in successIds) {
          _selectedRelationByUserId.remove(id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('تم إرسال ${successIds.length} طلب إضافة للشبكة'),
        ),
      );
      if (provider.pendingCount == 0 && mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactNetworkProvider>(
      builder: (context, provider, _) {
        final bool hasPermission = provider.hasPermission;
        final List<UsersPhoneModel> people = provider.suggestions;
        final double maxHeight = MediaQuery.sizeOf(context).height * 0.91;

        return SafeArea(
          top: false,
          child: TaapdeelGlassBottomSheet(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SheetHeroHeader(
                    count: provider.pendingCount,
                    syncing: provider.isSyncing,
                    onRefresh: hasPermission
                        ? () => provider.syncInBackground(force: true, reason: 'manual_bottom_sheet')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  if (!hasPermission)
                    _PermissionPanel(
                      loading: provider.isSyncing,
                      onAllow: () => provider.requestPermissionAndSync(
                        force: true,
                        reason: 'bottom_sheet_permission',
                      ),
                    )
                  else if (people.isEmpty)
                    _EmptyPanel(
                      syncing: provider.isSyncing,
                      onRefresh: () => provider.syncInBackground(force: true, reason: 'empty_manual'),
                    )
                  else
                    Flexible(
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 4),
                        itemCount: people.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.95,
                        ),
                        itemBuilder: (_, i) {
                          final UsersPhoneModel user = people[i];
                          final String id = (user.userId ?? '').trim();
                          final int relationId = _selectedRelationByUserId[id] ?? 0;
                          return _PersonCard(
                            user: user,
                            selectedRelation: _relationById(relationId),
                            onTap: () => _toggleUser(user),
                            onDismiss: () => provider.dismissUser(id),
                          );
                        },
                      ),
                    ),
                  if (hasPermission && people.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _BottomActionBar(
                      count: _selectedRelationByUserId.length,
                      sending: _sending,
                      onTap: _selectedRelationByUserId.isEmpty || _sending
                          ? null
                          : () => _sendSelected(provider),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _RelationOption? _relationById(int id) {
    for (final _RelationOption r in _relations) {
      if (r.id == id) return r;
    }
    return null;
  }
}

class _SheetHeroHeader extends StatelessWidget {
  const _SheetHeroHeader({
    required this.count,
    required this.syncing,
    required this.onRefresh,
  });

  final int count;
  final bool syncing;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: <Color>[_C.aqua, _C.teal, _C.deep],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _C.teal.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withOpacity(0.18),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: const Icon(
                  Icons.groups_2_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              if (count > 0)
                PositionedDirectional(
                  top: -7,
                  end: -7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB020),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Color(0xFF231307),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count > 0
                      ? '$count أصدقاء / أقارب جدد'
                      : 'شبكة العائلة والأصدقاء',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'أضف عائلتك وأصدقاءك للاستمتاع بالمميزات',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.86),
                    fontSize: 11.4,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                const _HeaderMiniBenefits(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (syncing)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
          else if (onRefresh != null)
            Material(
              color: Colors.white.withOpacity(0.18),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRefresh,
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderMiniBenefits extends StatelessWidget {
  const _HeaderMiniBenefits();

  @override
  Widget build(BuildContext context) {
    const List<_HeaderMiniBenefit> benefits = <_HeaderMiniBenefit>[
      _HeaderMiniBenefit(
        Icons.home_work_rounded,
        'معرض العائلة',
      ),
      _HeaderMiniBenefit(
        Icons.message,
        'رسائل لطيفه',
      ),
      _HeaderMiniBenefit(
        Icons.hub_rounded,
        'منتجات الأصدقاء وأقاربهم',
      ),
      _HeaderMiniBenefit(
        Icons.verified_user_rounded,
        'ترشيحات أوثق',
      ),
    ];

    return SizedBox(
      height: 28,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: benefits.map((_HeaderMiniBenefit benefit) {
              final bool isLast = benefit == benefits.last;

              return Padding(
                padding: EdgeInsetsDirectional.only(
                  end: isLast ? 0 : 6,
                ),
                child: Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: 7,
                    end: 8,
                    top: 5,
                    bottom: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.22),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        benefit.icon,
                        size: 12.5,
                        color: Colors.white.withOpacity(0.95),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        benefit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w900,
                          fontSize: 9.7,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _HeaderMiniBenefit {
  const _HeaderMiniBenefit(this.icon, this.title);

  final IconData icon;
  final String title;
}

class _PermissionPanel extends StatelessWidget {
  const _PermissionPanel({required this.loading, required this.onAllow});
  final bool loading;
  final Future<bool> Function() onAllow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _C.aqua.withOpacity(0.28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _C.teal.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: _C.softAqua,
            ),
            child: const Icon(Icons.security_rounded, color: _C.trust, size: 30),
          ),
          const SizedBox(height: 10),
          const Text(
            'اكتشف الأقارب والأصدقاء الموجودين على تبديل',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: _C.text),
          ),
          const SizedBox(height: 7),
          Text(
            'نستخدم جهات الاتصال فقط للمطابقة مع مستخدمين موجودين بالفعل. لا نعرض أرقامك لأي شخص.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              height: 1.45,
              fontSize: 12.2,
              color: Colors.black.withOpacity(0.58),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: loading ? null : onAllow,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(colors: <Color>[_C.aqua, _C.teal]),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _C.teal.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: loading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text(
                'اكتشف شبكتي الآن',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.syncing, required this.onRefresh});
  final bool syncing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_rounded, color: Colors.black.withOpacity(0.36), size: 44),
          const SizedBox(height: 8),
          const Text(
            'لاضافة المزيد من الاصدقاء والاقارب',
            style: TextStyle(fontWeight: FontWeight.w900, color: _C.text),
          ),
          const SizedBox(height: 5),
          Text(
            'شارك التطبيق لترشيحات تبديل افضل واكثر ثقة.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.52)),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: syncing ? null : onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.user,
    required this.selectedRelation,
    required this.onTap,
    required this.onDismiss,
  });

  final UsersPhoneModel user;
  final _RelationOption? selectedRelation;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final String displayName = _displayName(user);
    final String appName = _appName(user);
    final bool showAppName = _hasDifferentLocalName(user);
    final int itemsCount = user.itemsCount ?? int.tryParse(user.postCount ?? '') ?? 0;
    final bool selected = selectedRelation != null;
    final Color accent = selectedRelation?.color ?? _C.teal;
    final Color bg = selectedRelation?.bg ?? _C.softAqua;
    final double rating = double.tryParse(user.overallRating ?? '') ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 210),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.white, Colors.white.withOpacity(0.92)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? _C.aqua.withOpacity(0.42) : Colors.black.withOpacity(0.07),
              width: selected ? 1.3 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.050),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              PositionedDirectional(
                top: -7,
                end: -7,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onDismiss,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.black.withOpacity(0.28),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ContactAvatar(
                      user: user,
                      name: displayName,
                      accent: accent,
                      bg: bg,
                      selected: selected,
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        displayName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.2,
                          color: _C.text,
                          height: 1.0,
                        ),
                      ),
                    ),
                    if (showAppName) ...[
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'على تبديل: $appName',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 9.5,
                            color: Colors.black.withOpacity(0.38),
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        _MiniChip(
                          icon: Icons.inventory_2_rounded,
                          text: '$itemsCount منتجات',
                          color: _C.teal,
                          bg: _C.softAqua,
                        ),
                        if (rating > 0)
                          _MiniChip(
                            icon: Icons.star_rounded,
                            text: rating.toStringAsFixed(1),
                            color: const Color(0xFFE8A000),
                            bg: const Color(0xFFFFF7DB),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 170),
                      child: selected
                          ? Container(
                        key: ValueKey<int>(selectedRelation!.id),
                        constraints: const BoxConstraints(maxWidth: 125),
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: accent.withOpacity(0.26)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(selectedRelation!.icon, size: 12, color: accent),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                selectedRelation!.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.6,
                                  color: accent,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : Text(
                        'اضغط وحدد العلاقة',
                        key: const ValueKey<String>('hint'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          color: Colors.black.withOpacity(0.40),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({
    required this.user,
    required this.name,
    required this.accent,
    required this.bg,
    required this.selected,
  });

  final UsersPhoneModel user;
  final String name;
  final Color accent;
  final Color bg;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final String code = (user.code ?? user.userId ?? '').trim();
    final String heroTag = '$code${PsConst.HERO_TAG__IMAGE}';
    final String imagePath = (user.userProfilePhoto ?? '').trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: <Color>[bg, Colors.white],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: selected ? accent : _C.aqua.withOpacity(0.45),
              width: selected ? 2.4 : 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (selected ? accent : _C.teal).withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: ClipOval(
            child: PsNetworkCircleImageForUser(
              photoKey: heroTag,
              imagePath: imagePath,
              gender: user.userGender,
              ageRange: user.userAge,
              width: 62,
              height: 62,
            ),
          ),
        ),
        PositionedDirectional(
          bottom: -3,
          start: -2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? accent : Colors.white,
              border: Border.all(color: selected ? Colors.white : _C.aqua, width: 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              selected ? Icons.check_rounded : Icons.add_rounded,
              color: selected ? Colors.white : _C.teal,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial({
    required this.name,
    required this.accent,
    required this.bg,
  });

  final String name;
  final Color accent;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg.withOpacity(0.75),
      alignment: Alignment.center,
      child: Text(
        _initial(name),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: accent,
          fontSize: 23,
          height: 1,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.icon,
    required this.text,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: color,
              fontSize: 10.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.count,
    required this.sending,
    required this.onTap,
  });

  final int count;
  final bool sending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = count > 0 && onTap != null;
    return Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              enabled ? 'تم اختيار $count' : 'اختر الأشخاص وحدد العلاقة',
              key: ValueKey<String>(enabled ? 'selected_$count' : 'empty'),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: enabled ? _C.text : Colors.black.withOpacity(0.48),
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: enabled ? const LinearGradient(colors: <Color>[_C.aqua, _C.teal]) : null,
              color: enabled ? null : Colors.black.withOpacity(0.08),
              boxShadow: enabled
                  ? <BoxShadow>[
                BoxShadow(
                  color: _C.teal.withOpacity(0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
                  : null,
            ),
            child: sending
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  enabled ? 'اضف لعلاقاتك' : 'اختر أولًا',
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.black.withOpacity(0.38),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(width: 7),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RelationOption {
  const _RelationOption(this.id, this.label, this.icon, this.color, this.bg, this.hint);
  final int id;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final String hint;
}

class _UserMeta {
  const _UserMeta({this.gender = _GenderKind.unknown, this.age});
  final _GenderKind gender;
  final int? age;
}

String _displayName(UsersPhoneModel user) {
  final String contactName = (user.localContactName ?? '').trim();
  if (contactName.isNotEmpty) return contactName;

  final String appName = (user.userName ?? '').trim();
  return appName.isEmpty ? 'مستخدم تبديل' : appName;
}

String _appName(UsersPhoneModel user) {
  final String appName = (user.userName ?? '').trim();
  return appName.isEmpty ? 'مستخدم تبديل' : appName;
}

bool _hasDifferentLocalName(UsersPhoneModel user) {
  final String contactName = (user.localContactName ?? '').trim();
  final String appName = (user.userName ?? '').trim();
  if (contactName.isEmpty || appName.isEmpty) return false;
  return contactName.toLowerCase() != appName.toLowerCase();
}

String _initial(String name) {
  final String n = name.trim();
  if (n.isEmpty) return '؟';
  return n.substring(0, math.min(1, n.length)).toUpperCase();
}

_GenderKind _parseGender(String? raw) {
  final String v = (raw ?? '').trim().toLowerCase();
  if (v.isEmpty) return _GenderKind.unknown;

  if (v == '1' || v.contains('male') || v.contains('ذكر') || v.contains('رجل') || v.contains('ولد')) {
    if (!v.contains('female')) return _GenderKind.male;
  }

  if (v == '2' || v.contains('female') || v.contains('أنث') || v.contains('انث') || v.contains('بنت') || v.contains('امرأة') || v.contains('مرأ')) {
    return _GenderKind.female;
  }

  return _GenderKind.unknown;
}

int? _parseAge(String? raw) {
  final String v = (raw ?? '').trim();
  if (v.isEmpty) return null;

  final Iterable<RegExpMatch> matches = RegExp(r'\d+').allMatches(v);
  final List<int> nums = matches.map((m) => int.tryParse(m.group(0) ?? '') ?? 0).where((n) => n > 0).toList();
  if (nums.isEmpty) return null;
  if (nums.length == 1) return nums.first;
  return ((nums.first + nums[1]) / 2).round();
}
