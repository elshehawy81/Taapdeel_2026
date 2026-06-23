import 'dart:async';
import 'package:taapdeel/utils/perf_benchmark.dart';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../config/ps_config.dart';
import '../../constant/ps_constants.dart';
import '../../constant/route_paths.dart';
import '../../db/common/ps_shared_preferences.dart';
import '../common/ps_ui_widget.dart';
import '../common/taapdeel/taapdeel_glass_bottom_sheet.dart';
import 'contact_network_provider.dart';
import 'pending_follows_cache.dart';
import 'user_phone_model.dart';

class ContactNetworkBottomSheet {
  static const String _introSeenKey = 'taapdeel_contact_network_intro_seen';

  static Future<void> show(BuildContext context) async {
    // ✅ BENCHMARK: وقت فتح وإغلاق bottom sheet الكونتاكتس كاملاً
    TaapdeelPerfBenchmark.start('contact_sheet_open');
    HapticFeedback.selectionClick();

    final ContactNetworkProvider provider = context.read<ContactNetworkProvider>();
    final bool introSeen = PsSharedPreferences.instance.shared.getBool(_introSeenKey) ?? false;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.46),
      builder: (_) => ChangeNotifierProvider<ContactNetworkProvider>.value(
        value: provider,
        child: _ContactNetworkUnifiedSheet(introSeen: introSeen),
      ),
    );
  }
}

class _ContactNetworkUnifiedSheet extends StatefulWidget {
  const _ContactNetworkUnifiedSheet({required this.introSeen});

  final bool introSeen;

  @override
  State<_ContactNetworkUnifiedSheet> createState() => _ContactNetworkUnifiedSheetState();
}

class _ContactNetworkUnifiedSheetState extends State<_ContactNetworkUnifiedSheet> {
  late final PageController _controller;
  late bool _showContacts;
  bool _loadingContacts = false;
  int _index = 0;

