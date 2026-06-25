import 'dart:async';
import 'dart:convert';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/product/product_provider.dart';
import 'package:taapdeel/ui/common/smooth_star_rating_widget.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/user_intent_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../api/common/ps_resource.dart';
import '../../../../api/common/ps_status.dart';
import '../../../../api/ps_api_service.dart';
import '../../../../api/ps_url.dart';
import '../../../../config/ps_config.dart';
import '../../../../repository/product_repository.dart';
import '../../../../utils/utils.dart';
import '../../../../viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import '../../../../viewobject/owner_relation.dart';
import '../../../common/ps_ui_widget.dart';
import '../../../sweet_phrase/sweet_message_provider.dart';
import '../../../sweet_phrase/sweet_message_repository.dart';
import '../../../sweet_phrase/sweet_phrase.dart';
import '../../../wish_Items/Wishlist_model.dart';

// ✅ provider + model for owner subscribed subcats
import '../../../../provider/subcategory/owner_subcat_subscribe_provider.dart';
import '../../../../viewobject/owner_subcat_subscribe.dart';

class SellerInfoTileView extends StatelessWidget {
  const SellerInfoTileView({
    Key? key,
    required this.itemDetail,
  }) : super(key: key);

  final ItemDetailProvider itemDetail;

  @override
  Widget build(BuildContext context) {
    final Product? data = itemDetail.itemDetail.data;
    if (data == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PsDimens.space12,
        vertical: PsDimens.space8,
      ),
      child: ChangeNotifierProvider<SweetMessageProvider>(
        create: (_) => SweetMessageProvider(
          repository: SweetMessageRepository(
            baseUrl: PsConfig.ps_app_url,
            headers: <String, String>{
              'Accept': 'application/json',
            },
          ),
        ),
        child: _SellerCardShell(
          child: ImageAndTextWidget(
            data: data,
            itemDetail: itemDetail,
          ),
        ),
      ),
    );
  }
}

/// ======================================================
/// ✅ Glass helpers
/// ======================================================
class _GlassContainer extends StatelessWidget {
  const _GlassContainer({
    Key? key,
    required this.child,
    this.radius = 16,
    this.padding,
    this.onTap,
  }) : super(key: key);

  final Widget child;
  final double radius;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = Colors.blue.withAlpha((0.35 * 255).round());
    final Color glow = Colors.white.withAlpha((0.10 * 255).round());
    final Color tintA = Colors.white.withAlpha((0.10 * 255).round());
    final Color tintB = Colors.white.withAlpha((0.10 * 255).round());

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: border),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[tintA, tintB],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: glow,
                    blurRadius: 22,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _SellerCardShell extends StatelessWidget {
  const _SellerCardShell({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      radius: 18,
      padding: const EdgeInsets.all(PsDimens.space16),
      child: child,
    );
  }
}

class ImageAndTextWidget extends StatefulWidget {
  const ImageAndTextWidget({
    Key? key,
    required this.data,
    required this.itemDetail,
  }) : super(key: key);

  final Product? data;
  final ItemDetailProvider itemDetail;

  @override
  State<ImageAndTextWidget> createState() => _ImageAndTextWidgetState();
}

class _ImageAndTextWidgetState extends State<ImageAndTextWidget> {
  Future<PsResource<OwnerRelation>>? _future;
  Future<List<WishlistProductModel>>? _wishFuture;
  Future<int>? _familyCountFuture;

  String _loadedOwnerId = '';

  final Map<String, Future<String>> _wishImgFutureCache =
  <String, Future<String>>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final PsValueHolder holder =
    Provider.of<PsValueHolder>(context, listen: false);
    final String viewerId = (holder.loginUserId ?? '').trim();
    final String ownerId = (widget.data?.addedUserId ?? '').trim();

    if (viewerId.isEmpty || ownerId.isEmpty || viewerId == ownerId) {
      _future = null;
    } else {
      _future ??= PsApiService().getOwnerRelation(
        viewerId: viewerId,
        ownerId: ownerId,
      );
    }

    if (ownerId.isEmpty) {
      _wishFuture = null;
      _familyCountFuture = null;
    } else {
      _wishFuture ??= _fetchOwnerWishlist(ownerId);
      _familyCountFuture ??= _fetchOwnerFamilyCount(ownerId);
    }

