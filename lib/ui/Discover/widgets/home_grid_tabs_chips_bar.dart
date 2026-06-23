import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../api/ps_url.dart';
import '../../../../utils/utils.dart';
import '../../Contacts/search_provider.dart';

/// ✅ Sticky header delegate (pinned chips bar)
class ChipsPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  ChipsPinnedHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    const Color navy = Color(0xFF0B2A6F);

    return Material(
      color: Colors.transparent,
      elevation: overlapsContent ? 10 : 0,
      shadowColor: Colors.black.withAlpha(25),
      child: ClipRRect(
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 1,
                color: navy.withOpacity(0.08),
              ),
            ),
            SafeArea(
              bottom: false,
              child: SizedBox(
                height: height,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ChipsPinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class HomeGridTabsChipsBar extends StatelessWidget {
  const HomeGridTabsChipsBar({
    Key? key,
    required this.loggedIn,
    required this.selectedKey,
    required this.onSelect,
    required this.contextForStrings,
    required this.barKey,
    required this.hController,
    required this.chipKeys,
  }) : super(key: key);

  final bool loggedIn;
  final String selectedKey;
  final void Function(String key, String title, String url) onSelect;
  final BuildContext contextForStrings;

  final GlobalKey barKey;
  final ScrollController hController;
  final Map<String, GlobalKey> chipKeys;

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Selector بدل Consumer — بيعمل rebuild بس لو sectionRequested / loading / count اتغيروا
    return Selector<SearchProvider, Map<String, _TabVisibilityData>>(
      selector: (_, sp) {
        // ✅ نجمع الـ data اللي الـ tabs visibility بتعتمد عليها في map واحدة
        final result = <String, _TabVisibilityData>{};
        for (final key in ['prefcat', 'family', 'premium', 'brands', 'explore', 'wish']) {
          final url = _urlForKey(key);
          result[key] = _TabVisibilityData(
            requested: sp.sectionRequested(url),
            loading: sp.sectionLoading(url),
            count: sp.sectionProducts(url).length,
          );
        }
        return result;
      },
      shouldRebuild: (prev, next) {
        for (final key in next.keys) {
          if (prev[key] != next[key]) return true;
        }
        return false;
      },
      builder: (context, tabData, _) {
        final items = <GridTabItem>[
          GridTabItem(
            keyName: 'prefcat',
            title: ' فرص لك انت',
            icon: Icons.auto_awesome_rounded,
            url: PsUrl.ps_Prefcat_bulk_url,
            requiresLogin: false,
          ),
          GridTabItem(
            keyName: 'family',
            title: Utils.getString(contextForStrings, 'FamilyProducts'),
            icon: Icons.family_restroom_rounded,
            url: PsUrl.ps_family_network_items_url,
            requiresLogin: true,
          ),
          GridTabItem(
            keyName: 'premium',
            title: Utils.getString(contextForStrings, 'SpecialProducts'),
            icon: Icons.local_fire_department_rounded,
            url: PsUrl.ps_premium_url,
            requiresLogin: false,
          ),
          GridTabItem(
            keyName: 'brands',
            title: Utils.getString(contextForStrings, 'Brands'),
            icon: Icons.verified_rounded,
            url: PsUrl.ps_brands_url,
            requiresLogin: false,
          ),
          // ✅ FIX: free tab محذوف نهائياً — متعلق في الكود ومش بيتحمّل
          GridTabItem(
            keyName: 'explore',
            title: Utils.getString(contextForStrings, 'Explore'),
            icon: Icons.explore_rounded,
            url: PsUrl.ps_explore_url,
            requiresLogin: false,
          ),
          GridTabItem(
            keyName: 'wish',
            title: 'حواديت تبديل',
            icon: Icons.forum_rounded,
            url: PsUrl.ps_get_wishlist_items_url,
            requiresLogin: false,
          ),
        ];

        bool shouldShowTab(GridTabItem it) {
          if (it.requiresLogin && !loggedIn) return false;

          const core = {'explore', 'wish'};
          if (core.contains(it.keyName)) return true;

          if (it.keyName == selectedKey) return true;

          final data = tabData[it.keyName];
          if (data == null) return true;

          // ✅ FIX: لو لسه بيتحمّل — خليه ظاهر دايماً حتى تتحدد النتيجة
          if (data.loading) return true;
          // بس لو تم الطلب وخلّص وكانت النتيجة صفر — اخفيه
          if (data.requested && !data.loading && data.count == 0) return false;

          return true;
        }

        final visible = items.where(shouldShowTab).toList();

        if (visible.length <= 1) {
          return const SizedBox.shrink();
        }

        final String safeSelectedKey = visible.any((e) => e.keyName == selectedKey)
            ? selectedKey
            : visible.first.keyName;

        return Padding(
          key: barKey,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: SizedBox(
            height: 54,
            child: ListView.separated(
              controller: hController,
              scrollDirection: Axis.horizontal,
              itemCount: visible.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final it = visible[i];
                final sel = it.keyName == safeSelectedKey;

                return SolidChip(
                  key: chipKeys[it.keyName],
                  selected: sel,
                  icon: it.icon,
                  label: it.title,
                  sectionKey: it.keyName,
                  onTap: () => onSelect(it.keyName, it.title, it.url),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ✅ helper لجلب الـ url من الـ key بدون context
  static String _urlForKey(String key) {
    switch (key) {
      case 'prefcat': return PsUrl.ps_Prefcat_bulk_url;
      case 'family':  return PsUrl.ps_family_network_items_url;
      case 'premium': return PsUrl.ps_premium_url;
      case 'brands':  return PsUrl.ps_brands_url;
      case 'explore': return PsUrl.ps_explore_url;
      case 'wish':    return PsUrl.ps_get_wishlist_items_url;
      default:        return PsUrl.ps_explore_url;
    }
  }
}

// ✅ Helper class للـ Selector
class _TabVisibilityData {
  const _TabVisibilityData({
    required this.requested,
    required this.loading,
    required this.count,
  });

  final bool requested;
  final bool loading;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is _TabVisibilityData &&
          other.requested == requested &&
          other.loading == loading &&
          other.count == count;

  @override
  int get hashCode => Object.hash(requested, loading, count);
}

class GridTabItem {
  const GridTabItem({
    required this.keyName,
    required this.title,
    required this.icon,
    required this.url,
    required this.requiresLogin,
  });

  final String keyName;
  final String title;
  final IconData icon;
  final String url;
  final bool requiresLogin;
}

class SolidChip extends StatelessWidget {
  const SolidChip({
    Key? key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.sectionKey,
  }) : super(key: key);

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String sectionKey;

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: استخدام static const map بدل switch function — لا object creation في كل build
    final palette = SectionPalette.forKey(sectionKey);

    final bg = selected ? palette.primary : Colors.white;
    final fg = selected ? Colors.white : palette.primary;

    final border = selected
        ? Colors.white.withAlpha(220)
        : palette.primary.withAlpha(70);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: selected ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withAlpha(selected ? 36 : 14),
                blurRadius: selected ? 16 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withAlpha(30) : palette.soft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? Colors.white.withAlpha(140)
                        : palette.primary.withAlpha(40),
                  ),
                ),
                child: Icon(icon, size: 16, color: fg),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Colors.white.withAlpha(245),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SectionPalette {
  const SectionPalette(this.primary, this.soft);
  final Color primary;
  final Color soft;

  // ✅ FIX: static const map بدل switch function — zero allocation في كل call
  static const Map<String, SectionPalette> _palettes = {
    'premium': SectionPalette(Color(0xFFD4AF37), Color(0xFFE8F0FF)),
    'friends': SectionPalette(Color(0xFF2F8CFF), Color(0xFFEFF6FF)),
    'family':  SectionPalette(Color(0xFF2F8CFF), Color(0xFFEFF6FF)),
    'prefcat': SectionPalette(Color(0xFF2CC2B7), Color(0xFFF3E8FF)),
    'brands':  SectionPalette(Color(0xFF1F4F75), Color(0xFFECFDF5)),
    'free':    SectionPalette(Color(0xFF2FB5A3), Color(0xFFFFFBEB)),
    'explore': SectionPalette(Color(0xFF6B63C6), Color(0xFFE0F2FE)),
    'wish':    SectionPalette(Color(0xFF0C587A), Color(0xFFEAFBFF)),
  };

  static const SectionPalette _default = SectionPalette(
    Color(0xFF0B2A6F),
    Color(0xFFE8F0FF),
  );

  static SectionPalette forKey(String key) => _palettes[key] ?? _default;
}

// ✅ backward compat — احتفظ بالـ function القديمة لو في كود تاني بيستخدمها
SectionPalette paletteForKey(String key) => SectionPalette.forKey(key);
