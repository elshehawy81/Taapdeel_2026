import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Standalone Single Intro page.
///
/// This file contains the full required code inside the single intro file:
/// - Step 1/3: add your products + AI scan animation.
/// - Step 2/3: compare and choose from animated recommendations.
/// - Step 3/3: safe swap through family/friends circle.
///
/// No dependency on Slide 2 / Slide 3 / intro content / persona resolver files.
class TaapdeelSingleIntroView extends StatefulWidget {
  const TaapdeelSingleIntroView({
    Key? key,
    this.logoAsset = 'assets/images/Taapdeel_logo.png',
    this.heroAsset = 'assets/images/taapdeel_intro_center_illustration.png',
    this.buttonText = 'ابدأ',
    this.skipText = 'تخطي',
    this.showSkipButton = true,
    this.onStart,
    this.onSkip,
  }) : super(key: key);

  final String logoAsset;
  final String heroAsset;
  final String buttonText;
  final String skipText;
  final bool showSkipButton;
  final VoidCallback? onStart;
  final VoidCallback? onSkip;

  @override
  State<TaapdeelSingleIntroView> createState() => _TaapdeelSingleIntroViewState();
}

class _TaapdeelSingleIntroViewState extends State<TaapdeelSingleIntroView>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _sceneController;
  late final AnimationController _logoPulse;
  late final AnimationController _buttonShimmer;

  Timer? _stepTimer;
  Timer? _initialHeroTimer;

  int _stepIndex = 0;
  bool _stepsVisible = false;
  bool _userInteracted = false;

  // Slower scene animation so every step is readable.
  static const Duration _sceneDuration = Duration(milliseconds: 6800);

  // Hero is shown alone first so the user understands the main message.
  static const Duration _initialHeroHoldDuration = Duration(milliseconds: 3600);

  // Each step remains visible long enough before automatic progression.
  static const Duration _stepHoldDuration = Duration(milliseconds: 7600);

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    )..forward();

    _sceneController = AnimationController(
      vsync: this,
      duration: _sceneDuration,
      animationBehavior: AnimationBehavior.preserve,
    );

    _logoPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _buttonShimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    )..repeat();

    _initialHeroTimer = Timer(_initialHeroHoldDuration, () {
      if (!mounted) return;
      setState(() {
        _stepsVisible = true;
        _stepIndex = 0;
      });
      _restartSceneAnimation();
      _scheduleNextStep();
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _initialHeroTimer?.cancel();
    _introController.dispose();
    _sceneController.dispose();
    _logoPulse.dispose();
    _buttonShimmer.dispose();
    super.dispose();
  }

  void _restartSceneAnimation() {
    _sceneController
      ..stop()
      ..reset()
      ..forward();
  }

  void _scheduleNextStep() {
    _stepTimer?.cancel();

    // Stop automatic progression when we reach step 3/3.
    // The user can still go back manually using arrows or swipe.
    if (_stepIndex >= 2) return;

    _stepTimer = Timer(_stepHoldDuration, () {
      if (!mounted) return;
      _goToStep(_stepIndex + 1, manual: false);
    });
  }

  void _goToStep(int index, {required bool manual}) {
    if (index < 0 || index > 2) return;

    if (manual) {
      _userInteracted = true;
      _stepTimer?.cancel();
      _initialHeroTimer?.cancel();
    }

    setState(() {
      _stepsVisible = true;
      _stepIndex = index;
    });

    _restartSceneAnimation();

    // Automatic flow continues only until the user interacts.
    if (!manual && !_userInteracted) {
      _scheduleNextStep();
    }
  }

  void _nextStep() {
    if (!_stepsVisible) {
      _goToStep(0, manual: true);
      return;
    }

    if (_stepIndex < 2) {
      _goToStep(_stepIndex + 1, manual: true);
      return;
    }

    _start();
  }

  void _previousStep() {
    if (!_stepsVisible) return;
    if (_stepIndex > 0) {
      _goToStep(_stepIndex - 1, manual: true);
    }
  }

  void _start() {
    if (widget.onStart != null) {
      widget.onStart!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _skip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
      return;
    }
    _start();
  }

  Animation<double> _ease(double begin, double end) {
    return CurvedAnimation(
      parent: _introController,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    final bool compact = size.height < 780 || size.width < 380;
    final bool veryCompact = size.height < 705;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FBFE),
        body: Stack(
          children: <Widget>[
            const Positioned.fill(child: _IntroBackground()),
            SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: compact ? 12 : 18,
                        right: compact ? 12 : 18,
                        top: compact ? 6 : 12,
                        bottom: (widget.showSkipButton ? 86 : 78) + padding.bottom,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _FadeSlide(
                                anim: _ease(0.00, 0.22),
                                dy: -14,
                                child: _LogoBadge(
                                  logoAsset: widget.logoAsset,
                                  pulse: _logoPulse,
                                  compact: compact,
                                ),
                              ),
                              SizedBox(height: compact ? 6 : 10),
                              _FadeSlide(
                                anim: _ease(0.08, 0.42),
                                dy: 18,
                                child: _SmartIntroHeroSection(
                                  heroAsset: widget.heroAsset,
                                  compact: compact,
                                  veryCompact: veryCompact,
                                ),
                              ),
                              SizedBox(height: compact ? 15 : 25),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 360),
                                curve: Curves.easeOutCubic,
                                alignment: Alignment.topCenter,
                                child: _stepsVisible
                                    ? _FadeSlide(
                                  anim: _ease(0.42, 0.86),
                                  dy: 14,
                                  child: _IntroStepsStepper(
                                    activeIndex: _stepIndex,
                                    compact: compact,
                                    onStepTap: (int index) => _goToStep(index, manual: true),
                                  ),
                                )
                                    : const SizedBox.shrink(),
                              ),
                              SizedBox(height: _stepsVisible ? (compact ? 15 : 25) : 0),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeOutCubic,
                                alignment: Alignment.topCenter,
                                child: _stepsVisible
                                    ? _FadeSlide(
                                  anim: _ease(0.42, 0.86),
                                  dy: 18,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onHorizontalDragEnd: (DragEndDetails details) {
                                      final double vx = details.primaryVelocity ?? 0;
                                      if (vx.abs() < 180) return;
                                      if (vx < 0) {
                                        _nextStep();
                                      } else {
                                        _previousStep();
                                      }
                                    },
                                    child: _SingleIntroStepSwitcher(
                                      stepIndex: _stepIndex,
                                      controller: _sceneController,
                                      compact: compact,
                                      veryCompact: veryCompact,
                                    ),
                                  ),
                                )
                                    : _HeroReadHint(compact: compact),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 8, 18, compact ? 8 : 12),
                  child: _FadeSlide(
                    anim: _ease(0.70, 1.00),
                    dy: 22,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: widget.showSkipButton ? 2 : 1,
                          child: _PrimaryIntroButton(
                            text: widget.buttonText,
                            shimmer: _buttonShimmer,
                            onTap: _start,
                          ),
                        ),
                        if (widget.showSkipButton) ...<Widget>[
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SkipButton(
                              text: widget.skipText,
                              onTap: _skip,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Static standalone content
// ─────────────────────────────────────────────────────────────────────────────

class _IntroProductModel {
  const _IntroProductModel({
    required this.title,
    required this.imageAsset,
    required this.percent,
    required this.label,
    required this.reasons,
  });

  final String title;
  final String imageAsset;
  final int percent;
  final String label;
  final List<_ReasonChipModel> reasons;
}

class _ReasonChipModel {
  const _ReasonChipModel({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _AiOverlayTagData {
  const _AiOverlayTagData({
    required this.icon,
    required this.text,
    required this.alignment,
  });

  final IconData icon;
  final String text;
  final Alignment alignment;
}

class _TrustMemberModel {
  const _TrustMemberModel({
    required this.label,
    required this.imageAsset,
    required this.icon,
  });

  final String label;
  final String imageAsset;
  final IconData icon;
}

class _NetworkProductModel {
  const _NetworkProductModel({
    required this.title,
    required this.fromLabel,
    required this.imageAsset,
  });

  final String title;
  final String fromLabel;
  final String imageAsset;
}

const _IntroProductModel _myProduct = _IntroProductModel(
  title: 'سماعة ألعاب',
  imageAsset: 'assets/images/products/boy_page1_gaming_headset.webp',
  percent: 0,
  label: '',
  reasons: <_ReasonChipModel>[],
);

const List<_AiOverlayTagData> _scanTags = <_AiOverlayTagData>[
  _AiOverlayTagData(
    icon: Icons.sports_esports_rounded,
    text: 'Gaming Gear',
    alignment: Alignment(-0.84, -0.23),
  ),
  _AiOverlayTagData(
    icon: Icons.headphones_rounded,
    text: 'إكسسوار ألعاب',
    alignment: Alignment(0.84, -0.14),
  ),
  _AiOverlayTagData(
    icon: Icons.bolt_rounded,
    text: 'استخدام يومي',
    alignment: Alignment(-0.78, 0.28),
  ),
  _AiOverlayTagData(
    icon: Icons.trending_up_rounded,
    text: 'رائج بين الشباب',
    alignment: Alignment(0.78, 0.34),
  ),
];

const List<_IntroProductModel> _candidateProducts = <_IntroProductModel>[
  _IntroProductModel(
    title: 'شنطة ظهر',
    imageAsset: 'assets/images/products/young_female_backpack_swap_alt.webp',
    percent: 76,
    label: 'تبديل مناسب',
    reasons: <_ReasonChipModel>[
      _ReasonChipModel(icon: Icons.location_on_rounded, label: 'نفس المنطقة'),
      _ReasonChipModel(icon: Icons.verified_user_rounded, label: 'من صديقك'),
    ],
  ),
  _IntroProductModel(
    title: 'كاميرا فورية',
    imageAsset: 'assets/images/products/instant_camera.webp',
    percent: 81,
    label: 'فرصة ممتازة',
    reasons: <_ReasonChipModel>[
      _ReasonChipModel(icon: Icons.verified_rounded, label: 'كسر زيرو'),
      _ReasonChipModel(icon: Icons.sell_rounded, label: 'من اهتماماتك'),
    ],
  ),
  _IntroProductModel(
    title: 'ساعة سمارت',
    imageAsset: 'assets/images/products/smartwatch.png',
    percent: 86,
    label: 'فرصة ممتازة',
    reasons: <_ReasonChipModel>[
      _ReasonChipModel(icon: Icons.price_check_rounded, label: 'من اهتمامات ابنتك'),
      _ReasonChipModel(icon: Icons.auto_awesome_rounded, label: 'استخدام 3 شهور'),
    ],
  ),
];

const List<_TrustMemberModel> _trustMembers = <_TrustMemberModel>[
  _TrustMemberModel(
    label: 'صديق',
    imageAsset: 'assets/images/intro/friend_1.png',
    icon: Icons.person_rounded,
  ),
  _TrustMemberModel(
    label: 'أخ',
    imageAsset: 'assets/images/intro/brother.png',
    icon: Icons.person_rounded,
  ),
  _TrustMemberModel(
    label: 'قريب',
    imageAsset: 'assets/images/intro/relative.png',
    icon: Icons.family_restroom_rounded,
  ),
  _TrustMemberModel(
    label: 'صديقة',
    imageAsset: 'assets/images/intro/friend_2.png',
    icon: Icons.person_rounded,
  ),
  _TrustMemberModel(
    label: 'العائلة',
    imageAsset: 'assets/images/intro/family.png',
    icon: Icons.groups_rounded,
  ),
];

const List<_NetworkProductModel> _networkProducts = <_NetworkProductModel>[
  _NetworkProductModel(
    title: 'ساعة سمارت',
    fromLabel: 'من صديق',
    imageAsset: 'assets/images/products/smartwatch.png',
  ),
  _NetworkProductModel(
    title: 'شنطة ظهر',
    fromLabel: 'من العائلة',
    imageAsset: 'assets/images/products/young_female_backpack_swap_alt.webp',
  ),
  _NetworkProductModel(
    title: 'كاميرا',
    fromLabel: 'من قريب',
    imageAsset: 'assets/images/products/instant_camera.webp',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Main step switcher
// ─────────────────────────────────────────────────────────────────────────────

class _SingleIntroStepSwitcher extends StatelessWidget {
  const _SingleIntroStepSwitcher({
    required this.stepIndex,
    required this.controller,
    required this.compact,
    required this.veryCompact,
  });

  final int stepIndex;
  final AnimationController controller;
  final bool compact;
  final bool veryCompact;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      reverseDuration: const Duration(milliseconds: 340),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Animation<Offset> slide = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1.0).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        key: ValueKey<int>(stepIndex),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (stepIndex == 0)
            _AddProductAiScanScene(controller: controller, compact: compact)
          else if (stepIndex == 1)
            _CompareRecommendationsScene(controller: controller, compact: compact)
          else
            _SafeTrustNetworkScene(controller: controller, compact: compact, veryCompact: veryCompact),
        ],
      ),
    );
  }
}


class _IntroStepsStepper extends StatelessWidget {
  const _IntroStepsStepper({
    required this.activeIndex,
    required this.compact,
    required this.onStepTap,
  });

  final int activeIndex;
  final bool compact;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    const List<_StepperItemData> items = <_StepperItemData>[
      _StepperItemData(
        number: '1',
        title: 'صوّر منتجاتك',
        subtitle: 'نحلل المنتج بالذكاء الاصطناعي',
        icon: Icons.camera_alt_rounded,
      ),
      _StepperItemData(
        number: '2',
        title: 'قارن واختر',
        subtitle: 'ترشيحات مناسبة لاهتماماتك',
        icon: Icons.compare_arrows_rounded,
      ),
      _StepperItemData(
        number: '3',
        title: 'بدّل بأمان',
        subtitle: 'مع الأصدقاء والأقارب',
        icon: Icons.verified_user_rounded,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.94)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _C.navy.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(items.length, (int index) {
          final bool active = index == activeIndex;
          final bool completed = index < activeIndex;

          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: _StepperCard(
                    data: items[index],
                    active: active,
                    completed: completed,
                    compact: compact,
                    onTap: () => onStepTap(index),
                  ),
                ),
                if (index != items.length - 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    width: compact ? 8 : 12,
                    height: 2,
                    margin: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
                    decoration: BoxDecoration(
                      color: index < activeIndex
                          ? _C.teal.withOpacity(0.72)
                          : _C.softBorder.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepperItemData {
  const _StepperItemData({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.data,
    required this.active,
    required this.completed,
    required this.compact,
    required this.onTap,
  });

  final _StepperItemData data;
  final bool active;
  final bool completed;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = active
        ? _C.teal
        : completed
        ? Colors.white
        : Colors.white.withOpacity(0.92);
    final Color border = active
        ? _C.teal
        : completed
        ? _C.teal.withOpacity(0.60)
        : _C.softBorder;
    final Color mainText = active ? Colors.white : _C.deepNavy;
    final Color subText = active ? Colors.white.withOpacity(0.88) : _C.softText.withOpacity(0.78);
    final Color numberBg = active
        ? Colors.white.withOpacity(0.22)
        : completed
        ? _C.teal
        : const Color(0xFFEAF8FF);
    final Color numberFg = active || completed ? Colors.white : _C.teal;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: compact ? 80 : 100,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 5 : 7,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: active ? 1.6 : 1.1),
            boxShadow: active
                ? <BoxShadow>[
              BoxShadow(
                color: _C.teal.withOpacity(0.20),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ]
                : const <BoxShadow>[],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: compact ? 22 : 24,
                padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 8),
                decoration: BoxDecoration(
                  color: numberBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (completed)
                      Icon(Icons.check_rounded, color: numberFg, size: compact ? 12 : 13)
                    else
                      Icon(data.icon, color: numberFg, size: compact ? 11 : 12),
                    const SizedBox(width: 3),
                    Text(
                      data.number,
                      style: TextStyle(
                        fontFamily: _C.font,
                        color: numberFg,
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 9.0 : 9.8,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 5 : 7),
              Text(
                data.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: _C.font,
                  color: mainText,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 10.1 : 11.4,
                  height: 1.05,
                ),
              ),
              SizedBox(height: compact ? 3 : 4),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: _C.font,
                  color: subText,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 7.8 : 8.7,
                  height: 1.18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1: AI scan product scene
// ─────────────────────────────────────────────────────────────────────────────

const double _kScanBegin = 0.18;
const double _kScanEnd = 0.48;
const List<double> _kTagBegins = <double>[0.52, 0.60, 0.68, 0.76];

class _AddProductAiScanScene extends StatelessWidget {
  const _AddProductAiScanScene({required this.controller, required this.compact});

  final AnimationController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - (compact ? 48 : 68)).clamp(280.0, 430.0);
    final double cardHeight = compact ? cardWidth * 0.46 : cardWidth * 0.54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _MiniSectionTitle(
          title: 'بنفهم منتجك بالذكاء الاصطناعي',
          icon: Icons.auto_awesome_rounded,
          compact: compact,
        ),
        SizedBox(height: compact ? 6 : 8),
        SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: PhysicalModel(
            color: Colors.transparent,
            elevation: compact ? 10 : 14,
            shadowColor: Colors.black.withOpacity(0.14),
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    _myProduct.imageAsset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => const _ImageFallback(icon: Icons.headphones_rounded),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withOpacity(0.02),
                          Colors.black.withOpacity(0.04),
                          Colors.black.withOpacity(0.40),
                        ],
                      ),
                    ),
                  ),
                  _AiScanOverlay(controller: controller, cardHeight: cardHeight),
                  Center(
                    child: Container(
                      width: compact ? 38 : 44,
                      height: compact ? 38 : 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.34)),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: _C.cyan,
                        size: compact ? 22 : 25,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: compact ? 12 : 15,
                    end: compact ? 12 : 15,
                    bottom: compact ? 12 : 15,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: compact ? 30 : 34,
                          height: compact ? 30 : 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.94),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.auto_awesome_rounded, color: _C.teal, size: compact ? 17 : 19),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _myProduct.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: compact ? 14 : 16,
                              shadows: const <Shadow>[
                                Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List<Widget>.generate(_scanTags.length, (int index) {
                    final _AiOverlayTagData tag = _scanTags[index];
                    final double begin = _kTagBegins[index];
                    final double end = (begin + 0.075).clamp(0.0, 1.0);
                    return Align(
                      alignment: tag.alignment,
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (_, __) {
                          final double pop = CurvedAnimation(
                            parent: controller,
                            curve: Interval(begin, end, curve: Curves.easeOutBack),
                          ).value;
                          final double fade = CurvedAnimation(
                            parent: controller,
                            curve: Interval(begin, end, curve: Curves.easeOut),
                          ).value;

                          return Opacity(
                            opacity: fade.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, (1 - fade) * 14),
                              child: Transform.scale(
                                scale: 0.80 + pop * 0.22,
                                child: _SolidAiTagChip(icon: tag.icon, text: tag.text, compact: compact),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AiScanOverlay extends StatelessWidget {
  const _AiScanOverlay({required this.controller, required this.cardHeight});

  final AnimationController controller;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final double scanProgress = CurvedAnimation(
          parent: controller,
          curve: const Interval(_kScanBegin, _kScanEnd, curve: Curves.easeInOut),
        ).value;
        final double scanFade = CurvedAnimation(
          parent: controller,
          curve: const Interval(_kScanEnd, 0.56, curve: Curves.easeIn),
        ).value;

        if (scanProgress == 0.0) return const SizedBox.shrink();

        final double lineY = scanProgress * cardHeight;
        final double opacity = (1.0 - scanFade).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: lineY,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withOpacity(0.30),
                        Colors.black.withOpacity(0.08),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: lineY - 1,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.transparent,
                        Color(0xFF5DBBFF),
                        Colors.white,
                        Color(0xFF5DBBFF),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: Color(0x995DBBFF), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                ),
              ),
              const Positioned(top: 10, left: 10, child: _ScanCorner(flipX: false, flipY: false)),
              const Positioned(top: 10, right: 10, child: _ScanCorner(flipX: true, flipY: false)),
              const Positioned(bottom: 10, left: 10, child: _ScanCorner(flipX: false, flipY: true)),
              const Positioned(bottom: 10, right: 10, child: _ScanCorner(flipX: true, flipY: true)),
            ],
          ),
        );
      },
    );
  }
}

class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.flipX, required this.flipY});

  final bool flipX;
  final bool flipY;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0),
      child: SizedBox(width: 18, height: 18, child: CustomPaint(painter: _CornerBracketPainter())),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF5DBBFF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2: compare recommendations scene
