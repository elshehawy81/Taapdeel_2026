import 'share_product_data.dart';
import 'share_theme_category_resolver.dart';
import 'share_theme_definition.dart';

import '../themes/books_share_themes.dart';
import '../themes/electronics_share_themes.dart';
import '../themes/general_share_themes.dart';
import '../themes/home_share_themes.dart';
import '../themes/kids_share_themes.dart';
import '../themes/modest_wear_share_themes.dart';
import '../themes/Games_share_themes.dart';
import '../themes/school_share_themes.dart';
import '../themes/sports_share_themes.dart';
import '../themes/women_fashion_share_themes.dart';
import '../themes/mens_wear_share_themes.dart';

class ShareThemeRegistry {
  const ShareThemeRegistry._();

  static List<ShareThemeDefinition> all() {
    return <ShareThemeDefinition>[
      ...BooksShareThemes.themes,
      ...SportsShareThemes.themes,
      ...ElectronicsShareThemes.themes,
      ...WomenFashionShareThemes.themes,
      ...ModestWearShareThemes.themes,
      ...KidsShareThemes.themes,
      ...SchoolShareThemes.themes,
      ...HomeShareThemes.themes,
      ...GamesShareThemes.themes,
      ...GeneralShareThemes.themes,
      ...MenShareThemes.themes,
    ];
  }

  static ShareThemeSections sectionsForProduct(
    ShareProductData data, {
    int maxSuitableThemes = 14,
    int maxGeneralThemes = 8,
  }) {
    final List<ShareThemeGroup> resolvedGroups = ShareThemeCategoryResolver.resolve(data);

    final List<ShareThemeDefinition> suitable = all()
        .where((ShareThemeDefinition theme) {
          final bool isGeneralOnly = theme.groups.length == 1 && theme.groups.first == ShareThemeGroup.general;
          if (isGeneralOnly) return false;

          return theme.groups.any((ShareThemeGroup group) => resolvedGroups.contains(group));
        })
        .toList();

    final List<ShareThemeDefinition> general = all()
        .where((ShareThemeDefinition theme) => theme.groups.contains(ShareThemeGroup.general))
        .toList();

    suitable.sort(_sortThemes);
    general.sort(_sortThemes);

    final List<ShareThemeDefinition> cleanSuitable = _uniqueById(suitable).take(maxSuitableThemes).toList();
    final List<ShareThemeDefinition> cleanGeneral = _uniqueById(general).take(maxGeneralThemes).toList();

    return ShareThemeSections(
      suitableThemes: cleanSuitable,
      generalThemes: cleanGeneral,
    );
  }

  static List<ShareThemeDefinition> forProduct(
    ShareProductData data, {
    int maxThemes = 18,
  }) {
    return sectionsForProduct(
      data,
      maxSuitableThemes: maxThemes,
      maxGeneralThemes: maxThemes,
    ).allVisibleThemes.take(maxThemes).toList();
  }

  static int _sortThemes(ShareThemeDefinition a, ShareThemeDefinition b) {
    final int byPriority = a.priority.compareTo(b.priority);
    if (byPriority != 0) return byPriority;
    return a.label.compareTo(b.label);
  }

  static List<ShareThemeDefinition> _uniqueById(List<ShareThemeDefinition> themes) {
    final Map<String, ShareThemeDefinition> map = <String, ShareThemeDefinition>{};
    for (final ShareThemeDefinition theme in themes) {
      map[theme.id] = theme;
    }
    return map.values.toList();
  }
}
