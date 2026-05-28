import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class ModestWearShareThemes {
  const ModestWearShareThemes._();

  static const Color _ink = Color(0xFF2F2521);
  static const Color _cream = Color(0xFFF8F1E8);
  static const Color _sand = Color(0xFFE8DCC8);
  static const Color _taupe = Color(0xFF8A745E);
  static const Color _coffee = Color(0xFF5B3F32);
  static const Color _rose = Color(0xFFC47A83);
  static const Color _sage = Color(0xFF7E9A82);
  static const Color _olive = Color(0xFF637257);
  static const Color _navy = Color(0xFF122033);
  static const Color _gold = Color(0xFFD8A84E);
  static const Color _plum = Color(0xFF4B2E4D);

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
    ShareThemeDefinition(
      id: 'modest_minimal_elegance',
      label: 'أناقة هادئة',
      subtitle: 'بساطة راقية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.modestWear],
      gradient: const <Color>[Color(0xFFE8DCC8), Color(0xFF8A745E)],
      priority: 10,
      builder: _minimalElegance,
    ),
    ShareThemeDefinition(
      id: 'modest_boutique_window',
      label: 'Boutique Window',
      subtitle: 'واجهة بوتيك',
      groups: const <ShareThemeGroup>[ShareThemeGroup.modestWear],
      gradient: const <Color>[Color(0xFFF8F1E8), Color(0xFFC47A83)],
      priority: 20,
      builder: _boutiqueWindow,
    ),
    ShareThemeDefinition(
      id: 'modest_linen_neutral',
      label: 'Linen Neutral',
      subtitle: 'كتان ودرجات طبيعية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.modestWear],
      gradient: const <Color>[Color(0xFFF7F1E6), Color(0xFFB59A7A)],
      priority: 30,
      builder: _linenNeutral,
    ),
    ShareThemeDefinition(
      id: 'modest_luxury_evening',
      label: 'Luxury Evening',
      subtitle: 'سهرة راقية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.modestWear],
      gradient: const <Color>[Color(0xFF122033), Color(0xFFD8A84E)],
      priority: 40,
      builder: _luxuryEvening,
    ),

    ShareThemeDefinition(
      id: 'modest_editorial_split',
      label: 'Editorial Split',
      subtitle: 'ستايل مجلة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.modestWear],
      gradient: const <Color>[Color(0xFF2F2521), Color(0xFFF8F1E8)],
      priority: 60,
      builder: _editorialSplit,
    ),
    ShareThemeDefinition(
      id: 'modest_soft_pink',
      label: 'Soft Pink',
      subtitle: 'وردي أنثوي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.modestWear],
      gradient: const <Color>[Color(0xFFFFF0F3), Color(0xFFC47A83)],
      priority: 70,
      builder: _softPink,
    ),
    ShareThemeDefinition(
      id: 'modest_accessory_focus',
      label: 'Accessory Focus',
      subtitle: 'للشنط والإكسسوارات',
      groups: const <ShareThemeGroup>[ShareThemeGroup.modestWear],
      gradient: const <Color>[Color(0xFFF4EFE7), Color(0xFF5B3F32)],
      priority: 80,
      builder: _accessoryFocus,
    ),
    ShareThemeDefinition(
      id: 'modest_premium_card',
      label: 'Premium Card',
      subtitle: 'كارت فاخر',
      groups: const <ShareThemeGroup>[ShareThemeGroup.modestWear],
      gradient: const <Color>[Color(0xFF4B2E4D), Color(0xFFC47A83)],
      priority: 90,
      builder: _premiumCard,
    ),
    ShareThemeDefinition(
      id: 'modest_clean_market',
      label: 'Clean Market',
      subtitle: 'واضح للبيع والشير',
      groups: const <ShareThemeGroup>[ShareThemeGroup.modestWear],
      gradient: const <Color>[Color(0xFFFFFFFF), Color(0xFFE8DCC8)],
      priority: 100,
      builder: _cleanMarket,
    ),
  ];

  static Widget _minimalElegance(BuildContext context, ShareProductData d) {
    return _ModestFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFF8F1E8), Color(0xFFE8DCC8), Color(0xFFF8F1E8)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 24 * u, right: 10 * u, child: Icon(Icons.spa_rounded, size: 62 * u, color: _taupe.withOpacity(0.10))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _taupe, fg: _ink, light: true),
                SizedBox(height: 14 * u),
                Text('Minimal\nModest', textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: TextStyle(color: _taupe, fontSize: 31 * u, height: 0.86, fontWeight: FontWeight.w900, letterSpacing: 0.4)),
                SizedBox(height: 7 * u),
                Text('أناقة هادئة لكل يوم', style: TextStyle(color: _coffee.withOpacity(0.70), fontSize: 12 * u, fontWeight: FontWeight.w800)),
                SizedBox(height: 12 * u),
                Expanded(child: _photoCard(d, u, radius: 28, shadow: _taupe.withOpacity(0.20))),
                SizedBox(height: 10 * u),
                _centerTitle(d, u, color: _ink),
                SizedBox(height: 8 * u),
                _softChips(d, u, accent: _taupe),
                SizedBox(height: 10 * u),
                _footerLine(u, color: _taupe, text: 'MODEST STYLE · SMART CHOICE'),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _boutiqueWindow(BuildContext context, ShareProductData d) {
    return _ModestFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFFFF9F3), Color(0xFFFFE8EC), Color(0xFFF8F1E8)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 70 * u, left: -25 * u, child: _circle(u, _rose.withOpacity(0.13), 150)),
            Positioned(bottom: 90 * u, right: -30 * u, child: _circle(u, _taupe.withOpacity(0.12), 150)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _rose, fg: _ink, light: true),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 56,
                        child: Container(
                          padding: EdgeInsets.all(9 * u),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(52 * u),
                              topRight: Radius.circular(52 * u),
                              bottomLeft: Radius.circular(22 * u),
                              bottomRight: Radius.circular(22 * u),
                            ),
                            boxShadow: <BoxShadow>[BoxShadow(color: _rose.withOpacity(0.18), blurRadius: 22 * u, offset: Offset(0, 10 * u))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(44 * u),
                              topRight: Radius.circular(44 * u),
                              bottomLeft: Radius.circular(16 * u),
                              bottomRight: Radius.circular(16 * u),
                            ),
                            child: shareNetworkImage(d.imageUrl),
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * u),
                      Expanded(
                        flex: 44,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text('Boutique\nFind', textDirection: TextDirection.ltr, style: TextStyle(color: _ink, fontSize: 29 * u, height: 0.88, fontWeight: FontWeight.w900)),
                            SizedBox(height: 7 * u),
                            Text('قطعة شيك\nجاهزة لصاحبتها الجديدة', style: TextStyle(color: _rose, fontSize: 11.5 * u, height: 1.25, fontWeight: FontWeight.w900)),
                            SizedBox(height: 10 * u),
                            Expanded(child: _lightDetails(d, u, accent: _rose)),
                            SizedBox(height: 8 * u),
                            _pricePlain(d, u, accent: _rose),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: _rose, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _linenNeutral(BuildContext context, ShareProductData d) {
    return _ModestFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFF7F1E6), Color(0xFFE7D4BB)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _FabricPatternPainter(color: _coffee.withOpacity(0.08)))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _brandRow(u, d, accent: _coffee, fg: _ink, light: true),
                SizedBox(height: 12 * u),
                Container(
                  padding: EdgeInsets.all(12 * u),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.62),
                    borderRadius: BorderRadius.circular(28 * u),
                    border: Border.all(color: Colors.white.withOpacity(0.70)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text('Linen\nNeutral', textDirection: TextDirection.ltr, style: TextStyle(color: _coffee, fontSize: 29 * u, height: 0.9, fontWeight: FontWeight.w900))),
                      Icon(Icons.checkroom_rounded, color: _taupe, size: 38 * u),
                    ],
                  ),
                ),
                SizedBox(height: 12 * u),
                Expanded(child: _photoCard(d, u, radius: 18, shadow: _coffee.withOpacity(0.16))),
                SizedBox(height: 10 * u),
                _centerTitle(d, u, color: _ink),
                SizedBox(height: 8 * u),
                _softChips(d, u, accent: _coffee),
                SizedBox(height: 10 * u),
                _cta(u, accent: _coffee, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _luxuryEvening(BuildContext context, ShareProductData d) {
    return _ModestFrame(
      background: const RadialGradient(
        center: Alignment.topRight,
        radius: 1.2,
        colors: <Color>[Color(0xFF263A5E), Color(0xFF122033), Color(0xFF05070C)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 20 * u, left: 18 * u, child: _sparkle(u, _gold)),
            Positioned(bottom: 96 * u, right: 14 * u, child: _sparkle(u, _gold.withOpacity(0.75))),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _gold, fg: Colors.white),
                SizedBox(height: 12 * u),
                Text('Luxury Evening', textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: TextStyle(color: _gold, fontSize: 31 * u, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                Text('اختيار راقٍ للمناسبات', style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12 * u, fontWeight: FontWeight.w800)),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(7 * u),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30 * u),
                      border: Border.all(color: _gold.withOpacity(0.56), width: 1.2),
                      boxShadow: <BoxShadow>[BoxShadow(color: _gold.withOpacity(0.18), blurRadius: 28 * u)],
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(24 * u), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
                SizedBox(height: 10 * u),
                _centerTitle(d, u, color: Colors.white),
                SizedBox(height: 8 * u),
                _softChips(d, u, accent: _gold, dark: true),
                SizedBox(height: 10 * u),
                _cta(u, accent: _gold, textColor: _navy),
              ],
            ),
          ],
        );
      },
    );
  }


  static Widget _editorialSplit(BuildContext context, ShareProductData d) {
    return _ModestFrame(
      padding: EdgeInsets.zero,
      background: const LinearGradient(colors: <Color>[Color(0xFFF8F1E8), Color(0xFFFFFFFF)]),
      childBuilder: (BuildContext context, double u) {
        return Row(
          children: <Widget>[
            Expanded(
              flex: 40,
              child: Container(
                padding: EdgeInsets.all(16 * u),
                color: _ink,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _brandMini(u, fg: Colors.white, accent: _sand),
                    const Spacer(),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'MODEST EDIT',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(color: _sand, fontSize: 30 * u, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                    ),
                    const Spacer(),
                    _categoryPill(_categoryText(d), u, accent: _sand, light: false),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 60,
              child: Padding(
                padding: EdgeInsets.all(14 * u),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('ستايل راقي', style: TextStyle(color: _ink, fontSize: 28 * u, fontWeight: FontWeight.w900)),
                    SizedBox(height: 6 * u),
                    Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: _coffee.withOpacity(0.82), fontSize: 13 * u, fontWeight: FontWeight.w800)),
                    SizedBox(height: 10 * u),
                    Expanded(child: _photoCard(d, u, radius: 16, shadow: Colors.black.withOpacity(0.12))),
                    SizedBox(height: 10 * u),
                    _softChips(d, u, accent: _coffee),
                    SizedBox(height: 9 * u),
                    _pricePlain(d, u, accent: _coffee),
                    SizedBox(height: 10 * u),
                    _cta(u, accent: _ink, textColor: Colors.white, compact: true),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _softPink(BuildContext context, ShareProductData d) {
    return _ModestFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFF0F3), Color(0xFFFFE8EF), Color(0xFFFFFFFF)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 68 * u, right: -20 * u, child: _circle(u, _rose.withOpacity(0.16), 150)),
            Positioned(bottom: 100 * u, left: -30 * u, child: _circle(u, _ink.withOpacity(0.12), 140)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: _rose, fg: _ink, light: true),
                SizedBox(height: 13 * u),
                Text('Soft Pink', textDirection: TextDirection.ltr, style: TextStyle(color: _rose, fontSize: 32 * u, fontWeight: FontWeight.w900)),
                Text('ناعم · أنثوي · شيك', style: TextStyle(color: _ink.withOpacity(0.58), fontSize: 12 * u, fontWeight: FontWeight.w800)),
                SizedBox(height: 13 * u),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Transform.rotate(angle: -0.05, child: _backCard(u, _rose.withOpacity(0.18))),
                      Transform.rotate(angle: 0.035, child: _photoCard(d, u, radius: 30, shadow: _rose.withOpacity(0.18))),
                    ],
                  ),
                ),
                SizedBox(height: 8 * u),
                _centerTitle(d, u, color: _ink),
                SizedBox(height: 8 * u),
                _softChips(d, u, accent: _rose),
                SizedBox(height: 10 * u),
                _cta(u, accent: _rose, textColor: Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _accessoryFocus(BuildContext context, ShareProductData d) {
    return _ModestFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFF4EFE7), Color(0xFFE3D2C3)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          children: <Widget>[
            _brandRow(u, d, accent: _coffee, fg: _ink, light: true),
            SizedBox(height: 12 * u),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12 * u),
                decoration: BoxDecoration(
                  color: _coffee,
                  borderRadius: BorderRadius.circular(30 * u),
                  boxShadow: <BoxShadow>[BoxShadow(color: _coffee.withOpacity(0.18), blurRadius: 22 * u, offset: Offset(0, 10 * u))],
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.shopping_bag_rounded, color: _sand, size: 34 * u),
                        SizedBox(width: 8 * u),
                        Expanded(child: Text('Accessory\nFocus', textDirection: TextDirection.ltr, style: TextStyle(color: _sand, fontSize: 27 * u, height: 0.9, fontWeight: FontWeight.w900))),
                      ],
                    ),
                    SizedBox(height: 10 * u),
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(24 * u), child: shareNetworkImage(d.imageUrl))),
                    SizedBox(height: 10 * u),
                    Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 15 * u, fontWeight: FontWeight.w900, height: 1.16)),
                    SizedBox(height: 8 * u),
                    _softChips(d, u, accent: _sand, dark: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12 * u),
            _cta(u, accent: _coffee, textColor: Colors.white),
          ],
        );
      },
    );
  }

  static Widget _premiumCard(BuildContext context, ShareProductData d) {
    return _ModestFrame(
      background: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF4B2E4D), Color(0xFF7D486B), Color(0xFFC47A83)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Stack(
          children: <Widget>[
            Positioned(top: 50 * u, left: 10 * u, child: _dotGrid(u, Colors.white.withOpacity(0.22))),
            Positioned(bottom: 70 * u, right: -35 * u, child: _circle(u, Colors.white.withOpacity(0.12), 180)),
            Column(
              children: <Widget>[
                _brandRow(u, d, accent: Colors.white, fg: Colors.white),
                SizedBox(height: 12 * u),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12 * u),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(32 * u),
                      border: Border.all(color: Colors.white.withOpacity(0.28)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 52,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text('Premium\nPiece', textDirection: TextDirection.ltr, style: TextStyle(color: Colors.white, fontSize: 29 * u, height: 0.9, fontWeight: FontWeight.w900)),
                              SizedBox(height: 8 * u),
                              Text('قطعة مميزة تستاهل تتشاف', style: TextStyle(color: Colors.white.withOpacity(0.76), fontSize: 11.5 * u, fontWeight: FontWeight.w800)),
                              SizedBox(height: 10 * u),
                              Expanded(child: _glassDetails(d, u)),
                              SizedBox(height: 8 * u),
                              _pricePlain(d, u, accent: Colors.white),
                            ],
                          ),
                        ),
                        SizedBox(width: 12 * u),
                        Expanded(flex: 48, child: _photoCard(d, u, radius: 28, shadow: Colors.black.withOpacity(0.22))),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12 * u),
                _cta(u, accent: Colors.white, textColor: _plum),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _cleanMarket(BuildContext context, ShareProductData d) {
    return _ModestFrame(
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF7F1E6)],
      ),
      childBuilder: (BuildContext context, double u) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _brandRow(u, d, accent: _taupe, fg: _ink, light: true),
            SizedBox(height: 14 * u),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12 * u),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28 * u),
                  border: Border.all(color: const Color(0xFFE9DFD3)),
                  boxShadow: <BoxShadow>[BoxShadow(color: _taupe.withOpacity(0.12), blurRadius: 22 * u, offset: Offset(0, 10 * u))],
                ),
                child: Column(
                  children: <Widget>[
                    Text('شارك ستايلك', style: TextStyle(color: _ink, fontSize: 26 * u, fontWeight: FontWeight.w900)),
                    Text('صورة واضحة + تفاصيل مختصرة', style: TextStyle(color: _taupe, fontSize: 11.5 * u, fontWeight: FontWeight.w800)),
                    SizedBox(height: 10 * u),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(flex: 56, child: ClipRRect(borderRadius: BorderRadius.circular(22 * u), child: shareNetworkImage(d.imageUrl))),
                          SizedBox(width: 10 * u),
                          Expanded(
                            flex: 44,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: _ink, fontSize: 14.5 * u, fontWeight: FontWeight.w900, height: 1.14)),
                                SizedBox(height: 8 * u),
                                Expanded(child: _lightDetails(d, u, accent: _taupe, compact: true)),
                                _pricePlain(d, u, accent: _taupe),
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
            _cta(u, accent: _taupe, textColor: Colors.white),
            SizedBox(height: 8 * u),
            _footerLine(u, color: _taupe, text: 'MODEST WEAR · ACCESSORIES · SMART SWAP'),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular((radius - 7) * u),
        child: shareNetworkImage(d.imageUrl),
      ),
    );
  }

  static Widget _centerTitle(ShareProductData d, double u, {required Color color}) {
    return Text(
      d.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontSize: 16.5 * u, fontWeight: FontWeight.w900, height: 1.15),
    );
  }

  static Widget _softChips(ShareProductData d, double u, {required Color accent, bool dark = false}) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6 * u,
      runSpacing: 6 * u,
      children: <Widget>[
        if (shareHas(d.condition)) _chip(d.condition, u, bg: dark ? Colors.white.withOpacity(0.12) : Colors.white, fg: dark ? Colors.white : accent, border: accent.withOpacity(0.22), icon: Icons.verified_rounded),
        if (shareHas(d.usage)) _chip(d.usage, u, bg: dark ? Colors.white.withOpacity(0.12) : Colors.white, fg: dark ? Colors.white : accent, border: accent.withOpacity(0.22), icon: Icons.timelapse_rounded),
        if (shareHas(sharePriceText(d))) _chip(sharePriceText(d), u, bg: accent, fg: dark ? _ink : Colors.white, icon: Icons.sell_rounded),
        if (shareHas(d.location)) _chip(shareShortLocation(d.location), u, bg: dark ? Colors.white.withOpacity(0.12) : Colors.white, fg: dark ? Colors.white : accent, border: accent.withOpacity(0.22), icon: Icons.location_on_rounded),
      ],
    );
  }

  static Widget _lightDetails(ShareProductData d, double u, {required Color accent, bool compact = false}) {
    final List<_ModestInfo> rows = <_ModestInfo>[
      if (shareHas(d.condition)) _ModestInfo(Icons.verified_rounded, 'الحالة', d.condition),
      if (shareHas(d.usage)) _ModestInfo(Icons.timelapse_rounded, 'الاستخدام', d.usage),
      if (shareHas(d.location)) _ModestInfo(Icons.location_on_rounded, 'الموقع', shareShortLocation(d.location)),
    ];

    return Column(
      children: <Widget>[
        for (final _ModestInfo row in rows)
          Container(
            margin: EdgeInsets.only(bottom: 7 * u),
            padding: EdgeInsets.symmetric(horizontal: 8 * u, vertical: compact ? 6 * u : 8 * u),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.90),
              borderRadius: BorderRadius.circular(13 * u),
              border: Border.all(color: accent.withOpacity(0.15)),
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

  static Widget _glassDetails(ShareProductData d, double u) {
    final List<_ModestInfo> rows = <_ModestInfo>[
      _ModestInfo(Icons.checkroom_rounded, 'المنتج', d.title),
      if (shareHas(d.condition)) _ModestInfo(Icons.verified_rounded, 'الحالة', d.condition),
      if (shareHas(d.usage)) _ModestInfo(Icons.timelapse_rounded, 'الاستخدام', d.usage),
      if (shareHas(d.location)) _ModestInfo(Icons.location_on_rounded, 'الموقع', shareShortLocation(d.location)),
    ];

    return Column(
      children: <Widget>[
        for (final _ModestInfo row in rows.take(4))
          Container(
            margin: EdgeInsets.only(bottom: 7 * u),
            padding: EdgeInsets.all(8 * u),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(13 * u), border: Border.all(color: Colors.white.withOpacity(0.18))),
            child: Row(
              children: <Widget>[
                Icon(row.icon, color: Colors.white, size: 14 * u),
                SizedBox(width: 5 * u),
                Expanded(child: Text(row.value, maxLines: row.label == 'المنتج' ? 2 : 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 9.8 * u, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
        const Spacer(),
      ],
    );
  }

  static Widget _pricePlain(ShareProductData d, double u, {required Color accent}) {
    final String txt = _price(d);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(txt, maxLines: 1, style: TextStyle(color: accent, fontSize: 25 * u, fontWeight: FontWeight.w900)),
    );
  }

  static Widget _cta(double u, {required Color accent, required Color textColor, bool compact = false}) {
    return Container(
      height: compact ? 37 * u : 42 * u,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(compact ? 14 * u : 18 * u),
        boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.22), blurRadius: 16 * u, offset: Offset(0, 7 * u))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.ios_share_rounded, color: textColor, size: 17 * u),
          SizedBox(width: 8 * u),
          Text('شارك بطاقة المنتج', style: TextStyle(color: textColor, fontSize: compact ? 14.5 * u : 17 * u, fontWeight: FontWeight.w900)),
          SizedBox(width: 8 * u),
          Icon(Icons.favorite_rounded, color: textColor, size: 16 * u),
        ],
      ),
    );
  }

  static Widget _chip(String text, double u, {required Color bg, required Color fg, Color? border, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * u, vertical: 5 * u),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999), border: border == null ? null : Border.all(color: border)),
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

  static Widget _brandRow(double u, ShareProductData d, {required Color accent, required Color fg, bool light = false}) {
    return Row(
      textDirection: TextDirection.ltr,
      children: <Widget>[
        _brandMini(u, fg: fg, accent: accent, light: light),
        const Spacer(),
        _categoryPill(_categoryText(d), u, accent: accent, light: light),
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
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(11 * u)),
          child: Icon(Icons.swap_horiz_rounded, color: light ? Colors.white : _ink, size: 18 * u),
        ),
        SizedBox(width: 7 * u),
        Text(' TAAPDEEL', textDirection: TextDirection.rtl, style: TextStyle(color: fg, fontSize: 14 * u, fontWeight: FontWeight.w900)),
      ],
    );
  }

  static Widget _categoryPill(String text, double u, {required Color accent, required bool light}) {
    return Container(
      constraints: BoxConstraints(maxWidth: 118 * u),
      padding: EdgeInsets.symmetric(horizontal: 9 * u, vertical: 5 * u),
      decoration: BoxDecoration(
        color: light ? Colors.white : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.checkroom_rounded, color: accent, size: 13 * u),
          SizedBox(width: 4 * u),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: light ? _ink : Colors.white, fontSize: 9.2 * u, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _footerLine(double u, {required Color color, required String text}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: color.withOpacity(0.82), fontSize: 8.8 * u, fontWeight: FontWeight.w900, letterSpacing: 0.8),
    );
  }

  static Widget _circle(double u, Color color, double size) {
    return Container(width: size * u, height: size * u, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  static Widget _sparkle(double u, Color color) {
    return Column(
      children: <Widget>[
        Icon(Icons.auto_awesome_rounded, color: color, size: 25 * u),
        SizedBox(height: 9 * u),
        Icon(Icons.star_rounded, color: color.withOpacity(0.70), size: 13 * u),
      ],
    );
  }

  static Widget _leafHeader(double u, Color color) {
    return Container(
      height: 86 * u,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Icon(Icons.spa_rounded, color: color.withOpacity(0.65), size: 38 * u),
      ),
    );
  }

  static Widget _backCard(double u, Color color) {
    return Container(
      margin: EdgeInsets.all(20 * u),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(34 * u)),
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
              (_) => Container(width: 2.2 * u, height: 2.2 * u, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ),
      ),
    );
  }

  static String _categoryText(ShareProductData d) {
    if (shareHas(d.subCategory)) return d.subCategory;
    if (shareHas(d.category)) return d.category;
    return 'أزياء محتشمة';
  }

  static String _price(ShareProductData d) {
    final String txt = sharePriceText(d);
    return shareHas(txt) ? txt : 'السعر عند التواصل';
  }
}

class _ModestFrame extends StatelessWidget {
  const _ModestFrame({
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

class _ModestInfo {
  const _ModestInfo(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _FabricPatternPainter extends CustomPainter {
  const _FabricPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double y = -size.height; y < size.height * 2; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width * 0.35), p);
    }

    final Paint p2 = Paint()
      ..color = color.withOpacity(0.55)
      ..strokeWidth = 0.8;

    for (double x = -size.width; x < size.width * 2; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height * 0.35, size.height), p2);
    }
  }

  @override
  bool shouldRepaint(covariant _FabricPatternPainter oldDelegate) => oldDelegate.color != color;
}