// ─────────────────────────────────────────────────────────────────────────────

class _CompareRecommendationsScene extends StatefulWidget {
  const _CompareRecommendationsScene({required this.controller, required this.compact});

  final AnimationController controller;
  final bool compact;

  @override
  State<_CompareRecommendationsScene> createState() => _CompareRecommendationsSceneState();
}

class _CompareRecommendationsSceneState extends State<_CompareRecommendationsScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swapPulseController;
  Timer? _candidateTimer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();

    _swapPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true);

    // Recommendation images must keep changing while Step 2 is visible.
    // This is independent from the parent scene animation.
    _candidateTimer = Timer.periodic(const Duration(milliseconds: 1900), (_) {
      if (!mounted) return;
      setState(() => _activeIndex = (_activeIndex + 1) % _candidateProducts.length);
    });
  }

  @override
  void dispose() {
    _candidateTimer?.cancel();
    _swapPulseController.dispose();
    super.dispose();
  }

  Widget _animatedChild({
    required Widget child,
    required double begin,
    required double end,
    double dy = 14,
  }) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        final double t = CurvedAnimation(
          parent: widget.controller,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _IntroProductModel activeCandidate = _candidateProducts[_activeIndex];

    return Container(
      padding: EdgeInsets.all(widget.compact ? 10 : 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3F1F7)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: _C.navy.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _animatedChild(
            begin: 0.08,
            end: 0.26,
            dy: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    'وبنرشحلك أفضل فرص التبديل',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _C.deepNavy,
                      fontWeight: FontWeight.w900,
                      fontSize: widget.compact ? 13 : 14.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 430),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.92, end: 1.0).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: _CompatibilityBadge(
                    key: ValueKey<String>('${activeCandidate.title}-${activeCandidate.percent}'),
                    percent: activeCandidate.percent,
                    label: activeCandidate.label,
                    compact: widget.compact,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.compact ? 8 : 10),
          _animatedChild(
            begin: 0.22,
            end: 0.52,
            dy: 15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _ProductSwapCard(
                        title: _myProduct.title,
                        imageAsset: _myProduct.imageAsset,
                        compact: widget.compact,
                        isHighlighted: false,
                      ),
                    ),
                    SizedBox(width: widget.compact ? 6 : 8),
                    Padding(
                      padding: EdgeInsets.only(top: widget.compact ? 38 : 44),
                      child: _AnimatedSwapIcon(compact: widget.compact, controller: _swapPulseController),
                    ),
                    SizedBox(width: widget.compact ? 6 : 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 560),
                        reverseDuration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (Widget child, Animation<double> anim) {
                          final Animation<Offset> slide = Tween<Offset>(
                            begin: const Offset(0.16, 0),
                            end: Offset.zero,
                          ).animate(anim);
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: slide,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: _ProductSwapCard(
                          key: ValueKey<String>(activeCandidate.imageAsset),
                          title: activeCandidate.title,
                          imageAsset: activeCandidate.imageAsset,
                          compact: widget.compact,
                          isHighlighted: true,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.compact ? 7 : 9),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 460),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: Transform.translate(offset: Offset(0, (1 - anim.value) * 8), child: child),
                    );
                  },
                  child: _TinyReasonChipsWrap(
                    key: ValueKey<String>('${activeCandidate.title}-${activeCandidate.percent}-reasons'),
                    reasons: activeCandidate.reasons,
                    compact: widget.compact,
                  ),
                ),
                SizedBox(height: widget.compact ? 4 : 6),
                _CandidateProgressDots(
                  count: _candidateProducts.length,
                  activeIndex: _activeIndex,
                  compact: widget.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSwapCard extends StatelessWidget {
  const _ProductSwapCard({
    Key? key,
    required this.title,
    required this.imageAsset,
    required this.compact,
    required this.isHighlighted,
  }) : super(key: key);

  final String title;
  final String imageAsset;
  final bool compact;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          height: compact ? 92 : 112,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isHighlighted ? _C.cyan.withOpacity(0.52) : const Color(0xFFE2ECF2)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (isHighlighted ? _C.teal : _C.navy).withOpacity(isHighlighted ? 0.14 : 0.06),
                blurRadius: isHighlighted ? 16 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            width: double.infinity,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => _ImageFallback(icon: isHighlighted ? Icons.inventory_2_rounded : Icons.headphones_rounded),
          ),
        ),
        SizedBox(height: compact ? 7 : 8),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _C.navy,
            fontWeight: FontWeight.w900,
            fontSize: compact ? 12 : 13,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _AnimatedSwapIcon extends StatelessWidget {
  const _AnimatedSwapIcon({required this.compact, required this.controller});

  final bool compact;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final double pulse = 0.5 + (controller.value - 0.5).abs();
        return Transform.scale(
          scale: 0.96 + (pulse * 0.05),
          child: Container(
            width: compact ? 34 : 38,
            height: compact ? 34 : 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _C.softBorder, width: 1.5),
              boxShadow: <BoxShadow>[
                BoxShadow(color: _C.teal.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Image.asset(
              'assets/images/Taapdeel_icon.png',
              width: compact ? 20 : 22,
              height: compact ? 20 : 22,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.swap_horiz_rounded, color: _C.teal, size: compact ? 20 : 22),
            ),
          ),
        );
      },
    );
  }
}

