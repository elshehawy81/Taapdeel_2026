import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class ElectronicsShareThemes {
  const ElectronicsShareThemes._();

  static const Color _navy = Color(0xFF061426);
  static const Color _deep = Color(0xFF02070D);
  static const Color _cyan = Color(0xFF24D5D8);
  static const Color _cyan2 = Color(0xFF63CAD6);
  static const Color _blue = Color(0xFF0C587A);
  static const Color _purple = Color(0xFF8B35FF);
  static const Color _pink = Color(0xFFFF3DCF);
  static const Color _orange = Color(0xFFFFB547);

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
    ShareThemeDefinition(
      id: 'electronics_smart_move',
      label: 'Smart Move',
      subtitle: 'تقني داكن',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFF061426), Color(0xFF0C587A)],
      priority: 10,
      builder: _smartMove,
    ),
    ShareThemeDefinition(
      id: 'electronics_clean_catalog',
      label: 'Clean Catalog',
      subtitle: 'أبيض بسيط',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFFE8F9FC)],
      priority: 20,
      builder: _cleanCatalog,
    ),
    ShareThemeDefinition(
      id: 'electronics_neon_gaming',
      label: 'Neon Gaming',
      subtitle: 'بنفسجي للألعاب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFF060014), Color(0xFF772BFF)],
      priority: 30,
      builder: _neonGaming,
    ),
    ShareThemeDefinition(
      id: 'electronics_big_price',
      label: 'Big Price',
      subtitle: 'السعر هو البطل',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFF062A35), Color(0xFF24D5D8)],
      priority: 40,
      builder: _bigPrice,
    ),
    ShareThemeDefinition(
      id: 'electronics_magazine_split',
      label: 'Magazine Split',
      subtitle: 'تقسيم مجلّة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFF101827), Color(0xFFF7FAFC)],
      priority: 50,
      builder: _magazineSplit,
    ),
    ShareThemeDefinition(
      id: 'electronics_story_bubble',
      label: 'Story Bubble',
      subtitle: 'مناسب للستوري',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFF052034), Color(0xFF24D5D8)],
      priority: 60,
      builder: _storyBubble,
    ),
    ShareThemeDefinition(
      id: 'electronics_glass_stack',
      label: 'Glass Stack',
      subtitle: 'كروت زجاجية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFF0B63A6), Color(0xFF24D5D8)],
      priority: 70,
      builder: _glassStack,
    ),
    ShareThemeDefinition(
      id: 'electronics_diagonal_energy',
      label: 'Diagonal Energy',
      subtitle: 'حركة وشير',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFF101B79), Color(0xFF24D5D8)],
      priority: 80,
      builder: _diagonalEnergy,
    ),
    ShareThemeDefinition(
      id: 'electronics_circuit_terminal',
      label: 'Circuit Terminal',
      subtitle: 'دوائر وبرمجة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFF02070D), Color(0xFF00C8E0)],
      priority: 90,
      builder: _circuitTerminal,
    ),
    ShareThemeDefinition(
      id: 'electronics_photo_first',
      label: 'Photo First',
      subtitle: 'الصورة أولاً',
      groups: const <ShareThemeGroup>[ShareThemeGroup.electronics],
      gradient: const <Color>[Color(0xFF111827), Color(0xFF24D5D8)],
      priority: 100,
      builder: _photoFirst,
    ),
  ];

  // 1) Keep only one card close to the old dark-tech structure.
  static Widget _smartMove(BuildContext context, ShareProductData d) {
    return _ThemeFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF061426), Color(0xFF082A3C), Color(0xFF02070D)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          children: <Widget>[
            _brandRow(u, d, fg: Colors.white, accent: _cyan),
            SizedBox(height: 10 * u),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 56,
                    child: _neonImageCard(d, u, accent: _cyan, radius: 18, padding: 6),
                  ),
                  SizedBox(width: 10 * u),
                  Expanded(
                    flex: 44,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _englishTitle('SMART', 'MOVE', u, _cyan),
                        SizedBox(height: 8 * u),
                        Text(
                          'اختيار ذكي\nقيمة حقيقية',
                          style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 10.5 * u, height: 1.2, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 10 * u),
                        Expanded(child: _darkInfoPanel(d, u, accent: _cyan)),
                        SizedBox(height: 8 * u),
                        _pricePill(d, u, accent: _cyan, dark: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * u),
            _cta(u, accent: _cyan, textColor: _deep),
            SizedBox(height: 8 * u),
            _benefitBar(u, fg: Colors.white, accent: _cyan),
          ],
        );
      },
    );
  }

  // 2) Completely different: white catalogue card, product on pedestal, minimal typography.
  static Widget _cleanCatalog(BuildContext context, ShareProductData d) {
    return _ThemeFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF6FBFE), Color(0xFFFFFFFF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          children: <Widget>[
            _brandRow(u, d, fg: const Color(0xFF122033), accent: const Color(0xFF2F80ED), light: true),
            SizedBox(height: 14 * u),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 54,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10 * u),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F7FB),
                              borderRadius: BorderRadius.circular(34 * u),
                              boxShadow: <BoxShadow>[
                                BoxShadow(color: const Color(0xFF1D4E89).withOpacity(0.10), blurRadius: 24 * u, offset: Offset(0, 12 * u)),
                              ],
                            ),
                            child: ClipRRect(borderRadius: BorderRadius.circular(28 * u), child: shareNetworkImage(d.imageUrl)),
                          ),
                        ),
                        SizedBox(height: 8 * u),
                        _softFeatureRow(u),
                      ],
                    ),
                  ),
                  SizedBox(width: 13 * u),
                  Expanded(
                    flex: 46,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('عرض', style: TextStyle(color: const Color(0xFF122033), fontSize: 33 * u, height: 0.9, fontWeight: FontWeight.w900)),
                        Text('مميز', style: TextStyle(color: _cyan, fontSize: 40 * u, height: 0.9, fontWeight: FontWeight.w900)),
                        SizedBox(height: 12 * u),
                        Text(d.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF122033), fontSize: 16 * u, fontWeight: FontWeight.w900, height: 1.15)),
                        SizedBox(height: 10 * u),
                        Expanded(child: _lightInfoList(d, u)),
                        SizedBox(height: 8 * u),
                        _pricePlain(d, u, accent: _cyan),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * u),
            _cta(u, accent: _cyan, textColor: Colors.white, invertIcon: true),
          ],
        );
      },
    );
  }

  // 3) Gaming poster: neon frame, purple/pink, headline at top, product dominates.
  static Widget _neonGaming(BuildContext context, ShareProductData d) {
    return _ThemeFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF060014), Color(0xFF160034), Color(0xFF020006)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 12 * u, left: 6 * u, child: _neonSlashes(u)),
            Positioned(top: 8 * u, right: 8 * u, child: _dotGrid(u, _pink)),
            Column(
              children: <Widget>[
                _brandRow(u, d, fg: Colors.white, accent: _pink),
                SizedBox(height: 10 * u),
                _bigNeonTitle(u),
                SizedBox(height: 10 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 57,
                        child: _neonImageCard(d, u, accent: _pink, secondary: const Color(0xFF18A7FF), radius: 24, padding: 5),
                      ),
                      SizedBox(width: 10 * u),
                      Expanded(
                        flex: 43,
                        child: Column(
                          children: <Widget>[
                            Expanded(child: _neonInfoBox(d, u)),
                            SizedBox(height: 8 * u),
                            _pricePill(d, u, accent: _pink, secondary: const Color(0xFF18A7FF), dark: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * u),
                _cta(u, accent: _pink, secondary: const Color(0xFF18A7FF), textColor: Colors.white),
                SizedBox(height: 8 * u),
                _benefitBar(u, fg: Colors.white, accent: _pink, items: const <_Benefit>[
                  _Benefit(Icons.shield_rounded, 'تبادل آمن'),
                  _Benefit(Icons.sync_rounded, 'سرعة وسهولة'),
                  _Benefit(Icons.bolt_rounded, 'طاقة للألعاب'),
                ]),
              ],
            ),
          ],
        );
      },
    );
  }

  // 4) Marketplace price poster: product is smaller, price and deal message dominate.
  static Widget _bigPrice(BuildContext context, ShareProductData d) {
    return _ThemeFrame(
      background: const RadialGradient(
        center: Alignment.topLeft,
        radius: 1.15,
        colors: <Color>[Color(0xFF0E5160), Color(0xFF062A35), Color(0xFF02070D)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _brandRow(u, d, fg: Colors.white, accent: _cyan),
            SizedBox(height: 12 * u),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.72,
                        heightFactor: 0.72,
                        child: Opacity(opacity: 0.22, child: ClipOval(child: shareNetworkImage(d.imageUrl))),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('فرصة ممتازة', style: TextStyle(color: Colors.white, fontSize: 34 * u, height: 0.95, fontWeight: FontWeight.w900)),
                      Text('لمنتج إلكتروني يستاهل', style: TextStyle(color: _cyan, fontSize: 15 * u, fontWeight: FontWeight.w900)),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.all(14 * u),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(26 * u),
                          border: Border.all(color: _cyan.withOpacity(0.52), width: 1.2),
                          boxShadow: <BoxShadow>[BoxShadow(color: _cyan.withOpacity(0.24), blurRadius: 24 * u)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('السعر', style: TextStyle(color: _cyan, fontSize: 13 * u, fontWeight: FontWeight.w900)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _price(d),
                                style: TextStyle(color: _cyan, fontSize: 46 * u, fontWeight: FontWeight.w900, height: 0.95),
                              ),
                            ),
                            Divider(color: Colors.white.withOpacity(0.12)),
                            Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 15 * u, fontWeight: FontWeight.w900)),
                            SizedBox(height: 8 * u),
                            _singleLineMeta(d, u, accent: _cyan),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * u),
            _cta(u, accent: _cyan, textColor: _deep),
          ],
        );
      },
    );
  }

  // 5) Magazine split: black left strip + white content. Very different from old layout.
  static Widget _magazineSplit(BuildContext context, ShareProductData d) {
    return _ThemeFrame(
      padding: EdgeInsets.zero,
      background: const LinearGradient(colors: <Color>[Color(0xFFF7FAFC), Color(0xFFFFFFFF)]),
      childBuilder: (BuildContext context, double u) {
        return Row(
          children: <Widget>[
            Expanded(
              flex: 38,
              child: Container(
                padding: EdgeInsets.all(16 * u),
                decoration: const BoxDecoration(
                  color: Color(0xFF101827),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(28), bottomRight: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _brandMini(u, fg: Colors.white, accent: _orange),
                    const Spacer(),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text('TECH DEAL', style: TextStyle(color: _orange, fontSize: 31 * u, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ),
                    const Spacer(),
                    _categoryTiny(_categoryText(d), u, _orange, dark: true),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 62,
              child: Padding(
                padding: EdgeInsets.all(14 * u),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('صفقة تقنية', style: TextStyle(color: const Color(0xFF101827), fontSize: 28 * u, fontWeight: FontWeight.w900)),
                    SizedBox(height: 6 * u),
                    Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF435467), fontSize: 13 * u, fontWeight: FontWeight.w800)),
                    SizedBox(height: 10 * u),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8 * u),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24 * u)),
                        child: ClipRRect(borderRadius: BorderRadius.circular(18 * u), child: shareNetworkImage(d.imageUrl)),
                      ),
                    ),
                    SizedBox(height: 10 * u),
                    _magazineMeta(d, u),
                    SizedBox(height: 10 * u),
                    _pricePlain(d, u, accent: _orange, darkText: true),
                    SizedBox(height: 10 * u),
                    _cta(u, accent: _orange, textColor: const Color(0xFF101827), compact: true),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 6) Story bubble: centered headline, circular photo, side stats.
  static Widget _storyBubble(BuildContext context, ShareProductData d) {
    return _ThemeFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFF052034), Color(0xFF062A35), Color(0xFF02070D)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(bottom: -55 * u, right: -45 * u, child: _glow(u, _cyan.withOpacity(0.25), 190)),
            Positioned(top: 62 * u, left: -35 * u, child: _glow(u, _cyan.withOpacity(0.14), 135)),
            Column(
              children: <Widget>[
                _brandRow(u, d, fg: Colors.white, accent: _cyan),
                SizedBox(height: 12 * u),
                Text('شارك منتجك', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 32 * u, fontWeight: FontWeight.w900, shadows: <Shadow>[Shadow(color: _cyan.withOpacity(0.75), blurRadius: 18 * u)])),
                Text('بدّل بسهولة ووصل لمشترين أكثر', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 11.5 * u, fontWeight: FontWeight.w800)),
                SizedBox(height: 10 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 46,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              padding: EdgeInsets.all(9 * u),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _cyan.withOpacity(0.62), width: 8 * u),
                                boxShadow: <BoxShadow>[BoxShadow(color: _cyan.withOpacity(0.24), blurRadius: 24 * u)],
                              ),
                              child: ClipOval(child: shareNetworkImage(d.imageUrl)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * u),
                      Expanded(flex: 54, child: _verticalTicket(d, u, accent: _cyan)),
                    ],
                  ),
                ),
                SizedBox(height: 10 * u),
                _cta(u, accent: _cyan, textColor: _deep),
                SizedBox(height: 8 * u),
                _benefitBar(u, fg: Colors.white, accent: _cyan),
              ],
            ),
          ],
        );
      },
    );
  }

  // 7) Glass stack: layered frosted cards with product floating above.
  static Widget _glassStack(BuildContext context, ShareProductData d) {
    return _ThemeFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF0B63A6), Color(0xFF24D5D8), Color(0xFF073A6A)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: -25 * u, right: -30 * u, child: _glow(u, Colors.white.withOpacity(0.18), 180)),
            Positioned(bottom: -45 * u, left: -40 * u, child: _glow(u, Colors.white.withOpacity(0.18), 210)),
            Column(
              children: <Widget>[
                _brandRow(u, d, fg: Colors.white, accent: Colors.white),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned.fill(
                        top: 22 * u,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(30 * u),
                            border: Border.all(color: Colors.white.withOpacity(0.45)),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 53,
                            child: Container(
                              margin: EdgeInsets.only(top: 34 * u, bottom: 18 * u),
                              padding: EdgeInsets.all(10 * u),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(26 * u),
                                border: Border.all(color: Colors.white.withOpacity(0.55)),
                              ),
                              child: ClipRRect(borderRadius: BorderRadius.circular(20 * u), child: shareNetworkImage(d.imageUrl)),
                            ),
                          ),
                          SizedBox(width: 12 * u),
                          Expanded(
                            flex: 47,
                            child: Padding(
                              padding: EdgeInsets.only(top: 44 * u, bottom: 16 * u, left: 10 * u),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text('PREMIUM', style: TextStyle(color: Colors.white.withOpacity(0.86), fontSize: 25 * u, fontWeight: FontWeight.w900, height: 0.92)),
                                  Text('TECH', style: TextStyle(color: const Color(0xFFBFF9FF), fontSize: 34 * u, fontWeight: FontWeight.w900, height: 0.92)),
                                  SizedBox(height: 9 * u),
                                  Expanded(child: _glassInfo(d, u)),
                                  SizedBox(height: 8 * u),
                                  _pricePill(d, u, accent: Colors.white, secondary: _cyan2, dark: false),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * u),
                _cta(u, accent: Colors.white, textColor: const Color(0xFF0B63A6), invertIcon: true),
              ],
            ),
          ],
        );
      },
    );
  }

  // 8) Diagonal energetic layout: skewed panels and strong share headline.
  static Widget _diagonalEnergy(BuildContext context, ShareProductData d) {
    return _ThemeFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF0B1264), Color(0xFF132B96), Color(0xFF24D5D8)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: -42 * u, left: -20 * u, child: Transform.rotate(angle: -0.55, child: Container(width: 170 * u, height: 32 * u, color: Colors.white.withOpacity(0.17)))),
            Positioned(bottom: 60 * u, right: -60 * u, child: Transform.rotate(angle: -0.55, child: Container(width: 250 * u, height: 72 * u, color: _cyan.withOpacity(0.20)))),
            Column(
              children: <Widget>[
                _brandRow(u, d, fg: Colors.white, accent: _cyan),
                SizedBox(height: 8 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 58,
                        child: Transform.rotate(
                          angle: -0.035,
                          child: Container(
                            padding: EdgeInsets.all(6 * u),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(22 * u),
                              border: Border.all(color: Colors.white.withOpacity(0.45)),
                              boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20 * u)],
                            ),
                            child: ClipRRect(borderRadius: BorderRadius.circular(17 * u), child: shareNetworkImage(d.imageUrl)),
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * u),
                      Expanded(
                        flex: 42,
                        child: Transform.rotate(
                          angle: 0.035,
                          child: Container(
                            padding: EdgeInsets.all(12 * u),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(24 * u),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text('جاهز', style: TextStyle(color: const Color(0xFF0B1264), fontSize: 33 * u, fontWeight: FontWeight.w900, height: 0.9)),
                                Text('للشير', style: TextStyle(color: _cyan, fontSize: 32 * u, fontWeight: FontWeight.w900, height: 0.9)),
                                SizedBox(height: 10 * u),
                                Expanded(child: _lightInfoList(d, u, compact: true)),
                                SizedBox(height: 8 * u),
                                _pricePlain(d, u, accent: const Color(0xFF0B1264), darkText: true),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * u),
                _cta(u, accent: _cyan, textColor: const Color(0xFF0B1264)),
                SizedBox(height: 8 * u),
                _benefitBar(u, fg: Colors.white, accent: _cyan),
              ],
            ),
          ],
        );
      },
    );
  }

  // 9) Circuit / terminal: product in terminal screen, green-cyan code style.
  static Widget _circuitTerminal(BuildContext context, ShareProductData d) {
    const Color green = Color(0xFF39FFB6);
    return _ThemeFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF02070D), Color(0xFF001B21), Color(0xFF02070D)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 8 * u, right: 8 * u, child: _circuitCorner(u, green)),
            Positioned(bottom: 62 * u, left: 8 * u, child: Transform.rotate(angle: math.pi, child: _circuitCorner(u, green))),
            Column(
              children: <Widget>[
                _brandRow(u, d, fg: green, accent: green),
                SizedBox(height: 10 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10 * u),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.42),
                      borderRadius: BorderRadius.circular(20 * u),
                      border: Border.all(color: green.withOpacity(0.55)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          textDirection: TextDirection.ltr,
                          children: <Widget>[
                            _terminalDot(Colors.redAccent, u),
                            _terminalDot(Colors.orangeAccent, u),
                            _terminalDot(green, u),
                            SizedBox(width: 8 * u),
                            Expanded(child: Text('taapdeel/electronics/share', textDirection: TextDirection.ltr, style: TextStyle(color: green.withOpacity(0.80), fontSize: 8.7 * u, fontWeight: FontWeight.w700))),
                          ],
                        ),
                        SizedBox(height: 9 * u),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 52,
                                child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14 * u), border: Border.all(color: green.withOpacity(0.33))),
                                  child: ClipRRect(borderRadius: BorderRadius.circular(13 * u), child: shareNetworkImage(d.imageUrl)),
                                ),
                              ),
                              SizedBox(width: 10 * u),
                              Expanded(
                                flex: 48,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text('NEXT_TECH();', textDirection: TextDirection.ltr, style: TextStyle(color: green, fontSize: 22 * u, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                    SizedBox(height: 8 * u),
                                    Expanded(child: _terminalInfo(d, u, green)),
                                    SizedBox(height: 8 * u),
                                    _pricePill(d, u, accent: green, dark: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10 * u),
                _cta(u, accent: green, textColor: _deep),
              ],
            ),
          ],
        );
      },
    );
  }

  // 10) Photo first: product image fills most of poster, details are floating overlay.
  static Widget _photoFirst(BuildContext context, ShareProductData d) {
    return _ThemeFrame(
      padding: EdgeInsets.zero,
      background: const LinearGradient(colors: <Color>[Color(0xFF111827), Color(0xFF111827)]),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(child: shareNetworkImage(d.imageUrl)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.black.withOpacity(0.16), Colors.black.withOpacity(0.18), Colors.black.withOpacity(0.82)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14 * u),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _brandRow(u, d, fg: Colors.white, accent: _cyan),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(14 * u),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.52),
                      borderRadius: BorderRadius.circular(26 * u),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('Photo First', textDirection: TextDirection.ltr, style: TextStyle(color: _cyan, fontSize: 15 * u, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        SizedBox(height: 4 * u),
                        Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 21 * u, height: 1.05, fontWeight: FontWeight.w900)),
                        SizedBox(height: 8 * u),
                        _singleLineMeta(d, u, accent: _cyan),
                        SizedBox(height: 10 * u),
                        Row(
                          children: <Widget>[
                            Expanded(child: _pricePill(d, u, accent: _cyan, dark: true)),
                            SizedBox(width: 8 * u),
                            SizedBox(width: 120 * u, child: _cta(u, accent: _cyan, textColor: _deep, compact: true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static String _categoryText(ShareProductData d) {
    if (shareHas(d.subCategory)) return d.subCategory;
    if (shareHas(d.category)) return d.category;
    return 'إلكترونيات';
  }

  static String _price(ShareProductData d) {
    final String txt = sharePriceText(d);
    return shareHas(txt) ? txt : 'السعر عند التواصل';
  }

  static Widget _brandRow(double u, ShareProductData d, {required Color fg, required Color accent, bool light = false}) {
    return Row(
      textDirection: TextDirection.ltr,
      children: <Widget>[
        _brandMini(u, fg: fg, accent: accent, light: light),
        const Spacer(),
        _categoryTiny(_categoryText(d), u, accent, dark: !light),
      ],
    );
  }

  static Widget _brandMini(double u, {required Color fg, required Color accent, bool light = false}) {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 30 * u,
          height: 30 * u,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(10 * u),
            boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.22), blurRadius: 14 * u)],
          ),
          child: Icon(Icons.swap_horiz_rounded, color: light ? Colors.white : _deep, size: 18 * u),
        ),
        SizedBox(width: 7 * u),
        Text(
          ' TAAPDEEL',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: fg, fontSize: 14.5 * u, fontWeight: FontWeight.w900, letterSpacing: 0.15),
        ),
      ],
    );
  }

  static Widget _categoryTiny(String text, double u, Color accent, {bool dark = true}) {
    return Container(
      constraints: BoxConstraints(maxWidth: 118 * u),
      padding: EdgeInsets.symmetric(horizontal: 9 * u, vertical: 5 * u),
      decoration: BoxDecoration(
        color: dark ? accent.withOpacity(0.13) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.54)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.memory_rounded, size: 12 * u, color: accent),
          SizedBox(width: 4 * u),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: dark ? accent : const Color(0xFF122033), fontSize: 9.5 * u, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _englishTitle(String line1, String line2, double u, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(line1, style: TextStyle(color: Colors.white, fontSize: 30 * u, height: 0.9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        Text(line2, style: TextStyle(color: accent, fontSize: 36 * u, height: 0.9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }

  static Widget _neonImageCard(
      ShareProductData d,
      double u, {
        required Color accent,
        Color? secondary,
        double radius = 18,
        double padding = 6,
      }) {
    return Container(
      padding: EdgeInsets.all(padding * u),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(radius * u),
        border: Border.all(color: accent.withOpacity(0.55), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(color: accent.withOpacity(0.24), blurRadius: 22 * u),
          if (secondary != null) BoxShadow(color: secondary.withOpacity(0.18), blurRadius: 30 * u),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular((radius - 4) * u), child: shareNetworkImage(d.imageUrl)),
    );
  }

  static Widget _darkInfoPanel(ShareProductData d, double u, {required Color accent}) {
    return Container(
      padding: EdgeInsets.all(10 * u),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(18 * u),
        border: Border.all(color: accent.withOpacity(0.28)),
      ),
      child: Column(
        children: <Widget>[
          _darkRow(Icons.devices_rounded, 'العنوان', d.title, u, accent, maxLines: 2),
          if (shareHas(d.condition)) _darkRow(Icons.verified_rounded, 'الحالة', d.condition, u, accent),
          if (shareHas(d.usage)) _darkRow(Icons.calendar_month_rounded, 'الاستخدام', d.usage, u, accent),
          if (shareHas(d.location)) _darkRow(Icons.location_on_rounded, 'الموقع', shareShortLocation(d.location), u, accent),
          const Spacer(),
        ],
      ),
    );
  }

  static Widget _darkRow(IconData icon, String label, String value, double u, Color accent, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7 * u),
      child: Row(
        children: <Widget>[
          Container(
            width: 27 * u,
            height: 27 * u,
            decoration: BoxDecoration(color: accent.withOpacity(0.15), borderRadius: BorderRadius.circular(9 * u)),
            child: Icon(icon, color: accent, size: 15 * u),
          ),
          SizedBox(width: 7 * u),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('$label:', style: TextStyle(color: accent, fontSize: 8.8 * u, fontWeight: FontWeight.w900)),
                Text(value, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 10.5 * u, height: 1.15, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _lightInfoList(ShareProductData d, double u, {bool compact = false}) {
    final List<_Info> rows = <_Info>[
      _Info(Icons.verified_rounded, 'الحالة', shareHas(d.condition) ? d.condition : 'ممتاز'),
      _Info(Icons.timer_rounded, 'الاستخدام', shareHas(d.usage) ? d.usage : 'خفيف'),
      _Info(Icons.location_on_rounded, 'الموقع', shareHas(d.location) ? shareShortLocation(d.location) : 'قريب منك'),
    ];

    return Column(
      children: <Widget>[
        for (final _Info r in rows)
          Container(
            margin: EdgeInsets.only(bottom: 7 * u),
            padding: EdgeInsets.symmetric(horizontal: 8 * u, vertical: compact ? 6 * u : 8 * u),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13 * u),
              border: Border.all(color: const Color(0xFFE6EEF7)),
            ),
            child: Row(
              children: <Widget>[
                Icon(r.icon, color: _cyan, size: 15 * u),
                SizedBox(width: 6 * u),
                Expanded(
                  child: Text('${r.label}: ${r.value}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF122033), fontSize: 10.5 * u, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        const Spacer(),
      ],
    );
  }

  static Widget _glassInfo(ShareProductData d, double u) {
    return Column(
      children: <Widget>[
        _glassLine(Icons.devices_rounded, d.title, u),
        if (shareHas(d.condition)) _glassLine(Icons.verified_rounded, d.condition, u),
        if (shareHas(d.usage)) _glassLine(Icons.calendar_month_rounded, d.usage, u),
        if (shareHas(d.location)) _glassLine(Icons.location_on_rounded, shareShortLocation(d.location), u),
        const Spacer(),
      ],
    );
  }

  static Widget _glassLine(IconData icon, String text, double u) {
    return Container(
      margin: EdgeInsets.only(bottom: 7 * u),
      padding: EdgeInsets.all(8 * u),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(13 * u), border: Border.all(color: Colors.white.withOpacity(0.25))),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 15 * u),
          SizedBox(width: 6 * u),
          Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 10.5 * u, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _verticalTicket(ShareProductData d, double u, {required Color accent}) {
    return Container(
      padding: EdgeInsets.all(10 * u),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.20),
        borderRadius: BorderRadius.circular(22 * u),
        border: Border.all(color: accent.withOpacity(0.34)),
      ),
      child: Column(
        children: <Widget>[
          Text(d.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 13.5 * u, fontWeight: FontWeight.w900, height: 1.1)),
          Divider(color: Colors.white.withOpacity(0.12)),
          if (shareHas(d.condition)) _ticketLine('الحالة', d.condition, u, accent),
          if (shareHas(d.usage)) _ticketLine('الاستخدام', d.usage, u, accent),
          if (shareHas(d.location)) _ticketLine('الموقع', shareShortLocation(d.location), u, accent),
          const Spacer(),
          _pricePill(d, u, accent: accent, dark: true),
        ],
      ),
    );
  }

  static Widget _ticketLine(String label, String value, double u, Color accent) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * u),
      child: Row(
        children: <Widget>[
          Text('$label:', style: TextStyle(color: accent, fontSize: 9.5 * u, fontWeight: FontWeight.w900)),
          SizedBox(width: 5 * u),
          Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 10.5 * u, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _neonInfoBox(ShareProductData d, double u) {
    return Container(
      padding: EdgeInsets.all(10 * u),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.34),
        borderRadius: BorderRadius.circular(18 * u),
        border: Border.all(color: _pink.withOpacity(0.55)),
      ),
      child: Column(
        children: <Widget>[
          Text(d.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 13 * u, fontWeight: FontWeight.w900, height: 1.1)),
          Divider(color: _pink.withOpacity(0.35)),
          if (shareHas(d.condition)) _neonLine(Icons.shield_rounded, 'الحالة', d.condition, u),
          if (shareHas(d.usage)) _neonLine(Icons.calendar_month_rounded, 'الاستخدام', d.usage, u),
          if (shareHas(d.location)) _neonLine(Icons.location_on_rounded, 'الموقع', shareShortLocation(d.location), u),
          const Spacer(),
        ],
      ),
    );
  }

  static Widget _neonLine(IconData icon, String label, String value, double u) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * u),
      child: Row(
        children: <Widget>[
          Icon(icon, color: _pink, size: 14 * u),
          SizedBox(width: 6 * u),
          Expanded(child: Text('$label: $value', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 9.8 * u, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _terminalInfo(ShareProductData d, double u, Color green) {
    final List<String> lines = <String>[
      'title: "${d.title}"',
      if (shareHas(d.condition)) 'condition: "${d.condition}"',
      if (shareHas(d.usage)) 'usage: "${d.usage}"',
      if (shareHas(d.location)) 'location: "${shareShortLocation(d.location)}"',
    ];

    return Container(
      padding: EdgeInsets.all(9 * u),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
        borderRadius: BorderRadius.circular(14 * u),
        border: Border.all(color: green.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final String l in lines.take(4))
            Padding(
              padding: EdgeInsets.only(bottom: 6 * u),
              child: Text(
                '> $l',
                textDirection: TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: green.withOpacity(0.88), fontSize: 9.2 * u, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
              ),
            ),
          const Spacer(),
        ],
      ),
    );
  }

  static Widget _pricePill(ShareProductData d, double u, {required Color accent, Color? secondary, bool dark = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * u, vertical: 8 * u),
      decoration: BoxDecoration(
        color: dark ? Colors.black.withOpacity(0.24) : Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16 * u),
        border: Border.all(color: accent.withOpacity(0.65), width: 1.2),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.sell_rounded, color: accent, size: 17 * u),
          SizedBox(width: 6 * u),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(_price(d), maxLines: 1, style: TextStyle(color: secondary ?? accent, fontSize: 22 * u, fontWeight: FontWeight.w900, height: 0.95)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _pricePlain(ShareProductData d, double u, {required Color accent, bool darkText = false}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        _price(d),
        maxLines: 1,
        style: TextStyle(color: accent, fontSize: 29 * u, fontWeight: FontWeight.w900, height: 0.95),
      ),
    );
  }

  static Widget _cta(double u, {required Color accent, Color? secondary, required Color textColor, bool invertIcon = false, bool compact = false}) {
    return Container(
      height: compact ? 37 * u : 43 * u,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: <Color>[accent, secondary ?? Color.lerp(accent, Colors.white, 0.28)!]),
        borderRadius: BorderRadius.circular(compact ? 14 * u : 17 * u),
        boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.25), blurRadius: 14 * u, offset: Offset(0, 6 * u))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.ios_share_rounded, size: 17 * u, color: textColor),
          SizedBox(width: 8 * u),
          Flexible(
            child: Text(
              'اعرض المنتج',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor, fontSize: compact ? 15 * u : 19 * u, fontWeight: FontWeight.w900),
            ),
          ),
          if (!compact) ...<Widget>[
            SizedBox(width: 10 * u),
            Container(
              width: 26 * u,
              height: 26 * u,
              decoration: BoxDecoration(color: (invertIcon ? textColor : Colors.black).withOpacity(0.18), shape: BoxShape.circle),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 12 * u, color: textColor),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _benefitBar(double u, {required Color fg, required Color accent, List<_Benefit> items = const <_Benefit>[
    _Benefit(Icons.verified_user_rounded, 'آمن وسهل'),
    _Benefit(Icons.sync_rounded, 'بدّل ووفر'),
    _Benefit(Icons.people_alt_rounded, 'مجتمع موثوق'),
  ]}) {
    return Container(
      height: 30 * u,
      padding: EdgeInsets.symmetric(horizontal: 8 * u),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(items[i].icon, color: accent, size: 13 * u),
                  SizedBox(width: 4 * u),
                  Flexible(child: Text(items[i].label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg.withOpacity(0.88), fontSize: 8.2 * u, fontWeight: FontWeight.w800))),
                ],
              ),
            ),
            if (i != items.length - 1) Container(width: 1, height: 15 * u, color: fg.withOpacity(0.15)),
          ],
        ],
      ),
    );
  }

  static Widget _softFeatureRow(double u) {
    return Container(
      height: 32 * u,
      decoration: BoxDecoration(color: const Color(0xFFF2F7FC), borderRadius: BorderRadius.circular(999)),
      child: Row(
        children: <Widget>[
          _softFeature(Icons.verified_user_rounded, 'آمن', u),
          _softFeature(Icons.swap_horiz_rounded, 'سهل', u),
          _softFeature(Icons.groups_rounded, 'موثوق', u),
        ],
      ),
    );
  }

  static Widget _softFeature(IconData icon, String text, double u) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: const Color(0xFF2F80ED), size: 13 * u),
          SizedBox(width: 3 * u),
          Text(text, style: TextStyle(color: const Color(0xFF526173), fontSize: 8.5 * u, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  static Widget _magazineMeta(ShareProductData d, double u) {
    return Wrap(
      spacing: 6 * u,
      runSpacing: 6 * u,
      children: <Widget>[
        if (shareHas(d.condition)) _magChip(Icons.verified_rounded, d.condition, u),
        if (shareHas(d.usage)) _magChip(Icons.timer_rounded, d.usage, u),
        if (shareHas(d.location)) _magChip(Icons.location_on_rounded, shareShortLocation(d.location), u),
      ],
    );
  }

  static Widget _magChip(IconData icon, String text, double u) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * u, vertical: 5 * u),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: _orange, size: 12 * u),
          SizedBox(width: 4 * u),
          Text(text, style: TextStyle(color: const Color(0xFF101827), fontSize: 8.8 * u, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _singleLineMeta(ShareProductData d, double u, {required Color accent}) {
    return Wrap(
      spacing: 6 * u,
      runSpacing: 5 * u,
      children: <Widget>[
        if (shareHas(d.condition)) _darkTinyChip(Icons.verified_rounded, d.condition, u, accent),
        if (shareHas(d.usage)) _darkTinyChip(Icons.timer_rounded, d.usage, u, accent),
        if (shareHas(d.location)) _darkTinyChip(Icons.location_on_rounded, shareShortLocation(d.location), u, accent),
      ],
    );
  }

  static Widget _darkTinyChip(IconData icon, String text, double u, Color accent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * u, vertical: 4 * u),
      decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(999), border: Border.all(color: accent.withOpacity(0.28))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: accent, size: 11 * u),
          SizedBox(width: 3 * u),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 8.5 * u, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  static Widget _bigNeonTitle(double u) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text('LEVEL', textDirection: TextDirection.ltr, style: TextStyle(color: _pink, fontSize: 38 * u, height: 0.85, fontWeight: FontWeight.w900, shadows: <Shadow>[Shadow(color: _pink.withOpacity(0.8), blurRadius: 15 * u)])),
        Text('UP', textDirection: TextDirection.ltr, style: TextStyle(color: const Color(0xFF18A7FF), fontSize: 48 * u, height: 0.85, fontWeight: FontWeight.w900, shadows: <Shadow>[Shadow(color: const Color(0xFF18A7FF).withOpacity(0.75), blurRadius: 15 * u)])),
      ],
    );
  }

  static Widget _neonSlashes(double u) {
    return Transform.rotate(
      angle: -0.7,
      child: Column(
        children: List<Widget>.generate(
          4,
              (int i) => Container(
            width: (54 + i * 16) * u,
            height: 3 * u,
            margin: EdgeInsets.only(bottom: 5 * u),
            decoration: BoxDecoration(color: _pink.withOpacity(0.55), borderRadius: BorderRadius.circular(999)),
          ),
        ),
      ),
    );
  }

  static Widget _terminalDot(Color color, double u) {
    return Container(
      width: 7 * u,
      height: 7 * u,
      margin: EdgeInsets.only(right: 4 * u),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  static Widget _dotGrid(double u, Color color) {
    return SizedBox(
      width: 52 * u,
      height: 42 * u,
      child: Wrap(
        spacing: 5 * u,
        runSpacing: 5 * u,
        children: List<Widget>.generate(
          30,
              (_) => Container(width: 2.2 * u, height: 2.2 * u, decoration: BoxDecoration(color: color.withOpacity(0.22), shape: BoxShape.circle)),
        ),
      ),
    );
  }

  static Widget _glow(double u, Color color, double size) {
    return Container(
      width: size * u,
      height: size * u,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: <Color>[color, Colors.transparent])),
    );
  }

  static Widget _circuitCorner(double u, Color color) {
    return SizedBox(
      width: 92 * u,
      height: 60 * u,
      child: CustomPaint(painter: _CircuitPainter(color: color.withOpacity(0.42), stroke: 1.1 * u)),
    );
  }
}

