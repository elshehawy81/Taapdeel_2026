import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taapdeel/utils/perf_benchmark.dart';
import 'package:taapdeel/ui/Foryou/widgets/suggested_swaps_section.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

import '../../constant/ps_constants.dart';
import '../../constant/route_paths.dart';
import '../../viewobject/holder/intent_holder/item_entry_intent_holder.dart';
import '../../viewobject/product.dart';
import '../Contacts/contact_network_provider.dart';
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
      height: MediaQuery.of(context).size.height < 720 ? 96 : 120,
      padding: EdgeInsets.all(MediaQuery.of(context).size.height < 720 ? 8 : 10),
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool compact = screenHeight < 720;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: double.infinity,
          height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFFEAF6FB),
                Color(0xFFF7FCFE),
              ],
            ),
          ),
          child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: 6,
            vertical: compact ? 6 : 10,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, compact ? 0 : _floatAnimation.value),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        compact ? 14 : 18,
                        compact ? 14 : 20,
                        compact ? 14 : 18,
                        compact ? 14 : 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.80),
                        borderRadius: BorderRadius.circular(compact ? 22 : 28),
                        border: Border.all(
                          color: const Color(0xFF79D6E7).withOpacity(0.26),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF79D6E7).withOpacity(0.10),
                            blurRadius: compact ? 18 : 26,
                            spreadRadius: 1,
                            offset: Offset(0, compact ? 8 : 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: compact ? 12 : 18,
                            offset: Offset(0, compact ? 5 : 8),
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
                              width: compact ? 58 : 72,
                              height: compact ? 50 : 60,
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
                                    blurRadius: compact ? 10 : 16,
                                    offset: Offset(0, compact ? 4 : 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(compact ? 10 : 12),
                                child: const Image(
                                  image: AssetImage('assets/images/Taapdeel_icon.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 16),
                          Text(
                            'جاري تجهيز أفضل فرص التبديل',
                            textAlign: TextAlign.center,
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                              fontSize: compact ? 15 : null,
                            ),
                          ),
                          SizedBox(height: compact ? 5 : 8),
                          Text(
                            'بنحلل منتجاتك ونرتب أنسب الفرص حسب السعر والحالة والعلاقات',
                            textAlign: TextAlign.center,
                            maxLines: compact ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall?.copyWith(
                              color: const Color(0xFF5F6B7A),
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              fontSize: compact ? 11 : null,
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 16),
                          Container(
                            height: compact ? 11 : 15,
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
                          SizedBox(height: compact ? 10 : 18),
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
                                width: compact ? 22 : 28,
                                height: compact ? 22 : 28,
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
          ),
        ),
      );
      },
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
  bool _endedForYouFirstOpen = false;

  ContactNetworkProvider? _contactNetworkProvider;
  int _lastHandledContactNetworkVersion = 0;
  int _lastStartedContactSyncAfterRecommendationsVersion = 0;

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

      _scheduleScrollToRecommendations(
        delay: const Duration(milliseconds: 90),
      );
    }

    if (_needsFinalRecommendationScroll && !home.recLoading) {
      _needsFinalRecommendationScroll = false;
      _scheduleScrollToRecommendations(
        delay: const Duration(milliseconds: 140),
      );
    }
  }

  void _finishForYouFirstOpen() {
    if (_endedForYouFirstOpen) return;
    _endedForYouFirstOpen = true;
    TaapdeelPerfBenchmark.end('foryou_first_open_total');
  }

  void _tryStartContactSyncAfterRecommendations(HomeProvider home) {
    if (!_isLoggedIn || !mounted) return;
    if (home.recLoading) return;

    final int version = home.recommendationsFinishedVersion;
    if (version <= 0 ||
        version <= _lastStartedContactSyncAfterRecommendationsVersion) {
      return;
    }

    final String finishedItemId = home.lastRecommendationsFinishedItemId.trim();
    if (finishedItemId.isEmpty) return;

    final ContactNetworkProvider? contactProvider = _contactNetworkProvider;
    if (contactProvider == null) return;

    _lastStartedContactSyncAfterRecommendationsVersion = version;

    Future<void>(() async {
      await contactProvider.startDeferredSyncAfterRecommendations(
        userId: widget.userId,
        reason: 'recommendations_finished',
      );
    });
  }

  void _bindContactNetworkProvider() {
    ContactNetworkProvider? nextProvider;

    try {
      nextProvider = Provider.of<ContactNetworkProvider>(context, listen: false);
    } catch (_) {
      nextProvider = null;
    }

    if (_contactNetworkProvider == nextProvider) return;

    _contactNetworkProvider?.removeListener(_onContactNetworkProviderChanged);
    _contactNetworkProvider = nextProvider;

    // أي تغيير سابق لفتح الصفحة لا يحتاج refresh إضافي؛ الترشيحات الأولى ستقرأ الحالة الحالية.
    _lastHandledContactNetworkVersion =
        nextProvider?.contactNetworkChangeVersion ?? _lastHandledContactNetworkVersion;

    _contactNetworkProvider?.addListener(_onContactNetworkProviderChanged);
  }

  void _onContactNetworkProviderChanged() {
    _tryRefreshRecommendationsAfterContactNetworkChange();
  }

  void _tryRefreshRecommendationsAfterContactNetworkChange() {
    if (!_isLoggedIn || !mounted) return;

    final ContactNetworkProvider? contactProvider = _contactNetworkProvider;
    if (contactProvider == null) return;

    final int version = contactProvider.contactNetworkChangeVersion;
    if (version <= 0 || version <= _lastHandledContactNetworkVersion) return;

    // انتظر notify الأخير بعد انتهاء sync حتى لا نعمل refresh أثناء القراءة/الإرسال.
    if (contactProvider.isSyncing) return;

    final HomeProvider home = HomeProvider.of(context, listen: false);
    if (home.myItemId.trim().isEmpty) {
      // لم يتم اختيار منتج بعد. لا نعلّم النسخة كـ handled حتى نحاول بعد تحميل منتجاتي.
      return;
    }

    _lastHandledContactNetworkVersion = version;

    Future<void>(() async {
      await home.refreshRecommendationsAfterContactNetworkChange(
        contactNetworkVersion: version,
        reason: contactProvider.lastContactNetworkChangeReason,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindContactNetworkProvider();
  }

  @override
  void initState() {
    super.initState();

    // يقيس أول فتح فعلي لـ ForYou مرة واحدة فقط، بدون تكرار مع كل rebuild.
    TaapdeelPerfBenchmark.start('foryou_first_open_total');

    Future.microtask(() {
      final home = HomeProvider.of(context, listen: false);
      if (_isLoggedIn) {
        // ✅ BENCHMARK: وقت جلب منتجات المستخدم من الـ API
        TaapdeelPerfBenchmark.start('foryou_my_products');
        final dynamic myProductResult = home.getMyProduct(widget.userId ?? '');
        if (myProductResult is Future) {
          myProductResult.then((_) {
            TaapdeelPerfBenchmark.end('foryou_my_products');
            _tryRefreshRecommendationsAfterContactNetworkChange();
            TaapdeelPerfBenchmark.printReport();
          }).catchError((_) {
            TaapdeelPerfBenchmark.end('foryou_my_products');
          });
        } else {
          // void — measure using post-frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            TaapdeelPerfBenchmark.end('foryou_my_products');
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _contactNetworkProvider?.removeListener(_onContactNetworkProviderChanged);
    _contentScrollController.dispose();
    super.dispose();
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
    _tryStartContactSyncAfterRecommendations(home);

    // أول مرة تظهر نتيجة ForYou، انتهي من قياس الفتح الأول مرة واحدة فقط.
    if (hasMyProducts || (!home.myProductLoading && !hasMyProducts)) {
      _finishForYouFirstOpen();
    }

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
                Builder(builder: (ctx) {
                  // ✅ BENCHMARK: وقت بناء قسم الـ swap recommendations
                  TaapdeelPerfBenchmark.start('foryou_swaps_render');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    TaapdeelPerfBenchmark.end('foryou_swaps_render');
                  });
                  return SuggestedSwapsSection(
                    key: const ValueKey('suggested_swaps'),
                    homeProvider: home,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeProvider home = HomeProvider.of(context);

    return TaapdeelScaffold(
      padding: const EdgeInsets.all(10),
      safeBottom: true,
      body: !_isLoggedIn
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
    );
  }
}