class _TinyReasonChipsWrap extends StatelessWidget {
  const _TinyReasonChipsWrap({Key? key, required this.reasons, required this.compact}) : super(key: key);

  final List<_ReasonChipModel> reasons;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: compact ? 5 : 6,
      runSpacing: compact ? 5 : 6,
      children: reasons.map((_) => _TinyReasonChip(reason: _, compact: compact)).toList(),
    );
  }
}

class _TinyReasonChip extends StatelessWidget {
  const _TinyReasonChip({required this.reason, required this.compact});

  final _ReasonChipModel reason;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 8, vertical: compact ? 4 : 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _C.softBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(reason.icon, color: _C.petrol, size: compact ? 11 : 12),
          const SizedBox(width: 4),
          Text(
            reason.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _C.softText,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 9.4 : 10.3,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  const _CompatibilityBadge({Key? key, required this.percent, required this.label, required this.compact}) : super(key: key);

  final int percent;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 5 : 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: <Color>[Color(0xFF3B5B86), Color(0xFF0D7E9B)]),
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[
          BoxShadow(color: _C.teal.withOpacity(0.20), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$percent%',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: compact ? 11 : 12, height: 1.0),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: compact ? 9.5 : 10.5, height: 1.0),
          ),
        ],
      ),
    );
  }
}

