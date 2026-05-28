import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class SportsShareThemes {
  const SportsShareThemes._();

  static const Color _dark = Color(0xFF07110C);
  static const Color _black = Color(0xFF050607);
  static const Color _lime = Color(0xFF7CFF00);
  static const Color _orange = Color(0xFFFFA000);
  static const Color _blue = Color(0xFF1EA7FF);
  static const Color _red = Color(0xFFFF3B30);
  static const Color _green = Color(0xFF00D084);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _yellow = Color(0xFFFFD166);
  static const Color _white = Color(0xFFFFFFFF);

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
    // ترتيب الثيمات: أهلي → زمالك → رياضي عام
    ShareThemeDefinition(
      id: 'sports_ahly_gomhoro_deh_hamah',
      label: 'جمهوره ده حماه',
      subtitle: 'أهلاوي جماهيري',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFE30613), Color(0xFF050505)],
      priority: 10,
      builder: _ahlyGomhoroDehHamah,
    ),
    ShareThemeDefinition(
      id: 'sports_zamalek_fakhr_leya',
      label: 'زملكاوي أنا والفخر ليا',
      subtitle: 'فخر أبيض',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFFE30613)],
      priority: 20,
      builder: _zamalekFakhrLeya,
    ),
    ShareThemeDefinition(
      id: 'sports_neon_power',
      label: 'ستايل رياضي',
      subtitle: 'طاقة وحركة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFF7CFF00), Color(0xFF061A10)],
      priority: 30,
      builder: _neonPower,
    ),

    ShareThemeDefinition(
      id: 'sports_ahly_talta_shemal',
      label: 'التالتة شمال',
      subtitle: 'بتهز جبال',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFB00018), Color(0xFF111111)],
      priority: 40,
      builder: _ahlyTaltaShemal,
    ),
    ShareThemeDefinition(
      id: 'sports_zamalek_madraset_fan',
      label: 'يا زمالك يا مدرسة لعب وفن وهندسة',
      subtitle: 'فن وهندسة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFF1EA7FF)],
      priority: 50,
      builder: _zamalekMadrasetFan,
    ),
    ShareThemeDefinition(
      id: 'sports_match_day',
      label: 'يوم المباراة',
      subtitle: 'للأدوات الرياضية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFFA000), Color(0xFF101010)],
      priority: 60,
      builder: _matchDay,
    ),

    ShareThemeDefinition(
      id: 'sports_ahly_fakhr_leya',
      label: 'أهلاوي والفخر ليا',
      subtitle: 'فخر وانتماء',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFE30613), Color(0xFFFFD166)],
      priority: 70,
      builder: _ahlyFakhrLeya,
    ),
    ShareThemeDefinition(
      id: 'sports_zamalek_abyad_aaly',
      label: 'الأبيض دايمًا عالي',
      subtitle: 'الأبيض عالي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFFE5E7EB)],
      priority: 80,
      builder: _zamalekAbyadAaly,
    ),
    ShareThemeDefinition(
      id: 'sports_stadium_lights',
      label: 'أضواء الملعب',
      subtitle: 'بوستر احترافي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFF1EA7FF), Color(0xFF07182D)],
      priority: 90,
      builder: _stadiumLights,
    ),

    ShareThemeDefinition(
      id: 'sports_ahly_greatest_club',
      label: 'أعظم نادي في الكون',
      subtitle: 'بوستر بطولة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFF111111), Color(0xFFE30613)],
      priority: 100,
      builder: _ahlyGreatestClub,
    ),
    ShareThemeDefinition(
      id: 'sports_zamalek_royal_impossible',
      label: 'الملكي لا يعرف المستحيل',
      subtitle: 'روح الملكي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFFFFD166)],
      priority: 110,
      builder: _zamalekRoyalImpossible,
    ),
    ShareThemeDefinition(
      id: 'sports_scoreboard',
      label: 'Scoreboard',
      subtitle: 'لوحة نتائج',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFF00D084), Color(0xFF031A12)],
      priority: 120,
      builder: _scoreboard,
    ),

    ShareThemeDefinition(
      id: 'sports_ahly_six_one',
      label: '6-1',
      subtitle: 'تصميم نتيجة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFE30613), Color(0xFF050505)],
      priority: 130,
      builder: _ahlySixOne,
    ),
    ShareThemeDefinition(
      id: 'sports_zamalek_eshq_omr',
      label: 'زمالك يا عشق العمر',
      subtitle: 'عشق أبيض',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFFE30613)],
      priority: 140,
      builder: _zamalekEshqOmr,
    ),
    ShareThemeDefinition(
      id: 'sports_training_card',
      label: 'Training Card',
      subtitle: 'معدات تمرين',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFEFF4F0), Color(0xFF00D084)],
      priority: 150,
      builder: _trainingCard,
    ),

    ShareThemeDefinition(
      id: 'sports_zamalek_fan_we_handsa',
      label: 'مدرسة الفن والهندسة',
      subtitle: 'تصميم زملكاوي إضافي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFF1EA7FF)],
      priority: 160,
      builder: _zamalekFanWeHandasa,
    ),
    ShareThemeDefinition(
      id: 'sports_speed_lines',
      label: 'Speed Lines',
      subtitle: 'حركة وسرعة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFF3B30), Color(0xFF111111)],
      priority: 170,
      builder: _speedLines,
    ),
    ShareThemeDefinition(
      id: 'sports_clean_shop',
      label: 'Clean Sport',
      subtitle: 'واضح وبسيط',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFFEAF7FF)],
      priority: 180,
      builder: _cleanShop,
    ),
    ShareThemeDefinition(
      id: 'sports_champion_gold',
      label: 'Champion Gold',
      subtitle: 'ستايل بطولة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFFFFD166), Color(0xFF201600)],
      priority: 190,
      builder: _championGold,
    ),
    ShareThemeDefinition(
      id: 'sports_urban_court',
      label: 'Urban Court',
      subtitle: 'شارع وملعب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFF8B5CF6), Color(0xFF101010)],
      priority: 200,
      builder: _urbanCourt,
    ),
    ShareThemeDefinition(
      id: 'sports_photo_hero',
      label: 'Photo Hero',
      subtitle: 'الصورة هي البطل',
      groups: const <ShareThemeGroup>[ShareThemeGroup.sports],
      gradient: const <Color>[Color(0xFF111111), Color(0xFF7CFF00)],
      priority: 210,
      builder: _photoHero,
    ),
  ];

  static Widget _neonPower(BuildContext context, ShareProductData d) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF061A10), Color(0xFF020403), Color(0xFF000000)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: -45 * u, right: -28 * u, child: _circle(u, _lime.withOpacity(0.13), 155)),
            Positioned(bottom: -55 * u, left: -40 * u, child: _circle(u, _lime.withOpacity(0.08), 190)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _brandRow(u, d, accent: _lime, fg: Colors.white),
                SizedBox(height: 12 * u),
                Text(
                  'READY\nTO PLAY',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: _lime, fontSize: 34 * u, height: 0.86, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900),
                ),
                Text('GEAR WITH ENERGY', textDirection: TextDirection.ltr, style: TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 9.5 * u, fontWeight: FontWeight.w800, letterSpacing: 1)),
                SizedBox(height: 12 * u),
                Expanded(child: _glowImage(d, u, accent: _lime)),
                SizedBox(height: 10 * u),
                _title(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _chips(d, u, accent: _lime, dark: true),
                SizedBox(height: 10 * u),
                _footerLine(u, 'MOVE FAST · SWAP SMART', Colors.white54),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _matchDay(BuildContext context, ShareProductData d) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFF14100A), Color(0xFF050505)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _PitchLinesPainter(color: _orange.withOpacity(0.18)))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _orange, fg: Colors.white),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 56, child: _glowImage(d, u, accent: _orange, radius: 22)),
                      SizedBox(width: 12 * u),
                      Expanded(
                        flex: 44,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'OWN\nTHE GAME',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(color: _orange, fontSize: 31 * u, height: 0.86, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 8 * u),
                            Text('Second hand. First move.', textDirection: TextDirection.ltr, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 9.5 * u, fontWeight: FontWeight.w800)),
                            SizedBox(height: 10 * u),
                            Expanded(child: _darkDetails(d, u, accent: _orange)),
                            SizedBox(height: 8 * u),
                            _priceBox(d, u, accent: _orange, textColor: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: _orange, textColor: Colors.black),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _stadiumLights(BuildContext context, ShareProductData d) {
    return _SportFrame(
      background: const RadialGradient(
        center: Alignment.topCenter,
        radius: 1.25,
        colors: <Color>[Color(0xFF0E3158), Color(0xFF07182D), Color(0xFF02060B)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: -10 * u, left: 20 * u, child: _lightBeam(u, alignmentLeft: true)),
            Positioned(top: -10 * u, right: 20 * u, child: _lightBeam(u, alignmentLeft: false)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _blue, fg: Colors.white),
                SizedBox(height: 12 * u),
                Text('STADIUM\nLIGHTS', textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 32 * u, height: 0.88, fontWeight: FontWeight.w900, letterSpacing: 0.7)),
                Text('جاهز للعب؟ شارك المنتج', textAlign: TextAlign.center, style: TextStyle(color: _blue, fontSize: 12 * u, fontWeight: FontWeight.w900)),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(7 * u),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28 * u),
                      border: Border.all(color: _blue.withOpacity(0.55), width: 1.2),
                      boxShadow: <BoxShadow>[BoxShadow(color: _blue.withOpacity(0.22), blurRadius: 26 * u)],
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(22 * u), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
                SizedBox(height: 10 * u),
                _sportsCard(d, u, accent: _blue),
                SizedBox(height: 10 * u),
                _cta(u, accent: _blue, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _scoreboard(BuildContext context, ShareProductData d) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF031A12), Color(0xFF07110C), Color(0xFF020403)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          children: <Widget>[
            _brandRow(u, d, accent: _green, fg: Colors.white),
            SizedBox(height: 12 * u),
            Container(
              padding: EdgeInsets.all(10 * u),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20 * u),
                border: Border.all(color: _green.withOpacity(0.45)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'SCOREBOARD',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(color: _green, fontSize: 25 * u, fontWeight: FontWeight.w900, letterSpacing: 1.4),
                    ),
                  ),
                  _scoreDigit('9', u),
                  SizedBox(width: 5 * u),
                  _scoreDigit('0', u),
                ],
              ),
            ),
            SizedBox(height: 12 * u),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(flex: 54, child: _glowImage(d, u, accent: _green, radius: 20)),
                  SizedBox(width: 12 * u),
                  Expanded(
                    flex: 46,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 15 * u, height: 1.12, fontWeight: FontWeight.w900)),
                        SizedBox(height: 10 * u),
                        Expanded(child: _darkDetails(d, u, accent: _green)),
                        SizedBox(height: 8 * u),
                        _priceBox(d, u, accent: _green, textColor: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * u),
            _cta(u, accent: _green, textColor: Colors.black),
          ],
        );
      },
    );
  }

  static Widget _trainingCard(BuildContext context, ShareProductData d) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFEFF4F0), Color(0xFFFFFFFF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          children: <Widget>[
            _brandRow(u, d, accent: _green, fg: const Color(0xFF15231B), light: true),
            SizedBox(height: 14 * u),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12 * u),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30 * u),
                  boxShadow: <BoxShadow>[BoxShadow(color: _green.withOpacity(0.12), blurRadius: 24 * u, offset: Offset(0, 10 * u))],
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: Text('Training\nEssentials', textDirection: TextDirection.ltr, style: TextStyle(color: const Color(0xFF15231B), fontSize: 29 * u, height: 0.9, fontWeight: FontWeight.w900))),
                        Container(
                          width: 54 * u,
                          height: 54 * u,
                          decoration: BoxDecoration(color: _green.withOpacity(0.13), shape: BoxShape.circle),
                          child: Icon(Icons.fitness_center_rounded, color: _green, size: 29 * u),
                        ),
                      ],
                    ),
                    SizedBox(height: 10 * u),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(flex: 56, child: ClipRRect(borderRadius: BorderRadius.circular(24 * u), child: shareNetworkImage(d.imageUrl))),
                          SizedBox(width: 10 * u),
                          Expanded(
                            flex: 44,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF15231B), fontSize: 14 * u, height: 1.12, fontWeight: FontWeight.w900)),
                                SizedBox(height: 8 * u),
                                Expanded(child: _lightDetails(d, u, accent: _green)),
                                _pricePlain(d, u, accent: _green),
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
            SizedBox(height: 12 * u),
            _cta(u, accent: _green, textColor: Colors.white),
          ],
        );
      },
    );
  }

  static Widget _speedLines(BuildContext context, ShareProductData d) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF270806), Color(0xFF111111), Color(0xFF020202)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _SpeedLinesPainter(color: _red.withOpacity(0.28)))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _red, fg: Colors.white),
                SizedBox(height: 12 * u),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('FAST\nMOVE', textDirection: TextDirection.ltr, style: TextStyle(color: _red, fontSize: 37 * u, height: 0.84, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900))),
                    Icon(Icons.speed_rounded, color: _red, size: 50 * u),
                  ],
                ),
                SizedBox(height: 10 * u),
                Expanded(
                  child: Transform.rotate(
                    angle: -0.035,
                    child: _glowImage(d, u, accent: _red, radius: 24),
                  ),
                ),
                SizedBox(height: 10 * u),
                _title(d, u, color: Colors.white),
                SizedBox(height: 7 * u),
                _chips(d, u, accent: _red, dark: true),
                SizedBox(height: 10 * u),
                _cta(u, accent: _red, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _cleanShop(BuildContext context, ShareProductData d) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFEAF7FF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _brandRow(u, d, accent: _blue, fg: const Color(0xFF122033), light: true),
            SizedBox(height: 14 * u),
            Text('شارك منتجك الرياضي', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF122033), fontSize: 27 * u, fontWeight: FontWeight.w900)),
            Text('صورة واضحة + تفاصيل مختصرة', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF637083), fontSize: 11.5 * u, fontWeight: FontWeight.w800)),
            SizedBox(height: 12 * u),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12 * u),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28 * u),
                  border: Border.all(color: const Color(0xFFE6EEF7)),
                  boxShadow: <BoxShadow>[BoxShadow(color: _blue.withOpacity(0.10), blurRadius: 22 * u, offset: Offset(0, 10 * u))],
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(flex: 56, child: ClipRRect(borderRadius: BorderRadius.circular(22 * u), child: shareNetworkImage(d.imageUrl))),
                    SizedBox(width: 10 * u),
                    Expanded(
                      flex: 44,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF122033), fontSize: 14.2 * u, height: 1.12, fontWeight: FontWeight.w900)),
                          SizedBox(height: 8 * u),
                          Expanded(child: _lightDetails(d, u, accent: _blue)),
                          _pricePlain(d, u, accent: _blue),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12 * u),
            _cta(u, accent: _blue, textColor: Colors.white),
          ],
        );
      },
    );
  }

  static Widget _championGold(BuildContext context, ShareProductData d) {
    return _SportFrame(
      background: const RadialGradient(
        center: Alignment.topCenter,
        radius: 1.22,
        colors: <Color>[Color(0xFF4A3604), Color(0xFF201600), Color(0xFF050403)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 58 * u, right: -20 * u, child: Icon(Icons.emoji_events_rounded, color: _yellow.withOpacity(0.15), size: 130 * u)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _yellow, fg: Colors.white),
                SizedBox(height: 12 * u),
                Text('CHAMPION\nGEAR', textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: TextStyle(color: _yellow, fontSize: 33 * u, height: 0.88, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      _circle(u, _yellow.withOpacity(0.13), 245),
                      FractionallySizedBox(widthFactor: 0.84, heightFactor: 0.86, child: _glowImage(d, u, accent: _yellow, radius: 28)),
                    ],
                  ),
                ),
                SizedBox(height: 8 * u),
                _title(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _chips(d, u, accent: _yellow, dark: true),
                SizedBox(height: 10 * u),
                _cta(u, accent: _yellow, textColor: Colors.black),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _urbanCourt(BuildContext context, ShareProductData d) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF101010), Color(0xFF201336), Color(0xFF050505)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _CourtPainter(color: _purple.withOpacity(0.24)))),
            Positioned(top: 18 * u, left: 15 * u, child: _dotGrid(u, _purple)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _purple, fg: Colors.white),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 58,
                        child: Transform.rotate(angle: -0.04, child: _glowImage(d, u, accent: _purple, radius: 26)),
                      ),
                      SizedBox(width: 12 * u),
                      Expanded(
                        flex: 42,
                        child: Container(
                          padding: EdgeInsets.all(11 * u),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.34),
                            borderRadius: BorderRadius.circular(24 * u),
                            border: Border.all(color: _purple.withOpacity(0.45)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text('URBAN\nCOURT', textDirection: TextDirection.ltr, style: TextStyle(color: _purple, fontSize: 29 * u, height: 0.88, fontWeight: FontWeight.w900)),
                              SizedBox(height: 10 * u),
                              Expanded(child: _darkDetails(d, u, accent: _purple)),
                              SizedBox(height: 8 * u),
                              _priceBox(d, u, accent: _purple, textColor: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: _purple, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _photoHero(BuildContext context, ShareProductData d) {
    return _SportFrame(
      padding: EdgeInsets.zero,
      background: const LinearGradient(colors: <Color>[Color(0xFF111111), Color(0xFF111111)]),
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
                    colors: <Color>[Colors.black.withOpacity(0.18), Colors.black.withOpacity(0.18), Colors.black.withOpacity(0.84)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14 * u),
              child: Column(
                children: <Widget>[
                  _brandRow(u, d, accent: _lime, fg: Colors.white),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(14 * u),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.56),
                      borderRadius: BorderRadius.circular(26 * u),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('PHOTO HERO', textDirection: TextDirection.ltr, style: TextStyle(color: _lime, fontSize: 14 * u, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        SizedBox(height: 4 * u),
                        Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 21 * u, height: 1.05, fontWeight: FontWeight.w900)),
                        SizedBox(height: 8 * u),
                        _chips(d, u, accent: _lime, dark: true),
                        SizedBox(height: 10 * u),
                        Row(
                          children: <Widget>[
                            Expanded(child: _priceBox(d, u, accent: _lime, textColor: Colors.black)),
                            SizedBox(width: 8 * u),
                            SizedBox(width: 118 * u, child: _cta(u, accent: _lime, textColor: Colors.black, compact: true)),
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


  // -------------------- Ahly phrase-based share themes --------------------
  // Fan-inspired color themes only. No official club logos or protected marks are used.

  static Widget _ahlyGomhoroDehHamah(BuildContext context, ShareProductData d) {
    const Color red = Color(0xFFE30613);
    return _ahlyPhrasePoster(
      d,
      phrase: 'جمهوره ده حماه',
      smallLine: 'المدرج سند وحكاية',
      accent: red,
      dark: const Color(0xFF140003),
      style: _AhlyPhraseStyle.crowd,
      icon: Icons.groups_rounded,
    );
  }

  static Widget _ahlyTaltaShemal(BuildContext context, ShareProductData d) {
    const Color red = Color(0xFFE30613);
    return _ahlyPhrasePoster(
      d,
      phrase: 'التالتة شمال بتهز جبال',
      smallLine: 'طاقة المدرج الأحمر',
      accent: red,
      dark: const Color(0xFF090909),
      style: _AhlyPhraseStyle.mountain,
      icon: Icons.terrain_rounded,
    );
  }

  static Widget _ahlyFakhrLeya(BuildContext context, ShareProductData d) {
    const Color red = Color(0xFFE30613);
    const Color gold = Color(0xFFE30613);
    return _ahlyPhrasePoster(
      d,
      phrase: 'أهلاوي والفخر ليا',
      smallLine: 'فخر وانتماء',
      accent: gold,
      secondary: red,
      dark: const Color(0xFF220005),
      style: _AhlyPhraseStyle.pride,
      icon: Icons.workspace_premium_rounded,
    );
  }


  static Widget _ahlyGreatestClub(BuildContext context, ShareProductData d) {
    const Color red = Color(0xFFE30613);
    const Color gold = Color(0xFFE30613);
    return _ahlyPhrasePoster(
      d,
      phrase: 'أعظم نادي في الكون',
      smallLine: 'بوستر يليق بالأبطال',
      accent: gold,
      secondary: red,
      dark: const Color(0xFF050505),
      style: _AhlyPhraseStyle.champion,
      icon: Icons.emoji_events_rounded,
    );
  }

  static Widget _ahlySixOne(BuildContext context, ShareProductData d) {
    const Color red = Color(0xFFE30613);
    return _SportFrame(
      background: const RadialGradient(
        center: Alignment.topCenter,
        radius: 1.18,
        colors: <Color>[Color(0xFF3A0008), Color(0xFF120004), Color(0xFF050505)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _PitchLinesPainter(color: red.withOpacity(0.20)))),
            Positioned(top: 70 * u, right: -35 * u, child: _circle(u, red.withOpacity(0.18), 170)),
            Column(
              children: <Widget>[
                _ahlyPhraseBrandRow(u, d, accent: red, fg: Colors.white, text: 'أهلاوي'),
                SizedBox(height: 12 * u),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14 * u, vertical: 10 * u),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.38),
                    borderRadius: BorderRadius.circular(24 * u),
                    border: Border.all(color: red.withOpacity(0.42)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.ltr,
                    children: <Widget>[
                      _ahlyScoreDigit('6', u, red, Colors.white),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10 * u),
                        child: Text('-', textDirection: TextDirection.ltr, style: TextStyle(color: Colors.white, fontSize: 42 * u, height: 0.9, fontWeight: FontWeight.w900)),
                      ),
                      _ahlyScoreDigit('1', u, Colors.white, red),
                    ],
                  ),
                ),
                SizedBox(height: 8 * u),
                Text(
                  'نتيجة للتاريخ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.78), fontSize: 12 * u, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 56, child: _glowImage(d, u, accent: red, radius: 26)),
                      SizedBox(width: 12 * u),
                      Expanded(
                        flex: 44,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 14.5 * u, height: 1.12, fontWeight: FontWeight.w900)),
                            SizedBox(height: 10 * u),
                            Expanded(child: _darkDetails(d, u, accent: red)),
                            SizedBox(height: 8 * u),
                            _priceBox(d, u, accent: red, textColor: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: red, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _ahlyPhrasePoster(
      ShareProductData d, {
        required String phrase,
        required String smallLine,
        required Color accent,
        required Color dark,
        required _AhlyPhraseStyle style,
        required IconData icon,
        Color? secondary,
      }) {
    final Color second = secondary ?? accent;
    return _SportFrame(
      background: RadialGradient(
        center: Alignment.topRight,
        radius: 1.25,
        colors: <Color>[Color.lerp(dark, second, 0.28) ?? dark, dark, const Color(0xFF050505)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            if (style == _AhlyPhraseStyle.crowd)
              Positioned.fill(child: CustomPaint(painter: _CrowdWavePainter(color: accent.withOpacity(0.24)))),
            if (style == _AhlyPhraseStyle.mountain)
              Positioned.fill(child: CustomPaint(painter: _MountainShakePainter(color: accent.withOpacity(0.28)))),
            if (style == _AhlyPhraseStyle.pride)
              Positioned(top: 55 * u, right: -25 * u, child: Icon(Icons.workspace_premium_rounded, color: accent.withOpacity(0.15), size: 130 * u)),
            if (style == _AhlyPhraseStyle.champion)
              Positioned(top: 55 * u, right: -25 * u, child: Icon(Icons.emoji_events_rounded, color: accent.withOpacity(0.16), size: 130 * u)),
            Positioned(bottom: 86 * u, left: -35 * u, child: _circle(u, second.withOpacity(0.14), 170)),
            Column(
              children: <Widget>[
                _ahlyPhraseBrandRow(u, d, accent: accent, fg: Colors.white, text: 'أهلاوي'),
                SizedBox(height: 12 * u),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        phrase,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: phrase.contains('\n') ? 31 * u : 34 * u,
                          height: 0.96,
                          fontWeight: FontWeight.w900,
                          shadows: <Shadow>[Shadow(color: second.withOpacity(0.55), blurRadius: 16 * u)],
                        ),
                      ),
                    ),
                    Container(
                      width: 58 * u,
                      height: 58 * u,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.32), blurRadius: 18 * u)],
                      ),
                      child: Icon(icon, color: dark.computeLuminance() > 0.3 ? Colors.black : Colors.white, size: 32 * u),
                    ),
                  ],
                ),
                SizedBox(height: 6 * u),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    smallLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: accent, fontSize: 11.5 * u, fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(height: 12 * u),
                Expanded(child: _glowImage(d, u, accent: accent, radius: 28)),
                SizedBox(height: 10 * u),
                _title(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _chips(d, u, accent: accent, dark: true),
                SizedBox(height: 10 * u),
                _cta(u, accent: accent, textColor: accent == Colors.white ? Colors.black : Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _ahlyCleanEmotionPoster(
      ShareProductData d, {
        required String phrase,
        required String smallLine,
        required Color accent,
      }) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFFFEEF0), Color(0xFFFFFFFF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 70 * u, right: -25 * u, child: _circle(u, accent.withOpacity(0.11), 155)),
            Positioned(bottom: 92 * u, left: -30 * u, child: _circle(u, accent.withOpacity(0.07), 170)),
            Column(
              children: <Widget>[
                _ahlyPhraseBrandRow(u, d, accent: accent, fg: const Color(0xFF122033), text: 'أهلاوي', light: true),
                SizedBox(height: 12 * u),
                Text(
                  phrase,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFF122033), fontSize: 33 * u, height: 0.98, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5 * u),
                Text(
                  smallLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: accent, fontSize: 11.5 * u, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12 * u),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30 * u),
                      border: Border.all(color: accent.withOpacity(0.14)),
                      boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.10), blurRadius: 22 * u, offset: Offset(0, 10 * u))],
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(flex: 56, child: ClipRRect(borderRadius: BorderRadius.circular(22 * u), child: shareNetworkImage(d.imageUrl))),
                        SizedBox(width: 10 * u),
                        Expanded(
                          flex: 44,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF122033), fontSize: 14.2 * u, height: 1.12, fontWeight: FontWeight.w900)),
                              SizedBox(height: 8 * u),
                              Expanded(child: _lightDetails(d, u, accent: accent)),
                              _pricePlain(d, u, accent: accent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: accent, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _ahlyPhraseBrandRow(
      double u,
      ShareProductData d, {
        required Color accent,
        required Color fg,
        required String text,
        bool light = false,
      }) {
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
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10 * u),
                boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.22), blurRadius: 12 * u)],
              ),
              child: Icon(Icons.swap_horiz_rounded, color: light ? Colors.white : Colors.black, size: 18 * u),
            ),
            SizedBox(width: 7 * u),
            Text('تبديل | TAAPDEEL', textDirection: TextDirection.rtl, style: TextStyle(color: fg, fontSize: 14 * u, fontWeight: FontWeight.w900)),
          ],
        ),
        const Spacer(),
        Container(
          constraints: BoxConstraints(maxWidth: 120 * u),
          padding: EdgeInsets.symmetric(horizontal: 9 * u, vertical: 5 * u),
          decoration: BoxDecoration(
            color: light ? Colors.white : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withOpacity(0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.local_fire_department_rounded, color: accent, size: 13 * u),
              SizedBox(width: 4 * u),
              Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: light ? const Color(0xFF122033) : Colors.white, fontSize: 9.2 * u, fontWeight: FontWeight.w900))),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _ahlyScoreDigit(String text, double u, Color bg, Color fg) {
    return Container(
      width: 66 * u,
      height: 74 * u,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18 * u),
        boxShadow: <BoxShadow>[BoxShadow(color: bg.withOpacity(0.28), blurRadius: 16 * u)],
      ),
      child: Center(
        child: Text(
          text,
          textDirection: TextDirection.ltr,
          style: TextStyle(color: fg, fontSize: 52 * u, height: 0.95, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }



  // -------------------- Zamalek phrase-based share themes --------------------
  // Fan-inspired white themes only. No official club logos or protected marks are used.

  static Widget _zamalekFakhrLeya(BuildContext context, ShareProductData d) {
    return _zamalekPhrasePoster(
      d,
      phrase: 'زملكاوي أنا\nوالفخر ليا',
      smallLine: 'فخر أبيض وانتماء',
      accent: const Color(0xFFE30613),
      secondary: const Color(0xFF1EA7FF),
      style: _ZamalekPhraseStyle.pride,
      icon: Icons.workspace_premium_rounded,
    );
  }

  static Widget _zamalekMadrasetFan(BuildContext context, ShareProductData d) {
    return _zamalekPhrasePoster(
      d,
      phrase: 'يا زمالك\nيا مدرسة لعب\nوفن وهندسة',
      smallLine: 'الكرة فن وهندسة',
      accent: const Color(0xFF1EA7FF),
      secondary: const Color(0xFFE30613),
      style: _ZamalekPhraseStyle.school,
      icon: Icons.architecture_rounded,
    );
  }

  static Widget _zamalekAbyadAaly(BuildContext context, ShareProductData d) {
    return _zamalekPhrasePoster(
      d,
      phrase: 'الأبيض\nدايمًا عالي',
      smallLine: 'راية الأبيض فوق',
      accent: const Color(0xFFE30613),
      secondary: const Color(0xFFFFFFFF),
      style: _ZamalekPhraseStyle.highFlag,
      icon: Icons.flag_rounded,
    );
  }

  static Widget _zamalekRoyalImpossible(BuildContext context, ShareProductData d) {
    return _zamalekPhrasePoster(
      d,
      phrase: 'الملكي\nلا يعرف المستحيل',
      smallLine: 'روح لا تستسلم',
      accent: const Color(0xFFD8A84E),
      secondary: const Color(0xFFE30613),
      style: _ZamalekPhraseStyle.royal,
      icon: Icons.auto_awesome_rounded,
    );
  }

  static Widget _zamalekEshqOmr(BuildContext context, ShareProductData d) {
    return _zamalekEmotionPoster(
      d,
      phrase: 'زمالك\nيا عشق العمر',
      smallLine: 'أبيض في القلب',
      accent: const Color(0xFFE30613),
    );
  }

  static Widget _zamalekFanWeHandasa(BuildContext context, ShareProductData d) {
    return _zamalekPhrasePoster(
      d,
      phrase: 'مدرسة الفن\nوالهندسة',
      smallLine: 'ستايل أبيض مختلف',
      accent: const Color(0xFF1EA7FF),
      secondary: const Color(0xFFE30613),
      style: _ZamalekPhraseStyle.engineering,
      icon: Icons.sports_soccer_rounded,
    );
  }

  static Widget _zamalekPhrasePoster(
      ShareProductData d, {
        required String phrase,
        required String smallLine,
        required Color accent,
        required Color secondary,
        required _ZamalekPhraseStyle style,
        required IconData icon,
      }) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: _zamalekPattern(style, u, accent, secondary)),
            Positioned(top: 70 * u, right: -24 * u, child: _circle(u, accent.withOpacity(0.08), 155)),
            Positioned(bottom: 86 * u, left: -30 * u, child: _circle(u, secondary.withOpacity(0.08), 170)),
            Column(
              children: <Widget>[
                _zamalekBrandRow(u, d, accent: accent, text: 'زملكاوي'),
                SizedBox(height: 12 * u),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        phrase,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: const Color(0xFF122033),
                          fontSize: phrase.split('\n').length >= 3 ? 25 * u : 32 * u,
                          height: 0.98,
                          fontWeight: FontWeight.w900,
                          shadows: <Shadow>[Shadow(color: accent.withOpacity(0.14), blurRadius: 12 * u)],
                        ),
                      ),
                    ),
                    Container(
                      width: 58 * u,
                      height: 58 * u,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withOpacity(0.55), width: 1.3),
                        boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.13), blurRadius: 18 * u)],
                      ),
                      child: Icon(icon, color: accent, size: 31 * u),
                    ),
                  ],
                ),
                SizedBox(height: 6 * u),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    smallLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: accent, fontSize: 11.5 * u, fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(height: 12 * u),
                Expanded(child: _whiteProductImage(d, u, accent: accent)),
                SizedBox(height: 10 * u),
                _title(d, u, color: const Color(0xFF122033)),
                SizedBox(height: 8 * u),
                _chips(d, u, accent: accent),
                SizedBox(height: 10 * u),
                _cta(u, accent: accent, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _zamalekEmotionPoster(
      ShareProductData d, {
        required String phrase,
        required String smallLine,
        required Color accent,
      }) {
    return _SportFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFFFF4F5), Color(0xFFFFFFFF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 64 * u, right: -20 * u, child: Icon(Icons.favorite_rounded, color: accent.withOpacity(0.08), size: 130 * u)),
            Positioned(bottom: 92 * u, left: -26 * u, child: _circle(u, accent.withOpacity(0.07), 160)),
            Column(
              children: <Widget>[
                _zamalekBrandRow(u, d, accent: accent, text: 'زملكاوي'),
                SizedBox(height: 12 * u),
                Text(
                  phrase,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF122033),
                    fontSize: 33 * u,
                    height: 0.98,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5 * u),
                Text(
                  smallLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: accent, fontSize: 11.5 * u, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12 * u),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30 * u),
                      border: Border.all(color: accent.withOpacity(0.14)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 22 * u, offset: Offset(0, 10 * u)),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 56,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22 * u),
                            child: shareNetworkImage(d.imageUrl),
                          ),
                        ),
                        SizedBox(width: 10 * u),
                        Expanded(
                          flex: 44,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF122033), fontSize: 14.2 * u, height: 1.12, fontWeight: FontWeight.w900)),
                              SizedBox(height: 8 * u),
                              Expanded(child: _lightDetails(d, u, accent: accent)),
                              _pricePlain(d, u, accent: accent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: accent, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _zamalekPattern(_ZamalekPhraseStyle style, double u, Color accent, Color secondary) {
    switch (style) {
      case _ZamalekPhraseStyle.pride:
        return CustomPaint(painter: _ZamalekDiagonalPainter(color: accent.withOpacity(0.08), secondary: secondary.withOpacity(0.05)));
      case _ZamalekPhraseStyle.school:
        return CustomPaint(painter: _EngineeringLinesPainter(color: secondary.withOpacity(0.12)));
      case _ZamalekPhraseStyle.highFlag:
        return CustomPaint(painter: _HighFlagPainter(color: accent.withOpacity(0.12)));
      case _ZamalekPhraseStyle.royal:
        return CustomPaint(painter: _RoyalSparkPainter(color: accent.withOpacity(0.18)));
      case _ZamalekPhraseStyle.engineering:
        return CustomPaint(painter: _EngineeringLinesPainter(color: accent.withOpacity(0.12)));
    }
  }

  static Widget _zamalekBrandRow(double u, ShareProductData d, {required Color accent, required String text}) {
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
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10 * u),
                boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.15), blurRadius: 12 * u)],
              ),
              child: Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18 * u),
            ),
            SizedBox(width: 7 * u),
            Text('تبديل | TAAPDEEL', textDirection: TextDirection.rtl, style: TextStyle(color: const Color(0xFF122033), fontSize: 14 * u, fontWeight: FontWeight.w900)),
          ],
        ),
        const Spacer(),
        Container(
          constraints: BoxConstraints(maxWidth: 124 * u),
          padding: EdgeInsets.symmetric(horizontal: 9 * u, vertical: 5 * u),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withOpacity(0.36)),
            boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10 * u)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.shield_rounded, color: accent, size: 13 * u),
              SizedBox(width: 4 * u),
              Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF122033), fontSize: 9.2 * u, fontWeight: FontWeight.w900))),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _whiteProductImage(ShareProductData d, double u, {required Color accent}) {
    return Container(
      padding: EdgeInsets.all(7 * u),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28 * u),
        border: Border.all(color: accent.withOpacity(0.16), width: 1.1),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 22 * u, offset: Offset(0, 10 * u))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22 * u),
        child: shareNetworkImage(d.imageUrl),
      ),
    );
  }


  static Widget _glowImage(ShareProductData d, double u, {required Color accent, double radius = 18}) {
    return Container(
      padding: EdgeInsets.all(6 * u),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(radius * u),
        border: Border.all(color: accent.withOpacity(0.38), width: 1.2),
        boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.18), blurRadius: 24 * u, spreadRadius: 1)],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular((radius - 4) * u), child: shareNetworkImage(d.imageUrl)),
    );
  }

  static Widget _sportsCard(ShareProductData d, double u, {required Color accent}) {
    return Container(
      padding: EdgeInsets.all(10 * u),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20 * u),
        border: Border.all(color: accent.withOpacity(0.33)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: _title(d, u, color: Colors.white, align: TextAlign.start)),
          SizedBox(width: 8 * u),
          _priceBox(d, u, accent: accent, textColor: Colors.white, compact: true),
        ],
      ),
    );
  }

  static Widget _title(ShareProductData d, double u, {required Color color, TextAlign align = TextAlign.center}) {
    return Text(
      d.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: TextStyle(color: color, fontSize: 16.5 * u, fontWeight: FontWeight.w900, height: 1.15),
    );
  }

  static Widget _darkDetails(ShareProductData d, double u, {required Color accent}) {
    return Container(
      padding: EdgeInsets.all(9 * u),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18 * u),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Column(
        children: <Widget>[
          if (shareHas(d.condition)) _detailLine(Icons.verified_rounded, 'الحالة', d.condition, u, accent, dark: true),
          if (shareHas(d.usage)) _detailLine(Icons.speed_rounded, 'الاستخدام', d.usage, u, accent, dark: true),
          if (shareHas(d.location)) _detailLine(Icons.location_on_rounded, 'الموقع', shareShortLocation(d.location), u, accent, dark: true),
          const Spacer(),
        ],
      ),
    );
  }

  static Widget _lightDetails(ShareProductData d, double u, {required Color accent}) {
    return Column(
      children: <Widget>[
        if (shareHas(d.condition)) _detailLine(Icons.verified_rounded, 'الحالة', d.condition, u, accent),
        if (shareHas(d.usage)) _detailLine(Icons.speed_rounded, 'الاستخدام', d.usage, u, accent),
        if (shareHas(d.location)) _detailLine(Icons.location_on_rounded, 'الموقع', shareShortLocation(d.location), u, accent),
        const Spacer(),
      ],
    );
  }

  static Widget _detailLine(IconData icon, String label, String value, double u, Color accent, {bool dark = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 7 * u),
      padding: EdgeInsets.symmetric(horizontal: 8 * u, vertical: 7 * u),
      decoration: BoxDecoration(
        color: dark ? Colors.black.withOpacity(0.16) : const Color(0xFFF6FAFD),
        borderRadius: BorderRadius.circular(13 * u),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: accent, size: 14 * u),
          SizedBox(width: 5 * u),
          Expanded(
            child: Text(
              '$label: $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: dark ? Colors.white : const Color(0xFF122033), fontSize: 9.8 * u, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _chips(ShareProductData d, double u, {required Color accent, bool dark = false}) {
    return Wrap(
      spacing: 7 * u,
      runSpacing: 7 * u,
      alignment: WrapAlignment.center,
      children: <Widget>[
        if (shareHas(d.condition)) _chip(d.condition, u, bg: dark ? Colors.white.withOpacity(0.10) : Colors.white, fg: accent, border: accent.withOpacity(0.20), icon: Icons.verified_rounded),
        if (shareHas(d.usage)) _chip(d.usage, u, bg: dark ? Colors.white.withOpacity(0.10) : Colors.white, fg: accent, border: accent.withOpacity(0.20), icon: Icons.speed_rounded),
        if (shareHas(sharePriceText(d))) _chip(sharePriceText(d), u, bg: accent, fg: Colors.black, icon: Icons.local_offer_rounded),
        if (shareHas(d.location)) _chip(shareShortLocation(d.location), u, bg: dark ? Colors.white.withOpacity(0.10) : Colors.white, fg: accent, border: accent.withOpacity(0.20), icon: Icons.location_on_rounded),
      ],
    );
  }

  static Widget _chip(String text, double u, {required Color bg, required Color fg, Color? border, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * u, vertical: 5 * u),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, color: fg, size: 11 * u),
            SizedBox(width: 3 * u),
          ],
          Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 9.2 * u, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _priceBox(ShareProductData d, double u, {required Color accent, required Color textColor, bool compact = false}) {
    final String txt = _price(d);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * u, vertical: compact ? 6 * u : 8 * u),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(compact ? 13 * u : 16 * u),
        boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.25), blurRadius: 14 * u)],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(txt, maxLines: 1, style: TextStyle(color: textColor, fontSize: compact ? 15 * u : 18.5 * u, fontWeight: FontWeight.w900)),
      ),
    );
  }

  static Widget _pricePlain(ShareProductData d, double u, {required Color accent}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(_price(d), maxLines: 1, style: TextStyle(color: accent, fontSize: 26 * u, fontWeight: FontWeight.w900)),
    );
  }

  static Widget _cta(double u, {required Color accent, required Color textColor, bool compact = false}) {
    return Container(
      height: compact ? 36 * u : 42 * u,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(compact ? 14 * u : 18 * u),
        boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.24), blurRadius: 16 * u, offset: Offset(0, 7 * u))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.ios_share_rounded, color: textColor, size: 17 * u),
          SizedBox(width: 8 * u),
          Flexible(child: Text('شارك بطاقة المنتج', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor, fontSize: compact ? 13.5 * u : 17 * u, fontWeight: FontWeight.w900))),
          if (!compact) ...<Widget>[
            SizedBox(width: 8 * u),
            Icon(Icons.sports_soccer_rounded, color: textColor, size: 17 * u),
          ],
        ],
      ),
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
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(10 * u)),
              child: Icon(Icons.swap_horiz_rounded, color: light ? Colors.white : Colors.black, size: 18 * u),
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
            color: light ? Colors.white : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withOpacity(0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.sports_soccer_rounded, color: accent, size: 13 * u),
              SizedBox(width: 4 * u),
              Flexible(child: Text(_categoryText(d), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: light ? const Color(0xFF122033) : Colors.white, fontSize: 9.2 * u, fontWeight: FontWeight.w900))),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _scoreDigit(String text, double u) {
    return Container(
      width: 34 * u,
      height: 42 * u,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8 * u), border: Border.all(color: _green.withOpacity(0.45))),
      child: Center(child: Text(text, style: TextStyle(color: _green, fontSize: 26 * u, fontWeight: FontWeight.w900))),
    );
  }

  static Widget _circle(double u, Color color, double size) {
    return Container(width: size * u, height: size * u, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  static Widget _lightBeam(double u, {required bool alignmentLeft}) {
    return Transform.rotate(
      angle: alignmentLeft ? -0.24 : 0.24,
      child: Container(
        width: 80 * u,
        height: 210 * u,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.white.withOpacity(0.24), Colors.white.withOpacity(0.06), Colors.transparent],
          ),
        ),
      ),
    );
  }

  static Widget _dotGrid(double u, Color color) {
    return SizedBox(
      width: 58 * u,
      height: 48 * u,
      child: Wrap(
        spacing: 5 * u,
        runSpacing: 5 * u,
        children: List<Widget>.generate(
          35,
              (_) => Container(width: 2.2 * u, height: 2.2 * u, decoration: BoxDecoration(color: color.withOpacity(0.42), shape: BoxShape.circle)),
        ),
      ),
    );
  }

  static Widget _footerLine(double u, String text, Color color) {
    return Text(text, textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 9.2 * u, fontWeight: FontWeight.w900, letterSpacing: 1));
  }

  static String _categoryText(ShareProductData d) {
    if (shareHas(d.subCategory)) return d.subCategory;
    if (shareHas(d.category)) return d.category;
    return 'رياضة';
  }

  static String _price(ShareProductData d) {
    final String txt = sharePriceText(d);
    return shareHas(txt) ? txt : 'السعر عند التواصل';
  }
}



