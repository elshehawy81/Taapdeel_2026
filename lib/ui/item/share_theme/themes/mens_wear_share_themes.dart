import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class MenShareThemes {
  const MenShareThemes._();

  static const Color _ink = Color(0xFF151A22);
  static const Color _black = Color(0xFF050607);
  static const Color _navy = Color(0xFF0B1B34);
  static const Color _denim = Color(0xFF1F5E8C);
  static const Color _steel = Color(0xFF64748B);
  static const Color _camel = Color(0xFFC89455);
  static const Color _orange = Color(0xFFFF8A2A);
  static const Color _green = Color(0xFF00B47A);
  static const Color _red = Color(0xFFE94444);
  static const Color _white = Color(0xFFFFFFFF);

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
        ShareThemeDefinition(
          id: 'men_urban_denim',
          label: 'Urban Denim',
          subtitle: 'شبابي وكاجوال',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFF0B1B34), Color(0xFF1F5E8C)],
          priority: 10,
          builder: _urbanDenim,
        ),
        ShareThemeDefinition(
          id: 'men_sneaker_drop',
          label: 'Sneaker Drop',
          subtitle: 'للأحذية والسنيكرز',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFF111827), Color(0xFFFF8A2A)],
          priority: 20,
          builder: _sneakerDrop,
        ),
        ShareThemeDefinition(
          id: 'men_classic_tailor',
          label: 'Classic Tailor',
          subtitle: 'رسمي وراقي',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFF1F2937), Color(0xFFC89455)],
          priority: 30,
          builder: _classicTailor,
        ),
        ShareThemeDefinition(
          id: 'men_streetwear_black',
          label: 'Streetwear Black',
          subtitle: 'أسود قوي',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFF050607), Color(0xFF64748B)],
          priority: 40,
          builder: _streetwearBlack,
        ),
        ShareThemeDefinition(
          id: 'men_clean_market',
          label: 'Clean Men',
          subtitle: 'واضح وبسيط',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFFEAF1F8)],
          priority: 50,
          builder: _cleanMarket,
        ),
        ShareThemeDefinition(
          id: 'men_sport_casual',
          label: 'Sport Casual',
          subtitle: 'رياضي رجالي',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFF061A13), Color(0xFF00B47A)],
          priority: 60,
          builder: _sportCasual,
        ),
        ShareThemeDefinition(
          id: 'men_premium_watch',
          label: 'Premium Accessory',
          subtitle: 'إكسسوارات رجالي',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFF101010), Color(0xFFC89455)],
          priority: 70,
          builder: _premiumAccessory,
        ),
        ShareThemeDefinition(
          id: 'men_outdoor_gear',
          label: 'Outdoor Gear',
          subtitle: 'رحلات وخروج',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFF2B3A25), Color(0xFFC89455)],
          priority: 80,
          builder: _outdoorGear,
        ),
        ShareThemeDefinition(
          id: 'men_youth_hype',
          label: 'Youth Hype',
          subtitle: 'للشباب',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFF27133E), Color(0xFFE94444)],
          priority: 90,
          builder: _youthHype,
        ),
        ShareThemeDefinition(
          id: 'men_photo_first',
          label: 'Photo First',
          subtitle: 'الصورة هي البطل',
          groups: const <ShareThemeGroup>[ShareThemeGroup.mensWear],
          gradient: const <Color>[Color(0xFF111827), Color(0xFF1F5E8C)],
          priority: 100,
          builder: _photoFirst,
        ),
      ];

  static Widget _urbanDenim(BuildContext context, ShareProductData d) {
    return _MenFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF0B1B34), Color(0xFF123456), Color(0xFF050607)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _DiagonalFabricPainter(color: _denim.withOpacity(0.16)))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _brandRow(u, d, accent: _denim, fg: Colors.white),
                SizedBox(height: 12 * u),
                Text('URBAN\nDENIM', textDirection: TextDirection.ltr, style: TextStyle(color: Colors.white, fontSize: 34 * u, height: 0.86, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                Text('ستايل شبابي عملي', style: TextStyle(color: _denim.withOpacity(0.95), fontSize: 12 * u, fontWeight: FontWeight.w900)),
                SizedBox(height: 12 * u),
                Expanded(child: _imageCard(d, u, accent: _denim, radius: 22)),
                SizedBox(height: 10 * u),
                _title(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _chips(d, u, accent: _denim, dark: true),
                SizedBox(height: 10 * u),
                _footerLine(u, 'MEN STYLE · SMART SWAP', Colors.white54),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _sneakerDrop(BuildContext context, ShareProductData d) {
    return _MenFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF111827), Color(0xFF1A0D05), Color(0xFF050607)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 54 * u, right: -24 * u, child: _circle(u, _orange.withOpacity(0.18), 150)),
            Positioned(bottom: 88 * u, left: -30 * u, child: _circle(u, _orange.withOpacity(0.10), 180)),
            Positioned.fill(child: CustomPaint(painter: _SpeedPainter(color: _orange.withOpacity(0.28)))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _orange, fg: Colors.white),
                SizedBox(height: 12 * u),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('SNEAKER\nDROP', textDirection: TextDirection.ltr, style: TextStyle(color: _orange, fontSize: 34 * u, height: 0.86, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
                    ),
                    Icon(Icons.directions_run_rounded, color: _orange, size: 48 * u),
                  ],
                ),
                SizedBox(height: 10 * u),
                Expanded(
                  child: Transform.rotate(
                    angle: -0.035,
                    child: _imageCard(d, u, accent: _orange, radius: 28),
                  ),
                ),
                SizedBox(height: 10 * u),
                _title(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _chips(d, u, accent: _orange, dark: true),
                SizedBox(height: 10 * u),
                _cta(u, accent: _orange, textColor: Colors.black),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _classicTailor(BuildContext context, ShareProductData d) {
    return _MenFrame(
      background: const RadialGradient(
        center: Alignment.topRight,
        radius: 1.20,
        colors: <Color>[Color(0xFF374151), Color(0xFF1F2937), Color(0xFF07090D)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 24 * u, left: 16 * u, child: Icon(Icons.auto_awesome_rounded, color: _camel.withOpacity(0.75), size: 26 * u)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _camel, fg: Colors.white),
                SizedBox(height: 14 * u),
                Text('CLASSIC\nTAILOR', textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: TextStyle(color: _camel, fontSize: 32 * u, height: 0.88, fontWeight: FontWeight.w900, letterSpacing: 0.7)),
                Text('رسمي · أنيق · عملي', style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 12 * u, fontWeight: FontWeight.w800)),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(7 * u),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30 * u),
                      border: Border.all(color: _camel.withOpacity(0.56), width: 1.2),
                      boxShadow: <BoxShadow>[BoxShadow(color: _camel.withOpacity(0.18), blurRadius: 28 * u)],
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(24 * u), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
                SizedBox(height: 10 * u),
                _title(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _chips(d, u, accent: _camel, dark: true),
                SizedBox(height: 10 * u),
                _cta(u, accent: _camel, textColor: Colors.black),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _streetwearBlack(BuildContext context, ShareProductData d) {
    return _MenFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFF191D24), Color(0xFF050607)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 70 * u, left: -30 * u, child: _circle(u, _steel.withOpacity(0.14), 170)),
            Positioned.fill(child: CustomPaint(painter: _GridPainter(color: _steel.withOpacity(0.13)))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _steel, fg: Colors.white),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 58, child: _imageCard(d, u, accent: _steel, radius: 22)),
                      SizedBox(width: 12 * u),
                      Expanded(
                        flex: 42,
                        child: Container(
                          padding: EdgeInsets.all(11 * u),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.34),
                            borderRadius: BorderRadius.circular(24 * u),
                            border: Border.all(color: _steel.withOpacity(0.45)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text('STREET\nWEAR', textDirection: TextDirection.ltr, style: TextStyle(color: Colors.white, fontSize: 30 * u, height: 0.88, fontWeight: FontWeight.w900)),
                              SizedBox(height: 8 * u),
                              Text('Black edition', textDirection: TextDirection.ltr, style: TextStyle(color: _steel, fontSize: 10 * u, fontWeight: FontWeight.w900)),
                              SizedBox(height: 10 * u),
                              Expanded(child: _darkDetails(d, u, accent: _steel)),
                              SizedBox(height: 8 * u),
                              _priceBox(d, u, accent: _steel, textColor: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: _steel, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _cleanMarket(BuildContext context, ShareProductData d) {
    return _MenFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFEAF1F8)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _brandRow(u, d, accent: _denim, fg: _ink, light: true),
            SizedBox(height: 14 * u),
            Text('شارك ستايلك', textAlign: TextAlign.center, style: TextStyle(color: _ink, fontSize: 28 * u, fontWeight: FontWeight.w900)),
            Text('ملابس رجالي · أحذية · إكسسوارات', textAlign: TextAlign.center, style: TextStyle(color: _steel, fontSize: 11.5 * u, fontWeight: FontWeight.w800)),
            SizedBox(height: 12 * u),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12 * u),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28 * u),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: <BoxShadow>[BoxShadow(color: _denim.withOpacity(0.10), blurRadius: 22 * u, offset: Offset(0, 10 * u))],
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
                          Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: _ink, fontSize: 14.4 * u, height: 1.12, fontWeight: FontWeight.w900)),
                          SizedBox(height: 8 * u),
                          Expanded(child: _lightDetails(d, u, accent: _denim)),
                          _pricePlain(d, u, accent: _denim),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12 * u),
            _cta(u, accent: _denim, textColor: Colors.white),
          ],
        );
      },
    );
  }

  static Widget _sportCasual(BuildContext context, ShareProductData d) {
    return _MenFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF061A13), Color(0xFF07110C), Color(0xFF020403)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: -45 * u, right: -28 * u, child: _circle(u, _green.withOpacity(0.13), 155)),
            Positioned(bottom: -55 * u, left: -40 * u, child: _circle(u, _green.withOpacity(0.08), 190)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _brandRow(u, d, accent: _green, fg: Colors.white),
                SizedBox(height: 12 * u),
                Text('SPORT\nCASUAL', textDirection: TextDirection.ltr, style: TextStyle(color: _green, fontSize: 34 * u, height: 0.86, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
                Text('خروج · تمرين · يومي', style: TextStyle(color: Colors.white.withOpacity(0.66), fontSize: 11 * u, fontWeight: FontWeight.w800)),
                SizedBox(height: 12 * u),
                Expanded(child: _imageCard(d, u, accent: _green, radius: 22)),
                SizedBox(height: 10 * u),
                _title(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _chips(d, u, accent: _green, dark: true),
                SizedBox(height: 10 * u),
                _cta(u, accent: _green, textColor: Colors.black),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _premiumAccessory(BuildContext context, ShareProductData d) {
    return _MenFrame(
      background: const RadialGradient(
        center: Alignment.topCenter,
        radius: 1.25,
        colors: <Color>[Color(0xFF3B2A13), Color(0xFF101010), Color(0xFF050505)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 54 * u, right: -20 * u, child: Icon(Icons.watch_rounded, color: _camel.withOpacity(0.12), size: 140 * u)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _camel, fg: Colors.white),
                SizedBox(height: 12 * u),
                Text('PREMIUM\nACCESSORY', textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: TextStyle(color: _camel, fontSize: 31 * u, height: 0.88, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                Text('ساعة · شنطة · نظارة · محفظة', style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11 * u, fontWeight: FontWeight.w800)),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      _circle(u, _camel.withOpacity(0.13), 245),
                      FractionallySizedBox(widthFactor: 0.84, heightFactor: 0.86, child: _imageCard(d, u, accent: _camel, radius: 28)),
                    ],
                  ),
                ),
                SizedBox(height: 8 * u),
                _title(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _chips(d, u, accent: _camel, dark: true),
                SizedBox(height: 10 * u),
                _cta(u, accent: _camel, textColor: Colors.black),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _outdoorGear(BuildContext context, ShareProductData d) {
    return _MenFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF2B3A25), Color(0xFF5E4B2D), Color(0xFF17120B)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _MapLinesPainter(color: _camel.withOpacity(0.20)))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _camel, fg: Colors.white),
                SizedBox(height: 12 * u),
                Row(
                  children: <Widget>[
                    Icon(Icons.terrain_rounded, color: _camel, size: 42 * u),
                    SizedBox(width: 8 * u),
                    Expanded(child: Text('OUTDOOR\nGEAR', textDirection: TextDirection.ltr, style: TextStyle(color: _camel, fontSize: 31 * u, height: 0.88, fontWeight: FontWeight.w900))),
                  ],
                ),
                SizedBox(height: 10 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 56, child: _imageCard(d, u, accent: _camel, radius: 24)),
                      SizedBox(width: 12 * u),
                      Expanded(
                        flex: 44,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 15 * u, height: 1.13, fontWeight: FontWeight.w900)),
                            SizedBox(height: 10 * u),
                            Expanded(child: _darkDetails(d, u, accent: _camel)),
                            SizedBox(height: 8 * u),
                            _priceBox(d, u, accent: _camel, textColor: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: _camel, textColor: Colors.black),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _youthHype(BuildContext context, ShareProductData d) {
    return _MenFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF27133E), Color(0xFF101010), Color(0xFF050505)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 14 * u, left: 14 * u, child: _dotGrid(u, _red)),
            Positioned(bottom: 70 * u, right: -35 * u, child: _circle(u, _red.withOpacity(0.14), 180)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _red, fg: Colors.white),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 58,
                        child: Transform.rotate(angle: -0.04, child: _imageCard(d, u, accent: _red, radius: 26)),
                      ),
                      SizedBox(width: 12 * u),
                      Expanded(
                        flex: 42,
                        child: Transform.rotate(
                          angle: 0.035,
                          child: Container(
                            padding: EdgeInsets.all(11 * u),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(24 * u),
                              border: Border.all(color: _red.withOpacity(0.45)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text('YOUTH\nHYPE', textDirection: TextDirection.ltr, style: TextStyle(color: _red, fontSize: 31 * u, height: 0.88, fontWeight: FontWeight.w900)),
                                SizedBox(height: 8 * u),
                                Text('ستايل مختلف للشباب', style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 10.5 * u, fontWeight: FontWeight.w800)),
                                SizedBox(height: 10 * u),
                                Expanded(child: _darkDetails(d, u, accent: _red)),
                                SizedBox(height: 8 * u),
                                _priceBox(d, u, accent: _red, textColor: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: _red, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _photoFirst(BuildContext context, ShareProductData d) {
    return _MenFrame(
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
                    colors: <Color>[Colors.black.withOpacity(0.12), Colors.black.withOpacity(0.20), Colors.black.withOpacity(0.84)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14 * u),
              child: Column(
                children: <Widget>[
                  _brandRow(u, d, accent: _denim, fg: Colors.white),
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
                        Text('PHOTO FIRST', textDirection: TextDirection.ltr, style: TextStyle(color: _denim, fontSize: 14 * u, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        SizedBox(height: 4 * u),
                        Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 21 * u, height: 1.05, fontWeight: FontWeight.w900)),
                        SizedBox(height: 8 * u),
                        _chips(d, u, accent: _denim, dark: true),
                        SizedBox(height: 10 * u),
                        Row(
                          children: <Widget>[
                            Expanded(child: _priceBox(d, u, accent: _denim, textColor: Colors.white)),
                            SizedBox(width: 8 * u),
                            SizedBox(width: 118 * u, child: _cta(u, accent: _denim, textColor: Colors.white, compact: true)),
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

  static Widget _imageCard(ShareProductData d, double u, {required Color accent, double radius = 22}) {
    return Container(
      padding: EdgeInsets.all(6 * u),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(radius * u),
        border: Border.all(color: accent.withOpacity(0.40), width: 1.2),
        boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.18), blurRadius: 24 * u, spreadRadius: 1)],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular((radius - 4) * u), child: shareNetworkImage(d.imageUrl)),
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
          if (shareHas(d.usage)) _detailLine(Icons.timelapse_rounded, 'الاستخدام', d.usage, u, accent, dark: true),
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
        if (shareHas(d.usage)) _detailLine(Icons.timelapse_rounded, 'الاستخدام', d.usage, u, accent),
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
              style: TextStyle(color: dark ? Colors.white : _ink, fontSize: 9.8 * u, fontWeight: FontWeight.w900),
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
        if (shareHas(d.usage)) _chip(d.usage, u, bg: dark ? Colors.white.withOpacity(0.10) : Colors.white, fg: accent, border: accent.withOpacity(0.20), icon: Icons.timelapse_rounded),
        if (shareHas(sharePriceText(d))) _chip(sharePriceText(d), u, bg: accent, fg: Colors.white, icon: Icons.local_offer_rounded),
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

  static Widget _title(ShareProductData d, double u, {required Color color}) {
    return Text(
      d.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontSize: 16.5 * u, fontWeight: FontWeight.w900, height: 1.15),
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
            Icon(Icons.checkroom_rounded, color: textColor, size: 17 * u),
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
          constraints: BoxConstraints(maxWidth: 122 * u),
          padding: EdgeInsets.symmetric(horizontal: 9 * u, vertical: 5 * u),
          decoration: BoxDecoration(
            color: light ? Colors.white : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withOpacity(0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.man_rounded, color: accent, size: 13 * u),
              SizedBox(width: 4 * u),
              Flexible(child: Text(_categoryText(d), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: light ? _ink : Colors.white, fontSize: 9.2 * u, fontWeight: FontWeight.w900))),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _circle(double u, Color color, double size) {
    return Container(width: size * u, height: size * u, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
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
    return 'رجالي';
  }

  static String _price(ShareProductData d) {
    final String txt = sharePriceText(d);
    return shareHas(txt) ? txt : 'السعر عند التواصل';
  }
}

class _MenFrame extends StatelessWidget {
  const _MenFrame({
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

class _DiagonalFabricPainter extends CustomPainter {
  const _DiagonalFabricPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.2;

    for (double y = -size.height; y < size.height * 2; y += 15) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width * 0.42), p);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalFabricPainter oldDelegate) => oldDelegate.color != color;
}

class _SpeedPainter extends CustomPainter {
  const _SpeedPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 14; i++) {
      final double y = size.height * (0.12 + i * 0.062);
      final double x = i.isEven ? size.width * 0.02 : size.width * 0.22;
      canvas.drawLine(Offset(x, y), Offset(x + size.width * 0.40, y - size.height * 0.055), p);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedPainter oldDelegate) => oldDelegate.color != color;
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 0.9;

    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.color != color;
}

class _MapLinesPainter extends CustomPainter {
  const _MapLinesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.4
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
  bool shouldRepaint(covariant _MapLinesPainter oldDelegate) => oldDelegate.color != color;
}
