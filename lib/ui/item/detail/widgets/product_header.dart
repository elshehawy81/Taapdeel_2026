import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/gallery/gallery_provider.dart';
import 'package:taapdeel/provider/product/favourite_item_provider.dart';
import 'package:taapdeel/provider/product/product_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/ui/common/dialog/confirm_dialog_view.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/ps_hero.dart';
import 'package:taapdeel/ui/item/share_theme/product_share_options.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/taapdeel_share_links.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/favourite_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/user_block_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/user_report_item_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PopUpMenuWidget extends StatelessWidget {
  const PopUpMenuWidget(
      {required this.userProvider,
        required this.itemId,
        required this.itemUserId,
        required this.addedUserId,
        required this.reportedUserId,
        required this.loginUserId,
        required this.itemTitle,
        required this.itemImage,
        required this.context,
        required this.itemDetailProvider});

  final UserProvider? userProvider;
  final String? itemId;
  final String? addedUserId;
  final String? reportedUserId;
  final String? loginUserId;
  final String? itemUserId;
  final String? itemTitle;
  final String? itemImage;
  final BuildContext context;
  final ItemDetailProvider itemDetailProvider;

  String _safeText(dynamic value) {
    final String text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  String _buildPlainProductShareMessage(Product? product, String link) {
    final String title = _safeText(product?.title).isNotEmpty
        ? _safeText(product?.title)
        : _safeText(itemTitle);

    final StringBuffer buffer = StringBuffer();

    if (title.isNotEmpty) {
      buffer.writeln('شوف المنتج ده على تبديل: $title');
    } else {
      buffer.writeln('شوف المنتج ده على تبديل');
    }

    buffer.writeln();
    buffer.writeln('لو التطبيق عندك هيفتح المنتج مباشرة، ولو مش عندك هتقدر تشوفه من الرابط:');
    buffer.writeln(link);

    return buffer.toString().trim();
  }

  Future<void> _onSelect(String value) async {
    switch (value) {
      case '1':
        showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialogView(
                description: Utils.getString(
                    context, 'item_detail__confirm_dialog_report_item'),
                leftButtonText: Utils.getString(context, 'dialog__cancel'),
                rightButtonText: Utils.getString(context, 'dialog__ok'),
                onAgreeTap: () async {
                  await PsProgressDialog.showDialog(context);

                  final UserReportItemParameterHolder
                  userReportItemParameterHolder =
                  UserReportItemParameterHolder(
                      itemId: itemId, reportedUserId: reportedUserId);

                  final PsResource<ApiStatus> _apiStatus = await userProvider!
                      .userReportItem(userReportItemParameterHolder.toMap());

                  if (_apiStatus.data != null &&
                      _apiStatus.data!.status != null) {
                    await itemDetailProvider.deleteLocalProductCacheById(
                        itemId, reportedUserId);
                  }

                  PsProgressDialog.dismissDialog();

                  Navigator.of(context)
                      .popUntil(ModalRoute.withName(RoutePaths.home));
                });
          },
        );

        break;

      case '2':
        showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialogView(
                description: Utils.getString(
                    context, 'item_detail__confirm_dialog_block_user'),
                leftButtonText: Utils.getString(context, 'dialog__cancel'),
                rightButtonText: Utils.getString(context, 'dialog__ok'),
                onAgreeTap: () async {
                  await PsProgressDialog.showDialog(context);

                  final UserBlockParameterHolder
                  userBlockItemParameterHolder =
                  UserBlockParameterHolder(
                      loginUserId: loginUserId, addedUserId: addedUserId);

                  final PsResource<ApiStatus> _apiStatus = await userProvider!
                      .blockUser(userBlockItemParameterHolder.toMap());

                  if (_apiStatus.data != null &&
                      _apiStatus.data!.status != null) {
                    await itemDetailProvider.deleteLocalProductCacheByUserId(
                        loginUserId, addedUserId);
                  }

                  PsProgressDialog.dismissDialog();

                  Navigator.of(context)
                      .popUntil(ModalRoute.withName(RoutePaths.home));
                });
          },
        );
        break;

      case '3':
        final Size size = MediaQuery.of(context).size;
        final Product? product = itemDetailProvider.itemDetail.data;
        final String link = TaapdeelShareLinks.product(
          product?.id ?? itemId,
        );

        Share.share(
          _buildPlainProductShareMessage(product, link),
          sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
        );

        break;
      default:
        print('English');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin:
        const EdgeInsets.only(left: PsDimens.space12, right: PsDimens.space12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: PsColors.black.withAlpha(100),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
              iconTheme:
              Theme.of(context).iconTheme.copyWith(color: PsColors.white)),
          child: PopupMenuButton<String>(
            onSelected: _onSelect,
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                if (itemDetailProvider.psValueHolder!.loginUserId != itemUserId &&
                    itemDetailProvider.psValueHolder!.loginUserId != null &&
                    itemDetailProvider.psValueHolder!.loginUserId != '')
                  PopupMenuItem<String>(
                    value: '1',
                    child: Visibility(
                      visible: true,
                      child: Text(
                        Utils.getString(context, 'item_detail__report_item'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                if (itemDetailProvider.psValueHolder!.loginUserId != itemUserId &&
                    itemDetailProvider.psValueHolder!.loginUserId != null &&
                    itemDetailProvider.psValueHolder!.loginUserId != '')
                  PopupMenuItem<String>(
                    value: '2',
                    child: Visibility(
                      visible: true,
                      child: Text(
                        Utils.getString(context, 'item_detail__block_user'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
              ];
            },
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ));
  }
}

class HeaderBoxWidget extends StatefulWidget {
  const HeaderBoxWidget(
      {Key? key,
        required this.itemDetail,
        required this.galleryProvider,
        required this.favouriteProvider,
        required this.product,
        required this.heroTagTitle})
      : super(key: key);

  final ItemDetailProvider itemDetail;
  final GalleryProvider? galleryProvider;
  final FavouriteItemProvider favouriteProvider;
  final Product? product;
  final String? heroTagTitle;

  @override
  _HeaderBoxWidgetState createState() => _HeaderBoxWidgetState();
}

class _HeaderBoxWidgetState extends State<HeaderBoxWidget> {
  bool showEditButton = true;

  bool _descExpanded = false;

  // ✅ NEW: local optimistic state for the favourite toggle.
  // null = not yet initialized from product data.
  bool? _isFavourited;

  // ✅ NEW: guard against double-tap while a request is in flight.
  bool _favouriteRequestInProgress = false;

  String _s(dynamic v) => (v ?? '').toString().trim();

  bool _has(dynamic v) => _s(v).isNotEmpty && _s(v).toLowerCase() != 'null';

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    final String s = v.toString().trim();
    return int.tryParse(s) ?? 0;
  }

  Map<String, dynamic> _parseHighlightMap(dynamic raw) {
    try {
      final String txt = _s(raw);
      if (txt.isEmpty) return <String, dynamic>{};
      final dynamic decoded = jsonDecode(txt);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  Map<String, dynamic> _parseJsonMap(dynamic raw) {
    try {
      final String txt = _s(raw);
      if (txt.isEmpty) return <String, dynamic>{};
      final dynamic decoded = jsonDecode(txt);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  bool _boolFromMap(Map<String, dynamic> m, List<String> keys) {
    for (final String k in keys) {
      if (!m.containsKey(k)) continue;
      final dynamic v = m[k];
      if (v is bool) return v;
      final String s = _s(v).toLowerCase();
      if (s == '1' || s == 'true' || s == 'yes') return true;
    }
    return false;
  }

  String _valueFromMap(Map<String, dynamic> m, List<String> keys) {
    for (final String k in keys) {
      if (!m.containsKey(k)) continue;
      final dynamic v = m[k];
      if (v == null) continue;
      if (v is Map) {
        final dynamic name = v['name'] ?? v['title'] ?? v['label'];
        if (_has(name)) return _s(name);
        final dynamic id = v['id'] ?? v['value'];
        if (_has(id)) return _s(id);
      }
      if (_has(v)) return _s(v);
    }
    return '';
  }

  String _stringifyValue(dynamic value) {
    if (value == null) return '';

    if (value is bool) return value ? 'نعم' : 'لا';

    if (value is Map) {
      final dynamic name = value['name'] ?? value['title'] ?? value['label'];
      if (_has(name)) return _s(name);

      final dynamic nestedValue =
          value['value'] ?? value['id'] ?? value['text'] ?? value['code'];
      if (_has(nestedValue)) return _s(nestedValue);

      return '';
    }

    if (value is List) {
      return value
          .map(_stringifyValue)
          .where((String e) => e.trim().isNotEmpty)
          .join('، ');
    }

    return _s(value);
  }

  String _prettyKey(String key) {
    const Map<String, String> custom = <String, String>{
      'brand': 'البراند',
      'brand_name': 'البراند',
      'brandName': 'البراند',
      'brand_id': 'البراند',
      'brandId': 'البراند',
      'size': 'المقاس',
      'sizes': 'المقاس',
      'color': 'اللون',
      'colors': 'الألوان',
      'material': 'الخامة',
      'model': 'الموديل',
      'capacity': 'السعة',
      'warranty': 'الضمان',
      'gender': 'النوع',
      'style': 'الستايل',
      'pattern': 'النقشة',
      'fabric': 'القماش',
      'season': 'الموسم',
      'fit': 'القصّة',
      'closure': 'نوع الغلق',
      'length': 'الطول',
      'width': 'العرض',
      'height': 'الارتفاع',
      'weight': 'الوزن',
      'age_group': 'الفئة العمرية',
      'usage_type': 'نوع الاستخدام',
      'authenticity': 'الأصالة',
      'origin': 'بلد المنشأ',
      'is_free': 'مجاني',
      'is_imported': 'مستورد',
      'is_wrapped': 'مغلف',
      'is_new': 'جديد',
    };

    if (custom.containsKey(key)) return custom[key]!;

    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'), (Match m) => '${m[1]} ${m[2]}')
        .trim();
  }

  bool _shouldHideSpecKey(String key) {
    const Set<String> hidden = <String>{
      'is_free',
      'free',
      'is_imported',
      'imported',
      'is_wrapped',
      'wrapped',
      'is_new',
      'new',
      'brand',
      'brand_name',
      'brandName',
      'brand_id',
      'brandId',
    };
    return hidden.contains(key);
  }

  List<MapEntry<String, String>> _extractDetailSpecs(Map<String, dynamic> m) {
    final List<MapEntry<String, String>> out = <MapEntry<String, String>>[];

    m.forEach((String key, dynamic value) {
      if (_shouldHideSpecKey(key)) return;
      if (!_has(value) && value is! bool && value is! List && value is! Map) {
        return;
      }

      final String finalValue = _stringifyValue(value);
      if (finalValue.trim().isEmpty) return;

      out.add(MapEntry<String, String>(_prettyKey(key), finalValue));
    });

    return out;
  }

  static const Color _goldBgStart = Color(0xFFFFF3C4);
  static const Color _goldBgEnd = Color(0xFFFFF3C4);
  static const Color _goldBorder = Color(0xFFE6B65C);
  static const Color _goldText = Color(0xFF8C6A03);

  Widget _chip({
    required String text,
    required IconData icon,
    Color? bg,
    Color? fg,
    bool gold = false,
  }) {
    final Color fgc = gold ? _goldText : (fg ?? const Color(0xFF0F2E57));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: gold
            ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[_goldBgStart, _goldBgEnd],
        )
            : null,
        color: gold ? null : (bg ?? const Color(0xFFF1F7FF)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: gold ? _goldBorder : Colors.black.withOpacity(0.06),
          width: gold ? 1.2 : 1.0,
        ),
        boxShadow: <BoxShadow>[
          if (gold)
            BoxShadow(
              color: _goldBorder.withOpacity(0.30),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: fgc.withOpacity(0.95)),
          const SizedBox(width: 6),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: fgc,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required String title,
    required String value,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                icon,
                size: 16,
                color: const Color(0xFF3167B0),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2E57),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.72),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {IconData? icon}) {
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(
            icon,
            size: 17,
            color: const Color(0xFF3167B0),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F2E57),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _withGap(List<Widget> items, {double gap = 8}) {
    if (items.isEmpty) return const <Widget>[];
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) {
        out.add(SizedBox(width: gap));
      }
    }
    return out;
  }

  Widget _chipRow(List<Widget> chips) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return Directionality(
      textDirection: Directionality.of(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _withGap(chips),
        ),
      ),
    );
  }


  String _resolveProductShareImageUrl(Product product) {
    String raw = '';

    try {
      raw = _s(product.defaultPhoto?.imgPath);
    } catch (_) {}

    if (!_has(raw)) {
      try {
        final dynamic d = product as dynamic;
        raw = _s(d.default_photo?.imgPath ?? d.default_photo?.img_path);
      } catch (_) {}
    }

    if (!_has(raw)) {
      try {
        final dynamic d = product as dynamic;
        raw = _s(d.defaultPhoto?.imgPath ?? d.defaultPhoto?.img_path);
      } catch (_) {}
    }

    if (!_has(raw)) return '';

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final String base = _s(PsConfig.ps_app_image_url);
    if (!_has(base)) return raw;

    final String cleanBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final String cleanPath = raw.startsWith('/') ? raw.substring(1) : raw;

    return '$cleanBase/$cleanPath';
  }

  void _openProductShareOptions(Product product) {
    final String dynamicLink = TaapdeelShareLinks.product(product.id);

    // لا نعتمد هنا على product.dynamicLink القادم من الداتا بيز، لأنه قد يحتوي
    // على Firebase Dynamic Link قديم. ProductShareOptions سيضيف نفس الرابط
    // الصحيح داخل رسالة الشير.
    ProductShareOptions.show(
      context: context,
      product: product,
      dynamicLink: dynamicLink,
      imageUrl: _resolveProductShareImageUrl(product),
    );
  }

  Widget _buildShareThemeFeatureCard(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PsDimens.space2,
        PsDimens.space12,
        PsDimens.space2,
        0,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openProductShareOptions(product),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: <Color>[
                Color(0xFF4FACFE),
                Color(0xFF4FACFE),
                Color(0xFF00F2FE),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF9EE7E1).withOpacity(0.70),
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF0C587A).withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.24),
                  ),
                ),
                child: const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'شارك المنتج بتصميم جذاب',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ' اختار الثيم اللي تحبة وشارك كارت المنتج على السوشيال ميديا',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.82),
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text(
                      'جرّب',
                      style: TextStyle(
                        color: Color(0xFF0C587A),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF0C587A),
                      size: 15,
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

  // ✅ NEW: تجميع منطق الضغط على أيقونة القلب في دالة واحدة واضحة.
  //
  // الفكرة:
  // 1) Optimistic UI: نبدّل الحالة محليًا فورًا (setState) بحيث يحس المستخدم
  //    باستجابة سريعة.
  // 2) نبعت الطلب للسيرفر (postFavourite) الذي يقوم بدوره بزيادة/تقليل
  //    favourite_count في bs_items.
  // 3) لو نجح الطلب: نعمل loadItemForFav لتحديث بيانات المنتج بالكامل
  //    (يشمل favourite_count المُحدّث من السيرفر).
  // 4) لو فشل الطلب أو رجع بدون data: نرجع الحالة المحلية لما كانت عليه
  //    (rollback) ونعرض رسالة خطأ.
  Future<void> _onFavouriteTap(
      Product product, PsValueHolder psValueHolder) async {
    if (_favouriteRequestInProgress) {
      return;
    }

    final bool hasInternet = await Utils.checkInternetConnectivity();
    if (!hasInternet) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'error_dialog__no_internet'),
          );
        },
      );
      return;
    }

    Utils.navigateOnUserVerificationView(
      widget.itemDetail,
      context,
          () async {
        // الحالة الحالية قبل التبديل (للـ rollback عند الفشل)
        final bool previousValue = _isFavourited ?? false;
        final bool nextValue = !previousValue;

        setState(() {
          _isFavourited = nextValue;
          _favouriteRequestInProgress = true;
        });

        final FavouriteParameterHolder favouriteParameterHolder =
        FavouriteParameterHolder(
          userId: psValueHolder.loginUserId,
          itemId: widget.product!.id,
        );

        final PsResource<Product> _apiStatus =
        await widget.favouriteProvider.postFavourite(
          favouriteParameterHolder.toMap(),
        );

        final bool succeeded = _apiStatus.status == PsStatus.SUCCESS &&
            _apiStatus.data != null;

        if (succeeded) {
          // إعادة تحميل بيانات المنتج (بما فيها favourite_count المحدث)
          await widget.itemDetail.loadItemForFav(
            widget.product!.id!,
            psValueHolder.loginUserId,
          );

          if (mounted) {
            final Product? refreshed = widget.itemDetail.itemDetail.data;
            setState(() {
              if (refreshed != null && _has(refreshed.isFavourited)) {
                _isFavourited = refreshed.isFavourited == PsConst.ONE;
              }
              _favouriteRequestInProgress = false;
            });
          }
        } else {
          // فشل الطلب: رجوع للحالة السابقة
          if (mounted) {
            setState(() {
              _isFavourited = previousValue;
              _favouriteRequestInProgress = false;
            });

            showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                    context,
                    'error_dialog__something_went_wrong',
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);

    if (widget.product != null && widget.itemDetail.itemDetail.data != null) {
      final Product data = widget.itemDetail.itemDetail.data!;
      final dynamic d = data as dynamic;

      // ✅ تهيئة الحالة المحلية مرة واحدة من بيانات المنتج القادمة من السيرفر
      _isFavourited ??= data.isFavourited == PsConst.ONE;

      final String title = _s(data.title);
      final String desc = _s(data.description);

      final String condition = _s(data.conditionOfItem?.name);
      final int condId =
      _toInt(data.conditionOfItemId ?? d.conditionOfItemId ?? d.condition_id);
      final bool goldCondition = (condId == 4 || condId == 5 || condId == 6);

      final String usage = _s(data.itemType?.name);
      final int itemTypeId = _toInt(data.itemTypeId ??
          d.itemTypeId ??
          d.item_type_id ??
          (data.itemType as dynamic?)?.id);
      final bool goldUsage = (itemTypeId == 2 || itemTypeId == 3);

      final String price = _s(data.price);

      final String locName = _s(data.itemLocation?.name);
      final String townName = _s(data.itemLocationTownship?.townshipName);

      final Map<String, dynamic> highlight =
      _parseHighlightMap(d.highlightInformation ?? d.highlight_info);

      final Map<String, dynamic> badgesRemark =
      _parseJsonMap(d.dealOptionRemark ?? d.deal_option_remark);

      final bool isFree = _boolFromMap(highlight, const <String>['is_free', 'free']);
      final bool isWrapped =
      _boolFromMap(highlight, const <String>['is_wrapped', 'wrapped']);
      final bool isNew = _boolFromMap(highlight, const <String>['is_new', 'new']);

      final int businessMode =
      _toInt(data.businessMode ?? d.businessMode ?? d.business_mode);
      final bool goldImported = (businessMode == 2);
      final String subCategoryName = _s(data.subCategory?.name ?? d.sub_category?.name);
      final String brand = _valueFromMap(
        highlight,
        const <String>['brand', 'brand_name', 'brandName', 'brand_id', 'brandId'],
      );
      final bool goldBrand = _has(brand);

      String locLabel = '';
      if (_has(locName) && _has(townName)) {
        locLabel = '$townName • $locName';
      } else if (_has(townName)) {
        locLabel = townName;
      } else if (_has(locName)) {
        locLabel = locName;
      }

      String priceLabel = '';
      if (isFree || price == '0' || price.toLowerCase() == 'free') {
        priceLabel = 'مجاني';
      } else if (_has(price)) {
        priceLabel = price;
      }

      int? imagesCount;
      try {
        final list = widget.galleryProvider?.galleryList.data;
        if (list != null) {
          imagesCount = list.length;
        }
      } catch (_) {}

      final List<MapEntry<String, String>> specs =
      _extractDetailSpecs(highlight);

      final List<dynamic> earnedBadgesRaw =
          (badgesRemark['earned_badges'] as List?) ?? <dynamic>[];

      final List<String> earnedBadges = earnedBadgesRaw
          .map((dynamic e) {
        if (e is Map) {
          return _s(e['title']);
        }
        return '';
      })
          .where((String e) => e.isNotEmpty)
          .toList();

      final int earnedCount = _toInt(badgesRemark['earned_count']);

      final String tierLabel = () {
        final int tier = _toInt(badgesRemark['tier']);
        if (tier == 3) return 'سوبر';
        if (tier == 2) return 'لُقْطَة';
        if (tier == 1) return 'مميز';
        return '';
      }();

      return Container(
        margin: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12,
          bottom: PsDimens.space12,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: PsDimens.space14,
                      right: PsDimens.space14,
                      top: PsDimens.space14,
                      bottom: PsDimens.space8,
                    ),
                    child: PsHero(
                      tag: widget.heroTagTitle!,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    final Product? product = widget.itemDetail.itemDetail.data;
                    if (product == null) return;
                    _openProductShareOptions(product);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: PsDimens.space8,
                      left: PsDimens.space8,
                      right: PsDimens.space8,
                      bottom: PsDimens.space6,
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: PsColors.activeColor,
                    ),
                  ),
                ),

                // ✅ زر/أيقونة الفافوريت بعد التبسيط
                if (data.addedUserId != '' &&
                    data.addedUserId != psValueHolder.loginUserId)
                  GestureDetector(
                    onTap: () => _onFavouriteTap(data, psValueHolder),
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: PsDimens.space8,
                        left: PsDimens.space8,
                        right: PsDimens.space8,
                        bottom: PsDimens.space6,
                      ),
                      child: Icon(
                        (_isFavourited ?? false)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: PsColors.activeColor,
                      ),
                    ),
                  ),
              ],
            ),            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PsDimens.space2),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.10 * 255).round()),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.blue.withAlpha((0.35 * 255).round()),
                    width: 1,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: PsColors.textColor3,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'تفاصيل المنتج',
                            style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: PsColors.textColor3,
                            ),
                          ),
                        ),
                        if (_has(priceLabel)) ...<Widget>[
                          const SizedBox(width: 8),
                          _chip(
                            text: 'متوسط السعر: $priceLabel',
                            icon: Icons.payments_rounded,
                            bg: const Color(0xFFF7F2DF),
                            fg: const Color(0xFF0F2E57),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),

                    Builder(builder: (_) {
                      final List<Widget> core = <Widget>[
                        if (_has(condition))
                          _chip(
                            text: condition,
                            icon: Icons.verified_rounded,
                            gold: goldCondition,
                            bg: const Color(0xFFF1F7FF),
                            fg: const Color(0xFF0F2E57),
                          ),
                        if (_has(usage))
                          _chip(
                            text: 'استخدام: $usage',
                            icon: Icons.timelapse_rounded,
                            gold: goldUsage,
                            bg: const Color(0xFFF1F7FF),
                            fg: const Color(0xFF0F2E57),
                          ),
                        if (_has(brand))
                          _chip(
                            text: brand,
                            icon: Icons.workspace_premium_rounded,
                            gold: goldBrand,
                            bg: const Color(0xFFEFFAF6),
                            fg: const Color(0xFF0F2E57),
                          ),
                      ];

                      final List<Widget> meta = <Widget>[
                        if (goldImported)
                          _chip(
                            text: 'مستورد',
                            icon: Icons.public_rounded,
                            gold: true,
                            bg: const Color(0xFFEFFAF6),
                            fg: const Color(0xFF0F2E57),
                          ),
                        if (isWrapped)
                          _chip(
                            text: 'مغلف',
                            icon: Icons.inventory_2_rounded,
                            gold: true,
                            bg: const Color(0xFFEFFAF6),
                            fg: const Color(0xFF0F2E57),
                          ),
                        if (isNew)
                          _chip(
                            text: 'جديد',
                            gold: true,
                            icon: Icons.new_releases_rounded,
                            bg: const Color(0xFFEFFAF6),
                            fg: const Color(0xFF0F2E57),
                          ),
                        if (isFree)
                          _chip(
                            text: 'مجاني',
                            icon: Icons.card_giftcard_rounded,
                            gold: true,
                            bg: const Color(0xFFF7F2DF),
                            fg: const Color(0xFF0F2E57),
                          ),
                        if (_has(locLabel))
                          _chip(
                            text: locLabel,
                            icon: Icons.location_on_rounded,
                            bg: const Color(0xFFF1F7FF),
                            fg: const Color(0xFF0F2E57),
                          ),
                        if (imagesCount != null && imagesCount! > 0)
                          _chip(
                            text: '$imagesCount صورة',
                            icon: Icons.photo_library_rounded,
                            bg: const Color(0xFFF1F7FF),
                            fg: const Color(0xFF0F2E57),
                          ),
                      ];

                      final int total = core.length + meta.length;

                      if (total <= 4) {
                        final List<Widget> oneRow = <Widget>[...core, ...meta];
                        return _chipRow(oneRow);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _chipRow(core.isNotEmpty ? core : meta),
                          if (core.isNotEmpty && meta.isNotEmpty)
                            const SizedBox(height: 8),
                          if (core.isNotEmpty && meta.isNotEmpty) _chipRow(meta),
                        ],
                      );
                    }),


                    /* if (specs.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Divider(color: Colors.black.withOpacity(0.06), height: 1),
                      const SizedBox(height: 10),
                      _sectionTitle('البيانات التفصيلية', icon: Icons.tune_rounded),
                      const SizedBox(height: 10),
                      ...specs.map((MapEntry<String, String> e) => _detailRow(
                        title: e.key,
                        value: e.value,
                      )),
                    ],*/

                    if (_has(desc)) ...<Widget>[
                      const SizedBox(height: 12),
                      Divider(color: Colors.black.withOpacity(0.06), height: 1),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: _sectionTitle('الوصف', icon: Icons.notes_rounded),
                          ),
                          if (_has(subCategoryName)) ...<Widget>[
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _chip(
                                  text: subCategoryName,
                                  icon: Icons.category_rounded,
                                  bg: const Color(0xFFF1F7FF),
                                  fg: const Color(0xFF0F2E57),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _descExpanded = !_descExpanded),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              desc,
                              maxLines: _descExpanded ? 12 : 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: PsColors.textColor5,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildShareThemeFeatureCard(data),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
