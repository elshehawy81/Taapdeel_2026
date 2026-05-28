import 'package:flutter/material.dart';

class WishStoryCardTheme {
  const WishStoryCardTheme({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.badgeLabel,
    required this.icon,
    required this.headerGradient,
    required this.cardBackground,
    required this.accent,
    required this.titleColor,
    required this.roleOneColor,
    required this.roleTwoColor,
    required this.bubbleOne,
    required this.bubbleTwo,
    required this.productPanel,
    required this.bottomPrimary,
    required this.bottomSecondary,
    required this.roleOne,
    required this.roleTwo,
    this.personaType = 'family',
  });

  final String id;
  final String label;
  final String subtitle;
  final String badgeLabel;
  final IconData icon;
  final List<Color> headerGradient;
  final Color cardBackground;
  final Color accent;
  final Color titleColor;
  final Color roleOneColor;
  final Color roleTwoColor;
  final Color bubbleOne;
  final Color bubbleTwo;
  final Color productPanel;
  final Color bottomPrimary;
  final Color bottomSecondary;
  final String roleOne;
  final String roleTwo;
  final String personaType;
}

class WishStoryCardThemes {
  const WishStoryCardThemes._();

  static const String defaultThemeId = 'wish_dream_ticket';

  static const List<WishStoryCardTheme> all = <WishStoryCardTheme>[
    WishStoryCardTheme(
      id: 'wish_dream_ticket',
      label: 'تذكرة الأمنية',
      subtitle: 'طلب واضح بشكل لطيف',
      badgeLabel: 'تذكرة أمنية',
      icon: Icons.confirmation_number_outlined,
      headerGradient: <Color>[Color(0xFF0C587A), Color(0xFF24A9C4)],
      cardBackground: Color(0xFFE8F8FB),
      accent: Color(0xFF0C587A),
      titleColor: Color(0xFF043757),
      roleOneColor: Color(0xFF0C587A),
      roleTwoColor: Color(0xFF24A9C4),
      bubbleOne: Color(0xFFFFFFFF),
      bubbleTwo: Color(0xFFCFEFF5),
      productPanel: Color(0xFFFFFFFF),
      bottomPrimary: Color(0xFF043757),
      bottomSecondary: Color(0xFF24A9C4),
      roleOne: 'أنا بدور على',
      roleTwo: 'اللي عنده المنتج',
      personaType: 'family',
    ),
    WishStoryCardTheme(
      id: 'wish_search_radar',
      label: 'رادار البحث',
      subtitle: 'ندور عليه حوالين المستخدم',
      badgeLabel: 'رادار تبديل',
      icon: Icons.radar_outlined,
      headerGradient: <Color>[Color(0xFF071B2F), Color(0xFF22C7B8)],
      cardBackground: Color(0xFF071B2F),
      accent: Color(0xFF22C7B8),
      titleColor: Color(0xFFFFFFFF),
      roleOneColor: Color(0xFF46F5E2),
      roleTwoColor: Color(0xFFFFFFFF),
      bubbleOne: Color(0x1A22C7B8),
      bubbleTwo: Color(0x2A46F5E2),
      productPanel: Color(0x141FFFFFFF),
      bottomPrimary: Color(0xFF22C7B8),
      bottomSecondary: Color(0xFF123C55),
      roleOne: 'الرادار',
      roleTwo: 'فرصة قريبة',
      personaType: 'family',
    ),
    WishStoryCardTheme(
      id: 'wish_empty_shelf',
      label: 'مكانه فاضي',
      subtitle: 'كارت يحفز اللي عنده المنتج',
      badgeLabel: 'مكانه فاضي',
      icon: Icons.inventory_2_outlined,
      headerGradient: <Color>[Color(0xFFFFF3D8), Color(0xFFD99B45)],
      cardBackground: Color(0xFFFFF8EA),
      accent: Color(0xFFD99B45),
      titleColor: Color(0xFF5A3A14),
      roleOneColor: Color(0xFF8A5A21),
      roleTwoColor: Color(0xFFD99B45),
      bubbleOne: Color(0xFFFFFFFF),
      bubbleTwo: Color(0xFFFFE8B8),
      productPanel: Color(0xFFFFF3D8),
      bottomPrimary: Color(0xFF8A5A21),
      bottomSecondary: Color(0xFFD99B45),
      roleOne: 'الرف',
      roleTwo: 'المنتج الناقص',
      personaType: 'home',
    ),
    WishStoryCardTheme(
      id: 'wish_swap_recipe',
      label: 'وصفة التبديل',
      subtitle: 'مكونات الصفقة المطلوبة',
      badgeLabel: 'وصفة تبديل',
      icon: Icons.restaurant_menu_rounded,
      headerGradient: <Color>[Color(0xFF2F4F3A), Color(0xFFB8D89A)],
      cardBackground: Color(0xFFF4FAEF),
      accent: Color(0xFF2F4F3A),
      titleColor: Color(0xFF223828),
      roleOneColor: Color(0xFF2F4F3A),
      roleTwoColor: Color(0xFF77A760),
      bubbleOne: Color(0xFFFFFFFF),
      bubbleTwo: Color(0xFFE3F2D8),
      productPanel: Color(0xFFEAF5DF),
      bottomPrimary: Color(0xFF2F4F3A),
      bottomSecondary: Color(0xFF77A760),
      roleOne: 'المكونات',
      roleTwo: 'النتيجة',
      personaType: 'family',
    ),
    WishStoryCardTheme(
      id: 'wish_mission_card',
      label: 'مهمة البحث',
      subtitle: 'Mission style للمنتج المطلوب',
      badgeLabel: 'مهمة بحث',
      icon: Icons.flag_rounded,
      headerGradient: <Color>[Color(0xFF2B2D42), Color(0xFFEF8354)],
      cardBackground: Color(0xFF2B2D42),
      accent: Color(0xFFEF8354),
      titleColor: Color(0xFF2B2D42),
      roleOneColor: Color(0xFFEF8354),
      roleTwoColor: Color(0xFFFFFFFF),
      bubbleOne: Color(0x1AEF8354),
      bubbleTwo: Color(0x22FFFFFF),
      productPanel: Color(0x141FFFFFFF),
      bottomPrimary: Color(0xFFEF8354),
      bottomSecondary: Color(0xFF4F5D75),
      roleOne: 'المهمة',
      roleTwo: 'المطلوب',
      personaType: 'mission',
    ),
    WishStoryCardTheme(
      id: 'wish_gift_hint',
      label: 'هدية منتظرة',
      subtitle: 'ستايل صندوق هدية',
      badgeLabel: 'هدية منتظرة',
      icon: Icons.card_giftcard_rounded,
      headerGradient: <Color>[Color(0xFFFFD6E8), Color(0xFFC45AA6)],
      cardBackground: Color(0xFFFFF3FA),
      accent: Color(0xFFC45AA6),
      titleColor: Color(0xFF813D70),
      roleOneColor: Color(0xFFC45AA6),
      roleTwoColor: Color(0xFF813D70),
      bubbleOne: Color(0xFFFFFFFF),
      bubbleTwo: Color(0xFFFFE2F1),
      productPanel: Color(0xFFFFEEF7),
      bottomPrimary: Color(0xFFC45AA6),
      bottomSecondary: Color(0xFF813D70),
      roleOne: 'الأمنية',
      roleTwo: 'الهدية',
      personaType: 'gift',
    ),
    WishStoryCardTheme(
      id: 'wish_market_note',
      label: 'نوتة السوق',
      subtitle: 'طلب بسيط وواضح',
      badgeLabel: 'نوتة السوق',
      icon: Icons.sticky_note_2_rounded,
      headerGradient: <Color>[Color(0xFFF6E7C8), Color(0xFF3D5A80)],
      cardBackground: Color(0xFFFFFBF0),
      accent: Color(0xFF3D5A80),
      titleColor: Color(0xFF263B56),
      roleOneColor: Color(0xFF3D5A80),
      roleTwoColor: Color(0xFFD29B45),
      bubbleOne: Color(0xFFFFFFFF),
      bubbleTwo: Color(0xFFFFF0D2),
      productPanel: Color(0xFFF6E7C8),
      bottomPrimary: Color(0xFF3D5A80),
      bottomSecondary: Color(0xFFD29B45),
      roleOne: 'المطلوب',
      roleTwo: 'الملاحظة',
      personaType: 'shopping',
    ),
    WishStoryCardTheme(
      id: 'wish_missing_piece',
      label: 'القطعة الناقصة',
      subtitle: 'تصميم Puzzle لطيف',
      badgeLabel: 'القطعة الناقصة',
      icon: Icons.extension_rounded,
      headerGradient: <Color>[Color(0xFFE8F7FF), Color(0xFF537FE7)],
      cardBackground: Color(0xFFF2FAFF),
      accent: Color(0xFF537FE7),
      titleColor: Color(0xFF29478F),
      roleOneColor: Color(0xFF537FE7),
      roleTwoColor: Color(0xFF29478F),
      bubbleOne: Color(0xFFFFFFFF),
      bubbleTwo: Color(0xFFE1EEFF),
      productPanel: Color(0xFFE8F7FF),
      bottomPrimary: Color(0xFF537FE7),
      bottomSecondary: Color(0xFF29478F),
      roleOne: 'البازل',
      roleTwo: 'القطعة',
      personaType: 'family',
    ),
    WishStoryCardTheme(
      id: 'wish_clean_request',
      label: 'طلب شيك',
      subtitle: 'ستايل minimal راقي',
      badgeLabel: 'طلب شيك',
      icon: Icons.check_circle_outline_rounded,
      headerGradient: <Color>[Color(0xFFF8FAFC), Color(0xFF0F2E57)],
      cardBackground: Color(0xFFF8FAFC),
      accent: Color(0xFF0F2E57),
      titleColor: Color(0xFF0F2E57),
      roleOneColor: Color(0xFF0F2E57),
      roleTwoColor: Color(0xFF64748B),
      bubbleOne: Color(0xFFFFFFFF),
      bubbleTwo: Color(0xFFE8EEF5),
      productPanel: Color(0xFFFFFFFF),
      bottomPrimary: Color(0xFF0F2E57),
      bottomSecondary: Color(0xFF64748B),
      roleOne: 'الطلب',
      roleTwo: 'التبديل',
      personaType: 'minimal',
    ),
    WishStoryCardTheme(
      id: 'wish_chat_request',
      label: 'حد عنده؟',
      subtitle: 'ستايل محادثة لطيف',
      badgeLabel: 'حد عنده؟',
      icon: Icons.chat_bubble_outline_rounded,
      headerGradient: <Color>[Color(0xFFE7FFF5), Color(0xFF36B37E)],
      cardBackground: Color(0xFFF0FFF8),
      accent: Color(0xFF36B37E),
      titleColor: Color(0xFF1F6A4C),
      roleOneColor: Color(0xFF36B37E),
      roleTwoColor: Color(0xFF1F6A4C),
      bubbleOne: Color(0xFFFFFFFF),
      bubbleTwo: Color(0xFFDDFBEC),
      productPanel: Color(0xFFE7FFF5),
      bottomPrimary: Color(0xFF36B37E),
      bottomSecondary: Color(0xFF1F6A4C),
      roleOne: 'السؤال',
      roleTwo: 'الرد',
      personaType: 'chat',
    ),
  ];

