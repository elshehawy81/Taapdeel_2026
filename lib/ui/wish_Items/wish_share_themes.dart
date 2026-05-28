import 'dart:math' as math;

import 'package:flutter/material.dart';


import '../item/share_theme/core/share_product_data.dart';
import '../item/share_theme/core/share_theme_definition.dart';
import '../item/share_theme/widgets/share_theme_helpers.dart';

class WishShareThemes {
  const WishShareThemes._();

  static List<ShareThemeDefinition> get themes => <ShareThemeDefinition>[
    ShareThemeDefinition(
      id: 'wish_dream_ticket',
      label: 'تذكرة الأمنية',
      subtitle: 'طلب واضح بشكل لطيف',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF0C587A), Color(0xFF24A9C4)],
      priority: 610,
      builder: _wishDreamTicket,
    ),
    ShareThemeDefinition(
      id: 'wish_search_radar',
      label: 'رادار البحث',
      subtitle: 'ندور عليه حوالين المستخدم',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF071B2F), Color(0xFF22C7B8)],
      priority: 611,
      builder: _wishSearchRadar,
    ),
    ShareThemeDefinition(
      id: 'wish_empty_shelf',
      label: 'مكانه فاضي',
      subtitle: 'كارت يحفز اللي عنده المنتج',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFFFF3D8), Color(0xFFD99B45)],
      priority: 612,
      builder: _wishEmptyShelf,
    ),
    ShareThemeDefinition(
      id: 'wish_swap_recipe',
      label: 'وصفة التبديل',
      subtitle: 'مكونات الصفقة المطلوبة',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF2F4F3A), Color(0xFFB8D89A)],
      priority: 613,
      builder: _wishSwapRecipe,
    ),
    ShareThemeDefinition(
      id: 'wish_mission_card',
      label: 'مهمة البحث',
      subtitle: 'Mission style للمنتج المطلوب',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFF2B2D42), Color(0xFFEF8354)],
      priority: 614,
      builder: _wishMissionCard,
    ),
    ShareThemeDefinition(
      id: 'wish_gift_hint',
      label: 'هدية منتظرة',
      subtitle: 'ستايل صندوق هدية',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFFFD6E8), Color(0xFFC45AA6)],
      priority: 615,
      builder: _wishGiftHint,
    ),
    ShareThemeDefinition(
      id: 'wish_market_note',
      label: 'نوتة السوق',
      subtitle: 'طلب بسيط وواضح',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFF6E7C8), Color(0xFF3D5A80)],
      priority: 616,
      builder: _wishMarketNote,
    ),
    ShareThemeDefinition(
      id: 'wish_missing_piece',
      label: 'القطعة الناقصة',
      subtitle: 'تصميم Puzzle لطيف',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFE8F7FF), Color(0xFF537FE7)],
      priority: 617,
      builder: _wishMissingPiece,
    ),
    ShareThemeDefinition(
      id: 'wish_clean_request',
      label: 'طلب شيك',
      subtitle: 'ستايل minimal راقي',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFF8FAFC), Color(0xFF0F2E57)],
      priority: 618,
      builder: _wishCleanRequest,
    ),
    ShareThemeDefinition(
      id: 'wish_chat_request',
      label: 'حد عنده؟',
      subtitle: 'ستايل محادثة لطيف',
      groups: const <ShareThemeGroup>[ShareThemeGroup.general],
      gradient: const <Color>[Color(0xFFE7FFF5), Color(0xFF36B37E)],
      priority: 619,
      builder: _wishChatRequest,
    ),
  ];

  static Widget _wishDreamTicket(BuildContext context, ShareProductData d) {
    const Color navy = Color(0xFF043757);
    const Color cyan = Color(0xFF24A9C4);
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: <Color>[Color(0xFFE8F8FB), Color(0xFFFFFFFF), Color(0xFFCFEFF5)])),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: cyan.withOpacity(0.35), width: 1.4), boxShadow: <BoxShadow>[BoxShadow(color: navy.withOpacity(0.14), blurRadius: 22, offset: const Offset(0, 10))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                decoration: const BoxDecoration(color: navy, borderRadius: BorderRadius.vertical(top: Radius.circular(23))),
                child: Row(children: <Widget>[const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 18), const SizedBox(width: 8), const Text('تذكرة أمنية', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)), const Spacer(), Text('#${_caseNo(d)}', style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 10, fontWeight: FontWeight.w800))]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: Column(children: <Widget>[
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(18), child: shareNetworkImage(d.imageUrl))),
                    const SizedBox(height: 12),
                    Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w900, height: 1.18)),
                    const SizedBox(height: 7),
                    Text(_wishLine(d), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF4B6472), fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.35)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _wishSearchRadar(BuildContext context, ShareProductData d) {
    const Color dark = Color(0xFF071B2F);
    const Color mint = Color(0xFF22C7B8);
    const Color mintBright = Color(0xFF46F5E2);

    final String price = sharePriceText(d);
    final String location = shareShortLocation(d.location);

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.12),
          radius: 1.02,
          colors: <Color>[Color(0xFF123C55), dark],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.22),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: mint.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: mintBright.withOpacity(0.18),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: mintBright,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'تبديل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'taapdeel',
                      style: TextStyle(
                        color: mintBright,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: _radarTopPill(
              text: 'رادار تبديل شغّال',
              icon: Icons.radar_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 86, 18, 18),
            child: Column(
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      const TextSpan(
                        text: 'حد عنده ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      TextSpan(
                        text: 'المنتج ده؟',
                        style: TextStyle(
                          color: mintBright,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          shadows: <Shadow>[
                            Shadow(
                              color: mintBright.withOpacity(0.25),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 10),
                Text(
                  d.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    if (location.isNotEmpty)
                      _radarInfoPill(
                        text: location,
                        icon: Icons.location_on_rounded,
                      ),
                    if (price.isNotEmpty)
                      _radarInfoPill(
                        text: 'في حدود $price',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 320,
                          height: 320,
                          child: CustomPaint(
                            painter: _WishRadarPainter(
                              ringColor: mint,
                              glowColor: mintBright,
                            ),
                          ),
                        ),
                        Container(
                          width: 176,
                          height: 176,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD7F5F0),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.85),
                              width: 4,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: mintBright.withOpacity(0.28),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: shareNetworkImage(d.imageUrl),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.favorite_border_rounded,
                      color: mintBright.withOpacity(0.95),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          children: <InlineSpan>[
                            const TextSpan(
                              text: 'المنتج ده ممكن يبقى عند حد... ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                height: 1.35,
                              ),
                            ),
                            TextSpan(
                              text: 'ساعد',
                              style: TextStyle(
                                color: mintBright,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const TextSpan(
                              text: ' في العثور عليه!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.send_rounded,
                      color: mintBright.withOpacity(0.95),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _radarTopPill({
    required String text,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC0B2033),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF22C7B8).withOpacity(0.75),
          width: 1.2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF22C7B8).withOpacity(0.20),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: const Color(0xFFBFFFF7), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _radarInfoPill({
    required String text,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x990A2237),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF22C7B8).withOpacity(0.70),
          width: 1.1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: const Color(0xFF22C7B8), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _wishEmptyShelf(BuildContext context, ShareProductData d) {
    const Color brown = Color(0xFF5E341B);
    const Color lightBrown = Color(0xFFB9854F);
    const Color beige = Color(0xFFF8F0E2);
    const Color beige2 = Color(0xFFFDF9F1);
    const Color shelfWood = Color(0xFFD7A76B);
    const Color shelfWoodDark = Color(0xFFC28A48);

    return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              beige,
              beige2,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFECCF9E),
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            children: <Widget>[
              // =========================
              // TOP TITLE
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _emptyShelfDoodle(
                    icon: Icons.favorite_border_rounded,
                    color: lightBrown,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'مكانه فاضي عندي',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: brown,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        shadows: <Shadow>[
                          Shadow(
                            color: Colors.white.withOpacity(0.45),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _emptyShelfDoodle(
                    icon: Icons.wb_sunny_outlined,
                    color: const Color(0xFFE7B45D),
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Container(
                width: 120,
                height: 16,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 1.4,
                        color: const Color(0xFFE6C38F),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.favorite,
                      size: 12,
                      color: Color(0xFFE0B06B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1.4,
                        color: const Color(0xFFE6C38F),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'لو عندك ${_kindLabel(d)}\nومش بتستخدمها... ممكن تكون هي دي اللي بدور عليها',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7A5B3D),
                  fontSize: 12.4,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              // =========================
              // CENTER SCENE
              // =========================
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    // shelf
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 46,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              shelfWood,
                              shelfWoodDark,
                            ],
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: brown.withOpacity(0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // vase left
                    Positioned(
                      left: 18,
                      bottom: 68,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 42,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2E4CF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE3C9A6),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: brown.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                // stems
                                Positioned(
                                  left: 16,
                                  top: -14,
                                  child: Transform.rotate(
                                    angle: -0.30,
                                    child: Container(
                                      width: 1.6,
                                      height: 26,
                                      color: const Color(0xFFD0A86C),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 22,
                                  top: -18,
                                  child: Transform.rotate(
                                    angle: 0.18,
                                    child: Container(
                                      width: 1.6,
                                      height: 30,
                                      color: const Color(0xFFD0A86C),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 10,
                                  top: -10,
                                  child: Transform.rotate(
                                    angle: -0.58,
                                    child: Container(
                                      width: 1.5,
                                      height: 20,
                                      color: const Color(0xFFD0A86C),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  top: -22,
                                  left: 6,
                                  child: Text(
                                    '✿',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFE2C089),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  top: -26,
                                  left: 18,
                                  child: Text(
                                    '✿',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFE2C089),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  top: -16,
                                  left: 24,
                                  child: Text(
                                    '✿',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFE2C089),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2B8A2),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: brown.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_border_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // question mark right
                    Positioned(
                      right: 26,
                      bottom: 86,
                      child: Text(
                        '?',
                        style: TextStyle(
                          color: const Color(0xFFE2B567),
                          fontSize: 104,
                          fontWeight: FontWeight.w900,
                          height: 0.85,
                          shadows: <Shadow>[
                            Shadow(
                              color: const Color(0xFFF3D9A4).withOpacity(0.9),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // product card
                    Positioned(
                      bottom: 62,
                      child: Container(
                        width: 195,
                        height: 195,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE7C38E),
                            width: 1.7,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: brown.withOpacity(0.10),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              top: 2,
                              left: 2,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1B59E),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: brown.withOpacity(0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: shareNetworkImage(d.imageUrl),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // =========================
              // PRODUCT TITLE
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '✨',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: brown,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '✨',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Container(
                width: 118,
                height: 14,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 1.2,
                        color: const Color(0xFFE2BE86),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.favorite,
                      size: 11,
                      color: Color(0xFFE1B266),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1.2,
                        color: const Color(0xFFE2BE86),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =========================
              // CTA BUTTON
              // =========================
              Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0xFF85512B),
                      Color(0xFF6A3B1F),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFD7A257),
                    width: 1.6,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: brown.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(
                      Icons.swap_horiz_rounded,
                      color: Color(0xFFF5D389),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'اعرضه للتبديل لو موجود عندك',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
    }

  static Widget _emptyShelfDoodle({
    required IconData icon,
    required Color color,
    double size = 18,
  }) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }

  static Widget _wishSwapRecipe(BuildContext context, ShareProductData d) {
    const Color green = Color(0xFF2F4F3A);
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFFF7FFF1), Color(0xFFE2F0D3)])),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFB8D89A), width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            const Text('وصفة صفقة حلوة', textAlign: TextAlign.center, style: TextStyle(color: green, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Expanded(child: Row(children: <Widget>[Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(18), child: shareNetworkImage(d.imageUrl))), const SizedBox(width: 12), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[_recipeStep('1', 'المنتج المطلوب', d.title), _recipeStep('2', 'الفئة', _kindLabel(d)), _recipeStep('3', 'النطاق', shareHas(sharePriceText(d)) ? sharePriceText(d) : 'تبديل مناسب')]))])),
            const SizedBox(height: 12),
            Text(_wishLine(d), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF4C6B55), fontSize: 12, fontWeight: FontWeight.w700, height: 1.35)),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('عندك حاجة شبهه؟ خلينا نبدّل', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w900))))
          ]),
        ),
      ),
    );
  }

  static Widget _wishMissionCard(BuildContext context, ShareProductData d) {
    const Color dark = Color(0xFF2B2D42);
    const Color orange = Color(0xFFEF8354);
    return Container(
      color: dark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Row(children: <Widget>[Container(padding: const EdgeInsets.all(9), decoration: const BoxDecoration(color: orange, shape: BoxShape.circle), child: const Icon(Icons.flag_outlined, color: Colors.white, size: 18)), const SizedBox(width: 9), const Expanded(child: Text('مهمة البحث عن منتج', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900))), Text('OPEN', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 14),
          Expanded(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: orange.withOpacity(0.85), width: 2)), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: shareNetworkImage(d.imageUrl)))),
          const SizedBox(height: 12),
          Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, height: 1.18)),
          const SizedBox(height: 9),
          Row(children: <Widget>[_missionBadge('الحالة', 'مطلوب'), const SizedBox(width: 8), _missionBadge('الكود', _caseNo(d)), const SizedBox(width: 8), _missionBadge('المكان', shareShortLocation(d.location).isEmpty ? 'قريب' : shareShortLocation(d.location))]),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(14)), child: Text('الهدف: نوصل لصاحب عنده المنتج ومهتم بصفقة تبديل عادلة.', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFE9DF), fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.35))),
        ]),
      ),
    );
  }

  static Widget _wishGiftHint(BuildContext context, ShareProductData d) {
    const Color pink = Color(0xFFC45AA6);
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: <Color>[Color(0xFFFFEFF7), Color(0xFFFFD6E8), Color(0xFFF6F1FF)])),
      child: Stack(children: <Widget>[
        const Positioned(top: 18, left: 18, child: Text('🎁', style: TextStyle(fontSize: 28))),
        const Positioned(bottom: 90, right: 18, child: Text('✨', style: TextStyle(fontSize: 22))),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: <Widget>[
            const Text('نفسه في الهدية دي', textAlign: TextAlign.center, style: TextStyle(color: pink, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('مش لازم تكون جديدة… المهم تكون مناسبة وتفرّح صاحب الطلب', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: pink.withOpacity(0.76), fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.35)),
            const SizedBox(height: 14),
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: <BoxShadow>[BoxShadow(color: pink.withOpacity(0.22), blurRadius: 24, offset: const Offset(0, 10))]), child: ClipRRect(borderRadius: BorderRadius.circular(22), child: shareNetworkImage(d.imageUrl)))),
            const SizedBox(height: 12),
            Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF7A2E67), fontSize: 17, fontWeight: FontWeight.w900, height: 1.2)),
            const SizedBox(height: 10),
            sharePill(text: 'عندك حاجة شبهها؟ اعمل عرض تبديل', bg: pink, fg: Colors.white, icon: Icons.favorite_border_rounded),
          ]),
        ),
      ]),
    );
  }

  static Widget _wishMarketNote(BuildContext context, ShareProductData d) {
    const Color ink = Color(0xFF263238);
    const Color blue = Color(0xFF3D5A80);
    return Container(
      color: const Color(0xFFF6E7C8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(10), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 14, offset: const Offset(0, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            Row(children: <Widget>[const Icon(Icons.checklist_rtl_rounded, color: blue, size: 22), const SizedBox(width: 8), const Expanded(child: Text('نوتة الحاجات المطلوبة', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900))), Container(width: 42, height: 42, decoration: const BoxDecoration(color: Color(0xFFE8D6B6), shape: BoxShape.circle), child: const Center(child: Text('✓', style: TextStyle(color: blue, fontSize: 22, fontWeight: FontWeight.w900))))]),
            const SizedBox(height: 12),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(14), child: shareNetworkImage(d.imageUrl))),
            const SizedBox(height: 12),
            _noteLine('عايز', d.title),
            _noteLine('الفئة', _kindLabel(d)),
            _noteLine('المكان', shareShortLocation(d.location).isEmpty ? 'أي مكان مناسب' : shareShortLocation(d.location)),
            _noteLine('الميزانية', shareHas(sharePriceText(d)) ? sharePriceText(d) : 'تبديل عادل'),
            const Spacer(),
            Text('لو عندك المنتج ومش محتاجه، ممكن يبقى صفقة حلوة على تبديل.', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: blue, fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.35)),
          ]),
        ),
      ),
    );
  }

  static Widget _wishMissingPiece(BuildContext context, ShareProductData d) {
    const Color blue = Color(0xFF537FE7);
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFFFFFFFF), Color(0xFFE8F7FF)])),
      child: Stack(children: <Widget>[
        const Positioned(top: 20, right: 18, child: Icon(Icons.extension_outlined, color: Color(0x33537FE7), size: 64)),
        const Positioned(bottom: 28, left: 18, child: Icon(Icons.extension_outlined, color: Color(0x22537FE7), size: 86)),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: <Widget>[
            const Text('القطعة الناقصة', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF1D3E8A), fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text('محتاجين نكمل الصورة بالمنتج ده', textAlign: TextAlign.center, style: TextStyle(color: blue.withOpacity(0.75), fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Expanded(child: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: blue.withOpacity(0.22), width: 1.5)), child: ClipRRect(borderRadius: BorderRadius.circular(26), child: shareNetworkImage(d.imageUrl)))),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF2F7FF), borderRadius: BorderRadius.circular(18), border: Border.all(color: blue.withOpacity(0.18))), child: Column(children: <Widget>[Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF1D3E8A), fontSize: 17, fontWeight: FontWeight.w900, height: 1.18)), const SizedBox(height: 7), Text(_wishLine(d), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF4E6FAF), fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.35))])),
            const SizedBox(height: 10),
            sharePill(text: 'ساعده يلاقيها', bg: blue, fg: Colors.white, icon: Icons.search_rounded),
          ]),
        ),
      ]),
    );
  }

  static Widget _wishCleanRequest(BuildContext context, ShareProductData d) {
    const Color dark = Color(0xFF0F2E57);
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Row(children: <Widget>[const Text('WISH ITEM', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)), const Spacer(), sharePill(text: 'طلب جديد', bg: const Color(0xFFE0F2FE), fg: dark)]),
          const SizedBox(height: 18),
          Expanded(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), boxShadow: <BoxShadow>[BoxShadow(color: dark.withOpacity(0.14), blurRadius: 25, offset: const Offset(0, 10))]), child: ClipRRect(borderRadius: BorderRadius.circular(28), child: shareNetworkImage(d.imageUrl)))),
          const SizedBox(height: 16),
          Text('بدور على', textAlign: TextAlign.right, style: TextStyle(color: dark.withOpacity(0.55), fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: dark, fontSize: 24, fontWeight: FontWeight.w900, height: 1.12)),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))), child: Text(_wishLine(d), textAlign: TextAlign.right, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w700, height: 1.45))),
          const SizedBox(height: 12),
          Row(children: <Widget>[if (shareHas(sharePriceText(d))) Expanded(child: sharePill(text: sharePriceText(d), bg: dark, fg: Colors.white)), if (shareHas(sharePriceText(d)) && shareHas(d.location)) const SizedBox(width: 8), if (shareHas(d.location)) Expanded(child: sharePill(text: shareShortLocation(d.location), bg: const Color(0xFFE2E8F0), fg: dark))]),
        ]),
      ),
    );
  }

  static Widget _wishChatRequest(BuildContext context, ShareProductData d) {
    const Color green = Color(0xFF36B37E);
    const Color dark = Color(0xFF064E3B);
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFFE7FFF5), Color(0xFFFFFFFF)])),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          _wishBubble('حد عنده المنتج ده؟', alignRight: true, bg: green, fg: Colors.white),
          const SizedBox(height: 8),
          _wishBubble('ممكن نعمل صفقة تبديل لطيفة 👀', alignRight: false, bg: Colors.white, fg: dark),
          const SizedBox(height: 12),
          Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: green.withOpacity(0.25)), boxShadow: <BoxShadow>[BoxShadow(color: green.withOpacity(0.14), blurRadius: 18, offset: const Offset(0, 8))]), child: ClipRRect(borderRadius: BorderRadius.circular(18), child: shareNetworkImage(d.imageUrl)))),
          const SizedBox(height: 12),
          Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: dark, fontSize: 18, fontWeight: FontWeight.w900, height: 1.18)),
          const SizedBox(height: 8),
          _wishBubble(_wishLine(d), alignRight: true, bg: const Color(0xFFDFF8EC), fg: dark),
          const SizedBox(height: 10),
          Center(child: sharePill(text: 'افتح تبديل وشوف الطلب', bg: green, fg: Colors.white, icon: Icons.chat_bubble_outline_rounded)),
        ]),
      ),
    );
  }

  static Widget _recipeStep(String no, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFF4FAEF), borderRadius: BorderRadius.circular(12)),
      child: Row(children: <Widget>[Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFF2F4F3A), shape: BoxShape.circle), child: Center(child: Text(no, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)))), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF6D8564), fontSize: 9, fontWeight: FontWeight.w800)), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF2F4F3A), fontSize: 12, fontWeight: FontWeight.w900))]))]),
    );
  }

  static Widget _missionBadge(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.08))),
        child: Column(children: <Widget>[Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.48), fontSize: 8.5, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))]),
      ),
    );
  }

  static Widget _noteLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Container(width: 9, height: 9, margin: const EdgeInsets.only(top: 5), decoration: const BoxDecoration(color: Color(0xFF3D5A80), shape: BoxShape.circle)), const SizedBox(width: 8), Expanded(child: Text('$label: $value', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF263238), fontSize: 12.5, fontWeight: FontWeight.w800)))]),
    );
  }

  static Widget _wishBubble(String text, {required bool alignRight, required Color bg, required Color fg}) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(alignRight ? 16 : 4), bottomRight: Radius.circular(alignRight ? 4 : 16)), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))]),
        child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(color: fg, fontSize: 11.8, fontWeight: FontWeight.w800, height: 1.3)),
      ),
    );
  }

  static Widget _boardingInfo(String label, String value) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF7FA0BE), fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _chatBubble(String text, {required bool alignRight, String? emoji}) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF6E4A82), fontSize: 11.2, fontWeight: FontWeight.w800, height: 1.25)),
          ),
          if (emoji != null)
            Positioned(
              top: -8,
              right: alignRight ? null : -8,
              left: alignRight ? -8 : null,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
        ],
      ),
    );
  }

  static Widget _evidenceBox(String label, String value) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF3D3D3D)), color: const Color(0xFF202020)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF806A1A), fontSize: 8, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFFF4C437), fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static Widget _goldFeature(String text, IconData icon) {
    const Color gold = Color(0xFFC9A84C);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF4A3800)), color: Colors.black), child: Icon(icon, size: 17, color: gold)),
        const SizedBox(height: 5),
        SizedBox(width: 72, child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9A7A3A), fontSize: 10, fontWeight: FontWeight.w700, height: 1.2))),
      ],
    );
  }

  static String _kindLabel(ShareProductData d) {
    if (shareHas(d.subCategory)) return d.subCategory;
    if (shareHas(d.category)) return d.category;
    return 'المنتج';
  }

  static String _ownerNick(ShareProductData d) {
    final String loc = shareShortLocation(d.location);
    if (loc.isEmpty) return 'صاحبه الحالي';
    return 'صاحبه الحالي من $loc';
  }

  static String _friendlyStatus(ShareProductData d) {
    if (shareHas(d.condition)) return 'حالته ${d.condition}';
    if (d.isNew) return 'لسه جديد';
    return 'لسه فيه خير كتير';
  }

  static String _wishLine(ShareProductData d) {
    final String price = sharePriceText(d);
    final String area = shareShortLocation(d.location);
    final String pricePart = shareHas(price) ? ' في حدود $price' : '';
    final String areaPart = area.isEmpty ? '' : ' قريب من $area';
    return 'بدور على ${_kindLabel(d)}$pricePart$areaPart. لو عندك حاجة مناسبة ومش محتاجها، اعمل عرض تبديل.';
  }

  static String _headlineFor(ShareProductData d) {
    return '${_kindLabel(d)} تبحث عن صاحب جديد';
  }

  static String _newspaperBody(ShareProductData d) {
    final String status = _friendlyStatus(d);
    final String loc = shareShortLocation(d.location);
    final String place = loc.isEmpty ? 'قريب منك' : 'في $loc';
    return 'بعد رحلة هادئة مع صاحبها الأول، وصلت ${_kindLabel(d)} إلى لحظة مهمة: بداية جديدة مع صاحب يقدرها. $status وموجودة $place.';
  }

  static String _adText(ShareProductData d) {
    final String usage = shareHas(d.usage) ? '، ${d.usage}' : '';
    final String condition = shareHas(d.condition) ? d.condition : 'بحالة طيبة';
    return 'للتبديل: ${d.title}، $condition$usage، مع جرعة اهتمام حقيقية أو إكسسوار في نفس النطاق.';
  }

  static String _letterText(ShareProductData d) {
    final String status = _friendlyStatus(d);
    return 'أنا ${_kindLabel(d)} اللي لسه عندي حكايات كتير. $status، ومحتاج بيت جديد يحبني ويستفيد مني. مش بطلب كتير، بس فرصة لطيفة وصاحب يقدرني ✨';
  }

  static String _wantedText(ShareProductData d) {
    final String loc = shareShortLocation(d.location);
    return '${_kindLabel(d)} لطيفة، $loc، ${_friendlyStatus(d)}. آخر مشاهدة على تبديل، لا تشكل أي خطر — لطيفة جداً 😅';
  }

  static String _chatLineOne(ShareProductData d) {
    return 'أنا ${_kindLabel(d)} كنت بتشغل/بتستخدم بكل حب، والآن يوم تالت بسأل: مين؟';
  }

  static String _chatLineTwo(ShareProductData d) {
    return 'اللي هيخدني هيمشي لوحده — وأنا وحيدة في الأوضة 🥺';
  }

  static String _diaryText(ShareProductData d) {
    return 'قررت أحطها على تبديل — مش عشان أتخلص منها، لكن عشان تلاقي حد يحتاجها أكتر مني. هي مش مجرد ${_kindLabel(d)}، دي فرصة صغيرة لبيت جديد وقصة جديدة 😅';
  }

  static String _stickyNoteText(ShareProductData d) {
    return 'خدوني تمام 💙 مش هنام في الدولاب كتير. تستاهل واحدة تحبها ✨';
  }

  static String _evidenceText(ShareProductData d) {
    return 'وجدنا ${_kindLabel(d)} في ${_friendlyStatus(d)}، لا خدوش مؤثرة، لا آثار إهمال، فقط رغبة صادقة في البحث عن صاحب جديد.';
  }

  static String _avatarEmoji(ShareProductData d) {
    final String text = '${d.category} ${d.subCategory} ${d.title}'.toLowerCase();
    if (text.contains('لعب') || text.contains('طفل') || text.contains('baby') || text.contains('toy')) return '👶';
    if (text.contains('كتاب') || text.contains('book')) return '📚';
    if (text.contains('رياض') || text.contains('كرة') || text.contains('sport')) return '🏆';
    if (text.contains('الكتر') || text.contains('إلكتر') || text.contains('mobile')) return '📱';
    if (text.contains('شنطة') || text.contains('حقيبة') || text.contains('bag')) return '👜';
    return '✨';
  }

  static String _productHandle(ShareProductData d) {
    final String base = _kindLabel(d).replaceAll(' ', '_');
    final String suffix = _caseNo(d);
    return '${base}_$suffix@taapdeel';
  }

  static String _caseNo(ShareProductData d) {
    final String seed = d.title.isEmpty ? d.idSeed : d.title;
    int sum = 0;
    for (int i = 0; i < seed.length; i++) {
      sum += seed.codeUnitAt(i);
    }
    return (sum % 900 + 100).toString();
  }

  static String _arabicDate() {
    final DateTime n = DateTime.now();
    const List<String> days = <String>['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    const List<String> months = <String>['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final String day = days[n.weekday - 1];
    final String month = months[n.month - 1];
    return '$day، ${n.day} $month ${n.year}';
  }

}


