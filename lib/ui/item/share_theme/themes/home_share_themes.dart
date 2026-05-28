import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class HomeShareThemes {
  const HomeShareThemes._();

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[

    // New home templates inspired by the attached designs.
    ShareThemeDefinition(
      id: 'home_modern_specs',
      label: 'احترافي حديث',
      subtitle: 'مواصفات منظمة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFF07192A), Color(0xFF2E75B6)],
      priority: 47,
      builder: _modernSpecs,
    ),
    ShareThemeDefinition(
      id: 'home_info_specs',
      label: 'ستايل معلوماتي',
      subtitle: 'مواصفات واضحة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFF8FAFC), Color(0xFFC0C8D2)],
      priority: 44,
      builder: _infoSpecs,
    ),
    ShareThemeDefinition(
      id: 'home_clean_offer',
      label: 'عرض احترافي',
      subtitle: 'ستايل أبيض فاخر',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFFBFAF6), Color(0xFFBBA177)],
      priority: 40,
      builder: _cleanOffer,
    ),
    ShareThemeDefinition(
      id: 'home_black_gold',
      label: 'ستايل فاخر',
      subtitle: 'أسود وذهبي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFF111111), Color(0xFFC7A45C)],
      priority: 41,
      builder: _blackGold,
    ),
    ShareThemeDefinition(
      id: 'home_pop_social',
      label: 'ستايل مرح',
      subtitle: 'مناسب للسوشيال',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFFFCF28), Color(0xFF1EC5D8)],
      priority: 42,
      builder: _popSocial,
    ),

    ShareThemeDefinition(
      id: 'home_lifestyle_magazine',
      label: 'ستايل مجلة',
      subtitle: 'عرض أنيق ومختلف',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFD6D0C8), Color(0xFF4A4038)],
      priority: 45,
      builder: _lifestyleMagazine,
    ),
    ShareThemeDefinition(
      id: 'home_cute_soft',
      label: 'ستايل كيوت',
      subtitle: 'ألوان ناعمة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFFFDFED), Color(0xFFA58ADF)],
      priority: 46,
      builder: _cuteSoft,
    ),

    ShareThemeDefinition(
      id: 'home_flash_deal',
      label: 'عرض جذاب',
      subtitle: 'تصميم قوي للعرض',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFF111111), Color(0xFFFFD400)],
      priority: 48,
      builder: _flashDeal,
    ),
    ShareThemeDefinition(
      id: 'home_dream_story',
      label: 'حكاية بيت',
      subtitle: 'ستايل كيوت دافئ',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFE7D8FA), Color(0xFFFFDDE8)],
      priority: 30,
      builder: _dreamStory,
    ),
    ShareThemeDefinition(
      id: 'home_mom_diary',
      label: 'يوميات مرتبة',
      subtitle: 'نوت بوك للأمهات',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFF6EFE4), Color(0xFF9BAA9A)],
      priority: 31,
      builder: _momDiary,
    ),
    ShareThemeDefinition(
      id: 'home_eco_choice',
      label: 'اختيار ذكي',
      subtitle: 'إعادة استخدام بذكاء',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFF2E8D2), Color(0xFF2E703E)],
      priority: 32,
      builder: _ecoChoice,
    ),
    ShareThemeDefinition(
      id: 'home_elegant_boutique',
      label: 'ركن أنيق',
      subtitle: 'ستايل فاخر وناعم',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFFFF8F0), Color(0xFFD6A4A1)],
      priority: 33,
      builder: _elegantBoutique,
    ),

    ShareThemeDefinition(
      id: 'home_family_ticket',
      label: 'رفيقة السفر',
      subtitle: 'ستايل تذكرة سفر',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFFFF1DF), Color(0xFF5C9CA5)],
      priority: 37,
      builder: _familyTicket,
    ),
    ShareThemeDefinition(
      id: 'home_quick_review',
      label: 'مراجعة سريعة',
      subtitle: 'تقييم واضح',
      groups: const <ShareThemeGroup>[ShareThemeGroup.home],
      gradient: const <Color>[Color(0xFFF8FEFC), Color(0xFFAF8ED8)],
      priority: 38,
      builder: _quickReview,
    ),

  ];


  static Widget _dreamStory(BuildContext context, ShareProductData d) {
    return _poster(
      d,
      bg: const Color(0xFFFFEDF6),
      accent: const Color(0xFF8B74AA),
      title: 'حكاية بيت',
      subtitle: 'رفيقة البيت الصغيرة',
      icon: Icons.nights_stay_rounded,
      imageRadius: 34,
      topDecoration: const _FloatingDecorations(
        emojis: <String>['☾', '⭐', '☁️', '🧸'],
      ),
      body: _friendlyHomeLine(d),
      action: 'شاهدي التفاصيل',
      features: <_Feature>[
        _Feature(Icons.favorite_rounded, 'محفوظة بحب'),
        _Feature(Icons.verified_rounded, 'جاهزة للاستخدام'),
        _Feature(Icons.cleaning_services_rounded, 'نظيفة ومرتبة'),
      ],
    );
  }

  static Widget _momDiary(BuildContext context, ShareProductData d) {
    const Color sage = Color(0xFF82998E);
    return _paperPoster(
      d,
      accent: sage,
      title: 'يوميات أم مرتبة',
      subtitle: 'اختيار ذكي لراحة بيتك وتوفير لك',
      action: 'احتفظي بها الآن',
      notes: <String>['مريحة في البيت', 'سهلة التخزين', 'استخدام نظيف'],
      footer: 'اختيارك المرتب يحدث فرق ♡',
    );
  }

  static Widget _ecoChoice(BuildContext context, ShareProductData d) {
    const Color green = Color(0xFF2F6E3E);
    return _poster(
      d,
      bg: const Color(0xFFF7EEDB),
      accent: green,
      title: 'اختيار ذكي\nللمنزل',
      subtitle: 'إعادة استخدام بذكاء',
      icon: Icons.eco_rounded,
      imageRadius: 42,
      topDecoration: const _FloatingDecorations(
        icons: <IconData>[Icons.eco_rounded, Icons.recycling_rounded],
      ),
      body: 'منتجات بحالة جيدة تستحق حياة ثانية لتقليل الفاقد وحماية كوكبنا.',
      action: 'خليها تكمل رحلتها',
      features: <_Feature>[
        _Feature(Icons.account_balance_wallet_rounded, 'توفير'),
        _Feature(Icons.eco_rounded, 'مستدام'),
        _Feature(Icons.thumb_up_rounded, 'عملي'),
      ],
    );
  }

  static Widget _elegantBoutique(BuildContext context, ShareProductData d) {
    return _luxuryPoster(
      d,
      bg: const Color(0xFFFFF8F2),
      accent: const Color(0xFFD7A762),
      textColor: const Color(0xFF8A6557),
      title: 'ركن البيت الأنيق',
      subtitle: 'كل ما يحتاجه بيتك بأناقة',
      action: 'تفاصيل أكثر',
      dark: false,
    );
  }


  static Widget _familyTicket(BuildContext context, ShareProductData d) {
    return _ticketPoster(
      d,
      accent: const Color(0xFF5A9CA5),
      secondary: const Color(0xFFD7A1A0),
      title: 'رفيقة السفر الصغيرة',
      subtitle: 'جاهزة للمشاوير',
      action: 'خذيها للمشاوير',
    );
  }

  static Widget _quickReview(BuildContext context, ShareProductData d) {
    return _reviewPoster(
      d,
      accent: const Color(0xFFA97AD5),
      secondary: const Color(0xFF9EDDC9),
      title: 'مراجعة سريعة',
      action: 'اكتشفيها',
    );
  }


  static Widget _cleanOffer(BuildContext context, ShareProductData d) {
    return _cleanPoster(
      d,
      accent: const Color(0xFFB89B6A),
      title: 'عرض احترافي',
      subtitle: _homeCategoryTitle(d, fallback: 'منتج منزلي عملي'),
    );
  }

  static Widget _blackGold(BuildContext context, ShareProductData d) {
    return _luxuryPoster(
      d,
      bg: const Color(0xFF11100E),
      accent: const Color(0xFFD8B56D),
      textColor: Colors.white,
      title: 'ستايل فاخر',
      subtitle: 'عرض مميز للمنتج',
      action: 'اختيار ذكي لكل بيت',
      dark: true,
    );
  }

  static Widget _popSocial(BuildContext context, ShareProductData d) {
    return _popPoster(d);
  }


  static Widget _infoSpecs(BuildContext context, ShareProductData d) {
    return _specPoster(
      d,
      bg: const Color(0xFFF7F8FA),
      accent: const Color(0xFF1B2D3E),
      title: 'ستايل معلوماتي',
      subtitle: 'مميزات المنتج',
      dark: false,
    );
  }

  static Widget _lifestyleMagazine(BuildContext context, ShareProductData d) {
    return _magazinePoster(d);
  }

  static Widget _cuteSoft(BuildContext context, ShareProductData d) {
    return _poster(
      d,
      bg: const Color(0xFFFFF0E8),
      accent: const Color(0xFF9574C8),
      title: 'ستايل كيوت',
      subtitle: 'عرض لطيف للمنتج',
      icon: Icons.favorite_rounded,
      imageRadius: 28,
      topDecoration: const _FloatingDecorations(
        emojis: <String>['☁️', '⭐', '🧸', '💗'],
      ),
      body: 'تصميم عملي وسهل التخزين، خفيف ومتين لراحة يومك.',
      action: 'راحة لطفلك',
      features: <_Feature>[
        _Feature(Icons.favorite_rounded, 'راحة لطفلك'),
        _Feature(Icons.star_rounded, 'جودة تدوم'),
        _Feature(Icons.verified_rounded, 'اختيار ذكي'),
      ],
    );
  }

  static Widget _modernSpecs(BuildContext context, ShareProductData d) {
    return _specPoster(
      d,
      bg: const Color(0xFF081A2B),
      accent: const Color(0xFF7EC8FF),
      title: 'ستايل احترافي حديث',
      subtitle: 'تصميم منظم وجذاب',
      dark: true,
    );
  }

  static Widget _flashDeal(BuildContext context, ShareProductData d) {
    return _flashPoster(d);
  }



  static Widget _poster(
      ShareProductData d, {
        required Color bg,
        required Color accent,
        required String title,
        required String subtitle,
        required IconData icon,
        required double imageRadius,
        required String body,
        required String action,
        required List<_Feature> features,
        _FloatingDecorations? topDecoration,
      }) {
    return Container(
      color: bg,
      child: Stack(
        children: <Widget>[
          if (topDecoration != null) Positioned.fill(child: topDecoration),
          Positioned.fill(child: CustomPaint(painter: _SoftDotsPainter(color: accent.withOpacity(0.10)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              Icon(icon, color: accent, size: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: accent, fontSize: 29, fontWeight: FontWeight.w900, height: 0.98),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.66), borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(imageRadius + 8),
                      boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(imageRadius),
                      child: shareNetworkImage(d.imageUrl),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.72), borderRadius: BorderRadius.circular(17)),
                  child: Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: accent.withOpacity(0.88), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.35),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 9),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7,
                  runSpacing: 7,
                  children: features.map((f) => _miniChip(f.icon, f.label, accent)).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(44, 0, 44, 15),
                child: _cta(action, accent, Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _paperPoster(
      ShareProductData d, {
        required Color accent,
        required String title,
        required String subtitle,
        required String action,
        required List<String> notes,
        required String footer,
      }) {
    return Container(
      color: const Color(0xFFFCF6EA),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _GridPainter(color: const Color(0xFFE0D6C7)))),
          const Positioned(left: 4, top: 22, bottom: 18, child: _Holes()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 13),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.70), borderRadius: BorderRadius.circular(5)),
                  child: Text(title, style: const TextStyle(color: Color(0xFF5E564D), fontSize: 14, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: Text(
                  _homeCategoryTitle(d, fallback: 'اختيار مرتب'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF5E564D), fontSize: 30, fontWeight: FontWeight.w900),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6B6257), fontSize: 11.5, fontWeight: FontWeight.w700)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 4, 20, 8),
                  child: ClipRRect(borderRadius: BorderRadius.circular(24), child: shareNetworkImage(d.imageUrl)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 3, 24, 6),
                child: Row(
                  children: notes
                      .map((e) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _note(e, accent),
                    ),
                  ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _infoBox('الحالة', shareHas(d.condition) ? d.condition : 'جيدة جدًا', Icons.search_rounded, accent)),
                    const SizedBox(width: 8),
                    Expanded(child: _infoBox('المكان', shareShortLocation(d.location).isEmpty ? 'قريب منك' : shareShortLocation(d.location), Icons.location_on_rounded, accent)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Text(footer, textAlign: TextAlign.center, style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 8, 48, 14),
                child: _cta(action, accent, Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }



  static Widget _ticketPoster(
      ShareProductData d, {
        required Color accent,
        required Color secondary,
        required String title,
        required String subtitle,
        required String action,
      }) {
    return Container(
      color: accent.withOpacity(0.88),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFFFF7EB), borderRadius: BorderRadius.circular(24)),
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: CustomPaint(painter: _TicketPainter(color: accent.withOpacity(0.18)))),
              Positioned(top: 17, right: 18, child: _tag(subtitle, secondary, Colors.white)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
                    child: Row(
                      children: <Widget>[
                        const Text('عائلة سعيدة\nرحلات أجمل', style: TextStyle(color: Color(0xFFD7A1A0), fontSize: 10, fontWeight: FontWeight.w800, height: 1.2)),
                        const Spacer(),
                        Icon(Icons.flight_takeoff_rounded, color: secondary, size: 18),
                        const SizedBox(width: 7),
                        Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: accent, fontSize: 23, fontWeight: FontWeight.w900))),
                        const Spacer(),
                        const Text('SEAT\n07A', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9B8B82), fontSize: 13, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.70), borderRadius: BorderRadius.circular(8), border: Border.all(color: secondary.withOpacity(0.25))),
                      child: Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: accent, fontSize: 15, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                      child: Transform.rotate(
                        angle: -0.015,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 14, offset: const Offset(0, 7))]),
                          child: ClipRRect(borderRadius: BorderRadius.circular(13), child: shareNetworkImage(d.imageUrl)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 5, 22, 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: _plainFeature('خفيفة', Icons.home, accent)),
                        Expanded(child: _plainFeature('مناسبة للخروج', Icons.child_friendly_rounded, secondary)),
                        Expanded(child: _plainFeature('جاهزة للمشاوير', Icons.favorite_rounded, accent)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(52, 0, 52, 14),
                    child: _cta(action, accent, Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _reviewPoster(
      ShareProductData d, {
        required Color accent,
        required Color secondary,
        required String title,
        required String action,
      }) {
    return Container(
      color: const Color(0xFFF8FFFD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 8,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                    child: shareNetworkImage(d.imageUrl),
                  ),
                ),
                Positioned(top: 14, right: 20, child: _floatingLabel(title, Icons.timer_rounded, secondary, const Color(0xFF3D3A52))),
                Positioned(left: 16, top: 62, child: _floatingText('رفيقك\nكل يوم', accent)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF3D3A52), fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(_locationLine(d), textAlign: TextAlign.center, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w800)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: <BoxShadow>[BoxShadow(color: secondary.withOpacity(0.25), blurRadius: 18)]),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(_friendlyHomeLine(d), maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF3D3A52), fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.35))),
                  Container(width: 1, height: 50, color: accent.withOpacity(0.25)),
                  const SizedBox(width: 12),
                  Column(
                    children: <Widget>[
                      const Text('التقييم العام', style: TextStyle(color: Color(0xFF3D3A52), fontSize: 11, fontWeight: FontWeight.w900)),
                      Text('${d.stars}.8', style: TextStyle(color: accent, fontSize: 32, fontWeight: FontWeight.w900, height: 1.0)),
                      Row(children: List<Widget>.generate(5, (int i) => const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB72B)))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Row(
              children: <Widget>[
                Expanded(child: _ratingCard('الحالة', shareHas(d.condition) ? d.condition : 'نظيفة جدًا', Icons.verified_user_rounded, secondary)),
                const SizedBox(width: 8),
                Expanded(child: _ratingCard('الخفة', 'سهلة الحركة', Icons.home, accent)),
                const SizedBox(width: 8),
                Expanded(child: _ratingCard('الراحة', 'مناسبة للبيت', Icons.chair_rounded, secondary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 14),
            child: _cta(action, accent, Colors.white),
          ),
        ],
      ),
    );
  }


  static Widget _cleanPoster(
      ShareProductData d, {
        required Color accent,
        required String title,
        required String subtitle,
      }) {
    return Container(
      color: const Color(0xFFFBFAF6),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _SoftSpotPainter(color: accent.withOpacity(0.16)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(title, textAlign: TextAlign.left, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 34, fontWeight: FontWeight.w900, height: 1)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
                child: Text(subtitle, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 18, fontWeight: FontWeight.w500)),
              ),
              Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(94, 4, 18, 0), child: shareNetworkImage(d.imageUrl))),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _cleanFeature('عملية', Icons.check_circle_outline_rounded, accent)),
                    const SizedBox(width: 8),
                    Expanded(child: _cleanFeature('خامة جيدة', Icons.verified_user_outlined, accent)),
                    const SizedBox(width: 8),
                    Expanded(child: _cleanFeature('سهلة الحمل', Icons.home, accent)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 6, 26, 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.76), borderRadius: BorderRadius.circular(18), border: Border.all(color: accent.withOpacity(0.20))),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 15, fontWeight: FontWeight.w900))),
                      if (shareHas(sharePriceText(d))) ...<Widget>[
                        const SizedBox(width: 8),
                        Text(sharePriceText(d), style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w900)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _luxuryPoster(
      ShareProductData d, {
        required Color bg,
        required Color accent,
        required Color textColor,
        required String title,
        required String subtitle,
        required String action,
        required bool dark,
      }) {
    return Container(
      color: bg,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _StagePainter(color: accent.withOpacity(dark ? 0.35 : 0.15)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 28),
              Text(title, textAlign: TextAlign.center, style: TextStyle(color: accent, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: dark ? Colors.white70 : textColor.withOpacity(0.85), fontSize: 15, fontWeight: FontWeight.w600)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(42, 18, 42, 0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Container(height: 38, decoration: BoxDecoration(color: accent.withOpacity(0.18), borderRadius: BorderRadius.circular(999), boxShadow: <BoxShadow>[BoxShadow(color: accent.withOpacity(0.25), blurRadius: 28, spreadRadius: 3)])),
                      Padding(padding: const EdgeInsets.only(bottom: 14), child: shareNetworkImage(d.imageUrl)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _callout('تصميم أنيق', 'مظهر عصري', Icons.auto_awesome_rounded, accent, textColor, dark)),
                    const SizedBox(width: 12),
                    Expanded(child: _callout('خفيف وسهل', 'في الحمل والنقل', Icons.home, accent, textColor, dark)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: accent.withOpacity(0.35))), color: dark ? Colors.black.withOpacity(0.20) : Colors.white.withOpacity(0.45)),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(shareHas(sharePriceText(d)) ? sharePriceText(d) : action, style: TextStyle(color: dark ? Colors.white : textColor, fontSize: 12, fontWeight: FontWeight.w800))),
                      Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent)), child: Icon(Icons.workspace_premium_rounded, color: accent)),
                      Expanded(child: Text(d.title, textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.white70 : textColor, fontSize: 11.5, fontWeight: FontWeight.w800))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _popPoster(ShareProductData d) {
    const Color pink = Color(0xFFFF2E86);
    const Color purple = Color(0xFF7C3ACF);
    const Color cyan = Color(0xFF28C7D9);
    const Color yellow = Color(0xFFFFD43B);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[yellow, Colors.white, cyan, pink]),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _PopPainter())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 24),
              const Text('ستايل مرح', textAlign: TextAlign.center, style: TextStyle(color: purple, fontSize: 35, fontWeight: FontWeight.w900, height: 1)),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black54)),
                  child: const Text('شارك منتجك بشكل ممتع', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(42, 20, 42, 10),
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 5), borderRadius: BorderRadius.circular(26), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                child: Row(
                  children: <Widget>[
                    _sticker('Cute', Icons.favorite_rounded, const Color(0xFF75E0B7), Colors.white),
                    const Spacer(),
                    _sticker('Practical', Icons.check_rounded, pink, Colors.white),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                child: Row(
                  children: <Widget>[
                    _sticker('Ready\nto go', Icons.location_on_rounded, yellow, Colors.black),
                    const Spacer(),
                    Flexible(child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  static Widget _specPoster(
      ShareProductData d, {
        required Color bg,
        required Color accent,
        required String title,
        required String subtitle,
        required bool dark,
      }) {
    final Color text = dark ? Colors.white : const Color(0xFF1B2D3E);
    final Color panel = dark ? const Color(0xFF102942) : Colors.white;

    return Container(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(color: panel.withOpacity(dark ? 0.70 : 1), borderRadius: BorderRadius.circular(24), border: Border.all(color: accent.withOpacity(0.30))),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 22),
              Text(title, textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 27, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(color: accent.withOpacity(dark ? 0.22 : 0.75), borderRadius: BorderRadius.circular(999)),
                  child: Text(subtitle, style: TextStyle(color: dark ? accent : Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 5, child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl))),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: <Widget>[
                            _specCallout('قابل للطي بسهولة', 'تصميم عملي يساعد على التخزين', Icons.map_outlined, text, accent, dark),
                            const SizedBox(height: 8),
                            _specCallout('حجم مناسب', 'يوفر المساحة وسهل الحمل', Icons.view_in_ar_rounded, text, accent, dark),
                            const SizedBox(height: 8),
                            _specCallout('راحة وأناقة', 'مناسب للاستخدام اليومي', Icons.chair_rounded, text, accent, dark),
                            const SizedBox(height: 8),
                            _specCallout('جودة موثوقة', shareHas(d.condition) ? d.condition : 'بحالة جيدة', Icons.verified_user_outlined, text, accent, dark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 7, 16, 14),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _bottomSpec('خفيف الوزن', 'سهل الحمل والتنقل', Icons.home, text)),
                    Expanded(child: _bottomSpec('آمن', 'تصميم موثوق', Icons.shield_outlined, text)),
                    Expanded(child: _bottomSpec('عملي يوميًا', 'مناسب للبيت', Icons.check_circle_outline_rounded, text)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _magazinePoster(ShareProductData d) {
    const Color taupe = Color(0xFF8E7E71);
    const Color brown = Color(0xFF3B3029);

    return Container(
      color: const Color(0xFFD5CFC7),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: Opacity(opacity: 0.62, child: shareNetworkImage(d.imageUrl))),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.20))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text('LIFESTYLE', style: TextStyle(color: Colors.white, fontSize: 41, fontWeight: FontWeight.w300, letterSpacing: -1.5)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('SMART CHOICES. STYLISH LIVING.', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: Text('ستايل مجلة', style: const TextStyle(color: brown, fontSize: 32, fontWeight: FontWeight.w900)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(_homeCategoryTitle(d, fallback: 'عرض أنيق ومختلف'), style: const TextStyle(color: brown, fontSize: 18, fontWeight: FontWeight.w500)),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _magazineTextBlock('مفيد في كل لحظة', _friendlyHomeLine(d), taupe)),
                    const SizedBox(width: 16),
                    CircleAvatar(radius: 34, backgroundColor: taupe, child: const Text('STYLE\nTHAT\nSIMPLIFIES', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, height: 1.1))),
                  ],
                ),
              ),
              Container(
                color: brown,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('DESIGNED FOR MODERN HOMES', style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    Text('BEAUTY IN SIMPLICITY', style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _flashPoster(ShareProductData d) {
    const Color yellow = Color(0xFFFFD400);
    const Color dark = Color(0xFF111111);

    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[dark, Color(0xFF1D1D1D), Colors.white])),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _FlashPainter())),
          Positioned(
            top: 20,
            right: 18,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: yellow, shape: BoxShape.circle),
              child: const Text('عرض\nلفترة\nمحدودة!', textAlign: TextAlign.center, style: TextStyle(color: dark, fontSize: 10.5, fontWeight: FontWeight.w900, height: 1.05)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 36, 122, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text('عرض', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, height: 0.9)),
                    Text('جذاب', style: TextStyle(color: yellow, fontSize: 50, fontWeight: FontWeight.w900, height: 0.9)),
                    SizedBox(height: 6),
                    Text('جاهز للمشاركة', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(120, 0, 20, 6),
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: yellow, border: Border.all(color: Colors.white, width: 4), boxShadow: <BoxShadow>[BoxShadow(color: yellow.withOpacity(0.32), blurRadius: 22, offset: const Offset(0, 8))]),
                    child: ClipOval(child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 10),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _dealFeature('تصميم\nقابل للطي', Icons.map_outlined, yellow)),
                    Expanded(child: _dealFeature('خفيف الوزن\nوسهل الحمل', Icons.home, yellow)),
                    Expanded(child: _dealFeature('قفل أمان\nموثوق', Icons.lock_outline_rounded, yellow)),
                    Expanded(child: _dealFeature('تخزين\nعملي', Icons.shopping_bag_outlined, yellow)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(72, 4, 72, 16),
                child: _cta(shareHas(sharePriceText(d)) ? sharePriceText(d) : 'اطلب الآن', yellow, dark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _miniChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.76), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(0.16))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _cta(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999), boxShadow: <BoxShadow>[BoxShadow(color: bg.withOpacity(0.22), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w900))),
          const SizedBox(width: 8),
          Icon(Icons.arrow_back_rounded, color: fg, size: 18),
        ],
      ),
    );
  }

  static Widget _note(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      decoration: BoxDecoration(color: color.withOpacity(0.22), borderRadius: BorderRadius.circular(8), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF5E564D), fontSize: 12, fontWeight: FontWeight.w800, height: 1.25)),
    );
  }

  static Widget _infoBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.55), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.25))),
      child: Column(
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(icon, color: color, size: 15), const SizedBox(width: 5), Text(label, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 5),
          Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF5E564D), fontSize: 10.5, fontWeight: FontWeight.w700, height: 1.25)),
        ],
      ),
    );
  }



  static Widget _plainFeature(String text, IconData icon, Color color) {
    return Column(
      children: <Widget>[
        CircleAvatar(radius: 18, backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 6),
        Text(text, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, height: 1.16)),
      ],
    );
  }

  static Widget _ratingCard(String title, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: <BoxShadow>[BoxShadow(color: color.withOpacity(0.16), blurRadius: 12)]),
      child: Column(
        children: <Widget>[
          CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.55), child: Icon(icon, color: Colors.white, size: 16)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Color(0xFF3D3A52), fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List<Widget>.generate(5, (int i) => const Icon(Icons.star_rounded, size: 10, color: Color(0xFFFFB72B)))),
          const SizedBox(height: 2),
          Text(sub, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF5A5668), fontSize: 9.5, fontWeight: FontWeight.w700, height: 1.16)),
        ],
      ),
    );
  }

  static Widget _cleanFeature(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.75), borderRadius: BorderRadius.circular(999), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 9)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 12, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  static Widget _callout(String title, String sub, IconData icon, Color accent, Color textColor, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: accent.withOpacity(0.55)), color: dark ? Colors.black.withOpacity(0.22) : Colors.white.withOpacity(0.45)),
      child: Row(
        children: <Widget>[
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w900)),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.white70 : textColor.withOpacity(0.75), fontSize: 10, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }

  static Widget _sticker(String text, IconData icon, Color bg, Color fg) {
    return Transform.rotate(
      angle: -0.06,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white, width: 3), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[Icon(icon, color: fg, size: 16), const SizedBox(width: 5), Text(text, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w900, height: 1.0))],
        ),
      ),
    );
  }


  static Widget _specCallout(String title, String sub, IconData icon, Color textColor, Color accent, bool dark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: dark ? Colors.white.withOpacity(0.06) : Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: accent.withOpacity(0.32)), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
        child: Row(
          children: <Widget>[
            CircleAvatar(radius: 16, backgroundColor: accent.withOpacity(0.25), child: Icon(icon, color: accent, size: 16)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor, fontSize: 11.5, fontWeight: FontWeight.w900)),
              Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor.withOpacity(0.72), fontSize: 9.5, fontWeight: FontWeight.w600, height: 1.1)),
            ])),
          ],
        ),
      ),
    );
  }

  static Widget _bottomSpec(String title, String sub, IconData icon, Color color) {
    return Column(
      children: <Widget>[
        Icon(icon, color: color, size: 23),
        const SizedBox(height: 5),
        Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900)),
        Text(sub, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: color.withOpacity(0.78), fontSize: 8.8, fontWeight: FontWeight.w600, height: 1.15)),
      ],
    );
  }

  static Widget _magazineTextBlock(String title, String body, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(radius: 18, backgroundColor: accent, child: const Icon(Icons.eco_rounded, color: Colors.white, size: 17)),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(body, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10.8, fontWeight: FontWeight.w600, height: 1.35)),
      ],
    );
  }

  static Widget _dealFeature(String text, IconData icon, Color color) {
    return Column(
      children: <Widget>[
        CircleAvatar(radius: 18, backgroundColor: Colors.black, child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 6),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 9.5, fontWeight: FontWeight.w900, height: 1.1)),
      ],
    );
  }

  static Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w900, height: 1.1)),
    );
  }

  static Widget _floatingLabel(String text, IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(color: bg.withOpacity(0.85), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white, width: 2)),
      child: Row(children: <Widget>[Text(text, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w900)), const SizedBox(width: 6), Icon(icon, color: fg, size: 18)]),
    );
  }

  static Widget _floatingText(String text, Color color) {
    return Transform.rotate(
      angle: -0.08,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.82), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.20))),
        child: const Text('رفيقك\nكل يوم', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF3D3A52), fontSize: 13, fontWeight: FontWeight.w900, height: 1.15)),
      ),
    );
  }


  static String _homeCategoryTitle(ShareProductData d, {required String fallback}) {
    if (shareHas(d.subCategory)) return d.subCategory;
    if (shareHas(d.category)) return d.category;
    return fallback;
  }

  static String _friendlyHomeLine(ShareProductData d) {
    final String kind = _homeCategoryTitle(d, fallback: 'المنتج');
    final String condition = shareHas(d.condition) ? 'بحالة ${d.condition}' : 'بحالة مناسبة';
    final String location = shareShortLocation(d.location).isEmpty ? '' : ' في ${shareShortLocation(d.location)}';
    return 'أنا $kind $condition$location، جاهز أبدأ حكاية جديدة في بيت جديد.';
  }

  static String _locationLine(ShareProductData d) {
    final String loc = shareShortLocation(d.location);
    if (loc.isEmpty) return 'قريب منك';
    return '$loc · ${shareHas(d.condition) ? d.condition : 'حالة جيدة'}';
  }
}