class _ThemeFrame extends StatelessWidget {
  const _ThemeFrame({
    required this.background,
    required this.childBuilder,
    this.padding,
  });

  final Gradient background;
  final EdgeInsets? padding;
  final Widget Function(BuildContext context, double unit) childBuilder;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double u = (c.maxWidth / 390).clamp(0.82, 1.22);
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(gradient: background),
            child: Padding(
              padding: padding ?? EdgeInsets.all(14 * u),
              child: childBuilder(context, u),
            ),
          );
        },
      ),
    );
  }
}

class _Info {
  const _Info(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _Benefit {
  const _Benefit(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _CircuitPainter extends CustomPainter {
  const _CircuitPainter({required this.color, required this.stroke});

  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      ..moveTo(0, size.height * 0.18)
      ..lineTo(size.width * 0.22, size.height * 0.18)
      ..lineTo(size.width * 0.33, size.height * 0.38)
      ..lineTo(size.width * 0.58, size.height * 0.38)
      ..moveTo(0, size.height * 0.50)
      ..lineTo(size.width * 0.43, size.height * 0.50)
      ..lineTo(size.width * 0.56, size.height * 0.74)
      ..lineTo(size.width * 0.90, size.height * 0.74)
      ..moveTo(size.width * 0.72, 0)
      ..lineTo(size.width * 0.72, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.25);
    canvas.drawPath(path, p);

    final Paint dot = Paint()..color = color.withOpacity(0.78);
    for (final Offset o in <Offset>[
      Offset(size.width * 0.22, size.height * 0.18),
      Offset(size.width * 0.58, size.height * 0.38),
      Offset(size.width * 0.90, size.height * 0.74),
      Offset(size.width * 0.72, size.height * 0.25),
    ]) {
      canvas.drawCircle(o, 2.2, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.stroke != stroke;
  }
}