    if (ownerId.isNotEmpty && _loadedOwnerId != ownerId) {
      _loadedOwnerId = ownerId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final OwnerSubcatSubscribeProvider p =
        Provider.of<OwnerSubcatSubscribeProvider>(context, listen: false);
        p.loadOwnerSubcats(ownerUserId: ownerId);
      });
    }
  }

  Future<List<WishlistProductModel>> _fetchOwnerWishlist(String ownerId) async {
    final String apiUrl =
        '${PsConfig.ps_app_url}${PsUrl.ps_get_owner_wishlist_items_url}';
    final client = http.Client();
    try {
      final http.Response response = await client
          .post(
        Uri.parse(apiUrl),
        body: <String, String>{'added_user_id': ownerId},
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return <WishlistProductModel>[];
      }

      final dynamic decoded = json.decode(response.body);
      if (decoded is! List) return <WishlistProductModel>[];

      return decoded
          .whereType<dynamic>()
          .map((dynamic e) => WishlistProductModel.fromJson(e))
          .toList();
    } catch (_) {
      return <WishlistProductModel>[];
    } finally {
      client.close();
    }
  }

  Future<int> _fetchOwnerFamilyCount(String ownerId) async {
    final String id = ownerId.trim();
    if (id.isEmpty) return 0;

    final ProductRepository repo =
    Provider.of<ProductRepository>(context, listen: false);

    final StreamController<PsResource<List<Product>>> sc =
    StreamController<PsResource<List<Product>>>();

    try {
      final completer = Completer<int>();
      late final StreamSubscription sub;

      sub = sc.stream.listen((PsResource<List<Product>> res) {
        final int len = (res.data ?? <Product>[]).length;

        if (len > 0) {
          if (!completer.isCompleted) completer.complete(len);
        } else if (res.status == PsStatus.SUCCESS ||
            res.status == PsStatus.ERROR) {
          if (!completer.isCompleted) completer.complete(0);
        }
      }, onError: (_) {
        if (!completer.isCompleted) completer.complete(0);
      });

      await repo.getFamilyItemsByUserId(
        sc,
        true,
        null,
        id,
        100,
        0,
        PsStatus.PROGRESS_LOADING,
      );

      final int result = await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => 0,
      );

      await sub.cancel();
      await sc.close();

      return result;
    } catch (_) {
      try {
        await sc.close();
      } catch (_) {}
      return 0;
    }
  }

  String _extractRelationText(OwnerRelation rel) {
    try {
      final dynamic d = rel;
      final String v = (d.relationText ??
          d.relation_text ??
          d.relationTextLabel ??
          d.relation ??
          d.text ??
          '')
          .toString()
          .trim();
      return v;
    } catch (_) {
      return '';
    }
  }

  int _extractRelationType(OwnerRelation rel) {
    try {
      final int directType = rel.viewerToOwnerType ?? 0;
      if (directType >= 1 && directType <= 6) {
        return directType;
      }

      final String txt = _extractRelationText(rel).trim();

      if (txt.contains('صديق')) return 1;
      if (txt.contains('زوج') || txt.contains('زوجة')) return 2;
      if (txt.contains('ابنك') ||
          txt.contains('ابنتك') ||
          txt.contains('بنتك')) {
        return 3;
      }
      if (txt.contains('أبوك') ||
          txt.contains('أمك') ||
          txt.contains('والد') ||
          txt.contains('والدتك') ||
          txt.contains('والدك')) {
        return 4;
      }
      if (txt.contains('أخ') || txt.contains('أخت')) return 5;
      if (txt.contains('قريب')) return 6;

      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<String> _fetchWishImageUrlViaApi(String wishItemId) {
    final String id = wishItemId.trim();
    if (id.isEmpty) return Future<String>.value('');

    final cached = _wishImgFutureCache[id];
    if (cached != null) return cached;

    final future = () async {
      try {
        final res = await PsApiService().getImageList(id, 'wishitem', 1, 0);
        final photos = res.data;
        if (photos == null || photos.isEmpty) return '';

        final raw = (photos.first.imgPath ?? '').toString().trim();
        if (raw.isEmpty) return '';

        return _resolveImageUrl(raw).trim();
      } catch (_) {
        return '';
      }
    }();

    _wishImgFutureCache[id] = future;
    return future;
  }

  @override
  Widget build(BuildContext context) {
    final Product data = widget.data!;
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);

    final String ownerId = (data.addedUserId ?? '').trim();
    final String ownerName = (data.user?.userName ?? '').trim();
    final String loginUserId = (psValueHolder.loginUserId ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: PsColors.primary500.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PsColors.primary500.withOpacity(0.18),
                ),
              ),
              child: Icon(
                Icons.person_pin_circle_outlined,
                size: 20,
                color: PsColors.primary500,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'صاحب المنتج',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PsColors.textColor1,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ✅ الصف الأول: الصورة والاسم تحتها + العلاقة وزر الرسالة في نفس السطر
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: PsNetworkCircleImageForUser(
                      photoKey: '',
                      imagePath: data.user?.userProfilePhoto,
                      boxfit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ownerName.isEmpty
                        ? Utils.getString(context, 'default__user_name')
                        : ownerName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PsColors.textColor2,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _future == null
                  ? const SizedBox.shrink()
                  : FutureBuilder<PsResource<OwnerRelation>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasError) return const SizedBox.shrink();

                  final res = snapshot.data;
                  if (res == null ||
                      res.status != PsStatus.SUCCESS ||
                      res.data == null) {
                    return const SizedBox.shrink();
                  }

                  final OwnerRelation rel = res.data!;
                  final String relationText = _extractRelationText(rel);
                  final int relationType = _extractRelationType(rel);
                  final bool canShowSweetButton =
                  _canShowSweetMessageButton(relationType);

                  if (relationText.isEmpty && !canShowSweetButton) {
                    return const SizedBox.shrink();
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (relationText.isNotEmpty)
                          _MetaChip(
                            icon: Icons.people_alt_outlined,
                            label: relationText,
                          ),
                        if (relationText.isNotEmpty &&
                            canShowSweetButton &&
                            loginUserId.isNotEmpty &&
                            ownerId.isNotEmpty &&
                            loginUserId != ownerId)
                          const SizedBox(width: 8),
                        if (canShowSweetButton &&
                            loginUserId.isNotEmpty &&
                            ownerId.isNotEmpty &&
                            loginUserId != ownerId)
                          _SweetMessageMiniChip(
                            onTap: () {
                              _showSweetMessageBottomSheet(
                                context: context,
                                loginUserId: loginUserId,
                                receiverUserId: ownerId,
                                receiverName: ownerName.isEmpty
                                    ? 'المستخدم'
                                    : ownerName,
                                itemId: (data.id ?? '').toString(),
                                relationType: relationType,
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // ✅ الصف الثالث: نبذة
        if ((data.user?.userAboutMe ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.28),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.16),
              ),
            ),
            child: Text(
              data.user!.userAboutMe!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PsColors.textColor2?.withAlpha((0.82 * 255).round()),
                height: 1.35,
              ),
            ),
          ),
        ],

        // ✅ الصف الرابع: معرض العائلة
        if (_familyCountFuture != null) ...[
          const SizedBox(height: 12),
          FutureBuilder<int>(
            future: _familyCountFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              final int count = snapshot.data ?? 0;
              if (count <= 0) return const SizedBox.shrink();

              return SizedBox(
                height: 42,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ProfileProductChip(
                          icon: Icons.grid_view_rounded,
                          label: 'جميع منتجاته',
                          countText: null,
                          gradient: const <Color>[
                            Color(0xFF3F7CFF),
                            Color(0xFF42C6F5),
                          ],
                          shadowColor: const Color(0x3342A5F5),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutePaths.userDetail,
                              arguments: UserIntentHolder(
                                userId: ownerId,
                                userName: ownerName,
                              ),
                            );
                          },
                        );
                      }

                      return _ProfileProductChip(
                        icon: Icons.family_restroom_rounded,
                        label: 'معرض عائلته',
                        countText: '$count',
                        gradient: const <Color>[
                          Color(0xFFFF9F1C),
                          Color(0xFFFFC857),
                        ],
                        shadowColor: const Color(0x33FF9F1C),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RoutePaths.userDetail,
                            arguments: UserIntentHolder(
                              userId: ownerId,
                              userName: ownerName,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],

        const SizedBox(height: 14),

        Consumer<OwnerSubcatSubscribeProvider>(
          builder: (context, p, _) {
            final res = p.subcats;
            final List<OwnerSubcatSubscribe> items =
                res.data?.message ?? <OwnerSubcatSubscribe>[];

            if (res.status == PsStatus.PROGRESS_LOADING) {
              return const SizedBox.shrink();
            }
            if (items.isEmpty) return const SizedBox.shrink();

            const int maxShown = 30;
            final shown = items.take(maxShown).toList();

            return _SectionBlock(
              icon: Icons.interests_outlined,
              title: 'تصنيفاته المفضلة',
              child: _ChipsRow(
                labels: shown
                    .map((m) => (m.subcatName).trim().isEmpty
                    ? 'تصنيف'
                    : m.subcatName.trim())
                    .toList(),
                onTapLabel: (label) {},
              ),
            );
          },
        ),

        if (_wishFuture != null) ...[
          const SizedBox(height: 12),
          _OwnerWishlistSection(
            future: _wishFuture!,
            imageFutureOf: _fetchWishImageUrlViaApi,
            onSeeAll: () {},
            onTapVm: (WishVM vm) {
              if (vm.id.trim().isEmpty) return;
              Navigator.pushNamed(
                context,
                RoutePaths.productDetail,
                arguments: ProductDetailIntentHolder(
                  productId: vm.id,
                  heroTagImage: vm.id,
                ),
              );
            },
          ),
        ],




      ],
    );
  }
}