class _WishRadarPainter extends CustomPainter {
  const _WishRadarPainter({
    required this.ringColor,
    required this.glowColor,
  });

  final Color ringColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.shortestSide / 2) - 6;
    final Rect radarRect = Rect.fromCircle(center: center, radius: radius);

    final Path sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(radarRect, -0.72, 0.82, false)
      ..close();

    final Paint sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          glowColor.withOpacity(0.42),
          glowColor.withOpacity(0.18),
          glowColor.withOpacity(0.02),
        ],
        stops: const <double>[0.0, 0.65, 1.0],
      ).createShader(radarRect);

    canvas.drawPath(sweepPath, sweepPaint);

    final Paint sweepArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = glowColor.withOpacity(0.90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawArc(radarRect, -0.72, 0.82, false, sweepArcPaint);

    final Paint outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = ringColor.withOpacity(0.32);

    canvas.drawCircle(center, radius, outerRingPaint);

    final List<double> ringFactors = <double>[1.0, 0.82, 0.64, 0.46, 0.33];
    for (final double factor in ringFactors) {
      final Paint ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = factor == 1.0 ? 1.6 : 1
        ..color = ringColor.withOpacity(factor == 1.0 ? 0.18 : 0.14);
      canvas.drawCircle(center, radius * factor, ringPaint);
    }

    final Paint crossPaint = Paint()
      ..strokeWidth = 1
      ..color = ringColor.withOpacity(0.22);

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      crossPaint,
    );

    final Paint tickPaint = Paint()
      ..strokeWidth = 1
      ..color = ringColor.withOpacity(0.10);

    for (int i = 0; i < 48; i++) {
      final double angle = (i * 7.5) * math.pi / 180.0;
      final double tickStart = i.isEven ? radius - 13 : radius - 8;
      final double x1 = center.dx + tickStart * math.cos(angle);
      final double y1 = center.dy + tickStart * math.sin(angle);
      final double x2 = center.dx + radius * math.cos(angle);
      final double y2 = center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    _drawBlip(canvas, center.translate(-radius * 0.76, radius * 0.52), glowColor);
    _drawBlip(canvas, center.translate(-radius * 0.62, -radius * 0.22), glowColor);
    _drawBlip(canvas, center.translate(radius * 0.72, radius * 0.46), glowColor);
    _drawBlip(canvas, center.translate(radius * 0.52, -radius * 0.18), glowColor);
  }

  void _drawBlip(Canvas canvas, Offset point, Color color) {
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final Paint corePaint = Paint()..color = const Color(0xFFBFFFF7);

    canvas.drawCircle(point, 10, glowPaint);
    canvas.drawCircle(point, 4.8, corePaint);
  }

  @override
  bool shouldRepaint(covariant _WishRadarPainter oldDelegate) {
    return oldDelegate.ringColor != ringColor || oldDelegate.glowColor != glowColor;
  }
}

extension _ShareDataSeed on ShareProductData {
  String get idSeed => '$title$category$subCategory$price';
}
