import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/user.dart';

import '../../Product/taapdeel_selectable_user_card.dart';

/// ✅ بدل UserVerticalListItem -> عنصر أفقي يعتمد على TaapdeelSelectableUserCard
class UserVerticalListItem extends StatelessWidget {
  const UserVerticalListItem({
    Key? key,
    required this.user,
    this.onTap,
    this.animationController,
    this.animation,
    this.width,
    this.compact = true,
    this.selected = false,
  }) : super(key: key);

  final User user;
  final VoidCallback? onTap;

  final AnimationController? animationController;
  final Animation<double>? animation;

  /// Width of card in horizontal list
  final double? width;

  /// compact style for small cards
  final bool compact;

  /// if you want to show selected check
  final bool selected;

  @override
  Widget build(BuildContext context) {
    // ✅ safe forward (sometimes null in legacy)
    if (animationController != null) {
      animationController!.forward();
    }

    final double cardWidth = width ?? (compact ? 118 : 140);

    // Hero tag (prefer unique stable)
    final String heroTag = '${user.userId}${PsConst.HERO_TAG__IMAGE}';

    // user fields
    final String name = (user.userName ?? '').toString().trim();
    final String? imagePath = user.userProfilePhoto;

    // These fields might exist in your User model (based on earlier usage)
    final String? gender = (user.userGender ?? '').toString().isEmpty ? null : user.userGender;
    final String? ageRange = (user.userAge ?? '').toString().isEmpty ? null : user.userAge;

    // If you have a real field, replace here:
    // final int? itemsCount = user.itemCount;
    final int? itemsCount = null;

    final Widget card = SizedBox(
      width: cardWidth,
      child: TaapdeelSelectableUserCircleCard(
        //width: double.infinity,
        userId: (user.userId ?? '').toString(),
        name: name.isEmpty ? Utils.getString(context, 'default__user_name') : name,
        photoHeroTag: heroTag,
        imagePath: imagePath,
        gender: gender,
        ageRange: ageRange,
        selected: selected,
       //compact: compact,

        onTap: onTap ?? () {},
      ),
    );

    // ✅ If no animation provided, return direct
    if (animationController == null || animation == null) {
      return card;
    }

    // ✅ Horizontal slide-in animation (from right)
    return AnimatedBuilder(
      animation: animationController!,
      child: card,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform.translate(
            offset: Offset(40 * (1.0 - animation!.value), 0),
            child: child,
          ),
        );
      },
    );
  }
}
