import 'dart:convert';
import 'package:taapdeel/utils/perf_benchmark.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:http/http.dart' as http;

import '../../config/ps_config.dart';
import '../../db/common/ps_shared_preferences.dart';

// ─────────────────────────────────────────────
// Brand tokens
// ─────────────────────────────────────────────
class _Brand {
  static const Color primary      = Color(0xFF0B7B6B);
  static const Color primaryLight = Color(0xFFE6F5F3);
  static const Color danger       = Color(0xFFDC2626);
  static const Color dangerLight  = Color(0xFFFEE2E2);
  static const Color surface      = Color(0xFFF8FAFC);
  static const Color border       = Color(0xFFE2E8F0);
  static const Color textPrimary  = Color(0xFF0F172A);
  static const Color textSecond   = Color(0xFF64748B);
  static const Color textHint     = Color(0xFF94A3B8);
}

// ─────────────────────────────────────────────
// Relation meta
// ─────────────────────────────────────────────
class _RelMeta {
  const _RelMeta({required this.id, required this.label, required this.icon, required this.color, required this.bg});
  final int id;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  static const List<_RelMeta> all = [
    _RelMeta(id: 1, label: 'أصدقاء',       icon: Icons.group_rounded,           color: Color(0xFF2563EB), bg: Color(0xFFEFF6FF)),
    _RelMeta(id: 2, label: 'زوج / زوجة',   icon: Icons.favorite_rounded,        color: Color(0xFFDB2777), bg: Color(0xFFFDF2F8)),
    _RelMeta(id: 3, label: 'ابن / ابنة',   icon: Icons.child_care_rounded,      color: Color(0xFF059669), bg: Color(0xFFECFDF5)),
    _RelMeta(id: 4, label: 'أم / أب',      icon: Icons.account_circle_rounded,  color: Color(0xFFD97706), bg: Color(0xFFFFFBEB)),
    _RelMeta(id: 5, label: 'أخ / أخت',    icon: Icons.people_alt_rounded,      color: Color(0xFF7C3AED), bg: Color(0xFFF5F3FF)),
    _RelMeta(id: 6, label: 'عائلة كبيرة', icon: Icons.family_restroom_rounded, color: Color(0xFF0B7B6B), bg: Color(0xFFE6F5F3)),
  ];

  static _RelMeta fromId(int id) => all.firstWhere((r) => r.id == id, orElse: () => all.first);
}

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────
class FollowRequest {
  final String recordId;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhoto;
  final String? fromUserGender;
  final int relationType;

  const FollowRequest({
    required this.recordId,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPhoto,
    this.fromUserGender,
    required this.relationType,
  });

  factory FollowRequest.fromJson(Map<String, dynamic> j) => FollowRequest(
    recordId    : j['id']?.toString() ?? '',
    fromUserId  : j['user_id']?.toString() ?? '',
    fromUserName: j['user_name']?.toString() ?? 'مستخدم',
    fromUserPhoto : j['user_profile_photo']?.toString(),
    fromUserGender: j['user_gender']?.toString(),
    relationType  : int.tryParse(j['relation_type']?.toString() ?? '1') ?? 1,
  );

  FollowRequest copyWith({int? relationType}) => FollowRequest(
    recordId      : recordId,
    fromUserId    : fromUserId,
    fromUserName  : fromUserName,
    fromUserPhoto : fromUserPhoto,
    fromUserGender: fromUserGender,
    relationType  : relationType ?? this.relationType,
  );
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────
class _Notifier extends ChangeNotifier {
  List<FollowRequest> items = [];
  bool loading = false;
  String? error;
  final Set<String> _accepted = {};
  final Set<String> _rejected = {};

  bool isAccepted(String id) => _accepted.contains(id);
  bool isRejected(String id) => _rejected.contains(id);

