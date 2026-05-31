import '../models/intro_models.dart';

final Map<IntroPersonaKey, IntroPersonaModel> introPersonaContent = {
  IntroPersonaKey.male23Plus: IntroPersonaModel(
    headerTitle: 'انت اغني مما تتخيل \n\n بيتك مليان حاجات غير مستخدمة',
    topBlock: const IntroBlockModel(
      title: 'صفقات أسرع… واختيارات أذكى',
      imageAsset: 'assets/images/products/01_mens_clothes.jpg',
    ),
    middleBlock: const IntroBlockModel(
      title: 'وفر وقتك وفلوسك \n(بيع وشراء ومشاوير)',
      imageAsset: 'assets/images/products/05_gaming_setup_white.jpg',
    ),
    bottomBlock: const IntroBlockModel(
      title: 'التبديل أذكى من البيع والشراء',
      imageAsset: 'assets/images/products/fitness_set.jpg',
    ),
  ),
  IntroPersonaKey.maleUnder23: IntroPersonaModel(
    headerTitle: 'تبديل بيعرض منتجات على مزاجك',
    topBlock: const IntroBlockModel(
      title: 'صفقات أسرع… واختيارات أذكى',
      imageAsset: 'assets/images/products/04_gaming_desk_dark.jpg',
    ),
    middleBlock: const IntroBlockModel(
      title: 'نفسك فى مغامرة جديدة\n بدّل حاجات القديمة بحاجة أقوى وأمتع',
      imageAsset: 'assets/images/products/03_stem_robotics.jpg',
    ),
    bottomBlock: const IntroBlockModel(
      title: 'التبديل أذكى من البيع والشراء',
      imageAsset: 'assets/images/products/fitness_set.jpg',
    ),
  ),
  IntroPersonaKey.female23Plus: IntroPersonaModel(
    headerTitle: 'تبديل بيعرض منتجات تناسب اهتماماتك',
    topBlock: const IntroBlockModel(
      title: 'أناقة متجددة\nالتبديل أذكى من البيع والشراء',
      imageAsset: 'assets/images/products/13_pastel_fashion_set.jpg',
    ),
    middleBlock: const IntroBlockModel(
      title: 'وفري وقتك وفلوسك \n(بيع وشراء ومشاوير)',
      imageAsset: 'assets/images/products/hobbies.png',
    ),
    bottomBlock: const IntroBlockModel(
      title: 'اهتماماتك أولاً\nصفقات أسرع… واختيارات أذكى',
      imageAsset: 'assets/images/products/fitness.jpg',
    ),
  ),
  IntroPersonaKey.femaleUnder23: IntroPersonaModel(
    headerTitle: 'تبديل بيعرض منتجات تناسب اهتماماتك',
    topBlock: const IntroBlockModel(
      title: 'وفري وقتك وفلوسك \nبدلي بمنتجات منابه لك',
      imageAsset: 'assets/images/products/young_female_network_headphones_alt.webp',
    ),
    middleBlock: const IntroBlockModel(
      title: 'أناقة متجددة\nالتبديل أذكى من البيع والشراء',
      imageAsset: 'assets/images/products/fitness.jpg',
    ),
    bottomBlock: const IntroBlockModel(
      title: 'لمسة جديدة ليكي \nصفقات أسرع… واختيارات أذكى',
      imageAsset: 'assets/images/products/outfi.png',
    ),
  ),
};
