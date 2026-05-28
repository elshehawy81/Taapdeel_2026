import 'package:flutter/material.dart';

import '../models/intro_models.dart';

/// Slide 2: Smart AI product understanding + recommended swap opportunity.
final Map<IntroPersonaKey, IntroSlide2Model> slide2NewContent = {
  // ── ذكر 23+ ──────────────────────────────────────────────────────────────
  IntroPersonaKey.male23Plus: IntroSlide2Model(
    headerTitle: 'تبديـــل حل أسهــــل',
    headerSubtitle: 'صور منتجك وسيب الباقي علينا',
    compatibilityPercent: 84,
    compatibilityLabel: 'فرصة ممتازة',
    myProductTitle: 'شنطة لاب توب',
    myProductImageAsset: 'assets/images/products/business_bag_from_brother.webp',
    suggestedProductTitle: 'كرسي ألعاب',
    suggestedProductImageAsset: 'assets/images/products/young_female_earbuds_swap.webp',
    reasons: const <IntroReasonChipModel>[
      IntroReasonChipModel(
        icon: Icons.interests_rounded,
        label: 'من اهتماماتك',
      ),
      IntroReasonChipModel(
        icon: Icons.location_on_rounded,
        label: 'قريب منك',
      ),
      IntroReasonChipModel(
        icon: Icons.verified_rounded,
        label: 'حالة ممتازة',
      ),
      IntroReasonChipModel(
        icon: Icons.sell_rounded,
        label: 'نفس السعر',
      ),
    ],
    footerAiLabel: 'تحليل ذكي يساعدك تختار أسرع',
  ),

  // ── ذكر أقل من 23 ────────────────────────────────────────────────────────
  IntroPersonaKey.maleUnder23: IntroSlide2Model(
    headerTitle: 'تبديـــل حل أسهــــل',
    headerSubtitle: 'صور منتجك وسيب الباقي علينا',
    compatibilityPercent: 88,
    compatibilityLabel: 'فرصة ممتازة',
    myProductTitle: 'سماعة ألعاب',
    myProductImageAsset: 'assets/images/products/boy_page1_gaming_headset.webp',
    suggestedProductTitle: 'ساعة سمارت',
    suggestedProductImageAsset: 'assets/images/products/smartwatch.png',
    reasons: const <IntroReasonChipModel>[
      IntroReasonChipModel(
        icon: Icons.sports_esports_rounded,
        label: 'من اهتماماتك',
      ),
      IntroReasonChipModel(
        icon: Icons.location_on_rounded,
        label: 'قريب منك',
      ),
      IntroReasonChipModel(
        icon: Icons.verified_rounded,
        label: 'حالة ممتازة',
      ),
      IntroReasonChipModel(
        icon: Icons.sell_rounded,
        label: 'نفس السعر',
      ),
    ],
    footerAiLabel: 'تحليل ذكي يساعدك تختار أسرع',
  ),

  // ── أنثى 23+ ─────────────────────────────────────────────────────────────
  IntroPersonaKey.female23Plus: IntroSlide2Model(
    headerTitle: 'تبديـــل حل أسهــــل',
    headerSubtitle: 'صور منتجك وسيب الباقي علينا',
    compatibilityPercent: 87,
    compatibilityLabel: 'فرصة ممتازة',
    myProductTitle: 'عربة أطفال',
    myProductImageAsset: 'assets/images/products/adult_female_stroller_swap.png',
    suggestedProductTitle: 'شنطة براند',
    suggestedProductImageAsset: 'assets/images/products/05_white_bag_closeup.png',
    reasons: const <IntroReasonChipModel>[
      IntroReasonChipModel(
        icon: Icons.favorite_rounded,
        label: 'من احتياجات أسرتك',
      ),
      IntroReasonChipModel(
        icon: Icons.verified_rounded,
        label: 'حالة ممتازة',
      ),
      IntroReasonChipModel(
        icon: Icons.location_on_rounded,
        label: 'قريب منك',
      ),
      IntroReasonChipModel(
        icon: Icons.sell_rounded,
        label: 'نفس السعر',
      ),
    ],
    footerAiLabel: 'تحليل ذكي يساعدك تختاري أسرع',
  ),

  // ── أنثى أقل من 23 ───────────────────────────────────────────────────────
  IntroPersonaKey.femaleUnder23: IntroSlide2Model(
    headerTitle: 'تبديـــل حل أسهــــل',
    headerSubtitle: 'صور منتجك وسيب الباقي علينا',
    compatibilityPercent: 91,
    compatibilityLabel: 'فرصة ممتازة',
    myProductTitle: 'شنطة براند',
    myProductImageAsset:
    'assets/images/products/young_female_backpack_swap_alt.webp',
    suggestedProductTitle: 'كاميرا سمارت',
    suggestedProductImageAsset: 'assets/images/products/instant_camera.webp',
    reasons: const <IntroReasonChipModel>[
      IntroReasonChipModel(
        icon: Icons.interests_rounded,
        label: 'من اهتماماتك',
      ),
      IntroReasonChipModel(
        icon: Icons.location_on_rounded,
        label: 'قريب منك',
      ),
      IntroReasonChipModel(
        icon: Icons.verified_rounded,
        label: 'حالة كسر زيرو',
      ),
      IntroReasonChipModel(
        icon: Icons.sell_rounded,
        label: 'من صديقتك',
      ),
    ],
    footerAiLabel: 'تحليل ذكي يساعدك تختاري أسرع',
  ),
};