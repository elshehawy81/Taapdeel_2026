import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class GeneralShareThemes {
  const GeneralShareThemes._();

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
    ShareThemeDefinition(
      id: 'general_funny_newspaper',
      label: 'جريدة التبديل',
      subtitle: 'خبر طريف عن المنتج',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFB89558), Color(0xFF6B4318)],
      priority: 800,
      builder: _funnyNewspaper,
    ),
    ShareThemeDefinition(
      id: 'general_owner_letter',
      label: 'رسالة المنتج',
      subtitle: 'كلام لطيف من المنتج',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFF4E8D3), Color(0xFFB88A5A)],
      priority: 810,
      builder: _ownerLetter,
    ),
    ShareThemeDefinition(
      id: 'general_taapdeel_air',
      label: 'Taapdeel Air',
      subtitle: 'رحلة لمالك جديد',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF244C73), Color(0xFF10283F)],
      priority: 820,
      builder: _taapdeelAir,
    ),
    ShareThemeDefinition(
      id: 'general_wanted_poster',
      label: 'مطلوب صاحب جديد',
      subtitle: 'ستايل Wanted قديم',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFC49B3A), Color(0xFF7A5A12)],
      priority: 830,
      builder: _wantedPoster,
    ),
    ShareThemeDefinition(
      id: 'general_stop_notice',
      label: 'ورقة مهمة',
      subtitle: 'إعلان طريف وسريع',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF111827), Color(0xFFD55335)],
      priority: 840,
      builder: _stopNotice,
    ),
    ShareThemeDefinition(
      id: 'general_product_story_chat',
      label: 'أنا المنتج',
      subtitle: 'المنتج بيحكي حكايته',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFE8F5EA), Color(0xFFC7A0D9)],
      priority: 850,
      builder: _productStoryChat,
    ),
    ShareThemeDefinition(
      id: 'general_diary_note',
      label: 'مذكرات المنتج',
      subtitle: 'ورقة دفتر لطيفة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFF7EBC7), Color(0xFFB56D35)],
      priority: 860,
      builder: _diaryNote,
    ),
    ShareThemeDefinition(
      id: 'general_polaroid_memo',
      label: 'صورة وملحوظة',
      subtitle: 'ستايل Polaroid مرح',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF232323), Color(0xFFFFE879)],
      priority: 870,
      builder: _polaroidMemo,
    ),
    ShareThemeDefinition(
      id: 'general_evidence_case',
      label: 'ملف التحقيق',
      subtitle: 'ستايل Evidence مضحك',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF1E1E1E), Color(0xFFE4B62F)],
      priority: 880,
      builder: _evidenceCase,
    ),
    ShareThemeDefinition(
      id: 'general_emotion_meter',
      label: 'مقياس المشاعر',
      subtitle: 'مزاج المنتج اليوم',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFFFC6D9), Color(0xFF8E6CCF)],
      priority: 700,
      builder: _emotionMeter,
    ),
    ShareThemeDefinition(
      id: 'general_green_flags_board',
      label: 'جرين فلاج',
      subtitle: 'أسباب تخليك تحبه',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFB8F3CB), Color(0xFF3FAE7A)],
      priority: 701,
      builder: _greenFlagsBoard,
    ),
    ShareThemeDefinition(
      id: 'general_product_cv',
      label: 'CV المنتج',
      subtitle: 'خبراته ومهاراته',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFE6EEF8), Color(0xFF5477B8)],
      priority: 702,
      builder: _productCv,
    ),
    ShareThemeDefinition(
      id: 'general_blind_date',
      label: 'موعد تعارف',
      subtitle: 'تعارف لطيف مع المنتج',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFFFD8DE), Color(0xFFE0788B)],
      priority: 703,
      builder: _blindDateTheme,
    ),
    ShareThemeDefinition(
      id: 'general_therapy_session',
      label: 'جلسة فضفضة',
      subtitle: 'المنتج بيتكلم من قلبه',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFE6DCF9), Color(0xFF9478D0)],
      priority: 704,
      builder: _therapySession,
    ),
    ShareThemeDefinition(
      id: 'general_hotline',
      label: 'خط النجدة',
      subtitle: 'استغاثة كيوت للمنتج',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFFFE4C7), Color(0xFFFF8F5A)],
      priority: 705,
      builder: _hotlineTheme,
    ),
    ShareThemeDefinition(
      id: 'general_movie_poster',
      label: 'فيلم المنتج',
      subtitle: 'بوستر درامي لذيذ',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF202840), Color(0xFFED8E5E)],
      priority: 706,
      builder: _moviePosterTheme,
    ),
    ShareThemeDefinition(
      id: 'general_confession_card',
      label: 'اعترافات المنتج',
      subtitle: 'قال الحقيقة أخيراً',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFF7F0C2), Color(0xFFCD9155)],
      priority: 707,
      builder: _confessionCard,
    ),
    ShareThemeDefinition(
      id: 'general_matchmaker',
      label: 'خاطبة التبديل',
      subtitle: 'نبحث عن الماتش المثالي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFFFD5E8), Color(0xFFA65FD1)],
      priority: 708,
      builder: _matchMakerTheme,
    ),
    ShareThemeDefinition(
      id: 'general_meme_mood',
      label: 'مزاجي الحالي',
      subtitle: 'ستايل meme لطيف',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFFFF077), Color(0xFF2A2A2A)],
      priority: 709,
      builder: _memeMoodTheme,
    ),
    ShareThemeDefinition(
      id: 'general_elegant_warm',
      label: 'عرض أنيق',
      subtitle: 'هادئ وراقي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFBFA07A), Color(0xFF7A5A35)],
      priority: 900,
      builder: _elegantWarm,
    ),
    ShareThemeDefinition(
      id: 'general_luxury_gold',
      label: 'ستايل فاخر',
      subtitle: 'ذهبي مميز',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF5A3A00), Color(0xFF1A1000)],
      priority: 910,
      builder: _luxuryGold,
    ),
    ShareThemeDefinition(
      id: 'general_quick_review',
      label: 'كارت مراجعة',
      subtitle: 'ملخص سريع',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF4A8A7A), Color(0xFF2A5A50)],
      priority: 920,
      builder: _quickReview,
    ),
    ShareThemeDefinition(
      id: 'general_cute_soft',
      label: 'ستايل كيوت',
      subtitle: 'ألوان لطيفة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFBB7FCC), Color(0xFF8A4BAD)],
      priority: 930,
      builder: _cuteSoft,
    ),
  ];

  static Widget _funnyNewspaper(BuildContext context, ShareProductData d) {
    const Color paper = Color(0xFFF4E8D3);
    const Color ink = Color(0xFF2C1605);
    const Color line = Color(0xFF8A6A3B);
    const Color red = Color(0xFFD64B34);

    return Container(
      color: paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(height: 5, color: line),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: Row(
              children: <Widget>[
                Text(
                  shareShortLocation(d.location).isEmpty ? 'اليوم' : shareShortLocation(d.location),
                  style: const TextStyle(color: line, fontSize: 9, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const Text(
                  'جريدة التبديل',
                  style: TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'serif'),
                ),
              ],
            ),
          ),
          Container(height: 1.2, color: line),
          Expanded(
            flex: 6,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _headlineFor(d),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w900, height: 1.25),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _newspaperBody(d),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: ink, fontSize: 10.5, fontWeight: FontWeight.w700, height: 1.55),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, color: line.withOpacity(0.65)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(9),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: shareNetworkImage(d.imageUrl),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1.2, color: line),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                children: <Widget>[
                  const Text(
                    '— إعلانات التبديل —',
                    style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 1, color: line.withOpacity(0.7)),
                  const SizedBox(height: 9),
                  Expanded(
                    child: Text(
                      _adText(d),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700, height: 1.55),
                    ),
                  ),
                  if (shareHas(sharePriceText(d)))
                    Text(
                      'نطاق التبديل: ${sharePriceText(d)}',
                      style: const TextStyle(color: red, fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                ],
              ),
            ),
          ),
          Container(height: 5, color: line),
        ],
      ),
    );
  }

  static Widget _ownerLetter(BuildContext context, ShareProductData d) {
    const Color paper = Color(0xFFFDF8EF);
    const Color ink = Color(0xFF3A2415);
    const Color red = Color(0xFFD75035);
    const Color blue = Color(0xFF245AC8);

    return Container(
      color: const Color(0xFF111111),
      child: Column(
        children: <Widget>[
          ClipPath(
            clipper: _EnvelopeClipper(),
            child: Container(height: 36, color: const Color(0xFFE8DFC9)),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: paper,
              child: Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(child: shareNetworkImage(d.imageUrl)),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 80,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: <Color>[paper, Colors.transparent],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'إلى صاحبي الجديد،',
                                style: const TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Text(
                                  _letterText(d),
                                  maxLines: 7,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: ink, fontSize: 12.3, fontWeight: FontWeight.w700, height: 1.65),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'بحبك، ${_kindLabel(d)} 💙',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                shareHas(sharePriceText(d)) ? 'ملاحظة: ${sharePriceText(d)}' : 'ملاحظة: جاهز لرحلة جديدة',
                                style: const TextStyle(color: red, fontSize: 10.5, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 100,
                    left: 18,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: red, border: Border.all(color: Colors.white, width: 3)),
                      child: Center(
                        child: Text(
                          shareHas(sharePriceText(d)) ? sharePriceText(d).replaceAll('ج.م', '').trim() : 'جاهز',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, height: 1.1),
                        ),
                      ),
                    ),
                  ),
                  Positioned(top: 126, right: 16, child: Icon(Icons.favorite_rounded, color: blue.withOpacity(0.85), size: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _taapdeelAir(BuildContext context, ShareProductData d) {
    const Color navy = Color(0xFF173A5A);
    const Color navy2 = Color(0xFF10283F);
    const Color green = Color(0xFF4CE07B);
    const Color light = Color(0xFFB8D0E8);

    return Container(
      color: navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(border: Border.all(color: light.withOpacity(0.35)), borderRadius: BorderRadius.circular(5)),
                  child: const Text('SWAP CLASS', style: TextStyle(color: light, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                ),
                const Spacer(),
                const Text('T A A P D E E L   A I R', style: TextStyle(color: light, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 3)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      const Text('NEW', style: TextStyle(color: green, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text('صاحبها الجديد', style: TextStyle(color: light.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Icon(Icons.flight_rounded, color: light.withOpacity(0.55), size: 28),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      const Text('SAR', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 8),
                      Text('رحلتها الأولى', style: TextStyle(color: light.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: shareNetworkImage(d.imageUrl)),
                Positioned.fill(child: Container(color: navy.withOpacity(0.10))),
              ],
            ),
          ),
          Container(
            color: navy2,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _boardingInfo('الحالة', shareHas(d.condition) ? d.condition : 'جاهز جداً'),
                    _boardingInfo('الموقع', shareShortLocation(d.location).isEmpty ? 'قريب منك' : shareShortLocation(d.location)),
                    _boardingInfo('النطاق', shareHas(sharePriceText(d)) ? sharePriceText(d) : 'مفتوح'),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(height: 42, child: CustomPaint(painter: _BarsPainter(color: light.withOpacity(0.8)))),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(8)),
                  child: const Center(
                    child: Text('✈ احجزي مقعدك — طلب تبديل', style: TextStyle(color: Color(0xFF04180B), fontSize: 14, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _wantedPoster(BuildContext context, ShareProductData d) {
    const Color paper = Color(0xFFF7E8B8);
    const Color brown = Color(0xFF7D5B16);
    const Color ink = Color(0xFF4A260E);
    const Color red = Color(0xFFD45134);

    return Container(
      color: brown,
      padding: const EdgeInsets.all(9),
      child: Container(
        decoration: BoxDecoration(color: paper, border: Border.all(color: brown.withOpacity(0.65), width: 1.4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 8),
            const Text('WANTED', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 6, fontFamily: 'serif')),
            Container(margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8), height: 2, color: brown),
            const Text('مطلوب — صاحب جديد', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 10.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Expanded(
              flex: 6,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 46),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(border: Border.all(color: brown, width: 4)),
                  child: shareNetworkImage(d.imageUrl),
                ),
              ),
            ),
            Container(margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8), height: 2, color: brown),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            Container(margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8), height: 2, color: brown),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(_wantedText(d), maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: ink, fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.45)),
            ),
            const SizedBox(height: 8),
            Container(
              color: red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: <Widget>[
                  const Text('المكافأة', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  Text(shareHas(sharePriceText(d)) ? sharePriceText(d) : 'طلب تبديل', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFF1C7), fontSize: 25, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('أي معلومات تؤدي لتبديل ممتع فوراً!', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _stopNotice(BuildContext context, ShareProductData d) {
    const Color paper = Color(0xFFF7ECD5);
    const Color navy = Color(0xFF14182A);
    const Color red = Color(0xFFD65135);
    const Color ink = Color(0xFF42270D);

    return Container(
      color: paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: navy,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            child: Row(
              children: <Widget>[
                Text('برقية ${_caseNo(d)}', style: const TextStyle(color: Color(0xFFE7D39F), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const Spacer(),
                const Text('TAAPDEEL', style: TextStyle(color: Color(0xFFE7D39F), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3)),
              ],
            ),
          ),
          Container(color: red, padding: const EdgeInsets.symmetric(vertical: 7), child: const Center(child: Text('— ورقة مهمة —', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD5BC7C))),
              child: Row(
                children: <Widget>[
                  const Text('من', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_ownerNick(d), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 10.5, fontWeight: FontWeight.w800))),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: ClipRRect(borderRadius: BorderRadius.circular(2), child: shareNetworkImage(d.imageUrl)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 10),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800, height: 1.55),
                        children: <TextSpan>[
                          const TextSpan(text: 'لدي '),
                          TextSpan(text: d.title, style: const TextStyle(color: red, fontWeight: FontWeight.w900)),
                          const TextSpan(text: ' حقيقية جداً '),
                          const TextSpan(text: 'STOP ', style: TextStyle(color: red, fontWeight: FontWeight.w900)),
                          TextSpan(text: '${_friendlyStatus(d)} '),
                          const TextSpan(text: 'STOP '),
                          const TextSpan(text: 'جاهزة لانتقال محترم إلى صاحب جديد. '),
                          const TextSpan(text: 'STOP', style: TextStyle(color: red, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 1, color: const Color(0xFFD5BC7C)),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text('العنوان: تبديل، مصر', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 10.5, fontWeight: FontWeight.w700))),
                      Text(shareHas(sharePriceText(d)) ? sharePriceText(d) : 'مجانا 😅', style: const TextStyle(color: red, fontSize: 12, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _productStoryChat(BuildContext context, ShareProductData d) {
    const Color bgTop = Color(0xFFE8F4EC);
    const Color bgBottom = Color(0xFFF3E9F6);
    const Color purple = Color(0xFF6E4A82);
    const Color green = Color(0xFF8AC795);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[bgTop, bgBottom],
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
            child: Row(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFBFD3C2),
                    child: Text(_avatarEmoji(d), style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        _kindLabel(d),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: purple,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _productHandle(d),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: purple.withOpacity(0.55),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: shareNetworkImage(d.imageUrl)),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[bgBottom, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: constraints.maxWidth - 36,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _chatBubble(_chatLineOne(d), alignRight: true),
                          const SizedBox(height: 6),
                          _chatBubble(_chatLineTwo(d), alignRight: false, emoji: '😊'),
                          const SizedBox(height: 6),
                          _chatBubble('عايز اروح بيت تاني وأفرح تاني — تبدليني؟ 🙏', alignRight: true),
                          const SizedBox(height: 7),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 6,
                            runSpacing: 6,
                            children: <Widget>[
                              if (shareHas(d.condition))
                                sharePill(
                                  text: '✓ ${d.condition}',
                                  bg: const Color(0xFFCDEECF),
                                  fg: const Color(0xFF2F7A3D),
                                ),
                              if (shareHas(d.usage))
                                sharePill(
                                  text: d.usage,
                                  bg: const Color(0xFFD3F0FF),
                                  fg: const Color(0xFF2873A5),
                                ),
                              if (shareHas(sharePriceText(d)))
                                sharePill(
                                  text: sharePriceText(d),
                                  bg: const Color(0xFFE9C7EF),
                                  fg: purple,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: <Color>[green, Color(0xFFC690D6)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'عايزة ازور بيتك — طلب تبديل 💙',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _diaryNote(BuildContext context, ShareProductData d) {
    const Color paper = Color(0xFFF6EBCB);
    const Color line = Color(0xFFD9C597);
    const Color red = Color(0xFFE05A42);
    const Color ink = Color(0xFF4A2A18);

    return Container(
      color: paper,
      child: CustomPaint(
        painter: _NotebookPainter(lineColor: line, marginColor: red.withOpacity(0.55)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(_arabicDate(), textAlign: TextAlign.right, style: const TextStyle(color: ink, fontSize: 10.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 118,
                    height: 102,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: const Color(0xFFF7E29D), border: Border.all(color: const Color(0xFFD1A743)), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))]),
                    child: shareNetworkImage(d.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اتذكرت إني اشتريت ${_kindLabel(d)} من مدة، ${shareHas(d.condition) ? d.condition : 'لسه شكله لطيف'} ومابستعملهوش كتير.',
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800, height: 1.55),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Text(
                  _diaryText(d),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w700, height: 1.75),
                ),
              ),
              Row(
                children: <Widget>[
                  const Text('💙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shareHas(sharePriceText(d)) ? 'السعر بين ${sharePriceText(d)} — عادل إن شاء الله' : 'تبديل لطيف — عادل إن شاء الله',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w900, backgroundColor: Color(0xFFFFEE8A)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _polaroidMemo(BuildContext context, ShareProductData d) {
    const Color dark = Color(0xFF111111);
    const Color note = Color(0xFFFFEA78);
    const Color ink = Color(0xFF1F1A13);

    return Container(
      color: dark,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _SubtleDotsPainter(color: Colors.white.withOpacity(0.04)))),
          Positioned(
            top: 16,
            left: 30,
            right: 30,
            bottom: 92,
            child: Transform.rotate(
              angle: -0.045,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(child: shareNetworkImage(d.imageUrl)),
                    const SizedBox(height: 12),
                    Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      <String>[shareHas(sharePriceText(d)) ? sharePriceText(d) : '', shareShortLocation(d.location)].where(shareHas).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ink.withOpacity(0.55), fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 120,
            right: 120,
            child: Container(height: 18, decoration: BoxDecoration(color: const Color(0xFFF8E5A7), borderRadius: BorderRadius.circular(2))),
          ),
          Positioned(
            left: 22,
            right: 52,
            bottom: 28,
            child: Transform.rotate(
              angle: -0.02,
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                color: note,
                child: Text(_stickyNoteText(d), maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w900, height: 1.45)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _evidenceCase(BuildContext context, ShareProductData d) {
    const Color dark = Color(0xFF191919);
    const Color darker = Color(0xFF0F0F0F);
    const Color yellow = Color(0xFFF4C437);
    const Color grey = Color(0xFF8B8B8B);

    return Container(
      color: dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: yellow,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: const Text('TAAPDEEL EVIDENCE · DO NOT CROSS · TAAPDEEL EVIDENCE', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF111111), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 3)),
          ),
          Expanded(
            flex: 7,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: ColorFiltered(colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation), child: shareNetworkImage(d.imageUrl))),
                Positioned.fill(child: Container(color: Colors.black.withOpacity(0.32))),
                Positioned(
                  right: 18,
                  bottom: 20,
                  child: Transform.rotate(
                    angle: 0.04,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      color: yellow,
                      child: Column(
                        children: <Widget>[
                          Text('E-${_caseNo(d)}', style: const TextStyle(color: darker, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const Text('EVIDENCE', style: TextStyle(color: darker, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('CASE FILE #${_caseNo(d)} · OPEN', textAlign: TextAlign.center, style: const TextStyle(color: grey, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 3)),
                  const SizedBox(height: 14),
                  const Text('الشاهد الرئيسي', textAlign: TextAlign.right, style: TextStyle(color: yellow, fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(_evidenceText(d), maxLines: 4, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFFD4D4D4), fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.6)),
                  const SizedBox(height: 14),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 2.55,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        _evidenceBox('LOCATION', shareShortLocation(d.location).isEmpty ? 'UNKNOWN' : shareShortLocation(d.location).toUpperCase()),
                        _evidenceBox('CONDITION', shareHas(d.condition) ? d.condition.toUpperCase() : 'GOOD'),
                        _evidenceBox('SUBSECTION', shareHas(d.subCategory) ? d.subCategory.toUpperCase() : 'NONE'),
                        _evidenceBox('SWAP RANGE', shareHas(sharePriceText(d)) ? sharePriceText(d) : 'OPEN'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomPaint(size: const Size(double.infinity, 22), painter: _CautionStripePainter()),
        ],
      ),
    );
  }

  static Widget _emotionMeter(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFFFF1F5);
    const Color ink = Color(0xFF6D3F74);
    const Color soft = Color(0xFFD8C4F1);

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFD9E8),
                  ),
                  child: const Center(child: Text('🥹', style: TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('مقياس المشاعر', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900)),
                      SizedBox(height: 2),
                      Text('المشاعر النهاردة: محتاج مالك جديد', style: TextStyle(color: Color(0xFF9A74A7), fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(height: 165, child: shareNetworkImage(d.imageUrl)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Text('😶', style: TextStyle(fontSize: 20)),
                Text('🙂', style: TextStyle(fontSize: 20)),
                Text('😊', style: TextStyle(fontSize: 20)),
                Text('🥰', style: TextStyle(fontSize: 20)),
                Text('🤩', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: const LinearProgressIndicator(
                value: 0.78,
                minHeight: 10,
                backgroundColor: Color(0xFFE8DAF6),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8A56B2)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              d.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: ink, fontSize: 19, fontWeight: FontWeight.w900, height: 1.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'حالتي الآن: ${_friendlyStatus(d)}، ومعدل الحنين لصاحب جديد مرتفع جدًا. باختصار: لو شفتني وما خدتنيش، هزعل شوية 😌',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF7A6485), fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.45),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                if (shareHas(d.condition)) sharePill(text: d.condition, bg: const Color(0xFFEFE5FB), fg: ink, icon: Icons.favorite_rounded),
                if (shareHas(d.location)) sharePill(text: shareShortLocation(d.location), bg: const Color(0xFFFFDDE6), fg: ink, icon: Icons.location_on_rounded),
                if (shareHas(sharePriceText(d))) sharePill(text: sharePriceText(d), bg: soft, fg: ink, icon: Icons.sell_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _greenFlagsBoard(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFF2FFF6);
    const Color green = Color(0xFF2C8C5A);
    const Color deep = Color(0xFF155136);

    Widget point(String text) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: Color(0xFFD9F7E5), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 13, color: green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: deep, fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.35)),
          ),
        ],
      );
    }

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: const Color(0xFFDDF7E6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: <Widget>[
                Text('✅', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Expanded(child: Text('جرين فلاج فقط', style: TextStyle(color: deep, fontSize: 17, fontWeight: FontWeight.w900))),
                Text('no red flags', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(height: 120, child: shareNetworkImage(d.imageUrl)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: deep, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Column(
              children: <Widget>[
                point('حالته ${shareHas(d.condition) ? d.condition : 'كويسة جدًا'} — وده جرين فلاج محترم.'),
                const SizedBox(height: 8),
                point('سهل التبديل عليه ومش داخل يتشرط كثير 😌'),
                const SizedBox(height: 8),
                point('جاهز يدي صاحبه الجديد راحة نفسية ورضا فوري.'),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('جرين فلاج بامتياز', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                  Text(shareHas(sharePriceText(d)) ? sharePriceText(d) : 'جاهز للتبديل', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _productCv(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFF8FBFF);
    const Color navy = Color(0xFF395A95);
    const Color soft = Color(0xFFDCE7FA);

    Widget statCard(String title, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: soft)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF7A8DB3), fontSize: 9.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: navy, fontSize: 12, fontWeight: FontWeight.w900, height: 1.2)),
          ],
        ),
      );
    }

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      Text('CV المنتج', style: TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('جاهز لوظيفة: يسعد صاحبه الجديد', style: TextStyle(color: Color(0xFF7A8DB3), fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(color: soft, shape: BoxShape.circle),
                  child: const Icon(Icons.badge_rounded, color: navy),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(height: 120, child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      statCard('المسمى الوظيفي', d.title),
                      const SizedBox(height: 8),
                      statCard('سنوات الخبرة', shareHas(d.usage) ? d.usage : 'متعاون من أول يوم'),
                      const SizedBox(height: 8),
                      statCard('مكان العمل', shareHas(d.location) ? shareShortLocation(d.location) : 'مرن جدًا'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'ملخص مهني: ${_kindLabel(d)} مؤدبة، ${_friendlyStatus(d)}، وتبحث عن فرصة انتقال محترمة إلى بيت جديد يقدّرها 👌',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: navy, fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.45),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(child: statCard('المهارة الأبرز', 'يعيش معاك بدون دراما')),
                const SizedBox(width: 8),
                Expanded(child: statCard('التوقعات', shareHas(sharePriceText(d)) ? sharePriceText(d) : 'تبديل مناسب')),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('متاح للمقابلة فورًا', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900))),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _blindDateTheme(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFFFF4F6);
    const Color pink = Color(0xFFD66C86);
    const Color plum = Color(0xFF7C3A55);

    Widget qa(String q, String a) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: pink.withOpacity(0.08)),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 54,
              child: Text(
                q,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: pink,
                  fontSize: 9.2,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                a,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: plum,
                  fontSize: 9.8,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: bg,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: const <Widget>[
                    Text('💘', style: TextStyle(fontSize: 17)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'موعد تعارف على خفيف',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: plum,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(height: 94, child: shareNetworkImage(d.imageUrl)),
                ),
                const SizedBox(height: 7),
                Text(
                  d.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: plum,
                    fontSize: 15.2,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 7),
                qa('الاسم', _kindLabel(d)),
                qa('بحب', 'الاهتمام وصاحب يقدّر قيمتي.'),
                qa('بكره', 'أفضل مركون من غير استفادة 😅'),
                qa(
                  'بدور على',
                  shareHas(d.location)
                      ? 'صاحب جديد في ${shareShortLocation(d.location)}'
                      : 'صاحب جديد محترم وبشوش',
                ),
                //const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: pink,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'لو في كيميا — اطلب تبديل',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.8,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        shareHas(sharePriceText(d)) ? sharePriceText(d) : 'ready',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.8,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _therapySession(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFF6F0FF);
    const Color purple = Color(0xFF8C63C7);
    const Color deep = Color(0xFF5D3A8A);

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_kindLabel(d), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: deep, fontSize: 18, fontWeight: FontWeight.w900)),

                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE2D8F7)),
                  child: Center(child: Text(_avatarEmoji(d), style: const TextStyle(fontSize: 22))),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            child: SizedBox(height: 120, child: shareNetworkImage(d.imageUrl)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: <Widget>[
                _chatBubble('أنا ${_kindLabel(d)} وبصراحة حاسس إني جاهز لمرحلة جديدة بس محتاج حد يفهمني 😌', alignRight: true, emoji: '🛋️'),
                const SizedBox(height: 10),
                _chatBubble('نفسي أبطل أكون مُخزّن أو مركون... أنا لسه فيّ خير والله 🥹', alignRight: false, emoji: '💬'),
                const SizedBox(height: 10),
                _chatBubble('لو أنت لطيف وبتحب الحاجات الشاطرة — تعالى نتبادل 🤝', alignRight: true, emoji: '✨'),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                if (shareHas(d.condition)) sharePill(text: d.condition, bg: const Color(0xFFD8EEF7), fg: deep),
                if (shareHas(d.location)) sharePill(text: shareShortLocation(d.location), bg: const Color(0xFFF6DCEC), fg: deep),
                if (shareHas(sharePriceText(d))) sharePill(text: sharePriceText(d), bg: const Color(0xFFD8F0D9), fg: deep),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _hotlineTheme(BuildContext context, ShareProductData d) {
    const Color cream = Color(0xFFFFF7EE);
    const Color orange = Color(0xFFE6783A);
    const Color brown = Color(0xFF6E4023);

    return Container(
      color: cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: const Color(0xFFFFE4CF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const <Widget>[
                Icon(Icons.support_agent_rounded, color: orange),
                SizedBox(width: 8),
                Expanded(child: Text('خط نجدة المنتج', style: TextStyle(color: brown, fontSize: 15, fontWeight: FontWeight.w800))),
                Text('24/7', style: TextStyle(color: orange, fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFFFD3BA))),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(color: Color(0xFFFFE8D6), shape: BoxShape.circle),
                    child: const Icon(Icons.phone_in_talk_rounded, color: orange),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('الحالة: أحتاج صاحب جديد', style: const TextStyle(color: brown, fontSize: 13, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        const Text('الوضع تحت السيطرة... بس لو اتأخرت ممكن أزعل 🤭', style: TextStyle(color: Color(0xFFA76A49), fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(height: 90, child: shareNetworkImage(d.imageUrl)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: brown, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                _therapyInfoRow('سبب البلاغ', 'منتج لطيف بقاله شوية مستني التبديل'),
                const SizedBox(height: 7),
                _therapyInfoRow('الاستجابة المطلوبة', 'حد يجي ياخده بحب ويقدّره'),
                const SizedBox(height: 7),
                _therapyInfoRow('آخر موقع', shareHas(d.location) ? shareShortLocation(d.location) : 'قريب منك'),
              ],
            ),
          ),
          //const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(shareHas(sharePriceText(d)) ? 'تم حل البلاغ على ${sharePriceText(d)}' : 'تم فتح البلاغ للتبديل', style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800))),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _moviePosterTheme(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFF131826);
    const Color orange = Color(0xFFEF8D57);
    const Color white = Color(0xFFF6F1EA);

    return Container(
      color: bg,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: CustomPaint(painter: _SubtleDotsPainter(color: Colors.white24)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              const Center(child: Text('A TAAPDEEL ORIGINAL', style: TextStyle(color: Color(0xFF8E98AF), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2))),
              const SizedBox(height: 8),
              const Center(child: Text('فيلم المنتج', style: TextStyle(color: white, fontSize: 22, fontWeight: FontWeight.w900))),
              const Center(child: Text('دراما خفيفة بنكهة التبديل', style: TextStyle(color: orange, fontSize: 11, fontWeight: FontWeight.w700))),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(height: 165, child: shareNetworkImage(d.imageUrl)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(d.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.15)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Text(
                  'بطولة ${_kindLabel(d)} في دور المنتج اللي تعب من الركنة، ويبحث عن نهاية سعيدة مع صاحب جديد 💫',
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFBFC7D8), fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.45),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(children: const <Widget>[Icon(Icons.star_rounded, color: Color(0xFFFFC44D), size: 18), Icon(Icons.star_rounded, color: Color(0xFFFFC44D), size: 18), Icon(Icons.star_rounded, color: Color(0xFFFFC44D), size: 18), Icon(Icons.star_rounded, color: Color(0xFFFFC44D), size: 18), Icon(Icons.star_half_rounded, color: Color(0xFFFFC44D), size: 18)]),
                    Text(shareHas(sharePriceText(d)) ? sharePriceText(d) : 'NOW SHOWING', style: const TextStyle(color: orange, fontSize: 12, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('نهاية الفيلم عندك — اطلب تبديل', style: TextStyle(color: bg, fontSize: 13, fontWeight: FontWeight.w900))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _confessionCard(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFFFFBED);
    const Color ink = Color(0xFF5A442A);
    const Color accent = Color(0xFFD18F4E);

    return Container(
      color: bg,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _NotebookPainter(lineColor: Color(0xFFE9E0B8), marginColor: Color(0xFFE19D77)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: const <Widget>[
                    Expanded(child: Text('اعترافات المنتج', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900))),
                    Text('🤫', style: TextStyle(fontSize: 22)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(height: 120, child: shareNetworkImage(d.imageUrl)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('أعترف إني ${shareHas(d.condition) ? d.condition : 'محترم جدًا'}', style: const TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text('وأعترف كمان إني ${shareHas(d.usage) ? d.usage : 'لسه فيّ استخدام كثير'}', style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800, height: 1.3)),
                          const SizedBox(height: 8),
                          const Text('والحقيقة؟ أنا زعلان بس بأدب... عايز حد يقدّرني بدل ما أفضل مركون 🙈', style: TextStyle(color: ink, fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.45)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFFFF2B8), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    shareHas(sharePriceText(d)) ? 'السعر بين ${sharePriceText(d)} — وبوعدك إني أكون صفقة مريحة.' : 'مستعد لتبديل لطيف يرضي الطرفين.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: ink, fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('وقّعت بالرضا: ${_kindLabel(d)} ✍️', textAlign: TextAlign.center, style: const TextStyle(color: accent, fontSize: 12.5, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _matchMakerTheme(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFFFF4FB);
    const Color purple = Color(0xFFA054C8);
    const Color pink = Color(0xFFE97AA6);
    const Color ink = Color(0xFF6E3F87);

    Widget card(String title, List<String> items, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.35))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...items.map((String e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.favorite_rounded, size: 12, color: color),
                    const SizedBox(width: 5),
                    Expanded(child: Text(e, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 10.8, fontWeight: FontWeight.w700, height: 1.3))),
                  ],
                ),
              )),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: const <Widget>[
                Icon(Icons.auto_awesome_rounded, color: pink),
                SizedBox(width: 8),
                Expanded(child: Text('خاطبة التبديل', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(height: 150, child: shareNetworkImage(d.imageUrl)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                card('يحب', <String>['الاهتمام والذوق', 'بيت جديد ونظيف', 'صاحب يعرف قيمته'], purple),
                const SizedBox(width: 8),
                card('يبحث عن', <String>['تبديل مناسب', shareHas(d.location) ? shareShortLocation(d.location) : 'موقع مناسب', shareHas(sharePriceText(d)) ? sharePriceText(d) : 'اتفاق لطيف'], pink),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: <Color>[Color(0xFFFD9CC2), Color(0xFFB677E3)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('نسبة التوافق', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                  Text('98%', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Center(child: Text('إحساسنا بيقول: هتكونوا مناسبين لبعض 💘', style: TextStyle(color: ink, fontSize: 11.5, fontWeight: FontWeight.w800))),
          ),
        ],
      ),
    );
  }

  static Widget _memeMoodTheme(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFF171717);
    const Color yellow = Color(0xFFFFEA58);
    const Color white = Color(0xFFFDFDFD);

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(12)),
              child: Text(
                'أنا لما ألاقي صاحب جديد: 😎',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 175, width: double.infinity, child: shareNetworkImage(d.imageUrl)),
                  const SizedBox(height: 10),
                  Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(
                    <String>[shareHas(sharePriceText(d)) ? sharePriceText(d) : '', shareShortLocation(d.location)].where(shareHas).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Transform.translate(
              offset: const Offset(-6, -14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(color: yellow, boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 10)]),
                  child: const Text('حالتي تمام 💙\nبس من غير صاحب جديد هبتدي أعمل دراما ✨', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800, height: 1.35)),
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _reactionChip('😂 طيب جدًا'),
                _reactionChip('😍 يستاهل'),
                _reactionChip('🔥 لقطة'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _therapyInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFDCC7))),
      child: Row(
        children: <Widget>[
          Text(label, style: const TextStyle(color: Color(0xFFE6783A), fontSize: 10.5, fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF6E4023), fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.3))),
        ],
      ),
    );
  }

  static Widget _reactionChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white24)),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
  static Widget _elegantWarm(BuildContext context, ShareProductData d) {
    const Color cream = Color(0xFFF5EFE6);
    const Color brown = Color(0xFF6B4F2A);
    const Color dark = Color(0xFF2C1A0A);

    return Container(
      color: cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: const Color(0xFF8B6A45),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('TAAPDEEL', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                Text('PRE-LOVED, LOVED AGAIN', style: TextStyle(color: Colors.white60, fontSize: 7.5, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ],
            ),
          ),
          Expanded(
            flex: 11,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: shareNetworkImage(d.imageUrl)),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 90,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[cream, Colors.transparent]),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: sharePill(
                    text: shareHas(d.subCategory) ? d.subCategory : d.category,
                    bg: const Color(0xFFEDE0C8),
                    fg: brown,
                    icon: Icons.category_rounded,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: dark, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                if (shareHas(d.condition)) sharePill(text: d.condition, icon: Icons.verified_rounded, bg: const Color(0xFFEDE0C8), fg: brown),
                if (shareHas(d.usage)) sharePill(text: d.usage, icon: Icons.timelapse_rounded, bg: const Color(0xFFDDE8D4), fg: const Color(0xFF3A5A30)),
                if (d.isNew) sharePill(text: 'جديد', icon: Icons.new_releases_rounded, bg: const Color(0xFFE8D0D4), fg: const Color(0xFF7A2A30)),
                if (shareHas(d.brand)) sharePill(text: d.brand, icon: Icons.workspace_premium_rounded, bg: const Color(0xFFE0D4EC), fg: const Color(0xFF4A2A6A)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: <Widget>[
                if (shareHas(sharePriceText(d))) Text(sharePriceText(d), style: const TextStyle(color: brown, fontSize: 26, fontWeight: FontWeight.w900)),
                const Spacer(),
                if (shareHas(d.location)) Flexible(child: Text(shareShortLocation(d.location), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: brown, fontSize: 11, fontWeight: FontWeight.w800))),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 14),
            color: dark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: shareBrandFooter(),
          ),
        ],
      ),
    );
  }

  static Widget _luxuryGold(BuildContext context, ShareProductData d) {
    const Color gold = Color(0xFFC9A84C);
    const Color divider = Color(0xFF3A2800);

    return Container(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _SpotlightPainter())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.workspace_premium_rounded, color: gold, size: 15),
                  SizedBox(width: 6),
                  Text('TAAPDEEL PREMIUM', style: TextStyle(color: gold, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
                  SizedBox(width: 6),
                  Icon(Icons.workspace_premium_rounded, color: gold, size: 15),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8, horizontal: 50), child: Divider(color: divider, height: 1)),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 12,
                          width: 180,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), boxShadow: <BoxShadow>[BoxShadow(color: gold.withOpacity(0.45), blurRadius: 35, spreadRadius: 8)]),
                        ),
                      ),
                      ClipRRect(borderRadius: BorderRadius.circular(16), child: shareNetworkImage(d.imageUrl)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
                child: Row(children: <Widget>[const Expanded(child: Divider(color: divider, height: 1)), const SizedBox(width: 8), Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: gold)), const SizedBox(width: 8), const Expanded(child: Divider(color: divider, height: 1))]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFEDD98A), fontSize: 19, fontWeight: FontWeight.w900, height: 1.2)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (shareHas(d.condition)) _goldFeature(d.condition, Icons.verified_rounded),
                    if (shareHas(d.usage)) _goldFeature(d.usage, Icons.timelapse_rounded),
                    if (shareHas(d.location)) _goldFeature(shareShortLocation(d.location), Icons.location_on_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (shareHas(sharePriceText(d))) Center(child: Text(sharePriceText(d), style: TextStyle(color: gold, fontSize: 28, fontWeight: FontWeight.w900, shadows: <Shadow>[Shadow(color: gold.withOpacity(0.6), blurRadius: 22)]))),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(border: Border.all(color: divider), borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text('راحة الاختيار، أناقة القيمة', style: TextStyle(color: Color(0xFF9A7A3A), fontSize: 9, fontWeight: FontWeight.w700)), Text('Taapdeel', style: TextStyle(color: gold, fontSize: 9, fontWeight: FontWeight.w900))]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _quickReview(BuildContext context, ShareProductData d) {
    const Color mint = Color(0xFF3AB87A);
    const Color dark = Color(0xFF1A4A30);
    const Color bg = Color(0xFFF0FAF6);

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 8,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: shareNetworkImage(d.imageUrl)),
                Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 100, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[bg, Colors.transparent])))),
                Positioned(top: 12, right: 12, child: sharePill(text: 'مراجعة سريعة', bg: Colors.white.withOpacity(0.92), fg: mint, icon: Icons.timer_outlined)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: dark, fontSize: 17, fontWeight: FontWeight.w900, height: 1.2)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: <Widget>[...List<Widget>.generate(5, (int i) => Icon(i < d.stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 17, color: const Color(0xFFFFB800))), const SizedBox(width: 6), Expanded(child: Text(shareHas(d.condition) ? d.condition : 'حالة ممتازة', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF3A7A5A), fontSize: 11, fontWeight: FontWeight.w700))), if (shareHas(sharePriceText(d))) sharePill(text: sharePriceText(d), bg: mint, fg: Colors.white)]),
          ),
          const SizedBox(height: 8),
          if (shareHas(d.description))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: mint.withOpacity(0.2))),
                child: Text(d.description.length > 80 ? '${d.description.substring(0, 80)}...' : d.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF2A4A35), fontSize: 11, fontWeight: FontWeight.w700, height: 1.45)),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: <Color>[mint, Color(0xFF1A7A50)]), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('اكتشف المنتج', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900))),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _cuteSoft(BuildContext context, ShareProductData d) {
    const Color purple = Color(0xFF8A3AC0);

    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFFEDD8F5), Color(0xFFFAF0FE), Color(0xFFF0E0FA)])),
      child: Stack(
        children: <Widget>[
          const Positioned(top: 14, right: 18, child: Text('✦', style: TextStyle(color: Color(0xFFCC88E0), fontSize: 18))),
          const Positioned(top: 40, left: 22, child: Text('♥', style: TextStyle(color: Color(0xFFFF9EC4), fontSize: 15))),
          const Positioned(bottom: 80, left: 14, child: Text('♥', style: TextStyle(color: Color(0xFFFF9EC4), fontSize: 11))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              Center(child: sharePill(text: 'ستايل كيوت ✨', bg: Colors.white.withOpacity(0.88), fg: purple)),
              const SizedBox(height: 10),
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: <BoxShadow>[BoxShadow(color: const Color(0xFFCC88E0).withOpacity(0.3), blurRadius: 22, offset: const Offset(0, 8))]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(22), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6A2A8A), fontSize: 16, fontWeight: FontWeight.w900, height: 1.2)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: <Widget>[
                  if (shareHas(d.condition)) sharePill(text: d.condition, bg: const Color(0xFFF5C8FF), fg: purple),
                  if (shareHas(sharePriceText(d))) sharePill(text: sharePriceText(d), bg: const Color(0xFFFFD8E8), fg: const Color(0xFFAA3A6A)),
                  if (shareHas(d.location)) sharePill(text: shareShortLocation(d.location), bg: const Color(0xFFC8E8FF), fg: const Color(0xFF2A6AAA)),
                ]),
              ),
              const Spacer(),
              Center(child: Text('Taapdeel ♥', style: TextStyle(color: purple.withOpacity(0.55), fontSize: 9, fontWeight: FontWeight.w800))),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _boardingInfo(String label, String value) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF7FA0BE), fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _chatBubble(String text, {required bool alignRight, String? emoji}) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF6E4A82), fontSize: 11.2, fontWeight: FontWeight.w800, height: 1.25)),
          ),
          if (emoji != null)
            Positioned(
              top: -8,
              right: alignRight ? null : -8,
              left: alignRight ? -8 : null,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
        ],
      ),
    );
  }

  static Widget _evidenceBox(String label, String value) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF3D3D3D)), color: const Color(0xFF202020)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF806A1A), fontSize: 8, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFFF4C437), fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _goldFeature(String text, IconData icon) {
    const Color gold = Color(0xFFC9A84C);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF4A3800)), color: Colors.black), child: Icon(icon, size: 17, color: gold)),
        const SizedBox(height: 5),
        SizedBox(width: 72, child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9A7A3A), fontSize: 10, fontWeight: FontWeight.w700, height: 1.2))),
      ],
    );
  }

  static String _kindLabel(ShareProductData d) {
    if (shareHas(d.subCategory)) return d.subCategory;
    if (shareHas(d.category)) return d.category;
    return 'المنتج';
  }

  static String _ownerNick(ShareProductData d) {
    final String loc = shareShortLocation(d.location);
    if (loc.isEmpty) return 'صاحبه الحالي';
    return 'صاحبه الحالي من $loc';
  }

  static String _friendlyStatus(ShareProductData d) {
    if (shareHas(d.condition)) return 'حالته ${d.condition}';
    if (d.isNew) return 'لسه جديد';
    return 'لسه فيه خير كتير';
  }

  static String _headlineFor(ShareProductData d) {
    return '${_kindLabel(d)} تبحث عن صاحب جديد';
  }

  static String _newspaperBody(ShareProductData d) {
    final String status = _friendlyStatus(d);
    final String loc = shareShortLocation(d.location);
    final String place = loc.isEmpty ? 'قريب منك' : 'في $loc';
    return 'بعد رحلة هادئة مع صاحبها الأول، وصلت ${_kindLabel(d)} إلى لحظة مهمة: بداية جديدة مع صاحب يقدرها. $status وموجودة $place.';
  }

  static String _adText(ShareProductData d) {
    final String usage = shareHas(d.usage) ? '، ${d.usage}' : '';
    final String condition = shareHas(d.condition) ? d.condition : 'بحالة طيبة';
    return 'للتبديل: ${d.title}، $condition$usage، مع جرعة اهتمام حقيقية أو إكسسوار في نفس النطاق.';
  }

  static String _letterText(ShareProductData d) {
    final String status = _friendlyStatus(d);
    return 'أنا ${_kindLabel(d)} اللي لسه عندي حكايات كتير. $status، ومحتاج بيت جديد يحبني ويستفيد مني. مش بطلب كتير، بس فرصة لطيفة وصاحب يقدرني ✨';
  }

  static String _wantedText(ShareProductData d) {
    final String loc = shareShortLocation(d.location);
    return '${_kindLabel(d)} لطيفة، $loc، ${_friendlyStatus(d)}. آخر مشاهدة على تبديل، لا تشكل أي خطر — لطيفة جداً 😅';
  }

  static String _chatLineOne(ShareProductData d) {
    return 'أنا ${_kindLabel(d)} كنت بتشغل/بتستخدم بكل حب، والآن يوم تالت بسأل: مين؟';
  }

  static String _chatLineTwo(ShareProductData d) {
    return 'اللي هيخدني هيمشي لوحده — وأنا وحيدة في الأوضة 🥺';
  }

  static String _diaryText(ShareProductData d) {
    return 'قررت أحطها على تبديل — مش عشان أتخلص منها، لكن عشان تلاقي حد يحتاجها أكتر مني. هي مش مجرد ${_kindLabel(d)}، دي فرصة صغيرة لبيت جديد وقصة جديدة 😅';
  }

  static String _stickyNoteText(ShareProductData d) {
    return 'خدوني تمام 💙 مش هنام في الدولاب كتير. تستاهل واحدة تحبها ✨';
  }

  static String _evidenceText(ShareProductData d) {
    return 'وجدنا ${_kindLabel(d)} في ${_friendlyStatus(d)}، لا خدوش مؤثرة، لا آثار إهمال، فقط رغبة صادقة في البحث عن صاحب جديد.';
  }

  static String _avatarEmoji(ShareProductData d) {
    final String text = '${d.category} ${d.subCategory} ${d.title}'.toLowerCase();
    if (text.contains('لعب') || text.contains('طفل') || text.contains('baby') || text.contains('toy')) return '👶';
    if (text.contains('كتاب') || text.contains('book')) return '📚';
    if (text.contains('رياض') || text.contains('كرة') || text.contains('sport')) return '🏆';
    if (text.contains('الكتر') || text.contains('إلكتر') || text.contains('mobile')) return '📱';
    if (text.contains('شنطة') || text.contains('حقيبة') || text.contains('bag')) return '👜';
    return '✨';
  }

  static String _productHandle(ShareProductData d) {
    final String base = _kindLabel(d).replaceAll(' ', '_');
    final String suffix = _caseNo(d);
    return '${base}_$suffix@taapdeel';
  }

  static String _caseNo(ShareProductData d) {
    final String seed = d.title.isEmpty ? d.idSeed : d.title;
    int sum = 0;
    for (int i = 0; i < seed.length; i++) {
      sum += seed.codeUnitAt(i);
    }
    return (sum % 900 + 100).toString();
  }

  static String _arabicDate() {
    final DateTime n = DateTime.now();
    const List<String> days = <String>['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    const List<String> months = <String>['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final String day = days[n.weekday - 1];
    final String month = months[n.month - 1];
    return '$day، ${n.day} $month ${n.year}';
  }

}