  static const List<_IntroPageData> _pages = <_IntroPageData>[
    _IntroPageData(
      title: 'أضف أصدقاءك وأقاربك',
      subtitle: 'بدّل بثقة مع دائرتك القريبة',
      imageAsset: 'assets/images/friends_network.png',
      accent: _C.appNavy,
      accent2: _C.appTeal,
      soft: _C.softTeal,
      cta: 'صفحة تعريفية 2/2',
      features: <_IntroFeatureData>[
        _IntroFeatureData(
          icon: Icons.verified_user_rounded,
          title: 'ترشيحات أفضل',
          description: 'ترشيحات أفضل \nوتبديل أكثر ثقة وأمانًا.',
          accent: _C.premiumGold,
          accent2: _C.premiumGold2,
          soft: _C.softGold,
        ),
        _IntroFeatureData(
          icon: Icons.inventory_2_rounded,
          title: 'معرض منتجات مميز',
          description: 'استعرض منتجات العائلة والأصدقاء واختر الأفضل لك.',
          accent: _C.featureBlue,
          accent2: _C.featureBlue2,
          soft: _C.softFeatureBlue,
        ),
      ],
    ),
    _IntroPageData(
      title: 'أضف أفراد عائلتك',
      subtitle: 'أب/أم • ابن/ابنة • زوج/زوجة • أخ/أخت',
      imageAsset: 'assets/images/family_network.png',
      accent: _C.appNavy,
      accent2: _C.appTeal,
      soft: _C.softTeal,
      cta: 'اكتشف منتجات العائلة والأصدقاء',
      features: <_IntroFeatureData>[
        _IntroFeatureData(
          icon: Icons.favorite_rounded,
          title: 'ترشيحات مناسبة لعائلتك',
          description: 'نقدم ترشيحات مناسبة لعائلتك.',
          accent: _C.featurePurple,
          accent2: _C.featurePurple2,
          soft: _C.softPurple,
          chips: <String>['مناسب لابنك', 'مناسب لزوجتك'],
        ),
        _IntroFeatureData(
          icon: Icons.photo_library_rounded,
          title: 'معرض العائلة',
          description: 'عرض منتجات أفراد العائلة',
          accent: _C.appOrange,
          accent2: _C.appOrange2,
          soft: _C.softOrange,
          chips: <String>['لمستخدمين أكثر', 'تبديل أسهل'],
        ),
        _IntroFeatureData(
          icon: Icons.hub_rounded,
          title: 'دائرة ترشيحات أكبر',
          description: 'اكتشف فرص تبديل من أصدقاء وأقارب أفراد العائلة.',
          accent: _C.appTealDark,
          accent2: _C.appTeal,
          soft: _C.softTeal,
          chips: <String>['من صديقة ابنتك', 'من أقارب زوجك'],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _showContacts = widget.introSeen;

    if (_showContacts) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prepareContacts());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _prepareContacts() async {
    if (_loadingContacts || !mounted) return;

    // ✅ BENCHMARK: وقت تحضير الكونتاكتس (permission + sync)
    TaapdeelPerfBenchmark.start('contact_sheet_prepare');

    final ContactNetworkProvider provider = context.read<ContactNetworkProvider>();

    if (!provider.hasPermission) {
      setState(() => _loadingContacts = true);

      final bool granted = await provider.requestPermissionAndSync(
        force: true,
        reason: 'contact_unified_sheet_cta',
      );

      if (!mounted) return;

      if (!granted && !provider.hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('فعّل صلاحية جهات الاتصال لاكتشاف منتجات أصدقائك وأقاربك.'),
          ),
        );
      }

      if (!mounted) return;
      setState(() => _loadingContacts = false);
      TaapdeelPerfBenchmark.end('contact_sheet_prepare');
      return;
    }

    // فيه permission فعلاً: اعرض الكاش الموجود فورًا بدون "تهنيجة"،
    // وشغّل التحديث (full sync أو light check بحسب الحاجة) في الخلفية.
    // أي نتيجة جديدة هتوصل عبر notifyListeners والـ Consumer هيعكسها تلقائيًا.
    TaapdeelPerfBenchmark.end('contact_sheet_prepare'); // cache hit — instant
    unawaited(provider.syncInBackground(
      force: false,
      reason: 'contact_unified_sheet_cta',
    ));
  }

  Future<void> _finishIntro() async {
    // ✅ BENCHMARK: وقت إكمال الـ onboarding intro
    TaapdeelPerfBenchmark.start('contact_intro_finish');

    HapticFeedback.selectionClick();
    await PsSharedPreferences.instance.shared.setBool(ContactNetworkBottomSheet._introSeenKey, true);

    if (!mounted) return;
    setState(() => _showContacts = true);
    await _prepareContacts();
    TaapdeelPerfBenchmark.end('contact_intro_finish');
    TaapdeelPerfBenchmark.printReport();
  }

  void _next() {
    HapticFeedback.selectionClick();

    if (_index >= _pages.length - 1) {
      _finishIntro();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final bool compact = screenHeight < 720;
    final double sheetHeight = math.min(screenHeight * 0.91, compact ? 646 : 760);
    final bool last = _index == _pages.length - 1;
    final _IntroPageData activePage = _pages[_index];

    return SafeArea(
      top: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TaapdeelGlassBottomSheet(
          padding: EdgeInsets.fromLTRB(14, compact ? 9 : 11, 14, 14),
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                SizedBox(height: compact ? 9 : 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _showContacts
                        ? _ContactNetworkSheetBody(
                      key: const ValueKey<String>('contacts'),
                      loading: _loadingContacts,
                    )
                        : PageView.builder(
                      key: const ValueKey<String>('intro'),
                      controller: _controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _pages.length,
                      onPageChanged: (int i) => setState(() => _index = i),
                      itemBuilder: (_, int i) => _IntroOnboardingPage(
                        data: _pages[i],
                        compact: compact,
                      ),
                    ),
                  ),
                ),
                if (!_showContacts) ...[
                  SizedBox(height: compact ? 8 : 10),
                  _IntroDots(count: _pages.length, index: _index, activeColor: activePage.accent2),
                  SizedBox(height: compact ? 10 : 12),
                  _IntroPrimaryButton(
                    title: last ? _pages.last.cta : _pages.first.cta,
                    accent: activePage.accent,
                    accent2: activePage.accent2,
                    icon: last ? Icons.groups_2_rounded : Icons.arrow_forward_rounded,
                    onTap: _next,
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

class _IntroOnboardingPage extends StatelessWidget {
  const _IntroOnboardingPage({required this.data, required this.compact});

  final _IntroPageData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _IntroTitleBlock(data: data, compact: compact),
          SizedBox(height: compact ? 10 : 13),
          _IntroNetworkImage(data: data, compact: compact),
          SizedBox(height: compact ? 12 : 15),
          _IntroFeatureCardsRow(data: data, compact: compact),
        ],
      ),
    );
  }
}

class _IntroTitleBlock extends StatelessWidget {
  const _IntroTitleBlock({required this.data, required this.compact});

  final _IntroPageData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6),
      child: Column(
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: data.accent,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 22 : 25,
              height: 1.18,
            ),
          ),
          SizedBox(height: compact ? 6 : 7),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black.withOpacity(0.54),
              fontWeight: FontWeight.w800,
              fontSize: compact ? 12.2 : 13.6,
              height: 1.22,
            ),
          ),
          if ((data.helper ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              data.helper!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withOpacity(0.46),
                fontWeight: FontWeight.w700,
                fontSize: compact ? 11.4 : 12.4,
                height: 1.20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IntroNetworkImage extends StatelessWidget {
  const _IntroNetworkImage({required this.data, required this.compact});

  final _IntroPageData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double height = compact ? 215 : 240;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: <Color>[data.soft.withOpacity(0.72), Colors.white.withOpacity(0.96)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        border: Border.all(color: data.accent2.withOpacity(0.13)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: data.accent2.withOpacity(0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PositionedDirectional(
            top: -42,
            end: -35,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.accent2.withOpacity(0.06),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -52,
            start: -44,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.accent.withOpacity(0.045),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 6 : 8),
            child: Image.asset(
              data.imageAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => _IntroImageFallback(data: data),
            ),
          ),
        ],
      ),
    );
  }
}


class _IntroFeatureCardsRow extends StatelessWidget {
  const _IntroFeatureCardsRow({required this.data, required this.compact});

  final _IntroPageData data;
  final bool compact;

  List<_IntroFeatureData> _orderedFeatures(List<_IntroFeatureData> features) {
    // في صفحة العائلة ترتيب الداتا هو: مناسب لعائلتك، معرض العائلة، دائرة ترشيحات أكبر.
    // التصميم المطلوب يعرضهم تحت بعض مع الحفاظ على نفس أولوية الفوكس الحالية:
    // دائرة الترشيحات أولاً، ثم الترشيحات المناسبة، ثم معرض العائلة.
    if (features.length > 2) {
      return <_IntroFeatureData>[
        features[2],
        features[0],
        features[1],
        ...features.skip(3),
      ];
    }

    return features;
  }