  String get _rest {
    final String b = PsConfig.ps_app_url.trim();
    final String n = b.endsWith('/') ? b.substring(0, b.length - 1) : b;
    return n.endsWith('/rest') ? n : '$n/rest';
  }

  Future<void> load(String uid) async {
    // ✅ BENCHMARK: وقت تحميل قائمة طلبات المتابعة من السيرفر
    TaapdeelPerfBenchmark.start('follow_requests_load');

    loading = true; error = null; notifyListeners();
    try {
      final res = await http.get(
        Uri.parse('$_rest/follow_request/pending?user_id=${Uri.encodeQueryComponent(uid)}'),
      ).timeout(const Duration(seconds: 12));
      final dynamic d = jsonDecode(res.body);
      if (d is Map && d['status'] == 'success') {
        items = (d['requests'] as List<dynamic>? ?? [])
            .map((e) => FollowRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      } else { error = 'فشل التحميل'; }
    } catch (e) { error = e.toString(); }
    finally {
      loading = false;
      TaapdeelPerfBenchmark.end('follow_requests_load');
      notifyListeners();
    }
  }

  Future<bool> _post(String endpoint, Map<String, String> body) async {
    try {
      final res = await http.post(Uri.parse('$_rest/$endpoint'), body: body)
          .timeout(const Duration(seconds: 12));
      final dynamic d = jsonDecode(res.body);
      return d is Map && d['status'] == 'success';
    } catch (_) { return false; }
  }

  Future<bool> accept(String uid, String rid, int relationType) async {
    // ✅ BENCHMARK: وقت قبول طلب متابعة
    TaapdeelPerfBenchmark.start('follow_accept_$rid');

    _accepted.add(rid); notifyListeners();
    final ok = await _post('follow_request/accept', <String, String>{
      'record_id': rid,
      'user_id': uid,
      'relation_type': relationType.toString(),
    });
    TaapdeelPerfBenchmark.end('follow_accept_$rid');
    if (!ok) { _accepted.remove(rid); notifyListeners(); }
    return ok;
  }

  Future<bool> reject(String uid, String rid) async {
    // ✅ BENCHMARK: وقت رفض طلب متابعة
    TaapdeelPerfBenchmark.start('follow_reject_$rid');

    _rejected.add(rid); notifyListeners();
    final ok = await _post('follow_request/reject', {'record_id': rid, 'user_id': uid});
    TaapdeelPerfBenchmark.end('follow_reject_$rid');
    if (!ok) { _rejected.remove(rid); notifyListeners(); }
    return ok;
  }

  void updateRelation(String rid, int rel) {
    final int i = items.indexWhere((r) => r.recordId == rid);
    if (i == -1) return;
    items[i] = items[i].copyWith(relationType: rel);
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class FollowRequestsScreen extends StatefulWidget {
  const FollowRequestsScreen({Key? key, required this.baseUrl}) : super(key: key);
  final String baseUrl;

  @override
  State<FollowRequestsScreen> createState() => _FollowRequestsScreenState();
}

class _FollowRequestsScreenState extends State<FollowRequestsScreen> {
  late final _Notifier _n;
  late final String _uid;

  @override
  void initState() {
    super.initState();
    // ✅ BENCHMARK: وقت فتح شاشة طلبات المتابعة من initState لأول frame
    TaapdeelPerfBenchmark.start('follow_requests_screen_open');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TaapdeelPerfBenchmark.end('follow_requests_screen_open');
    });
    _uid = PsSharedPreferences.instance.shared.getString(PsConst.VALUE_HOLDER__USER_ID) ?? '';
    _n = _Notifier()..load(_uid);
  }

  @override
  void dispose() { _n.dispose(); super.dispose(); }

  void _toast(String msg, {bool ok = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      backgroundColor: ok ? _Brand.primary : _Brand.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _editRelation(FollowRequest req) async {
    final int? picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RelPicker(currentId: req.relationType),
    );
    if (picked != null && picked != req.relationType) {
      _n.updateRelation(req.recordId, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Brand.surface,
      appBar: _AppBar(onBack: () => Navigator.pop(context)),
      body: AnimatedBuilder(
        animation: _n,
        builder: (_, __) {
          if (_n.loading) return _Loading();
          if (_n.error != null) return _Error(msg: _n.error!, onRetry: () => _n.load(_uid));
          final List<FollowRequest> pending = _n.items
              .where((r) => !_n.isAccepted(r.recordId) && !_n.isRejected(r.recordId))
              .toList();
          if (pending.isEmpty) return const _Empty();
          return RefreshIndicator(
            color: _Brand.primary,
            onRefresh: () => _n.load(_uid),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final req = pending[i];
                return _Card(
                  req: req,
                  onEdit: () => _editRelation(req),
                  onAccept: () async {
                    HapticFeedback.mediumImpact();
                    final bool ok = await _n.accept(_uid, req.recordId, req.relationType);
                    if (!mounted) return;
                    _toast(ok ? 'تم القبول ✓' : 'حدث خطأ، حاول مجدداً', ok: ok);
                  },
                  onReject: () async {
                    HapticFeedback.lightImpact();
                    final bool ok = await _n.reject(_uid, req.recordId);
                    if (!mounted) return;
                    _toast(ok ? 'تم الرفض' : 'حدث خطأ، حاول مجدداً', ok: ok);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: 61,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _Brand.surface,
                        border: Border.all(color: _Brand.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: _Brand.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('طلبات المتابعة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _Brand.textPrimary, height: 1.1)),
                      Text('راجع وأكد العلاقات الواردة', style: TextStyle(fontSize: 11, color: _Brand.textSecond, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: _Brand.border),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Request Card
// ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.req, required this.onEdit, required this.onAccept, required this.onReject});
  final FollowRequest req;
  final VoidCallback onEdit;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final _RelMeta meta = _RelMeta.fromId(req.relationType);
    final bool fem = (req.fromUserGender ?? '').toLowerCase().contains('f') ||
        (req.fromUserGender ?? '').contains('أنثى');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Brand.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            decoration: BoxDecoration(
              color: meta.bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                Icon(meta.icon, size: 13, color: meta.color),
                const SizedBox(width: 6),
                Text('طلب علاقة — ${meta.label}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: meta.color)),
                const Spacer(),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              children: [
                // User
                Row(
                  children: [
                    _Ava(photo: req.fromUserPhoto, name: req.fromUserName, fem: fem),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req.fromUserName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: _Brand.textPrimary)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 12, color: _Brand.textHint),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text('يريد إضافتك كـ ${meta.label}',
                                    style: const TextStyle(fontSize: 12, color: _Brand.textSecond, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 0.5, color: _Brand.border),
                const SizedBox(height: 14),
                // Buttons
                Row(
                  children: [
                    Expanded(flex: 3, child: _Btn(label: 'قبول', icon: Icons.check_rounded, primary: true, onTap: onAccept)),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _Btn(label: 'تعديل', icon: Icons.edit_rounded, primary: false, onTap: onEdit)),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _Btn(label: 'رفض', icon: Icons.close_rounded, primary: false, onTap: onReject)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ava extends StatelessWidget {
  const _Ava({required this.photo, required this.name, required this.fem});
  final String? photo;
  final String name;
  final bool fem;

  @override
  Widget build(BuildContext context) {
    final Color bg = fem ? const Color(0xFFFDF2F8) : const Color(0xFFEFF6FF);
    final Color bd = fem ? const Color(0xFFF9A8D4) : const Color(0xFF93C5FD);
    final Color fg = fem ? const Color(0xFFDB2777) : const Color(0xFF2563EB);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg, border: Border.all(color: bd, width: 2)),
      child: (photo != null && photo!.isNotEmpty)
          ? ClipOval(child: Image.network(photo!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _init(name, fg)))
          : _init(name, fg),
    );
  }

  Widget _init(String n, Color fg) {
    final String c = n.trim().isNotEmpty ? n.trim()[0].toUpperCase() : '?';
    return Center(child: Text(c, style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 20)));
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.icon, required this.primary, required this.onTap});
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: primary ? _Brand.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary ? _Brand.primary : _Brand.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: primary ? Colors.white : _Brand.textSecond),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                  color: primary ? Colors.white : _Brand.textSecond)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ✅ Relation Picker Sheet
// ─────────────────────────────────────────────
class _RelPicker extends StatelessWidget {
  const _RelPicker({required this.currentId});
  final int currentId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(margin: const EdgeInsets.only(top: 12, bottom: 18),
              width: 38, height: 4,
              decoration: BoxDecoration(color: _Brand.border, borderRadius: BorderRadius.circular(99))),

          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: _Brand.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.edit_rounded, size: 17, color: _Brand.primary),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('تعديل العلاقة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _Brand.textPrimary)),
                  Text('اختر العلاقة الصحيحة', style: TextStyle(fontSize: 11, color: _Brand.textSecond, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _RelMeta.all.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.05,
            ),
            itemBuilder: (_, i) {
              final _RelMeta r = _RelMeta.all[i];
              final bool sel = r.id == currentId;
              return GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); Navigator.pop(context, r.id); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 130),
                  decoration: BoxDecoration(
                    color: sel ? r.bg : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: sel ? r.color.withOpacity(0.55) : _Brand.border, width: sel ? 1.5 : 0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: sel ? r.color.withOpacity(0.12) : _Brand.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(r.icon, size: 17, color: r.color),
                      ),
                      const SizedBox(height: 7),
                      Text(r.label, textAlign: TextAlign.center, maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                              color: sel ? r.color : _Brand.textPrimary, height: 1)),
                      if (sel) ...[
                        const SizedBox(height: 4),
                        Icon(Icons.check_circle_rounded, size: 12, color: r.color),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _Brand.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _Brand.primary.withOpacity(0.18)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, size: 13, color: _Brand.primary),
                SizedBox(width: 8),
                Expanded(child: Text('تعديل العلاقة يؤثر على المنتجات المعروضة في الـ feed.',
                    style: TextStyle(fontSize: 11, color: _Brand.primary, fontWeight: FontWeight.w600, height: 1.4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// States
// ─────────────────────────────────────────────
class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 36, height: 36,
          child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: const AlwaysStoppedAnimation(_Brand.primary))),
      const SizedBox(height: 12),
      const Text('جاري التحميل...', style: TextStyle(color: _Brand.textSecond, fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.msg, required this.onRetry});
  final String msg;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 60, height: 60,
            decoration: BoxDecoration(color: _Brand.dangerLight, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.wifi_off_rounded, size: 28, color: _Brand.danger)),
        const SizedBox(height: 14),
        const Text('تعذّر تحميل الطلبات',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: _Brand.textPrimary)),
        const SizedBox(height: 6),
        Text(msg, textAlign: TextAlign.center,
            style: const TextStyle(color: _Brand.textSecond, fontSize: 12)),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 15),
          label: const Text('إعادة المحاولة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _Brand.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ]),
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 76, height: 76,
            decoration: BoxDecoration(color: _Brand.primaryLight, borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.people_outline_rounded, size: 36, color: _Brand.primary)),
        const SizedBox(height: 16),
        const Text('لا توجد طلبات معلقة',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _Brand.textPrimary)),
        const SizedBox(height: 8),
        const Text('ستظهر هنا طلبات المتابعة الواردة\nبمجرد إرسالها من أشخاص في قائمة جهات اتصالك',
            textAlign: TextAlign.center,
            style: TextStyle(color: _Brand.textSecond, fontWeight: FontWeight.w500, fontSize: 13, height: 1.5)),
      ]),
    ),
  );
}