  static WishStoryCardTheme byId(String? id) {
    final String normalized = _normalizeThemeId(id);
    if (normalized.isEmpty) return _defaultTheme();

    return all.firstWhere(
      (WishStoryCardTheme theme) => _normalizeThemeId(theme.id) == normalized,
      orElse: _defaultTheme,
    );
  }

  static WishStoryCardTheme byIndex(int index) {
    if (all.isEmpty) return _defaultTheme();
    return all[index.abs() % all.length];
  }

  static WishStoryCardTheme fromPersonaType(String? personaType) {
    final String p = (personaType ?? '').trim().toLowerCase();
    if (p.isEmpty) return _defaultTheme();

    return all.firstWhere(
      (WishStoryCardTheme theme) => theme.personaType.toLowerCase() == p,
      orElse: _defaultTheme,
    );
  }

  static List<WishStoryCardTheme> suggestionsForPersona(String? personaType) {
    return all;
  }

  static String tagline(WishStoryCardTheme theme) {
    switch (theme.id) {
      case 'wish_search_radar':
        return 'رادار تبديل بيدور على المنتج المطلوب';
      case 'wish_empty_shelf':
        return 'مكانه فاضي ويمكن يكون عند حد تاني';
      case 'wish_swap_recipe':
        return 'وصفة بسيطة لصفقة تبديل مناسبة';
      case 'wish_mission_card':
        return 'مهمة بحث واضحة عن المنتج';
      case 'wish_gift_hint':
        return 'هدية منتظرة ممكن تتحقق بالتبديل';
      case 'wish_market_note':
        return 'نوتة طلب واضحة وسهلة المشاركة';
      case 'wish_missing_piece':
        return 'القطعة الناقصة اللي بتكمل الحكاية';
      case 'wish_clean_request':
        return 'طلب شيك ومباشر بدون زحمة';
      case 'wish_chat_request':
        return 'سؤال بسيط: حد عنده المنتج ده؟';
      case 'wish_dream_ticket':
      default:
        return 'تذكرة أمنية واضحة على تبديل';
    }
  }