class _Feature {
  const _Feature(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _FloatingDecorations extends StatelessWidget {
  const _FloatingDecorations({this.emojis = const <String>[], this.icons = const <IconData>[]});

  final List<String> emojis;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    final List<Alignment> alignments = <Alignment>[
      const Alignment(-0.82, -0.86),
      const Alignment(0.80, -0.72),
      const Alignment(-0.74, 0.78),
      const Alignment(0.78, 0.74),
    ];

    final List<Widget> children = <Widget>[];

    for (int i = 0; i < emojis.length; i++) {
      children.add(Align(
        alignment: alignments[i % alignments.length],
        child: Text(emojis[i], style: const TextStyle(fontSize: 34)),
      ));
    }

    for (int i = 0; i < icons.length; i++) {
      children.add(Align(
        alignment: alignments[(i + emojis.length) % alignments.length],
        child: Icon(icons[i], size: 38, color: Colors.white.withOpacity(0.30)),
      ));
    }

    return IgnorePointer(child: Stack(children: children));
  }
}

class _Holes extends StatelessWidget {
  const _Holes();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        16,
            (int i) => Expanded(
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: const Color(0xFFB8A995).withOpacity(0.70), shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftDotsPainter extends CustomPainter {
  const _SoftDotsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color;
    for (double y = 16; y < size.height; y += 40) {
      for (double x = 18; x < size.width; x += 46) {
        canvas.drawCircle(Offset(x, y), 1.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SoftDotsPainter oldDelegate) => oldDelegate.color != color;
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 0.8;

    for (double x = 22; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }

    for (double y = 22; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.color != color;
}

class _RoomPainter extends CustomPainter {
  const _RoomPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(20, 94), Offset(92, 94), p);
    canvas.drawLine(Offset(size.width - 94, 82), Offset(size.width - 18, 82), p);
    canvas.drawLine(Offset(0, size.height * 0.43), Offset(size.width, size.height * 0.43), Paint()..color = color.withOpacity(0.45));
  }

  @override
  bool shouldRepaint(covariant _RoomPainter oldDelegate) => oldDelegate.color != color;
}

class _TicketPainter extends CustomPainter {
  const _TicketPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.4;

    for (double x = 20; x < size.width - 20; x += 16) {
      canvas.drawLine(Offset(x, 62), Offset(x + 7, 62), p);
    }

    for (double y = 88; y < size.height - 80; y += 30) {
      canvas.drawCircle(Offset(22, y), 2.2, p);
    }
  }

  @override
  bool shouldRepaint(covariant _TicketPainter oldDelegate) => oldDelegate.color != color;
}

class _SoftSpotPainter extends CustomPainter {
  const _SoftSpotPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.55, -0.10),
        radius: 0.72,
        colors: <Color>[color, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), p);
  }

