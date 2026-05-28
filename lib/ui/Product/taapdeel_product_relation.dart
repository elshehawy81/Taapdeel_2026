import 'dart:ui';
import 'package:flutter/material.dart';

/// ✅ Relation Types (IDs)
class RelationIds {
  // Direct
  static const int friends = 1;
  static const int spouse = 2;
  static const int child = 3;
  static const int parents = 4;
  static const int sibling = 5;
  static const int bigFamily = 6;

  static const int self = 777;

  // Level 2 (explicit)
  static const int friendOfFriend = 999; // صديق صديقك
  static const int friendsFamily = 1001; // عائلة صديقك
  static const int friendsBigFamily = 1002; // قريب صديقك
  static const int friendOfFamily = 1003; // صديق عائلتك
  static const int friendOfBigFamily = 1004; // صديق قريبك

  // Relatives bucket (any FAMILY_OF_*)
  static const int relatives = 1005; // أقاربك
}

/// ✅ helper: backend relation_code -> UI relationType (int)
int relationTypeFromBackendCode(String? code) {
  final c = (code ?? '').trim().toUpperCase();
  if (c.isEmpty || c == 'NONE') return 0;

  // Direct
  if (c == 'FAMILY') return RelationIds.parents;
  if (c == 'BIG_FAMILY') return RelationIds.bigFamily;
  if (c == 'FRIEND') return RelationIds.friends;
  if (c == 'SELF') return RelationIds.self;

  // Level 2 - Intermediate FRIEND
  if (c == 'FRIEND_OF_FRIEND') return RelationIds.friendOfFriend;
  if (c == 'FRIENDS_FAMILY') return RelationIds.friendsFamily;
  if (c == 'FRIENDS_BIG_FAMILY') return RelationIds.friendsBigFamily;

  // Level 2 - Intermediate FAMILY / BIG_FAMILY
  if (c == 'FRIEND_OF_FAMILY') return RelationIds.friendOfFamily;
  if (c == 'FRIEND_OF_BIG_FAMILY') return RelationIds.friendOfBigFamily;

  // ✅ Any FAMILY_OF_* => show as "اقاربك"
  if (c.startsWith('FAMILY_OF_')) return RelationIds.relatives;

  // Optional legacy
  if (c == 'FOF_LEVEL_3') return RelationIds.friendOfFriend;

  return 0;
}

/// ✅ UI config (reusable)
class TaapdeelRelationUI {
  final bool visible;
  final String label;      // label النهائي اللي بيتعرض
  final String? subLabel;
  final IconData icon;
  final Color bg;
  final Color border;
  final Color fg;

  // ✅ NEW
  final String? ownerName;
  final bool showOwnerWithRelation; // direct relations only

  const TaapdeelRelationUI({
    required this.visible,
    required this.label,
    required this.icon,
    required this.bg,
    required this.border,
    required this.fg,
    this.subLabel,
    this.ownerName,
    this.showOwnerWithRelation = false,
  });

  /// ✅ helper: build "Ahmed (عائلتك)" only when direct relation
  static String _composeLabel({
    required String baseRelationLabel,
    required String? ownerName,
    required bool showOwnerWithRelation,
  }) {
    final name = (ownerName ?? '').trim();
    if (!showOwnerWithRelation || name.isEmpty) return baseRelationLabel;
    return '$name ($baseRelationLabel)';
  }