/// ======================================================
/// ✅ Sweet message helpers
/// ======================================================
bool _canShowSweetMessageButton(dynamic relationType) {
  final int value = int.tryParse((relationType ?? '0').toString()) ?? 0;
  return value >= 1 && value <= 6;
}

class _SweetUiPalette {
  const _SweetUiPalette({
    required this.primary,
    required this.secondary,
    required this.soft,
    required this.border,
    required this.badgeBg,
    required this.badgeFg,
    required this.icon,
    required this.headerEmoji,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.emptyText,
    required this.sendLabel,
    required this.pillLabel,
  });

  final Color primary;
  final Color secondary;
  final Color soft;
  final Color border;
  final Color badgeBg;
  final Color badgeFg;
  final IconData icon;
  final String headerEmoji;
  final String headerTitle;
  final String headerSubtitle;
  final String emptyText;
  final String sendLabel;
  final String pillLabel;
}

class _PhraseCardTone {
  const _PhraseCardTone({
    required this.bgTop,
    required this.bgBottom,
    required this.border,
    required this.bubbleBg,
    required this.bubbleFg,
    required this.accent,
  });

  final Color bgTop;
  final Color bgBottom;
  final Color border;
  final Color bubbleBg;
  final Color bubbleFg;
  final Color accent;
}