  @override
  Widget build(BuildContext context) {
    final List<_IntroFeatureData> features = _orderedFeatures(data.features);

    if (features.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        for (int i = 0; i < features.length; i++) ...<Widget>[
          _AnimatedIntroMiniFeatureCard(
            feature: features[i],
            index: i + 1,
            compact: compact,
            wide: true,
          ),
          if (i != features.length - 1) SizedBox(height: compact ? 10 : 12),
        ],
      ],
    );
  }
}

class _AnimatedIntroMiniFeatureCard extends StatelessWidget {
  const _AnimatedIntroMiniFeatureCard({
    required this.feature,
    required this.index,
    required this.compact,
    required this.wide,
  });

  final _IntroFeatureData feature;
  final int index;
  final bool compact;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + (index * 110)),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        final double opacity = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - opacity)),
            child: Transform.scale(
              scale: 0.96 + (0.04 * opacity),
              child: child,
            ),
          ),
        );
      },
      child: _IntroMiniFeatureCard(
        feature: feature,
        index: index,
        compact: compact,
        wide: wide,
      ),
    );
  }
}

class _IntroMiniFeatureCard extends StatelessWidget {
  const _IntroMiniFeatureCard({
    required this.feature,
    required this.index,
    required this.compact,
    required this.wide,
  });

  final _IntroFeatureData feature;
  final int index;
  final bool compact;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (wide) {
      return Container(
        width: double.infinity,
        height: compact ? 112 : 126,
        padding: EdgeInsetsDirectional.fromSTEB(
          14,
          compact ? 12 : 14,
          14,
          compact ? 12 : 14,
        ),
        decoration: _featureCardDecoration(feature),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              _FeatureCardIcon(feature: feature, compact: compact, large: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FeatureCardTitle(feature: feature, compact: compact, center: false),
                    SizedBox(height: compact ? 4 : 5),
                    _FeatureCardDescription(
                      feature: feature,
                      compact: compact,
                      center: false,
                      maxLines: feature.chips.isEmpty ? 2 : 1,
                    ),
                    if (feature.chips.isNotEmpty) ...[
                      SizedBox(height: compact ? 8 : 9),
                      _FeatureCardChips(feature: feature, compact: compact, center: false),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: compact ? 144 : 162,
      padding: EdgeInsets.fromLTRB(10, compact ? 10 : 12, 10, compact ? 10 : 12),
      decoration: _featureCardDecoration(feature),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _FeatureCardIcon(feature: feature, compact: compact, large: true),
            SizedBox(height: compact ? 15 : 20),
            _FeatureCardTitle(feature: feature, compact: compact, center: true),
            const SizedBox(height: 12),
            Expanded(
              child: _FeatureCardDescription(
                feature: feature,
                compact: compact,
                center: true,
                maxLines: feature.chips.isEmpty ? 3 : 2,
              ),
            ),
            if (feature.chips.isNotEmpty) ...[
              const SizedBox(height: 5),
              _FeatureCardChips(feature: feature, compact: compact, center: true),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _featureCardDecoration(_IntroFeatureData feature) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: feature.accent2.withOpacity(0.17), width: 1.15),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: feature.accent2.withOpacity(0.10),
          blurRadius: 19,
          offset: const Offset(0, 9),
        ),
      ],
    );
  }
}

class _FeatureCardIcon extends StatelessWidget {
  const _FeatureCardIcon({
    required this.feature,
    required this.compact,
    required this.large,
  });

  final _IntroFeatureData feature;
  final bool compact;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final double size = large ? (compact ? 50 : 56) : (compact ? 40 : 46);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: <Color>[feature.accent2, feature.accent],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: feature.accent2.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Icon(feature.icon, color: Colors.white, size: compact ? 18 : 22),
    );
  }
}


class _FeatureCardChips extends StatelessWidget {
  const _FeatureCardChips({
    required this.feature,
    required this.compact,
    required this.center,
  });

  final _IntroFeatureData feature;
  final bool compact;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final List<String> chips = feature.chips.take(2).toList();

    return Wrap(
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      spacing: compact ? 7 : 8,
      runSpacing: compact ? 7 : 8,
      children: chips.map((String chip) {
        return Container(
          constraints: BoxConstraints(minHeight: compact ? 30 : 34),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 11 : 13,
            vertical: compact ? 6 : 7,
          ),
          decoration: BoxDecoration(
            color: feature.soft.withOpacity(0.98),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: feature.accent2.withOpacity(0.28),
              width: 1.15,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: feature.accent2.withOpacity(0.09),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            chip,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: feature.accent,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 10.0 : 11.0,
              height: 1.08,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureCardTitle extends StatelessWidget {
  const _FeatureCardTitle({
    required this.feature,
    required this.compact,
    required this.center,
  });

  final _IntroFeatureData feature;
  final bool compact;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Text(
      feature.title,
      textAlign: center ? TextAlign.center : TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: feature.accent,
        fontWeight: FontWeight.w900,
        fontSize: compact ? 13.4 : 15.0,
        height: 1.18,
      ),
    );
  }
}

class _FeatureCardDescription extends StatelessWidget {
  const _FeatureCardDescription({
    required this.feature,
    required this.compact,
    required this.center,
    required this.maxLines,
  });

  final _IntroFeatureData feature;
  final bool compact;
  final bool center;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      feature.description,
      textAlign: center ? TextAlign.center : TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.black.withOpacity(0.62),
        fontWeight: FontWeight.w700,
        fontSize: compact ? 10.4 : 11.4,
        height: 1.30,
      ),
    );
  }
}