extension _ShareDataSeed on ShareProductData {
  String get idSeed => '$title$category$subCategory$price';
}

class _SpotlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.65,
        colors: <Color>[const Color(0xFF3A2800).withOpacity(0.6), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnvelopeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color;
    const int count = 44;
    final double gap = size.width / count;
    for (int i = 0; i < count; i++) {
      final double h = 8 + ((i * 7) % 27).toDouble();
      final double x = i * gap;
      canvas.drawRect(Rect.fromLTWH(x, size.height - h, 2, h), p);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) => oldDelegate.color != color;
}

class _NotebookPainter extends CustomPainter {
  const _NotebookPainter({required this.lineColor, required this.marginColor});

  final Color lineColor;
  final Color marginColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (double y = 54; y < size.height; y += 31) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    final Paint marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(38, 0), Offset(38, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant _NotebookPainter oldDelegate) => false;
}

class _SubtleDotsPainter extends CustomPainter {
  const _SubtleDotsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color;
    for (double y = 0; y < size.height; y += 16) {
      for (double x = 0; x < size.width; x += 16) {
        canvas.drawCircle(Offset(x, y), 1.1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SubtleDotsPainter oldDelegate) => oldDelegate.color != color;
}

class _CautionStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint yellow = Paint()..color = const Color(0xFFF4C437);
    final Paint black = Paint()..color = const Color(0xFF111111);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), yellow);
    for (double x = -30; x < size.width + 30; x += 42) {
      final Path path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 20, 0)
        ..lineTo(x + 50, size.height)
        ..lineTo(x + 30, size.height)
        ..close();
      canvas.drawPath(path, black);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
