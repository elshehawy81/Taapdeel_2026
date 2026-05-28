import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class KidsShareThemes {
  const KidsShareThemes._();

  static const Color _ink = Color(0xFF243047);
  static const Color _navy = Color(0xFF0D2440);
  static const Color _cream = Color(0xFFFFF6E8);
  static const Color _pink = Color(0xFFFF6FAE);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _blue = Color(0xFF4BA3FF);
  static const Color _cyan = Color(0xFF24D5D8);
  static const Color _mint = Color(0xFF5EE6A8);
  static const Color _yellow = Color(0xFFFFC857);
  static const Color _orange = Color(0xFFFF9F43);

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
    ShareThemeDefinition(
      id: 'kids_playful_clouds',
      label: 'Playful Clouds',
      subtitle: 'لطيف ومرح',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFFFFF6E8), Color(0xFFFFD6E8)],
      priority: 10,
      builder: _playfulClouds,
    ),
    ShareThemeDefinition(
      id: 'kids_toy_store',
      label: 'Toy Store',
      subtitle: 'ألوان لعب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFF4BA3FF), Color(0xFFFFC857)],
      priority: 20,
      builder: _toyStore,
    ),
    ShareThemeDefinition(
      id: 'kids_baby_soft',
      label: 'Baby Soft',
      subtitle: 'هادئ للبيبي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFFEAF7FF), Color(0xFFFFEEF7)],
      priority: 30,
      builder: _babySoft,
    ),
    ShareThemeDefinition(
      id: 'kids_superhero',
      label: 'Superhero',
      subtitle: 'قوي وحماسي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFF182B5C), Color(0xFFFFC857)],
      priority: 40,
      builder: _superhero,
    ),
    ShareThemeDefinition(
      id: 'kids_rainbow_card',
      label: 'Rainbow Card',
      subtitle: 'قوس قزح',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFFFF6FAE), Color(0xFF5EE6A8)],
      priority: 50,
      builder: _rainbowCard,
    ),
    ShareThemeDefinition(
      id: 'kids_school_fun',
      label: 'School Fun',
      subtitle: 'مدرسي مرح',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFFFFF7D6), Color(0xFF4BA3FF)],
      priority: 60,
      builder: _schoolFun,
    ),
    ShareThemeDefinition(
      id: 'kids_magic_story',
      label: 'Magic Story',
      subtitle: 'خيالي ومميز',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFF2B174A), Color(0xFFFF6FAE)],
      priority: 70,
      builder: _magicStory,
    ),
    ShareThemeDefinition(
      id: 'kids_minimal_parent',
      label: 'Parent Clean',
      subtitle: 'مناسب للأمهات',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFFEAF7FF)],
      priority: 80,
      builder: _minimalParent,
    ),
    ShareThemeDefinition(
      id: 'kids_adventure_map',
      label: 'Adventure Map',
      subtitle: 'مغامرة أطفال',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFFB8F7D4), Color(0xFFFFE4A3)],
      priority: 90,
      builder: _adventureMap,
    ),
    ShareThemeDefinition(
      id: 'kids_big_smile',
      label: 'Big Smile',
      subtitle: 'فرحة المنتج',
      groups: const <ShareThemeGroup>[ShareThemeGroup.kids],
      gradient: const <Color>[Color(0xFFFFF1F7), Color(0xFFFFC857)],
      priority: 100,
      builder: _bigSmile,
    ),
  ];

  static Widget _playfulClouds(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFF8EC), Color(0xFFFFE1EF), Color(0xFFFFF8EC)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 42 * u, left: 14 * u, child: _cloud(u, _pink.withOpacity(0.18), 62)),
            Positioned(top: 96 * u, right: 8 * u, child: _cloud(u, _blue.withOpacity(0.16), 52)),
            Positioned(bottom: 96 * u, left: -10 * u, child: _cloud(u, _yellow.withOpacity(0.20), 70)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _pink, fg: _ink, light: true),
                SizedBox(height: 10 * u),
                Text('فرحة صغيرة', style: TextStyle(color: _ink, fontSize: 31 * u, fontWeight: FontWeight.w900, height: 1)),
                Text('تقدر تفرّح طفل تاني ✨', style: TextStyle(color: _pink, fontSize: 13 * u, fontWeight: FontWeight.w900)),
                SizedBox(height: 10 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(9 * u),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32 * u),
                      boxShadow: <BoxShadow>[BoxShadow(color: _pink.withOpacity(0.20), blurRadius: 24 * u, offset: Offset(0, 10 * u))],
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(25 * u), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
                SizedBox(height: 10 * u),
                _centerTitle(d, u, color: _ink),
                SizedBox(height: 8 * u),
                _softChips(d, u, accent: _pink),
                SizedBox(height: 10 * u),
                _cta(u, accent: _pink, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _toyStore(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF4BA3FF), Color(0xFF5EE6A8), Color(0xFFFFC857)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 55 * u, left: -20 * u, child: _circle(u, Colors.white.withOpacity(0.18), 120)),
            Positioned(bottom: 65 * u, right: -35 * u, child: _circle(u, Colors.white.withOpacity(0.16), 150)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: Colors.white, fg: Colors.white),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 56,
                        child: Transform.rotate(
                          angle: -0.035,
                          child: _photoCard(d, u, radius: 28, shadow: Colors.black.withOpacity(0.16)),
                        ),
                      ),
                      SizedBox(width: 12 * u),
                      Expanded(
                        flex: 44,
                        child: Transform.rotate(
                          angle: 0.035,
                          child: Container(
                            padding: EdgeInsets.all(12 * u),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(28 * u),
                              boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 22 * u, offset: Offset(0, 10 * u))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text('Toy\nStore', textDirection: TextDirection.ltr, style: TextStyle(color: _ink, fontSize: 30 * u, fontWeight: FontWeight.w900, height: 0.9)),
                                SizedBox(height: 8 * u),
                                Expanded(child: _lightDetails(d, u, accent: _blue)),
                                _pricePlain(d, u, accent: _orange),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: Colors.white, textColor: _ink, iconColor: _blue),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _babySoft(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFEAF7FF), Color(0xFFFFEEF7), Color(0xFFFFFFFF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          children: <Widget>[
            _brandRow(u, d, accent: _cyan, fg: _ink, light: true),
            SizedBox(height: 12 * u),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * u, vertical: 9 * u),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), boxShadow: <BoxShadow>[BoxShadow(color: _cyan.withOpacity(0.13), blurRadius: 15 * u)]),
              child: Text('بيبي كيوت وناعم 🍼', style: TextStyle(color: _ink, fontSize: 17 * u, fontWeight: FontWeight.w900)),
            ),
            SizedBox(height: 12 * u),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _circle(u, _cyan.withOpacity(0.16), 220),
                  _circle(u, _pink.withOpacity(0.13), 160),
                  FractionallySizedBox(
                    widthFactor: 0.80,
                    heightFactor: 0.82,
                    child: _photoCard(d, u, radius: 36, shadow: _cyan.withOpacity(0.18)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * u),
            _centerTitle(d, u, color: _ink),
            SizedBox(height: 7 * u),
            _softChips(d, u, accent: _cyan),
            SizedBox(height: 12 * u),
            _cta(u, accent: _cyan, textColor: Colors.white),
          ],
        );
      },
    );
  }

  static Widget _superhero(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF182B5C), Color(0xFF0D2440), Color(0xFF02070D)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 54 * u, right: -30 * u, child: Transform.rotate(angle: -0.25, child: Container(width: 170 * u, height: 42 * u, color: _yellow.withOpacity(0.20)))),
            Positioned(bottom: 88 * u, left: -20 * u, child: Transform.rotate(angle: -0.25, child: Container(width: 210 * u, height: 55 * u, color: _blue.withOpacity(0.18)))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _yellow, fg: Colors.white),
                SizedBox(height: 10 * u),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('SUPER\nDEAL!', textDirection: TextDirection.ltr, style: TextStyle(color: _yellow, fontSize: 36 * u, fontWeight: FontWeight.w900, height: 0.85, shadows: <Shadow>[Shadow(color: _yellow.withOpacity(0.40), blurRadius: 14 * u)]))),
                    Container(
                      width: 58 * u,
                      height: 58 * u,
                      decoration: BoxDecoration(color: _pink, shape: BoxShape.circle, boxShadow: <BoxShadow>[BoxShadow(color: _pink.withOpacity(0.32), blurRadius: 18 * u)]),
                      child: Icon(Icons.flash_on_rounded, color: Colors.white, size: 35 * u),
                    ),
                  ],
                ),
                SizedBox(height: 8 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 56, child: _photoCard(d, u, radius: 22, shadow: _yellow.withOpacity(0.22))),
                      SizedBox(width: 10 * u),
                      Expanded(
                        flex: 44,
                        child: Column(
                          children: <Widget>[
                            Expanded(child: _darkDetails(d, u, accent: _yellow)),
                            SizedBox(height: 8 * u),
                            _pricePill(d, u, accent: _yellow, textColor: _ink),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * u),
                _cta(u, accent: _yellow, textColor: _ink),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _rainbowCard(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFFF6FAE), Color(0xFFFFC857), Color(0xFF5EE6A8), Color(0xFF4BA3FF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 55 * u, right: 25 * u, child: _rainbow(u)),
            Positioned(bottom: 85 * u, left: 20 * u, child: Text('★', style: TextStyle(color: Colors.white.withOpacity(0.62), fontSize: 34 * u))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: Colors.white, fg: Colors.white),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12 * u),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(34 * u),
                      boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 24 * u, offset: Offset(0, 12 * u))],
                    ),
                    child: Column(
                      children: <Widget>[
                        Text('ألوان وفرحة', style: TextStyle(color: _ink, fontSize: 28 * u, fontWeight: FontWeight.w900)),
                        SizedBox(height: 8 * u),
                        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(24 * u), child: shareNetworkImage(d.imageUrl))),
                        SizedBox(height: 9 * u),
                        _centerTitle(d, u, color: _ink),
                        SizedBox(height: 7 * u),
                        _softChips(d, u, accent: _pink),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: Colors.white, textColor: _ink, iconColor: _pink),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _schoolFun(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFF7D6), Color(0xFFEAF7FF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          children: <Widget>[
            _brandRow(u, d, accent: _blue, fg: _ink, light: true),
            SizedBox(height: 10 * u),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 47,
                    child: Container(
                      padding: EdgeInsets.all(12 * u),
                      decoration: BoxDecoration(color: const Color(0xFF243047), borderRadius: BorderRadius.circular(24 * u)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text('Back\nto Fun', textDirection: TextDirection.ltr, style: TextStyle(color: _yellow, fontSize: 31 * u, height: 0.86, fontWeight: FontWeight.w900)),
                          SizedBox(height: 10 * u),
                          Text('منتجات أطفال مفيدة وممتعة', style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 12 * u, fontWeight: FontWeight.w800)),
                          const Spacer(),
                          _chalkLine('✓ حالة واضحة', u),
                          _chalkLine('✓ سعر مناسب', u),
                          _chalkLine('✓ مشاركة سهلة', u),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * u),
                  Expanded(
                    flex: 53,
                    child: Column(
                      children: <Widget>[
                        Expanded(child: _photoCard(d, u, radius: 25, shadow: _blue.withOpacity(0.16))),
                        SizedBox(height: 8 * u),
                        _centerTitle(d, u, color: _ink),
                        SizedBox(height: 7 * u),
                        _pricePill(d, u, accent: _blue, textColor: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * u),
            _cta(u, accent: _blue, textColor: Colors.white),
          ],
        );
      },
    );
  }

  static Widget _magicStory(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const RadialGradient(
        center: Alignment.topRight,
        radius: 1.25,
        colors: <Color>[Color(0xFF59359A), Color(0xFF2B174A), Color(0xFF12091F)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 48 * u, left: 12 * u, child: _sparkles(u, _yellow)),
            Positioned(bottom: 88 * u, right: 18 * u, child: _sparkles(u, _pink)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _yellow, fg: Colors.white),
                SizedBox(height: 12 * u),
                Text('قصة سحرية', style: TextStyle(color: Colors.white, fontSize: 31 * u, fontWeight: FontWeight.w900, shadows: <Shadow>[Shadow(color: _pink.withOpacity(0.55), blurRadius: 18 * u)])),
                Text('منتج كان له ذكرى ورايح لفرحة جديدة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 11.5 * u, fontWeight: FontWeight.w800)),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Transform.rotate(angle: -0.07, child: _magicCard(u, _pink.withOpacity(0.35))),
                      Transform.rotate(angle: 0.045, child: _photoCard(d, u, radius: 28, shadow: _pink.withOpacity(0.28))),
                    ],
                  ),
                ),
                SizedBox(height: 9 * u),
                _centerTitle(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _softChips(d, u, accent: _yellow, dark: true),
                SizedBox(height: 10 * u),
                _cta(u, accent: _yellow, textColor: const Color(0xFF2B174A)),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _minimalParent(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFEAF7FF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _brandRow(u, d, accent: _cyan, fg: _ink, light: true),
            SizedBox(height: 14 * u),
            Text('اختيار عملي للأمهات', textAlign: TextAlign.center, style: TextStyle(color: _ink, fontSize: 27 * u, fontWeight: FontWeight.w900)),
            Text('منتج أطفال بحالة واضحة وسعر مناسب', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF637083), fontSize: 11.5 * u, fontWeight: FontWeight.w800)),
            SizedBox(height: 14 * u),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10 * u),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28 * u),
                  border: Border.all(color: const Color(0xFFE6EEF7)),
                  boxShadow: <BoxShadow>[BoxShadow(color: const Color(0xFF1D4E89).withOpacity(0.09), blurRadius: 22 * u, offset: Offset(0, 10 * u))],
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(flex: 55, child: ClipRRect(borderRadius: BorderRadius.circular(22 * u), child: shareNetworkImage(d.imageUrl))),
                    SizedBox(width: 10 * u),
                    Expanded(
                      flex: 45,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: _ink, fontSize: 15 * u, height: 1.12, fontWeight: FontWeight.w900)),
                          SizedBox(height: 9 * u),
                          Expanded(child: _lightDetails(d, u, accent: _cyan)),
                          _pricePlain(d, u, accent: _cyan),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12 * u),
            _cta(u, accent: _cyan, textColor: Colors.white),
          ],
        );
      },
    );
  }

  static Widget _adventureMap(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFB8F7D4), Color(0xFFFFE4A3), Color(0xFFFFC857)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _MapPatternPainter(color: const Color(0xFF8F6B2E).withOpacity(0.20)))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: const Color(0xFF177A5B), fg: _ink, light: true),
                SizedBox(height: 10 * u),
                Row(
                  children: <Widget>[
                    Icon(Icons.explore_rounded, color: const Color(0xFF177A5B), size: 35 * u),
                    SizedBox(width: 8 * u),
                    Expanded(child: Text('خريطة المغامرة', style: TextStyle(color: _ink, fontSize: 28 * u, fontWeight: FontWeight.w900))),
                  ],
                ),
                SizedBox(height: 10 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 54, child: _photoCard(d, u, radius: 24, shadow: const Color(0xFF177A5B).withOpacity(0.17))),
                      SizedBox(width: 10 * u),
                      Expanded(
                        flex: 46,
                        child: Container(
                          padding: EdgeInsets.all(10 * u),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.78),
                            borderRadius: BorderRadius.circular(22 * u),
                            border: Border.all(color: const Color(0xFF177A5B).withOpacity(0.24)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: _ink, fontSize: 14 * u, height: 1.12, fontWeight: FontWeight.w900)),
                              SizedBox(height: 8 * u),
                              Expanded(child: _lightDetails(d, u, accent: const Color(0xFF177A5B), transparent: true)),
                              _pricePlain(d, u, accent: const Color(0xFF177A5B)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: const Color(0xFF177A5B), textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _bigSmile(BuildContext context, ShareProductData d) {
    return _KidsFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFF1F7), Color(0xFFFFF6D8), Color(0xFFFFFFFF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 60 * u, right: -20 * u, child: Text('😊', style: TextStyle(fontSize: 95 * u))),
            Positioned(bottom: 92 * u, left: 8 * u, child: Text('🎁', style: TextStyle(fontSize: 42 * u))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _orange, fg: _ink, light: true),
                SizedBox(height: 12 * u),
                Text('أخيرًا حاجة تفرّح!', textAlign: TextAlign.center, style: TextStyle(color: _ink, fontSize: 28 * u, fontWeight: FontWeight.w900)),
                Text('شارك المنتج وخلي طفل تاني ينبسط', textAlign: TextAlign.center, style: TextStyle(color: _orange, fontSize: 12.5 * u, fontWeight: FontWeight.w900)),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10 * u),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30 * u), boxShadow: <BoxShadow>[BoxShadow(color: _orange.withOpacity(0.18), blurRadius: 24 * u, offset: Offset(0, 10 * u))]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(24 * u), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
                SizedBox(height: 9 * u),
                _centerTitle(d, u, color: _ink),
                SizedBox(height: 7 * u),
                _softChips(d, u, accent: _orange),
                SizedBox(height: 10 * u),
                _cta(u, accent: _orange, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _photoCard(ShareProductData d, double u, {required double radius, required Color shadow}) {
    return Container(
      padding: EdgeInsets.all(7 * u),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius * u),
        boxShadow: <BoxShadow>[BoxShadow(color: shadow, blurRadius: 24 * u, offset: Offset(0, 10 * u))],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular((radius - 7) * u), child: shareNetworkImage(d.imageUrl)),
    );
  }

  static Widget _centerTitle(ShareProductData d, double u, {required Color color}) {
    return Text(
      d.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontSize: 16 * u, fontWeight: FontWeight.w900, height: 1.15),
    );
  }

  static Widget _softChips(ShareProductData d, double u, {required Color accent, bool dark = false}) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6 * u,
      runSpacing: 6 * u,
      children: <Widget>[
        if (shareHas(d.condition)) _chip(d.condition, u, bg: dark ? Colors.white.withOpacity(0.13) : Colors.white, fg: dark ? Colors.white : accent, border: accent.withOpacity(0.25)),
        if (shareHas(sharePriceText(d))) _chip(sharePriceText(d), u, bg: accent, fg: dark ? const Color(0xFF2B174A) : Colors.white),
        if (shareHas(d.location)) _chip(shareShortLocation(d.location), u, bg: dark ? Colors.white.withOpacity(0.13) : Colors.white, fg: dark ? Colors.white : accent, border: accent.withOpacity(0.25)),
      ],
    );
  }

  static Widget _lightDetails(ShareProductData d, double u, {required Color accent, bool transparent = false}) {
    final List<_KidInfo> rows = <_KidInfo>[
      if (shareHas(d.condition)) _KidInfo(Icons.verified_rounded, 'الحالة', d.condition),
      if (shareHas(d.usage)) _KidInfo(Icons.timer_rounded, 'الاستخدام', d.usage),
      if (shareHas(d.location)) _KidInfo(Icons.location_on_rounded, 'الموقع', shareShortLocation(d.location)),
    ];

    return Column(
      children: <Widget>[
        for (final _KidInfo row in rows)
          Container(
            margin: EdgeInsets.only(bottom: 7 * u),
            padding: EdgeInsets.symmetric(horizontal: 8 * u, vertical: 7 * u),
            decoration: BoxDecoration(
              color: transparent ? Colors.white.withOpacity(0.45) : const Color(0xFFF6FAFD),
              borderRadius: BorderRadius.circular(13 * u),
              border: Border.all(color: accent.withOpacity(0.13)),
            ),
            child: Row(
              children: <Widget>[
                Icon(row.icon, color: accent, size: 14 * u),
                SizedBox(width: 5 * u),
                Expanded(child: Text('${row.label}: ${row.value}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _ink, fontSize: 9.8 * u, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
        const Spacer(),
      ],
    );
  }

  static Widget _darkDetails(ShareProductData d, double u, {required Color accent}) {
    return Container(
      padding: EdgeInsets.all(9 * u),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.20), borderRadius: BorderRadius.circular(18 * u), border: Border.all(color: accent.withOpacity(0.32))),
      child: Column(
        children: <Widget>[
          Text(d.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 12 * u, height: 1.12, fontWeight: FontWeight.w900)),
          Divider(color: Colors.white.withOpacity(0.10)),
          if (shareHas(d.condition)) _darkLine(Icons.verified_rounded, d.condition, u, accent),
          if (shareHas(d.usage)) _darkLine(Icons.timer_rounded, d.usage, u, accent),
          if (shareHas(d.location)) _darkLine(Icons.location_on_rounded, shareShortLocation(d.location), u, accent),
          const Spacer(),
        ],
      ),
    );
  }

  static Widget _darkLine(IconData icon, String text, double u, Color accent) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7 * u),
      child: Row(
        children: <Widget>[
          Icon(icon, color: accent, size: 13 * u),
          SizedBox(width: 5 * u),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 9.6 * u, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _pricePill(ShareProductData d, double u, {required Color accent, required Color textColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * u, vertical: 8 * u),
      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(999), boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.25), blurRadius: 14 * u)]),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(_price(d), maxLines: 1, style: TextStyle(color: textColor, fontSize: 18 * u, fontWeight: FontWeight.w900)),
      ),
    );
  }

  static Widget _pricePlain(ShareProductData d, double u, {required Color accent}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(_price(d), style: TextStyle(color: accent, fontSize: 25 * u, fontWeight: FontWeight.w900)),
    );
  }

  static Widget _cta(double u, {required Color accent, required Color textColor, Color? iconColor}) {
    return Container(
      height: 42 * u,
      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(18 * u), boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.25), blurRadius: 16 * u, offset: Offset(0, 7 * u))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.ios_share_rounded, color: iconColor ?? textColor, size: 18 * u),
          SizedBox(width: 8 * u),
          Text('شارك بطاقة المنتج', style: TextStyle(color: textColor, fontSize: 17 * u, fontWeight: FontWeight.w900)),
          SizedBox(width: 8 * u),
          Icon(Icons.favorite_rounded, color: iconColor ?? textColor, size: 17 * u),
        ],
      ),
    );
  }

  static Widget _chip(String text, double u, {required Color bg, required Color fg, Color? border}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9 * u, vertical: 5 * u),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999), border: border == null ? null : Border.all(color: border)),
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 9.5 * u, fontWeight: FontWeight.w900)),
    );
  }

  static Widget _brandRow(double u, ShareProductData d, {required Color accent, required Color fg, bool light = false}) {
    return Row(
      textDirection: TextDirection.ltr,
      children: <Widget>[
        Row(
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 30 * u,
              height: 30 * u,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(11 * u)),
              child: Icon(Icons.swap_horiz_rounded, color: light ? Colors.white : _ink, size: 18 * u),
            ),
            SizedBox(width: 7 * u),
            Text('تبديل | TAAPDEEL', textDirection: TextDirection.rtl, style: TextStyle(color: fg, fontSize: 14 * u, fontWeight: FontWeight.w900)),
          ],
        ),
        const Spacer(),
        Container(
          constraints: BoxConstraints(maxWidth: 112 * u),
          padding: EdgeInsets.symmetric(horizontal: 9 * u, vertical: 5 * u),
          decoration: BoxDecoration(
            color: light ? Colors.white : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withOpacity(0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.child_care_rounded, color: accent, size: 13 * u),
              SizedBox(width: 4 * u),
              Flexible(
                child: Text(_categoryText(d), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: light ? _ink : Colors.white, fontSize: 9.2 * u, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _cloud(double u, Color color, double size) {
    return SizedBox(
      width: size * u,
      height: size * 0.50 * u,
      child: Stack(
        children: <Widget>[
          Positioned(bottom: 0, left: 0, right: 0, child: Container(height: size * 0.28 * u, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)))),
          Positioned(left: size * 0.12 * u, top: size * 0.05 * u, child: _circle(u, color, size * 0.34)),
          Positioned(left: size * 0.36 * u, top: 0, child: _circle(u, color, size * 0.44)),
        ],
      ),
    );
  }

  static Widget _circle(double u, Color color, double size) {
    return Container(width: size * u, height: size * u, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  static Widget _rainbow(double u) {
    return SizedBox(
      width: 105 * u,
      height: 58 * u,
      child: CustomPaint(painter: _RainbowPainter()),
    );
  }

  static Widget _sparkles(double u, Color color) {
    return Column(
      children: <Widget>[
        Icon(Icons.auto_awesome_rounded, color: color, size: 24 * u),
        SizedBox(height: 9 * u),
        Icon(Icons.star_rounded, color: color.withOpacity(0.75), size: 14 * u),
      ],
    );
  }

  static Widget _magicCard(double u, Color color) {
    return Container(
      margin: EdgeInsets.all(22 * u),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(32 * u), border: Border.all(color: Colors.white.withOpacity(0.16))),
    );
  }

  static Widget _chalkLine(String text, double u) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * u),
      child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.86), fontSize: 11 * u, fontWeight: FontWeight.w800)),
    );
  }

  static String _categoryText(ShareProductData d) {
    if (shareHas(d.subCategory)) return d.subCategory;
    if (shareHas(d.category)) return d.category;
    return 'أطفال';
  }

  static String _price(ShareProductData d) {
    final String txt = sharePriceText(d);
    return shareHas(txt) ? txt : 'السعر عند التواصل';
  }
}

