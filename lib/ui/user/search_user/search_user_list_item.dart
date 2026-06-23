import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/user.dart';

import '../../Product/taapdeel_selectable_user_widecard .dart';

class SearchUserVerticalListItem extends StatelessWidget {
  const SearchUserVerticalListItem({
    Key? key,
    required this.user,
    required this.currentUser,
    this.onTap,
    this.onFollowBtnTap,
    this.animationController,
    this.animation,
  }) : super(key: key);

  final User user;
  final String? currentUser;
  final Function? onTap;
  final Function? onFollowBtnTap;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    animationController?.forward();
    final bool isMe = (currentUser == user.userId);

    final Widget card = Stack(
      children: <Widget>[
        // ✅ نفس كارت widecard
        TaapdeelSelectableUserWidecard(
          userId: user.userId ?? '',
          name: (user.userName == null || user.userName!.trim().isEmpty)
              ? Utils.getString(context, 'default__user_name')
              : user.userName!.trim(),
          photoHeroTag: 'search_user_${user.userId ?? ''}',
          imagePath: user.userProfilePhoto,
          selected: false,
          onTap: () {
            if (onTap != null) onTap!();
          },

          // لو عندك counts حقيقية ابعتها وهنوصلها
          itemsCount: null,
        ),

        // ✅ زر متابعة (بنفس logic القديم)
        if (!isMe)
          PositionedDirectional(
            top: 10,
            end: 10,
            child: _FollowMiniButton(
              isFollowing: user.isFollowed != PsConst.ZERO,
              onPressed: onFollowBtnTap as void Function()?,
            ),
          ),
      ],
    );

    // ✅ Animation زي ما هو
    return AnimatedBuilder(
      animation: animationController!,
      child: card,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform.translate(
            offset: Offset(0, 14 * (1.0 - animation!.value)),
            child: child,
          ),
        );
      },
    );
  }
}

class _FollowMiniButton extends StatelessWidget {
  const _FollowMiniButton({
    Key? key,
    required this.isFollowing,
    this.onPressed,
  }) : super(key: key);

  final bool isFollowing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color bg = isFollowing
        ? (PsColors.activeColor ?? PsColors.buttonColor)!.withOpacity(0.15)
        : (PsColors.buttonColor ?? Colors.black);

    final Color fg = isFollowing ? (PsColors.textColor1 ?? Colors.black) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isFollowing
                  ? (PsColors.textColor3 ?? Colors.grey).withOpacity(0.25)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            isFollowing
                ? Utils.getString(context, 'profile__following')
                : Utils.getString(context, 'profile__follow'),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ),
      ),
    );
  }
}
