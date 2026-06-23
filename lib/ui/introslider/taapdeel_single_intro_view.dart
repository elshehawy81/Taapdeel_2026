import 'dart:async';
import 'package:flutter/material.dart';

/// Standalone Single Intro page.
///
/// Clean production-ready version:
/// - Static main title and subtitle never disappear.
/// - Stage 0 shows the hero artwork + motivation chips first.
/// - Stages 1/2 show the onboarding steps in the same card area.
/// - Visual language matches the Profile Setup screen: soft background,
///   white translucent cards, 28/30px radii, navy/teal gradient accents.
///
/// Sequential reveal order (first load):
///   1. Header card (logo + main title)        → immediately via _introController
///   2. Hero artwork + chips                    → after 650 ms  (_sceneRevealController)
///   3. Stepper layers are revealed only after the user moves to step 1.
///
/// On stage change (manual or auto):
///   Stepper updates instantly (AnimatedContainer colours).
///   Subtitle fades out → new one fades in (AnimatedSwitcher key-swap).
///   Scene fades out → new one fades in + _sceneRevealController re-runs.
class TaapdeelSingleIntroView extends StatefulWidget {
  const TaapdeelSingleIntroView({
    Key? key,
    this.logoAsset = 'assets/images/Taapdeel_logo.png',
    this.heroAsset = 'assets/images/taapdeel_intro_center_illustration.png',
    this.buttonText = 'إبدأ',
    this.showSkipButton = true,
    this.onStart,
    this.onSkip,
  }) : super(key: key);

  final String logoAsset;
  final String heroAsset;
  final String buttonText;
  final bool showSkipButton;
  final VoidCallback? onStart;
  final VoidCallback? onSkip;

  @override
  State<TaapdeelSingleIntroView> createState() => _TaapdeelSingleIntroViewState();
}