enum _ZamalekPhraseStyle {
  pride,
  school,
  highFlag,
  royal,
  engineering,
}

class _ZamalekDiagonalPainter extends CustomPainter {
  const _ZamalekDiagonalPainter({required this.color, required this.secondary});

  final Color color;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * 0.62, -size.height * 0.10);
    canvas.rotate(-0.52);
    final Paint p = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * 0.30, size.height * 1.35), const Radius.circular(18)),
      p,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.16, size.height * 0.04);
    canvas.rotate(-0.52);
    final Paint p2 = Paint()..color = secondary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * 0.18, size.height * 1.00), const Radius.circular(18)),
      p2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ZamalekDiagonalPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.secondary != secondary;
  }
}

class _EngineeringLinesPainter extends CustomPainter {
  const _EngineeringLinesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }

    final Paint dot = Paint()..color = color.withOpacity(0.75);
    for (int i = 0; i < 16; i++) {
      final double x = size.width * (0.12 + (i % 4) * 0.22);
      final double y = size.height * (0.18 + (i ~/ 4) * 0.17);
      canvas.drawCircle(Offset(x, y), 2.2, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _EngineeringLinesPainter oldDelegate) => oldDelegate.color != color;
}

class _HighFlagPainter extends CustomPainter {
  const _HighFlagPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path flag = Path()
      ..moveTo(size.width * 0.12, size.height * 0.72)
      ..lineTo(size.width * 0.12, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.34, size.height * 0.08, size.width * 0.55, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.74, size.height * 0.28, size.width * 0.92, size.height * 0.16)
      ..lineTo(size.width * 0.92, size.height * 0.38)
      ..quadraticBezierTo(size.width * 0.72, size.height * 0.50, size.width * 0.52, size.height * 0.39)
      ..quadraticBezierTo(size.width * 0.34, size.height * 0.29, size.width * 0.12, size.height * 0.40);
    canvas.drawPath(flag, p);
  }

  @override
  bool shouldRepaint(covariant _HighFlagPainter oldDelegate) => oldDelegate.color != color;
}

