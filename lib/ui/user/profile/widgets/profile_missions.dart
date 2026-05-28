import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_info_card_shell.dart';

class _MissionStepModel {
  const _MissionStepModel({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.icon,
    required this.onTap,
    this.progress, // 0..1
    this.progressText, // مثلا "3/10" أو "250/500"
    this.showProgressWhenClosed = true,
  });

  final String title;
  final String subtitle;
  final String cta;
  final IconData icon;
  final VoidCallback onTap;
  final double? progress;
  final String? progressText;
  final bool showProgressWhenClosed;
}

class _MissionGroupModel {
  const _MissionGroupModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.steps,
    required this.shouldShow,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color accent;
  final List<_MissionStepModel> steps;

  /// condition to show this group
  final bool Function() shouldShow;
}

class MissionGroupsSection extends StatefulWidget {
  const MissionGroupsSection({
    required this.productsCount,
    required this.wishCount,
    required this.following,
    required this.followers,
    required this.onTapAddWish,
    required this.onTapAddProduct,
    required this.onTapDiscoverFriends,
    required this.onTapBoost,
    required this.onTapHot,
    required this.onTapSafe,
    required this.onTapShare,
    required this.points,
    required this.swapsDone,
    required this.laktaProductsCount,
  });

  final int productsCount;
  final int laktaProductsCount;
  final int wishCount;
  final int following;
  final int followers;
  final int points;
  final int swapsDone;

  final VoidCallback onTapAddWish;
  final VoidCallback onTapAddProduct;
  final VoidCallback onTapDiscoverFriends;

  final VoidCallback onTapBoost;
  final VoidCallback onTapHot;
  final VoidCallback onTapSafe;
  final VoidCallback onTapShare;

  @override
  State<MissionGroupsSection> createState() => _MissionGroupsSectionState();
}

class _MissionGroupsSectionState extends State<MissionGroupsSection> {
  // ✅ لكل Group مفتاح step المفتوح (أو null يعني كله مقفول)
  final Map<String, String?> _openStepByGroup = <String, String?>{};

  // ✅ keys for each step per group (to locate step)
  final Map<String, List<GlobalKey>> _stepKeysByGroup =
  <String, List<GlobalKey>>{};

  // ✅ ScrollController لكل Group (عشان نسكرول جوّا الكارد مش الصفحة)
  final Map<String, ScrollController> _stepScrollByGroup =
  <String, ScrollController>{};

  // ✅ Carousel
  late final PageController _pageController;
  int _currentPage = 0;

  List<GlobalKey> _keysFor(String groupId, int len) {
    final existing = _stepKeysByGroup[groupId];
    if (existing != null && existing.length == len) return existing;

    final keys =
    List<GlobalKey>.generate(len, (_) => GlobalKey(), growable: false);
    _stepKeysByGroup[groupId] = keys;
    return keys;
  }

