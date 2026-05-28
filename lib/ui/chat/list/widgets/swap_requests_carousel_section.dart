import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/ui/chat/list/widgets/swap_request_carousel_card.dart';
import 'package:taapdeel/viewobject/chat_history.dart';

import '../../enum/user_type.dart';

class SwapRequestsCarouselSection extends StatefulWidget {
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

  @override
  State<SwapRequestsCarouselSection> createState() =>
      _SwapRequestsCarouselSectionState();
}

class _SwapRequestsCarouselSectionState
    extends State<SwapRequestsCarouselSection> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
  }

  @override
  void didUpdateWidget(covariant SwapRequestsCarouselSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool listChanged = oldWidget.requests.length != widget.requests.length ||
        !_sameIds(oldWidget.requests, widget.requests);

    if (listChanged) {
      final int nextIndex =
      widget.requests.isEmpty ? 0 : _currentIndex.clamp(0, widget.requests.length - 1);

      if (nextIndex != _currentIndex) {
        _currentIndex = nextIndex;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients || widget.requests.isEmpty) {
          return;
        }
        try {
          _pageController.jumpToPage(nextIndex);
        } catch (_) {}
      });
    }
  }

  bool _sameIds(List<ChatHistory> a, List<ChatHistory> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final String aid = _requestStableId(a[i]);
      final String bid = _requestStableId(b[i]);
      if (aid != bid) return false;
    }
    return true;
  }

  String _requestStableId(ChatHistory r) {
    return [
      (r.id ?? '').toString(),
      (r.itemId ?? '').toString(),
      (r.buyerItem ?? '').toString(),
      (r.addedDateStr ?? '').toString(),
    ].join('|');
  }

  void _goNext() {
    if (_currentIndex >= widget.requests.length - 1) return;
    _animateToIndex(_currentIndex + 1);
  }

  void _goPrev() {
    if (_currentIndex <= 0) return;
    _animateToIndex(_currentIndex - 1);
  }

  void _animateToIndex(int index) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }


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

    if (widget.userType == UserType.buyer) {
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

    if (widget.userType == UserType.seller) {
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
      heroTagImage: '${safeProductId.hashCode}$safeProductId${PsConst.HERO_TAG__IMAGE}',
      heroTagTitle: '${safeProductId.hashCode}$safeProductId${PsConst.HERO_TAG__TITLE}',
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
    required int index,
  }) {
    if (_currentIndex != index) {
      _animateToIndex(index);
      return;
    }

    final String productId = _primaryProductIdForRequest(request);
    _openProductDetailsById(context, productId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ChatHistory> requests = widget.requests;

    if (requests.isEmpty) {
      return _EmptyRequestsState(
        title: widget.emptyTitle,
        subtitle: widget.emptySubtitle,
      );
    }

    final int safeIndex = _currentIndex.clamp(0, requests.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[

        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: requests.length,
            onPageChanged: (int index) {
              if (!mounted) return;
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              final ChatHistory request = requests[index];

              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: index == 0 ? 0 : 4,
                  end: index == requests.length - 1 ? 0 : 4,
                ),
                child: SwapRequestCarouselCard(
                  request: request,
                  userType: widget.userType,
                  index: index,
                  totalCount: requests.length,
                  providerS: widget.providerS,
                  providerB: widget.providerB,
                  onTapCard: () => _handleRequestCardTap(
                    context: context,
                    request: request,
                    index: index,
                  ),
                ),
              );
            },
          ),
        ),
        if (requests.length > 1) ...<Widget>[
          const SizedBox(height: 12),
          _BottomNavigator(
            currentIndex: safeIndex,
            total: requests.length,
            onPrev: _goPrev,
            onNext: _goNext,
            onDotTap: _animateToIndex,
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    Key? key,
    required this.title,
    required this.currentIndex,
    required this.total,
  }) : super(key: key);

  final String title;
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7FA),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD3EDF1)),
          ),
          child: Text(
            '${currentIndex + 1}/$total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF0F6E76),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF163F57),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNavigator extends StatelessWidget {
  const _BottomNavigator({
    Key? key,
    required this.currentIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.onDotTap,
  }) : super(key: key);

  final int currentIndex;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    final bool canPrev = currentIndex > 0;
    final bool canNext = currentIndex < total - 1;

    return Column(
      children: <Widget>[
        _DotsIndicator(
          currentIndex: currentIndex,
          total: total,
          onDotTap: onDotTap,
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            _MiniNavButton(
              icon: Icons.chevron_left_rounded,
              enabled: canPrev,
              onTap: onPrev,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'اسحب يمين أو يسار للتنقل بين الطلبات',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5C7389),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _MiniNavButton(
              icon: Icons.chevron_right_rounded,
              enabled: canNext,
              onTap: onNext,
            ),
          ],
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    Key? key,
    required this.currentIndex,
    required this.total,
    required this.onDotTap,
  }) : super(key: key);

  final int currentIndex;
  final int total;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    final int visibleCount = total > 8 ? 8 : total;
    int start = 0;

    if (total > visibleCount) {
      start = currentIndex - (visibleCount ~/ 2);
      if (start < 0) start = 0;
      if (start > total - visibleCount) start = total - visibleCount;
    }

    final int end = start + visibleCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(end - start, (int i) {
        final int actualIndex = start + i;
        final bool selected = actualIndex == currentIndex;

        return GestureDetector(
          onTap: () => onDotTap(actualIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: selected ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: selected
                  ? const LinearGradient(
                colors: <Color>[
                  Color(0xFF1AB8C3),
                  Color(0xFF133D75),
                ],
              )
                  : null,
              color: selected ? null : const Color(0xFFC9DAE3),
            ),
          ),
        );
      }),
    );
  }
}

class _MiniNavButton extends StatelessWidget {
  const _MiniNavButton({
    Key? key,
    required this.icon,
    required this.enabled,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: enabled
                ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF1AB8C3),
                Color(0xFF133D75),
              ],
            )
                : const LinearGradient(
              colors: <Color>[
                Color(0xFFD8E1E8),
                Color(0xFFC5D0D9),
              ],
            ),
            boxShadow: enabled
                ? const <BoxShadow>[
              BoxShadow(
                color: Color(0x220E8FAE),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
                : const <BoxShadow>[],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
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