class _RoyalSparkPainter extends CustomPainter {
  const _RoyalSparkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final Offset c in <Offset>[
      Offset(size.width * 0.22, size.height * 0.20),
      Offset(size.width * 0.80, size.height * 0.24),
      Offset(size.width * 0.70, size.height * 0.72),
      Offset(size.width * 0.28, size.height * 0.78),
    ]) {
      canvas.drawLine(Offset(c.dx - 10, c.dy), Offset(c.dx + 10, c.dy), p);
      canvas.drawLine(Offset(c.dx, c.dy - 10), Offset(c.dx, c.dy + 10), p);
    }
  }

  @override
  bool shouldRepaint(covariant _RoyalSparkPainter oldDelegate) => oldDelegate.color != color;
}

enum _AhlyPhraseStyle {
  crowd,
  mountain,
  pride,
  champion,
}

class _CrowdWavePainter extends CustomPainter {
  const _CrowdWavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final double y = size.height * (0.20 + i * 0.13);
      final Path path = Path()..moveTo(-size.width * 0.05, y);
      for (double x = 0; x <= size.width * 1.1; x += size.width * 0.16) {
        path.quadraticBezierTo(x + size.width * 0.08, y - 18 - i * 2, x + size.width * 0.16, y);
      }
      canvas.drawPath(path, p);
    }

    final Paint dot = Paint()..color = color.withOpacity(0.72);
    for (int i = 0; i < 28; i++) {
      final double x = (i % 7) * size.width / 6.2 + size.width * 0.02;
      final double y = size.height * 0.64 + (i ~/ 7) * 15;
      canvas.drawCircle(Offset(x, y), 2.2, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _CrowdWavePainter oldDelegate) => oldDelegate.color != color;
}