_SweetUiPalette _paletteForCategory(String category) {
  if (category == 'joke') {
    return const _SweetUiPalette(
      primary: Color(0xFF5F8CFF),
      secondary: Color(0xFF62C6FF),
      soft: Color(0xFFF1F8FF),
      border: Color(0xFFD9E9FF),
      badgeBg: Color(0xFFE6F2FF),
      badgeFg: Color(0xFF215EA6),
      icon: Icons.sentiment_very_satisfied_rounded,
      headerEmoji: '😊',
      headerTitle: 'تعليق خفيف',
      headerSubtitle:
      'اختَر تعليقًا بسيطًا يضيف جوًا لطيفًا وابتسامة خفيفة ✨',
      emptyText: 'لا توجد تعليقات خفيفة مناسبة الآن',
      sendLabel: 'إرسال التعليق',
      pillLabel: 'خفيف',
    );
  }

  return const _SweetUiPalette(
    primary: Color(0xFF0FA7B5),
    secondary: Color(0xFF5F8CFF),
    soft: Color(0xFFF2FAFB),
    border: Color(0xFFD7EEF2),
    badgeBg: Color(0xFFE6F8FA),
    badgeFg: Color(0xFF0E7681),
    icon: Icons.auto_awesome_rounded,
    headerEmoji: '✨',
    headerTitle: 'رسالة لطيفة',
    headerSubtitle:
    'اختَر رسالة جميلة ترسم ابتسامة وتوصل ذوقك واهتمامك 🌷',
    emptyText: 'لا توجد رسائل لطيفة مناسبة الآن',
    sendLabel: 'إرسال الرسالة',
    pillLabel: 'لطيفة',
  );
}