class _CandidateProgressDots extends StatelessWidget {
  const _CandidateProgressDots({required this.count, required this.activeIndex, required this.compact});

  final int count;
  final int activeIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: active ? (compact ? 14 : 16) : 5,
          height: 5,
          decoration: BoxDecoration(
            color: active ? _C.teal : _C.softBorder.withOpacity(0.95),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3: safe trust network scene
// ─────────────────────────────────────────────────────────────────────────────

class _SafeTrustNetworkScene extends StatelessWidget {
  const _SafeTrustNetworkScene({
    required this.controller,
    required this.compact,
    required this.veryCompact,
  });

  final AnimationController controller;
  final bool compact;
  final bool veryCompact;

  Widget _fade({required Widget child, required double begin, required double end, double dy = 12}) {
    final Animation<double> anim = CurvedAnimation(parent: controller, curve: Interval(begin, end, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: anim,
      child: AnimatedBuilder(
        animation: anim,
        builder: (_, __) => Transform.translate(offset: Offset(0, (1 - anim.value) * dy), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _fade(
          begin: 0.06,
          end: 0.36,
          child: _SimpleTrustNetworkVisual(
            controller: controller,
            compact: compact,
            veryCompact: veryCompact,
          ),
        ),
        SizedBox(height: compact ? 7 : 10),
        _fade(
          begin: 0.48,
          end: 0.68,
          dy: 10,
          child: Column(
            children: <Widget>[
              Text(
                'ترشيحات من أقاربك وأصحابك',
                style: TextStyle(color: _C.deepNavy, fontWeight: FontWeight.w900, fontSize: compact ? 15 : 17),
              ),
              SizedBox(height: compact ? 6 : 8),
              _NetworkProductsRow(products: _networkProducts, compact: compact),
            ],
          ),
        ),
      ],
    );
  }
}


class _SimpleTrustNetworkVisual extends StatelessWidget {
  const _SimpleTrustNetworkVisual({
    required this.controller,
    required this.compact,
    required this.veryCompact,
  });

  final AnimationController controller;
  final bool compact;
  final bool veryCompact;

  @override
  Widget build(BuildContext context) {
    final double cardSize = veryCompact ? 58 : (compact ? 64 : 76);
    final double shieldSize = veryCompact ? 54 : (compact ? 60 : 70);
    final double totalHeight = veryCompact ? 88 : (compact ? 100 : 116);

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final double baseT = CurvedAnimation(
            parent: controller,
            curve: const Interval(0.08, 0.38, curve: Curves.easeOutCubic),
          ).value;

          final double leftT = CurvedAnimation(
            parent: controller,
            curve: const Interval(0.14, 0.44, curve: Curves.easeOutBack),
          ).value;

          final double centerT = CurvedAnimation(
            parent: controller,
            curve: const Interval(0.20, 0.50, curve: Curves.easeOutBack),
          ).value;

          final double rightT = CurvedAnimation(
            parent: controller,
            curve: const Interval(0.26, 0.56, curve: Curves.easeOutBack),
          ).value;

          final double lineT = CurvedAnimation(
            parent: controller,
            curve: const Interval(0.32, 0.64, curve: Curves.easeOutCubic),
          ).value;

          final double pulse = 0.5 + (controller.value - 0.5).abs();

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                left: compact ? 42 : 58,
                right: compact ? 42 : 58,
                top: totalHeight * 0.42,
                child: Opacity(
                  opacity: lineT.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scaleX: lineT.clamp(0.0, 1.0),
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: <Color>[
                            _C.teal.withOpacity(0.05),
                            _C.teal.withOpacity(0.30),
                            _C.teal.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: compact ? 20 : 38,
                top: compact ? 12 : 16,
                child: _AnimatedTrustTile(
                  progress: leftT,
                  size: cardSize,
                  icon: Icons.family_restroom_rounded,
                  label: 'أقارب',
                  subtitle: 'دائرة قريبة',
                ),
              ),
              Transform.translate(
                offset: Offset(0, (1 - centerT) * 12),
                child: Opacity(
                  opacity: centerT.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.82 + centerT * 0.18 + pulse * 0.015,
                    child: _CentralTrustShield(
                      size: shieldSize,
                      compact: compact,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                end: compact ? 20 : 38,
                top: compact ? 12 : 16,
                child: _AnimatedTrustTile(
                  progress: rightT,
                  size: cardSize,
                  icon: Icons.groups_rounded,
                  label: 'أصدقاء',
                  subtitle: 'ناس تعرفهم',
                ),
              ),

            ],
          );
        },
      ),
    );
  }
}

class _AnimatedTrustTile extends StatelessWidget {
  const _AnimatedTrustTile({
    required this.progress,
    required this.size,
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final double progress;
  final double size;
  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final double t = progress.clamp(0.0, 1.0);

    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 14),
        child: Transform.scale(
          scale: 0.84 + t * 0.16,
          child: Container(
            width: size,
            height: size,
            padding: EdgeInsets.symmetric(
              horizontal: size < 65 ? 5 : 7,
              vertical: size < 65 ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.94),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _C.cyan.withOpacity(0.18)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _C.navy.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  color: _C.teal,
                  size: size < 65 ? 20 : 24,
                ),
                SizedBox(height: size < 65 ? 3 : 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _C.font,
                    color: _C.deepNavy,
                    fontWeight: FontWeight.w900,
                    fontSize: size < 65 ? 10 : 11.5,
                    height: 1,
                  ),
                ),
                SizedBox(height: size < 65 ? 2 : 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _C.font,
                    color: _C.softText.withOpacity(0.78),
                    fontWeight: FontWeight.w700,
                    fontSize: size < 65 ? 7.5 : 8.5,
                    height: 1,
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

class _CentralTrustShield extends StatelessWidget {
  const _CentralTrustShield({
    required this.size,
    required this.compact,
  });

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[Color(0xFF24A9C4), Color(0xFF0D5E7B)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.95), width: 4),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _C.teal.withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Icon(
        Icons.verified_user_rounded,
        color: Colors.white,
        size: compact ? 30 : 36,
      ),
    );
  }
}


class _TrustConstellation extends StatelessWidget {
  const _TrustConstellation({required this.controller, required this.compact});

  final AnimationController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double centerSize = compact ? 48.0 : 64.0;
    final double memberSize = compact ? 42.0 : 50.0;
    final double orbitRadius = compact ? 56.0 : 70.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final double t = CurvedAnimation(parent: controller, curve: const Interval(0.10, 0.42, curve: Curves.easeOutCubic)).value;

        return CustomPaint(
          painter: _ConstellationLinePainter(memberCount: _trustMembers.length, orbitRadius: orbitRadius, progress: t),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Opacity(opacity: t.clamp(0.0, 1.0), child: _CenterAvatar(size: centerSize, compact: compact)),
              ...List<Widget>.generate(_trustMembers.length, (int i) {
                final double angle = (2 * math.pi / _trustMembers.length) * i - math.pi / 2;
                final double dx = math.cos(angle) * orbitRadius;
                final double dy = math.sin(angle) * orbitRadius;
                final double memberDelay = i / _trustMembers.length;
                final double memberT = ((t - memberDelay * 0.3) / 0.7).clamp(0.0, 1.0);

                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: Opacity(
                    opacity: memberT,
                    child: Transform.scale(
                      scale: 0.7 + memberT * 0.3,
                      child: _MemberAvatar(member: _trustMembers[i], size: memberSize, compact: compact),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ConstellationLinePainter extends CustomPainter {
  _ConstellationLinePainter({required this.memberCount, required this.orbitRadius, required this.progress});

  final int memberCount;
  final double orbitRadius;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Paint paint = Paint()
      ..color = _C.teal.withOpacity(0.30 * progress)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < memberCount; i++) {
      final double angle = (2 * math.pi / memberCount) * i - math.pi / 2;
      final double memberX = center.dx + math.cos(angle) * orbitRadius;
      final double memberY = center.dy + math.sin(angle) * orbitRadius;
      canvas.drawLine(center, Offset(memberX, memberY), paint);
      final Paint dotPaint = Paint()
        ..color = _C.teal.withOpacity(0.60 * progress)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(memberX, memberY), 4 * progress, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ConstellationLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.memberCount != memberCount || oldDelegate.orbitRadius != orbitRadius;
  }
}

class _CenterAvatar extends StatelessWidget {
  const _CenterAvatar({required this.size, required this.compact});

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEDF5FF),
            border: Border.all(color: _C.teal, width: 2.5),
            boxShadow: <BoxShadow>[
              BoxShadow(color: _C.teal.withOpacity(0.20), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Icon(Icons.person_rounded, color: _C.deepNavy, size: compact ? 30 : 36),
        ),
        SizedBox(height: compact ? 4 : 6),
        Text(
          'أنت',
          style: TextStyle(color: _C.deepNavy, fontWeight: FontWeight.w900, fontSize: compact ? 11 : 12),
        ),
      ],
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, required this.size, required this.compact});

  final _TrustMemberModel member;
  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  member.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEDF5FF),
                    child: Icon(member.icon, color: _C.deepNavy, size: compact ? 24 : 27),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 0,
              end: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: const BoxDecoration(color: _C.teal, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 11),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 3 : 5),
        Text(
          member.label,
          style: TextStyle(color: _C.deepNavy, fontWeight: FontWeight.w800, fontSize: compact ? 10 : 11),
        ),
      ],
    );
  }
}

