import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';

import '../../../viewobject/noti.dart';

class NotiListItem extends StatelessWidget {
  const NotiListItem({
    Key? key,
    required this.noti,
    this.animationController,
    this.animation,
    this.onTap,
  }) : super(key: key);

  final Noti noti;
  final VoidCallback? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;

  // ── Notification type → icon + color ─────────────────────────────────────
  static const Map<String, _NotiStyle> _styleMap = {
    'swap_request_received':  _NotiStyle(Icons.swap_horiz_rounded,       Color(0xFF1D9E75)),
    'swap_request_accepted':  _NotiStyle(Icons.check_circle_outline,      Color(0xFF1D9E75)),
    'swap_request_rejected':  _NotiStyle(Icons.cancel_outlined,           Color(0xFFE24B4A)),
    'swap_request_completed': _NotiStyle(Icons.celebration_outlined,      Color(0xFF1D9E75)),
    'swap_status_changed':    _NotiStyle(Icons.update,                    Color(0xFF1D9E75)),
    'swap_request_in_progress': _NotiStyle(Icons.update,                 Color(0xFF1D9E75)),
    'offer_received':         _NotiStyle(Icons.local_offer_outlined,      Color(0xFFBA7517)),
    'offer_accepted':         _NotiStyle(Icons.local_offer_outlined,      Color(0xFF1D9E75)),
    'offer_rejected':         _NotiStyle(Icons.local_offer_outlined,      Color(0xFFE24B4A)),
    'chat_message':           _NotiStyle(Icons.chat_bubble_outline,       Color(0xFF378ADD)),
    'chat_message_received':  _NotiStyle(Icons.chat_bubble_outline,       Color(0xFF378ADD)),
    'sweet_message_received': _NotiStyle(Icons.favorite_outline,          Color(0xFFD4537E)),
    'sweet_message_replied':  _NotiStyle(Icons.reply_outlined,            Color(0xFFD4537E)),
    'follow_request_received':_NotiStyle(Icons.person_add_outlined,       Color(0xFF7F77DD)),
    'follow_request_accepted':_NotiStyle(Icons.how_to_reg_outlined,       Color(0xFF7F77DD)),
    'family_product_added':   _NotiStyle(Icons.home_outlined,             Color(0xFF7F77DD)),
    'wish_match_found':       _NotiStyle(Icons.star_outline,              Color(0xFFBA7517)),
    'wish_item_matched':      _NotiStyle(Icons.star_outline,              Color(0xFFBA7517)),
    'swap_opportunity':       _NotiStyle(Icons.emoji_events_outlined,     Color(0xFFBA7517)),
    'golden_swap_found':      _NotiStyle(Icons.emoji_events_outlined,     Color(0xFFBA7517)),
    'badge_earned':           _NotiStyle(Icons.military_tech_outlined,    Color(0xFFBA7517)),
    'promotion_expiring':     _NotiStyle(Icons.timer_outlined,            Color(0xFFBA7517)),
    'rating_received':        _NotiStyle(Icons.star_half_outlined,        Color(0xFF378ADD)),
    'rating_reminder':        _NotiStyle(Icons.rate_review_outlined,      Color(0xFF378ADD)),
    'item_approved':          _NotiStyle(Icons.verified_outlined,         Color(0xFF1D9E75)),
    'item_rejected':          _NotiStyle(Icons.error_outline,             Color(0xFFE24B4A)),
    'relation_request_received': _NotiStyle(Icons.family_restroom_outlined, Color(0xFF7F77DD)),
    'relation_request_accepted': _NotiStyle(Icons.family_restroom_outlined, Color(0xFF7F77DD)),
  };

  _NotiStyle get _style =>
      _styleMap[noti.notiType ?? ''] ??
      const _NotiStyle(Icons.notifications_outlined, Color(0xFF888780));

  bool get _isUnread => noti.isRead == '0';

  @override
  Widget build(BuildContext context) {
    animationController!.forward();

    return AnimatedBuilder(
      animation: animationController!,
      child: _buildCard(context),
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 60 * (1.0 - animation!.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: PsDimens.space12, vertical: PsDimens.space4),
        decoration: BoxDecoration(
          color: _isUnread
              ? (_style.color.withOpacity(isDark ? 0.08 : 0.05))
              : PsColors.baseColor,
          borderRadius: BorderRadius.circular(PsDimens.space12),
          border: Border.all(
            color: _isUnread
                ? _style.color.withOpacity(0.2)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PsDimens.space12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Type icon (replaces thumbnail for type-based notis) ───
              _buildLeadingIcon(context),

              const SizedBox(width: PsDimens.space12),

              // ── Content ──────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      noti.displayTitle,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: _isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            height: 1.35,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (noti.displayBody.isNotEmpty &&
                        noti.displayBody != noti.displayTitle) ...[
                      const SizedBox(height: 3),
                      Text(
                        noti.displayBody,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.72),
                              height: 1.35,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: PsDimens.space4),

                    // Date
                    Text(
                      noti.addedDateStr ?? '',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ),

              // ── Unread dot ───────────────────────────────────────────
              if (_isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: PsDimens.space8),
                  decoration: BoxDecoration(
                    color: _style.color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    // If noti has a photo AND it's a generic broadcast, show the image
    if (noti.defaultPhoto != null &&
        noti.defaultPhoto!.imgPath != null &&
        noti.defaultPhoto!.imgPath!.isNotEmpty &&
        (noti.notiType == null || noti.notiType!.isEmpty)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(PsDimens.space10),
        child: SizedBox(
          width: PsDimens.space52,
          height: PsDimens.space52,
          child: PsNetworkImage(
            photoKey: '',
            defaultPhoto: noti.defaultPhoto,
            imageAspectRation: PsConst.Aspect_Ratio_1x,
            onTap: onTap,
          ),
        ),
      );
    }

    // Otherwise show type icon
    return Container(
      width: PsDimens.space52,
      height: PsDimens.space52,
      decoration: BoxDecoration(
        color: _style.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PsDimens.space12),
      ),
      child: Icon(
        _style.icon,
        color: _style.color,
        size: 24,
      ),
    );
  }
}

// ── Style data class ─────────────────────────────────────────────────────────
class _NotiStyle {
  const _NotiStyle(this.icon, this.color);
  final IconData icon;
  final Color color;
}
