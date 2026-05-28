import 'package:flutter/material.dart';

enum IntroPersonaKey { male23Plus, maleUnder23, female23Plus, femaleUnder23 }

// ─── Slide 1 ──────────────────────────────────────────────────────────────────

class IntroPersonaProfileModel {
  final String name;
  final String ageLabel; // e.g. "38 سنة" or "16 سنة"
  final String gender; // 'male' | 'female'
  final String headerTitle;
  final String headerSubtitle;
  final List<String> interests; // emoji + label pairs
  final List<IntroProductCardModel> products;
  final String footerHint;
  final String avatarAsset;

  const IntroPersonaProfileModel({
    required this.name,
    required this.ageLabel,
    required this.gender,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.interests,
    required this.products,
    required this.footerHint,
    required this.avatarAsset,
  });
}

class IntroProductCardModel {
  final String title;
  final String imageAsset;

  const IntroProductCardModel({
    required this.title,
    required this.imageAsset,
  });
}

// ─── Slide 2 ──────────────────────────────────────────────────────────────────

class IntroSlide2Model {
  final String headerTitle;
  final String headerSubtitle;
  final int compatibilityPercent;
  final String compatibilityLabel;
  final String myProductTitle;
  final String myProductImageAsset;
  final String suggestedProductTitle;
  final String suggestedProductImageAsset;
  final List<IntroReasonChipModel> reasons;
  final String footerAiLabel;

  const IntroSlide2Model({
    required this.headerTitle,
    required this.headerSubtitle,
    required this.compatibilityPercent,
    required this.compatibilityLabel,
    required this.myProductTitle,
    required this.myProductImageAsset,
    required this.suggestedProductTitle,
    required this.suggestedProductImageAsset,
    required this.reasons,
    required this.footerAiLabel,
  });
}

class IntroReasonChipModel {
  final IconData icon;
  final String label;

  const IntroReasonChipModel({
    required this.icon,
    required this.label,
  });
}

// ─── Slide 3 ──────────────────────────────────────────────────────────────────

class IntroSlide3TrustModel {
  final String headerTitle;
  final String headerSubtitle;
  final List<IntroTrustMemberModel> members;
  final String trustBadgeTitle;
  final String trustBadgeSubtitle;
  final List<IntroNetworkProductModel> networkProducts;
  final String sharePromptTitle;

  const IntroSlide3TrustModel({
    required this.headerTitle,
    required this.headerSubtitle,
    required this.members,
    required this.trustBadgeTitle,
    required this.trustBadgeSubtitle,
    required this.networkProducts,
    required this.sharePromptTitle,
  });
}

class IntroTrustMemberModel {
  final String label;
  final String imageAsset;

  const IntroTrustMemberModel({
    required this.label,
    required this.imageAsset,
  });
}

class IntroNetworkProductModel {
  final String title;
  final String imageAsset;
  final String fromLabel;
  final String conditionLabel;

  const IntroNetworkProductModel({
    required this.title,
    required this.imageAsset,
    required this.fromLabel,
    required this.conditionLabel,
  });
}

// ─── Legacy models (kept for compatibility) ───────────────────────────────────

class IntroBlockModel {
  final String title;
  final String imageAsset;

  const IntroBlockModel({
    required this.title,
    required this.imageAsset,
  });
}

class IntroPersonaModel {
  final String headerTitle;
  final IntroBlockModel topBlock;
  final IntroBlockModel middleBlock;
  final IntroBlockModel bottomBlock;

  const IntroPersonaModel({
    required this.headerTitle,
    required this.topBlock,
    required this.middleBlock,
    required this.bottomBlock,
  });
}

class IntroCarouselCardModel {
  final String title;
  final String subtitle;
  final String imageAsset;

  const IntroCarouselCardModel({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });
}

class IntroSlide2PersonaCarouselModel {
  final String title;
  final String subtitle;
  final List<IntroCarouselCardModel> cards;

  const IntroSlide2PersonaCarouselModel({
    required this.title,
    required this.subtitle,
    required this.cards,
  });
}

class IntroSlide3TagModel {
  final String text;
  final Alignment alignment;
  final Offset offset;

  const IntroSlide3TagModel({
    required this.text,
    required this.alignment,
    this.offset = Offset.zero,
  });
}

class IntroSlide3RecoCardModel {
  final String title;
  final String imageAsset;

  const IntroSlide3RecoCardModel({
    required this.title,
    required this.imageAsset,
  });
}

class IntroSlide3PersonaModel {
  final String title;
  final String subtitle;
  final String mainProductAsset;
  final List<IntroSlide3TagModel> tags;
  final List<IntroSlide3RecoCardModel> recoCards;

  const IntroSlide3PersonaModel({
    required this.title,
    required this.subtitle,
    required this.mainProductAsset,
    required this.tags,
    required this.recoCards,
  });
}