class _IntroImageFallback extends StatelessWidget {
  const _IntroImageFallback({required this.data});

  final _IntroPageData data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 118,
        height: 118,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: <Color>[data.accent2, data.accent]),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: data.accent2.withOpacity(0.24),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.hub_rounded, color: Colors.white, size: 54),
      ),
    );
  }
}


class _IntroPrimaryButton extends StatelessWidget {
  const _IntroPrimaryButton({
    required this.title,
    required this.accent,
    required this.accent2,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final Color accent;
  final Color accent2;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: <Color>[accent2, accent],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent2.withOpacity(0.24),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15.2,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 19),
          ],
        ),
      ),
    );
  }
}

class _IntroDots extends StatelessWidget {
  const _IntroDots({required this.count, required this.index, required this.activeColor});

  final int count;
  final int index;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: active ? activeColor : Colors.black.withOpacity(0.12),
          ),
        );
      }),
    );
  }
}

class _IntroPageData {
  const _IntroPageData({
    required this.title,
    required this.subtitle,
    this.helper,
    required this.imageAsset,
    required this.accent,
    required this.accent2,
    required this.soft,
    required this.cta,
    required this.features,
  });

  final String title;
  final String subtitle;
  final String? helper;
  final String imageAsset;
  final Color accent;
  final Color accent2;
  final Color soft;
  final String cta;
  final List<_IntroFeatureData> features;
}

class _IntroFeatureData {
  const _IntroFeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.accent2,
    required this.soft,
    this.chips = const <String>[],
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final Color accent2;
  final Color soft;
  final List<String> chips;
}

class _C {
  // App palette derived from PsColors:
  // primary500 = 0xFF0C2345, secondary500 = 0xFF0FA3A6, orangeColor = 0xFFDCC88F.
  static const Color appNavy = Color(0xFF0C2345);
  static const Color appNavy2 = Color(0xFF102E5C);
  static const Color appTeal = Color(0xFF0FA3A6);
  static const Color appTeal2 = Color(0xFF1CC7B8);
  static const Color appTealDark = Color(0xFF0B777A);
  static const Color softTeal = Color(0xFFE9FBFA);

  static const Color featureBlue = Color(0xFF0C5AA6);
  static const Color featureBlue2 = Color(0xFF2F80ED);
  static const Color softFeatureBlue = Color(0xFFEAF4FF);

  static const Color premiumGold = Color(0xFFDCC88F);
  static const Color premiumGold2 = Color(0xFFFFD35A);
  static const Color softGold = Color(0xFFFFF8E4);

  static const Color appOrange = Color(0xFFFF9F1C);
  static const Color appOrange2 = Color(0xFFFF7A00);
  static const Color softOrange = Color(0xFFFFF3E0);

  static const Color appPurple = Color(0xFF6D28D9);
  static const Color appPurple2 = Color(0xFFA855F7);
  static const Color softPurple = Color(0xFFF5F0FF);

  static const Color logoBlue = appNavy;
  static const Color logoCyan = appTeal;
  static const Color softBlue = softTeal;

  static const Color featureGold = premiumGold;
  static const Color featureGold2 = premiumGold2;

  static const Color featureOrange = appOrange;
  static const Color featureOrange2 = appOrange2;

  static const Color featurePurple = appPurple;
  static const Color featurePurple2 = appPurple2;

  static const Color featureChat = appTealDark;
  static const Color featureChat2 = appTeal;

  static const Color deepGreen = appNavy;
  static const Color familyGreen = appTeal;
  static const Color softGreen = softTeal;

  static const Color deep = appNavy;
  static const Color navy = appNavy;
  static const Color teal = appTeal;
  static const Color aqua = appTeal2;
  static const Color softAqua = softTeal;
  static const Color text = Color(0xFF102A43);
  static const Color muted = Color(0xFF667085);
  static const Color border = Color(0xFFE4EEF2);

  static const Color family = appOrange;
  static const Color family2 = appOrange2;
  static const Color network = appTeal;
  static const Color network2 = appTeal2;
  static const Color trust = appTealDark;
  static const Color trust2 = appTeal;
}
enum _RelationDisplayMode {
  swapRecommendations,
  familyGallery,
}

class _FollowSelection {
  const _FollowSelection({
    required this.relationType,
    required this.receiveRecommendations,
    required this.showInFamilyGallery,
  });

  final int relationType;
  final bool receiveRecommendations;
  final bool showInFamilyGallery;
}

class _ContactNetworkSheetBody extends StatefulWidget {
  const _ContactNetworkSheetBody({Key? key, required this.loading}) : super(key: key);

  final bool loading;

  @override
  State<_ContactNetworkSheetBody> createState() => _ContactNetworkSheetBodyState();
}

class _ContactNetworkSheetBodyState extends State<_ContactNetworkSheetBody> {
  final Map<String, _FollowSelection> _selectedRelationByUserId = <String, _FollowSelection>{};
  bool _sending = false;

