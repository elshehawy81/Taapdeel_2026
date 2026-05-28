import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class GamesShareThemes {
  const GamesShareThemes._();

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
    ShareThemeDefinition(
      id: 'playstation_01_action_level_up',
      label: 'PS Level Up',
      subtitle: 'جاهز لمستوى جديد من اللعب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF061A46), Color(0xFF0088FF)],
      priority: 1,
      builder: _ps01ActionLevelUp,
    ),
    ShareThemeDefinition(
      id: 'playstation_02_glass_future',
      label: 'PS Future Glass',
      subtitle: 'مستقبل اللعب يبدأ من هنا',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF1615A6), Color(0xFF8B5CF6)],
      priority: 2,
      builder: _ps02GlassFuture,
    ),
    ShareThemeDefinition(
      id: 'playstation_03_luxury_collector',
      label: 'PS Collector Gold',
      subtitle: 'قطعة مميزة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF050505), Color(0xFFD4AF37)],
      priority: 3,
      builder: _ps03LuxuryCollector,
    ),

    ShareThemeDefinition(
      id: 'games_level_up_story',
      label: 'Level Up',
      subtitle: 'ستايل شبابي جذاب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF7C3AED), Color(0xFF06B6D4)],
      priority: 22,
      builder: _levelUpStory,
    ),
    ShareThemeDefinition(
      id: 'games_mom_clearing_magic',
      label: 'ترتيب ولطافة',
      subtitle: 'للأمهات وكراكيب اللعب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFFFFD6E7), Color(0xFFFFB5C9)],
      priority: 23,
      builder: _momClearingMagic,
    ),
    ShareThemeDefinition(
      id: 'games_gift_ready_card',
      label: 'Gift Ready',
      subtitle: 'هديّة ولعبة في نفس الوقت',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFFFFD166), Color(0xFFFF8C42)],
      priority: 24,
      builder: _giftReadyCard,
    ),
    ShareThemeDefinition(
      id: 'games_swap_poster_pro',
      label: 'Swap Poster',
      subtitle: 'بوستر قوي وسريع',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF0F172A), Color(0xFF334155)],
      priority: 25,
      builder: _swapPosterPro,
    ),
    ShareThemeDefinition(
      id: 'games_storybook_fun',
      label: 'حكاية لعبتي',
      subtitle: 'أسلوب قصصي دافئ',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFFA78BFA), Color(0xFFF9A8D4)],
      priority: 26,
      builder: _storybookFun,
    ),

    ShareThemeDefinition(
      id: 'games_teen_trend',
      label: 'Teen Trend',
      subtitle: 'ستايل مناسب لـ 12–16',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF111827), Color(0xFFEA580C)],
      priority: 28,
      builder: _teenTrend,
    ),
    ShareThemeDefinition(
      id: 'games_soft_girl_fun',
      label: 'Soft Fun',
      subtitle: 'ستايل لطيف للبنات',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFFFFC4E1), Color(0xFFC4B5FD)],
      priority: 29,
      builder: _softGirlFun,
    ),
    ShareThemeDefinition(
      id: 'games_comic_pop_blast',
      label: 'Comic Pop',
      subtitle: 'ستايل مرح ومتحرك',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFFFDE047), Color(0xFFF97316)],
      priority: 30,
      builder: _comicPopBlast,
    ),
    ShareThemeDefinition(
      id: 'games_family_play_invite',
      label: 'Family Play',
      subtitle: 'دعوة لعب جماعي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF34D399), Color(0xFF10B981)],
      priority: 31,
      builder: _familyPlayInvite,
    ),
    ShareThemeDefinition(
      id: 'games_vip_showcase',
      label: 'VIP Showcase',
      subtitle: 'عرض فاخر للعبة مميزة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF1E293B), Color(0xFFD4AF37)],
      priority: 32,
      builder: _vipShowcase,
    ),
    ShareThemeDefinition(
      id: 'games_fresh_start_board',
      label: 'Fresh Start',
      subtitle: 'بداية جديدة للعبة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF93C5FD), Color(0xFF14B8A6)],
      priority: 33,
      builder: _freshStartBoard,
    ),
    ShareThemeDefinition(
      id: 'games_collector_pick',
      label: 'Collector Pick',
      subtitle: 'قطعة تستحق الاهتمام',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF312E81), Color(0xFF8B5CF6)],
      priority: 34,
      builder: _collectorPick,
    ),
    ShareThemeDefinition(
      id: 'games_journal_diary',
      label: 'يوميات لعبة',
      subtitle: 'ستايل نوتة وذكريات',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFFD6D3D1), Color(0xFFBCAAA4)],
      priority: 35,
      builder: _journalDiary,
    ),
    ShareThemeDefinition(
      id: 'games_quick_sale_fun',
      label: 'Quick Fun',
      subtitle: 'إعلان لفت نظر سريع',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF38BDF8), Color(0xFF2563EB)],
      priority: 36,
      builder: _quickSaleFun,
    ),
    ShareThemeDefinition(
      id: 'games_wishlist_match',
      label: 'Wishlist Match',
      subtitle: 'مناسبة للي بيدور على لعبة حلوة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFFF472B6), Color(0xFFE879F9)],
      priority: 37,
      builder: _wishlistMatch,
    ),
    ShareThemeDefinition(
      id: 'games_playdate_card',
      label: 'Playdate',
      subtitle: 'لعبة جاهزة لصاحب جديد',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFF60A5FA), Color(0xFF22C55E)],
      priority: 38,
      builder: _playdateCard,
    ),
    ShareThemeDefinition(
      id: 'games_smart_mom_pick',
      label: 'اختيار ذكي',
      subtitle: 'ستايل مناسب للأمهات',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFFF5D0FE), Color(0xFFDDD6FE)],
      priority: 39,
      builder: _smartMomPick,
    ),
    ShareThemeDefinition(
      id: 'games_fun_market',
      label: 'Fun Market',
      subtitle: 'ستايل متجر جذاب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.games],
      gradient: const <Color>[Color(0xFFFB7185), Color(0xFFF59E0B)],
      priority: 40,
      builder: _funMarket,
    ),
  ];

  static Widget _ps01ActionLevelUp(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFF020B1D);
    const Color blue = Color(0xFF008DFF);
    const Color cyan = Color(0xFF15D7FF);
    const Color white = Colors.white;

    return _poster(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF073B88), bg],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _PSActionBackgroundPainter())),
          Column(
            children: <Widget>[
              _psLogoCorner(white, blue),
              _psSlantedHeadline('جاهز لمستوى', 'جديد من اللعب؟', blue, white),
              Expanded(
                child: _psArenaStage(
                  d.imageUrl,
                  border: cyan,
                  glow: blue,
                  placeholderText: ' ',
                ),
              ),
              _centerTitle(d.title, white, 24),
              _centerCaption(_psDescription(d, 'أداء قوي وتجربة ممتعة'), cyan),
              _psSpecTiles(d, blue: blue, fg: white, dark: true),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _ps02GlassFuture(BuildContext context, ShareProductData d) {
    const Color blue = Color(0xFF0EA5E9);
    const Color purple = Color(0xFF8B5CF6);
    const Color cyan = Color(0xFF22D3EE);

    return _poster(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF071A63), Color(0xFF331B91), Color(0xFF16133D)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _PSGlassBackgroundPainter())),
          Column(
            children: <Widget>[
              _psLogoCorner(Colors.white, cyan),
              _psHeadline('مستقبل اللعب\nيبدأ من هنا', Colors.white, size: 22),
              Expanded(
                child: _psGlassDisplay(
                  d.imageUrl,
                  border: cyan,
                  glow: purple,
                  placeholderText: ' ',
                ),
              ),
              _psGlassInfoCard(d, purple, cyan),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _ps03LuxuryCollector(BuildContext context, ShareProductData d) {
    const Color gold = Color(0xFFD4AF37);
    const Color deepGold = Color(0xFF9A6A13);
    const Color bg = Color(0xFF050505);

    return _poster(
      decoration: const BoxDecoration(color: bg),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _PSLuxuryFramePainter())),
          Column(
            children: <Widget>[
              _psLogoCorner(gold, gold, center: true),
              _psMiniText('قطعة مميزة', gold),
              Expanded(child: _psLuxuryStage(d.imageUrl, gold)),
              _centerTitle(d.title, gold, 25),
              _psMiniText('اختيار فاخر لهواة الألعاب', Colors.white.withOpacity(0.82)),
              _psSpecTiles(d, blue: gold, fg: Colors.white, dark: true, luxury: true),
            ],
          ),
        ],
      ),
    );
  }



  static Widget _poster({required Decoration decoration, required Widget child}) {
    return Container(
      decoration: decoration,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
          child: child,
        ),
      ),
    );
  }

  static Widget _psLogoCorner(Color color, Color accent, {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
      child: Row(
        mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: center ? Colors.transparent : accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: center ? null : Border.all(color: accent.withOpacity(0.20)),
            ),
          ),
          if (!center)
            Text('△ ○ × □', style: TextStyle(color: accent.withOpacity(0.82), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
        ],
      ),
    );
  }

  static Widget _psSlantedHeadline(String line1, String line2, Color blue, Color white) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 2),
      child: Column(
        children: <Widget>[
          Transform.rotate(
            angle: -0.045,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: <Color>[blue.withOpacity(0.86), const Color(0xFF0B3EA8)]),
                boxShadow: <BoxShadow>[BoxShadow(color: blue.withOpacity(0.30), blurRadius: 12)],
              ),
              child: Text(line1, style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 2),
          Text(line2, textAlign: TextAlign.center, style: TextStyle(color: white, fontSize: 31, fontWeight: FontWeight.w900, height: 0.98, letterSpacing: -0.4)),
        ],
      ),
    );
  }

  static Widget _psHeadline(String text, Color color, {double size = 21}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Text(text, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w900, height: 1.08)),
    );
  }

  static Widget _psMiniText(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      child: Text(text, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 12.6, fontWeight: FontWeight.w800, height: 1.25)),
    );
  }

  static Widget _psArenaStage(String imageUrl, {required Color border, required Color glow, required String placeholderText}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 10, 22, 8),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), border: Border.all(color: border.withOpacity(0.95), width: 2), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFF071B49), Color(0xFF020A18)]), boxShadow: <BoxShadow>[BoxShadow(color: glow.withOpacity(0.42), blurRadius: 26, offset: const Offset(0, 10))]))),
          Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 34), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(imageUrl))),
          Positioned(bottom: 46, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.22), borderRadius: BorderRadius.circular(999)), child: Text(placeholderText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: border.withOpacity(0.78), fontSize: 10.5, fontWeight: FontWeight.w800)))),
        ],
      ),
    );
  }

  static Widget _psGlassDisplay(String imageUrl, {required Color border, required Color glow, required String placeholderText}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 12, 22, 4),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(34), border: Border.all(color: border.withOpacity(0.42), width: 1.5), gradient: LinearGradient(colors: <Color>[Colors.white.withOpacity(0.13), glow.withOpacity(0.15)])))),
          Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 42), child: ClipRRect(borderRadius: BorderRadius.circular(24), child: shareNetworkImage(imageUrl))),
          Positioned(bottom: 54, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.13), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withOpacity(0.16))), child: Text(placeholderText, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w800)))),
        ],
      ),
    );
  }

  static Widget _psLuxuryStage(String imageUrl, Color gold) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 12, 28, 6),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(child: Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gold.withOpacity(0.45), width: 1.2), gradient: RadialGradient(colors: <Color>[gold.withOpacity(0.14), Colors.transparent])))),
          Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 32), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(imageUrl))),
        ],
      ),
    );
  }





  static Widget _psGlassInfoCard(ShareProductData d, Color purple, Color cyan) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: LinearGradient(colors: <Color>[Colors.white.withOpacity(0.13), purple.withOpacity(0.16)]), border: Border.all(color: Colors.white.withOpacity(0.18))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[Expanded(child: Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))), Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(0.13), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 24))]),
          const SizedBox(height: 8),
          Text(_psDescription(d, 'تفاصيل أوضح وتجربة أقرب للواقع'), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _psInlineChips(d, accent: cyan, dark: true),
        ],
      ),
    );
  }

  static Widget _psSpecTiles(ShareProductData d, {required Color blue, required Color fg, required bool dark, bool luxury = false}) {
    final Color bg = dark ? Colors.white.withOpacity(0.06) : Colors.white;
    final Color border = blue.withOpacity(dark ? 0.65 : 0.18);
    final List<_InfoItem> items = <_InfoItem>[
      _InfoItem(shareHas(d.subCategory) ? d.subCategory : 'إكسسوار', 'الفئة', Icons.gamepad_rounded),
      _InfoItem(shareHas(d.condition) ? d.condition : 'ممتازة', 'الحالة', Icons.verified_rounded),
      const _InfoItem('مناسب\nللتبديل', 'عرض', Icons.swap_horiz_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: items.map((_InfoItem item) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(luxury ? 999 : 12), border: Border.all(color: border)), child: Column(children: <Widget>[Icon(item.icon, color: blue, size: 18), const SizedBox(height: 5), Text(item.label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 10.2, fontWeight: FontWeight.w900, height: 1.1))])))).toList(),
      ),
    );
  }

  static Widget _psInlineChips(ShareProductData d, {required Color accent, required bool dark}) {
    final Color fg = dark ? Colors.white : accent;
    final Color bg = dark ? Colors.white.withOpacity(0.10) : accent.withOpacity(0.07);
    final List<String> chips = <String>[ shareHas(d.subCategory) ? d.subCategory : 'ألعاب/ملحقات', shareHas(d.condition) ? d.condition : 'حالة ممتازة', 'ضمان الجودة'];
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: chips.map((String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: accent.withOpacity(0.20))), child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w900)))).toList(),
    );
  }




  static Widget _psSmallBadge(String text, IconData icon, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: bg.withOpacity(0.92), borderRadius: BorderRadius.circular(999), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(icon, color: fg, size: 16), const SizedBox(width: 5), Text(text, style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w900))]),
    );
  }



  static Widget _psPricePanel(String price, Color blue, Color purple) {
    final String value = price.trim().isEmpty ? 'السعر أو قيمة التبديل' : price;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: <Color>[blue.withOpacity(0.18), purple.withOpacity(0.24)]), border: Border.all(color: purple.withOpacity(0.58))),
      child: Row(children: <Widget>[Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: purple), boxShadow: <BoxShadow>[BoxShadow(color: purple.withOpacity(0.30), blurRadius: 14)]), child: Icon(Icons.sell_outlined, color: Colors.white.withOpacity(0.92), size: 22)), const SizedBox(width: 12), Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)))]),
    );
  }



  static String _psDescription(ShareProductData d, String fallback) {
    if (!shareHas(d.description)) return fallback;
    final String text = d.description.trim().replaceAll('\n', ' ');
    if (text.length <= 88) return text;
    return '${text.substring(0, 88)}...';
  }


  static Widget _levelUpStory(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFF0E1026);
    const Color cyan = Color(0xFF22D3EE);
    const Color violet = Color(0xFF8B5CF6);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF141735), Color(0xFF0B1022)],
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cyan.withOpacity(0.25)),
            ),
            child: Row(
              children: const <Widget>[
                Icon(Icons.sports_esports_rounded, color: cyan, size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'LEVEL UP — اللعبة دي مستنية لاعب جديد',
                    style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(colors: <Color>[cyan, violet]),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: cyan.withOpacity(0.28), blurRadius: 22, offset: const Offset(0, 10)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: shareNetworkImage(d.imageUrl),
                ),
              ),
            ),
          ),
          _centerTitle(d.title, Colors.white, 19),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: <Widget>[
                Expanded(child: _infoBadge('الحالة', shareHas(d.condition) ? d.condition : 'جاهزة', cyan, dark: true)),
                const SizedBox(width: 8),
                Expanded(child: _infoBadge('السعر', sharePriceText(d).isEmpty ? 'مفتوح' : sharePriceText(d), violet, dark: true)),
                const SizedBox(width: 8),
                Expanded(child: _infoBadge('المكان', shareShortLocation(d.location).isEmpty ? 'قريب منك' : shareShortLocation(d.location), cyan, dark: true)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _ctaBar('لو عجبتك… اطلب تبديلها قبل غيرك', cyan, bg),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _momClearingMagic(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFFFF5F9);
    const Color rose = Color(0xFFE879A8);
    const Color plum = Color(0xFF7C3F66);
    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: rose.withOpacity(0.18)),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: const Color(0xFFFFE0EC), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.auto_awesome_rounded, color: rose, size: 23),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'لعبة حلوة بدل ما تقعد مركونة… خليها تدخل بيتًا تاني وتفرّح طفلًا جديدًا.',
                      style: TextStyle(color: plum, fontSize: 13.2, fontWeight: FontWeight.w800, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: _imageCard(d.imageUrl, borderColor: rose.withOpacity(0.16), radius: 24),
            ),
          ),
          _centerTitle(d.title, plum, 18),
          _centerChips(d, accent: rose, lightBg: Colors.white),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              'رسالة للأمهات: لو اللعبة لسه جميلة ومفيدة، مشاركتها هنا تخلي حد يستفيد بيها بدل التخزين.',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: plum.withOpacity(0.78), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.38),
            ),
          ),
          const Spacer(),
          _ctaBar('انشريها… ويمكن تلاقي تبديل مناسب بسرعة', rose, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _giftReadyCard(BuildContext context, ShareProductData d) {
    const Color gold = Color(0xFFF59E0B);
    const Color orange = Color(0xFFFB923C);
    const Color ink = Color(0xFF5C3210);
    return Container(
      color: const Color(0xFFFFFAF0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8C2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '🎁 لعبة تنفع هدية… وتنفع تبديل لطيف كمان',
              textAlign: TextAlign.center,
              style: TextStyle(color: ink, fontSize: 13.4, fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: _imageCard(d.imageUrl, borderColor: gold.withOpacity(0.2), radius: 24),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(999)),
                      child: const Text('Gift Ready', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _centerTitle(d.title, ink, 19),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
            child: Text(
              'لو حد بيدور على لعبة لطيفة ومرتبة، دي ممكن تكون اختيار ممتاز وتلفت النظر بسرعة.',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink.withOpacity(0.75), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.35),
            ),
          ),
          const SizedBox(height: 8),
          _centerChips(d, accent: gold, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('شارِك اللعبة وخليها توصل لصاحبها المناسب', orange, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _swapPosterPro(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFF111827);
    const Color white = Colors.white;
    const Color accent = Color(0xFF22C55E);
    const Color warm = Color(0xFFF59E0B);
    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Row(
              children: <Widget>[
                Expanded(
                  child: Text('SWAP POSTER', style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                ),
                Icon(Icons.campaign_rounded, color: warm),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    shareNetworkImage(d.imageUrl),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Colors.black.withOpacity(0.04), Colors.black.withOpacity(0.42)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(d.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: white, fontSize: 21, fontWeight: FontWeight.w900, height: 1.12)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: <Widget>[
                Expanded(child: _posterMetric('الحالة', shareHas(d.condition) ? d.condition : 'جيدة', accent)),
                const SizedBox(width: 8),
                Expanded(child: _posterMetric('السعر', sharePriceText(d).isEmpty ? 'مفتوح' : sharePriceText(d), warm)),
                const SizedBox(width: 8),
                Expanded(child: _posterMetric('المكان', shareShortLocation(d.location).isEmpty ? 'قريب' : shareShortLocation(d.location), accent)),
              ],
            ),
          ),
          const Spacer(),
          _ctaBar('لو مناسبة لك… اطلب تبديلها الآن', accent, bg),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _storybookFun(BuildContext context, ShareProductData d) {
    const Color lilac = Color(0xFFF4ECFF);
    const Color violet = Color(0xFF7C3AED);
    const Color berry = Color(0xFFEC4899);
    const Color ink = Color(0xFF4C325F);
    return Container(
      color: lilac,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          const Text('حكاية لعبتي', style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            'مرة لعبة جميلة… دلوقتي مستنية بطل جديد',
            style: TextStyle(color: ink.withOpacity(0.72), fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 10),
              child: _imageCard(d.imageUrl, borderColor: berry.withOpacity(0.18), radius: 26),
            ),
          ),
          _centerTitle(d.title, ink, 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
            child: Text(
              _smartDescription(d,
                  fallback: 'دي لعبة لسه فيها روح ومتعة، وكل اللي ناقصها حد يختارها ويبدأ معاها فصل جديد.'),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink.withOpacity(0.8), fontSize: 11.6, fontWeight: FontWeight.w800, height: 1.36),
            ),
          ),
          const SizedBox(height: 8),
          _centerChips(d, accent: violet, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('لو حسّيت إنها مناسبة… ابعت طلب تبديل', berry, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


  static Widget _teenTrend(BuildContext context, ShareProductData d) {
    const Color dark = Color(0xFF101216);
    const Color orange = Color(0xFFEA580C);
    const Color white = Colors.white;
    return Container(
      color: dark,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[Color(0xFF1F2937), Color(0xFF111827)]),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: orange.withOpacity(0.35)),
            ),
            child: const Text(
              'TEEN TREND — للناس اللي بتحب حاجتها تبان جامدة',
              textAlign: TextAlign.center,
              style: TextStyle(color: white, fontSize: 13.2, fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    shareNetworkImage(d.imageUrl),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Colors.transparent, Colors.black.withOpacity(0.45)],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(999)),
                        child: const Text('Hot Pick', style: TextStyle(color: white, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _centerTitle(d.title, white, 19),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              'لو إنت شاب من 12–16 وعاوز تشارك لعبة بشكل جامد وجاذب — ده من أنسب الستايلات.',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withOpacity(0.76), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.34),
            ),
          ),
          const SizedBox(height: 8),
          _centerChips(d, accent: orange, lightBg: Colors.white.withOpacity(0.1), dark: true),
          const Spacer(),
          _ctaBar('لو عجبتك… اطلبها قبل ما تروح لحد تاني', orange, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _softGirlFun(BuildContext context, ShareProductData d) {
    const Color pink = Color(0xFFFFAED6);
    const Color purple = Color(0xFFB794F4);
    const Color ink = Color(0xFF6B476A);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFFFF2F8), Color(0xFFF3EEFF)],
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
            child: const Text('💕 لعبة لطيفة تستحق حد يختارها', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: _imageCard(d.imageUrl, borderColor: pink.withOpacity(0.25), radius: 26),
            ),
          ),
          _centerTitle(d.title, ink, 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
            child: Text(
              'ستايل هادي ولطيف مناسب جدًا لبنوته أو لماما بتحب تعرض ألعاب الأولاد بشكل جميل.',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink.withOpacity(0.76), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.34),
            ),
          ),
          const SizedBox(height: 8),
          _centerChips(d, accent: purple, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('خلي اللعبة توصل لحد يفرح بيها', pink, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _comicPopBlast(BuildContext context, ShareProductData d) {
    const Color yellow = Color(0xFFFDE047);
    const Color orange = Color(0xFFF97316);
    const Color ink = Color(0xFF151515);
    return Container(
      color: const Color(0xFFFFFBEB),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _PopDotsPainter())),
          Column(
            children: <Widget>[
              const SizedBox(height: 14),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: yellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ink, width: 1.4),
                ),
                child: const Text('WOW! لعبة ممكن تخطف النظر من أول ثانية', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 13.2, fontWeight: FontWeight.w900)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: ink, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: shareNetworkImage(d.imageUrl)),
                    ),
                  ),
                ),
              ),
              _centerTitle(d.title, ink, 19),
              const SizedBox(height: 8),
              _centerChips(d, accent: orange, lightBg: Colors.white),
              const Spacer(),
              _ctaBar('لو شدت انتباهك… ابعت طلب تبديل', orange, Colors.white),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _familyPlayInvite(BuildContext context, ShareProductData d) {
    const Color green = Color(0xFF10B981);
    const Color dark = Color(0xFF0F3D33);
    return Container(
      color: const Color(0xFFF1FBF7),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: const <Widget>[
                Icon(Icons.groups_rounded, color: green),
                SizedBox(width: 8),
                Expanded(child: Text('دعوة لعب عائلي', style: TextStyle(color: dark, fontSize: 20, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
              child: _imageCard(d.imageUrl, borderColor: green.withOpacity(0.2), radius: 24),
            ),
          ),
          _centerTitle(d.title, dark, 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(
              'لو حد بيدور على لعبة تدخل جوّ حلو في البيت، دي فرصة ممتازة وتستحق التجربة.',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: dark.withOpacity(0.74), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.33),
            ),
          ),
          const SizedBox(height: 8),
          _centerChips(d, accent: green, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('خلي حد يدخل جو اللعب الجميل ده', green, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _vipShowcase(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFF111827);
    const Color gold = Color(0xFFD4AF37);
    const Color ivory = Color(0xFFFFFBF0);
    return Container(
      color: bg,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          const Text('VIP SHOWCASE', style: TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('عرض فاخر للعبة مميزة', style: TextStyle(color: ivory.withOpacity(0.76), fontSize: 11, fontWeight: FontWeight.w800)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF161C2D),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: gold.withOpacity(0.55)),
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl)),
              ),
            ),
          ),
          _centerTitle(d.title, ivory, 18),
          const SizedBox(height: 8),
          _centerChips(d, accent: gold, lightBg: Colors.white.withOpacity(0.08), dark: true),
          const Spacer(),
          _ctaBar('لعبة تستحق الاهتمام — اطلب تبديلها', gold, bg),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _freshStartBoard(BuildContext context, ShareProductData d) {
    const Color aqua = Color(0xFF14B8A6);
    const Color blue = Color(0xFF38BDF8);
    const Color ink = Color(0xFF134E4A);
    return Container(
      color: const Color(0xFFF0FDFA),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: const <Widget>[
                Expanded(child: Text('Fresh Start', style: TextStyle(color: ink, fontSize: 23, fontWeight: FontWeight.w900))),
                Icon(Icons.refresh_rounded, color: aqua),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'أحيانًا اللعبة مش محتاجة غير بداية جديدة وصاحب جديد يقدّرها.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ink.withOpacity(0.7), fontSize: 11.5, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 10),
              child: _imageCard(d.imageUrl, borderColor: blue.withOpacity(0.2), radius: 24),
            ),
          ),
          _centerTitle(d.title, ink, 18),
          const SizedBox(height: 8),
          _centerChips(d, accent: aqua, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('ابدأ معاها بداية جديدة', blue, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _collectorPick(BuildContext context, ShareProductData d) {
    const Color deep = Color(0xFF312E81);
    const Color accent = Color(0xFF8B5CF6);
    const Color bg = Color(0xFFF5F3FF);
    return Container(
      color: bg,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: accent.withOpacity(0.18))),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.auto_awesome_mosaic_rounded, color: accent),
                  SizedBox(width: 8),
                  Expanded(child: Text('Collector Pick — لعبة مميزة تستحق التوقف عندها', style: TextStyle(color: deep, fontSize: 13.3, fontWeight: FontWeight.w900))),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
              child: _imageCard(d.imageUrl, borderColor: accent.withOpacity(0.2), radius: 26),
            ),
          ),
          _centerTitle(d.title, deep, 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
            child: Text(
              'لو بتحب الحاجات المختلفة أو بتدور على لعبة ملفتة، الستايل ده مناسب جدًا للعرض.',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: deep.withOpacity(0.76), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.34),
            ),
          ),
          const SizedBox(height: 8),
          _centerChips(d, accent: accent, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('لفتت نظرك؟ اطلب تبديلها الآن', deep, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _journalDiary(BuildContext context, ShareProductData d) {
    const Color paper = Color(0xFFFAF7F2);
    const Color line = Color(0xFFE7DED3);
    const Color ink = Color(0xFF5E4B3C);
    const Color accent = Color(0xFF0EA5E9);
    return Container(
      color: paper,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text('يوميات لعبة جميلة', style: TextStyle(color: ink, fontSize: 23, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: paper,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: line),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(child: CustomPaint(painter: _NotebookLinesPainter())),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: shareNetworkImage(d.imageUrl)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            d.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'جاهزة تعيش ذكرى جديدة مع حد هيقدّرها ويلعب بيها بدل ما تفضل على الرف.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ink.withOpacity(0.76), fontSize: 11.3, fontWeight: FontWeight.w800, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _centerChips(d, accent: accent, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('اكتب لها صفحة جديدة مع صاحب جديد', accent, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _quickSaleFun(BuildContext context, ShareProductData d) {
    const Color blue = Color(0xFF0EA5E9);
    const Color deep = Color(0xFF1D4ED8);
    return Container(
      color: const Color(0xFFF0F9FF),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: <Color>[blue, deep]),
            ),
            child: const Text('عرض سريع… لكن جذاب جدًا 👀', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: _imageCard(d.imageUrl, borderColor: blue.withOpacity(0.18), radius: 24),
            ),
          ),
          _centerTitle(d.title, const Color(0xFF0F172A), 18),
          const SizedBox(height: 8),
          _centerChips(d, accent: blue, lightBg: Colors.white),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'دي من الستايلات اللي تلفت العين بسرعة وتخلي الناس توقف عند المنتج.',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: const Color(0xFF0F172A).withOpacity(0.72), fontSize: 11.4, fontWeight: FontWeight.w800, height: 1.34),
            ),
          ),
          const SizedBox(height: 12),
          _ctaBar('خلّي المنتج يبان… واطلب تبديله', deep, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _wishlistMatch(BuildContext context, ShareProductData d) {
    const Color pink = Color(0xFFF472B6);
    const Color plum = Color(0xFF9D4EDD);
    const Color ink = Color(0xFF5B375F);
    return Container(
      color: const Color(0xFFFFF6FC),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[pink, plum]),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text('💖 يمكن تكون هي اللعبة اللي حد بيدور عليها', style: TextStyle(color: Colors.white, fontSize: 13.2, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
              child: _imageCard(d.imageUrl, borderColor: pink.withOpacity(0.2), radius: 24),
            ),
          ),
          _centerTitle(d.title, ink, 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
            child: Text(
              'الرسالة هنا موجهة لشخص نفسه يلاقي لعبة حلوة… وممكن لعبتك تكون هي الاختيار المثالي له.',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink.withOpacity(0.77), fontSize: 11.4, fontWeight: FontWeight.w800, height: 1.33),
            ),
          ),
          const SizedBox(height: 8),
          _centerChips(d, accent: plum, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('لو حسّيتها مناسبة… ابعت طلب تبديل', pink, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _playdateCard(BuildContext context, ShareProductData d) {
    const Color blue = Color(0xFF3B82F6);
    const Color green = Color(0xFF22C55E);
    const Color ink = Color(0xFF1E3A5F);
    return Container(
      color: const Color(0xFFF6FBFF),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: blue.withOpacity(0.18))),
            child: const Text('🎮 لعبة جاهزة لموعد لعب جديد', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 10),
              child: _imageCard(d.imageUrl, borderColor: green.withOpacity(0.2), radius: 24),
            ),
          ),
          _centerTitle(d.title, ink, 18),
          const SizedBox(height: 8),
          _centerChips(d, accent: blue, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('لو بتدور على لعبة تسلّي… دي جاهزة', green, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _smartMomPick(BuildContext context, ShareProductData d) {
    const Color lilac = Color(0xFFF5F3FF);
    const Color purple = Color(0xFF8B5CF6);
    const Color ink = Color(0xFF5B4A72);
    return Container(
      color: lilac,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: purple.withOpacity(0.16))),
              child: const Text(
                'للأمهات: عرض شيك للعبة حلوة بدل ما تفضل مخزنة في البيت.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ink, fontSize: 13.2, fontWeight: FontWeight.w900, height: 1.35),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
              child: _imageCard(d.imageUrl, borderColor: purple.withOpacity(0.18), radius: 24),
            ),
          ),
          _centerTitle(d.title, ink, 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
            child: Text(
              'رسالة عملية ومشجعة تساعد أي أم تعرض ألعاب أولادها بشكل مرتب ويجذب الناس للتبديل.',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink.withOpacity(0.75), fontSize: 11.4, fontWeight: FontWeight.w800, height: 1.34),
            ),
          ),
          const SizedBox(height: 8),
          _centerChips(d, accent: purple, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('انشري اللعبة… ويمكن تلاقي تبديل ممتاز', purple, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _funMarket(BuildContext context, ShareProductData d) {
    const Color pink = Color(0xFFFB7185);
    const Color amber = Color(0xFFF59E0B);
    const Color ink = Color(0xFF582B38);
    return Container(
      color: const Color(0xFFFFFBF7),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: <Color>[pink, amber]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'FUN MARKET — إعلان جذاب يخلي المنتج يبان من أول نظرة',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13.1, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
              child: _imageCard(d.imageUrl, borderColor: pink.withOpacity(0.18), radius: 24),
            ),
          ),
          _centerTitle(d.title, ink, 18),
          const SizedBox(height: 8),
          _centerChips(d, accent: amber, lightBg: Colors.white),
          const Spacer(),
          _ctaBar('لو عجبتك الفكرة… اطلب تبديلها فورًا', pink, Colors.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _headerTitle(String title, String subtitle, Color accent, Color ink) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        children: <Widget>[
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: accent, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: ink.withOpacity(0.74), fontSize: 11.3, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  static Widget _imageCard(
      String imageUrl, {
        required Color borderColor,
        double radius = 24,
        double innerPadding = 6,
      }) {
    return Container(
      padding: EdgeInsets.all(innerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius + 6),
        border: Border.all(color: borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: shareNetworkImage(imageUrl),
      ),
    );
  }

  static Widget _centerTitle(String title, Color color, double size) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w900, height: 1.12),
      ),
    );
  }

  static Widget _centerCaption(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color.withOpacity(0.76), fontSize: 11.4, fontWeight: FontWeight.w800, height: 1.34),
      ),
    );
  }

  static Widget _centerChips(
      ShareProductData d, {
        required Color accent,
        required Color lightBg,
        bool dark = false,
      }) {
    final Color fg = dark ? Colors.white : accent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: <Widget>[
          if (shareHas(d.subCategory) || shareHas(d.category))
            sharePill(
              text: shareHas(d.subCategory) ? d.subCategory : d.category,
              bg: lightBg,
              fg: fg,
              icon: Icons.extension_rounded,
            ),
          if (shareHas(d.condition))
            sharePill(text: d.condition, bg: lightBg, fg: fg, icon: Icons.verified_rounded),
          if (shareHas(sharePriceText(d)))
            sharePill(text: sharePriceText(d), bg: accent, fg: Colors.white, icon: Icons.payments_rounded),
          if (shareHas(d.location))
            sharePill(text: shareShortLocation(d.location), bg: lightBg, fg: fg, icon: Icons.location_on_rounded),
        ],
      ),
    );
  }

  static Widget _ctaBar(String text, Color bg, Color fg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: fg, fontSize: 13.1, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  static Widget _infoBadge(String label, String value, Color accent, {bool dark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Column(
        children: <Widget>[
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: dark ? Colors.white : const Color(0xFF1F2937), fontSize: 10.5, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  static Widget _posterMetric(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Column(
        children: <Widget>[
          Text(label, style: TextStyle(color: accent, fontSize: 8.8, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10.4, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _priceStrip(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(14)),
      child: Text(text, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12.8, fontWeight: FontWeight.w900)),
    );
  }

  static String _smartDescription(ShareProductData d, {required String fallback}) {
    if (shareHas(d.description)) {
      final String text = d.description.trim();
      if (text.length <= 95) return text;
      return '${text.substring(0, 95)}...';
    }

    if (shareHas(d.subCategory)) {
      return 'قطعة ممتعة من فئة ${d.subCategory}، حالتها ${shareHas(d.condition) ? d.condition : 'جيدة'} وجاهزة تدخل بيتًا جديدًا.';
    }

    return fallback;
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

class _PSActionBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint blue = Paint()..color = const Color(0xFF008DFF).withOpacity(0.34)..strokeWidth = 3;
    final Paint soft = Paint()..color = Colors.white.withOpacity(0.08)..strokeWidth = 1.3;
    final Paint dots = Paint()..color = const Color(0xFF22D3EE).withOpacity(0.30);
    for (double x = -size.height; x < size.width + size.height; x += 46) {
      canvas.drawLine(Offset(x, size.height * .72), Offset(x + size.height * .52, size.height * .24), x % 92 == 0 ? blue : soft);
    }
    for (double y = 18; y < size.height; y += 18) {
      for (double x = size.width - 64; x < size.width - 18; x += 11) {
        canvas.drawCircle(Offset(x, y), 1.3, dots);
      }
    }
    final Paint shadow = Paint()..color = Colors.black.withOpacity(0.22);
    canvas.drawOval(Rect.fromLTWH(-35, size.height * .20, 130, 220), shadow);
    canvas.drawOval(Rect.fromLTWH(size.width - 100, size.height * .22, 130, 220), shadow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PSGlassBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint blue = Paint()..color = const Color(0xFF22D3EE).withOpacity(0.18)..strokeWidth = 1.4;
    final Paint purple = Paint()..color = const Color(0xFF8B5CF6).withOpacity(0.20);
    canvas.drawCircle(Offset(size.width + 20, 70), 115, purple);
    canvas.drawCircle(Offset(-20, size.height - 110), 95, purple);
    canvas.drawLine(Offset(0, size.height * .17), Offset(size.width, size.height * .04), blue);
    canvas.drawLine(Offset(size.width, size.height * .32), Offset(0, size.height * .48), blue);
    canvas.drawLine(Offset(size.width * .10, size.height), Offset(size.width * .88, 0), blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PSLuxuryFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint border = Paint()..color = const Color(0xFFD4AF37).withOpacity(0.90)..strokeWidth = 1.4..style = PaintingStyle.stroke;
    final Paint glow = Paint()..color = const Color(0xFFD4AF37).withOpacity(0.12);
    final RRect r = RRect.fromRectAndRadius(Rect.fromLTWH(8, 8, size.width - 16, size.height - 16), const Radius.circular(24));
    canvas.drawRRect(r, border);
    final Paint inner = Paint()..color = const Color(0xFFD4AF37).withOpacity(0.35)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(14, 14, size.width - 28, size.height - 28), const Radius.circular(20)), inner);
    canvas.drawCircle(Offset(size.width / 2, size.height * .30), size.width * .33, glow);
    final Paint blue = Paint()..color = const Color(0xFF005CFF).withOpacity(0.75)..strokeWidth = 2;
    canvas.drawLine(Offset(10, size.height * .36), Offset(10, size.height * .50), blue);
    canvas.drawLine(Offset(size.width - 10, size.height * .36), Offset(size.width - 10, size.height * .50), blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PSNeonCircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint blue = Paint()..color = const Color(0xFF0A8BFF).withOpacity(0.72)..strokeWidth = 2;
    final Paint purple = Paint()..color = const Color(0xFFC026FF).withOpacity(0.72)..strokeWidth = 2;
    final Paint dots = Paint()..color = const Color(0xFF0A8BFF).withOpacity(0.20);
    final RRect outer = RRect.fromRectAndRadius(Rect.fromLTWH(8, 8, size.width - 16, size.height - 16), const Radius.circular(28));
    canvas.drawRRect(outer, blue);
    final RRect inner = RRect.fromRectAndRadius(Rect.fromLTWH(16, 18, size.width - 32, size.height - 36), const Radius.circular(22));
    canvas.drawRRect(inner, purple);
    for (double y = 40; y < size.height; y += 16) {
      for (double x = 28; x < 74; x += 10) {
        canvas.drawCircle(Offset(x, y), 1.2, dots);
      }
      for (double x = size.width - 74; x < size.width - 28; x += 10) {
        canvas.drawCircle(Offset(x, y), 1.2, dots);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PSCleanBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint blueSoft = Paint()..color = const Color(0xFF0B6FDC).withOpacity(0.10);
    final Paint blueLine = Paint()..color = const Color(0xFF0B6FDC).withOpacity(0.16)..strokeWidth = 1.2;
    canvas.drawCircle(Offset(size.width * .52, 120), 92, blueSoft);
    canvas.drawCircle(Offset(-30, 80), 100, blueSoft);
    canvas.drawLine(Offset(0, size.height * .18), Offset(size.width, size.height * .05), blueLine);
    canvas.drawLine(Offset(size.width, size.height * .24), Offset(size.width * .65, size.height * .05), blueLine);
    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    final List<String> shapes = <String>['△', '○', '×', '□'];
    for (int i = 0; i < shapes.length; i++) {
      tp.text = TextSpan(text: shapes[i], style: TextStyle(color: const Color(0xFF0B6FDC).withOpacity(0.58), fontSize: 32, fontWeight: FontWeight.w900));
      tp.layout();
      tp.paint(canvas, Offset(26 + i * 78, 110 + (i % 2) * 55));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PopDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = const Color(0xFFF97316).withOpacity(0.08);
    for (double y = 12; y < size.height; y += 28) {
      for (double x = 10; x < size.width; x += 28) {
        canvas.drawCircle(Offset(x, y), 1.8, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint lines = Paint()..color = const Color(0xFFE5DDD4)..strokeWidth = 1;
    final Paint red = Paint()..color = const Color(0xFFFCA5A5)..strokeWidth = 1;
    for (double y = 18; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lines);
    }
    canvas.drawLine(const Offset(34, 0), Offset(34, size.height), red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