_PhraseCardTone _toneForCard(String category, int index, bool selected) {
  if (selected) {
    return const _PhraseCardTone(
      bgTop: Color(0xFFEAF7FF),
      bgBottom: Color(0xFFF7FCFF),
      border: Color(0xFF74B7FF),
      bubbleBg: Color(0xFFDFF1FF),
      bubbleFg: Color(0xFF155B9A),
      accent: Color(0xFF4D97F2),
    );
  }

  if (category == 'joke') {
    const tones = <_PhraseCardTone>[
      _PhraseCardTone(
        bgTop: Color(0xFFF7FAFF),
        bgBottom: Color(0xFFEEF5FF),
        border: Color(0xFFDCE8FF),
        bubbleBg: Color(0xFFE8F1FF),
        bubbleFg: Color(0xFF2E61B8),
        accent: Color(0xFF79A9FF),
      ),
      _PhraseCardTone(
        bgTop: Color(0xFFF4FBFF),
        bgBottom: Color(0xFFEAF8FF),
        border: Color(0xFFD5ECFA),
        bubbleBg: Color(0xFFE1F5FF),
        bubbleFg: Color(0xFF1F7DA1),
        accent: Color(0xFF6BC6E9),
      ),
      _PhraseCardTone(
        bgTop: Color(0xFFF8F7FF),
        bgBottom: Color(0xFFF1EEFF),
        border: Color(0xFFE4DEFF),
        bubbleBg: Color(0xFFEEE8FF),
        bubbleFg: Color(0xFF6652B7),
        accent: Color(0xFF9A87F7),
      ),
    ];
    return tones[index % tones.length];
  }

  const tones = <_PhraseCardTone>[
    _PhraseCardTone(
      bgTop: Color(0xFFF5FCFB),
      bgBottom: Color(0xFFECF9F7),
      border: Color(0xFFD9F0EC),
      bubbleBg: Color(0xFFE3F7F3),
      bubbleFg: Color(0xFF0E7D73),
      accent: Color(0xFF56C1B2),
    ),
    _PhraseCardTone(
      bgTop: Color(0xFFF7FAFF),
      bgBottom: Color(0xFFEEF4FF),
      border: Color(0xFFDCE6FF),
      bubbleBg: Color(0xFFE8F0FF),
      bubbleFg: Color(0xFF355FB4),
      accent: Color(0xFF7A9BFF),
    ),
    _PhraseCardTone(
      bgTop: Color(0xFFFFFAF6),
      bgBottom: Color(0xFFFFF3EA),
      border: Color(0xFFF7E4D6),
      bubbleBg: Color(0xFFFFEEE0),
      bubbleFg: Color(0xFFB06A2D),
      accent: Color(0xFFF2AE73),
    ),
  ];
  return tones[index % tones.length];
}

class _SweetMessageMiniChip extends StatelessWidget {
  const _SweetMessageMiniChip({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Color start = Color(0xFF5EC6D0);
    const Color end = Color(0xFF5F8CFF);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[start, end],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.55),
          width: 1.1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x225F8CFF),
            blurRadius: 18,
            spreadRadius: 1,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsetsDirectional.only(
              start: 10,
              end: 14,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ابعت كلمة حلوة',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.9,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'كلمات بسيطة تدخل السرور',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.2,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 7),
                    Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showSweetMessageBottomSheet({
  required BuildContext context,
  required String loginUserId,
  required String receiverUserId,
  required String receiverName,
  required String itemId,
  required int relationType,
}) async {
  final SweetMessageProvider provider =
  Provider.of<SweetMessageProvider>(context, listen: false);

  provider.reset();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return ChangeNotifierProvider.value(
        value: provider,
        child: _SweetMessageBottomSheetBody(
          loginUserId: loginUserId,
          receiverUserId: receiverUserId,
          receiverName: receiverName,
          itemId: itemId,
          relationType: relationType,
        ),
      );
    },
  );
}

class _SweetMessageBottomSheetBody extends StatefulWidget {
  const _SweetMessageBottomSheetBody({
    Key? key,
    required this.loginUserId,
    required this.receiverUserId,
    required this.receiverName,
    required this.itemId,
    required this.relationType,
  }) : super(key: key);

  final String loginUserId;
  final String receiverUserId;
  final String receiverName;
  final String itemId;
  final int relationType;

  @override
  State<_SweetMessageBottomSheetBody> createState() =>
      _SweetMessageBottomSheetBodyState();
}