  List<_RelationOption> get _relations => const <_RelationOption>[
    // الترتيب الظاهر في الشبكة من اليمين لليسار:
    // صديق/زميل، قريب/عائلة، أخ/أخت
    // أم/أب، زوج/زوجة، ابن/ابنة
    _RelationOption(
      1,
      'صديق/زميل',
      Icons.group_rounded,
      Color(0xFF3B82F6),
      Color(0xFFEFF6FF),
      'الأكثر شيوعًا للمعارف والزملاء',
    ),
    _RelationOption(
      6,
      'قريب/عائلة',
      Icons.family_restroom_rounded,
      Color(0xFF14B8A6),
      Color(0xFFE6FFFB),
      'أقارب ومعارف العائلة',
    ),
    _RelationOption(
      5,
      'أخ/أخت',
      Icons.people_alt_rounded,
      Color(0xFF8B5CF6),
      Color(0xFFF5F3FF),
      'لإضافة الإخوة والأخوات',
    ),
    _RelationOption(
      4,
      'أم/أب',
      Icons.account_circle_rounded,
      Color(0xFFF59E0B),
      Color(0xFFFFF7E6),
      'عندما يكون الشخص أحد الوالدين',
    ),
    _RelationOption(
      2,
      'زوج/زوجة',
      Icons.favorite_rounded,
      Color(0xFFFB7185),
      Color(0xFFFFF1F2),
      'للزوجين فقط ويؤثر على الثقة',
    ),
    _RelationOption(
      3,
      'ابن/ابنة',
      Icons.child_care_rounded,
      Color(0xFF22C55E),
      Color(0xFFECFDF3),
      'عندما يكون الشخص أحد الأبناء',
    ),
  ];

  List<_RelationOption> _smartRelationsFor(UsersPhoneModel user) {
    return _relations;
  }

  bool _isDirectFamilyRelation(int relationType) {
    // زوج/زوجة، ابن/ابنة، أم/أب، أخ/أخت.
    // هؤلاء يتم توجيههم افتراضيًا لمعرض العائلة لأنهم أفراد عائلة مباشرين.
    return relationType == 2 || relationType == 3 || relationType == 4 || relationType == 5;
  }

  _RelationDisplayMode _defaultDisplayModeForRelation(int relationType) {
    // صديق/زميل + قريب/عائلة: الافتراضي ترشيحات تبديل.
    // أفراد العائلة المباشرين: الافتراضي معرض العائلة.
    return _isDirectFamilyRelation(relationType)
        ? _RelationDisplayMode.familyGallery
        : _RelationDisplayMode.swapRecommendations;
  }

