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
          title: 'تصميمات عامة',
          subtitle: 'مناسبة لمعظم المنتجات',
          badge: 'عام',
          type: ShareThemeSectionType.general,
        ),
      if (sections.suitableThemes.isNotEmpty)
        const _ShareThemeTabData(
          title: 'تصميم مناسب للمنتج',
          subtitle: 'حسب فئة المنتج الحالية',
          badge: 'مخصص',
          type: ShareThemeSectionType.suitable,
        ),
    ];

    if (tabs.isEmpty) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3FAFD),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFD7EBF4),
            width: 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xFF24A9C4),
                        Color(0xFF0C587A),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.style_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'اختار نوع تصميم المشاركة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF102A43),
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: tabs
                  .map(
                    (_ShareThemeTabData tab) => Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: tab == tabs.first ? 0 : 5,
                      end: tab == tabs.last ? 0 : 5,
                    ),
                    child: _ShareTabButton(
                      tab: tab,
                      selected: tab.type == activeSection,
                      onTap: () => onSectionChanged(tab.type),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

enum ShareThemeSectionType { general, suitable }

class _ShareThemeTabData {
  const _ShareThemeTabData({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.type,
  });

  final String title;
  final String subtitle;
  final String badge;
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
    final Color activeColor = const Color(0xFF0C587A);
    final Color activeLight = const Color(0xFF24A9C4);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 76,
          padding: const EdgeInsets.fromLTRB(9, 9, 9, 8),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[
                Color(0xFF0C587A),
                Color(0xFF24A9C4),
              ],
            )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? Colors.white.withOpacity(0.75)
                  : const Color(0xFFD5E7F1),
              width: selected ? 1.8 : 1.2,
            ),
            boxShadow: selected
                ? <BoxShadow>[
              BoxShadow(
                color: activeColor.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ]
                : <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 9,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[

                  Expanded(
                    child: Text(
                      tab.badge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: selected
                            ? Colors.white.withOpacity(0.95)
                            : const Color(0xFF7192A6),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: selected ? 1 : 0,
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tab.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF102A43),
                  fontSize: 11.8,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                tab.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? Colors.white.withOpacity(0.86)
                      : const Color(0xFF6B8798),
                  fontSize: 9.3,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}