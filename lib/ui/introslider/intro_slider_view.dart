import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:provider/provider.dart';

import 'widgets/intro_dots.dart';
import 'widgets/slide1_persona.dart';
import 'widgets/slide2_persona_staged.dart';
import 'widgets/slide3_smart_ai_reco.dart';

class IntroSliderView extends StatefulWidget {
  const IntroSliderView({
    Key? key,
    required this.settingSlider,
  }) : super(key: key);

  final int settingSlider;

  @override
  State<IntroSliderView> createState() => _IntroSliderViewState();
}

class _IntroSliderViewState extends State<IntroSliderView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  UserProvider? _userProvider;
  UserRepository? _userRepo;
  PsValueHolder? _psValueHolder;

  int _slide1PlayKey = 0;
  int _slide2PlayKey = 0;
  int _slide3PlayKey = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToCategoryView({required bool onBoarding}) async {
    final psValueHolder = _psValueHolder;

    if (psValueHolder == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (widget.settingSlider == 1) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (psValueHolder.isForceLogin == true &&
        Utils.checkUserLoginId(psValueHolder) == 'nologinuser') {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RoutePaths.login_container);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      RoutePaths.CategoryView,
      arguments: <String, dynamic>{
        'onBoarding': onBoarding,
        'Discover': false,
      },
    );
  }

  Future<void> _onNextPressed() async {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _goToCategoryView(onBoarding: true);
  }

  Future<void> _onSkipPressed() async {
    await _goToCategoryView(onBoarding: false);
  }

  /// Returns the primary button label per slide index, matching the new designs:
  /// Slide 0 → "التالي"
  /// Slide 1 → "التالي"
  /// Slide 2 → "ابدأ التبديل" (last slide of trust network design) or "ابدئي التبديل" for females
  String _primaryLabel() {
    if (_currentPage < 2) return 'التالي';
    // Last slide CTA changes based on persona — but we keep it neutral for simplicity.
    // The persona-aware label can be injected via PersonaResolver if needed.
    return 'حدد اهتماماتك';
  }

  @override
  Widget build(BuildContext context) {
    _userRepo = Provider.of<UserRepository>(context);
    _psValueHolder = Provider.of<PsValueHolder>(context);

    return ChangeNotifierProvider<UserProvider>(
      lazy: false,
      create: (BuildContext context) {
        final userProvider = UserProvider(
          repo: _userRepo!,
          psValueHolder: _psValueHolder!,
        );
        _userProvider = userProvider;
        return userProvider;
      },
      child: Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider provider, Widget? child) {
          _userProvider = provider;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: TaapdeelScaffold(
              safeTop: true,
              safeBottom: true,
              padding: EdgeInsets.zero,
              body: Stack(
                children: [
                  // ── Light background blobs ─────────────────────────
                  Positioned(
                    top: -60,
                    right: -60,
                    child: _BackgroundBlob(
                      size: 220,
                      color: const Color(0xFF0FA3A6).withOpacity(0.07),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: -80,
                    child: _BackgroundBlob(
                      size: 180,
                      color: const Color(0xFF1A3F6F).withOpacity(0.05),
                    ),
                  ),
                  Positioned(
                    bottom: 200,
                    right: -50,
                    child: _BackgroundBlob(
                      size: 160,
                      color: const Color(0xFF0FA3A6).withOpacity(0.06),
                    ),
                  ),

                  // ── Pages ─────────────────────────────────────────
                  Positioned.fill(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) {
                        setState(() {
                          _currentPage = i;
                          if (i == 0) _slide1PlayKey++;
                          if (i == 1) _slide2PlayKey++;
                          if (i == 2) _slide3PlayKey++;
                        });
                      },
                      children: [
                        Slide1Persona(
                          psValueHolder: _psValueHolder,
                          playKey: _slide1PlayKey,
                        ),
                        Slide2PersonaStaged(
                          psValueHolder: _psValueHolder,
                          playKey: _slide2PlayKey,
                        ),
                        Slide3SmartAiReco(
                          psValueHolder: _psValueHolder,
                          playKey: _slide3PlayKey,
                        ),
                      ],
                    ),
                  ),



                  // ── Bottom buttons ────────────────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Container(
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20, 8, 20, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IntroDots(current: _currentPage),
                              const SizedBox(height: 12),
                              _currentPage == 0
                                  ? Row(
                                children: [
                                  Expanded(
                                    child: TaapdeelButton(
                                      label: 'تخطي',
                                      onPressed: _onSkipPressed,
                                      isPrimary: false,
                                      isExpanded: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: TaapdeelButton(
                                      label: 'التالي',
                                      onPressed: _onNextPressed,
                                      isPrimary: true,
                                      isExpanded: true,
                                    ),
                                  ),
                                ],
                              )
                                  : Row(
                                children: [
                                  // Show "تخطي" on slide 2, hide on last slide
                                  if (_currentPage < 2) ...[
                                    Expanded(
                                      child: TaapdeelButton(
                                        label: 'تخطي',
                                        onPressed: _onSkipPressed,
                                        isPrimary: false,
                                        isExpanded: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: TaapdeelButton(
                                        label: 'التالي',
                                        onPressed: _onNextPressed,
                                        isPrimary: true,
                                        isExpanded: true,
                                      ),
                                    ),
                                  ] else ...[
                                    Expanded(
                                      child: TaapdeelButton(
                                        label: 'تخطي',
                                        onPressed: _onSkipPressed,
                                        isPrimary: false,
                                        isExpanded: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: TaapdeelButton(
                                        label: _primaryLabel(),
                                        onPressed: _onNextPressed,
                                        isPrimary: true,
                                        isExpanded: true,
                                      ),
                                    ),
                                  ],
                                ],
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
          );
        },
      ),
    );
  }
}

// ── Decorative background blob ─────────────────────────────────────────────────
class _BackgroundBlob extends StatelessWidget {
  const _BackgroundBlob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