class _KidsFrame extends StatelessWidget {
  const _KidsFrame({
    required this.background,
    required this.childBuilder,
  });

  final Gradient background;
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
              padding: EdgeInsets.all(14 * u),
              child: childBuilder(context, u),
            ),
          );
        },
      ),
    );
  }
}

class _KidInfo {
  const _KidInfo(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _RainbowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final List<Color> colors = <Color>[
      const Color(0xFFFF6FAE),
      const Color(0xFFFFC857),
      const Color(0xFF5EE6A8),
      const Color(0xFF4BA3FF),
    ];

    for (int i = 0; i < colors.length; i++) {
      final Paint p = Paint()
        ..color = colors[i]
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final Rect r = Rect.fromLTWH(8.0 + i * 9, 10.0 + i * 9, size.width - 16.0 - i * 18, size.height * 1.55 - i * 18);
      canvas.drawArc(r, math.pi, math.pi, false, p);
    }
  }

  @override
  bool shouldRepaint(covariant _RainbowPainter oldDelegate) => false;
}

class _MapPatternPainter extends CustomPainter {
  const _MapPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.25)
      ..cubicTo(size.width * 0.26, size.height * 0.18, size.width * 0.30, size.height * 0.42, size.width * 0.50, size.height * 0.35)
      ..cubicTo(size.width * 0.70, size.height * 0.28, size.width * 0.78, size.height * 0.54, size.width * 0.95, size.height * 0.47)
      ..moveTo(size.width * 0.12, size.height * 0.72)
      ..cubicTo(size.width * 0.32, size.height * 0.62, size.width * 0.45, size.height * 0.82, size.width * 0.68, size.height * 0.72)
      ..cubicTo(size.width * 0.80, size.height * 0.66, size.width * 0.86, size.height * 0.76, size.width * 0.95, size.height * 0.70);

    canvas.drawPath(path, p);

    final Paint dot = Paint()..color = color.withOpacity(0.85);
    for (final Offset o in <Offset>[
      Offset(size.width * 0.12, size.height * 0.25),
      Offset(size.width * 0.50, size.height * 0.35),
      Offset(size.width * 0.80, size.height * 0.50),
      Offset(size.width * 0.38, size.height * 0.70),
      Offset(size.width * 0.68, size.height * 0.72),
    ]) {
      canvas.drawCircle(o, 3.2, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPatternPainter oldDelegate) => oldDelegate.color != color;
}
