import 'package:flutter/material.dart';

import '../core/share_product_data.dart';
import '../core/share_theme_definition.dart';
import '../widgets/share_theme_helpers.dart';

class SchoolShareThemes {
  const SchoolShareThemes._();

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
        ShareThemeDefinition(id: 'school_mood', label: 'School Mood', subtitle: 'أدوات مدرسية', groups: const <ShareThemeGroup>[ShareThemeGroup.school], gradient: const <Color>[Color(0xFFB8D9C4), Color(0xFF4B8060)], priority: 10, builder: _schoolMood),
        ShareThemeDefinition(id: 'school_journal_vibes', label: 'Journal Vibes', subtitle: 'دراسة وتنظيم', groups: const <ShareThemeGroup>[ShareThemeGroup.school], gradient: const <Color>[Color(0xFFC7A7E8), Color(0xFF7B5AA6)], priority: 20, builder: _journalVibes),
      ];

  static Widget _schoolMood(BuildContext context, ShareProductData d) => _base(d, accent: const Color(0xFF4B8060), bg: const Color(0xFFF2F8EF), title: 'SCHOOL MOOD');
  static Widget _journalVibes(BuildContext context, ShareProductData d) => _base(d, accent: const Color(0xFF7B5AA6), bg: const Color(0xFFF6F0FF), title: 'JOURNAL VIBES');

  static Widget _base(ShareProductData d, {required Color accent, required Color bg, required String title}) {
    return Container(
      color: bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 8), child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: accent, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.6))),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: accent.withOpacity(0.22))), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: shareNetworkImage(d.imageUrl))))),
        Padding(padding: const EdgeInsets.fromLTRB(18, 12, 18, 8), child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF213027), fontSize: 18, fontWeight: FontWeight.w900))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Wrap(alignment: WrapAlignment.center, spacing: 7, runSpacing: 7, children: <Widget>[
          if (shareHas(d.condition)) sharePill(text: d.condition, bg: Colors.white, fg: accent, icon: Icons.verified_rounded),
          if (shareHas(d.usage)) sharePill(text: d.usage, bg: Colors.white, fg: accent, icon: Icons.school_rounded),
          if (shareHas(sharePriceText(d))) sharePill(text: sharePriceText(d), bg: accent, fg: Colors.white, icon: Icons.local_offer_rounded),
        ])),
        Padding(padding: const EdgeInsets.all(18), child: shareBrandFooter(color: accent.withOpacity(0.70), right: 'READY FOR A NEW SCHOOL DAY')),
      ]),
    );
  }

}