  Future<_FollowSelection?> _pickRelation(UsersPhoneModel user) async {
    final List<_RelationOption> options = _smartRelationsFor(user);
    final String name = _displayName(user);
    int? selectedRelationType;
    _RelationDisplayMode displayMode = _RelationDisplayMode.swapRecommendations;

    return showModalBottomSheet<_FollowSelection>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.32),
      builder: (_) => StatefulBuilder(
        builder: (BuildContext sheetContext, void Function(void Function()) setSheetState) {
          final _RelationOption? selectedRelation = selectedRelationType == null
              ? null
              : _relationById(selectedRelationType!);

          return TaapdeelGlassBottomSheet(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.86,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 54,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: <Color>[_C.aqua, _C.teal],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: _C.teal.withOpacity(0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اختيار العلاقة مع $name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: _C.text,
                                  fontSize: 15.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'اختر العلاقة، ثم حدد طريقة ظهور منتجاته: ترشيحات تبديل أو معرض العائلة.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _C.muted,
                                  fontSize: 11.4,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: options.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.92,
                      ),
                      itemBuilder: (_, i) {
                        final _RelationOption r = options[i];
                        final bool selected = selectedRelationType == r.id;
                        return InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setSheetState(() {
                              selectedRelationType = r.id;
                              displayMode = _defaultDisplayModeForRelation(r.id);
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.96),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? _C.teal.withOpacity(0.70) : Colors.black.withOpacity(0.08),
                                width: selected ? 1.8 : 1.1,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withOpacity(selected ? 0.070 : 0.045),
                                  blurRadius: selected ? 16 : 12,
                                  offset: const Offset(0, 7),
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
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(color: r.color.withOpacity(0.22)),
                                      ),
                                      child: Icon(r.icon, color: r.color, size: 19),
                                    ),
                                    if (selected)
                                      Positioned(
                                        top: -4,
                                        left: -4,
                                        child: Container(
                                          width: 17,
                                          height: 17,
                                          decoration: BoxDecoration(
                                            color: _C.teal,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.4),
                                          ),
                                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  r.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11.0,
                                    color: r.color,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r.hint,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 8.5,
                                    color: Colors.black.withOpacity(0.45),
                                    height: 1.08,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (selectedRelation != null) ...<Widget>[
                      const SizedBox(height: 14),
                      _RelationDisplayOptionsPanel(
                        selectedMode: displayMode,
                        selectedRelation: selectedRelation,
                        personName: name,
                        onChanged: (_RelationDisplayMode mode) {
                          setSheetState(() => displayMode = mode);
                        },
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(sheetContext, null),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: selectedRelationType == null
                                ? null
                                : () => Navigator.pop(
                              sheetContext,
                              _FollowSelection(
                                relationType: selectedRelationType!,
                                receiveRecommendations: displayMode == _RelationDisplayMode.swapRecommendations,
                                showInFamilyGallery: displayMode == _RelationDisplayMode.familyGallery,
                              ),
                            ),
                            child: const Text('تأكيد الاختيار'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleUser(UsersPhoneModel user) async {
    final String userId = (user.userId ?? '').trim();
    if (userId.isEmpty) return;

    if (_selectedRelationByUserId.containsKey(userId)) {
      setState(() => _selectedRelationByUserId.remove(userId));
      return;
    }

    final _FollowSelection? selection = await _pickRelation(user);
    if (!mounted || selection == null) return;
    setState(() => _selectedRelationByUserId[userId] = selection);
  }

  Future<bool> _sendFollowRequest({
    required String fromUserId,
    required String toUserId,
    required int relationType,
    required bool receiveRecommendations,
    required bool showInFamilyGallery,
  }) async {
    final String base = PsConfig.ps_app_url.trim().endsWith('/')
        ? PsConfig.ps_app_url.trim()
        : '${PsConfig.ps_app_url.trim()}/';
    final Uri uri = Uri.parse('${base}rest/follow_request/send');

    final http.Response res = await http.post(
      uri,
      headers: const <String, String>{'Accept': 'application/json'},
      body: <String, String>{
        'user_id': fromUserId,
        'followed_user_id': toUserId,
        'relation_type': relationType.toString(),
        'receive_recommendations': receiveRecommendations ? '1' : '0',
        // مفاتيح إضافية اختيارية للباك إند. لو غير مدعومة حاليًا غالبًا سيتم تجاهلها.
        // الهدف: فصل ظهور المنتجات كترشيحات عن ظهورها داخل معرض العائلة.
        'show_in_family_gallery': showInFamilyGallery ? '1' : '0',
        'display_in_family_gallery': showInFamilyGallery ? '1' : '0',
      },
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) return false;
    final dynamic decoded = jsonDecode(res.body);
    return decoded is Map && decoded['status'] == 'success';
  }

  Future<void> _sendSelected(ContactNetworkProvider provider) async {
    if (_selectedRelationByUserId.isEmpty || _sending) return;

    final String uid = (PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__USER_ID) ??
        '')
        .trim();

    final bool loggedIn = uid.isNotEmpty && uid.toLowerCase() != 'nologinuser';

    if (!loggedIn) {
      final Map<String, PendingFollowSelection> pending = PendingFollowsCache.read();
      _selectedRelationByUserId.forEach((String userId, _FollowSelection selection) {
        pending[userId] = PendingFollowSelection(
          relationType: selection.relationType,
          receiveRecommendations: selection.receiveRecommendations,
        );
      });
      await PendingFollowsCache.save(pending);

      if (!mounted) return;

      final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

      Navigator.pop(context);

      messenger.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('تم حفظ الاختيارات. سجّل الدخول لإرسال طلبات الإضافة تلقائيًا.'),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 180));
      rootNavigator.pushNamed(RoutePaths.login_container);
      return;
    }

    setState(() => _sending = true);
    final Set<String> successIds = <String>{};

    final List<MapEntry<String, _FollowSelection>> entries = _selectedRelationByUserId.entries.toList();
    final List<bool> results = await Future.wait(
      entries.map((MapEntry<String, _FollowSelection> e) => _sendFollowRequest(
        fromUserId: uid,
        toUserId: e.key,
        relationType: e.value.relationType,
        receiveRecommendations: e.value.receiveRecommendations,
        showInFamilyGallery: e.value.showInFamilyGallery,
      ).catchError((_) => false)),
    );

    for (int i = 0; i < entries.length; i++) {
      if (results[i]) successIds.add(entries[i].key);
    }

    if (!mounted) return;
    setState(() => _sending = false);

    if (successIds.isNotEmpty) {
      await provider.markUsersHandled(successIds);
      if (!mounted) return;

      final int addedCount = successIds.length;

      setState(() {
        for (final String id in successIds) {
          _selectedRelationByUserId.remove(id);
        }
      });

      final bool willClose = provider.pendingCount == 0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Text(
            addedCount == 1
                ? 'تم إضافة الشخص لشبكتك 🎉 هتشوف فرص تبديل أقرب ورسائل ألطف'
                : 'تم إضافة $addedCount أشخاص لشبكتك 🎉 هتشوف فرص تبديل أقرب ورسائل ألطف',
          ),
        ),
      );

      if (willClose) {
        // أعطِ وقت كافٍ لظهور الرسالة قبل إغلاق الشيت.
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (mounted) Navigator.pop(context);
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('حدث خطأ أثناء الإضافة، حاول مرة أخرى.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactNetworkProvider>(
      builder: (context, provider, _) {
        final bool hasPermission = provider.hasPermission;
        final List<UsersPhoneModel> people = provider.suggestions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CompactContactsHeader(
              count: provider.pendingCount,
              syncing: widget.loading || provider.isSyncing,
              onRefresh: hasPermission && !widget.loading
                  ? () => provider.syncInBackground(
                force: true,
                reason: 'manual_bottom_sheet',
              )
                  : null,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: widget.loading
                    ? const _LoadingPanel(key: ValueKey<String>('loading'))
                    : (!hasPermission || people.isEmpty)
                    ? _EmptyPanel(
                  key: const ValueKey<String>('empty'),
                  syncing: provider.isSyncing,
                  onRefresh: () => provider.syncInBackground(
                    force: true,
                    reason: 'empty_manual',
                  ),
                )
                    : GridView.builder(
                  key: const ValueKey<String>('people'),
                  padding: const EdgeInsets.only(bottom: 4),
                  itemCount: people.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (_, i) {
                    final UsersPhoneModel user = people[i];
                    final String id = (user.userId ?? '').trim();
                    final _FollowSelection? selection = _selectedRelationByUserId[id];
                    final int relationId = selection?.relationType ?? 0;
                    return _PersonCard(
                      user: user,
                      selectedRelation: _relationById(relationId),
                      onTap: () => _toggleUser(user),
                      onDismiss: () => provider.dismissUser(id),
                    );
                  },
                ),
              ),
            ),
            if (hasPermission && people.isNotEmpty) ...[
              const SizedBox(height: 10),
              _BottomActionBar(
                count: _selectedRelationByUserId.length,
                sending: _sending,
                onTap: _selectedRelationByUserId.isEmpty || _sending
                    ? null
                    : () => _sendSelected(provider),
              ),
            ],
          ],
        );
      },
    );
  }

  _RelationOption? _relationById(int id) {
    for (final _RelationOption r in _relations) {
      if (r.id == id) return r;
    }
    return null;
  }
}

class _CompactContactsHeader extends StatelessWidget {
  const _CompactContactsHeader({
    required this.count,
    required this.syncing,
    required this.onRefresh,
  });