  @override
  bool shouldRepaint(covariant _SoftSpotPainter oldDelegate) => oldDelegate.color != color;
}

class _StagePainter extends CustomPainter {
  const _StagePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.20),
        radius: 0.75,
        colors: <Color>[color, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glow);
  }

  @override
  bool shouldRepaint(covariant _StagePainter oldDelegate) => oldDelegate.color != color;
}

class _PopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint dot = Paint()..color = Colors.black.withOpacity(0.30);

    for (double y = 90; y < size.height; y += 12) {
      for (double x = 10; x < 70; x += 12) {
        canvas.drawCircle(Offset(x, y), 1.3, dot);
      }
    }

    final Paint white = Paint()
      ..color = Colors.white.withOpacity(0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final Path p = Path()
      ..moveTo(size.width * 0.65, 80)
      ..quadraticBezierTo(size.width * 0.82, 120, size.width * 0.72, 160);

    canvas.drawPath(p, white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint yellow = Paint()..color = const Color(0xFFFFD400);
    final Path corner = Path()
      ..moveTo(size.width * 0.72, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.28)
      ..close();

    canvas.drawPath(corner, yellow);

    final Paint stripe = Paint()
      ..color = Colors.white.withOpacity(0.09)
      ..strokeWidth = 1.2;

    for (double x = -size.width; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), stripe);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