class _NetworkProductsRow extends StatelessWidget {
  const _NetworkProductsRow({required this.products, required this.compact});

  final List<_NetworkProductModel> products;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final List<_NetworkProductModel> visibleProducts = products.take(3).toList();
    final double gap = compact ? 8.0 : 10.0;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count = visibleProducts.length;
        if (count == 0) return const SizedBox.shrink();

        final double totalGaps = gap * (count - 1);
        final double cardWidth = (constraints.maxWidth - totalGaps) / count;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(count, (int index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: cardWidth.clamp(76.0, 132.0),
                  child: _NetworkProductCard(product: visibleProducts[index], compact: compact),
                ),
                if (index != count - 1) SizedBox(width: gap),
              ],
            );
          }),
        );
      },
    );
  }
}

class _NetworkProductCard extends StatelessWidget {
  const _NetworkProductCard({required this.product, required this.compact});

  final _NetworkProductModel product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5F1F6)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              AspectRatio(
                aspectRatio: compact ? 1.22 : 1.18,
                child: Image.asset(
                  product.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _ImageFallback(icon: Icons.image_rounded),
                ),
              ),
              PositionedDirectional(
                top: 5,
                end: 5,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: compact ? 58 : 68),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: _C.deepNavy.withOpacity(0.92), borderRadius: BorderRadius.circular(99)),
                    child: Text(
                      product.fromLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800, height: 1.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 5 : 7, compact ? 5 : 7, compact ? 5 : 7, compact ? 6 : 8),
            child: Text(
              product.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _C.deepNavy, fontWeight: FontWeight.w900, fontSize: compact ? 10 : 11, height: 1.15),
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Shared UI
// ─────────────────────────────────────────────────────────────────────────────

