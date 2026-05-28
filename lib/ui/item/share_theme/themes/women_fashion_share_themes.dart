import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class WomenFashionShareThemes {
  const WomenFashionShareThemes._();

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
    ShareThemeDefinition(
      id: 'fashion_closet_refresh',
      label: 'Closet Refresh',
      subtitle: 'ملابس وأحذية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFFF5A6C8), Color(0xFF8A4864)],
      priority: 10,
      builder: _closetRefresh,
    ),
    ShareThemeDefinition(
      id: 'fashion_luxe_reloved',
      label: 'Luxe Re-loved',
      subtitle: 'ستايل فاخر',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion, ShareThemeGroup.beauty],
      gradient: const <Color>[Color(0xFFC9A84C), Color(0xFF120A05)],
      priority: 20,
      builder: _luxeReloved,
    ),
    ShareThemeDefinition(
      id: 'fashion_dream_shot',
      label: 'Dream Shot',
      subtitle: 'كيوت وبناتي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion, ShareThemeGroup.beauty],
      gradient: const <Color>[Color(0xFF8B6FE8), Color(0xFFFFA4CB)],
      priority: 30,
      builder: _dreamShot,
    ),
    ShareThemeDefinition(
      id: 'fashion_journal_vibes',
      label: 'Journal Vibes',
      subtitle: 'ستايل سكراب بوك',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFFE8D8F4), Color(0xFFB98AD8)],
      priority: 40,
      builder: _journalVibes,
    ),
    ShareThemeDefinition(
      id: 'fashion_pastel_beats',
      label: 'Pastel Beats',
      subtitle: 'ستايل شبابي لطيف',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion, ShareThemeGroup.beauty],
      gradient: const <Color>[Color(0xFFFFA8DD), Color(0xFF8D6BFF)],
      priority: 50,
      builder: _pastelBeats,
    ),
    ShareThemeDefinition(
      id: 'fashion_glow_corner',
      label: 'Glow Corner',
      subtitle: 'جمال وروتين يومي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion, ShareThemeGroup.beauty],
      gradient: const <Color>[Color(0xFFFFC0AE), Color(0xFF8A4D3A)],
      priority: 60,
      builder: _glowCorner,
    ),
    ShareThemeDefinition(
      id: 'fashion_pink_dream',
      label: 'Pink Dream',
      subtitle: 'جمال وأنوثة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion, ShareThemeGroup.beauty],
      gradient: const <Color>[Color(0xFFFF7AA9), Color(0xFFFFD6E6)],
      priority: 80,
      builder: _pinkDream,
    ),
    ShareThemeDefinition(
      id: 'fashion_move_bold',
      label: 'Move Bold',
      subtitle: 'ستايل رياضي قوي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFF211229), Color(0xFF9C63E8)],
      priority: 90,
      builder: _moveBold,
    ),
    ShareThemeDefinition(
      id: 'fashion_nature_glow',
      label: 'Nature Glow',
      subtitle: 'إكسسوارات ناعمة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion, ShareThemeGroup.beauty],
      gradient: const <Color>[Color(0xFFF6ECD8), Color(0xFFB48DDD)],
      priority: 100,
      builder: _natureGlow,
    ),
    ShareThemeDefinition(
      id: 'fashion_level_up',
      label: 'Level Up',
      subtitle: 'ستايل جريء وحديث',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFF150031), Color(0xFFDA3BFF)],
      priority: 110,
      builder: _levelUp,
    ),
    ShareThemeDefinition(
      id: 'fashion_teen_trend',
      label: 'Teen Trend',
      subtitle: 'مودرن وشبابي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFFFF8DB5), Color(0xFFFBE8E8)],
      priority: 120,
      builder: _teenTrend,
    ),

    ShareThemeDefinition(
      id: 'fashion_minimal_modest',
      label: 'Minimal Modest',
      subtitle: 'محايد وراقي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFFEDE4D7), Color(0xFFA8927B)],
      priority: 150,
      builder: _minimalModest,
    ),

    ShareThemeDefinition(
      id: 'fashion_closet_pastel_combo',
      label: 'Pastel Combo',
      subtitle: 'طقم باستيل لطيف',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFFF59DB6), Color(0xFF8ABBE3)],
      priority: 220,
      builder: _closetPastelCombo,
    ),

    ShareThemeDefinition(
      id: 'fashion_floral_dress_elegance',
      label: 'Floral Elegance',
      subtitle: 'فستان بنعومة الورد',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFFFFC8D1), Color(0xFFB56B73)],
      priority: 240,
      builder: _floralDressElegance,
    ),
    ShareThemeDefinition(
      id: 'fashion_casual_denim_days',
      label: 'Casual Denim',
      subtitle: 'جينز يومي مريح',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFF2E5F95), Color(0xFFE7F2FA)],
      priority: 250,
      builder: _casualDenimDays,
    ),

    ShareThemeDefinition(
      id: 'fashion_sneaker_refresh',
      label: 'Sneaker Refresh',
      subtitle: 'أحذية شبابية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFF8F6DD6), Color(0xFF6FC6C4)],
      priority: 270,
      builder: _sneakerRefresh,
    ),

    ShareThemeDefinition(
      id: 'fashion_boho_rewear',
      label: 'Boho Rewear',
      subtitle: 'بوهو وستايل طبيعي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFF7B4E25), Color(0xFF63733F)],
      priority: 310,
      builder: _bohoRewear,
    ),
    ShareThemeDefinition(
      id: 'fashion_closet_refresh_notes',
      label: 'Closet Notes',
      subtitle: 'سكراب بوك للفاشون',
      groups: const <ShareThemeGroup>[ShareThemeGroup.womenFashion],
      gradient: const <Color>[Color(0xFFF6A5B7), Color(0xFF8FC3E8)],
      priority: 320,
      builder: _closetRefreshNotes,
    ),
  ];

  static Widget _closetRefresh(BuildContext context, ShareProductData d) => _fashionBase(
    d,
    bg: const Color(0xFFFFF2F6),
    accent: const Color(0xFFC85D85),
    title: 'Closet Refresh',
    dark: const Color(0xFF4A2432),
  );

  static Widget _luxeReloved(BuildContext context, ShareProductData d) => _fashionBase(
    d,
    bg: const Color(0xFF100B08),
    accent: const Color(0xFFC9A84C),
    title: 'Luxe Re-loved',
    dark: const Color(0xFFEAD98A),
    inverse: true,
  );

  static Widget _dreamShot(BuildContext context, ShareProductData d) {
    const Color purple = Color(0xFF8A64D6);
    const Color pink = Color(0xFFFFA4C8);
    const Color cream = Color(0xFFFFF2F8);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF6F58C7), Color(0xFFF9A3C9), Color(0xFFFFF1FA)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _SparklePainter(color: Colors.white.withOpacity(0.55)))),
          Positioned(top: 18, right: 18, child: _moonIcon()),
          Positioned(bottom: 42, left: 18, child: _softCloud(width: 90)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              _bigTitle('DREAM', 'SHOT', purple, pink),
              const SizedBox(height: 4),
              const Text('Capture your magic ♡', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 14, 28, 8),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(28), boxShadow: <BoxShadow>[BoxShadow(color: purple.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(22), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              _centerProductTitle(d, purple),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _dreamMini('Cute', Icons.favorite_rounded, purple)),
                    const SizedBox(width: 8),
                    Expanded(child: _dreamMini('Ready', Icons.camera_alt_rounded, purple)),
                    const SizedBox(width: 8),
                    Expanded(child: _dreamMini(shareHas(d.condition) ? d.condition : 'Good', Icons.stars_rounded, purple)),
                  ],
                ),
              ),
              _ctaBar('احفظي اللحظة', purple, cream, icon: Icons.auto_awesome_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _journalVibes(BuildContext context, ShareProductData d) {
    const Color purple = Color(0xFF8E70BD);
    const Color pink = Color(0xFFE98AA3);
    const Color paper = Color(0xFFFFFBF1);
    const Color ink = Color(0xFF5A4A55);

    return Container(
      color: const Color(0xFFF3EAF6),
      child: CustomPaint(
        painter: _GridPaperPainter(lineColor: purple.withOpacity(0.10)),
        child: Stack(
          children: <Widget>[
            const Positioned(top: 24, left: 18, child: Text('good\nthings\ntake\ntime ♡', style: TextStyle(color: ink, fontSize: 10.5, fontWeight: FontWeight.w800, height: 1.35))),
            Positioned(top: 74, right: 14, child: _paperNote('واسعة\nومنظمة', purple)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 14),
                Text('JOURNAL', textAlign: TextAlign.center, style: TextStyle(color: purple.withOpacity(0.90), fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const Text('VIBES', textAlign: TextAlign.center, style: TextStyle(color: pink, fontSize: 31, fontWeight: FontWeight.w900, height: 0.95)),
                const Text('Cute · Organized · Ready', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 12, 30, 8),
                    child: Transform.rotate(
                      angle: -0.025,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: paper, borderRadius: BorderRadius.circular(22), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 9))]),
                        child: ClipRRect(borderRadius: BorderRadius.circular(16), child: shareNetworkImage(d.imageUrl)),
                      ),
                    ),
                  ),
                ),
                _centerProductTitle(d, ink),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _scrapChip('Pre-loved', Icons.favorite_rounded, purple),
                      _scrapChip(shareHas(d.condition) ? d.condition : 'Ready', Icons.verified_rounded, purple),
                      _scrapChip(shareHas(sharePriceText(d)) ? sharePriceText(d) : 'Smart', Icons.local_offer_rounded, purple),
                    ],
                  ),
                ),
                _ctaBar('اكتشفيها', purple, Colors.white, icon: Icons.favorite_rounded),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pastelBeats(BuildContext context, ShareProductData d) {
    const Color pink = Color(0xFFFF73B9);
    const Color purple = Color(0xFF8A63E8);
    const Color white = Color(0xFFFFF7FF);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFFA8D8), Color(0xFFB7A5FF), Color(0xFFFFE4F6)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _SparklePainter(color: Colors.white.withOpacity(0.42)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              _bigTitle('PASTEL', 'BEATS', pink, purple),
              const Text('Listen in style. ♡', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 16, 30, 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.82), borderRadius: BorderRadius.circular(999), boxShadow: <BoxShadow>[BoxShadow(color: purple.withOpacity(0.28), blurRadius: 28, offset: const Offset(0, 12))]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(28), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              _centerProductTitle(d, purple),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _roundIconText(Icons.bluetooth_rounded, 'Freedom', purple)),
                    Expanded(child: _roundIconText(Icons.battery_charging_full_rounded, 'All day', purple)),
                    Expanded(child: _roundIconText(Icons.favorite_rounded, 'Comfy', purple)),
                    Expanded(child: _roundIconText(Icons.mic_rounded, 'Clear', purple)),
                  ],
                ),
              ),
              _ctaBar('كوني مميزة', pink, white, icon: Icons.headphones_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _glowCorner(BuildContext context, ShareProductData d) {
    const Color peach = Color(0xFFFFC2A8);
    const Color brown = Color(0xFF6B3E2C);
    const Color soft = Color(0xFFFFECE2);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFFB06B50), Color(0xFFFFCDB8), Color(0xFFFFEFE6)]),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _GlowDotsPainter(color: Colors.white.withOpacity(0.20)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Text('GLOW\nCORNER', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFF0C7), fontSize: 34, fontWeight: FontWeight.w900, height: 0.90, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              const Text('Light up your routine.', textAlign: TextAlign.center, style: TextStyle(color: brown, fontSize: 12, fontWeight: FontWeight.w800)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 15, 26, 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(28), boxShadow: <BoxShadow>[BoxShadow(color: Colors.white.withOpacity(0.55), blurRadius: 26, spreadRadius: 2)]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(21), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              _centerProductTitle(d, brown),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _cleanFeature(Icons.lightbulb_outline_rounded, 'Better lighting', brown)),
                    Expanded(child: _cleanFeature(Icons.touch_app_rounded, 'Touch control', brown)),
                    Expanded(child: _cleanFeature(Icons.favorite_border_rounded, 'Everyday glow', brown)),
                  ],
                ),
              ),
              _ctaBar('شاهدي التفاصيل', brown, Colors.white, icon: Icons.auto_awesome_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _schoolMood(BuildContext context, ShareProductData d) {
    const Color mint = Color(0xFF8AC8A7);
    const Color deep = Color(0xFF557665);
    const Color paper = Color(0xFFFFFEF7);

    return Container(
      color: paper,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _SchoolDoodlePainter(color: deep.withOpacity(0.25)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              Text('SCHOOL\nMOOD', textAlign: TextAlign.center, style: TextStyle(color: mint.withOpacity(0.95), fontSize: 34, fontWeight: FontWeight.w900, height: 0.90)),
              const SizedBox(height: 7),
              const Text('Simple. Sweet. Smart.', textAlign: TextAlign.center, style: TextStyle(color: deep, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: ClipRRect(borderRadius: BorderRadius.circular(28), child: shareNetworkImage(d.imageUrl)),
                ),
              ),
              _centerProductTitle(d, deep),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  children: <Widget>[
                    _simpleRow(Icons.edit_rounded, 'منظمة وسهلة الاستخدام', deep),
                    const SizedBox(height: 7),
                    _simpleRow(Icons.verified_rounded, shareHas(d.condition) ? d.condition : 'بحالة ممتازة', deep),
                    const SizedBox(height: 7),
                    _simpleRow(Icons.favorite_rounded, 'اختيار عملي لكل يوم', deep),
                  ],
                ),
              ),
              _ctaBar('ابدئي يوم جديد', mint, Colors.white, icon: Icons.check_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _pinkDream(BuildContext context, ShareProductData d) {
    const Color pink = Color(0xFFE75E93);
    const Color rose = Color(0xFFFFC3D5);
    const Color deep = Color(0xFF8E3D62);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFFFF8FB7), Color(0xFFFFD8E7), Color(0xFFFFA3C8)]),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _GlowDotsPainter(color: Colors.white.withOpacity(0.38)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Text('PINK\nDREAM', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 0.92, letterSpacing: 1.0)),
              const SizedBox(height: 7),
              const Text('Soft scent, sweet mood.', textAlign: TextAlign.center, style: TextStyle(color: deep, fontSize: 12.5, fontWeight: FontWeight.w800)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 18, 30, 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.62), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white.withOpacity(0.8), width: 2)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(24), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              _centerProductTitle(d, deep),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _cleanFeature(Icons.local_florist_rounded, 'Soft', deep)),
                    Expanded(child: _cleanFeature(Icons.auto_awesome_rounded, 'Fresh', deep)),
                    Expanded(child: _cleanFeature(Icons.favorite_rounded, 'Loved', deep)),
                    Expanded(child: _cleanFeature(Icons.diamond_rounded, 'Elegant', deep)),
                  ],
                ),
              ),
              _ctaBar('Feel pretty', pink, Colors.white, icon: Icons.favorite_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _moveBold(BuildContext context, ShareProductData d) {
    const Color purple = Color(0xFF9B63EA);
    const Color black = Color(0xFF0B0810);
    const Color white = Color(0xFFF7F4FF);

    return Container(
      color: black,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _BrushStrokePainter(color: purple.withOpacity(0.35)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Text('MOVE', textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w900, height: 0.95), textDirection: TextDirection.ltr),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Text('BOLD', textAlign: TextAlign.left, style: TextStyle(color: purple.withOpacity(0.95), fontSize: 41, fontWeight: FontWeight.w900, height: 0.90), textDirection: TextDirection.ltr),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 4),
                child: Text('Active every day.', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800), textDirection: TextDirection.ltr),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(70, 8, 16, 8),
                  child: ClipRRect(borderRadius: BorderRadius.circular(24), child: shareNetworkImage(d.imageUrl)),
                ),
              ),
              _centerProductTitle(d, white),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _darkIconText(Icons.directions_run_rounded, 'Sporty', purple)),
                    Expanded(child: _darkIconText(Icons.water_drop_rounded, 'Reliable', purple)),
                    Expanded(child: _darkIconText(Icons.timer_rounded, 'Ready', purple)),
                  ],
                ),
              ),
              _ctaBar('Move bold', purple, Colors.white, icon: Icons.flash_on_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _natureGlow(BuildContext context, ShareProductData d) {
    const Color purple = Color(0xFF57306F);
    const Color lavender = Color(0xFFA98ED2);
    const Color gold = Color(0xFFD4A34F);
    const Color cream = Color(0xFFFFF6E9);

    return Container(
      color: cream,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _LeafPatternPainter(color: purple.withOpacity(0.18)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Text('NATURE\nGLOW', textAlign: TextAlign.center, style: TextStyle(color: purple, fontSize: 35, fontWeight: FontWeight.w900, height: 0.92, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              const Text('Tiny details, big charm.', textAlign: TextAlign.center, style: TextStyle(color: purple, fontSize: 12.5, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(34, 18, 34, 8),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: gold, width: 2), color: Colors.white, boxShadow: <BoxShadow>[BoxShadow(color: lavender.withOpacity(0.28), blurRadius: 26, offset: const Offset(0, 12))]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(26), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              _centerProductTitle(d, purple),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _cleanFeature(Icons.local_florist_rounded, 'Inspired', purple)),
                    Expanded(child: _cleanFeature(Icons.auto_awesome_rounded, 'Delicate', purple)),
                    Expanded(child: _cleanFeature(Icons.card_giftcard_rounded, 'Giftable', purple)),
                    Expanded(child: _cleanFeature(Icons.favorite_border_rounded, 'Loved', purple)),
                  ],
                ),
              ),
              _ctaBar('Shine naturally', lavender, Colors.white, icon: Icons.favorite_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _levelUp(BuildContext context, ShareProductData d) {
    const Color neon = Color(0xFFE13DFF);
    const Color blue = Color(0xFF29C7FF);
    const Color dark = Color(0xFF070318);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF08021B), Color(0xFF22104B), Color(0xFF08021B)]),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _NeonGridPainter(color: neon.withOpacity(0.20)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              const Text('LEVEL', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 0.95)),
              Text('UP', textAlign: TextAlign.center, style: TextStyle(color: neon, fontSize: 56, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 0.85, shadows: <Shadow>[Shadow(color: blue.withOpacity(0.70), blurRadius: 18)])),
              const Text('Play your way. ♡', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: dark, borderRadius: BorderRadius.circular(28), border: Border.all(color: blue.withOpacity(0.72), width: 2), boxShadow: <BoxShadow>[BoxShadow(color: neon.withOpacity(0.38), blurRadius: 30)]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(21), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              _centerProductTitle(d, Colors.white),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _neonInfo(Icons.speed_rounded, 'Fast', neon)),
                    Expanded(child: _neonInfo(Icons.verified_user_rounded, 'Win', blue)),
                    Expanded(child: _neonInfo(Icons.auto_awesome_rounded, 'You', neon)),
                  ],
                ),
              ),
              _ctaBar('SLAY THE GAME', neon, Colors.white, icon: Icons.sports_esports_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _teenTrend(BuildContext context, ShareProductData d) {
    const Color pink = Color(0xFFE93E80);
    const Color black = Color(0xFF111111);
    const Color cream = Color(0xFFFFF1EC);

    return Container(
      color: cream,
      child: Stack(
        children: <Widget>[
          Positioned(right: -20, top: 0, bottom: 0, child: Container(width: 90, color: const Color(0xFFFFC9DA))),
          Positioned.fill(child: CustomPaint(painter: _PaperTearPainter(color: Colors.white.withOpacity(0.55)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.only(left: 18),
                child: Text('TEEN\nTREND', textAlign: TextAlign.left, style: TextStyle(color: black, fontSize: 42, fontWeight: FontWeight.w900, height: 0.86), textDirection: TextDirection.ltr),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 6),
                child: Text('Fresh style every step. ♡', style: TextStyle(color: pink, fontSize: 14, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic), textDirection: TextDirection.ltr),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(34, 14, 34, 8),
                  child: Transform.rotate(
                    angle: -0.04,
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              _centerProductTitle(d, black),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _cleanFeature(Icons.favorite_border_rounded, 'Comfort', black)),
                    Expanded(child: _cleanFeature(Icons.checkroom_rounded, 'Trendy', black)),
                    Expanded(child: _cleanFeature(Icons.workspace_premium_rounded, 'For you', black)),
                  ],
                ),
              ),
              _ctaBar('Step into awesome', pink, Colors.white, icon: Icons.arrow_forward_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _minimalModest(BuildContext context, ShareProductData d) {
    const Color taupe = Color(0xFF7A6657);
    const Color beige = Color(0xFFE8DCCB);
    const Color cream = Color(0xFFFFFBF4);

    return Container(
      color: cream,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _MinimalLinesPainter(color: taupe.withOpacity(0.20)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Text('Minimal', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF4F433B), fontSize: 35, fontWeight: FontWeight.w400, height: 0.95)),
              const Text('Modest', textAlign: TextAlign.center, style: TextStyle(color: taupe, fontSize: 33, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic, height: 1.0)),
              const SizedBox(height: 4),
              const Text('Everyday hijabs, gently loved', textAlign: TextAlign.center, style: TextStyle(color: taupe, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: beige.withOpacity(0.55), borderRadius: BorderRadius.circular(28)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              _centerProductTitle(d, taupe),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _minimalFeature(Icons.favorite_border_rounded, 'Pre-Loved', taupe)),
                    Expanded(child: _minimalFeature(Icons.cloud_outlined, 'Soft Fabric', taupe)),
                    Expanded(child: _minimalFeature(Icons.verified_outlined, shareHas(d.condition) ? d.condition : 'Very Good', taupe)),
                    Expanded(child: _minimalFeature(Icons.layers_rounded, 'Simple', taupe)),
                  ],
                ),
              ),
              _ctaBar('Minimal choice', taupe, Colors.white, icon: Icons.spa_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _closetPastelCombo(BuildContext context, ShareProductData d) {
    const Color pink = Color(0xFFF59AB2);
    const Color blue = Color(0xFF73AED8);
    const Color ink = Color(0xFF4F5263);
    const Color cream = Color(0xFFFFFAF0);

    return Container(
      color: cream,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _GridPaperPainter(lineColor: blue.withOpacity(0.08)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 14),
              Text('Closet', textAlign: TextAlign.center, style: TextStyle(color: pink, fontSize: 39, fontWeight: FontWeight.w900, shadows: <Shadow>[Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 5)])),
              Text('Refresh', textAlign: TextAlign.center, style: TextStyle(color: blue, fontSize: 34, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, height: 0.78, shadows: <Shadow>[Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 5)])),
              const SizedBox(height: 9),
              Container(margin: const EdgeInsets.symmetric(horizontal: 42), padding: const EdgeInsets.symmetric(vertical: 7), decoration: BoxDecoration(color: blue.withOpacity(0.22), borderRadius: BorderRadius.circular(999)), child: const Text('Fresh style, gently loved ♡', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 11.5, fontWeight: FontWeight.w800))),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: blue.withOpacity(0.35))),
                    child: ClipRRect(borderRadius: BorderRadius.circular(18), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              _centerProductTitle(d, ink),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _pastelSticker(Icons.checkroom_rounded, 'Pre-Loved', pink, ink)),
                    Expanded(child: _pastelSticker(Icons.favorite_rounded, 'Cute Match', blue, ink)),
                    Expanded(child: _pastelSticker(Icons.verified_rounded, shareHas(d.condition) ? d.condition : 'Ready', pink, ink)),
                  ],
                ),
              ),
              _ctaBar('Refresh your closet', blue, Colors.white, icon: Icons.favorite_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }


  static Widget _floralDressElegance(BuildContext context, ShareProductData d) {
    const Color rose = Color(0xFFB9636D);
    const Color blush = Color(0xFFFFF0EF);
    const Color ink = Color(0xFF653B3F);

    return Container(
      color: blush,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _FloralCornerPainter(color: rose.withOpacity(0.22)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Text('Pre-Loved', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 30, fontWeight: FontWeight.w500, height: 0.95)),
              const Text('Elegance ♡', textAlign: TextAlign.center, style: TextStyle(color: rose, fontSize: 34, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, height: 1.0)),
              const Text('Gracefully worn, ready for a new story', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 11.5, fontWeight: FontWeight.w700)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: rose.withOpacity(0.35))), child: ClipRRect(borderRadius: BorderRadius.circular(18), child: shareNetworkImage(d.imageUrl))),
                ),
              ),
              _centerProductTitle(d, ink),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  children: <Widget>[
                    _elegantLine(Icons.favorite_border_rounded, 'Pre-Loved', 'Cherished again', rose, ink),
                    _elegantLine(Icons.auto_awesome_rounded, 'Excellent Condition', shareHas(d.condition) ? d.condition : 'Well cared for', rose, ink),
                    _elegantLine(Icons.checkroom_rounded, shareHas(d.subCategory) ? d.subCategory : 'Ready to Wear', 'No fixes needed', rose, ink),
                  ],
                ),
              ),
              _ctaBar('Share your style', rose, Colors.white, icon: Icons.camera_alt_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _casualDenimDays(BuildContext context, ShareProductData d) {
    const Color denim = Color(0xFF2E5F95);
    const Color light = Color(0xFFEAF5FB);
    const Color ink = Color(0xFF14345A);

    return Container(
      color: light,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _WindowLightPainter(color: denim.withOpacity(0.07)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Padding(padding: EdgeInsets.only(left: 18), child: Text('Casual', textDirection: TextDirection.ltr, style: TextStyle(color: ink, fontSize: 34, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, height: 0.95))),
              const Padding(padding: EdgeInsets.only(left: 18), child: Text('DENIM\nDays', textDirection: TextDirection.ltr, style: TextStyle(color: denim, fontSize: 36, fontWeight: FontWeight.w900, height: 0.86))),
              const Padding(padding: EdgeInsets.only(left: 20, top: 4), child: Text('Easy style, loved before ♡', textDirection: TextDirection.ltr, style: TextStyle(color: ink, fontSize: 12.5, fontWeight: FontWeight.w800))),
              Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(116, 8, 20, 8), child: ClipRRect(borderRadius: BorderRadius.circular(24), child: shareNetworkImage(d.imageUrl)))),
              _centerProductTitle(d, ink),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Column(
                  children: <Widget>[
                    _brushRow(Icons.favorite_rounded, 'Pre-Loved', denim),
                    const SizedBox(height: 6),
                    _brushRow(Icons.verified_rounded, shareHas(d.condition) ? d.condition : 'Very Good Condition', denim),
                    const SizedBox(height: 6),
                    _brushRow(Icons.checkroom_rounded, shareHas(d.subCategory) ? d.subCategory : 'Daily Wear', denim),
                  ],
                ),
              ),
              _ctaBar('Ready again', denim, Colors.white, icon: Icons.checkroom_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }


  static Widget _sneakerRefresh(BuildContext context, ShareProductData d) {
    const Color purple = Color(0xFF8E6DD7);
    const Color teal = Color(0xFF5FB9B8);
    const Color pink = Color(0xFFE981AA);

    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _BrushStrokePainter(color: teal.withOpacity(0.18)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Padding(padding: EdgeInsets.only(left: 18), child: Text('Sneaker', textDirection: TextDirection.ltr, style: TextStyle(color: purple, fontSize: 39, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 0.90))),
              const Padding(padding: EdgeInsets.only(left: 22), child: Text('Refresh', textDirection: TextDirection.ltr, style: TextStyle(color: teal, fontSize: 36, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 0.90))),
              const Padding(padding: EdgeInsets.only(left: 22, top: 7), child: Text('Step into a second life', textDirection: TextDirection.ltr, style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w800))),
              Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(98, 12, 18, 8), child: ClipRRect(borderRadius: BorderRadius.circular(24), child: shareNetworkImage(d.imageUrl)))),
              _centerProductTitle(d, Colors.black87),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Row(children: <Widget>[
                  Expanded(child: _pastelSticker(Icons.favorite_rounded, 'Pre-Loved', purple, Colors.black87)),
                  Expanded(child: _pastelSticker(Icons.verified_rounded, shareHas(d.condition) ? d.condition : 'Good', teal, Colors.black87)),
                  Expanded(child: _pastelSticker(Icons.directions_walk_rounded, 'Walk Ready', pink, Colors.black87)),
                ]),
              ),
              _ctaBar('Sneaker refresh', teal, Colors.white, icon: Icons.directions_walk_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }


  static Widget _bohoRewear(BuildContext context, ShareProductData d) {
    const Color olive = Color(0xFF61713D);
    const Color brown = Color(0xFF7B4E25);
    const Color cream = Color(0xFFF4E6CE);

    return Container(
      color: cream,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _LeafPatternPainter(color: olive.withOpacity(0.28)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Padding(padding: EdgeInsets.only(left: 18), child: Text('Boho', textDirection: TextDirection.ltr, style: TextStyle(color: brown, fontSize: 42, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, height: 0.86))),
              const Padding(padding: EdgeInsets.only(left: 18), child: Text('Rewear', textDirection: TextDirection.ltr, style: TextStyle(color: olive, fontSize: 34, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, height: 0.95))),
              const Padding(padding: EdgeInsets.only(left: 20, top: 6), child: Text('Free spirit, second chance', textDirection: TextDirection.ltr, style: TextStyle(color: brown, fontSize: 13, fontWeight: FontWeight.w800))),
              Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(118, 10, 18, 8), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: olive, width: 2)), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl))))),
              _centerProductTitle(d, brown),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Column(children: <Widget>[
                  _sageLine(Icons.favorite_rounded, 'Pre-Loved', 'Second chance', olive, brown),
                  _sageLine(Icons.spa_rounded, 'Soft Fabric', shareHas(d.condition) ? d.condition : 'Good Condition', olive, brown),
                  _sageLine(Icons.eco_rounded, 'Better for planet', shareHas(sharePriceText(d)) ? sharePriceText(d) : 'Reuse. Rewear.', olive, brown),
                ]),
              ),
              _ctaBar('Better for the planet', olive, Colors.white, icon: Icons.eco_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _closetRefreshNotes(BuildContext context, ShareProductData d) {
    const Color pink = Color(0xFFE9859F);
    const Color yellow = Color(0xFFF4D88B);
    const Color mint = Color(0xFF96C9A6);
    const Color ink = Color(0xFF35323A);

    return Container(
      color: const Color(0xFFFFF3E7),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _GridPaperPainter(lineColor: pink.withOpacity(0.08)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 14),
              const Text('Closet Refresh', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 31, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)),
              Container(margin: const EdgeInsets.symmetric(horizontal: 44), padding: const EdgeInsets.symmetric(vertical: 7), decoration: BoxDecoration(color: pink.withOpacity(0.18), borderRadius: BorderRadius.circular(999)), child: const Text('Fresh style, gently loved ♥', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 11.5, fontWeight: FontWeight.w800))),
              Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(24, 14, 24, 8), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: ClipRRect(borderRadius: BorderRadius.circular(18), child: shareNetworkImage(d.imageUrl))))),
              _centerProductTitle(d, ink),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Row(children: <Widget>[
                  Expanded(child: _pastelSticker(Icons.favorite_rounded, 'Pre-Loved', pink, ink)),
                  Expanded(child: _pastelSticker(Icons.checkroom_rounded, 'Cute Match', yellow, ink)),
                  Expanded(child: _pastelSticker(Icons.verified_rounded, shareHas(d.condition) ? d.condition : 'Very Good', mint, ink)),
                ]),
              ),
              _ctaBar('Grab it before it’s gone!', pink, Colors.white, icon: Icons.favorite_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }


  static Widget _pastelSticker(IconData icon, String label, Color accent, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.20),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accent.withOpacity(0.32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(radius: 14, backgroundColor: accent.withOpacity(0.75), child: Icon(icon, color: Colors.white, size: 14)),
          const SizedBox(height: 5),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 9.5, fontWeight: FontWeight.w900, height: 1.10)),
        ],
      ),
    );
  }

  static Widget _fashionBase(
      ShareProductData d, {
        required Color bg,
        required Color accent,
        required String title,
        required Color dark,
        bool inverse = false,
      }) {
    final Color text = inverse ? const Color(0xFFF8EBC0) : dark;
    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: text, fontSize: 26, fontWeight: FontWeight.w900, height: 1.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Fresh style, gently loved',
              textAlign: TextAlign.center,
              style: TextStyle(color: text.withOpacity(0.55), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: inverse ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: accent.withOpacity(0.35)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: accent.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(16), child: shareNetworkImage(d.imageUrl)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: Text(
              d.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w900, height: 1.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 7,
              runSpacing: 7,
              children: <Widget>[
                if (shareHas(d.condition)) sharePill(text: d.condition, bg: inverse ? Colors.white.withOpacity(0.08) : Colors.white, fg: accent, icon: Icons.favorite_rounded),
                if (shareHas(d.usage)) sharePill(text: d.usage, bg: inverse ? Colors.white.withOpacity(0.08) : Colors.white, fg: accent, icon: Icons.replay_rounded),
                if (shareHas(sharePriceText(d))) sharePill(text: sharePriceText(d), bg: accent, fg: inverse ? Colors.black : Colors.white, icon: Icons.local_offer_rounded),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: shareBrandFooter(color: text.withOpacity(0.55), right: 'STYLE AGAIN · SMARTER VALUE'),
          ),
        ],
      ),
    );
  }

  static Widget _centerProductTitle(ShareProductData d, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        d.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 17.5, fontWeight: FontWeight.w900, height: 1.15),
      ),
    );
  }

  static Widget _bigTitle(String a, String b, Color c1, Color c2) {
    return Column(
      children: <Widget>[
        Text(a, textAlign: TextAlign.center, style: TextStyle(color: c1, fontSize: 36, fontWeight: FontWeight.w900, height: 0.92, shadows: <Shadow>[Shadow(color: Colors.white.withOpacity(0.95), blurRadius: 5)])),
        Text(b, textAlign: TextAlign.center, style: TextStyle(color: c2, fontSize: 38, fontWeight: FontWeight.w900, height: 0.88, shadows: <Shadow>[Shadow(color: Colors.white.withOpacity(0.95), blurRadius: 5)])),
      ],
    );
  }

  static Widget _ctaBar(String text, Color bg, Color fg, {IconData icon = Icons.arrow_forward_rounded}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[BoxShadow(color: bg.withOpacity(0.28), blurRadius: 15, offset: const Offset(0, 7))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: fg, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _dreamMini(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.78), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.12))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _scrapChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.86), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(0.20))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _roundIconText(IconData icon, String text, Color color) {
    return Column(
      children: <Widget>[
        CircleAvatar(radius: 17, backgroundColor: Colors.white.withOpacity(0.25), child: Icon(icon, color: Colors.white, size: 17)),
        const SizedBox(height: 5),
        Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
      ],
    );
  }

  static Widget _cleanFeature(IconData icon, String text, Color color) {
    return Column(
      children: <Widget>[
        Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.65), border: Border.all(color: color.withOpacity(0.14))), child: Icon(icon, color: color, size: 17)),
        const SizedBox(height: 5),
        Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 9.3, fontWeight: FontWeight.w800, height: 1.15)),
      ],
    );
  }

  static Widget _darkIconText(IconData icon, String text, Color color) {
    return Column(
      children: <Widget>[
        CircleAvatar(radius: 18, backgroundColor: Colors.white.withOpacity(0.08), child: Icon(icon, color: Colors.white, size: 18)),
        const SizedBox(height: 5),
        Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w900)),
      ],
    );
  }

  static Widget _neonInfo(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.35))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _brushRow(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.76), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: <Widget>[
          CircleAvatar(radius: 13, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 14)),
          const SizedBox(width: 9),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _elegantLine(IconData icon, String title, String text, Color accent, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.68), borderRadius: BorderRadius.circular(13), border: Border.all(color: accent.withOpacity(0.26))),
      child: Row(
        children: <Widget>[
          CircleAvatar(radius: 15, backgroundColor: accent.withOpacity(0.85), child: Icon(icon, color: Colors.white, size: 15)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w900)),
                Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color.withOpacity(0.68), fontSize: 9.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _minimalFeature(IconData icon, String label, Color color) {
    return Column(
      children: <Widget>[
        Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.56), border: Border.all(color: color.withOpacity(0.20))), child: Icon(icon, color: color, size: 17)),
        const SizedBox(height: 5),
        Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 9.0, fontWeight: FontWeight.w800, height: 1.10)),
      ],
    );
  }

  static Widget _sageLine(IconData icon, String title, String text, Color accent, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.58), borderRadius: BorderRadius.circular(14), border: Border.all(color: accent.withOpacity(0.20))),
      child: Row(
        children: <Widget>[
          CircleAvatar(radius: 15, backgroundColor: accent.withOpacity(0.82), child: Icon(icon, color: Colors.white, size: 15)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w900)),
                Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color.withOpacity(0.70), fontSize: 9.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  static Widget _simpleRow(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.76), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _paperNote(String text, Color color) {
    return Transform.rotate(
      angle: 0.04,
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, height: 1.25)),
      ),
    );
  }

  static Widget _moonIcon() {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(color: Color(0xFFFFE8A4), shape: BoxShape.circle),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(width: 34, height: 46, decoration: const BoxDecoration(color: Color(0xFF6F58C7), shape: BoxShape.circle)),
      ),
    );
  }

  static Widget _softCloud({required double width}) {
    return Container(
      width: width,
      height: 38,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.42), borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color;
    for (int i = 0; i < 58; i++) {
      final double x = ((i * 37) % size.width.toInt()).toDouble();
      final double y = ((i * 61) % size.height.toInt()).toDouble();
      final double r = 1.2 + (i % 3);
      canvas.drawCircle(Offset(x, y), r, p);
      if (i % 7 == 0) {
        canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), p..strokeWidth = 1);
        canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), p..strokeWidth = 1);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.color != color;
}

