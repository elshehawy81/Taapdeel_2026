import 'package:flutter/material.dart';

// =============================================================
// SwapShareLayout
// يحدد شكل الصورة النهائية، وليس الألوان فقط.
// =============================================================
enum SwapShareLayout {
  pollGrid,
  vsBattle,
  chatAdvice,
  decisionBoard,
  storySocial,
}

// =============================================================
// SwapShareTheme
// ثيمات الشير الخاصة بسؤال الأصدقاء/العائلة عن أفضل فرصة تبديل.
// كل ثيم له Layout مختلف + نصوص مختلفة + ألوان مختلفة + CTA واضح.
// =============================================================
class SwapShareTheme {
  const SwapShareTheme({
    required this.id,
    required this.name,
    required this.shortLabel,
    required this.previewLabel,
    required this.layout,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.question,
    required this.replyHint,
    required this.whatsAppTitle,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.primaryColor,
    required this.accentColor,
    required this.secondaryAccentColor,
    required this.softAccentColor,
  });

  final String id;
  final String name;
  final String shortLabel;
  final String previewLabel;
  final SwapShareLayout layout;
  final String headerTitle;
  final String headerSubtitle;
  final String question;
  final String replyHint;
  final String whatsAppTitle;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color primaryColor;
  final Color accentColor;
  final Color secondaryAccentColor;
  final Color softAccentColor;

  List<Color> get gradient => <Color>[primaryColor, accentColor];

  String get layoutTitle {
    switch (layout) {
      case SwapShareLayout.pollGrid:
        return 'أفضل لردود سريعة';
      case SwapShareLayout.vsBattle:
        return 'أفضل للمقارنة';
      case SwapShareLayout.chatAdvice:
        return 'أفضل للاستشارة الشخصية';
      case SwapShareLayout.decisionBoard:
        return 'أفضل للقرار الجاد';
      case SwapShareLayout.storySocial:
        return 'أفضل للشير والستوري';
    }
  }

  String bestUseForCount(int count) {
    if (count <= 1) {
      switch (layout) {
        case SwapShareLayout.vsBattle:
          return 'أفضل مع عرض واحد';
        case SwapShareLayout.chatAdvice:
          return 'سؤال مباشر';
        case SwapShareLayout.storySocial:
          return 'شير سريع';
        case SwapShareLayout.pollGrid:
        case SwapShareLayout.decisionBoard:
          return 'مناسب لعرض واحد';
      }
    }

    if (count == 2) {
      switch (layout) {
        case SwapShareLayout.vsBattle:
          return 'أفضل مع عرضين';
        case SwapShareLayout.pollGrid:
          return 'تصويت سريع';
        case SwapShareLayout.storySocial:
          return 'قصة مقارنة';
        case SwapShareLayout.chatAdvice:
        case SwapShareLayout.decisionBoard:
          return 'مناسب للمقارنة';
      }
    }

    if (count <= 3) {
      switch (layout) {
        case SwapShareLayout.pollGrid:
          return 'أفضل مع 3 اختيارات';
        case SwapShareLayout.decisionBoard:
          return 'قرار واضح';
        case SwapShareLayout.chatAdvice:
          return 'استشارة سهلة';
        case SwapShareLayout.vsBattle:
        case SwapShareLayout.storySocial:
          return 'مناسب لـ 3 عروض';
      }
    }

    switch (layout) {
      case SwapShareLayout.decisionBoard:
        return 'أفضل مع 4-5 عروض';
      case SwapShareLayout.storySocial:
        return 'يعرض حتى 5 عروض';
      case SwapShareLayout.pollGrid:
        return 'تصويت متعدد';
      case SwapShareLayout.chatAdvice:
        return 'استشارة جماعية';
      case SwapShareLayout.vsBattle:
        return 'مواجهة مرتبة';
    }
  }

  // 1) ثيم اختار لي الأفضل — Poll
  static const SwapShareTheme chooseBest = SwapShareTheme(
    id: 'choose_best',
    name: 'تصويت سريع',
    shortLabel: 'تصويت',
    previewLabel: 'اختيارات أ / ب / ج',
    layout: SwapShareLayout.pollGrid,
    headerTitle: '🗳️ أنهي عرض أفضل؟',
    headerSubtitle: 'حول الاستشارة لتصويت سريع وسهل',
    question: 'أنهي عرض أختار؟',
    replyHint: 'ابعتلي رقم الاختيار 👇',
    whatsAppTitle: 'اختارولي أحسن عرض تبديل',
      backgroundColor: Color(0xFFEFFBFD),
      surfaceColor: Color(0xFFFFFFFF),
      primaryColor: Color(0xFF4FACFE),
      accentColor: Color(0xFF00F2FE),
      secondaryAccentColor: Color(0xFF011934),
      softAccentColor: Color(0xFFDFF7FB)
  );