  final int count;
  final bool syncing;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: <Color>[_C.aqua, _C.teal],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
            ),
            child: const Icon(Icons.groups_2_rounded, color: Colors.white, size: 23),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count > 0 ? '$count أصدقاء / أقارب مقترحين' : 'اختر من أصدقائك وأقاربك',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _C.text,
                    fontSize: 15.2,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'حدد الأشخاص والعلاقة المناسبة لإضافتهم لشبكتك.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.48),
                    fontSize: 11.4,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (syncing)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: _C.teal),
            )
          else if (onRefresh != null)
            Material(
              color: _C.softAqua,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRefresh,
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.refresh_rounded, color: _C.teal, size: 22),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _C.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: _C.teal),
            ),
            SizedBox(width: 10),
            Text(
              'جاري تجهيز شبكتك...',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: _C.text,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({Key? key, required this.syncing, required this.onRefresh}) : super(key: key);
  final bool syncing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_rounded, color: Colors.black.withOpacity(0.36), size: 44),
          const SizedBox(height: 8),
          const Text(
            'لاضافة المزيد من الاصدقاء والاقارب',
            style: TextStyle(fontWeight: FontWeight.w900, color: _C.text),
          ),
          const SizedBox(height: 5),
          Text(
            'شارك التطبيق لترشيحات تبديل افضل واكثر ثقة.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.52)),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: syncing ? null : onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.user,
    required this.selectedRelation,
    required this.onTap,
    required this.onDismiss,
  });

  final UsersPhoneModel user;
  final _RelationOption? selectedRelation;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final String displayName = _displayName(user);
    final String appName = _appName(user);
    final bool showAppName = _hasDifferentLocalName(user);
    final int itemsCount = user.itemsCount ?? int.tryParse(user.postCount ?? '') ?? 0;
    final bool selected = selectedRelation != null;
    final Color accent = selectedRelation?.color ?? _C.teal;
    final Color bg = selectedRelation?.bg ?? _C.softAqua;
    final double rating = double.tryParse(user.overallRating ?? '') ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 210),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.white, Colors.white.withOpacity(0.92)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? _C.aqua.withOpacity(0.42) : Colors.black.withOpacity(0.07),
              width: selected ? 1.3 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.050),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              PositionedDirectional(
                top: -7,
                end: -7,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onDismiss,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.black.withOpacity(0.28),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ContactAvatar(
                      user: user,
                      name: displayName,
                      accent: accent,
                      bg: bg,
                      selected: selected,
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        displayName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.2,
                          color: _C.text,
                          height: 1.0,
                        ),
                      ),
                    ),
                    if (showAppName) ...[
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'على تبديل: $appName',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 9.5,
                            color: Colors.black.withOpacity(0.38),
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        _MiniChip(
                          icon: Icons.inventory_2_rounded,
                          text: '$itemsCount منتجات',
                          color: _C.teal,
                          bg: _C.softAqua,
                        ),
                        if (rating > 0)
                          _MiniChip(
                            icon: Icons.star_rounded,
                            text: rating.toStringAsFixed(1),
                            color: const Color(0xFFE8A000),
                            bg: const Color(0xFFFFF7DB),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 170),
                      child: selected
                          ? Container(
                        key: ValueKey<int>(selectedRelation!.id),
                        constraints: const BoxConstraints(maxWidth: 125),
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: accent.withOpacity(0.26)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(selectedRelation!.icon, size: 12, color: accent),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                selectedRelation!.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.6,
                                  color: accent,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : Text(
                        'اضغط وحدد العلاقة',
                        key: const ValueKey<String>('hint'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          color: Colors.black.withOpacity(0.40),
                        ),
                      ),
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

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({
    required this.user,
    required this.name,
    required this.accent,
    required this.bg,
    required this.selected,
  });

  final UsersPhoneModel user;
  final String name;
  final Color accent;
  final Color bg;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final String code = (user.code ?? user.userId ?? '').trim();
    final String heroTag = '$code${PsConst.HERO_TAG__IMAGE}';
    final String imagePath = (user.userProfilePhoto ?? '').trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: <Color>[bg, Colors.white],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: selected ? accent : _C.aqua.withOpacity(0.45),
              width: selected ? 2.4 : 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (selected ? accent : _C.teal).withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: ClipOval(
            child: PsNetworkCircleImageForUser(
              photoKey: heroTag,
              imagePath: imagePath,
              gender: user.userGender,
              ageRange: user.userAge,
              width: 62,
              height: 62,
            ),
          ),
        ),
        PositionedDirectional(
          bottom: -3,
          start: -2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? accent : Colors.white,
              border: Border.all(color: selected ? Colors.white : _C.aqua, width: 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              selected ? Icons.check_rounded : Icons.add_rounded,
              color: selected ? Colors.white : _C.teal,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}


class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.icon,
    required this.text,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: color,
              fontSize: 10.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationDisplayOptionsPanel extends StatelessWidget {
  const _RelationDisplayOptionsPanel({
    required this.selectedMode,
    required this.selectedRelation,
    required this.personName,
    required this.onChanged,
  });

  final _RelationDisplayMode selectedMode;
  final _RelationOption? selectedRelation;
  final String personName;
  final ValueChanged<_RelationDisplayMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool hasRelation = selectedRelation != null;
    final bool directFamily = selectedRelation == null
        ? false
        : selectedRelation!.id == 2 ||
        selectedRelation!.id == 3 ||
        selectedRelation!.id == 4 ||
        selectedRelation!.id == 5;
    final String safePersonName = personName.trim().isEmpty ? 'هذا الشخص' : personName.trim();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.softAqua,
                  border: Border.all(color: _C.teal.withOpacity(0.16)),
                ),
                child: const Icon(Icons.tune_rounded, color: _C.teal, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ' تفضل منتجات "$safePersonName"  تظهر كـ',
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _C.text,
                    fontSize: 13.6,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _RelationDisplayModeCard(
                  selected: hasRelation && selectedMode == _RelationDisplayMode.swapRecommendations,
                  enabled: hasRelation,
                  icon: Icons.auto_awesome_rounded,
                  title: 'ترشيحات تبديل',
                  subtitle: 'منتجاته تظهر \nكفرص تبديل \nمقترحة لك\n في فرص التبديل ',
                  badge: directFamily ? null : 'للأصدقاء والأقارب',
                  accent: _C.teal,
                  onTap: () => onChanged(_RelationDisplayMode.swapRecommendations),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _RelationDisplayModeCard(
                  selected: hasRelation && selectedMode == _RelationDisplayMode.familyGallery,
                  enabled: hasRelation,
                  icon: Icons.photo_library_rounded,
                  title: 'معرض العائلة',
                  subtitle: ' منتجاته تظهر \nبمعرض العائلة\nالخاص بك\n في حسابك',
                  badge: directFamily ? 'لأفراد العائلة' : null,
                  accent: _C.appOrange2,
                  onTap: () => onChanged(_RelationDisplayMode.familyGallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RelationDisplayModeCard extends StatelessWidget {
  const _RelationDisplayModeCard({
    required this.selected,
    required this.enabled,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.accent,
    required this.onTap,
  });

  final bool selected;
  final bool enabled;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeAccent = enabled ? accent : Colors.black.withOpacity(0.28);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 136,
        padding: const EdgeInsets.fromLTRB(9, 10, 9, 9),
        decoration: BoxDecoration(
          color: selected ? activeAccent.withOpacity(0.070) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? activeAccent.withOpacity(0.70) : Colors.black.withOpacity(0.060),
            width: selected ? 1.55 : 1.0,
          ),
          boxShadow: selected
              ? <BoxShadow>[
            BoxShadow(
              color: activeAccent.withOpacity(0.09),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ]
              : null,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: selected ? activeAccent : _C.text,
                      fontSize: 12.6,
                      height: 1.13,
                    ),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 21,
                    height: 21,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? activeAccent : Colors.white,
                      border: Border.all(
                        color: selected ? activeAccent : Colors.black.withOpacity(0.16),
                        width: selected ? 1.4 : 1.2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 9),

              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.49),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.count,
    required this.sending,
    required this.onTap,
  });

  final int count;
  final bool sending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = count > 0 && onTap != null;
    return Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              enabled ? 'تم اختيار $count' : 'اختر الأشخاص وحدد العلاقة',
              key: ValueKey<String>(enabled ? 'selected_$count' : 'empty'),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: enabled ? _C.text : Colors.black.withOpacity(0.48),
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: enabled ? const LinearGradient(colors: <Color>[_C.aqua, _C.teal]) : null,
              color: enabled ? null : Colors.black.withOpacity(0.08),
              boxShadow: enabled
                  ? <BoxShadow>[
                BoxShadow(
                  color: _C.teal.withOpacity(0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
                  : null,
            ),
            child: sending
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  enabled ? 'اضف لعلاقاتك' : 'اختر أولًا',
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.black.withOpacity(0.38),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(width: 7),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RelationOption {
  const _RelationOption(this.id, this.label, this.icon, this.color, this.bg, this.hint);
  final int id;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final String hint;
}

String _displayName(UsersPhoneModel user) {
  final String contactName = (user.localContactName ?? '').trim();
  if (contactName.isNotEmpty) return contactName;

  final String appName = (user.userName ?? '').trim();
  return appName.isEmpty ? 'مستخدم تبديل' : appName;
}

String _appName(UsersPhoneModel user) {
  final String appName = (user.userName ?? '').trim();
  return appName.isEmpty ? 'مستخدم تبديل' : appName;
}

bool _hasDifferentLocalName(UsersPhoneModel user) {
  final String contactName = (user.localContactName ?? '').trim();
  final String appName = (user.userName ?? '').trim();
  if (contactName.isEmpty || appName.isEmpty) return false;
  return contactName.toLowerCase() != appName.toLowerCase();
}