class _C {
  static const Color navy = Color(0xFF061F3A);
  static const Color deepNavy = Color(0xFF082B49);
  static const Color petrol = Color(0xFF0B5471);
  static const Color teal = Color(0xFF0E989B);
  static const Color cyan = Color(0xFF24A9C4);
  static const Color softText = Color(0xFF3E6078);
  static const Color softBorder = Color(0xFFDCEEF5);
  static const String font = 'Cairo';
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.anim, required this.child, this.dy = 20});

  final Animation<double> anim;
  final Widget child;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, Widget? c) {
        final double v = anim.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * dy),
            child: Transform.scale(scale: 0.98 + v * 0.02, child: c),
          ),
        );
      },
      child: child,
    );
  }
}

class _IntroBackground extends StatelessWidget {
  const _IntroBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFF4FAFE), Color(0xFFFFFFFF), Color(0xFFF7FCFE)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -70,
            right: -40,
            child: _BgBlob(width: 210, height: 170, color: _C.cyan.withOpacity(0.10)),
          ),
          Positioned(
            top: 70,
            left: -60,
            child: _BgBlob(width: 180, height: 140, color: _C.teal.withOpacity(0.08)),
          ),
          Positioned(
            bottom: 130,
            right: -80,
            child: _BgBlob(width: 240, height: 190, color: _C.petrol.withOpacity(0.06)),
          ),
          Positioned(
            bottom: -70,
            left: -70,
            child: _BgBlob(width: 220, height: 180, color: _C.cyan.withOpacity(0.08)),
          ),
        ],
      ),
    );
  }
}

