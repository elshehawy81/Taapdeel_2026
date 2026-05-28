import 'package:flutter/material.dart';

import 'share_product_data.dart';

typedef ShareThemeBuilder = Widget Function(
  BuildContext context,
  ShareProductData data,
);

enum ShareThemeGroup {
  books,
  sports,
  electronics,
  womenFashion,
  modestWear,
  kids,
  school,
  home,
  games,
  beauty,
  general, mensWear,
}

class ShareThemeDefinition {
  const ShareThemeDefinition({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.groups,
    required this.gradient,
    required this.builder,
    this.priority = 100,
  });

  final String id;
  final String label;
  final String subtitle;
  final List<ShareThemeGroup> groups;
  final List<Color> gradient;
  final ShareThemeBuilder builder;
  final int priority;
}

class ShareThemeSections {
  const ShareThemeSections({
    required this.suitableThemes,
    required this.generalThemes,
  });

  final List<ShareThemeDefinition> suitableThemes;
  final List<ShareThemeDefinition> generalThemes;

  List<ShareThemeDefinition> get allVisibleThemes {
    final Map<String, ShareThemeDefinition> unique = <String, ShareThemeDefinition>{};
    for (final ShareThemeDefinition theme in suitableThemes) {
      unique[theme.id] = theme;
    }
    for (final ShareThemeDefinition theme in generalThemes) {
      unique[theme.id] = theme;
    }
    return unique.values.toList();
  }
}