class _SweetMessageBottomSheetBodyState
    extends State<_SweetMessageBottomSheetBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String get _currentCategory => _tabController.index == 0 ? 'sweet' : 'joke';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SweetMessageProvider provider =
      Provider.of<SweetMessageProvider>(context, listen: false);

      provider.setMessageCategory('sweet');
      await provider.loadPhraseSuggestions(
        loginUserId: widget.loginUserId,
        receiverUserId: widget.receiverUserId,
      );
      if (mounted) {
        setState(() {});
      }
    });

    _tabController.addListener(() async {
      if (_tabController.indexIsChanging) {
        return;
      }

      if (mounted) {
        setState(() {});
      }

      final SweetMessageProvider provider =
      Provider.of<SweetMessageProvider>(context, listen: false);

      final String nextCategory = _tabController.index == 0 ? 'sweet' : 'joke';

      if (provider.messageCategory == nextCategory) {
        return;
      }

      provider.setMessageCategory(nextCategory);
      await provider.loadPhraseSuggestions(
        loginUserId: widget.loginUserId,
        receiverUserId: widget.receiverUserId,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SweetMessageProvider provider =
    Provider.of<SweetMessageProvider>(context);

    final _SweetUiPalette palette = _paletteForCategory(_currentCategory);
    final String safeReceiverName =
    widget.receiverName.trim().isEmpty ? 'هذا الشخص' : widget.receiverName;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFEFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewPadding.bottom + 14,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.76,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFD7E3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        palette.soft,
                        Colors.white,
                      ],
                    ),
                    border: Border.all(color: palette.border),
                    boxShadow: [
                      BoxShadow(
                        color: palette.secondary.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [palette.primary, palette.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: palette.secondary.withOpacity(0.22),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            palette.headerEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ابعث رسالة لطيفة إلى $safeReceiverName',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: PsColors.textColor2,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              palette.headerSubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color:
                                PsColors.textColor2?.withOpacity(0.72),
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2EAF2)),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Color(0xFF0FA7B5),
                          Color(0xFF5F8CFF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5F8CFF).withOpacity(0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: PsColors.textColor2,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'رسائل لطيفة'),
                      Tab(text: 'تعليقات خفيفة'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _SheetHintChip(
                      icon: palette.icon,
                      label: palette.pillLabel,
                      bgColor: palette.badgeBg,
                      fgColor: palette.badgeFg,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'اختَر جملة واحدة وأرسلها فورًا ✨',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PsColors.textColor2?.withOpacity(0.72),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PhraseTabContent(
                        provider: provider,
                        emptyText: _paletteForCategory('sweet').emptyText,
                        category: 'sweet',
                      ),
                      _PhraseTabContent(
                        provider: provider,
                        emptyText: _paletteForCategory('joke').emptyText,
                        category: 'joke',
                      ),
                    ],
                  ),
                ),
                if ((provider.errorMessage ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3F3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFFD5D5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Color(0xFF0B2A58),
                          Color(0xFF123F78),
                        ],
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x220B2A58),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: provider.isSending
                          ? null
                          : () async {
                        final bool ok = await provider.sendSelectedPhrase(
                          loginUserId: widget.loginUserId,
                          receiverUserId: widget.receiverUserId,
                          itemId: widget.itemId,
                          relationType: widget.relationType,
                        );

                        if (!mounted) {
                          return;
                        }

                        if (ok) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إرسال الرسالة بنجاح ✨'),
                            ),
                          );
                        }
                      },
                      icon: provider.isSending
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        provider.isSending
                            ? 'جارٍ الإرسال...'
                            : palette.sendLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHintChip extends StatelessWidget {
  const _SheetHintChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.fgColor,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: 10,
        end: 12,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: fgColor.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: fgColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w800,
              fontSize: 11.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhraseTabContent extends StatelessWidget {
  const _PhraseTabContent({
    Key? key,
    required this.provider,
    required this.emptyText,
    required this.category,
  }) : super(key: key);

  final SweetMessageProvider provider;
  final String emptyText;
  final String category;

  @override
  Widget build(BuildContext context) {
    final _SweetUiPalette palette = _paletteForCategory(category);

    if (provider.isLoadingPhrases) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(palette.secondary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'جارٍ تجهيز اقتراحات مناسبة...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PsColors.textColor2?.withOpacity(0.66),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.phrases.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            color: palette.soft,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: palette.badgeBg,
                child: Icon(
                  palette.icon,
                  color: palette.badgeFg,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                emptyText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PsColors.textColor2?.withOpacity(0.68),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmall = constraints.maxWidth < 360;
        final double mainExtent = isSmall ? 160 : 120;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 4),
          itemCount: provider.phrases.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            mainAxisExtent: mainExtent,
          ),
          itemBuilder: (context, index) {
            final SweetPhrase phrase = provider.phrases[index];
            final bool selected =
                provider.selectedPhrase?.phraseId == phrase.phraseId;

            return _PhraseChoiceCard(
              phrase: phrase,
              selected: selected,
              palette: palette,
              category: category,
              cardIndex: index,
              onTap: () => provider.selectPhrase(phrase),
            );
          },
        );
      },
    );
  }
}