class _BgBlob extends StatelessWidget {
  const _BgBlob({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.logoAsset, required this.pulse, required this.compact});

  final String logoAsset;
  final AnimationController pulse;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double boxSize = compact ? 50 : 58;
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, Widget? child) {
        return Transform.scale(scale: 1.0 + pulse.value * 0.014, child: child);
      },
      child: Container(
        width: boxSize,
        height: boxSize,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.84),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: Colors.white.withOpacity(0.85)),
          boxShadow: <BoxShadow>[
            BoxShadow(color: _C.teal.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.white.withOpacity(0.70), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: Image.asset(
          logoAsset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => const Icon(Icons.swap_horiz_rounded, color: _C.teal, size: 34),
        ),
      ),
    );
  }
}


class _SmartIntroHeroSection extends StatelessWidget {
  const _SmartIntroHeroSection({
    required this.heroAsset,
    required this.compact,
    required this.veryCompact,
  });

  final String heroAsset;
  final bool compact;
  final bool veryCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ShaderMask(
          shaderCallback: (Rect bounds) => const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: <Color>[Color(0xFF061F3A), Color(0xFF0D7E9B)],
          ).createShader(bounds),
          child: Text(
            'تبديــل حل أذكى وأسهل',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: _C.font,
              color: Colors.white,
              fontSize: compact ? 20 : 23,
              fontWeight: FontWeight.w800,
              height: 1.28,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: compact ? 4 : 7),
        Text(
          'منتجاتك غير المستخدمة بدّلها بمنتجات مناسبة لك ولعائلتك',
          textAlign: TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: _C.font,
            color: _C.deepNavy.withOpacity(0.72),
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
        SizedBox(height: compact ? 7 : 12),
        _HeroArtwork(
          heroAsset: heroAsset,
          compact: compact,
          veryCompact: veryCompact,
        ),

      ],
    );
  }
}

class _HeroArtwork extends StatelessWidget {
  const _HeroArtwork({
    required this.heroAsset,
    required this.compact,
    required this.veryCompact,
  });

  final String heroAsset;
  final bool compact;
  final bool veryCompact;

