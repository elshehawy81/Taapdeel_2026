import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/ui/Foryou/widgets/suggested_swaps_section.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

import '../../constant/ps_constants.dart';
import '../../constant/route_paths.dart';
import '../../viewobject/holder/intent_holder/item_entry_intent_holder.dart';
import '../../viewobject/product.dart';
import '../common/taapdeel/taapdeel_button.dart';
import 'home_provider.dart';

bool showContactUser = true;

class _MyProductsHintCard extends StatelessWidget {
  const _MyProductsHintCard({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.70)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1D4ED8).withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF1D4ED8).withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'للحصول على أفضل ترشيحات التبديل لمنتجاتك',
                  style: t.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ضيف أول منتج علشان نعرض لك أفضل فرص تبديل حسب اهتماماتك.',
                  style: t.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0xFF1AB8C3),
                          Color(0xFF133D75),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'أضف منتج الآن',
                      style: t.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
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

// =============================================================
// _RecommendationLoadingCard
// =============================================================
class _RecommendationLoadingCard extends StatefulWidget {
  const _RecommendationLoadingCard();

  @override
  State<_RecommendationLoadingCard> createState() =>
      _RecommendationLoadingCardState();
}

class _RecommendationLoadingCardState extends State<_RecommendationLoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _miniCard({
    required BuildContext context,
    required bool isMine,
    required String topLabel,
    required String bottomLabel,
  }) {
    final Color cardTextColor = isMine ? const Color(0xFF163F57) : Colors.white;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isMine
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFEAFBFF),
            Color(0xFFD2F4FB),
          ],
        )
            : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF1AB8C3),
            Color(0xFF133D75),
          ],
        ),
        border: Border.all(
          color: isMine
              ? const Color(0xFFD8EFE2)
              : Colors.white.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            topLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cardTextColor,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: isMine
                    ? Colors.white.withOpacity(0.82)
                    : Colors.white.withOpacity(0.12),
                border: Border.all(
                  color: isMine
                      ? const Color(0xFFD8EFE2)
                      : Colors.white.withOpacity(0.16),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) {
                        return Opacity(
                          opacity: 0.18 + (_progressAnimation.value * 0.16),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Color(0xFFEAFBFF),
                                  Color(0xFFBDEBF5),
                                  Color(0xFF79D6E7),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.image_search_rounded,
                      color: isMine
                          ? const Color(0xFF79D6E7)
                          : Colors.white70,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isMine
                  ? Colors.white.withOpacity(0.84)
                  : Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isMine
                    ? const Color(0xFFCDEAD9)
                    : Colors.white.withOpacity(0.22),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              bottomLabel,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cardTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.80),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF79D6E7).withOpacity(0.26),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF79D6E7).withOpacity(0.10),
                      blurRadius: 26,
                      spreadRadius: 1,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFFF9FEFF),
                      Color(0xFFF2FBFC),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 72,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              Color(0xFFE9FBFC),
                              Color(0xFFD8F8F6),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF79D6E7).withOpacity(0.20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF79D6E7).withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Image(
                            image: AssetImage('assets/images/Taapdeel_icon.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري تجهيز أفضل فرص التبديل',
                      textAlign: TextAlign.center,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'بنحلل منتجاتك ونرتب أنسب الفرص حسب السعر والحالة والعلاقات',
                      textAlign: TextAlign.center,
                      style: t.bodySmall?.copyWith(
                        color: const Color(0xFF5F6B7A),
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 15,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F4F6),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFCBEEF1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.24 + (_progressAnimation.value * 0.60),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: <Color>[
                                    Color(0xFFEAFBFF),
                                    Color(0xFFBDEBF5),
                                    Color(0xFF79D6E7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _miniCard(
                            context: context,
                            isMine: true,
                            topLabel: 'منتجك',
                            bottomLabel: 'جاري تحليل التفاصيل',
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset(
                            'assets/images/Taapdeel_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _miniCard(
                            context: context,
                            isMine: false,
                            topLabel: 'أفضل فرص التبديل',
                            bottomLabel: 'مطابقة السعر والحالة',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================
// HomeViewWidget
// =============================================================
class HomeViewWidget extends StatefulWidget {
  const HomeViewWidget(
      this.context,
      this.userId,
      );

  final BuildContext context;
  final String? userId;

  @override
  _HomeViewWidgetState createState() => _HomeViewWidgetState();
}

class _HomeViewWidgetState extends State<HomeViewWidget> {
  bool get _isLoggedIn => widget.userId != null && widget.userId!.isNotEmpty;

  final ScrollController _contentScrollController = ScrollController();
  final GlobalKey _recommendationsAnchorKey = GlobalKey();

  String? _lastSelectedProductIdForAutoScroll;
  bool _needsFinalRecommendationScroll = false;

  String _productId(Product? product) {
    return (product?.id ?? '').toString().trim();
  }

  void _scheduleScrollToRecommendations({
    Duration delay = const Duration(milliseconds: 80),
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }

      if (!mounted) return;

      final BuildContext? anchorContext =
          _recommendationsAnchorKey.currentContext;
      if (anchorContext == null) return;

      await Scrollable.ensureVisible(
        anchorContext,
        alignment: 0.0,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _handleAutoScrollAfterProductSelection(HomeProvider home) {
    final String selectedProductId = _productId(home.myProduct);

    if (selectedProductId.isEmpty) {
      _lastSelectedProductIdForAutoScroll = null;
      _needsFinalRecommendationScroll = false;
      return;
    }

    if (selectedProductId != _lastSelectedProductIdForAutoScroll) {
      _lastSelectedProductIdForAutoScroll = selectedProductId;
      _needsFinalRecommendationScroll = true;

      // Scroll immediately to the recommendation area, even while loading.
      _scheduleScrollToRecommendations(
        delay: const Duration(milliseconds: 90),
      );
    }

    // When recommendations finish loading, scroll again so the final section
    // starts at the top of the page after its real height/content is rendered.
    if (_needsFinalRecommendationScroll && !home.recLoading) {
      _needsFinalRecommendationScroll = false;
      _scheduleScrollToRecommendations(
        delay: const Duration(milliseconds: 140),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final home = HomeProvider.of(context, listen: false);
      if (_isLoggedIn) {
        home.getMyProduct(widget.userId ?? '');
      }
    });
  }

  @override
  void dispose() {
    _contentScrollController.dispose();
    super.dispose();
  }

  Widget? _buildBottomBar(BuildContext context, HomeProvider home) {
    final bool canSubmit = home.canSubmitSwap;
    final bool isPending = home.isMyProductPending;

    final String helperText = isPending
        ? 'منتجك لسه في انتظار موافقة الأدمن'
        : 'اختر منتجك ومنتج للتبديل أولاً';

    if (!canSubmit) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isPending
                    ? const Color(0xFFF59E0B).withOpacity(0.28)
                    : const Color(0xFFD7E6EE),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPending
                      ? Icons.hourglass_top_rounded
                      : Icons.info_outline_rounded,
                  size: 13,
                  color: isPending
                      ? const Color(0xFFF59E0B)
                      : PsColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    helperText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPending
                          ? const Color(0xFFF59E0B)
                          : PsColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.8,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
        child: IgnorePointer(
          ignoring: home.isSubmitting,
          child: Opacity(
            opacity: home.isSubmitting ? 0.55 : 1.0,
            child: TaapdeelButton(
              label: home.isSubmitting ? 'جاري الإرسال...' : 'اطلب التبديل',
              onPressed: () async {
                final HomeProvider homeProvider =
                HomeProvider.of(context, listen: false);

                final Product? requestedProduct =
                    homeProvider.selectedSwapProduct;

                try {
                  await homeProvider.submitSwap(context: context);
                } catch (_) {
                  return;
                }

                if (!context.mounted || requestedProduct == null) {
                  return;
                }

                notifySuggestedSwapRequestSent(
                  context: context,
                  requestedProduct: requestedProduct,
                );
              },
              isPrimary: true,
              isExpanded: true,
              outlined: false,
              height: 40,
            ),
          ),
        ),
      ),
    );
  }

  void _goToAddItem() {
    Navigator.pushNamed(
      context,
      RoutePaths.itemEntry,
      arguments: ItemEntryIntentHolder(
        flag: PsConst.ADD_NEW_ITEM,
        item: Product(),
      ),
    );
  }

  Widget _buildLoggedInContent(HomeProvider home) {
    final bool hasMyProducts = home.myProducts.isNotEmpty;

    _handleAutoScrollAfterProductSelection(home);

    if (home.myProductLoading && !hasMyProducts) {
      return const _RecommendationLoadingCard();
    }

    if (!hasMyProducts) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _MyProductsHintCard(
              onAdd: _goToAddItem,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _contentScrollController,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                KeyedSubtree(
                  key: _recommendationsAnchorKey,
                  child: const SizedBox.shrink(),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: home.recLoading
                      ? const Padding(
                    key: ValueKey('recommendation_loading'),
                    padding: EdgeInsets.only(top: 24),
                    child: RepaintBoundary(
                      child: _RecommendationLoadingCard(),
                    ),
                  )
                      : SuggestedSwapsSection(
                    key: const ValueKey('suggested_swaps'),
                    homeProvider: home,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = HomeProvider.of(context);

    final bool showStickySwapButton = _isLoggedIn && home.myProducts.isNotEmpty;
    final double bottomBodyPadding = showStickySwapButton ? 0.0 : 0.0;

    return TaapdeelScaffold(
      padding: const EdgeInsets.all(10),
      safeBottom: true,
      bottom: showStickySwapButton ? _buildBottomBar(context, home) : null,
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomBodyPadding),
        child: !_isLoggedIn
            ? Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _MyProductsHintCard(
                onAdd: _goToAddItem,
              ),
            ),
          ),
        )
            : _buildLoggedInContent(home),
      ),
    );
  }
}