  static String defaultTitleForTheme(
    WishStoryCardTheme theme,
    String productName,
  ) {
    final String product =
        productName.trim().isEmpty ? 'المنتج ده' : productName.trim();

    switch (theme.id) {
      case 'wish_search_radar':
        return 'حد عنده $product؟';
      case 'wish_empty_shelf':
        return 'مكان $product فاضي عندي';
      case 'wish_swap_recipe':
        return 'وصفة تبديل لـ $product';
      case 'wish_mission_card':
        return 'مهمة البحث عن $product';
      case 'wish_gift_hint':
        return '$product كهدية منتظرة';
      case 'wish_market_note':
        return '$product في نوتة السوق';
      case 'wish_missing_piece':
        return '$product هو القطعة الناقصة';
      case 'wish_clean_request':
        return 'بدور على $product';
      case 'wish_chat_request':
        return 'حد عنده $product؟';
      case 'wish_dream_ticket':
      default:
        return 'تذكرة أمنية لـ $product';
    }
  }


  static WishStoryCardTheme _defaultTheme() {
    return all.firstWhere(
      (WishStoryCardTheme theme) => theme.id == defaultThemeId,
      orElse: () => all.first,
    );
  }

  static String _normalizeThemeId(String? value) {
    final String id = (value ?? '').trim().toLowerCase();
    if (id.isEmpty || id == 'null') return '';
    return id;
  }
}