  @override
  Widget build(BuildContext context) {
    final double height = veryCompact ? 100 : (compact ? 130 : 200);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.88,
                  colors: <Color>[
                    const Color(0xFFDBF2F8).withOpacity(0.38),
                    const Color(0xFFEAF7FB).withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              heroAsset,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.swap_horiz_rounded,
                color: _C.teal,
                size: 64,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainHeader extends StatelessWidget {
  const _MainHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ShaderMask(
          shaderCallback: (Rect bounds) => const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: <Color>[Color(0xFF061F3A), Color(0xFF0D7E9B)],
          ).createShader(bounds),
          child: Text(
            'تبديل حل أذكى وأسهل',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _C.font,
              color: Colors.white,
              fontSize: compact ? 23 : 27,
              fontWeight: FontWeight.w900,
              height: 1.28,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: compact ? 5 : 7),
        Text(
          'منتجاتك غير المستخدمة بدّلها بمنتجات مناسبة لك ولعائلتك',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: _C.font,
            color: _C.deepNavy.withOpacity(0.72),
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w600,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _StepHeaderPill extends StatelessWidget {
  const _StepHeaderPill({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.compact,
  });

  final String step;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 13, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.92)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: _C.navy.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 7)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: compact ? 40 : 48,
            height: compact ? 40 : 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: <Color>[Color(0xFF24A9C4), Color(0xFF0D5E7B)]),
              border: Border.all(color: Colors.white.withOpacity(0.92), width: 2.5),
              boxShadow: <BoxShadow>[
                BoxShadow(color: _C.teal.withOpacity(0.20), blurRadius: 12, offset: const Offset(0, 5)),
              ],
            ),
            child: Text(
              step,
              style: TextStyle(fontFamily: _C.font, color: Colors.white, fontSize: compact ? 14 : 15, fontWeight: FontWeight.w900, height: 1),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: _C.font, color: _C.navy, fontSize: compact ? 15.5 : 18, fontWeight: FontWeight.w900, height: 1.20),
                ),
                SizedBox(height: compact ? 3 : 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: _C.font, color: _C.softText.withOpacity(0.88), fontSize: compact ? 10.8 : 12, fontWeight: FontWeight.w700, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSectionTitle extends StatelessWidget {
  const _MiniSectionTitle({required this.title, required this.icon, required this.compact});

  final String title;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 7 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _C.softBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(color: _C.navy.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: _C.teal, size: compact ? 14 : 15),
          const SizedBox(width: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _C.deepNavy, fontWeight: FontWeight.w900, fontSize: compact ? 11.5 : 12.5, height: 1.0),
          ),
        ],
      ),
    );
  }
}

class _SolidAiTagChip extends StatelessWidget {
  const _SolidAiTagChip({required this.icon, required this.text, required this.compact});

  final IconData icon;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: compact ? 122 : 142),
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 6 : 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: <double>[0.0, 0.45, 1.0],
          colors: <Color>[Color(0xFF082B49), Color(0xFF3B5B86), Color(0xFF0D7E9B)],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[
          BoxShadow(color: _C.teal.withOpacity(0.22), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: compact ? 12 : 13),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: compact ? 9.8 : 10.8, fontWeight: FontWeight.w800, height: 1.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (int index) {
        final bool active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? _C.teal : _C.softBorder,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}


class _HeroReadHint extends StatelessWidget {
  const _HeroReadHint({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: compact ? 4 : 8),
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 9 : 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.92)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: _C.navy.withOpacity(0.045), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: compact ? 32 : 36,
            height: compact ? 32 : 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: <Color>[Color(0xFF24A9C4), Color(0xFF0D5E7B)]),
              boxShadow: <BoxShadow>[
                BoxShadow(color: _C.teal.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تبديل حل أسهل… اتعرف على خطوات التبديل',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _C.font,
                color: _C.deepNavy.withOpacity(0.82),
                fontWeight: FontWeight.w800,
                fontSize: compact ? 11.5 : 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepNavigationBar extends StatelessWidget {
  const _StepNavigationBar({
    required this.visible,
    required this.activeIndex,
    required this.onPrevious,
    required this.onNext,
    required this.compact,
  });

  final bool visible;
  final int activeIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = visible && activeIndex > 0;
    final String nextLabel = !visible
        ? 'ابدأ الشرح'
        : activeIndex == 2
        ? 'ابدأ'
        : 'التالي';

    return Row(
      children: <Widget>[
        _RoundStepNavButton(
          icon: Icons.arrow_back_rounded,
          label: 'السابق',
          enabled: canGoBack,
          onTap: onPrevious,
          compact: compact,
        ),
        Expanded(
          child: _StepDots(activeIndex: activeIndex),
        ),
        _RoundStepNavButton(
          icon: Icons.arrow_forward_rounded,
          label: nextLabel,
          enabled: true,
          onTap: onNext,
          compact: compact,
          highlight: true,
        ),
      ],
    );
  }
}

class _RoundStepNavButton extends StatelessWidget {
  const _RoundStepNavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.compact,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool compact;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final Color bg = highlight ? _C.teal : Colors.white.withOpacity(0.92);
    final Color fg = highlight ? Colors.white : _C.deepNavy;

    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: compact ? 36 : 40,
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: highlight ? _C.teal : _C.softBorder),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: (highlight ? _C.teal : _C.navy).withOpacity(highlight ? 0.18 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: _C.font,
                    color: fg,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 11 : 12,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, color: fg, size: compact ? 16 : 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryIntroButton extends StatefulWidget {
  const _PrimaryIntroButton({required this.text, required this.shimmer, required this.onTap});

  final String text;
  final AnimationController shimmer;
  final VoidCallback onTap;

  @override
  State<_PrimaryIntroButton> createState() => _PrimaryIntroButtonState();
}

class _PrimaryIntroButtonState extends State<_PrimaryIntroButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: <Color>[Color(0xFF061F3A), Color(0xFF0D5E7B), Color(0xFF0FA3A6)],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(color: const Color(0xFF0D5E7B).withOpacity(_pressed ? 0.34 : 0.24), blurRadius: _pressed ? 32 : 24, offset: const Offset(0, 12)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: <Widget>[
                AnimatedBuilder(
                  animation: widget.shimmer,
                  builder: (_, __) {
                    return Positioned.fill(
                      child: FractionalTranslation(
                        translation: Offset((widget.shimmer.value * 2.4) - 1.2, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Colors.white.withOpacity(0.00),
                                  Colors.white.withOpacity(0.20),
                                  Colors.white.withOpacity(0.00),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.text,
                        style: const TextStyle(fontFamily: _C.font, color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 9),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                    ],
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

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _C.cyan.withOpacity(0.48), width: 1.4),
          ),
          child: Text(
            text,
            style: const TextStyle(fontFamily: _C.font, color: _C.deepNavy, fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF8FF),
      alignment: Alignment.center,
      child: Icon(icon, color: _C.teal, size: 34),
    );
  }
}