class _PhraseChoiceCard extends StatelessWidget {
  const _PhraseChoiceCard({
    Key? key,
    required this.phrase,
    required this.selected,
    required this.palette,
    required this.category,
    required this.cardIndex,
    required this.onTap,
  }) : super(key: key);

  final SweetPhrase phrase;
  final bool selected;
  final _SweetUiPalette palette;
  final String category;
  final int cardIndex;
  final VoidCallback onTap;

  bool get _isJoke => category.toLowerCase() == 'joke';

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = _isJoke
        ? const <Color>[
      Color(0xFF213F96),
      Color(0xFF172F78),
      Color(0xFF0E235F),
    ]
        : const <Color>[
      Color(0xFF061F46),
      Color(0xFF0C587A),
      Color(0xFF24A9C4),
      Color(0xFF29D6C7),
    ];

    return AnimatedScale(
      scale: selected ? 1.0 : 0.985,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: colors,
          ),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.72),
            width: selected ? 2.0 : 1.35,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: (_isJoke ? const Color(0xFF172F78) : const Color(0xFF0C587A))
                  .withOpacity(selected ? 0.34 : 0.18),
              blurRadius: selected ? 22 : 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.78),
                          width: 1.05,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!_isJoke)
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: Opacity(
                      opacity: 0.20,
                      child: Image.asset(
                        'assets/images/Taapdeel_icon.png',
                        width: 34,
                        height: 34,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (_isJoke)
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: Icon(
                      Icons.sentiment_very_satisfied_rounded,
                      color: Colors.white.withOpacity(0.22),
                      size: 28,
                    ),
                  ),
                if (selected)
                  PositionedDirectional(
                    top: 9,
                    start: 9,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.92),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: _isJoke ? const Color(0xFF213F96) : const Color(0xFF0C587A),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Center(
                      child: Text(
                        phrase.phraseText,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.2,
                          height: 1.55,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// ======================================================
/// ✅ Section UI helpers
/// ======================================================
class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    Key? key,
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final Widget child;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      radius: 16,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: PsColors.textColor2),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: PsColors.textColor2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if ((trailing ?? '').isNotEmpty)
                Text(
                  trailing!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                    PsColors.textColor2?.withAlpha((0.75 * 255).round()),
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ChipsRow extends StatelessWidget {
  const _ChipsRow({
    Key? key,
    required this.labels,
    this.onTapLabel,
  }) : super(key: key);

  final List<String> labels;
  final void Function(String label)? onTapLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = labels[i];
          return _WishChip(
            label: label,
            onTap: () => onTapLabel?.call(label),
          );
        },
      ),
    );
  }
}

class _ProfileProductChip extends StatelessWidget {
  const _ProfileProductChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.gradient,
    required this.shadowColor,
    this.countText,
    this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final String? countText;
  final List<Color> gradient;
  final Color shadowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasCount = (countText ?? '').trim().isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: gradient,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.62),
          width: 1.1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 10,
              end: 12,
              top: 7,
              bottom: 7,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.32),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.2,
                    height: 1.0,
                  ),
                ),
                if (hasCount) ...<Widget>[
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.30),
                      ),
                    ),
                    child: Text(
                      countText!.trim(),
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11.2,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      radius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: PsColors.textColor2),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PsColors.textColor2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================================================
/// ✅ Wishlist adaptive model + rendering
/// ======================================================
enum WishLayout { chip, mini, rich }

class WishVM {
  final String id;
  final String title;
  final String? imageUrl;
  final String? desc;

  const WishVM({
    required this.id,
    required this.title,
    this.imageUrl,
    this.desc,
  });

  bool get hasImage => (imageUrl ?? '').trim().isNotEmpty;
  bool get hasDesc => (desc ?? '').trim().isNotEmpty;

  WishLayout get layout {
    if (!hasImage && !hasDesc) return WishLayout.chip;
    if (hasImage && hasDesc) return WishLayout.rich;
    if (hasImage && !hasDesc) return WishLayout.mini;
    return WishLayout.rich;
  }

  WishVM copyWith({String? imageUrl}) {
    return WishVM(
      id: id,
      title: title,
      imageUrl: imageUrl ?? this.imageUrl,
      desc: desc,
    );
  }
}

String _baseForFiles() {
  final String app = PsConfig.ps_app_url.trim();
  return app.replaceAll('index.php/', '').replaceAll('index.php', '');
}