class _GridPaperPainter extends CustomPainter {
  const _GridPaperPainter({required this.lineColor});
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPaperPainter oldDelegate) => oldDelegate.lineColor != lineColor;
}

class _GlowDotsPainter extends CustomPainter {
  const _GlowDotsPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color;
    for (int i = 0; i < 35; i++) {
      final double x = ((i * 53) % size.width.toInt()).toDouble();
      final double y = ((i * 41) % size.height.toInt()).toDouble();
      canvas.drawCircle(Offset(x, y), 2 + (i % 4).toDouble(), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowDotsPainter oldDelegate) => oldDelegate.color != color;
}

class _SchoolDoodlePainter extends CustomPainter {
  const _SchoolDoodlePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(18, 18, 60, 50), const Radius.circular(12)), p);
    canvas.drawCircle(Offset(size.width - 46, 70), 22, p);
    canvas.drawLine(Offset(20, size.height - 60), Offset(size.width - 20, size.height - 60), p);
    for (double x = 28; x < size.width; x += 72) {
      canvas.drawCircle(Offset(x, size.height - 34), 3, p);
    }
  }

  @override
  bool shouldRepaint(covariant _SchoolDoodlePainter oldDelegate) => oldDelegate.color != color;
}

class _BrushStrokePainter extends CustomPainter {
  const _BrushStrokePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-20, size.height * 0.22), Offset(size.width * 0.9, size.height * 0.06), p);
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.80), Offset(size.width + 20, size.height * 0.62), p..strokeWidth = 28);
    canvas.drawLine(Offset(-20, size.height * 0.68), Offset(size.width * 0.65, size.height * 0.95), p..strokeWidth = 18);
  }

  @override
  bool shouldRepaint(covariant _BrushStrokePainter oldDelegate) => oldDelegate.color != color;
}

