import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:taapdeel/utils/utils.dart';

enum ProfileTabType { wishlist, family, active, pending, paid, sold, rejected, disabled }

class ProfileHorizontalCardsBar extends StatefulWidget {
  const ProfileHorizontalCardsBar({
    required this.expandedType,
    required this.onTap,
    required this.controller,
    required this.wishCount,
    required this.wishLoading,
    required this.activeCount,
    required this.activeLoading,
    required this.familyCount,
    required this.familyLoading,
    this.familyCountReady = true,
    required this.pendingCount,
    required this.pendingLoading,
    required this.paidCount,
    required this.paidLoading,
    required this.soldCount,
    required this.soldLoading,
    required this.rejectedCount,
    required this.rejectedLoading,
    required this.disabledCount,
    required this.disabledLoading,

    this.wishTotalValue = 0,
    this.familyTotalValue = 0,
    this.activeTotalValue = 0,
    this.pendingTotalValue = 0,
    this.paidTotalValue = 0,
    this.soldTotalValue = 0,
    this.rejectedTotalValue = 0,
    this.disabledTotalValue = 0,

    // ✅ FIX: countReady = false لما البيانات لسه ما اتطلبتش (NOACTION)
    //         الكارد يعرض "·" بدل "0" عشان مش يوهم المستخدم
    this.pendingCountReady = true,
    this.soldCountReady = true,
    this.rejectedCountReady = true,
    this.disabledCountReady = true,
  });

  final ProfileTabType? expandedType;
  final void Function(ProfileTabType type, int index) onTap;
  final ScrollController controller;

  final int wishCount;
  final bool wishLoading;
  final int familyCount;
  final bool familyLoading;
  final bool familyCountReady;
  final int activeCount;
  final bool activeLoading;

  final int pendingCount;
  final bool pendingLoading;

  final int paidCount;
  final bool paidLoading;

  final int soldCount;
  final bool soldLoading;

  final int rejectedCount;
  final bool rejectedLoading;

  final int disabledCount;
  final bool disabledLoading;

  final num wishTotalValue;
  final num familyTotalValue;
  final num activeTotalValue;
  final num pendingTotalValue;
  final num paidTotalValue;
  final num soldTotalValue;
  final num rejectedTotalValue;
  final num disabledTotalValue;

  final bool pendingCountReady;
  final bool soldCountReady;
  final bool rejectedCountReady;
  final bool disabledCountReady;

  @override
  State<ProfileHorizontalCardsBar> createState() => ProfileHorizontalCardsBarState();
}