class _MountainShakePainter extends CustomPainter {
  const _MountainShakePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 4; i++) {
      final double base = size.height * (0.34 + i * 0.10);
      final Path mountain = Path()
        ..moveTo(size.width * 0.02, base)
        ..lineTo(size.width * 0.18, base - 30)
        ..lineTo(size.width * 0.30, base - 10)
        ..lineTo(size.width * 0.46, base - 45)
        ..lineTo(size.width * 0.62, base - 8)
        ..lineTo(size.width * 0.78, base - 34)
        ..lineTo(size.width * 0.98, base);
      canvas.drawPath(mountain, p);
    }

    final Paint shake = Paint()
      ..color = color.withOpacity(0.70)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 7; i++) {
      final double x = size.width * (0.14 + i * 0.12);
      canvas.drawLine(Offset(x, size.height * 0.16), Offset(x + 15, size.height * 0.12), shake);
      canvas.drawLine(Offset(x + 4, size.height * 0.19), Offset(x + 20, size.height * 0.16), shake);
    }
  }

  @override
  bool shouldRepaint(covariant _MountainShakePainter oldDelegate) => oldDelegate.color != color;
}

class _SportFrame extends StatelessWidget {
  const _SportFrame({
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

class _PitchLinesPainter extends CustomPainter {
  const _PitchLinesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Rect field = Rect.fromLTWH(size.width * 0.08, size.height * 0.16, size.width * 0.84, size.height * 0.68);
    canvas.drawRRect(RRect.fromRectAndRadius(field, const Radius.circular(18)), p);
    canvas.drawLine(Offset(size.width * 0.50, field.top), Offset(size.width * 0.50, field.bottom), p);
    canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.50), size.width * 0.12, p);
  }

  @override
  bool shouldRepaint(covariant _PitchLinesPainter oldDelegate) => oldDelegate.color != color;
}

class _SpeedLinesPainter extends CustomPainter {
  const _SpeedLinesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 14; i++) {
      final double y = size.height * (0.10 + i * 0.065);
      final double x = i.isEven ? size.width * 0.02 : size.width * 0.20;
      canvas.drawLine(Offset(x, y), Offset(x + size.width * 0.42, y - size.height * 0.06), p);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedLinesPainter oldDelegate) => oldDelegate.color != color;
}

class _CourtPainter extends CustomPainter {
  const _CourtPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(size.width * 0.07, size.height * 0.18, size.width * 0.86, size.height * 0.64), p);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.50), size.width * 0.16, p);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width * 0.18, size.height * 0.50), radius: size.width * 0.16), -math.pi / 2, math.pi, false, p);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width * 0.82, size.height * 0.50), radius: size.width * 0.16), math.pi / 2, math.pi, false, p);
  }

  @override
  bool shouldRepaint(covariant _CourtPainter oldDelegate) => oldDelegate.color != color;
}