  /// ✅ NEW: pass ownerName
  static TaapdeelRelationUI fromType(int? t, {String? ownerName}) {
    if (t == null || t == 0) {
      return const TaapdeelRelationUI(
        visible: false,
        label: '',
        icon: Icons.circle,
        bg: Colors.transparent,
        border: Colors.transparent,
        fg: Colors.transparent,
      );
    }

    final isStrongFamily =
        t == RelationIds.parents ||
            t == RelationIds.spouse ||
            t == RelationIds.child ||
            t == RelationIds.sibling;

    // ✅ direct relations: friend / family / relatives (bigFamily+relatives)
    final isDirectForOwner =
        isStrongFamily || t == RelationIds.friends || t == RelationIds.bigFamily || t == RelationIds.relatives;

    if (isStrongFamily) {
      final base = 'عائلتك';
      return TaapdeelRelationUI(
        visible: true,
        ownerName: ownerName,
        showOwnerWithRelation: true,
        label: _composeLabel(baseRelationLabel: base, ownerName: ownerName, showOwnerWithRelation: true),
        icon: Icons.family_restroom_rounded,
        bg: const Color(0xFF20BFA9).withAlpha(30),
        border: const Color(0xFF20BFA9).withAlpha(170),
        fg: Colors.white,
      );
    }

    if (t == RelationIds.friends) {
      final base = 'صديقك';
      return TaapdeelRelationUI(
        visible: true,
        ownerName: ownerName,
        showOwnerWithRelation: true,
        label: _composeLabel(baseRelationLabel: base, ownerName: ownerName, showOwnerWithRelation: true),
        icon: Icons.handshake_rounded,
        bg: const Color(0xFF2F8CFF).withAlpha(50),
        border: const Color(0xFF2F8CFF).withAlpha(140),
        fg: Colors.white,
      );
    }

    if (t == RelationIds.self) {
      return TaapdeelRelationUI(
        visible: true,
        label: 'منتجك',
        icon: Icons.person,
        bg: const Color(0xffffffff).withAlpha(35),
        border: const Color(0xffffffff).withAlpha(140),
        fg: Colors.white,
      );
    }

    if (t == RelationIds.bigFamily ) {
      final base = 'اقاربك';
      return TaapdeelRelationUI(
        visible: true,
        ownerName: ownerName,
        showOwnerWithRelation: true,
        label: _composeLabel(baseRelationLabel: base, ownerName: ownerName, showOwnerWithRelation: true),
        icon: Icons.family_restroom_rounded,
        bg: const Color(0xFF20BFA9).withAlpha(30),
        border: const Color(0xFF20BFA9).withAlpha(100),
        fg: Colors.white,
      );
    }

    if (t == RelationIds.relatives) {
      return TaapdeelRelationUI(
        visible: true,
        label: 'دائرة الاقارب',
        icon: Icons.family_restroom_rounded,
        bg: const Color(0xFF20BFA9).withAlpha(30),
        border: const Color(0xFF20BFA9).withAlpha(100),
        fg: Colors.white,
      );
    }

    // ✅ Level 2 (no owner name)
    if (t == RelationIds.friendOfFriend) {
      return TaapdeelRelationUI(
        visible: true,
        label: 'صديق صديقك',
        icon: Icons.group_rounded,
        bg: Colors.white.withAlpha(18),
        border: Colors.white.withAlpha(60),
        fg: Colors.white.withAlpha(230),
      );
    }

    if (t == RelationIds.friendsFamily) {
      return TaapdeelRelationUI(
        visible: true,
        label: 'عائلة صديقك',
        icon: Icons.family_restroom_rounded,
        bg: const Color(0xFF2F8CFF).withAlpha(35),
        border: const Color(0xFF2F8CFF).withAlpha(140),
        fg: Colors.white.withAlpha(230),
      );
    }

    if (t == RelationIds.friendsBigFamily) {
      return TaapdeelRelationUI(
        visible: true,
        label: 'قريب صديقك',
        icon: Icons.groups_rounded,
        bg: const Color(0xFF2F8CFF).withAlpha(35),
        border: const Color(0xff2563EB).withAlpha(140),
        fg: Colors.white.withAlpha(230),
      );
    }

    if (t == RelationIds.friendOfFamily) {
      return TaapdeelRelationUI(
        visible: true,
        label: 'صديق عائلتك',
        icon: Icons.handshake_rounded,
        bg: const Color(0xFF20BFA9).withAlpha(30),
        border: const Color(0xFF20BFA9).withAlpha(100),
        fg: Colors.white.withAlpha(230),
      );
    }

    if (t == RelationIds.friendOfBigFamily) {
      return TaapdeelRelationUI(
        visible: true,
        label: 'صديق قريبك',
        icon: Icons.handshake_rounded,
        bg: const Color(0xFF20BFA9).withAlpha(30),
        border: const Color(0xFF20BFA9).withAlpha(100),
        fg: Colors.white.withAlpha(230),
      );
    }

    return const TaapdeelRelationUI(
      visible: false,
      label: '',
      icon: Icons.circle,
      bg: Colors.transparent,
      border: Colors.transparent,
      fg: Colors.transparent,
    );
  }
}

/// ✅ Reusable widget
class TaapdeelRelationBar extends StatelessWidget {
  const TaapdeelRelationBar({
    Key? key,
    required this.ui,
    this.radius = 14,
    this.blur = 10,
  }) : super(key: key);

  final TaapdeelRelationUI ui;
  final double radius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    if (!ui.visible) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: ui.bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: ui.border),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisSize: MainAxisSize.min, // ✅ يخلي العرض على قد المحتوى
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(ui.icon, size: 12, color: ui.fg),
                const SizedBox(width: 8),

                // ✅ بدل Expanded (اللي بيفرد العرض)
                Flexible(
                  fit: FlexFit.loose, // ✅ يتمدد عند الحاجة فقط (ويحترم maxWidth من الأب)
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        ui.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ui.fg,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      if (ui.subLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          ui.subLabel!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ui.fg.withAlpha(220),
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