class ProfileHorizontalCardsBarState extends State<ProfileHorizontalCardsBar> {
  double _progress01 = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ProfileHorizontalCardsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients) return;

    final max = widget.controller.position.maxScrollExtent;
    if (max <= 0) {
      if (_progress01 != 0) setState(() => _progress01 = 0);
      return;
    }

    final p = (widget.controller.position.pixels / max).clamp(0.0, 1.0);
    if ((p - _progress01).abs() > 0.02) {
      setState(() => _progress01 = p);
    }
  }

  String _formatValue(num value) {
    if (value >= 1000000) {
      final v = value / 1000000;
      return v % 1 == 0 ? '${v.toStringAsFixed(0)} مليون' : '${v.toStringAsFixed(1)} مليون';
    }
    if (value >= 1000) {
      final v = value / 1000;
      return v % 1 == 0 ? '${v.toStringAsFixed(0)} ألف' : '${v.toStringAsFixed(1)} ألف';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final raw = <_ColorCardItem>[
      _ColorCardItem(
        type: ProfileTabType.active,
        title: Utils.getString(context, 'profile__listing'),
        count: widget.activeCount,
        totalValue: widget.activeTotalValue,
        isLoading: widget.activeLoading,
        icon: Icons.grid_view_rounded,
        a: const Color(0xFF4F46E5),
        b: const Color(0xFF38BDF8),
      ),
      _ColorCardItem(
        type: ProfileTabType.family,
        title: Utils.getString(context, 'Family_Products'),
        count: widget.familyCount,
        totalValue: widget.familyTotalValue,
        isLoading: widget.familyLoading,
        countReady: widget.familyCountReady,
        icon: Icons.grid_view_rounded,
        a: const Color(0xFFFFC857),
        b: const Color(0xFFFF7A00),
      ),
      _ColorCardItem(
        type: ProfileTabType.wishlist,
        title: Utils.getString(context, 'ownerWishlist'),
        count: widget.wishCount,
        totalValue: widget.wishTotalValue,
        isLoading: widget.wishLoading,
        icon: Icons.favorite_rounded,
        a: const Color(0xFF6EE7B7),
        b: const Color(0xFF12B76A),
      ),
      _ColorCardItem(
        type: ProfileTabType.pending,
        title: Utils.getString(context, 'profile__pending_listing'),
        count: widget.pendingCount,
        totalValue: widget.pendingTotalValue,
        isLoading: widget.pendingLoading,
        countReady: widget.pendingCountReady,
        showWhenEmpty: true, // يظهر دايماً بعد التحميل حتى لو = 0
        icon: Icons.timelapse_rounded,
        a: const Color(0xFF9B5DE5),
        b: const Color(0xFF5F0FDC),
      ),
      _ColorCardItem(
        type: ProfileTabType.paid,
        title: Utils.getString(context, 'profile__paid_ad'),
        count: widget.paidCount,
        totalValue: widget.paidTotalValue,
        isLoading: widget.paidLoading,
        icon: Icons.campaign_rounded,
        a: const Color(0xFFD4AF37),
        b: const Color(0xFF8A6A1F),
      ),
      _ColorCardItem(
        type: ProfileTabType.sold,
        title: Utils.getString(context, 'item_entry__sold_out'),
        count: widget.soldCount,
        totalValue: widget.soldTotalValue,
        isLoading: widget.soldLoading,
        countReady: widget.soldCountReady,
        icon: Icons.check_circle_rounded,
        a: const Color(0xFF14B8A6),
        b: const Color(0xFF67E8F9),
      ),
      _ColorCardItem(
        type: ProfileTabType.rejected,
        title: Utils.getString(context, 'profile__rejected_listing'),
        count: widget.rejectedCount,
        totalValue: widget.rejectedTotalValue,
        isLoading: widget.rejectedLoading,
        countReady: widget.rejectedCountReady,
        icon: Icons.block_rounded,
        a: const Color(0xFFFF4D6D),
        b: const Color(0xFFFF8FA3),
      ),
      _ColorCardItem(
        type: ProfileTabType.disabled,
        title: Utils.getString(context, 'profile__disable_listing'),
        count: widget.disabledCount,
        totalValue: widget.disabledTotalValue,
        isLoading: widget.disabledLoading,
        countReady: widget.disabledCountReady,
        icon: Icons.lock_rounded,
        a: const Color(0xFF64748B),
        b: const Color(0xFFA1A1AA),
      ),
    ];

    // منطق إظهار الكروت:
    // !countReady (NOACTION) → مخفي تماماً لأن البيانات لم تُطلب بعد.
    // isLoading → ظاهر حتى يرى المستخدم أن البيانات يتم تحميلها.
    // count > 0 → ظاهر لأن هناك منتجات.
    // count = 0 + showWhenEmpty → ظاهر فقط للتابات التي نريد ظهورها وهي فارغة مثل pending.
    // count = 0 + !showWhenEmpty → مخفي، وهذا يشمل معرض العائلة لو لا توجد به منتجات.
    final items = raw.where((it) {
      if (!it.countReady) return false;
      if (it.isLoading) return true;
      if (it.count > 0) return true;
      return it.showWhenEmpty;
    }).toList();

    if (items.isEmpty) return const SizedBox.shrink();

    final w = MediaQuery.of(context).size.width;
    final double cardW = (w - 5) / 2.2;
    const double listH = 100;

    return Column(
      children: [
        SizedBox(
          height: listH,
          child: Stack(
            children: [
              ListView.separated(
                controller: widget.controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemBuilder: (ctx, i) {
                  final it = items[i];
                  final bool hasExpanded = widget.expandedType != null;
                  final bool expanded = widget.expandedType == it.type;
                  final bool muted = hasExpanded && !expanded;

                  return SizedBox(
                    width: cardW,
                    child: _ProfileColorCard(
                      title: it.title,
                      count: it.count,
                      countReady: it.countReady,
                      totalValueText: _formatValue(it.totalValue),
                      isLoading: it.isLoading,
                      icon: it.icon,
                      a: it.a,
                      b: it.b,
                      expanded: expanded,
                      muted: muted,
                      onTap: () => widget.onTap(it.type, i),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: items.length,
              ),
              IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withOpacity(0.85),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _MiniDotsIndicator(progress01: _progress01, dotsCount: items.length),
      ],
    );
  }
}

class _ColorCardItem {
  _ColorCardItem({
    required this.type,
    required this.title,
    required this.count,
    required this.totalValue,
    required this.isLoading,
    required this.icon,
    required this.a,
    required this.b,
    this.countReady = true,
    this.showWhenEmpty = false,
  });

  final ProfileTabType type;
  final String title;
  final int count;
  final num totalValue;
  final bool isLoading;
  final IconData icon;
  final Color a;
  final Color b;
  // countReady=false → NOACTION لسه ما اتطلبش → مخفي
  // countReady=true  → اتطلب على الأقل مرة
  final bool countReady;
  // showWhenEmpty=true → يظهر حتى لو count=0 بعد التحميل (زي pending)
  final bool showWhenEmpty;
}

class _ProfileColorCard extends StatelessWidget {
  const _ProfileColorCard({
    required this.title,
    required this.count,
    required this.totalValueText,
    required this.isLoading,
    required this.icon,
    required this.a,
    required this.b,
    required this.expanded,
    required this.onTap,
    required this.muted,
    this.countReady = true,
  });

  final String title;
  final int count;
  // true = عرض الرقم، false = عرض "·" (لسه ما اتحملتش)
  final bool countReady;
  final String totalValueText;
  final bool isLoading;
  final IconData icon;
  final Color a;
  final Color b;
  final bool expanded;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final Color border = expanded
        ? Colors.white.withOpacity(0.65)
        : Colors.white.withOpacity(muted ? 0.18 : 0.35);

    final double contentOpacity = muted ? 0.55 : 1.0;

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [a, b],
        ),
        border: Border.all(color: border, width: expanded ? 1.2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              expanded ? 0.14 : (muted ? 0.03 : 0.08),
            ),
            blurRadius: expanded ? 16 : (muted ? 8 : 12),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Opacity(
        opacity: contentOpacity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(muted ? 0.14 : 0.22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(muted ? 0.16 : 0.25),
                    ),
                  ),
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Text(
                    // ✅ FIX: لو البيانات لسه ما اتطلبتش (NOACTION) نعرض "·"
                    //         بدل "0" عشان مش يوهم المستخدم إن مفيش منتجات
                    countReady ? '$count' : '·',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(muted ? 0.12 : 0.20),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(muted ? 0.14 : 0.25),
                    ),
                  ),
                  child: Text(
                    totalValueText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(muted ? 0.75 : 1.0),
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (muted) {
      card = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: card,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

class _MiniDotsIndicator extends StatelessWidget {
  const _MiniDotsIndicator({required this.progress01, required this.dotsCount});
  final double progress01;
  final int dotsCount;

  @override
  Widget build(BuildContext context) {
    final int n = dotsCount.clamp(1, 7);
    final int active = (progress01 * (n - 1)).round();

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(n, (i) {
          final bool on = i == active;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: on ? 14 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: on ? Colors.blueAccent : Colors.black.withOpacity(0.12),
            ),
          );
        }),
      ),
    );
  }
}