class _LeafPatternPainter extends CustomPainter {
  const _LeafPatternPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (double y = 40; y < size.height; y += 95) {
      canvas.drawLine(Offset(18, y), Offset(50, y - 30), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(30, y - 8), width: 18, height: 9), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(44, y - 22), width: 18, height: 9), p);
      canvas.drawLine(Offset(size.width - 18, y + 20), Offset(size.width - 50, y - 10), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 30, y + 8), width: 18, height: 9), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 45, y - 4), width: 18, height: 9), p);
    }
  }

  @override
  bool shouldRepaint(covariant _LeafPatternPainter oldDelegate) => oldDelegate.color != color;
}

class _NeonGridPainter extends CustomPainter {
  const _NeonGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x + 90, size.height), p);
    }
    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(Offset(((i * 47) % size.width.toInt()).toDouble(), ((i * 83) % size.height.toInt()).toDouble()), 2, p..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _NeonGridPainter oldDelegate) => oldDelegate.color != color;
}

class _PaperTearPainter extends CustomPainter {
  const _PaperTearPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.66, 0)
      ..lineTo(size.width * 0.56, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _PaperTearPainter oldDelegate) => oldDelegate.color != color;
}

class _UrbanTexturePainter extends CustomPainter {
  const _UrbanTexturePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (double y = 20; y < size.height; y += 64) {
      canvas.drawLine(Offset(0, y), Offset(size.width * 0.55, y - 20), p);
    }
    final Paint dot = Paint()..color = color.withOpacity(0.8);
    for (double x = 10; x < size.width; x += 16) {
      for (double y = 10; y < 110; y += 16) {
        canvas.drawCircle(Offset(x, y), 1.4, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _UrbanTexturePainter oldDelegate) => oldDelegate.color != color;
}

class _FloralCornerPainter extends CustomPainter {
  const _FloralCornerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), const Radius.circular(20)), p);
    for (int i = 0; i < 6; i++) {
      final double r = 12 + i * 4;
      canvas.drawCircle(Offset(size.width - 32, 32), r, p);
      canvas.drawCircle(Offset(32, size.height - 32), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _FloralCornerPainter oldDelegate) => oldDelegate.color != color;
}

class _MinimalLinesPainter extends CustomPainter {
  const _MinimalLinesPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(12, 12, size.width - 24, size.height - 24), p);
    for (double x = size.width - 70; x < size.width - 20; x += 12) {
      for (double y = 28; y < 86; y += 12) {
        canvas.drawCircle(Offset(x, y), 1.3, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MinimalLinesPainter oldDelegate) => oldDelegate.color != color;
}

class _WindowLightPainter extends CustomPainter {
  const _WindowLightPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color;
    for (double x = -80; x < size.width; x += 92) {
      final Path path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 58, 0)
        ..lineTo(x + 160, size.height)
        ..lineTo(x + 102, size.height)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _WindowLightPainter oldDelegate) => oldDelegate.color != color;
}

class _GoldFramePainter extends CustomPainter {
  const _GoldFramePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), p);
    canvas.drawLine(Offset(24, 44), Offset(68, 44), p);
    canvas.drawLine(Offset(size.width - 68, size.height - 44), Offset(size.width - 24, size.height - 44), p);
  }

  @override
  bool shouldRepaint(covariant _GoldFramePainter oldDelegate) => oldDelegate.color != color;
}

