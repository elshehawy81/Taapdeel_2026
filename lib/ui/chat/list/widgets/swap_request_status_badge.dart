import 'package:flutter/material.dart';
import 'package:taapdeel/ui/chat/list/swap_request_ui_status_helper.dart';
import 'package:taapdeel/viewobject/chat_history.dart';

import '../../enum/user_type.dart';

class SwapRequestStatusBadge extends StatelessWidget {
  const SwapRequestStatusBadge({
    Key? key,
    required this.request,
    required this.userType,
    this.compact = false,
  }) : super(key: key);

  final ChatHistory request;
  final UserType userType;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final SwapUiStatus status = SwapRequestUiStatusHelper.resolveUiStatus(
      request: request,
      userType: userType,
    );

    final _StatusPalette palette = _paletteFor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.border,
          width: 1,
        ),
      ),
      child: Text(
        _labelFor(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: palette.foreground,
          fontWeight: FontWeight.w800,
          fontSize: compact ? 11.5 : 12,
        ),
      ),
    );
  }

  String _labelFor(SwapUiStatus status) {
    switch (status) {
      case SwapUiStatus.waitingYourReply:
        return 'بانتظار ردك';
      case SwapUiStatus.waitingOtherSide:
        return 'بانتظار الطرف الآخر';
      case SwapUiStatus.inProgress:
        return 'جارٍ الاتفاق';
      case SwapUiStatus.completed:
        return 'مكتمل';
      case SwapUiStatus.cancelledOrRejected:
        return 'ملغي / مرفوض';
      case SwapUiStatus.all:
        return 'الكل';
    }
  }

  _StatusPalette _paletteFor(SwapUiStatus status) {
    switch (status) {
      case SwapUiStatus.waitingYourReply:
      case SwapUiStatus.waitingOtherSide:
        return const _StatusPalette(
          background: Color(0xFFFFF4E5),
          border: Color(0xFFF2D39B),
          foreground: Color(0xFFB26A00),
        );

      case SwapUiStatus.inProgress:
        return const _StatusPalette(
          background: Color(0xFFEAFBF1),
          border: Color(0xFFB8E3C8),
          foreground: Color(0xFF1D7A46),
        );

      case SwapUiStatus.completed:
        return const _StatusPalette(
          background: Color(0xFFF1EDFF),
          border: Color(0xFFD5C8FF),
          foreground: Color(0xFF6941C6),
        );

      case SwapUiStatus.cancelledOrRejected:
        return const _StatusPalette(
          background: Color(0xFFFDECEC),
          border: Color(0xFFF3C7C5),
          foreground: Color(0xFFB42318),
        );

      case SwapUiStatus.all:
        return const _StatusPalette(
          background: Color(0xFFEAF6F8),
          border: Color(0xFFBFE8EC),
          foreground: Color(0xFF0F6E76),
        );
    }
  }
}

class _StatusPalette {
  const _StatusPalette({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}