  ScrollController _controllerForGroup(String groupId) {
    return _stepScrollByGroup.putIfAbsent(groupId, () => ScrollController());
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _stepScrollByGroup.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MissionGroupsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  /// ✅ 3 Groups ظاهرين دايمًا (Carousel)
  List<_MissionGroupModel> _visibleGroups() {
    return <_MissionGroupModel>[
      // ==============================
      // ✅ Group 1 (Onboarding)
      // ==============================
      _MissionGroupModel(
        id: 'welcome',
        title: '✨ أهلاً بك في تبديل',
        subtitle: 'اكتشف كنوزك وكنوز اصدقاءك.',
        accent: const Color(0xFF9CA3AF), // Beige premium
        shouldShow: () => widget.productsCount <= 5, // ✅ دايمًا ظاهر في الكاروسيل
        steps: [
          _MissionStepModel(
            title: 'اختر منتجات تتمناها',
            subtitle: 'الرغبات بتساعدنا نرشّح لك تبديلات مناسبة.\n'
                'احصل على 50 نقطه لكل رغبه.',
            cta: 'أضف رغباتك',
            icon: Icons.favorite_rounded,
            onTap: widget.onTapAddWish,
            progress: (widget.wishCount / 5).clamp(0.0, 1.0),
            progressText: '${widget.wishCount}/5',
          ),
          _MissionStepModel(
            title: ' اضف منتجاتك للتبديل',
            subtitle: 'اضف منتجاتك بسهوله (AI) .\n'
                'استهدف 10 منتجات كبداية لتزيد فرص المطابقة والتبديل لخوارزمية الترشيح .',
            cta: 'أضف منتج',
            icon: Icons.add_box_rounded,
            onTap: widget.onTapAddProduct,
            progress: (widget.productsCount / 5).clamp(0.0, 1.0),
            progressText: '${widget.productsCount}/5',
          ),
        ],
      ),

      // ==============================
      // ✅ Group 2 (Boost visibility)
      // ==============================
      _MissionGroupModel(
        id: 'boost_visibility',
        title: '🚀 تبديل أسرع',
        subtitle: 'ارفع فرص التبديل بخطوات بسيطة.',
        accent: const Color(0xFFFFC36A), // Light orange
        shouldShow: () => widget.followers <=5,
        steps: [
          _MissionStepModel(
            title: 'اضف منتجات مميزة/لُقْطَة',
            subtitle: 'المنتجاتك المميزة تحصل علي افضل العروض \n'
                'منتج مميز بيكون فيه على الاقل 3 خصائص\n(حاله مميزة,استعمال قليل , مستورد ,براند , مغلف , مجاني).',
            cta: 'أضف منتج مميز',
            icon: Icons.local_fire_department_rounded,
            onTap: widget.onTapAddProduct,
            progress: (widget.laktaProductsCount / 5).clamp(0.0, 1.0),
            progressText: '${widget.laktaProductsCount}/5',
            // progress: (widget.swapsDone / 5).clamp(0.0, 1.0),
            // progressText: 'منتجات لقطة ${widget.swapsDone}/5',
          ),
          _MissionStepModel(
            title: 'شارك حسابك',
            subtitle: 'لينك واحد ممكن يجيب لك متابعين وتبديلات كثيرة.\n'
                'شارك بروفايلك مع صحابك/العيلة أو على السوشيال واحصل على متابعين اكثر',
            cta: 'شارك',
            icon: Icons.share_rounded,
            onTap: widget.onTapShare,
            progress: (widget.followers / 5).clamp(0.0, 1.0),
            progressText: ' المتابعين ${widget.followers}/5',
          ),
          /*_MissionStepModel(
            title: 'صفقات تبديل ناجحة',
            subtitle:
            '3 صفقات تبديل ناجحة تحسن ظهور منتجاتك فى صفحات البحث والترشيحات',
            cta: 'كمّل منتجاتك',
            icon: Icons.rocket_launch_rounded,
            onTap: widget.onTapBoost,
            progress: (widget.swapsDone / 3).clamp(0.0, 1.0),
            progressText: 'صفقات ناجحة ${widget.swapsDone}/3',
          ),*/
        ],
      ),

      // ==============================
      // ✅ Group 3 (Grow social)
      // ==============================
      _MissionGroupModel(
        id: 'grow_social',
        title: '✨مميزات Premium',
        subtitle: 'المتابعين = عروض أكثر = تبديلات أسرع.',
        accent: const Color(0xFFD4AF37), // Sky
        shouldShow: () => true,
        steps: [
          _MissionStepModel(
            title: 'ترويج مجاني',
            subtitle:
            'استبدل 500 نقطه واحصل على ترويج مجاني لواحد من منتجاتك لمده 3 ايام لاهم الترشيحات',
            cta: 'ترويج مجاني',
            icon: Icons.verified_user_rounded,
            onTap: widget.onTapSafe,
            progress: (widget.points / 500).clamp(0.0, 1.0),
            progressText: '${widget.points}/500',
          ),
          _MissionStepModel(
            title: 'اشتراك مجاني',
            subtitle:
            'استبدل 1000 نقطه واحصل على اشتراك مجاني لعدد لا نهائي من التبديلات لمده شهرين',
            cta: 'اشتراك مجاني',
            icon: Icons.person_add_alt_1_rounded,
            onTap: widget.onTapBoost,
            progress: (widget.points / 1000).clamp(0.0, 1.0),
            progressText: '${widget.points}/1000',
          ),
          /*_MissionStepModel(
            title: 'اعلان مميز',
            subtitle:
            'ترقيه لمنتجاتك بحيث تظهر كاعلان مميز فى الصفحات الاولي للبحث والترشيحات.',
            cta: ' ',
            icon: Icons.auto_awesome_rounded,
            onTap: widget.onTapBoost,
          ),*/
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final groups = _visibleGroups().where((g) => g.shouldShow()).toList();
    if (groups.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 315,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: groups.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i); // ✅ مهم عشان الـ indicator يحدث
            },
            itemBuilder: (context, index) {
              final group = groups[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildGroupCard(context, group),
              );
            },
          ),

          // ✅ Fade على الشمال واليمين (يوضح ان فيه سحب)
          if (groups.length > 1) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: IgnorePointer(
                child: Container(
                  width: 22,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withOpacity(0.55),
                        Colors.white.withOpacity(0)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IgnorePointer(
                child: Container(
                  width: 22,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.white.withOpacity(0.55),
                        Colors.white.withOpacity(0)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ✅ Dots تحت
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _CarouselDots(
                count: groups.length,
                index: _currentPage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, _MissionGroupModel group) {
    final Color accent = group.accent;

    final Color g1 = accent.withOpacity(0.14);
    final Color g2 = accent.withOpacity(0.08);

    final String groupId = group.id;
    final String? openKey = _openStepByGroup[groupId];

    // ✅ controller خاص بالـListView جوّا الكارد
    final ScrollController listC = _controllerForGroup(groupId);

    return TaapdeelInfoCardShell(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      withBlur: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              g1,
              g2,
              Colors.white.withOpacity(0.60),
            ],
            stops: const <double>[0.0, 0.55, 1.0],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.55)),
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              group.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black.withOpacity(0.58),
                fontWeight: FontWeight.w700,
                height: 1.18,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 12),

            // Steps list
            Expanded(
              child: ListView.separated(
                controller: listC, // ✅ مهم: ده اللي يمنع الصفحة تتحرك
                padding: const EdgeInsets.only(bottom: 14),
                physics: const BouncingScrollPhysics(),
                itemCount: group.steps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final s = group.steps[i];
                  final String keyStr = '${group.id}_$i';
                  final bool open = openKey == keyStr;

                  const bool locked = false;

                  final stepKeys = _keysFor(groupId, group.steps.length);
                  final GlobalKey stepKey = stepKeys[i];

                  return Container(
                    key: stepKey,
                    child: _MissionStepCard(
                      index: i + 1,
                      total: group.steps.length,
                      accent: accent,
                      open: open,
                      locked: locked,
                      title: s.title,
                      subtitle: s.subtitle,
                      cta: s.cta,
                      icon: s.icon,
                      progress: s.progress,
                      progressText: s.progressText,
                      showProgressWhenClosed: s.showProgressWhenClosed,
                      onTapHeader: () {
                        setState(() {
                          _openStepByGroup[groupId] = (open ? null : keyStr);
                        });

                        // ✅ بعد الفتح، اسكرول جوّا ListView بتاع الكارد (مش الصفحة)
                        if (!open) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            if (!listC.hasClients) return;

                            final BuildContext? stepCtx =
                                stepKey.currentContext;
                            if (stepCtx == null) return;

                            final RenderBox stepBox =
                            stepCtx.findRenderObject() as RenderBox;

                            // أقرب RenderObject للـListView
                            final RenderBox listBox =
                            listC.position.context.storageContext
                                .findRenderObject() as RenderBox;

                            final Offset stepInList = stepBox.localToGlobal(
                              Offset.zero,
                              ancestor: listBox,
                            );

                            const double topPadding = 12;
                            final double target = (listC.offset +
                                stepInList.dy -
                                topPadding)
                                .clamp(
                              0.0,
                              listC.position.maxScrollExtent,
                            );

                            listC.animateTo(
                              target,
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            );
                          });
                        }
                      },
                      onTapCta: s.onTap,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionStepCard extends StatelessWidget {
  const _MissionStepCard({
    required this.index,
    required this.total,
    required this.accent,
    required this.open,
    required this.locked,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.icon,
    required this.onTapHeader,
    required this.onTapCta,
    this.progress,
    this.progressText,
    this.showProgressWhenClosed = true,
  });

  final Color accent;
  final bool open;
  final bool locked;

  final String title;
  final String subtitle;
  final String cta;
  final IconData icon;

  final VoidCallback onTapHeader;
  final VoidCallback? onTapCta;

  final double? progress;
  final String? progressText;
  final bool showProgressWhenClosed;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final double? p = progress?.clamp(0.0, 1.0);
    final bool progressDone = (p != null && p >= 1.0);

    // ✅ أخضر بسيط
    const Color doneGreen = Color(0xFF22C55E);

    // ✅ لون الـprogress حسب الحالة
    final Color progressColor =
    progressDone ? doneGreen.withOpacity(0.70) : accent.withOpacity(0.70);

    final bool showClosedProgress =
        !open && !locked && showProgressWhenClosed && p != null;

    final Color border =
    open ? accent.withOpacity(0.28) : Colors.black.withOpacity(0.06);

    final double opacity = locked ? 0.55 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapHeader,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.90),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: open ? 1.2 : 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(open ? 0.07 : 0.04),
                  blurRadius: open ? 18 : 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withOpacity(0.18)),
                      ),
                      child: Icon(icon, size: 16, color: accent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withOpacity(0.88),
                          height: 1.12,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      turns: open ? 0.5 : 0.0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: Colors.black.withOpacity(0.40),
                      ),
                    ),
                  ],
                ),
                if (showClosedProgress) ...[
                  _MiniProgressBar(
                    value01: p!,
                    barColor: progressColor,
                    text: progressText,
                  ),
                ],
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _expandedBody(context),
                  ),
                  crossFadeState:
                  open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                  sizeCurve: Curves.easeOutCubic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _expandedBody(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black.withOpacity(0.78),
              fontWeight: FontWeight.w700,
              height: 1.23,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: onTapCta,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: onTapCta == null
                      ? Colors.black.withOpacity(0.06)
                      : accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: onTapCta == null
                        ? Colors.black.withOpacity(0.10)
                        : accent.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: onTapCta == null
                          ? Colors.black.withOpacity(0.35)
                          : accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cta,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black.withOpacity(
                          onTapCta == null ? 0.45 : 0.86,
                        ),
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  const _MiniProgressBar({
    required this.value01,
    required this.barColor,
    this.text,
  });

  final double value01;
  final Color barColor;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value01.clamp(0.04, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (text != null && text!.trim().isNotEmpty) ...[
          const SizedBox(width: 10),
          Text(
            text!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.black.withOpacity(0.55),
              height: 1,
            ),
          ),
        ],
      ],
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final on = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: on ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: on ? Colors.blueAccent : Colors.black.withOpacity(0.18),
          ),
        );
      }),
    );
  }
}