String _resolveImageUrl(String rawImg) {
  final String raw = rawImg.trim();
  if (raw.isEmpty) return '';

  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return Uri.encodeFull(raw);
  }

  String path = raw.replaceAll('\\', '/');
  if (path.startsWith('/')) path = path.substring(1);

  final String base = _baseForFiles();
  return Uri.encodeFull('$base/uploads/$path');
}

WishVM wishToVM(WishlistProductModel m) {
  final String id = (m.id ?? '').toString().trim();
  final String title = (m.title ?? '').toString().trim();
  final String desc = (m.description ?? '').toString().trim();

  return WishVM(
    id: id,
    title: title.isEmpty ? 'عنصر' : title,
    imageUrl: null,
    desc: desc.isEmpty ? null : desc,
  );
}

class _OwnerWishlistSection extends StatelessWidget {
  const _OwnerWishlistSection({
    Key? key,
    required this.future,
    required this.imageFutureOf,
    required this.onSeeAll,
    required this.onTapVm,
  }) : super(key: key);

  final Future<List<WishlistProductModel>> future;
  final Future<String> Function(String wishId) imageFutureOf;
  final VoidCallback onSeeAll;
  final void Function(WishVM vm) onTapVm;

  Future<List<WishVM>> _resolveImages(List<WishVM> vms, {int max = 18}) async {
    final shown = vms.take(max).toList();
    final futures = shown.map((vm) async {
      final url = (await imageFutureOf(vm.id)).trim();
      return vm.copyWith(imageUrl: url.isEmpty ? '' : url);
    }).toList();
    return Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WishlistProductModel>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snap.hasError) return const SizedBox.shrink();

        final items = (snap.data ?? <WishlistProductModel>[]);
        if (items.isEmpty) return const SizedBox.shrink();

        final allVms = items.map(wishToVM).toList();

        const int maxShown = 18;
        final bool hasMore = allVms.length > maxShown;

        return FutureBuilder<List<WishVM>>(
          future: _resolveImages(allVms, max: maxShown),
          builder: (context, rs) {
            final resolved = (rs.data ?? <WishVM>[]);
            if (resolved.isEmpty) return const SizedBox.shrink();

            final chips = resolved.where((e) => !e.hasImage).toList();
            final cards = resolved.where((e) => e.hasImage).toList();

            return _SectionBlock(
              icon: Icons.favorite_border,
              title: 'يحتاج إلى',
              trailing: hasMore ? 'عرض الكل' : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chips.isNotEmpty) ...[
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: chips.length + (hasMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          if (hasMore && i == chips.length) {
                            return _WishChip(
                              label: '+${allVms.length - maxShown}',
                              onTap: onSeeAll,
                              isCount: true,
                            );
                          }
                          final vm = chips[i];
                          return _WishChip(
                            label: vm.title,
                            onTap: () => onTapVm(vm),
                          );
                        },
                      ),
                    ),
                  ],
                  if (chips.isNotEmpty && cards.isNotEmpty)
                    const SizedBox(height: 10),
                  if (cards.isNotEmpty) ...[
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: cards.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final vm = cards[i];
                          return _WishImageDescCard(
                            vm: vm,
                            onTap: () => onTapVm(vm),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _WishImageDescCard extends StatelessWidget {
  const _WishImageDescCard({
    Key? key,
    required this.vm,
    required this.onTap,
  }) : super(key: key);

  final WishVM vm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final desc = (vm.desc ?? '').trim();

    return _GlassContainer(
      radius: 14,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 130,
        height: 86,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                vm.imageUrl!.trim(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withOpacity(0.06),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 18,
                    color: PsColors.textColor2?.withOpacity(0.7),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.10),
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),
              if (desc.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 10,
                  right: 10,
                  child: Text(
                    desc,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                      height: 1.15,
                    ),
                  ),
                ),
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Text(
                  vm.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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

class _WishChip extends StatelessWidget {
  const _WishChip({
    Key? key,
    required this.label,
    required this.onTap,
    this.isCount = false,
  }) : super(key: key);

  final String label;
  final VoidCallback onTap;
  final bool isCount;

  @override
  Widget build(BuildContext context) {
    final String text = label.trim().isEmpty ? 'عنصر' : label.trim();

    return _GlassContainer(
      radius: 999,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCount ? Icons.more_horiz : Icons.local_offer_outlined,
            size: 16,
            color: PsColors.textColor2?.withAlpha((0.92 * 255).round()),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PsColors.textColor2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}