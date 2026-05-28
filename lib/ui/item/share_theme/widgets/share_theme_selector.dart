import 'package:flutter/material.dart';

import '../core/share_theme_definition.dart';

class ShareThemeSelector extends StatelessWidget {
  const ShareThemeSelector({
    Key? key,
    required this.sections,
    required this.activeSection,
    required this.onSectionChanged,
  }) : super(key: key);

  final ShareThemeSections sections;
  final ShareThemeSectionType activeSection;
  final ValueChanged<ShareThemeSectionType> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final List<_ShareThemeTabData> tabs = <_ShareThemeTabData>[
      if (sections.generalThemes.isNotEmpty)
        const _ShareThemeTabData(
          title: 'ستايلات عامة',
          subtitle: 'تنفع مع أغلب المنتجات',
          icon: Icons.dashboard_customize_rounded,
          type: ShareThemeSectionType.general,
        ),
      if (sections.suitableThemes.isNotEmpty)
        const _ShareThemeTabData(
          title: 'ستايل مخصص للمنتج',
          subtitle: 'حسب فئة المنتج',
          icon: Icons.auto_awesome_rounded,
          type: ShareThemeSectionType.suitable,
        ),
    ];

    if (tabs.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FA),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD5E7F1)),
      ),
      child: Row(
        children: tabs
            .map(
              (_ShareThemeTabData tab) => Expanded(
                child: _ShareTabButton(
                  tab: tab,
                  selected: tab.type == activeSection,
                  onTap: () => onSectionChanged(tab.type),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

enum ShareThemeSectionType { general, suitable }

class _ShareThemeTabData {
  const _ShareThemeTabData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ShareThemeSectionType type;
}

class _ShareTabButton extends StatelessWidget {
  const _ShareTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _ShareThemeTabData tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: selected ? Border.all(color: const Color(0xFFC9E0EC)) : null,
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF0C587A).withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              tab.icon,
              size: 15,
              color: selected ? const Color(0xFF0C587A) : const Color(0xFF7192A6),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tab.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? const Color(0xFF102A43) : const Color(0xFF5A7587),
                      fontSize: 11.3,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tab.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? const Color(0xFF6B8798) : const Color(0xFF8CA6B5),
                      fontSize: 8.2,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