class _TaapdeelSingleIntroViewState extends State<TaapdeelSingleIntroView>
    with TickerProviderStateMixin {

  // ── persistent controllers ────────────────────────────────────────────────
  late final AnimationController _introController;      // header card entrance
  late final AnimationController _sceneController;      // per-step scene timeline
  late final AnimationController _logoPulse;
  late final AnimationController _buttonShimmer;
  late final AnimationController _nextHintController;

  // ── sequential reveal controllers (first load) ────────────────────────────
  late final AnimationController _stepperRevealController;   // title + stepper
  late final AnimationController _subtitleRevealController;  // subtitle pill
  late final AnimationController _sceneRevealController;     // scene card

  // ── timers ────────────────────────────────────────────────────────────────
  Timer? _stageTimer;
  Timer? _stepperRevealTimer;
  Timer? _subtitleRevealTimer;
  Timer? _sceneRevealTimer;
  Timer? _stageTransitionSubtitleTimer;
  Timer? _stageTransitionSceneTimer;

  /// 0 = intro hero artwork, 1 = Add product, 2 = Compare.
  int _stageIndex = 0;
  bool _userInteracted = false;
  bool _firstLoadDone = false;
  bool _nextHintReady = false;  // becomes true once all 3 reveal layers have fired

  static const Duration _sceneDuration    = Duration(milliseconds: 10000);
  static const Duration _stepHoldDuration = Duration(milliseconds: 10000);

  // ── first-load reveal delays ──────────────────────────────────────────────
  static const Duration _stepperDelay  = Duration(milliseconds: 900);
  static const Duration _subtitleDelay = Duration(milliseconds: 1500);
  static const Duration _sceneDelay    = Duration(milliseconds: 650);

  // ── stage-transition reveal delays ───────────────────────────────────────
  static const Duration _transSubtitleDelay = Duration(milliseconds: 260);
  static const Duration _transSceneDelay    = Duration(milliseconds: 620);

  bool get _isIntroHeroStage => _stageIndex == 0;
  bool get _isFinalStepStage => _stageIndex == 2;
  int  get _activeStepIndex  => (_stageIndex - 1).clamp(0, 1);

  String get _headerTitle {
    if (_stageIndex == 0) return 'تبديــل حل أذكى';
    if (_stageIndex == 1) return 'تبديل حل أسهل';
    return 'تبديل حل آمن';
  }

  String get _headerSubtitle {
    if (_stageIndex == 0) {
      return 'منتجاتك غير المستخدمة\nبدّلــها\nبمنتجات مناسبة لك ولعائلتك';
    }

    if (_stageIndex == 1) {
      return 'وفّر وقتك وفلوسك\nمش محتاج بيع وشراء وفصال';
    }

    return 'بدّل وأنت مطمن\nترشيحات من اصدقاءك واقاربك';
  }

  String? get _nextStageLabel {
    if (_stageIndex == 0) return 'جولة تعريفية';
    if (_stageIndex == 1) return 'الخطوة 2';
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _sceneController = AnimationController(
      vsync: this,
      duration: _sceneDuration,
      animationBehavior: AnimationBehavior.preserve,
    )..forward();

    _logoPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _buttonShimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    )..repeat();

    _nextHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
      animationBehavior: AnimationBehavior.preserve,
    );

    _sceneController.addStatusListener(_handleSceneStatus);

    // Reveal controllers – all start at 0 and play once.
    _stepperRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
      animationBehavior: AnimationBehavior.preserve,
    );

    _subtitleRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
      animationBehavior: AnimationBehavior.preserve,
    );

    _sceneRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
      animationBehavior: AnimationBehavior.preserve,
    );

    // ── fire reveal layers sequentially ──────────────────────────────────
    _stepperRevealTimer = Timer(_stepperDelay, () {
      if (!mounted) return;
      _stepperRevealController.forward();
    });

    _subtitleRevealTimer = Timer(_subtitleDelay, () {
      if (!mounted) return;
      _subtitleRevealController.forward();
    });

    _sceneRevealTimer = Timer(_sceneDelay, () {
      if (!mounted) return;
      _sceneRevealController.forward().whenComplete(() {
        if (!mounted) return;
        _firstLoadDone = true;
      });
    });
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _stepperRevealTimer?.cancel();
    _subtitleRevealTimer?.cancel();
    _sceneRevealTimer?.cancel();
    _stageTransitionSubtitleTimer?.cancel();
    _stageTransitionSceneTimer?.cancel();

    _sceneController.removeStatusListener(_handleSceneStatus);

    _introController.dispose();
    _sceneController.dispose();
    _logoPulse.dispose();
    _buttonShimmer.dispose();
    _nextHintController.dispose();
    _stepperRevealController.dispose();
    _subtitleRevealController.dispose();
    _sceneRevealController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  Animation<double> _ease(double begin, double end) {
    return CurvedAnimation(
      parent: _introController,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  void _handleSceneStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted || _stageIndex >= 2) {
      return;
    }

    if (!_nextHintReady) {
      setState(() => _nextHintReady = true);
    }

    if (!_nextHintController.isAnimating) {
      _nextHintController.repeat(reverse: true);
    }
  }

  void _resetNextHint() {
    _nextHintController
      ..stop()
      ..reset();

    if (_nextHintReady) {
      setState(() => _nextHintReady = false);
    }
  }

  void _restartSceneController() {
    _resetNextHint();
    _sceneController
      ..stop()
      ..reset()
      ..forward();
  }

  /// After a stage change reset subtitle + scene reveal controllers and
  /// replay them with short staggered delays so the user reads subtitle
  /// before the scene appears.
  void _restartContentReveal() {
    // Cancel any in-flight transition timers.
    _stageTransitionSubtitleTimer?.cancel();
    _stageTransitionSceneTimer?.cancel();

    // Immediately hide both layers.
    _subtitleRevealController
      ..stop()
      ..reset();
    _sceneRevealController
      ..stop()
      ..reset();

    // Subtitle in first.
    _stageTransitionSubtitleTimer = Timer(_transSubtitleDelay, () {
      if (!mounted) return;
      _subtitleRevealController.forward();
    });

    // Scene in second.
    _stageTransitionSceneTimer = Timer(_transSceneDelay, () {
      if (!mounted) return;
      _sceneRevealController.forward();
    });
  }

  void _scheduleNextStage() {
    // Auto stage navigation is intentionally disabled.
    // The user moves forward only by tapping the quick next arrow.
    _stageTimer?.cancel();
  }

  void _goToStage(int index, {required bool manual}) {
    if (index < 0 || index > 2) return;

    if (manual) {
      _userInteracted = true;
      _stageTimer?.cancel();
    }

    if (index > 0 && _stepperRevealController.value < 1.0) {
      _stepperRevealTimer?.cancel();
      _stepperRevealController.forward();
    }

    setState(() => _stageIndex = index);
    _restartSceneController();

    // Only run the staggered reveal if the first-load hero sequence is already done.
    if (_firstLoadDone) {
      _restartContentReveal();
    }

  }

  void _goToStep(int stepIndex, {required bool manual}) {
    _goToStage(stepIndex + 1, manual: manual);
  }

  void _nextStage() {
    if (_stageIndex < 2) {
      _goToStage(_stageIndex + 1, manual: true);
      return;
    }
    _start();
  }

  void _quickNextStage() {
    if (_stageIndex >= 2) return;

    _stageTimer?.cancel();

    // If the user jumps forward while the first-load stagger is still running,
    // reveal all layers so the next step appears immediately and cleanly.
    if (!_firstLoadDone) {
      _stepperRevealTimer?.cancel();
      _subtitleRevealTimer?.cancel();
      _sceneRevealTimer?.cancel();

      _stepperRevealController.forward();
      _subtitleRevealController.forward();
      _sceneRevealController.forward();
      _firstLoadDone = true;
    }

    _goToStage(_stageIndex + 1, manual: true);
  }

  void _previousStage() {
    if (_stageIndex > 0) {
      _goToStage(_stageIndex - 1, manual: true);
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

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final Size size = media.size;
    final double shortestSide = size.shortestSide;
    final bool compact = size.height < 780 || size.width < 380;
    final bool veryCompact = size.height < 705 || size.width < 340;
    final bool ultraCompact = size.height < 640 || size.width < 330;

    final double horizontalPadding = shortestSide < 340 ? 10 : 14;
    final double contentGap = ultraCompact ? 6 : (compact ? 8 : 10);
    final double buttonHeight = compact ? 48 : 52;
    final double bottomButtonsReserve = buttonHeight + media.padding.bottom + (compact ? 30 : 36);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF6FBFE),
        body: Stack(
          children: <Widget>[
            const Positioned.fill(child: _TaapdeelSetupLikeBackground()),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  ultraCompact ? 10 : 15,
                  horizontalPadding,
                  bottomButtonsReserve,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        _FadeSlide(
                          anim: _ease(0.00, 0.35),
                          dy: -10,
                          child: _SetupLikeHeaderCard(
                            logoAsset: widget.logoAsset,
                            pulse: _logoPulse,
                            compact: compact,
                            title: _headerTitle,
                            subtitle: _headerSubtitle,
                          ),
                        ),
                        SizedBox(height: contentGap),
                        Expanded(
                          child: _FadeSlide(
                            anim: _ease(0.16, 0.64),
                            dy: 16,
                            child: _SetupLikeContentCard(
                              activeStepIndex:      _activeStepIndex,
                              isIntroHeroStage:     _isIntroHeroStage,
                              sceneController:      _sceneController,
                              stepperReveal:        _stepperRevealController,
                              subtitleReveal:       _subtitleRevealController,
                              sceneReveal:          _sceneRevealController,
                              heroAsset:            widget.heroAsset,
                              compact:              compact,
                              veryCompact:          veryCompact,
                              onStepTap: (int index) => _goToStep(index, manual: true),
                              onQuickNextTap: _quickNextStage,
                              nextHint: _nextHintController,
                              nextHintReady: _nextHintReady,
                              nextHintLabel: _nextStageLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding + 4,
                    8,
                    horizontalPadding + 4,
                    compact ? 8 : 12,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _FadeSlide(
                        anim: _ease(0.55, 1.00),
                        dy: 22,
                        child: Row(
                          children: <Widget>[
                            if (_isFinalStepStage) ...<Widget>[
                              Expanded(
                                child: _PrimaryIntroButton(
                                  text: widget.buttonText,
                                  shimmer: _buttonShimmer,
                                  isFinalState: true,
                                  onTap: _start,
                                ),
                              ),
                            ] else ...<Widget>[
                              Expanded(
                                flex: 4,
                                child: _PrimaryIntroButton(
                                  text: 'تخطي',
                                  shimmer: _buttonShimmer,
                                  isFinalState: false,
                                  onTap: _skip,
                                ),
                              ),
                              SizedBox(width: compact ? 10 : 12),
                              Expanded(
                                flex: 6,
                                child: _QuickNextStageButton(
                                  compact: compact,
                                  onTap: _quickNextStage,
                                  hint: _nextHintController,
                                  hintReady: _nextHintReady,
                                  hintLabel: _nextStageLabel,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
// Static content
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
  final int    percent;
  final String label;
  final List<_ReasonChipModel> reasons;
}

class _ReasonChipModel {
  const _ReasonChipModel({required this.icon, required this.label});
  final IconData icon;
  final String   label;
}


class _StepData {
  const _StepData({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String   number;
  final String   title;
  final String   subtitle;
  final IconData icon;
}

const _IntroProductModel _myProduct = _IntroProductModel(
  title:      'سماعة Airpod',
  imageAsset: 'assets/images/products/Airpod.png',
  percent:    0,
  label:      '',
  reasons:    <_ReasonChipModel>[],
);

const List<_StepData> _introStepItems = <_StepData>[
  _StepData(
    number:   '1',
    title:    'صوّر منتجاتك',
    subtitle: 'صور منتجك والباقي علينا',
    icon:     Icons.camera_alt_rounded,
  ),
  _StepData(
    number:   '2',
    title:    'بدّل بأمان',
    subtitle: 'ترشيحات مناسبة لاهتماماتك \nواهتمامات عائلتك',
    icon:     Icons.compare_arrows_rounded,
  ),
];


const List<_IntroProductModel> _candidateProducts = <_IntroProductModel>[
  _IntroProductModel(
    title:      'ادوات دراسية',
    imageAsset: 'assets/images/products/bag.png',
    percent:    76,
    label:      'فرصة مناسبة',
    reasons: <_ReasonChipModel>[
      _ReasonChipModel(icon: Icons.location_on_rounded,   label: 'نفس المنطقة'),
      _ReasonChipModel(icon: Icons.verified_user_rounded, label: 'من صديقك'),
    ],
  ),
  _IntroProductModel(
    title:      'الكترونيات',
    imageAsset: 'assets/images/products/05_gaming_setup_white.jpg',
    percent:    81,
    label:      'فرصة ممتازة',
    reasons: <_ReasonChipModel>[
      _ReasonChipModel(icon: Icons.verified_rounded, label: 'كسر زيرو'),
      _ReasonChipModel(icon: Icons.sell_rounded,     label: 'من اهتماماتك'),
    ],
  ),
  _IntroProductModel(
    title:      'ازياء',
    imageAsset: 'assets/images/products/04_dress_bag_accessories.png',
    percent:    86,
    label:      'فرصة ذهبية',
    reasons: <_ReasonChipModel>[
      _ReasonChipModel(icon: Icons.auto_awesome_rounded,  label: 'استخدام 3 شهور'),
      _ReasonChipModel(icon: Icons.price_check_rounded,   label: 'مناسب لعائلتك'),
    ],
  ),
  _IntroProductModel(
    title:      'العاب',
    imageAsset: 'assets/images/products/toys.png',
    percent:    65,
    label:      'تبديل مناسب',
    reasons: <_ReasonChipModel>[
      _ReasonChipModel(icon: Icons.auto_awesome_rounded,  label: 'نفس متوسط السعر'),
      _ReasonChipModel(icon: Icons.price_check_rounded,   label: 'مناسب لابنك'),
    ],
  ),
  _IntroProductModel(
    title:      'رياضه',
    imageAsset: 'assets/images/products/fitness.jpg',
    percent:    70,
    label:      'فرصة ممتازة',
    reasons: <_ReasonChipModel>[
      _ReasonChipModel(icon: Icons.auto_awesome_rounded,  label: 'نفس الحي'),
      _ReasonChipModel(icon: Icons.price_check_rounded,   label: 'من قريبك'),
    ],
  ),
];


// ─────────────────────────────────────────────────────────────────────────────
// Main layout cards
// ─────────────────────────────────────────────────────────────────────────────

class _SetupLikeHeaderCard extends StatelessWidget {
  const _SetupLikeHeaderCard({
    required this.logoAsset,
    required this.pulse,
    required this.compact,
    required this.title,
    required this.subtitle,
  });

  final String logoAsset;
  final AnimationController pulse;
  final bool compact;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, compact ? 15 : 18, 18, compact ? 15 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end:   AlignmentDirectional.bottomEnd,
          colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF6FBFE), Color(0xFFEAF6FB)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.92)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color:      const Color(0xFF072D56).withOpacity(0.08),
            blurRadius: 28,
            offset:     const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          PositionedDirectional(
            top: -38, start: -34,
            child: _SoftCircle(size: 120, color: _C.cyan.withOpacity(0.08)),
          ),
          PositionedDirectional(
            bottom: -46, end: -38,
            child: _SoftCircle(size: 150, color: const Color(0xFF0FA3A6).withOpacity(0.07)),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.rtl,
                    children: <Widget>[
                      _LogoBadge(
                        logoAsset: logoAsset,
                        pulse: pulse,
                        compact: true,
                      ),
                      SizedBox(width: compact ? 8 : 10),
                      Flexible(
                        child: Text(
                          title,
                          key: ValueKey<String>('header-title-$title'),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _C.font,
                            color: const Color(0xFF072D56),
                            fontWeight: FontWeight.w900,
                            fontSize: compact ? 21 : 24,
                            height: 1.20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  key: ValueKey<String>('header-subtitle-$subtitle'),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _C.font,
                    color: const Color(0xFF315A7A).withOpacity(0.88),
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 13 : 15,
                    height: 1.75,
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

// ─────────────────────────────────────────────────────────────────────────────

class _SetupLikeContentCard extends StatelessWidget {
  const _SetupLikeContentCard({
    required this.activeStepIndex,
    required this.isIntroHeroStage,
    required this.sceneController,
    required this.stepperReveal,
    required this.subtitleReveal,
    required this.sceneReveal,
    required this.heroAsset,
    required this.compact,
    required this.veryCompact,
    required this.onStepTap,
    required this.onQuickNextTap,
    required this.nextHint,
    required this.nextHintReady,
    required this.nextHintLabel,
  });

  final int  activeStepIndex;
  final bool isIntroHeroStage;
  final AnimationController sceneController;
  final AnimationController stepperReveal;
  final AnimationController subtitleReveal;
  final AnimationController sceneReveal;
  final String heroAsset;
  final bool compact;
  final bool veryCompact;
  final ValueChanged<int> onStepTap;
  final VoidCallback onQuickNextTap;
  final AnimationController nextHint;
  final bool nextHintReady;
  final String? nextHintLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(compact ? 10 : 16, compact ? 10 : 16, compact ? 10 : 16, compact ? 10 : 16),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border:       Border.all(color: Colors.white.withOpacity(0.92)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color:      const Color(0xFF072D56).withOpacity(0.07),
            blurRadius: 24,
            offset:     const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: _StepContentStage(
          activeStepIndex:  activeStepIndex,
          showIntroHero:    isIntroHeroStage,
          heroAsset:        heroAsset,
          sceneController:  sceneController,
          stepperReveal:    stepperReveal,
          subtitleReveal:   subtitleReveal,
          sceneReveal:      sceneReveal,
          compact:          compact,
          veryCompact:      veryCompact,
          onStepTap:        onStepTap,
          onQuickNextTap:  onQuickNextTap,
          nextHint:        nextHint,
          nextHintReady:   nextHintReady,
          nextHintLabel:   nextHintLabel,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero (final stage)
// ─────────────────────────────────────────────────────────────────────────────

class _HeroContentStage extends StatelessWidget {
  const _HeroContentStage({
    Key? key,
    required this.heroAsset,
    required this.compact,
    required this.veryCompact,
  }) : super(key: key);

  final String heroAsset;
  final bool compact;
  final bool veryCompact;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double heroHeight = (width * (compact ? 0.72 : 0.80))
        .clamp(
      veryCompact ? 180.0 : 200.0,
      compact ? 240.0 : 280.0,
    )
        .toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width:  double.infinity,
          height: heroHeight,
          child: Container(
            decoration: BoxDecoration(
              color:        const Color(0xFFF8FCFE),
              borderRadius: BorderRadius.circular(22),
              border:       Border.all(color: const Color(0xFF0C587A).withOpacity(0.06)),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                PositionedDirectional(
                  top: -22, start: -18,
                  child: _SoftCircle(size: 96, color: _C.cyan.withOpacity(0.07)),
                ),
                PositionedDirectional(
                  bottom: -28, end: -24,
                  child: _SoftCircle(size: 130, color: _C.teal.withOpacity(0.06)),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 8 : 10, compact ? 4 : 6,
                      compact ? 8 : 10, compact ? 4 : 6,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: compact ? 1.08 : 1.12,
                        child: Image.asset(
                          heroAsset,
                          fit:           BoxFit.contain,
                          alignment:     Alignment.center,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.swap_horiz_rounded, color: _C.teal, size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: compact ? 9 : 11),
        _HeroMotivationSection(compact: compact, veryCompact: veryCompact),
      ],
    );
  }
}

class _HeroMotivationSection extends StatelessWidget {
  const _HeroMotivationSection({required this.compact, required this.veryCompact});

  final bool compact;
  final bool veryCompact;

  static const List<_HeroMotivationItem> _items = <_HeroMotivationItem>[
    _HeroMotivationItem(Icons.savings_rounded,        'وفّر فلوسك'),
    _HeroMotivationItem(Icons.auto_awesome_rounded,   'جدّد حياتك'),
    _HeroMotivationItem(Icons.family_restroom_rounded,'فرّح عيلتك'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 12, compact ? 9 : 11, compact ? 10 : 12, compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border:       Border.all(color: _C.cyan.withOpacity(0.16)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: _C.navy.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:      MainAxisSize.min,
            children: <Widget>[
              Text(
                'مع تبديل \n بخطوات بسيطه تقدر تجيب اللي نفسك فيه',
                textAlign: TextAlign.center,
                maxLines:  2,
                overflow:  TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: _C.font,
                  color: const Color(0xFF072D56),
                  fontWeight: FontWeight.w900,
                  fontSize:   compact ? 12 : 14, height: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 16),
          Row(
            children: List<Widget>.generate(_items.length, (int index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: index == 0 ? 0 : (compact ? 3.0 : 3.5),
                    end:   index == _items.length - 1 ? 0 : (compact ? 3.0 : 3.5),
                  ),
                  child: _HeroMotivationChip(item: _items[index], compact: compact, veryCompact: veryCompact),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HeroMotivationItem {
  const _HeroMotivationItem(this.icon, this.text);
  final IconData icon;
  final String   text;
}

class _HeroMotivationChip extends StatelessWidget {
  const _HeroMotivationChip({required this.item, required this.compact, required this.veryCompact});

  final _HeroMotivationItem item;
  final bool compact;
  final bool veryCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 7, vertical: compact ? 6 : 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  AlignmentDirectional.topStart,
          end:    AlignmentDirectional.bottomEnd,
          colors: <Color>[const Color(0xFFEAF8FF), Colors.white.withOpacity(0.98)],
        ),
        borderRadius: BorderRadius.circular(999),
        border:       Border.all(color: _C.softBorder.withOpacity(0.95)),
      ),
      child: Row(
        mainAxisSize:      MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(item.icon, color: _C.teal, size: compact ? 12 : 13),
          SizedBox(width: compact ? 3 : 4),
          Flexible(
            child: Text(
              item.text,
              maxLines:  1,
              overflow:  TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _C.font, color: _C.deepNavy,
                fontWeight: FontWeight.w900,
                fontSize:   compact ? 8 : 10, height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StepContentStage  —  the fixed content card with 3-layer staggered reveal
// ─────────────────────────────────────────────────────────────────────────────

class _StepContentStage extends StatelessWidget {
  const _StepContentStage({
    Key? key,
    required this.activeStepIndex,
    required this.showIntroHero,
    required this.heroAsset,
    required this.sceneController,
    required this.stepperReveal,
    required this.subtitleReveal,
    required this.sceneReveal,
    required this.compact,
    required this.veryCompact,
    required this.onStepTap,
    required this.onQuickNextTap,
    required this.nextHint,
    required this.nextHintReady,
    required this.nextHintLabel,
  }) : super(key: key);

  final int  activeStepIndex;
  final bool showIntroHero;
  final String heroAsset;
  final AnimationController sceneController;
  final AnimationController stepperReveal;
  final AnimationController subtitleReveal;
  final AnimationController sceneReveal;
  final bool compact;
  final bool veryCompact;
  final ValueChanged<int> onStepTap;
  final VoidCallback onQuickNextTap;
  final AnimationController nextHint;
  final bool nextHintReady;
  final String? nextHintLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: compact ? 14 : 18),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (showIntroHero) ...<Widget>[
                  _RevealFromAnimation(
                    animation: CurvedAnimation(
                      parent: sceneReveal,
                      curve: Curves.easeOutCubic,
                    ),
                    dy: 18,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _HeroContentStage(
                        key: const ValueKey<String>('intro-hero-stage'),
                        heroAsset: heroAsset,
                        compact: compact,
                        veryCompact: veryCompact,
                      ),
                    ),
                  ),
                ] else ...<Widget>[

                  _RevealFromAnimation(
                    animation: CurvedAnimation(
                      parent: stepperReveal,
                      curve: const Interval(0.35, 1.00, curve: Curves.easeOutCubic),
                    ),
                    dy: 15,
                    child: _IntroStepsStepper(
                      activeIndex: activeStepIndex,
                      compact: compact,
                      onStepTap: onStepTap,
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 14),

                  _RevealFromAnimation(
                    animation: CurvedAnimation(
                      parent: subtitleReveal,
                      curve: Curves.easeOutCubic,
                    ),
                    dy: 12,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      reverseDuration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (Widget child, Animation<double> anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: _StepSceneSubtitle(
                        key: ValueKey<int>(activeStepIndex),
                        text: _introStepItems[activeStepIndex].subtitle,
                        compact: compact,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 16),

                  _RevealFromAnimation(
                    animation: CurvedAnimation(
                      parent: sceneReveal,
                      curve: Curves.easeOutCubic,
                    ),
                    dy: 18,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _SingleIntroStepSwitcher(
                        stepIndex: activeStepIndex,
                        controller: sceneController,
                        compact: compact,
                        veryCompact: veryCompact,
                        onQuickNextTap: onQuickNextTap,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step switcher and stepper
// ─────────────────────────────────────────────────────────────────────────────

class _SingleIntroStepSwitcher extends StatelessWidget {
  const _SingleIntroStepSwitcher({
    required this.stepIndex,
    required this.controller,
    required this.compact,
    required this.veryCompact,
    required this.onQuickNextTap,
  });

  final int stepIndex;
  final AnimationController controller;
  final bool compact;
  final bool veryCompact;
  final VoidCallback onQuickNextTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration:        const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 280),
      switchInCurve:   Curves.easeOutCubic,
      switchOutCurve:  Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end:   Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey<int>(stepIndex),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (stepIndex == 0)
            _AddProductAiScanScene(
              controller: controller,
              compact: compact,
            )
          else
            _CompareRecommendationsScene(controller: controller, compact: compact),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared animation helper
// ─────────────────────────────────────────────────────────────────────────────

class _RevealFromAnimation extends StatelessWidget {
  const _RevealFromAnimation({
    required this.animation,
    required this.child,
    this.dy = 12,
  });

  final Animation<double> animation;
  final Widget child;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, Widget? c) {
        final double value = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * dy),
            child:  c,
          ),
        );
      },
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stepper UI
// ─────────────────────────────────────────────────────────────────────────────

class _StepperSectionTitle extends StatelessWidget {
  const _StepperSectionTitle({
    required this.compact,
    required this.showQuickNext,
    required this.onQuickNextTap,
    required this.nextHint,
    required this.nextHintReady,
    required this.nextHintLabel,
  });

  final bool compact;
  final bool showQuickNext;
  final VoidCallback onQuickNextTap;
  final AnimationController nextHint;
  final bool nextHintReady;
  final String? nextHintLabel;

  @override
  Widget build(BuildContext context) {
    final Text title = Text(
      'خطوات بسيطة للتبديل',
      textAlign: TextAlign.right,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: _C.font,
        color: const Color(0xFF072D56),
        fontWeight: FontWeight.w900,
        fontSize: compact ? 14.5 : 16,
        height: 1.25,
      ),
    );

    return Center(child: title);
  }
}

class _IntroStepsStepper extends StatelessWidget {
  const _IntroStepsStepper({
    required this.activeIndex,
    required this.compact,
    required this.onStepTap,
  });

  final int  activeIndex;
  final bool compact;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          for (int index = 0; index < _introStepItems.length; index++) ...<Widget>[
            Expanded(
              child: _PlainStepperItem(
                data:      _introStepItems[index],
                active:    index == activeIndex,
                completed: index < activeIndex,
                compact:   compact,
                onTap:     () => onStepTap(index),
              ),
            ),
            if (index != _introStepItems.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve:    Curves.easeOutCubic,
                  width:    compact ? 20 : 26,
                  height:   2,
                  decoration: BoxDecoration(
                    color: index < activeIndex
                        ? const Color(0xFF4FACFE).withOpacity(0.72)
                        : _C.softBorder.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PlainStepperItem extends StatelessWidget {
  const _PlainStepperItem({
    required this.data,
    required this.active,
    required this.completed,
    required this.compact,
    required this.onTap,
  });

  final _StepData data;
  final bool active;
  final bool completed;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool emphasized = active || completed;
    final Color titleColor = emphasized ? Colors.white : _C.deepNavy;
    final Color numberColor = emphasized ? _C.deepNavy : _C.teal;
    final Color numberBg = emphasized ? Colors.white.withOpacity(0.96) : const Color(0xFFEAF8FF);

    final LinearGradient cardGradient = active
        ? const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: <Color>[
        Color(0xFF4FACFE),
        Color(0xFF00F2FE),
      ],
    )
        : completed
        ? const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: <Color>[
        Color(0xFF061F3A),
        Color(0xFF0D5E7B),
        Color(0xFF24A9C4),
      ],
    )
        : LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: <Color>[
        Colors.white,
        const Color(0xFFF3FBFE).withOpacity(0.98),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: compact ? 58 : 68,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 8,
            vertical: compact ? 7 : 8,
          ),
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: emphasized ? Colors.white.withOpacity(0.0) : _C.softBorder.withOpacity(0.95),
              width: 1.15,
            ),
            boxShadow: emphasized
                ? <BoxShadow>[
              BoxShadow(
                color: active
                    ? const Color(0xFF4FACFE).withOpacity(0.24)
                    : _C.teal.withOpacity(0.14),
                blurRadius: active ? 16 : 10,
                offset: const Offset(0, 7),
              ),
            ]
                : <BoxShadow>[
              BoxShadow(
                color: _C.navy.withOpacity(0.035),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: compact ? 18 : 20,
                height: compact ? 18 : 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: numberBg,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: emphasized ? Colors.white.withOpacity(0.46) : _C.cyan.withOpacity(0.20),
                  ),
                ),
                child: completed
                    ? Icon(Icons.check_rounded, color: numberColor, size: compact ? 12 : 13)
                    : Text(
                  data.number,
                  style: TextStyle(
                    fontFamily: _C.font,
                    color: numberColor,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 11.5 : 12.5,
                    height: 1.0,
                  ),
                ),
              ),
              SizedBox(height: compact ? 4 : 5),
              Flexible(
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _C.font,
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 10 : 12,
                    height: 1.35,
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

class _QuickNextStageButton extends StatefulWidget {
  const _QuickNextStageButton({
    required this.compact,
    required this.onTap,
    required this.hint,
    required this.hintReady,
    required this.hintLabel,
  });

  final bool compact;
  final VoidCallback onTap;
  final Animation<double> hint;
  final bool hintReady;
  final String? hintLabel;

  @override
  State<_QuickNextStageButton> createState() => _QuickNextStageButtonState();
}

class _QuickNextStageButtonState extends State<_QuickNextStageButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.hint,
      builder: (BuildContext context, Widget? child) {
        final double hintValue = widget.hintReady ? widget.hint.value : 0.0;
        final double hintScale = widget.hintReady ? 1.0 + (hintValue * 0.045) : 1.0;
        final String buttonLabel = widget.hintLabel ?? 'التالي';
        final Color primaryFg = Colors.white;

        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : hintScale,
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              height: widget.compact ? 48 : 52,
              padding: EdgeInsetsDirectional.only(
                start: widget.compact ? 10 : 13,
                end: widget.compact ? 12 : 14,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: <Color>[
                    Color(0xFF061F3A),
                    Color(0xFF0D5E7B),
                    Color(0xFF0FA3A6),
                  ],
                ),
                border: Border.all(
                  color: Colors.transparent,
                  width: widget.hintReady ? 1.55 : 1.35,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _C.teal.withOpacity(
                      _pressed ? 0.20 : (widget.hintReady ? 0.17 + (hintValue * 0.05) : 0.12),
                    ),
                    blurRadius: _pressed ? 24 : 20 + (hintValue * 4),
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    child: AnimatedOpacity(
                      opacity: widget.hintLabel == null ? 0.92 : 1.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: Text(
                        buttonLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: _C.font,
                          color: primaryFg,
                          fontWeight: FontWeight.w900,
                          fontSize: widget.compact ? 13 : 14,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: widget.compact ? 7 : 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    width: widget.compact ? 28 : 30,
                    height: widget.compact ? 28 : 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.96),
                      boxShadow: widget.hintReady
                          ? <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFF4FACFE).withOpacity(0.24 + (hintValue * 0.14)),
                          blurRadius: 9 + (hintValue * 6),
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : null,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _C.deepNavy,
                      size: widget.compact ? 17 : 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class _StepSceneSubtitle extends StatelessWidget {
  const _StepSceneSubtitle({Key? key, required this.text, required this.compact}) : super(key: key);

  final String text;
  final bool   compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 3 : 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[
            _C.cyan.withOpacity(0.58),
            _C.teal.withOpacity(0.22),
            Colors.white.withOpacity(0.96),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _C.teal.withOpacity(0.11),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical:   compact ? 9  : 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: _C.cyan.withOpacity(0.34),
            width: 1.2,
          ),
        ),
        child: Row(
          children: <Widget>[

            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines:  2,
                overflow:  TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: _C.font,
                  color: _C.deepNavy.withOpacity(0.92),
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 12 : 14,
                  height: 1.42,
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
// Step 1: AI scan scene
// ─────────────────────────────────────────────────────────────────────────────

const double _kScanBegin       = 0.16;
const double _kScanEnd         = 0.68;
const double _kScanResultBegin = 0.74;
class _AddProductAiScanScene extends StatelessWidget {
  const _AddProductAiScanScene({
    required this.controller,
    required this.compact,
  });

  final AnimationController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 96).clamp(280.0, 430.0).toDouble();
    final double cardHeight = compact ? cardWidth * 0.48 : cardWidth * 0.60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: PhysicalModel(
            color: Colors.transparent,
            elevation: compact ? 8 : 12,
            shadowColor: Colors.black.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
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
                          Colors.black.withOpacity(0.26),
                        ],
                      ),
                    ),
                  ),
                  _AiScanOverlay(controller: controller, cardHeight: cardHeight),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) {
                      final double iconIn = CurvedAnimation(
                        parent: controller,
                        curve: const Interval(0.06, 0.20, curve: Curves.easeOutCubic),
                      ).value;
                      final double iconOut = CurvedAnimation(
                        parent: controller,
                        curve: const Interval(_kScanEnd, _kScanResultBegin, curve: Curves.easeInCubic),
                      ).value;
                      final double opacity = (iconIn * (1.0 - iconOut)).clamp(0.0, 1.0);

                      if (opacity <= 0.0) return const SizedBox.shrink();

                      return Center(
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: 0.90 + (opacity * 0.10),
                            child: Container(
                              width: compact ? 42 : 48,
                              height: compact ? 42 : 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.20),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.38)),
                              ),
                              child: Icon(Icons.auto_awesome_rounded, color: _C.cyan, size: compact ? 23 : 26),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 10),
        SizedBox(
          width: cardWidth,
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              final double value = controller.value;
              final bool scanActive = value >= _kScanBegin && value < _kScanResultBegin;
              final bool resultReady = value >= _kScanResultBegin;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                reverseDuration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: scanActive
                    ? _AiScanStatusMessage(
                  key: const ValueKey<String>('ai-scan-status'),
                  compact: compact,
                )
                    : resultReady
                    ? _RecognizedProductInfoCard(
                  key: const ValueKey<String>('ai-scan-result'),
                  compact: compact,
                )
                    : SizedBox(
                  key: const ValueKey<String>('ai-scan-empty'),
                  height: compact ? 42 : 48,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AiScanStatusMessage extends StatelessWidget {
  const _AiScanStatusMessage({Key? key, required this.compact}) : super(key: key);

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.cyan.withOpacity(0.25)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: _C.teal.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: compact ? 16 : 18,
            height: compact ? 16 : 18,
            child: CircularProgressIndicator(
              strokeWidth: compact ? 2.0 : 2.3,
              color: _C.teal,
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          Flexible(
            child: Text(
              'بنتعرف على الصورة بالذكاء الاصطناعي',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _C.font,
                color: _C.deepNavy,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 11.5 : 13,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecognizedProductInfoCard extends StatelessWidget {
  const _RecognizedProductInfoCard({Key? key, required this.compact}) : super(key: key);

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 12,
        compact ? 10 : 12,
        compact ? 10 : 12,
        compact ? 11 : 13,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[
            Colors.white.withOpacity(0.28),
            const Color(0xFFF3FBFE).withOpacity(0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.cyan.withOpacity(0.22)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: _C.navy.withOpacity(0.055), blurRadius: 16, offset: const Offset(0, 7)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: compact ? 8 : 10),
          _DetectedInfoLine(label: 'العنوان', value: 'سماعة Airpod', compact: compact, strong: true),
          SizedBox(height: compact ? 5 : 6),
          _DetectedInfoLine(label: 'الوصف', value: 'سماعة ايربودز برو، مزودة بخاصية إلغاء الضوضاء النشطة وتصميم مريح', compact: compact),
          SizedBox(height: compact ? 5 : 6),
          _DetectedInfoLine(label: 'الفئة', value: 'اكسسوارات موبايل', compact: compact),
          SizedBox(height: compact ? 5 : 6),
          _DetectedInfoLine(label: 'اللون', value: 'أبيض', compact: compact),
        ],
      ),
    );
  }
}

class _DetectedInfoLine extends StatelessWidget {
  const _DetectedInfoLine({
    required this.label,
    required this.value,
    required this.compact,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool compact;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label : ',
          style: TextStyle(
            fontFamily: _C.font,
            color: _C.softText,
            fontWeight: FontWeight.w800,
            fontSize: compact ? 10.5 : 12,
            height: 1.25,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: _C.font,
              color: _C.deepNavy,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
              fontSize: compact ? 10.5 : 12,
              height: 1.25,
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
          curve:  const Interval(_kScanBegin, _kScanEnd, curve: Curves.easeInOut),
        ).value;
        final double scanFade = CurvedAnimation(
          parent: controller,
          curve:  const Interval(_kScanEnd, _kScanResultBegin, curve: Curves.easeIn),
        ).value;

        if (scanProgress == 0.0) return const SizedBox.shrink();

        final double lineY   = scanProgress * cardHeight;
        final double opacity = (1.0 - scanFade).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0, left: 0, right: 0, height: lineY,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin:  Alignment.topCenter,
                      end:    Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withOpacity(0.30),
                        Colors.black.withOpacity(0.08),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: lineY - 1, left: 0, right: 0,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.transparent, Color(0xFF5DBBFF),
                        Colors.white, Color(0xFF5DBBFF), Colors.transparent,
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: Color(0x995DBBFF), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                ),
              ),
              const Positioned(top: 10, left:  10, child: _ScanCorner(flipX: false, flipY: false)),
              const Positioned(top: 10, right: 10, child: _ScanCorner(flipX: true,  flipY: false)),
              const Positioned(bottom: 10, left:  10, child: _ScanCorner(flipX: false, flipY: true)),
              const Positioned(bottom: 10, right: 10, child: _ScanCorner(flipX: true,  flipY: true)),
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
      child: SizedBox(
        width: 18, height: 18,
        child: CustomPaint(painter: _CornerBracketPainter()),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color      = const Color(0xFF5DBBFF)
      ..strokeWidth = 2.5
      ..style      = PaintingStyle.stroke
      ..strokeCap  = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2: Compare recommendations
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
      vsync:    this,
      duration: const Duration(milliseconds: 2600),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true);

    _candidateTimer = Timer.periodic(const Duration(milliseconds: 3300), (_) {
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

  Widget _animatedChild({required Widget child, required double begin, required double end, double dy = 14}) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        final double t = CurvedAnimation(
          parent: widget.controller,
          curve:  Interval(begin, end, curve: Curves.easeOutCubic),
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
      padding: EdgeInsets.all(widget.compact ? 9 : 12),
      decoration: BoxDecoration(
        color:        const Color(0xFFF8FCFE),
        borderRadius: BorderRadius.circular(22),
        border:       Border.all(color: const Color(0xFF0C587A).withOpacity(0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _animatedChild(
            begin: 0.10, end: 0.34, dy: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    'بنرشحلك أفضل فرص التبديل',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: _C.font, color: _C.deepNavy,
                      fontWeight: FontWeight.w900,
                      fontSize:   widget.compact ? 10 : 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration:      const Duration(milliseconds: 700),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInCubic,
                  child: _CompatibilityBadge(
                    key:     ValueKey<String>('${activeCandidate.title}-${activeCandidate.percent}'),
                    percent: activeCandidate.percent,
                    label:   activeCandidate.label,
                    compact: widget.compact,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.compact ? 8 : 10),
          _animatedChild(
            begin: 0.30, end: 0.68, dy: 15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _ProductSwapCard(
                        title:         _myProduct.title,
                        imageAsset:    _myProduct.imageAsset,
                        compact:       widget.compact,
                        isHighlighted: false,
                      ),
                    ),
                    SizedBox(width: widget.compact ? 6 : 8),
                    Padding(
                      padding: EdgeInsets.only(top: widget.compact ? 36 : 42),
                      child: _AnimatedSwapIcon(compact: widget.compact, controller: _swapPulseController),
                    ),
                    SizedBox(width: widget.compact ? 6 : 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration:        const Duration(milliseconds: 860),
                        reverseDuration: const Duration(milliseconds: 520),
                        switchInCurve:   Curves.easeOutCubic,
                        switchOutCurve:  Curves.easeInCubic,
                        transitionBuilder: (Widget child, Animation<double> anim) {
                          return FadeTransition(
                            opacity: anim,
                            child:   SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.16, 0),
                                end:   Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          );
                        },
                        child: _ProductSwapCard(
                          key:           ValueKey<String>(activeCandidate.imageAsset),
                          title:         activeCandidate.title,
                          imageAsset:    activeCandidate.imageAsset,
                          compact:       widget.compact,
                          isHighlighted: true,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.compact ? 15 : 20),
                AnimatedSwitcher(
                  duration:      const Duration(milliseconds: 680),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _TinyReasonChipsWrap(
                    key:     ValueKey<String>('${activeCandidate.title}-${activeCandidate.percent}-reasons'),
                    reasons: activeCandidate.reasons,
                    compact: widget.compact,
                  ),
                ),
                SizedBox(height: widget.compact ? 4 : 6),
                _CandidateProgressDots(
                  count:       _candidateProducts.length,
                  activeIndex: _activeIndex,
                  compact:     widget.compact,
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
  final bool   compact;
  final bool   isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedContainer(
          duration:  const Duration(milliseconds: 360),
          curve:     Curves.easeOutCubic,
          height:    compact ? 120 : 150,
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(18),
            border:       Border.all(
              color: isHighlighted ? _C.cyan.withOpacity(0.52) : const Color(0xFFE2ECF2),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color:      (isHighlighted ? _C.teal : _C.navy).withOpacity(isHighlighted ? 0.14 : 0.06),
                blurRadius: isHighlighted ? 16 : 10,
                offset:     const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            imageAsset,
            fit:           BoxFit.cover,
            width:         double.infinity,
            filterQuality: FilterQuality.medium,
            errorBuilder:  (_, __, ___) => _ImageFallback(
              icon: isHighlighted ? Icons.inventory_2_rounded : Icons.headphones_rounded,
            ),
          ),
        ),
        SizedBox(height: compact ? 7 : 8),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines:  1,
          overflow:  TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: _C.font, color: _C.navy,
            fontWeight: FontWeight.w900,
            fontSize:   compact ? 12 : 13, height: 1.15,
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
            width:  compact ? 34 : 38,
            height: compact ? 34 : 38,
            decoration: BoxDecoration(
              color:  Colors.white,
              shape:  BoxShape.circle,
              border: Border.all(color: _C.softBorder, width: 1.5),
              boxShadow: <BoxShadow>[
                BoxShadow(color: _C.teal.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Image.asset(
              'assets/images/Taapdeel_icon.png',
              width:  compact ? 20 : 22,
              height: compact ? 20 : 22,
              fit:    BoxFit.contain,
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
      alignment:  WrapAlignment.center,
      spacing:    compact ? 5 : 6,
      runSpacing: compact ? 5 : 6,
      children: reasons.map((_ReasonChipModel r) => _TinyReasonChip(reason: r, compact: compact)).toList(),
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
        color:        const Color(0xFFEAF8FF),
        borderRadius: BorderRadius.circular(999),
        border:       Border.all(color: _C.softBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(reason.icon, color: _C.petrol, size: compact ? 11 : 12),
          const SizedBox(width: 4),
          Text(
            reason.label,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: _C.font, color: _C.softText,
              fontWeight: FontWeight.w800,
              fontSize:   compact ? 12 : 14, height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  const _CompatibilityBadge({Key? key, required this.percent, required this.label, required this.compact}) : super(key: key);
  final int    percent;
  final String label;
  final bool   compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 5 : 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF072D56), Color(0xFF0D5E7B), Color(0xFF24A9C4)],
        ),
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
            style: TextStyle(fontFamily: _C.font, color: Colors.white, fontWeight: FontWeight.w900, fontSize: compact ? 11 : 12, height: 1.0),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontFamily: _C.font, color: Colors.white, fontWeight: FontWeight.w800, fontSize: compact ? 9.5 : 10.5, height: 1.0),
          ),
        ],
      ),
    );
  }
}


class _CandidateProgressDots extends StatelessWidget {
  const _CandidateProgressDots({required this.count, required this.activeIndex, required this.compact});
  final int  count;
  final int  activeIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool active = index == activeIndex;
        return AnimatedContainer(
          duration:  const Duration(milliseconds: 260),
          curve:     Curves.easeOutCubic,
          margin:    const EdgeInsets.symmetric(horizontal: 2.5),
          width:     active ? (compact ? 14 : 16) : 5,
          height:    5,
          decoration: BoxDecoration(
            color:        active ? _C.teal : _C.softBorder.withOpacity(0.95),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI helpers
// ─────────────────────────────────────────────────────────────────────────────

class _C {
  static const Color navy     = Color(0xFF061F3A);
  static const Color deepNavy = Color(0xFF082B49);
  static const Color petrol   = Color(0xFF0B5471);
  static const Color teal     = Color(0xFF0E989B);
  static const Color cyan     = Color(0xFF24A9C4);
  static const Color softText = Color(0xFF3E6078);
  static const Color softBorder = Color(0xFFDCEEF5);
  static const String font    = 'Cairo';
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({Key? key, required this.anim, required this.child, this.dy = 20}) : super(key: key);
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
            child:  Transform.scale(scale: 0.98 + v * 0.02, child: c),
          ),
        );
      },
      child: child,
    );
  }
}

class _TaapdeelSetupLikeBackground extends StatelessWidget {
  const _TaapdeelSetupLikeBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
          colors: <Color>[Color(0xFFF4FAFE), Color(0xFFFFFFFF), Color(0xFFF7FCFE)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(top: -56, right: -46, child: _SoftCircle(size: 182, color: _C.cyan.withOpacity(0.10))),
          Positioned(top: 92,  left:  -70, child: _SoftCircle(size: 182, color: _C.teal.withOpacity(0.08))),
          Positioned(bottom: -18, left: -50, child: _SoftCircle(size: 300, color: const Color(0xFFDBEAFE).withOpacity(0.35))),
          Positioned(bottom: 90,  right: -92, child: _SoftCircle(size: 210, color: _C.petrol.withOpacity(0.06))),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.color});
  final double size;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
      builder: (_, Widget? child) => Transform.scale(scale: 1.0 + pulse.value * 0.014, child: child),
      child: Container(
        width: boxSize, height: boxSize,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(0.84),
          borderRadius: BorderRadius.circular(21),
          border:       Border.all(color: Colors.white.withOpacity(0.95)),
          boxShadow: <BoxShadow>[
            BoxShadow(color: const Color(0xFF072D56).withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 9)),
          ],
        ),
        child: Image.asset(
          logoAsset,
          fit:           BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder:  (_, __, ___) => const Icon(Icons.swap_horiz_rounded, color: _C.teal, size: 34),
        ),
      ),
    );
  }
}

class _PrimaryIntroButton extends StatefulWidget {
  const _PrimaryIntroButton({
    required this.text,
    required this.shimmer,
    required this.isFinalState,
    required this.onTap,
  });

  final String text;
  final AnimationController shimmer;
  final bool isFinalState;
  final VoidCallback onTap;

  @override
  State<_PrimaryIntroButton> createState() => _PrimaryIntroButtonState();
}

class _PrimaryIntroButtonState extends State<_PrimaryIntroButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool filled = widget.isFinalState;
    final Color fgColor = filled ? Colors.white : _C.deepNavy;
    final List<Color> gradientColors = filled
        ? const <Color>[Color(0xFF061F3A), Color(0xFF0D5E7B), Color(0xFF0FA3A6)]
        : const <Color>[Color(0xFFFFFFFF), Color(0xFFF8FCFE), Color(0xFFEAF8FF)];

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: gradientColors,
            ),
            border: Border.all(
              color: filled ? Colors.transparent : _C.cyan.withOpacity(0.48),
              width: 1.35,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (filled ? const Color(0xFF0D5E7B) : _C.teal).withOpacity(
                  _pressed ? (filled ? 0.34 : 0.20) : (filled ? 0.24 : 0.13),
                ),
                blurRadius: _pressed ? 32 : 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: <Widget>[
                if (filled)
                  AnimatedBuilder(
                    animation: widget.shimmer,
                    builder: (_, __) => Positioned.fill(
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
                    ),
                  ),
                Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontFamily: _C.font,
                      color: fgColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(widget.text),
                        const SizedBox(width: 9),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            key: ValueKey<bool>(filled),
                            color: fgColor,
                            size: 22,
                          ),
                        ),
                      ],
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


class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color:     const Color(0xFFEAF8FF),
      alignment: Alignment.center,
      child:     Icon(icon, color: _C.teal, size: 34),
    );
  }
}