  // 2) ثيم مين يكسب التبديل؟ — VS Battle
  static const SwapShareTheme whoWins = SwapShareTheme(
    id: 'who_wins',
    name: 'مواجهة',
    shortLabel: 'VS',
    previewLabel: 'Battle / جولات',
    layout: SwapShareLayout.vsBattle,
    headerTitle: '🏆 مين يكسب؟',
    headerSubtitle: 'منتجي في مواجهة عروض التبديل',
    question: 'شايف تبديل أنهي عرض أقوى؟',
    replyHint: 'اختار الفائز واكتب الرمز',
    whatsAppTitle: 'مين يكسب التبديل؟',
    backgroundColor: Color(0xFFF3F7FB),
    surfaceColor: Color(0xFFFFFFFF),
    primaryColor: Color(0xFFBFEAE4),
    accentColor: Color(0xFF008E84),
    secondaryAccentColor: Color(0xFF008E84),
    softAccentColor: Color(0xFFE8F9FC),
  );

  // 3) ثيم استشارة صديق — Chat-like
  static const SwapShareTheme quickAdvice = SwapShareTheme(
    id: 'quick_advice',
    name: 'استشارة صديق',
    shortLabel: 'استشارة',
    previewLabel: 'ستايل محادثة',
    layout: SwapShareLayout.chatAdvice,
    headerTitle: 'محتاج رأيك بسرعة 🙏',
    headerSubtitle: 'استشارة بشكل محادثة طبيعية',
    question: 'أبدّل ولا أستنى؟',
    replyHint: 'قول: أبدّل / لا / اختار رقم المنتج',
    whatsAppTitle: 'محتاج نصيحتك في عرض تبديل',
    backgroundColor: Color(0xFFF5F3FF),
    surfaceColor: Color(0xFFFFFFFF),
    primaryColor: Color(0xFF312E81),
    accentColor: Color(0xFF7C3AED),
    secondaryAccentColor: Color(0xFFA78BFA),
    softAccentColor: Color(0xFFEDE9FE),
  );

  // 4) ثيم كارت قرار — Decision board
  static const SwapShareTheme fairDeal = SwapShareTheme(
    id: 'fair_deal',
    name: 'مساعدة في القرار',
    shortLabel: 'قرار',
    previewLabel: 'Decision Board',
    layout: SwapShareLayout.decisionBoard,
    headerTitle: '📋 مساعدة في اتخاذ القرار',
    headerSubtitle: 'قارن المنتج الحالي بالخيارات المتاحة',
    question: 'لو كنت مكاني، تختار أنهي عرض؟',
    replyHint: 'قولولي أبدّل ولا أستنى',
    whatsAppTitle: 'ساعدوني أقرر أفضل عرض تبديل',
    backgroundColor: Color(0xFFFFFBEB),
    surfaceColor: Color(0xFFFFFFFF),
    primaryColor: Color(0xFFFF6A6A),
    accentColor: Color(0xFFFF8E8E),
    secondaryAccentColor: Color(0xFF011934),
    softAccentColor: Color(0xFFFFF3C4),
  );

  // 5) ثيم ساعدني أقرر — Story / Social Card
  static const SwapShareTheme storySocial = SwapShareTheme(
    id: 'story_social',
    name: 'ستايل اجتماعي',
    shortLabel: 'Story',
    previewLabel: 'Story + كروت مائلة',
    layout: SwapShareLayout.storySocial,
    headerTitle: '✨ ساعدني أقرر',
    headerSubtitle: 'ستايل عصري مناسب للشير والستوري',
    question: 'محتار بين العروض دي',
    replyHint: 'رد عليا: أبدّل / ما أبدّلش / اختار رقم المنتج',
    whatsAppTitle: 'محتار بين عروض تبديل وعايز رأيكم',
    backgroundColor: Color(0xFFEAF8FB),
    surfaceColor: Color(0xFFFFFFFF),
    primaryColor: Color(0xFF0D3B6B),
    accentColor: Color(0xFF1AB8C3),
    secondaryAccentColor: Color(0xFF7FCFE8),
    softAccentColor: Color(0xFFDFF7FB),
  );

  // Alias للحفاظ على أي استخدام قديم لـ opinion.
  static const SwapShareTheme opinion = storySocial;

  static const List<SwapShareTheme> presets = <SwapShareTheme>[
    chooseBest,
    whoWins,
    quickAdvice,
    fairDeal,
    storySocial,
  ];

  static const SwapShareTheme defaultTheme = chooseBest;
}
