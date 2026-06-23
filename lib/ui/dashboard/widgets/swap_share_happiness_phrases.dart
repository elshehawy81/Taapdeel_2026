import 'dart:math' as math;

// =============================================================
// SwapShareHappinessPhrases
// جمل قصيرة ولطيفة تظهر عشوائيًا داخل كارت الشير لتحفيز إحساس
// السعادة والفرحة والانبساط بدون ربطها مباشرة بفكرة التبديل.
// الجمل مقسمة لفئات، والاختيار العشوائي يفضّل فئة مختلفة عن
// آخر فئة ظهرت لتقليل التكرار في المعنى.
// =============================================================

enum HappinessPhraseCategory {
  gratitude, // الامتنان
  sharing, // العطاء والمشاركة
  optimism, // التفاؤل والطاقة
  calm, // الهدوء والرضا
  presence, // اللحظة الحالية
  selfWorth, // المستخدم نفسه يستاهل كل حاجة حلوة
}

class HappinessPhraseResult {
  const HappinessPhraseResult(this.phrase, this.category);

  final String phrase;
  final HappinessPhraseCategory category;
}

class SwapShareHappinessPhrases {
  const SwapShareHappinessPhrases._();

  static const Map<HappinessPhraseCategory, List<String>> categorizedPhrases =
  <HappinessPhraseCategory, List<String>>{
    HappinessPhraseCategory.gratitude: <String>[
      'خليك ممتن لكل حاجة بتفرّحك 🙏',
      'اختار لحظة تخليك تقول: الحمد لله 🙏',
      'فيه جمال في أبسط اللحظات 🌸',
      'افرح بالتفاصيل… فيها سر السعادة 🌸',
      'كل تفصيلة حلوة تستحق الامتنان 🌸',
      'الحلو في الحياة يستاهل نلاحظه 🍃',
      'خليك ممتن للحظة الحلوة 🙏',
    ],
    HappinessPhraseCategory.sharing: <String>[
      'البهجة بتكبر لما نشاركها 🌼',
      'الفرحة لما تتشارك بتزيد 😍',
      'الفرحة معدية… شاركها مع اللي حواليك 😍',
      'خليك سبب في ابتسامة حد 😍',
      'حاجة صغيرة منك ممكن تعمل فرق كبير عند حد تاني 🎁',
      'إحساس جميل يستاهل يتشارك 💙',
      'الأيام بتتحلى بالناس والكلام الحلو 💛',
    ],
    HappinessPhraseCategory.optimism: <String>[
      'خلي اليوم ده فيه حاجة تضحكك 😂',
      'ابتسامتك ممكن تغيّر مود يوم كامل 😄',
      'خلي التفاؤل صاحبك النهارده 🌞',
      'كل ابتسامة بداية لطاقة جديدة ⚡',
      'يومك أجمل لما تبدأه بطاقة حلوة ☀️',
      'كل يوم جديد فرصة تبتسم 😊',
      'خلي يومك مليان طاقة حلوة ⚡',
      'الانبساط قرار صغير بيغيّر كتير 😊',
    ],
    HappinessPhraseCategory.calm: <String>[
      'مفيش أجمل من قلب مرتاح ومبسوط 💙',
      'خلي روحك خفيفة وقلبك مطمئن 🍃',
      'لو قلبك ارتاح… دي علامة حلوة 💛',
      'قلبك يستاهل لحظة انبساط 💙',
      'القلب المبسوط يشوف الدنيا أجمل 💛',
      'خليك دايمًا قريب من اللي يطمن قلبك 💙',
      'لما قلبك يفرح… كل حاجة تبقى أخف 😊',
    ],
    HappinessPhraseCategory.presence: <String>[
      'استمتع باللحظة… دي بتاعتك ✨',
      'لحظة حلوة تكفي تنوّر اليوم ☀️',
      'عيش اللحظة اللي تفرّحك 🎈',
      'لحظة لطيفة ممكن تسيب أثر كبير 💫',
      'فرحة النهارده ممكن تبقى ذكرى جميلة 📸',
      'كل يوم فيه لقطة تستاهل تفرحك 📸',
      'خلّي اللحظة دي أخف وأجمل 🌿',
    ],
    HappinessPhraseCategory.selfWorth: <String>[
      'إنت تستاهل كل حاجة حلوة 💛',
      'فرّح نفسك… أنت تستاهل 💖',
      'يومك يستاهل حاجة تفرّحك 🎉',
      'إنت سبب كفاية إن النهارده يبقى يوم حلو 🌟',
      'كل اللي يضحك قلبك… إنت تستاهله 😊',
      'خليك لطيف مع نفسك وفرّحها 💙',
      'إنت تستاهل لحظة من قلبك تماميًا 🌸',
      'حلو إنك تفرح بنفسك كمان مش بس بالناس 💫',
    ],
  };

  static List<String> get phrases =>
      categorizedPhrases.values.expand((List<String> e) => e).toList();

  static HappinessPhraseCategory _categoryOf(String phrase) {
    for (final MapEntry<HappinessPhraseCategory, List<String>> entry
    in categorizedPhrases.entries) {
      if (entry.value.contains(phrase)) return entry.key;
    }
    return HappinessPhraseCategory.presence;
  }

  /// يرجع جملة عشوائية، مع تفضيل فئة مختلفة عن [lastCategory] لو تم تمريرها.
  static String random({
    math.Random? random,
    HappinessPhraseCategory? lastCategory,
  }) {
    final math.Random r = random ?? math.Random();

    final List<HappinessPhraseCategory> categories =
    categorizedPhrases.keys.toList();

    List<HappinessPhraseCategory> candidates = categories;
    if (lastCategory != null && categories.length > 1) {
      candidates = categories
          .where((HappinessPhraseCategory c) => c != lastCategory)
          .toList();
    }

    final HappinessPhraseCategory chosenCategory =
    candidates[r.nextInt(candidates.length)];

    final List<String> pool = categorizedPhrases[chosenCategory]!;
    return pool[r.nextInt(pool.length)];
  }

  /// يرجع جملة + فئتها، مفيد للـ widget عشان يخزن آخر فئة ظهرت.
  static HappinessPhraseResult randomWithCategory({
    math.Random? random,
    HappinessPhraseCategory? lastCategory,
  }) {
    final String phrase = SwapShareHappinessPhrases.random(
      random: random,
      lastCategory: lastCategory,
    );
    return HappinessPhraseResult(phrase, _categoryOf(phrase));
  }
}
