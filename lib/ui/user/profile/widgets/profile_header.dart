import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/product/added_item_provider.dart';
import 'package:taapdeel/provider/product/paid_id_item_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/ui/Contacts/follow_requests_screen.dart';
import 'package:taapdeel/ui/user/user_detail/user_detail_view.dart';
import 'package:taapdeel/ui/common/ps_button_widget_with_round_corner.dart';
import 'package:taapdeel/ui/common/ps_frame_loading_widget.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/common/smooth_star_rating_widget.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_info_card_shell.dart';
import 'package:taapdeel/ui/item/paid_ad/paid_ad_item_horizontal_list_item.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/user.dart';
import 'package:provider/provider.dart';

import '../../../Contacts/follow_request_badge_provider.dart';
import '../../../Contacts/contact_network_bottom_sheet.dart';

// ─────────────────────────────────────────────────────────────
// Brand tokens (متناسقة مع البراند)
// ─────────────────────────────────────────────────────────────
class _B {
  static const Color primary = Color(0xFF0B7B6B);
  static const Color primaryLt = Color(0xFFE6F5F3);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLt = Color(0xFFFEE2E2);
  static const Color border = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecond = Color(0xFF64748B);
}

// ─────────────────────────────────────────────────────────────
// PaidAdsSection
// ─────────────────────────────────────────────────────────────
class PaidAdsSection extends StatelessWidget {
  const PaidAdsSection({required this.onPromote});
  final VoidCallback onPromote;


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaidAdItemProvider>(
      builder: (context, p, _) {
        final List<dynamic> ads = p.paidAdItemList.data ?? [];
        final bool loading = p.paidAdItemList.status == PsStatus.BLOCK_LOADING;

        if (loading && ads.isEmpty) {
          return const Center(child: PsFrameUIForLoading());
        }

        if (ads.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
            child: TaapdeelInfoCardShell(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              withBlur: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderWidget(
                    headerName: Utils.getString(context, 'profile__paid_ad'),
                    viewAllClicked: () =>
                        Navigator.pushNamed(context, RoutePaths.paidAdItemList),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'مافيش إعلانات مدفوعة لسه 👀',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: PsColors.textColor2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'روّج منتجك وخليه يطلع للناس أسرع.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: PsColors.textColor3),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: PSButtonWidgetWithIconRoundCorner(
                      hasShadow: false,
                      icon: Icons.campaign_rounded,
                      iconColor: PsColors.textColor4,
                      colorData: PsColors.activeColor,
                      titleText: 'روّج منتجك',
                      onPressed: onPromote,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: ads.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (ctx, i) {
            final dynamic item = ads[i];
            return PaidAdItemHorizontalListItem(
              paidAdItem: item,
              onTap: () => Navigator.pushNamed(
                ctx,
                RoutePaths.productDetail,
                arguments: ProductDetailIntentHolder(
                  productId: item.item!.id,
                  heroTagImage: 'paid_${item.item!.id}_${PsConst.HERO_TAG__IMAGE}',
                  heroTagTitle: 'paid_${item.item!.id}_${PsConst.HERO_TAG__TITLE}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ProfileDetailWidget
// ─────────────────────────────────────────────────────────────
class ProfileDetailWidget extends StatefulWidget {
  const ProfileDetailWidget({
    Key? key,
    this.animationController,
    this.animation,
    required this.status,
    required this.headerTitle,
    required this.userId,
    required this.callLogoutCallBack,
  }) : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;
  final String? userId;
  final Function callLogoutCallBack;
  final String headerTitle;
  final String status;

  @override
  __ProfileDetailWidgetState createState() => __ProfileDetailWidgetState();
}

class __ProfileDetailWidgetState extends State<ProfileDetailWidget> {
  String? _lastUid;

  void _ensureLoaded(UserProvider p) {
    final String? loginId = p.psValueHolder?.loginUserId;
    final String? target =
    (loginId == null || loginId.isEmpty) ? widget.userId : loginId;
    if (target == null || target.isEmpty) return;
    if (_lastUid == target && p.userParameterHolder.id == target) return;
    _lastUid = target;
    p.userParameterHolder.id = target;
    p.getUser(target);
  }


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider p = context.watch<UserProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensureLoaded(p);
    });

    if (p.user.data == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: widget.animationController!,
        child: Container(
          color: Colors.transparent,
          child: TaapdeelInfoCardShell(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            withBlur: true,
            child: Column(
              children: [
                _ProfileIdentityInline(
                  userProvider: p,
                  onEdit: () async {
                    final result =
                    await Navigator.pushNamed(context, RoutePaths.editProfile);
                    if (result == true) {
                      final String? lid = p.psValueHolder?.loginUserId;
                      if (lid != null && lid.isNotEmpty) p.getUser(lid);
                    }
                  },
                  callLogoutCallBack: widget.callLogoutCallBack,
                ),
                _ImageAndTextWidget(
                  userProvider: p,
                  callLogoutCallBack: widget.callLogoutCallBack,
                  status: widget.status,
                  headerTitle: widget.headerTitle,
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ),
        builder: (context, child) => FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0,
              100 * (1 - widget.animation!.value),
              0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _ProfileIdentityInline
// ─────────────────────────────────────────────────────────────
class _ProfileIdentityInline extends StatelessWidget {
  const _ProfileIdentityInline({
    required this.userProvider,
    required this.onEdit,
    required this.callLogoutCallBack,
  });

  final UserProvider userProvider;
  final VoidCallback onEdit;
  final Function callLogoutCallBack;


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = userProvider.user.data;
    if (u == null) return const SizedBox.shrink();
    final bool hasRating = (u.ratingDetail?.totalRatingValue != null) &&
        (double.tryParse(u.ratingDetail!.totalRatingValue!) ?? 0) > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            PsNetworkCircleImageForUser(
              photoKey: '',
              imagePath: u.userProfilePhoto,
              gender: u.userGender,
              ageRange: u.userAge,
              width: 56,
              height: 56,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PsColors.activeColor,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      u.userName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final dynamic ret = await Navigator.pushNamed(
                        context,
                        RoutePaths.more,
                        arguments: userProvider.user.data!.userName,
                      );
                      if (ret == true) {
                        callLogoutCallBack(userProvider.psValueHolder!.loginUserId);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        children: [
                          Text(
                            Utils.getString(context, 'profile__more'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: PsColors.activeColor
                                  ?.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: PsColors.activeColor?.withValues(alpha: 0.85),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if ((u.userAboutMe ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  u.userAboutMe!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (hasRating) ...[
                    _RatingWidget(data: u),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _JoinDateWidget(userProvider: userProvider),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _ImageAndTextWidget — network stats + pending requests banner
// ─────────────────────────────────────────────────────────────
class _ImageAndTextWidget extends StatelessWidget {
  const _ImageAndTextWidget({
    required this.userProvider,
    required this.callLogoutCallBack,
    required this.status,
    required this.headerTitle,
  });

  final UserProvider userProvider;
  final Function callLogoutCallBack;
  final String status;
  final String headerTitle;

  String get _restBase {
    final String b = PsConfig.ps_app_url.trim();
    final String n = b.endsWith('/') ? b.substring(0, b.length - 1) : b;
    return n.endsWith('/rest') ? n : '$n/rest';
  }

  Future<void> _openFollowRequests(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (_) => FollowRequestsScreen(baseUrl: _restBase),
      ),
    );
    if (!context.mounted) return;
    final String uid =
    (Provider.of<PsValueHolder>(context, listen: false).loginUserId ?? '')
        .trim();
    if (uid.isNotEmpty && uid != 'nologinuser') {
      await context.read<FollowRequestBadgeProvider>().loadPendingCount(uid);
    }
  }


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<PsValueHolder>(context);
    Provider.of<AddedItemProvider>(context, listen: false);

    final String profileUserId = (userProvider.user.data?.userId ??
        userProvider.psValueHolder?.loginUserId ??
        '')
        .trim();

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PsDimens.space4),
            child: _NetworkSummarySection(
              userId: profileUserId,
              restBase: _restBase,
            ),
          ),
          Consumer<FollowRequestBadgeProvider>(
            builder: (context, badge, _) {
              if (!badge.hasPending) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                child: _PendingBanner(
                  count: badge.pendingCount,
                  onTap: () => _openFollowRequests(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NetworkCounts {
  const _NetworkCounts({
    required this.family,
    required this.relatives,
    required this.friends,
  });

  final int family;
  final int relatives;
  final int friends;

  static const _NetworkCounts zero = _NetworkCounts(
    family: 0,
    relatives: 0,
    friends: 0,
  );
}

class _NetworkPerson {
  const _NetworkPerson({
    required this.userId,
    required this.name,
    required this.photo,
    required this.about,
    required this.gender,
    required this.age,
    required this.relationType,
  });

  final String userId;
  final String name;
  final String photo;
  final String about;
  final String gender;
  final String age;
  final int relationType;

  String get relationLabel {
    switch (relationType) {
      case 1:
        return 'صديق/زميل';
      case 2:
        return 'زوج/زوجة';
      case 3:
        return 'ابن/ابنة';
      case 4:
        return 'أم/أب';
      case 5:
        return 'أخ/أخت';
      case 6:
        return 'من العائلة';
      default:
        return 'علاقة';
    }
  }

  IconData get relationIcon {
    switch (relationType) {
      case 1:
        return Icons.handshake_rounded;
      case 2:
        return Icons.favorite_rounded;
      case 3:
        return Icons.child_care_rounded;
      case 4:
        return Icons.account_circle_rounded;
      case 5:
        return Icons.people_alt_rounded;
      case 6:
        return Icons.family_restroom_rounded;
      default:
        return Icons.groups_rounded;
    }
  }

  factory _NetworkPerson.fromMap(Map<String, dynamic> map) {
    String read(String key) => (map[key] ?? '').toString();

    int readInt(String key) {
      final dynamic value = map[key];
      if (value is int) return value;
      return int.tryParse((value ?? '').toString()) ?? 0;
    }

    return _NetworkPerson(
      userId: read('user_id'),
      name: read('user_name').trim().isEmpty ? 'مستخدم تبديل' : read('user_name'),
      photo: read('user_profile_photo'),
      about: read('user_about_me'),
      gender: read('user_gender'),
      age: read('user_age'),
      relationType: readInt('relation_type'),
    );
  }
}

class _NetworkSummarySection extends StatefulWidget {
  const _NetworkSummarySection({
    required this.userId,
    required this.restBase,
  });

  final String userId;
  final String restBase;

  @override
  State<_NetworkSummarySection> createState() => _NetworkSummarySectionState();
}

class _NetworkSummarySectionState extends State<_NetworkSummarySection> {
  late Future<_NetworkCounts> _future;
  String _loadedForUserId = '';

  String get _apiKey => 'teampsisthebest1';

  @override
  void initState() {
    super.initState();
    _loadedForUserId = widget.userId;
    _future = _fetchCounts(widget.userId);
  }

  @override
  void didUpdateWidget(covariant _NetworkSummarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId || _loadedForUserId != widget.userId) {
      _loadedForUserId = widget.userId;
      _future = _fetchCounts(widget.userId);
    }
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  dynamic _unwrapApi(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded['data'] != null) {
      return decoded['data'];
    }
    return decoded;
  }

  Future<_NetworkCounts> _fetchCounts(String userId) async {
    if (userId.trim().isEmpty) return _NetworkCounts.zero;

    try {
      final http.Response response = await http.post(
        Uri.parse('${widget.restBase}/userfollows/relation_summary/api_key/$_apiKey'),
        body: <String, String>{'user_id': userId},
      );

      if (response.statusCode != 200 || response.body.trim().isEmpty) {
        return _NetworkCounts.zero;
      }

      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = _unwrapApi(decoded);

      if (data is Map<String, dynamic>) {
        return _NetworkCounts(
          family: _toInt(data['family_count']),
          relatives: _toInt(data['relatives_count']),
          friends: _toInt(data['friends_count']),
        );
      }
    } catch (e) {
      debugPrint('Network counts error: $e');
    }

    return _NetworkCounts.zero;
  }

  Future<List<_NetworkPerson>> _fetchPeople(String group) async {
    if (widget.userId.trim().isEmpty) return <_NetworkPerson>[];

    try {
      final Uri uri = Uri.parse(
        '${widget.restBase}/userfollows/relation_list/api_key/$_apiKey',
      );

      final http.Response response = await http.post(
        uri,
        body: <String, String>{
          'user_id': widget.userId,
          'relation_group': group,
        },
      );

      debugPrint('NETWORK_RELATION_LIST_URL=$uri');
      debugPrint('NETWORK_RELATION_LIST_GROUP=$group USER=${widget.userId}');
      debugPrint('NETWORK_RELATION_LIST_STATUS=${response.statusCode}');
      debugPrint('NETWORK_RELATION_LIST_BODY=${response.body}');

      if (response.statusCode != 200 || response.body.trim().isEmpty) {
        return <_NetworkPerson>[];
      }

      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = _unwrapApi(decoded);

      List<dynamic> rawList = <dynamic>[];

      if (data is List) {
        rawList = data;
      } else if (data is Map<String, dynamic>) {
        final dynamic nestedData = data['data'];
        final dynamic items = data['items'];
        final dynamic results = data['results'];
        final dynamic users = data['users'];

        if (nestedData is List) {
          rawList = nestedData;
        } else if (items is List) {
          rawList = items;
        } else if (results is List) {
          rawList = results;
        } else if (users is List) {
          rawList = users;
        }
      }

      final Map<String, _NetworkPerson> unique = <String, _NetworkPerson>{};

      for (final Map raw in rawList.whereType<Map>()) {
        final _NetworkPerson person =
        _NetworkPerson.fromMap(Map<String, dynamic>.from(raw));

        final String id = person.userId.trim();

        if (id.isEmpty || id == widget.userId) {
          continue;
        }

        unique.putIfAbsent(id, () => person);
      }

      return unique.values.toList();
    } catch (e) {
      debugPrint('Network people error: $e');
      return <_NetworkPerson>[];
    }
  }

  Future<void> _openPersonProfile(_NetworkPerson person) async {
    final String targetUserId = person.userId.trim();

    if (targetUserId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('لا يمكن فتح هذا البروفايل حاليًا.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (_) => UserDetailView(
          userId: targetUserId,
          userName: person.name,
        ),
      ),
    );
  }

  Future<void> _openPeopleSheet({
    required String title,
    required String group,
    required Color accent,
  }) async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.42,
          maxChildSize: 0.92,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.groups_rounded, color: accent),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _B.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: FutureBuilder<List<_NetworkPerson>>(
                      future: _fetchPeople(group),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<_NetworkPerson>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final List<_NetworkPerson> people = snapshot.data ?? [];
                        if (people.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'لا يوجد أشخاص في هذا القسم حاليًا',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                          itemCount: people.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.86,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final _NetworkPerson person = people[index];
                            return _NetworkPersonTile(
                              person: person,
                              accent: accent,
                              onTap: () async {
                                Navigator.of(sheetContext).pop();

                                await Future<void>.delayed(
                                  const Duration(milliseconds: 180),
                                );

                                if (!mounted) return;
                                await _openPersonProfile(person);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_NetworkCounts>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<_NetworkCounts> snapshot) {
        final bool loading = snapshot.connectionState == ConnectionState.waiting;
        final _NetworkCounts counts = snapshot.data ?? _NetworkCounts.zero;

        final dynamic activeProductsData =
            context.watch<AddedItemProvider>().itemList.data;
        final int productsCount =
        activeProductsData is List ? activeProductsData.length : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: PremiumMiniStatCard(
                    icon: Icons.family_restroom_rounded,
                    label: 'العائلة',
                    value: loading ? '...' : counts.family.toString(),
                    accent: const Color(0xFF0EA5E9),
                    onTap: () => _openPeopleSheet(
                      title: 'العائلة المضافة',
                      group: 'family',
                      accent: const Color(0xFF0EA5E9),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: PremiumMiniStatCard(
                    icon: Icons.diversity_3_rounded,
                    label: 'الأقارب',
                    value: loading ? '...' : counts.relatives.toString(),
                    accent: const Color(0xFF8B5CF6),
                    onTap: () => _openPeopleSheet(
                      title: 'الأقارب',
                      group: 'relatives',
                      accent: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: PremiumMiniStatCard(
                    icon: Icons.handshake_rounded,
                    label: 'الأصدقاء',
                    value: loading ? '...' : counts.friends.toString(),
                    accent: const Color(0xFF10B981),
                    onTap: () => _openPeopleSheet(
                      title: 'الأصدقاء',
                      group: 'friends',
                      accent: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PremiumRewardChallengeCard(
              productsCount: productsCount,
              familyCount: counts.family,
              relativesCount: counts.relatives,
              friendsCount: counts.friends,
              loading: loading,
              onAddProduct: () => _showAddProductHint(context),
              onAddNetwork: () => _openAddNetworkSheet(context),
            ),
          ],
        );
      },
    );
  }
}


class _RewardRequirement {
  const _RewardRequirement({
    required this.label,
    required this.current,
    required this.target,
    required this.icon,
    required this.accent,
  });

  final String label;
  final int current;
  final int target;
  final IconData icon;
  final Color accent;

  int get remaining => (target - current).clamp(0, target).toInt();
  bool get done => current >= target;
  double get progress => target <= 0 ? 1.0 : (current / target).clamp(0.0, 1.0);
  String get text => '${current.clamp(0, target)}/$target';
}

class _RewardChallengeViewModel {
  const _RewardChallengeViewModel({
    required this.code,
    required this.title,
    required this.rewardText,
    required this.badgeText,
    required this.accent,
    required this.icon,
    required this.requirements,
    required this.completed,
  });

  final String code;
  final String title;
  final String rewardText;
  final String badgeText;
  final Color accent;
  final IconData icon;
  final List<_RewardRequirement> requirements;
  final bool completed;

  int get doneCount => requirements.where((r) => r.done).length;
  int get totalCount => requirements.length;
  double get progress {
    if (requirements.isEmpty) return completed ? 1.0 : 0.0;
    final double total = requirements.fold<double>(0, (sum, r) => sum + r.progress);
    return (total / requirements.length).clamp(0.0, 1.0);
  }

  String get nextActionText {
    if (completed) return 'تفعيل المكافأة';

    final List<_RewardRequirement> missing = requirements
        .where((r) => !r.done)
        .toList()
      ..sort((a, b) => a.remaining.compareTo(b.remaining));

    if (missing.isEmpty) return 'أكمل الآن';
    final _RewardRequirement first = missing.first;
    return first.label == 'منتجات' ? 'أضف منتج' : 'أضف علاقاتك';
  }

  String get motivationalText {
    if (completed) return 'مبروك! التحدي اكتمل ويمكنك تفعيل المكافأة الآن 🎉';

    final List<String> parts = <String>[];
    for (final _RewardRequirement r in requirements) {
      if (!r.done) parts.add('${r.remaining} ${r.label}');
    }
    if (parts.isEmpty) return 'اقتربت جدًا من فتح Premium مجانًا.';
    return 'باقي لك ${parts.take(2).join(' + ')} لفتح المكافأة.';
  }
}

class _PremiumRewardChallengeCard extends StatefulWidget {
  const _PremiumRewardChallengeCard({
    required this.productsCount,
    required this.familyCount,
    required this.relativesCount,
    required this.friendsCount,
    required this.loading,
    required this.onAddProduct,
    required this.onAddNetwork,
  });

  final int productsCount;
  final int familyCount;
  final int relativesCount;
  final int friendsCount;
  final bool loading;
  final VoidCallback onAddProduct;
  final VoidCallback onAddNetwork;

  @override
  State<_PremiumRewardChallengeCard> createState() =>
      _PremiumRewardChallengeCardState();
}

class _PremiumRewardChallengeCardState extends State<_PremiumRewardChallengeCard> {
  bool _expanded = false;

  static const Color _deep = Color(0xFF062F4F);
  static const Color _petrol = Color(0xFF0C587A);
  static const Color _cyan = Color(0xFF24A9C4);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _success = Color(0xFF16A34A);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _line = Color(0xFFE2E8F0);

  _RewardChallengeViewModel _buildVm() {
    final int networkTotal =
        widget.familyCount + widget.relativesCount + widget.friendsCount;
    final int familyRelatives = widget.familyCount + widget.relativesCount;

    final bool starterDone = widget.productsCount >= 3 &&
        widget.familyCount >= 3 &&
        widget.friendsCount >= 3 &&
        widget.relativesCount >= 3;

    final bool growthDone = widget.productsCount >= 5 &&
        widget.familyCount >= 5 &&
        widget.friendsCount >= 5 &&
        widget.relativesCount >= 5;

    final bool leaderDone = widget.productsCount >= 10 &&
        networkTotal >= 30 &&
        widget.friendsCount >= 5 &&
        familyRelatives >= 5;

    if (!starterDone) {
      return _RewardChallengeViewModel(
        code: 'starter_3m',
        title: 'تحدي البداية',
        rewardText: 'افتح 3 شهور Premium مجانًا',
        badgeText: '3 شهور',
        accent: _petrol,
        icon: Icons.card_giftcard_rounded,
        completed: false,
        requirements: <_RewardRequirement>[
          _RewardRequirement(
            label: 'منتجات',
            current: widget.productsCount,
            target: 3,
            icon: Icons.inventory_2_rounded,
            accent: _petrol,
          ),
          _RewardRequirement(
            label: 'العائلة',
            current: widget.familyCount,
            target: 3,
            icon: Icons.family_restroom_rounded,
            accent: _petrol,
          ),
          _RewardRequirement(
            label: 'الأصدقاء',
            current: widget.friendsCount,
            target: 3,
            icon: Icons.handshake_rounded,
            accent: _petrol,
          ),
          _RewardRequirement(
            label: 'الأقارب',
            current: widget.relativesCount,
            target: 3,
            icon: Icons.diversity_3_rounded,
            accent: _petrol,
          ),
        ],
      );
    }

    if (!growthDone) {
      return _RewardChallengeViewModel(
        code: 'growth_6m',
        title: 'تحدي التقدم',
        rewardText: 'افتح 6 شهور Premium مجانًا',
        badgeText: '6 شهور',
        accent: _gold,
        icon: Icons.workspace_premium_rounded,
        completed: false,
        requirements: <_RewardRequirement>[
          _RewardRequirement(
            label: 'منتجات',
            current: widget.productsCount,
            target: 6,
            icon: Icons.inventory_2_rounded,
            accent: _gold,
          ),
          _RewardRequirement(
            label: 'العائلة',
            current: widget.familyCount,
            target: 4,
            icon: Icons.family_restroom_rounded,
            accent: _gold,
          ),
          _RewardRequirement(
            label: 'الأصدقاء',
            current: widget.friendsCount,
            target: 6,
            icon: Icons.handshake_rounded,
            accent: _gold,
          ),
          _RewardRequirement(
            label: 'الأقارب',
            current: widget.relativesCount,
            target: 6,
            icon: Icons.diversity_3_rounded,
            accent: _gold,
          ),
        ],
      );
    }

    if (!leaderDone) {
      return _RewardChallengeViewModel(
        code: 'leader_12m',
        title: 'تحدي القادة',
        rewardText: 'افتح سنة Premium مجانًا',
        badgeText: 'سنة كاملة',
        accent: const Color(0xFF7C3AED),
        icon: Icons.emoji_events_rounded,
        completed: false,
        requirements: <_RewardRequirement>[
          _RewardRequirement(
            label: 'منتجات',
            current: widget.productsCount,
            target: 10,
            icon: Icons.inventory_2_rounded,
            accent: const Color(0xFF7C3AED),
          ),
          _RewardRequirement(
            label: 'علاقات',
            current: networkTotal,
            target: 30,
            icon: Icons.hub_rounded,
            accent: const Color(0xFF7C3AED),
          ),
          _RewardRequirement(
            label: 'الأصدقاء',
            current: widget.friendsCount,
            target: 5,
            icon: Icons.handshake_rounded,
            accent: const Color(0xFF7C3AED),
          ),
          _RewardRequirement(
            label: 'عائلة/أقارب',
            current: familyRelatives,
            target: 5,
            icon: Icons.diversity_3_rounded,
            accent: const Color(0xFF7C3AED),
          ),
        ],
      );
    }

    return _RewardChallengeViewModel(
      code: 'all_completed',
      title: 'قائد شبكة تبديل',
      rewardText: 'كل التحديات مكتملة — تستحق سنة Premium 🎉',
      badgeText: 'Leader',
      accent: _success,
      icon: Icons.verified_rounded,
      completed: true,
      requirements: <_RewardRequirement>[
        _RewardRequirement(
          label: 'منتجات',
          current: widget.productsCount,
          target: 10,
          icon: Icons.inventory_2_rounded,
          accent: _success,
        ),
        _RewardRequirement(
          label: 'علاقات',
          current: networkTotal,
          target: 30,
          icon: Icons.hub_rounded,
          accent: _success,
        ),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  void _handleTap(BuildContext context, _RewardChallengeViewModel vm) {
    if (widget.loading) return;

    if (vm.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('تم فتح ${vm.rewardText}. اربطها لاحقًا بـ API التفعيل.'),
        ),
      );
      return;
    }

    final bool productMissing = vm.requirements.any(
          (_RewardRequirement r) => r.label == 'منتجات' && !r.done,
    );

    if (productMissing) {
      widget.onAddProduct();
    } else {
      widget.onAddNetwork();
    }
  }

  Color _softAccent(Color accent) {
    if (accent == _gold) return const Color(0xFFF59E0B);
    return accent;
  }

  @override
  Widget build(BuildContext context) {
    final _RewardChallengeViewModel vm = _buildVm();
    final Color accent = _softAccent(vm.accent);
    final bool completed = vm.completed;

    return Container(
      padding: const EdgeInsets.all(1.1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[
            _cyan.withOpacity(0.22),
            accent.withOpacity(0.18),
            Colors.white.withOpacity(0.80),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _deep.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: Colors.white.withOpacity(0.85)),
        ),
        child: Stack(
          children: <Widget>[
            PositionedDirectional(
              top: -34,
              end: -42,
              child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.055),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _RewardCollapsedHeader(
                  vm: vm,
                  accent: accent,
                  completed: completed,
                  expanded: _expanded,
                  onTap: _toggleExpanded,
                ),
                const SizedBox(height: 10),
                _RewardOverallProgress(
                  value01: vm.progress,
                  accent: accent,
                  text: '${vm.doneCount}/${vm.totalCount}',
                ),
                AnimatedCrossFade(
                  firstChild: _RewardCollapsedFooter(
                    vm: vm,
                    accent: accent,
                    loading: widget.loading,
                    onTap: _toggleExpanded,
                  ),
                  secondChild: _RewardExpandedDetails(
                    vm: vm,
                    accent: accent,
                    loading: widget.loading,
                    completed: completed,
                    onActionTap: () => _handleTap(context, vm),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 240),
                  reverseDuration: const Duration(milliseconds: 180),
                  firstCurve: Curves.easeOutCubic,
                  secondCurve: Curves.easeOutCubic,
                  sizeCurve: Curves.easeOutCubic,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCollapsedHeader extends StatelessWidget {
  const _RewardCollapsedHeader({
    required this.vm,
    required this.accent,
    required this.completed,
    required this.expanded,
    required this.onTap,
  });

  final _RewardChallengeViewModel vm;
  final Color accent;
  final bool completed;
  final bool expanded;
  final VoidCallback onTap;

  static const Color _deep = Color(0xFF062F4F);
  static const Color _petrol = Color(0xFF0C587A);
  static const Color _success = Color(0xFF16A34A);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _line = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: completed
                            ? <Color>[_success, const Color(0xFF34D399)]
                            : <Color>[_deep, _petrol],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: (completed ? _success : _petrol).withOpacity(0.20),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Icon(vm.icon, color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          vm.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          vm.rewardText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 11.3,
                            fontWeight: FontWeight.w800,
                            height: 1.22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black.withOpacity(0.42),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: completed
                        ? _success.withOpacity(0.10)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: completed ? _success.withOpacity(0.24) : _line,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        completed
                            ? Icons.check_circle_rounded
                            : Icons.workspace_premium_rounded,
                        size: 12,
                        color: completed ? _success : accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vm.badgeText,
                        style: TextStyle(
                          color: completed ? _success : accent,
                          fontSize: 10.3,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardCollapsedFooter extends StatelessWidget {
  const _RewardCollapsedFooter({
    required this.vm,
    required this.accent,
    required this.loading,
    required this.onTap,
  });

  final _RewardChallengeViewModel vm;
  final Color accent;
  final bool loading;
  final VoidCallback onTap;

  static const Color _muted = Color(0xFF64748B);
  static const Color _line = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),

    );
  }
}

class _RewardExpandedDetails extends StatelessWidget {
  const _RewardExpandedDetails({
    required this.vm,
    required this.accent,
    required this.loading,
    required this.completed,
    required this.onActionTap,
  });

  final _RewardChallengeViewModel vm;
  final Color accent;
  final bool loading;
  final bool completed;
  final VoidCallback onActionTap;

  static const Color _petrol = Color(0xFF0C587A);
  static const Color _cyan = Color(0xFF24A9C4);
  static const Color _success = Color(0xFF16A34A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _line = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: vm.requirements
                .map((_RewardRequirement r) =>
                _RewardRequirementChip(requirement: r))
                .toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _line),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    vm.motivationalText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11.2,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: loading ? null : onActionTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: loading
                          ? null
                          : LinearGradient(
                        colors: completed
                            ? <Color>[_success, const Color(0xFF22C55E)]
                            : <Color>[_petrol, _cyan],
                      ),
                      color: loading ? Colors.black.withOpacity(0.07) : null,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: loading
                          ? null
                          : <BoxShadow>[
                        BoxShadow(
                          color: (completed ? _success : _petrol)
                              .withOpacity(0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      loading ? '...' : vm.nextActionText,
                      style: TextStyle(
                        color: loading ? Colors.black.withOpacity(0.35) : Colors.white,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
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


class _RewardOverallProgress extends StatelessWidget {
  const _RewardOverallProgress({
    required this.value01,
    required this.accent,
    required this.text,
  });

  final double value01;
  final Color accent;
  final String text;

  static const Color _track = Color(0xFFEAF0F6);
  static const Color _success = Color(0xFF16A34A);
  static const Color _petrol = Color(0xFF0C587A);
  static const Color _cyan = Color(0xFF24A9C4);

  @override
  Widget build(BuildContext context) {
    final bool done = value01 >= 1;
    final double percent = (value01.clamp(0.0, 1.0) * 100).roundToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'تقدم التحدي',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.48),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  '$text مكتمل · ${percent.toStringAsFixed(0)}%',
                  maxLines: 1,
                  style: TextStyle(
                    color: done ? _success : _petrol,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: _track,
            borderRadius: BorderRadius.circular(999),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value01.clamp(0.04, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: done
                          ? <Color>[_success, const Color(0xFF34D399)]
                          : <Color>[_petrol, _cyan],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardRequirementChip extends StatelessWidget {
  const _RewardRequirementChip({required this.requirement});

  final _RewardRequirement requirement;

  static const Color _success = Color(0xFF16A34A);
  static const Color _petrol = Color(0xFF0C587A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _line = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final bool done = requirement.done;
    final Color color = done ? _success : _petrol;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: done ? _success.withOpacity(0.09) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: done ? _success.withOpacity(0.22) : _line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            done ? Icons.check_circle_rounded : requirement.icon,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${requirement.label} ${requirement.text}',
            style: TextStyle(
              color: done ? _success : _muted,
              fontSize: 10.3,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkPersonTile extends StatelessWidget {
  const _NetworkPersonTile({
    required this.person,
    required this.accent,
    required this.onTap,
  });

  final _NetworkPerson person;
  final Color accent;
  final VoidCallback onTap;


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageKey =
        '${person.userId}_${person.photo}_${person.gender}_${person.age}';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withOpacity(0.16), width: 1.1),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accent.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: <Color>[
                          accent.withOpacity(0.18),
                          Colors.white,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      border: Border.all(
                        color: accent.withOpacity(0.45),
                        width: 2,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: accent.withOpacity(0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: PsNetworkCircleImageForUser(
                        photoKey: imageKey,
                        imagePath: person.photo.trim(),
                        gender: person.gender,
                        ageRange: person.age,
                        width: 62,
                        height: 62,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: -4,
                    start: -4,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        person.relationIcon,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                person.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: _B.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                constraints: const BoxConstraints(maxWidth: 125),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withOpacity(0.22)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      person.relationIcon,
                      size: 12,
                      color: accent,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        person.relationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: accent,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (person.about.trim().isNotEmpty) ...[
                const SizedBox(height: 7),
                Text(
                  person.about,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.8,
                    fontWeight: FontWeight.w600,
                    color: _B.textSecond,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    size: 12,
                    color: accent.withOpacity(0.85),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'اضغط لعرض المنتجات',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: accent.withOpacity(0.85),
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ _PendingBanner — Professional Design
// ─────────────────────────────────────────────────────────────
class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _B.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _B.primaryLt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.group_add_rounded,
                      size: 20,
                      color: _B.primary,
                    ),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _B.danger,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
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
                      count == 1
                          ? 'لديك طلب علاقة في انتظارك'
                          : 'لديك $count طلبات في انتظارك',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _B.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'اضغط لمراجعة الطلبات وقبول أو رفض',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: _B.textSecond,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _B.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'مراجعة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 9,
                      color: Colors.white,
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

// ─────────────────────────────────────────────────────────────
// PremiumMiniStatCard
// ─────────────────────────────────────────────────────────────
class PremiumMiniStatCard extends StatelessWidget {
  const PremiumMiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(16),
                  bottomStart: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(9, 7, 9, 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(icon, size: 14, color: accent),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black.withValues(alpha: 0.90),
                            fontWeight: FontWeight.w900,
                            height: 1,
                            fontSize: 21,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.black.withValues(alpha: 0.66),
                      fontWeight: FontWeight.w900,
                      height: 1,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            PositionedDirectional(
              end: 3,
              top: 3,
              child: Icon(
                Icons.chevron_left_rounded,
                size: 14,
                color: Colors.black.withValues(alpha: 0.20),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────
class PendingFollowRequestBanner extends StatelessWidget {
  const PendingFollowRequestBanner({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      _PendingBanner(count: count, onTap: onTap);
}

class _RatingWidget extends StatelessWidget {
  const _RatingWidget({Key? key, required this.data}) : super(key: key);
  final User? data;


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? raw = data?.ratingDetail?.totalRatingValue;
    if (raw == null || raw.trim().isEmpty) return const SizedBox.shrink();
    final double rating = double.tryParse(raw) ?? 0;
    if (rating <= 0) return const SizedBox.shrink();
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            RoutePaths.ratingList,
            arguments: data!.userId,
          ),
          child: SmoothStarRating(
            key: Key(data!.ratingDetail!.totalRatingValue!),
            rating: double.parse(data!.ratingDetail!.totalRatingValue!),
            allowHalfRating: false,
            starCount: 5,
            isReadOnly: true,
            size: PsDimens.space16,
            color: PsColors.activeColor,
            borderColor: PsColors.activeColor,
            onRated: (double? v) {},
            spacing: 0,
          ),
        ),
        const SizedBox(width: PsDimens.space8),
        if (data!.overallRating != '0')
          Text(
            data!.overallRating!,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: PsColors.textColor2),
          ),
      ],
    );
  }
}

class _JoinDateWidget extends StatelessWidget {
  const _JoinDateWidget({this.userProvider});
  final UserProvider? userProvider;


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: PsDimens.space8),
      child: Row(
        children: [
          Text(
            Utils.getString(context, 'profile__join_on'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: PsDimens.space6),
          Text(
            userProvider!.user.data!.addedDateTimeStamp != null &&
                userProvider!.user.data!.addedDateTimeStamp != ''
                ? Utils.getDateFormat(
              userProvider!.user.data!.addedDate,
              userProvider!.psValueHolder!.dateFormat!,
            )
                : Utils.changeTimeStampToStandardDateTimeFormat(
              userProvider!.user.data!.addedDateTimeStamp,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({
    Key? key,
    required this.headerName,
    required this.viewAllClicked,
  }) : super(key: key);
  final String headerName;
  final Function viewAllClicked;


  void _showAddProductHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('اضغط زر إضافة في أعلى الشاشة لإضافة منتج جديد.'),
      ),
    );
  }

  Future<void> _openAddNetworkSheet(BuildContext context) async {
    try {
      await ContactNetworkBottomSheet.show(context);
    } catch (e) {
      debugPrint('Open contact network sheet error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('افتح إضافة الأصدقاء/الأقارب من زر الشبكة أعلى الصفحة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: viewAllClicked as void Function()?,
      child: Padding(
        padding: const EdgeInsets.only(
          top: PsDimens.space8,
          left: PsDimens.space6,
          right: PsDimens.space6,
          bottom: PsDimens.space8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(headerName, style: Theme.of(context).textTheme.titleMedium),
            Text(
              Utils.getString(context, 'profile__view_all'),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: PsColors.textColor3),
            ),
          ],
        ),
      ),
    );
  }
}
