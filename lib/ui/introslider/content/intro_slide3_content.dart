import '../models/intro_models.dart';

/// Slide 3: Trust network (family & friends) + WhatsApp share
final Map<IntroPersonaKey, IntroSlide3TrustModel> slide3TrustContent = {
  // ── ذكر 23+ ──────────────────────────────────────────────────────────────
  IntroPersonaKey.male23Plus: IntroSlide3TrustModel(
    headerTitle: 'بدّل مع العيلة والصحاب بثقة',
    headerSubtitle:
        'شبكة العائلة والأصدقاء تساعدك تشوف منتجات\nالقريبين منك.',
    members: const [
      IntroTrustMemberModel(
        label: 'أخ',
        imageAsset: 'assets/images/products/boy_network_center.jpg',
      ),
      IntroTrustMemberModel(
        label: 'صديق',
        imageAsset: 'assets/images/products/young_male_network_top_right.webp',
      ),
      IntroTrustMemberModel(
        label: 'قريب',
        imageAsset: 'assets/images/products/adult_male_profile_profile.jpg',
      ),
      IntroTrustMemberModel(
        label: 'زميل',
        imageAsset: 'assets/images/products/young_male_network_center.webp',
      ),
    ],
    trustBadgeTitle: 'مجتمع موثوق',
    trustBadgeSubtitle: 'تبديل آمن مع ناس تعرفهم وتثق فيهم',
    networkProducts: const [
      IntroNetworkProductModel(
        title: 'بلاي ستيشن',
        imageAsset: 'assets/images/products/18_ps5_console_closeup.jpg',
        fromLabel: 'من أخوك',
        conditionLabel: 'حالة ممتازة',
      ),
      IntroNetworkProductModel(
        title: ' كتب لتخصصك',
        imageAsset: 'assets/images/products/books.png',
        fromLabel: 'من صديقك',
        conditionLabel: 'حالة جيدة جداً',
      ),
      IntroNetworkProductModel(
        title: 'سماعة wireless',
        imageAsset: 'assets/images/products/boy_page1_gaming_headset.webp',
        fromLabel: 'من قريبك',
        conditionLabel: 'حالة ممتازة',
      ),
    ],
    sharePromptTitle: 'شارك فرصة التبديل',
  ),

  // ── ذكر أقل من 23 ────────────────────────────────────────────────────────
  IntroPersonaKey.maleUnder23: IntroSlide3TrustModel(
    headerTitle: 'صحابك وعيلتك في اللعبة',
    headerSubtitle:
        'شوف منتجات القريبين منك، استشير صحابك،\nوابدأ تبديل بثقة.',
    members: const [
      IntroTrustMemberModel(
        label: 'صديق',
        imageAsset: 'assets/images/products/young_male_network_center.webp',
      ),
      IntroTrustMemberModel(
        label: 'أخ',
        imageAsset: 'assets/images/products/young_male_network_top_right.webp',
      ),
      IntroTrustMemberModel(
        label: 'قريب',
        imageAsset: 'assets/images/products/adult_male_profile_profile.jpg',
      ),
      IntroTrustMemberModel(
        label: 'أخت',
        imageAsset: 'assets/images/products/young_female_network_alt_top_right.jpg',
      ),
    ],
    trustBadgeTitle: 'تبديل أكثر أماناً مع من تثق بهم',
    trustBadgeSubtitle: 'منتجات من شبكتك أقرب ليك،\nوتجربة تبديل أسهل وأسرع',
    networkProducts: const [
      IntroNetworkProductModel(
        title: 'Iphone',
        imageAsset: 'assets/images/products/iphone.jpg',
        fromLabel: 'من صديقك',
        conditionLabel: 'حالة ممتازة',
      ),
      IntroNetworkProductModel(
        title: 'ليجو برمجة',
        imageAsset: 'assets/images/products/robot_closeup.jpg',
        fromLabel: 'من أخوك',
        conditionLabel: 'حالة جيدة جداً',
      ),
      IntroNetworkProductModel(
        title: 'بلاي استيشن',
        imageAsset: 'assets/images/products/18_ps5_console_closeup.jpg',
        fromLabel: 'من قريبك',
        conditionLabel: 'حالة ممتازة',
      ),
    ],
    sharePromptTitle: 'استشارة الأصحاب قبل التبديل',
  ),

  // ── أنثى 23+ ─────────────────────────────────────────────────────────────
  IntroPersonaKey.female23Plus: IntroSlide3TrustModel(
    headerTitle: 'بدّلي مع العيلة والصحاب بثقة',
    headerSubtitle:
        'شبكة العائلة والأصدقاء تساعدك تشوفي منتجات\nالقريبين منك.',
    members: const [
      IntroTrustMemberModel(
        label: 'أخت',
        imageAsset: 'assets/images/products/young_female_network_alt_top_right.jpg',
      ),
      IntroTrustMemberModel(
        label: 'صديقة',
        imageAsset: 'assets/images/products/young_female_network_alt_center.webp',
      ),
      IntroTrustMemberModel(
        label: 'قريب',
        imageAsset: 'assets/images/products/adult_male_profile_profile.jpg',
      ),
      IntroTrustMemberModel(
        label: 'ابنة',
        imageAsset: 'assets/images/products/young_female_network_alt_bottom_right.jpg',
      ),
    ],
    trustBadgeTitle: 'مجتمع موثوق',
    trustBadgeSubtitle: 'تبديل آمن مع ناس تعرفيهم وتثقي فيهم',
    networkProducts: const [
      IntroNetworkProductModel(
        title: 'اناقة',
        imageAsset: 'assets/images/products/04_dress_bag_accessories.png',
        fromLabel: 'من أختك',
        conditionLabel: 'مناسب لك',
      ),
      IntroNetworkProductModel(
        title: 'منظم ادوات',
        imageAsset: 'assets/images/products/adult_female_storage_boxes.webp',
        fromLabel: 'من صديقتك',
        conditionLabel: 'مناسب لك',
      ),
      IntroNetworkProductModel(
        title: 'ادوات مطبخ',
        imageAsset: 'assets/images/products/adult_female_mixer.webp',
        fromLabel: 'من عائلتك',
        conditionLabel: 'مناسب لك',
      ),
    ],
    sharePromptTitle: 'شاركي فرصة التبديل واسأني أصحابك',
  ),

  // ── أنثى أقل من 23 ───────────────────────────────────────────────────────
  IntroPersonaKey.femaleUnder23: IntroSlide3TrustModel(
    headerTitle: 'بدّلي مع العيلة والصحاب بثقة',
    headerSubtitle:
        'شبكة العائلة والأصدقاء تساعدك تشوفي منتجات\nالقريبين منك.',
    members: const [
      IntroTrustMemberModel(
        label: 'أخت',
        imageAsset: 'assets/images/products/young_female_network_alt_top_right.jpg',
      ),
      IntroTrustMemberModel(
        label: 'صديقة',
        imageAsset: 'assets/images/products/young_female_network_alt_bottom_right.jpg',
      ),
      IntroTrustMemberModel(
        label: 'قريبة',
        imageAsset: 'assets/images/products/young_female_network_alt_center.webp',
      ),
      IntroTrustMemberModel(
        label: 'أخ',
        imageAsset: 'assets/images/products/adult_male_profile_profile.jpg',
      ),
    ],
    trustBadgeTitle: 'مجتمع موثوق',
    trustBadgeSubtitle: 'تبديل آمن مع ناس تعرفيهم وتثقي فيهم',
    networkProducts: const [
      IntroNetworkProductModel(
        title: 'شنطة براند',
        imageAsset: 'assets/images/products/adult_female_handbag.webp',
        fromLabel: 'من أختك',
        conditionLabel: 'مناسب لك',
      ),
      IntroNetworkProductModel(
        title: 'مجموعة ميك أب',
        imageAsset: 'assets/images/products/makeup_organizer.webp',
        fromLabel: 'من صديقتك',
        conditionLabel: 'مناسب لك',
      ),
      IntroNetworkProductModel(
        title: 'سماعات لاسلكية',
        imageAsset: 'assets/images/products/lavender_wireless_earbuds.webp',
        fromLabel: 'من قريبتك',
        conditionLabel: 'مناسب لك',
      ),
    ],
    sharePromptTitle: 'شاركي فرصة التبديل واسأني أصحابك',
  ),
};
