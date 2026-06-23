import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/ui/chat/list/widgets/swap_request_carousel_card.dart';
import 'package:taapdeel/viewobject/chat_history.dart';

import '../../enum/user_type.dart';

class SwapRequestsCarouselSection extends StatelessWidget {
  const SwapRequestsCarouselSection({
    Key? key,
    required this.requests,
    required this.userType,
    this.providerS,
    this.providerB,
    this.sectionTitle,
    this.emptyTitle = 'لا توجد طلبات لهذا المنتج',
    this.emptySubtitle = 'اختر منتجًا آخر أو غيّر الفلتر لعرض طلبات مختلفة',
    this.height = 420,
  }) : super(key: key);

  final List<ChatHistory> requests;
  final UserType userType;
  final dynamic providerS;
  final dynamic providerB;
  final String? sectionTitle;
  final String emptyTitle;
  final String emptySubtitle;
  final double height;

  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _productIdFromDynamic(dynamic value) {
    if (value == null) return '';

    if (value is Product) {
      return _safeString(value.id);
    }

    try {
      final dynamic id = value.id;
      final String parsed = _safeString(id);
      if (parsed.isNotEmpty && parsed != 'null') return parsed;
    } catch (_) {}

    final String asText = _safeString(value);
    if (asText.isEmpty || asText == 'null') return '';
    return asText;
  }

  String _primaryProductIdForRequest(ChatHistory request) {
    final dynamic d = request;

    if (userType == UserType.buyer) {
      final List<dynamic Function()> buyerCandidates = <dynamic Function()>[
            () => d.buyerItem,
            () => d.buyerProduct,
            () => d.buyerItemProduct,
            () => d.buyer_item,
            () => d.buyerItemId,
            () => d.buyerItemIdStr,
      ];

      for (final dynamic Function() read in buyerCandidates) {
        try {
          final String id = _productIdFromDynamic(read());
          if (id.isNotEmpty) return id;
        } catch (_) {}
      }
    }

    final List<dynamic Function()> sellerCandidates = <dynamic Function()>[
          () => d.item,
          () => d.product,
          () => d.itemProduct,
          () => d.sellerItem,
          () => d.sellerProduct,
          () => d.itemId,
    ];

    for (final dynamic Function() read in sellerCandidates) {
      try {
        final String id = _productIdFromDynamic(read());
        if (id.isNotEmpty) return id;
      } catch (_) {}
    }

    if (userType == UserType.seller) {
      try {
        final String id = _productIdFromDynamic(d.buyerItem);
        if (id.isNotEmpty) return id;
      } catch (_) {}
    }

    return '';
  }

  void _openProductDetailsById(BuildContext context, String productId) {
    final String safeProductId = productId.trim();
    if (safeProductId.isEmpty) return;

    final ProductDetailIntentHolder holder = ProductDetailIntentHolder(
      productId: safeProductId,
      heroTagImage:
      '${safeProductId.hashCode}$safeProductId${PsConst.HERO_TAG__IMAGE}',
      heroTagTitle:
      '${safeProductId.hashCode}$safeProductId${PsConst.HERO_TAG__TITLE}',
    );

    Navigator.pushNamed(
      context,
      RoutePaths.productDetail,
      arguments: holder,
    );
  }

  void _handleRequestCardTap({
    required BuildContext context,
    required ChatHistory request,
  }) {
    final String productId = _primaryProductIdForRequest(request);
    _openProductDetailsById(context, productId);
  }

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return _EmptyRequestsState(
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    final String title = (sectionTitle ?? '').trim().isEmpty
        ? 'طلبات المنتج المختار'
        : sectionTitle!.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SectionHeader(
            title: title,
            total: requests.length,
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Column(
              key: ValueKey<String>(_requestsKey(requests)),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List<Widget>.generate(requests.length, (int index) {
                final ChatHistory request = requests[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == requests.length - 1 ? 0 : 12,
                  ),
                  child: SizedBox(
                    height: height,
                    child: SwapRequestCarouselCard(
                      request: request,
                      userType: userType,
                      index: index,
                      totalCount: requests.length,
                      providerS: providerS,
                      providerB: providerB,
                      onTapCard: () => _handleRequestCardTap(
                        context: context,
                        request: request,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _requestsKey(List<ChatHistory> list) {
    return list.map((ChatHistory r) {
      return <String>[
        (r.id ?? '').toString(),
        (r.itemId ?? '').toString(),
        (r.buyerItem ?? '').toString(),
        (r.addedDateStr ?? '').toString(),
      ].join('|');
    }).join('::');
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    Key? key,
    required this.title,
    required this.total,
  }) : super(key: key);

  final String title;
  final int total;

  String _countText() {
    if (total <= 1) return 'طلب واحد';
    if (total == 2) return 'طلبان';
    return '$total طلبات';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 9, 10, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: <Color>[
            Color(0xFF0A7EA0),
            Color(0xFF0A7EA0),
            Color(0xFFB8F4FF),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFB8F4FF),
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    height: 1.1,
                  ),
                ),
                if (total > 1) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'اسحب لفوق لمراجعة كل الطلبات على نفس المنتج',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.86),
                      fontWeight: FontWeight.w800,
                      fontSize: 10.4,
                      height: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 31,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              _countText(),
              maxLines: 1,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF0C587A),
                fontWeight: FontWeight.w900,
                fontSize: 10.8,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRequestsState extends StatelessWidget {
  const _EmptyRequestsState({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD7E8EE),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7FA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFD3EDF1),
              ),
            ),
            child: const Icon(
              Icons.swap_horizontal_circle_outlined,
              color: Color(0xFF149EB7),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF163F57),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6A7F8F),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
