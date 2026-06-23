import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class BooksShareThemes {
  const BooksShareThemes._();

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
    ShareThemeDefinition(
      id: 'books_library_detective',
      label: 'محقق المكتبة',
      subtitle: 'ملف كتاب يبحث عن قارئ',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFF2E2A24), Color(0xFFC7974A)],
      priority: 1,
      builder: _libraryDetective,
    ),
    ShareThemeDefinition(
      id: 'books_reading_passport',
      label: 'جواز سفر القراءة',
      subtitle: 'رحلة كتاب لقارئ جديد',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFF244C73), Color(0xFF7BB0D6)],
      priority: 2,
      builder: _readingPassport,
    ),
    ShareThemeDefinition(
      id: 'books_book_cafe',
      label: 'مقهى القراءة',
      subtitle: 'قهوة وكتاب وحكاية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFFB98756), Color(0xFF5C3721)],
      priority: 3,
      builder: _bookCafe,
    ),
    ShareThemeDefinition(
      id: 'books_story_portal',
      label: 'بوابة الحكاية',
      subtitle: 'ادخل لعالم جديد',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFF6E52B8), Color(0xFF251A47)],
      priority: 4,
      builder: _storyPortal,
    ),
    ShareThemeDefinition(
      id: 'books_study_mission',
      label: 'مهمة مذاكرة',
      subtitle: 'للكتب التعليمية والدراسية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books, ShareThemeGroup.school],
      gradient: const <Color>[Color(0xFF4A7A6A), Color(0xFF1E4A3A)],
      priority: 5,
      builder: _studyMission,
    ),
    ShareThemeDefinition(
      id: 'books_bookmark_review',
      label: 'علامة صفحة',
      subtitle: 'ملخص أنيق للكتاب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFFF1C84B), Color(0xFF8E5C1C)],
      priority: 6,
      builder: _bookmarkReview,
    ),
    ShareThemeDefinition(
      id: 'books_shelf_rescue',
      label: 'إنقاذ من الرف',
      subtitle: 'كتاب محتاج يخرج للنور',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFFEAD9B2), Color(0xFF8B6037)],
      priority: 7,
      builder: _shelfRescue,
    ),
    ShareThemeDefinition(
      id: 'books_quote_of_the_day',
      label: 'اقتباس اليوم',
      subtitle: 'كارت أدبي جذاب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFFF7EBC7), Color(0xFFBE6A4B)],
      priority: 8,
      builder: _quoteOfTheDay,
    ),
    ShareThemeDefinition(
      id: 'books_book_club_invite',
      label: 'دعوة نادي الكتاب',
      subtitle: 'تعالى نقرأها سوا',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFFFFC6D8), Color(0xFF7D5FA6)],
      priority: 9,
      builder: _bookClubInvite,
    ),
    ShareThemeDefinition(
      id: 'books_chapter_ticket',
      label: 'تذكرة فصل جديد',
      subtitle: 'Book ticket style',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFFFFE1A6), Color(0xFF334D6E)],
      priority: 10,
      builder: _chapterTicket,
    ),
    ShareThemeDefinition(
      id: 'books_islamic_arch_library',
      label: 'مكتبة إسلامية',
      subtitle: 'ستايل هادئ للكتب الشرعية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFF0E5A4F), Color(0xFFD8B56D)],
      priority: 11,
      builder: _islamicArchLibrary,
    ),
    ShareThemeDefinition(
      id: 'books_islamic_manuscript',
      label: 'مخطوطة علم',
      subtitle: 'ستايل تراثي راقي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFF7B4E21), Color(0xFFF1D8A7)],
      priority: 12,
      builder: _islamicManuscript,
    ),
    ShareThemeDefinition(
      id: 'books_islamic_knowledge_card',
      label: 'نور المعرفة',
      subtitle: 'كارت أنيق للكتب الإسلامية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFF102A43), Color(0xFF48B89F)],
      priority: 13,
      builder: _islamicKnowledgeCard,
    ),
    ShareThemeDefinition(
      id: 'books_warm_story',
      label: 'حكاية دافئة',
      subtitle: 'للكتب والروايات',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books],
      gradient: const <Color>[Color(0xFF9A6A3A), Color(0xFF4A2A12)],
      priority: 40,
      builder: _warmStory,
    ),
    ShareThemeDefinition(
      id: 'books_smart_notes',
      label: 'ملاحظات ذكية',
      subtitle: 'علمي ودراسي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.books, ShareThemeGroup.school],
      gradient: const <Color>[Color(0xFF4A7A6A), Color(0xFF1E4A3A)],
      priority: 50,
      builder: _smartNotes,
    ),
  ];

  static Widget _libraryDetective(BuildContext context, ShareProductData d) {
    const Color dark = Color(0xFF25211B);
    const Color paper = Color(0xFFF3E4C5);
    const Color gold = Color(0xFFC7974A);
    const Color ink = Color(0xFF342515);

    return Container(
      color: dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: gold,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(
              children: const <Widget>[
                Icon(Icons.search_rounded, size: 15, color: dark),
                SizedBox(width: 6),
                Expanded(child: Text('ملف تحقيق مكتبي', style: TextStyle(color: dark, fontSize: 13, fontWeight: FontWeight.w900))),
                Text('CASE: BOOK', style: TextStyle(color: dark, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: paper, borderRadius: BorderRadius.circular(18), border: Border.all(color: gold, width: 2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 120,
                        height: 132,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withOpacity(0.25))),
                        child: shareNetworkImage(d.imageUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            const Text('المشتبه به اللطيف', textAlign: TextAlign.right, style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 7),
                            Text(d.title, maxLines: 4, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w900, height: 1.2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _caseRow('نوع القضية', shareHas(d.subCategory) ? d.subCategory : 'كتاب يستحق القراءة', ink, gold),
                  _caseRow('حالة الدليل', shareHas(d.condition) ? d.condition : 'واضح ومفيد', ink, gold),
                  _caseRow('آخر ظهور', shareShortLocation(d.location).isEmpty ? 'على رف هادئ' : shareShortLocation(d.location), ink, gold),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(color: dark, borderRadius: BorderRadius.circular(12)),
                    child: Text(_bookHook(d, 'القضية محتاجة قارئ جديد يحل اللغز ويكمل الحكاية.'), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.w900, height: 1.25)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _readingPassport(BuildContext context, ShareProductData d) {
    const Color navy = Color(0xFF244C73);
    const Color sky = Color(0xFFBFD8EE);
    const Color stamp = Color(0xFFE27455);
    return Container(
      color: const Color(0xFFEAF4FF),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: navy.withOpacity(0.28), width: 1.5)),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(color: navy, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                child: Row(
                  children: const <Widget>[
                    Text('READING PASSPORT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    Spacer(),
                    Icon(Icons.flight_takeoff_rounded, color: sky, size: 18),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ClipRRect(borderRadius: BorderRadius.circular(18), child: shareNetworkImage(d.imageUrl)),
                      ),
                      const SizedBox(height: 10),
                      Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w900, height: 1.12)),
                      const SizedBox(height: 7),
                      Row(
                        children: <Widget>[
                          Expanded(child: _passportField('FROM', shareShortLocation(d.location).isEmpty ? 'Old Shelf' : shareShortLocation(d.location), navy)),
                          const SizedBox(width: 8),
                          Expanded(child: _passportField('TO', 'New Reader', navy)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Transform.rotate(
                        angle: -0.05,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(border: Border.all(color: stamp, width: 2), borderRadius: BorderRadius.circular(8)),
                          child: Text(shareHas(sharePriceText(d)) ? 'APPROVED · ${sharePriceText(d)}' : 'APPROVED TO SWAP', style: const TextStyle(color: stamp, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _bookCafe(BuildContext context, ShareProductData d) {
    const Color cream = Color(0xFFFFF4E6);
    const Color coffee = Color(0xFF6A3F25);
    const Color latte = Color(0xFFE3B67F);
    return Container(
      color: cream,
      child: Stack(
        children: <Widget>[
          const Positioned(top: 18, right: 18, child: Icon(Icons.local_cafe_rounded, color: latte, size: 44)),
          const Positioned(bottom: 30, left: 18, child: Icon(Icons.menu_book_rounded, color: Color(0x33A56A3C), size: 54)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Center(child: Text('BOOK CAFÉ', style: TextStyle(color: coffee, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: <BoxShadow>[BoxShadow(color: coffee.withOpacity(0.16), blurRadius: 18, offset: const Offset(0, 8))]),
                  child: ClipRRect(borderRadius: BorderRadius.circular(20), child: SizedBox(height: 200, child: shareNetworkImage(d.imageUrl))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: coffee, fontSize: 19, fontWeight: FontWeight.w900, height: 1.12)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text('طبق اليوم: كتاب لطيف مع رشة فضول وقارئ جديد ☕', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: coffee.withOpacity(0.75), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.35)),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _miniCafeCard(Icons.auto_stories_rounded, shareHas(d.subCategory) ? d.subCategory : 'قراءة ممتعة', coffee)),
                    const SizedBox(width: 8),
                    Expanded(child: _miniCafeCard(Icons.payments_rounded, shareHas(sharePriceText(d)) ? sharePriceText(d) : 'تبديل', coffee)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _storyPortal(BuildContext context, ShareProductData d) {
    const Color purple = Color(0xFF6E52B8);
    const Color deep = Color(0xFF1F173A);
    const Color glow = Color(0xFFFFD66B);
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFF251A47), Color(0xFF110C24)])),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _BookStarsPainter())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              const Text('بوابة الحكاية', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('كل كتاب باب لعالم جديد', textAlign: TextAlign.center, style: TextStyle(color: glow, fontSize: 11, fontWeight: FontWeight.w700)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 16, 26, 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(colors: <Color>[glow.withOpacity(0.8), purple.withOpacity(0.35)]),
                      boxShadow: <BoxShadow>[BoxShadow(color: glow.withOpacity(0.25), blurRadius: 28, spreadRadius: 4)],
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(90), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, height: 1.15)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.09), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.14))),
                  child: Text(_bookHook(d, 'افتح الصفحة الأولى واترك الباقي للحكاية.'), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFEFE7FF), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.35)),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _studyMission(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFF3F8F1);
    const Color green = Color(0xFF3F6F4A);
    const Color yellow = Color(0xFFFFDA73);
    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: const <Widget>[
                Icon(Icons.task_alt_rounded, color: yellow, size: 18),
                SizedBox(width: 7),
                Expanded(child: Text('مهمة مذاكرة جاهزة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
                Text('+XP', style: TextStyle(color: yellow, fontSize: 13, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _missionStep('1', 'افتح الكتاب'),
                        _missionStep('2', 'تعلم فكرة'),
                        _missionStep('3', 'شاركه مع غيرك'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(12)),
                          child: const Text('MISSION READY', textAlign: TextAlign.center, style: TextStyle(color: green, fontSize: 10.5, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 5),
            child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: green, fontSize: 18, fontWeight: FontWeight.w900, height: 1.15)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                if (shareHas(d.condition)) sharePill(text: d.condition, bg: Colors.white, fg: green, icon: Icons.check_circle_rounded),
                if (shareHas(sharePriceText(d))) sharePill(text: sharePriceText(d), bg: const Color(0xFFE4EFE0), fg: green, icon: Icons.payments_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bookmarkReview(BuildContext context, ShareProductData d) {
    const Color paper = Color(0xFFFFF8E4);
    const Color brown = Color(0xFF6D441F);
    const Color gold = Color(0xFFF1C84B);
    return Container(
      color: paper,
      child: Stack(
        children: <Widget>[
          Positioned(top: 0, right: 28, child: CustomPaint(size: const Size(44, 96), painter: _BookmarkPainter(color: gold))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              const Text('علامة صفحة', textAlign: TextAlign.center, style: TextStyle(color: brown, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 5))]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(13), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: brown, fontSize: 18, fontWeight: FontWeight.w900, height: 1.14)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _bookmarkStat('الفئة', shareHas(d.subCategory) ? d.subCategory : 'كتاب', brown)),
                    const SizedBox(width: 8),
                    Expanded(child: _bookmarkStat('التقييم', '${d.stars}/5', brown)),
                    const SizedBox(width: 8),
                    Expanded(child: _bookmarkStat('القيمة', shareHas(sharePriceText(d)) ? sharePriceText(d) : 'تبديل', brown)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _shelfRescue(BuildContext context, ShareProductData d) {
    const Color wall = Color(0xFFEAD9B2);
    const Color shelf = Color(0xFF8B6037);
    const Color ink = Color(0xFF4D3018);
    return Container(
      color: wall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 15),
          const Text('نداء من الرف', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 23, fontWeight: FontWeight.w900)),
          const Text('هذا الكتاب لم يُخلق للغبار', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8B6037), fontSize: 10.5, fontWeight: FontWeight.w800)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Positioned.fill(
                    bottom: 18,
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl)),
                  ),
                  Container(height: 30, decoration: BoxDecoration(color: shelf, borderRadius: BorderRadius.circular(8), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 6))])),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFFFFF4D8), borderRadius: BorderRadius.circular(16), border: Border.all(color: shelf.withOpacity(0.35))),
              child: Column(
                children: <Widget>[
                  Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900, height: 1.15)),
                  const SizedBox(height: 7),
                  Text('أنقذني من الرف… وخد معايا قصة تستاهل تتقري 📚', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: ink.withOpacity(0.75), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.35)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  static Widget _quoteOfTheDay(BuildContext context, ShareProductData d) {
    const Color paper = Color(0xFFFFF7E8);
    const Color red = Color(0xFFBE6A4B);
    const Color ink = Color(0xFF483025);
    return Container(
      color: paper,
      child: CustomPaint(
        painter: _SoftLinesPainter(color: red.withOpacity(0.12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Row(
                children: const <Widget>[
                  Text('“', style: TextStyle(color: red, fontSize: 40, fontWeight: FontWeight.w900, height: 0.7)),
                  SizedBox(width: 6),
                  Expanded(child: Text('اقتباس اليوم', style: TextStyle(color: ink, fontSize: 21, fontWeight: FontWeight.w900))),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900, height: 1.15)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.78), borderRadius: BorderRadius.circular(16)),
                child: Text('اقتباس غير رسمي من الكتاب: «القارئ الجديد سيعرف قيمتي من أول صفحة» ✨', maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800, height: 1.45)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Row(
                children: <Widget>[
                  if (shareHas(sharePriceText(d))) sharePill(text: sharePriceText(d), bg: const Color(0xFFFFE2D7), fg: red, icon: Icons.sell_rounded),
                  const Spacer(),
                  sharePill(text: shareHas(d.condition) ? d.condition : 'جاهز للقراءة', bg: Colors.white, fg: red, icon: Icons.favorite_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _bookClubInvite(BuildContext context, ShareProductData d) {
    const Color bg = Color(0xFFFFF1F7);
    const Color purple = Color(0xFF7D5FA6);
    const Color pink = Color(0xFFE57AA4);
    return Container(
      color: bg,
      child: Stack(
        children: <Widget>[
          const Positioned(top: 18, right: 24, child: Text('📚', style: TextStyle(fontSize: 28))),
          const Positioned(top: 28, left: 25, child: Text('💬', style: TextStyle(fontSize: 22))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              const Text('دعوة نادي الكتاب', textAlign: TextAlign.center, style: TextStyle(color: purple, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('ضيف جديد على قعدة القراءة', textAlign: TextAlign.center, style: TextStyle(color: pink, fontSize: 11, fontWeight: FontWeight.w800)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 14, 28, 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), border: Border.all(color: pink.withOpacity(0.35), width: 2)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: purple, fontSize: 18, fontWeight: FontWeight.w900, height: 1.15)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Text('مين يحب يضيفه لمكتبته؟ الكتاب جاهز يدخل النادي ويبدأ نقاش لطيف 😄', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: purple, fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.35)),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _chapterTicket(BuildContext context, ShareProductData d) {
    const Color blue = Color(0xFF334D6E);
    const Color cream = Color(0xFFFFE1A6);
    const Color ink = Color(0xFF27364A);
    return Container(
      color: const Color(0xFFEAF0F7),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(22), border: Border.all(color: blue, width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: const BoxDecoration(color: blue, borderRadius: BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19))),
                child: Row(
                  children: const <Widget>[
                    Text('TICKET TO NEXT CHAPTER', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                    Spacer(),
                    Icon(Icons.confirmation_number_rounded, color: cream, size: 17),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 5, child: ClipRRect(borderRadius: BorderRadius.circular(18), child: shareNetworkImage(d.imageUrl))),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _ticketInfo('SECTION', shareHas(d.subCategory) ? d.subCategory : 'BOOKS'),
                            const SizedBox(height: 8),
                            _ticketInfo('SEAT', shareHas(d.condition) ? d.condition : 'READY'),
                            const SizedBox(height: 8),
                            _ticketInfo('VALUE', shareHas(sharePriceText(d)) ? sharePriceText(d) : 'SWAP'),
                            const Spacer(),
                            Container(height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withOpacity(0.55), borderRadius: BorderRadius.circular(12)), child: const Text('READ\nMORE', textAlign: TextAlign.center, style: TextStyle(color: blue, fontSize: 13, fontWeight: FontWeight.w900, height: 1.0))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w900, height: 1.15)),
              ),
              const SizedBox(height: 10),
              CustomPaint(size: const Size(double.infinity, 16), painter: _TicketDotsPainter(color: blue.withOpacity(0.55))),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _islamicArchLibrary(BuildContext context, ShareProductData d) {
    const Color deepGreen = Color(0xFF0E5A4F);
    const Color darkGreen = Color(0xFF07352F);
    const Color gold = Color(0xFFD8B56D);
    const Color cream = Color(0xFFF8F1DF);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[darkGreen, deepGreen],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicPatternPainter(color: Colors.white24),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              const Text(
                'مكتبة إسلامية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: gold,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'كتاب نافع يبحث عن قارئ ينتفع به',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cream,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 16, 26, 10),
                  child: CustomPaint(
                    painter: _IslamicArchPainter(
                      fillColor: cream,
                      borderColor: gold,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 34, 14, 14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: shareNetworkImage(d.imageUrl),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  d.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: gold.withOpacity(0.45)),
                  ),
                  child: Text(
                    _islamicBookHook(d, 'فرصة جميلة لكتاب ينتقل من رف إلى قارئ جديد يقدّر العلم والمعرفة.'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: cream,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: sharePill(
                        text: shareHas(d.subCategory) ? d.subCategory : 'كتب إسلامية',
                        bg: cream,
                        fg: deepGreen,
                        icon: Icons.menu_book_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (shareHas(sharePriceText(d)))
                      sharePill(
                        text: sharePriceText(d),
                        bg: gold,
                        fg: darkGreen,
                        icon: Icons.payments_rounded,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _islamicManuscript(BuildContext context, ShareProductData d) {
    const Color paper = Color(0xFFF4E2BE);
    const Color ink = Color(0xFF4B2D12);
    const Color brown = Color(0xFF7B4E21);
    const Color gold = Color(0xFFD6A94B);

    return Container(
      color: const Color(0xFF5A3518),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Container(
          decoration: BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold, width: 2),
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: _ManuscriptLinesPainter(
                    lineColor: brown.withOpacity(0.13),
                    ornamentColor: gold.withOpacity(0.22),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: brown,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: const <Widget>[
                        Icon(Icons.auto_stories_rounded, color: gold, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'مخطوطة علم',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          'علم ينتقل',
                          style: TextStyle(
                            color: gold,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E8),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: brown.withOpacity(0.25)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: shareNetworkImage(d.imageUrl),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: Text(
                      d.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'كتاب ينتظر قارئًا جديدًا يفتح صفحاته بعناية ويستفيد من محتواه.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ink.withOpacity(0.72),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 11, 18, 15),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 7,
                      runSpacing: 7,
                      children: <Widget>[
                        sharePill(
                          text: shareHas(d.condition) ? d.condition : 'جاهز للقراءة',
                          bg: const Color(0xFFFFF8E8),
                          fg: brown,
                          icon: Icons.verified_rounded,
                        ),
                        if (shareHas(d.location))
                          sharePill(
                            text: shareShortLocation(d.location),
                            bg: const Color(0xFFFFF8E8),
                            fg: brown,
                            icon: Icons.location_on_rounded,
                          ),
                        if (shareHas(sharePriceText(d)))
                          sharePill(
                            text: sharePriceText(d),
                            bg: gold,
                            fg: ink,
                            icon: Icons.sell_rounded,
                          ),
                      ],
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

  static Widget _islamicKnowledgeCard(BuildContext context, ShareProductData d) {
    const Color navy = Color(0xFF102A43);
    const Color teal = Color(0xFF1B8A78);
    const Color mint = Color(0xFFE6FFF8);
    const Color gold = Color(0xFFE8C46A);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[navy, Color(0xFF0B4B55), teal],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -34,
            right: -28,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: gold.withOpacity(0.22)),
              ),
            ),
          ),
          Positioned(
            bottom: -44,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: mint.withOpacity(0.12)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 16, 17, 8),
                child: Row(
                  children: const <Widget>[
                    Icon(Icons.lightbulb_rounded, color: gold, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'نور المعرفة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'TAAPDEEL BOOKS',
                      style: TextStyle(
                        color: mint,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: mint.withOpacity(0.16)),
                  ),
                  child: const Text(
                    'كتاب إسلامي نافع يمكن أن يبدأ رحلة جديدة مع قارئ جديد',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mint,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 15, 24, 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: gold.withOpacity(0.22),
                              blurRadius: 26,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: gold, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: shareNetworkImage(d.imageUrl),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                child: Text(
                  d.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _knowledgeMiniBox(
                        'الفئة',
                        shareHas(d.subCategory) ? d.subCategory : 'كتب إسلامية',
                        gold,
                        mint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _knowledgeMiniBox(
                        'الحالة',
                        shareHas(d.condition) ? d.condition : 'مناسبة للقراءة',
                        gold,
                        mint,
                      ),
                    ),
                    if (shareHas(sharePriceText(d))) ...<Widget>[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _knowledgeMiniBox(
                          'القيمة',
                          sharePriceText(d),
                          gold,
                          mint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      'شاركه مع من ينتفع به',
                      style: TextStyle(
                        color: navy,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _warmStory(BuildContext context, ShareProductData d) => _bookBase(
    d,
    bg: const Color(0xFFF6EFE4),
    accent: const Color(0xFF6B4324),
    title: 'حكاية تستحق قارئ جديد',
    header: 'TAAPDEEL BOOKS',
    icon: Icons.menu_book_rounded,
  );

  static Widget _smartNotes(BuildContext context, ShareProductData d) => _bookBase(
    d,
    bg: const Color(0xFFF3F7EF),
    accent: const Color(0xFF3F6F4A),
    title: 'اختيار ذكي للقارئ',
    header: 'SMART READING',
    icon: Icons.auto_stories_rounded,
  );

  static Widget _bookBase(
      ShareProductData d, {
        required Color bg,
        required Color accent,
        required String title,
        required String header,
        required IconData icon,
      }) {
    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: accent,
            child: Row(
              children: <Widget>[
                Text(header, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const Spacer(),
                const Text('READ IT. SHARE IT.', style: TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: <Widget>[
                Icon(icon, color: accent, size: 24),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: accent.withOpacity(0.18)), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))]),
                child: ClipRRect(borderRadius: BorderRadius.circular(16), child: shareNetworkImage(d.imageUrl)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
            child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF1D2A20), fontSize: 18, fontWeight: FontWeight.w900, height: 1.15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Wrap(spacing: 7, runSpacing: 7, children: <Widget>[
              sharePill(text: shareHas(d.subCategory) ? d.subCategory : d.category, bg: Colors.white, fg: accent, icon: Icons.category_rounded),
              if (shareHas(d.condition)) sharePill(text: d.condition, bg: Colors.white, fg: accent, icon: Icons.check_circle_rounded),
              if (shareHas(sharePriceText(d))) sharePill(text: sharePriceText(d), bg: accent.withOpacity(0.12), fg: accent, icon: Icons.payments_rounded),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('اكتشفه على تبديل', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900))),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _caseRow(String label, String value, Color ink, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.55), borderRadius: BorderRadius.circular(10), border: Border.all(color: accent.withOpacity(0.35))),
      child: Row(
        children: <Widget>[
          Text(label, style: TextStyle(color: ink.withOpacity(0.62), fontSize: 9.5, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _passportField(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFEAF4FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: TextStyle(color: color.withOpacity(0.55), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _miniCafeCard(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.78), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _missionStep(String no, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
      child: Row(
        children: <Widget>[
          CircleAvatar(radius: 12, backgroundColor: const Color(0xFF3F6F4A), child: Text(no, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
          const SizedBox(width: 7),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF3F6F4A), fontSize: 10.5, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static Widget _bookmarkStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.72), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: <Widget>[
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color.withOpacity(0.55), fontSize: 8.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _ticketInfo(String label, String value) {
    const Color blue = Color(0xFF334D6E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.55), borderRadius: BorderRadius.circular(12), border: Border.all(color: blue.withOpacity(0.16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: TextStyle(color: blue.withOpacity(0.55), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: blue, fontSize: 10.8, fontWeight: FontWeight.w900, height: 1.15)),
        ],
      ),
    );
  }

  static Widget _knowledgeMiniBox(
      String label,
      String value,
      Color accent,
      Color textColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor.withOpacity(0.72),
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  static String _islamicBookHook(ShareProductData d, String fallback) {
    if (shareHas(d.description)) {
      final String s = d.description.replaceAll('\n', ' ').trim();
      if (s.length > 85) return '${s.substring(0, 85)}...';
      return s;
    }

    if (shareHas(d.condition)) {
      return 'كتاب بحالة ${d.condition}، مناسب لمن يحب القراءة الهادئة والمحتوى النافع.';
    }

    return fallback;
  }

  static String _bookHook(ShareProductData d, String fallback) {
    if (shareHas(d.description)) {
      final String s = d.description.replaceAll('\n', ' ').trim();
      if (s.length > 90) return '${s.substring(0, 90)}...';
      return s;
    }
    return fallback;
  }

}

class _BookStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = Colors.white.withOpacity(0.12);
    for (double y = 18; y < size.height; y += 42) {
      for (double x = 16; x < size.width; x += 56) {
        canvas.drawCircle(Offset(x, y), 1.4, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BookmarkPainter extends CustomPainter {
  const _BookmarkPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 18)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BookmarkPainter oldDelegate) => oldDelegate.color != color;
}

class _SoftLinesPainter extends CustomPainter {
  const _SoftLinesPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = 34; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _SoftLinesPainter oldDelegate) => oldDelegate.color != color;
}

class _TicketDotsPainter extends CustomPainter {
  const _TicketDotsPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color;
    for (double x = 14; x < size.width; x += 18) {
      canvas.drawCircle(Offset(x, size.height / 2), 3, p);
    }
  }

  @override
  bool shouldRepaint(covariant _TicketDotsPainter oldDelegate) => oldDelegate.color != color;
}
class _IslamicPatternPainter extends CustomPainter {
  const _IslamicPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double y = 20; y < size.height; y += 48) {
      for (double x = 20; x < size.width; x += 48) {
        final Rect rect = Rect.fromCenter(
          center: Offset(x, y),
          width: 22,
          height: 22,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          p,
        );

        canvas.drawCircle(Offset(x, y), 4, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _IslamicArchPainter extends CustomPainter {
  const _IslamicArchPainter({
    required this.fillColor,
    required this.borderColor,
  });

  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Path arch = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.36)
      ..quadraticBezierTo(
        size.width * 0.50,
        -size.height * 0.10,
        size.width,
        size.height * 0.36,
      )
      ..lineTo(size.width, size.height)
      ..close();

    final Paint fill = Paint()..color = fillColor;
    final Paint border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    canvas.drawPath(arch, fill);
    canvas.drawPath(arch, border);
  }

  @override
  bool shouldRepaint(covariant _IslamicArchPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}

class _ManuscriptLinesPainter extends CustomPainter {
  const _ManuscriptLinesPainter({
    required this.lineColor,
    required this.ornamentColor,
  });

  final Color lineColor;
  final Color ornamentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double y = 72; y < size.height; y += 32) {
      canvas.drawLine(Offset(18, y), Offset(size.width - 18, y), line);
    }

    final Paint ornament = Paint()
      ..color = ornamentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Rect topRect = Rect.fromLTWH(18, 18, size.width - 36, 38);
    final Rect bottomRect =
    Rect.fromLTWH(18, size.height - 56, size.width - 36, 38);

    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(14)),
      ornament,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomRect, const Radius.circular(14)),
      ornament,
    );

    canvas.drawCircle(Offset(size.width / 2, 37), 5, ornament);
    canvas.drawCircle(Offset(size.width / 2, size.height - 37), 5, ornament);
  }

  @override
  bool shouldRepaint(covariant _ManuscriptLinesPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.ornamentColor != ornamentColor;
  }
}

