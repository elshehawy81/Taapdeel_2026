import 'package:flutter/material.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/user_intent_holder.dart';
import 'package:taapdeel/viewobject/noti.dart';

// ---------------------------------------------------------------------------
// NotificationRoutingHelper - النسخة البسيطة والآمنة
// Routes a Noti object (from the list) to the correct screen.
// Also used by the FCM NotificationService for push-tap deep links.
// ---------------------------------------------------------------------------

/// Callback للوصول إلى Dashboard navigation
typedef DashboardNavigator = void Function(int tabIndex);

class NotificationRoutingHelper {
  NotificationRoutingHelper._();

  /// متغير عام لتخزين الـ Dashboard navigator
  /// استدعها من dashboard_view.dart في initState
  static DashboardNavigator? _dashboardNavigator;

  /// سجل الـ Dashboard navigator (استدعها من dashboard_view في initState)
  ///
  /// مثال الاستخدام في dashboard_view.dart:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   NotificationRoutingHelper.registerDashboardNavigator((tabIndex) {
  ///     goToBottomTab(tabIndex);
  ///   });
  /// }
  /// ```
  static void registerDashboardNavigator(DashboardNavigator? navigator) {
    _dashboardNavigator = navigator;
  }

  /// Called when user taps a typed notification in the list.
  static void navigateFromNoti({
    required BuildContext context,
    required Noti noti,
  }) {
    navigateFromData(
      context: context,
      data: <String, dynamic>{
        'type':       noti.notiType   ?? '',
        'item_id':    noti.itemId     ?? '',
        'product_id': noti.productId  ?? '',
        'sender_id':  noti.senderId ?? noti.senderUserId ?? '',
        'sender_name': noti.senderName ?? '',
        'request_id': noti.requestId ?? '',
        'chat_id': noti.chatId ?? '',
        'route': noti.route ?? '',
      },
    );
  }

  /// Called by NotificationService when a push notification is tapped.
  static void navigateFromData({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) {
    final String type       = data['type']        as String? ?? '';
    final String itemId     = data['item_id']     as String? ?? '';
    final String productId  = data['product_id']  as String? ?? '';
    final String senderId   = data['sender_id']   as String? ?? '';
    final String senderName = data['sender_name'] as String? ?? '';

    final NavigatorState nav = Navigator.of(context);

    switch (type) {

    // ── Swap ──────────────────────────────────────────────────────────────
      case 'swap_request_received':
      case 'swap_request_accepted':
      case 'swap_request_rejected':
      case 'swap_request_completed':
      case 'swap_request_in_progress':
      case 'swap_status_changed':
        _goToSwapsTab(context);
        break;

    // ── Offer ─────────────────────────────────────────────────────────────
      case 'offer_received':
      case 'offer_accepted':
      case 'offer_rejected':
        nav.pushNamed(RoutePaths.offerList);
        break;

    // ── Chat ──────────────────────────────────────────────────────────────
    // فتح التاب الخاص بالتبديلات بدل chatListScreen
      case 'chat_message':
      case 'chat_message_received':
        _goToSwapsTab(context);
        break;

    // ── Sweet Message ──────────────────────────────────────────────────────
      case 'sweet_message_received':
      case 'sweet_message_replied':
        if (senderId.isNotEmpty) {
          _openUserProfile(context, senderId, senderName);
        } else {
          nav.pushNamed(RoutePaths.notiList);
        }
        break;

    // ── Social ────────────────────────────────────────────────────────────
      case 'follow_request_received':
      case 'relation_request_received':
        nav.pushNamed(RoutePaths.followRequests);
        break;

      case 'follow_request_accepted':
      case 'relation_request_accepted':
        if (senderId.isNotEmpty) {
          _openUserProfile(context, senderId, senderName);
        } else {
          nav.pushNamed(RoutePaths.notiList);
        }
        break;

      case 'family_product_added':
        if (productId.isNotEmpty) {
          nav.pushNamed(
            RoutePaths.productDetail,
            arguments: ProductDetailIntentHolder(
              productId:    productId,
              heroTagImage: '',
              heroTagTitle: '',
            ),
          );
        }
        break;

    // ── Wish / Opportunity ────────────────────────────────────────────────
      case 'wish_match_found':
      case 'wish_item_matched':
        nav.pushNamed(RoutePaths.wishItemEntry);
        break;

      case 'swap_opportunity':
      case 'golden_swap_found':
        if (productId.isNotEmpty) {
          nav.pushNamed(
            RoutePaths.productDetail,
            arguments: ProductDetailIntentHolder(
              productId:    productId,
              heroTagImage: '',
              heroTagTitle: '',
            ),
          );
        }
        break;

    // ── Badge / Promotion / Approval ──────────────────────────────────────
      case 'badge_earned':
      case 'promotion_expiring':
      case 'item_approved':
      case 'item_rejected':
        _openProfileDirectly(context);
        break;

    // ── Rating ────────────────────────────────────────────────────────────
      case 'rating_received':
        if (senderId.isNotEmpty) {
          _openUserProfile(context, senderId, senderName);
        }
        break;

      case 'rating_reminder':
        nav.pushNamed(RoutePaths.receivedSwapRequests);
        break;

    // ── Fallback ──────────────────────────────────────────────────────────
      default:
        nav.pushNamed(RoutePaths.notiList);
        break;
    }
  }

  /// فتح التاب الخاص بالتبديلات (التاب الثاني)
  static void _goToSwapsTab(BuildContext context) {
    // الخيار 1: استخدام الـ registered navigator
    if (_dashboardNavigator != null) {
      _dashboardNavigator!(1);  // 1 = التاب الثاني (Swaps)
      return;
    }

    // الخيار 2: Fallback - استخدام pushNamed
    Navigator.of(context).pushNamed(RoutePaths.chatListScreen);
  }

  /// فتح البروفايل الخاص بـ user معين
  static void _openUserProfile(BuildContext context, String userId, String userName) {
    // الخيار 1: استخدام الـ registered navigator
    if (_dashboardNavigator != null) {
      _dashboardNavigator!(4);  // 4 = تاب البروفايل
      return;
    }

    // الخيار 2: Fallback - استخدام pushNamed
    Navigator.of(context).pushNamed(
      RoutePaths.userDetail,
      arguments: UserIntentHolder(
        userId:   userId,
        userName: userName,
      ),
    );
  }

  /// فتح البروفايل الخاص بالمستخدم الحالي (للمنتجات المرفوضة/الموافق عليها)
  static void _openProfileDirectly(BuildContext context) {
    // الخيار 1: استخدام الـ registered navigator
    if (_dashboardNavigator != null) {
      _dashboardNavigator!(4);  // 4 = تاب البروفايل
      return;
    }

    // الخيار 2: Fallback - الذهاب للـ notification list
    Navigator.of(context).pushNamed(RoutePaths.notiList);
  }
}
