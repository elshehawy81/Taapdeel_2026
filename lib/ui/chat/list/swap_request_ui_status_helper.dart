import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/viewobject/chat_history.dart';

import '../enum/user_type.dart';

enum SwapUiStatus {
  all,
  waitingYourReply,
  waitingOtherSide,
  inProgress,
  completed,
  cancelledOrRejected,
}

class SwapUiStatusOption {
  const SwapUiStatusOption({
    required this.status,
    required this.label,
  });

  final SwapUiStatus status;
  final String label;
}

class SwapUiSummaryCounts {
  const SwapUiSummaryCounts({
    required this.total,
    required this.waitingYourReplyCount,
    required this.waitingOtherSideCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.cancelledOrRejectedCount,
  });

  final int total;
  final int waitingYourReplyCount;
  final int waitingOtherSideCount;
  final int inProgressCount;
  final int completedCount;
  final int cancelledOrRejectedCount;
}

class SwapRequestUiStatusHelper {
  static const List<SwapUiStatusOption> sellerFilterOptions =
  <SwapUiStatusOption>[
    SwapUiStatusOption(status: SwapUiStatus.all, label: 'الكل'),
    SwapUiStatusOption(
      status: SwapUiStatus.waitingYourReply,
      label: 'بانتظار ردك',
    ),
    SwapUiStatusOption(
      status: SwapUiStatus.inProgress,
      label: 'جارٍ الاتفاق',
    ),
    SwapUiStatusOption(
      status: SwapUiStatus.completed,
      label: 'مكتمل',
    ),
    SwapUiStatusOption(
      status: SwapUiStatus.cancelledOrRejected,
      label: 'ملغي / مرفوض',
    ),
  ];

  static const List<SwapUiStatusOption> buyerFilterOptions =
  <SwapUiStatusOption>[
    SwapUiStatusOption(status: SwapUiStatus.all, label: 'الكل'),
    SwapUiStatusOption(
      status: SwapUiStatus.waitingOtherSide,
      label: 'بانتظار الطرف الآخر',
    ),
    SwapUiStatusOption(
      status: SwapUiStatus.inProgress,
      label: 'جارٍ الاتفاق',
    ),
    SwapUiStatusOption(
      status: SwapUiStatus.completed,
      label: 'مكتمل',
    ),
    SwapUiStatusOption(
      status: SwapUiStatus.cancelledOrRejected,
      label: 'ملغي / مرفوض',
    ),
  ];

  static List<SwapUiStatusOption> filterOptionsFor(UserType userType) {
    if (userType == UserType.seller) {
      return sellerFilterOptions;
    }
    return buyerFilterOptions;
  }

  static SwapUiStatus resolveUiStatus({
    required ChatHistory request,
    required UserType userType,
  }) {
    final String offerStatus = (request.offerStatus ?? '').trim();

    switch (offerStatus) {
      case PsConst.REQUEST_PENDING:
        return _resolvePendingStatus(userType);

      case PsConst.REQUEST_ACCEPTED:
        return SwapUiStatus.inProgress;

      case PsConst.REQUEST_SWAPPED:
        return SwapUiStatus.completed;

      case PsConst.REQUEST_REJECTED:
        return SwapUiStatus.cancelledOrRejected;

      default:
        return _resolveUnknownStatus(userType);
    }
  }

  static SwapUiStatus _resolvePendingStatus(UserType userType) {
    if (userType == UserType.seller) {
      return SwapUiStatus.waitingYourReply;
    }
    return SwapUiStatus.waitingOtherSide;
  }

  static SwapUiStatus _resolveUnknownStatus(UserType userType) {
    if (userType == UserType.seller) {
      return SwapUiStatus.waitingYourReply;
    }
    return SwapUiStatus.waitingOtherSide;
  }

  static String labelForStatus(
      SwapUiStatus status, {
        required UserType userType,
      }) {
    switch (status) {
      case SwapUiStatus.all:
        return 'الكل';
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
    }
  }

  static String shortLabelForStatus(
      SwapUiStatus status, {
        required UserType userType,
      }) {
    switch (status) {
      case SwapUiStatus.all:
        return 'الكل';
      case SwapUiStatus.waitingYourReply:
        return 'بانتظارك';
      case SwapUiStatus.waitingOtherSide:
        return 'بانتظارهم';
      case SwapUiStatus.inProgress:
        return 'جارٍ الاتفاق';
      case SwapUiStatus.completed:
        return 'مكتمل';
      case SwapUiStatus.cancelledOrRejected:
        return 'مرفوض';
    }
  }

  static bool matchesFilter({
    required ChatHistory request,
    required UserType userType,
    required SwapUiStatus selectedFilter,
  }) {
    if (selectedFilter == SwapUiStatus.all) {
      return true;
    }

    return resolveUiStatus(
      request: request,
      userType: userType,
    ) ==
        selectedFilter;
  }

  static List<ChatHistory> filterRequests({
    required List<ChatHistory> requests,
    required UserType userType,
    required SwapUiStatus selectedFilter,
  }) {
    if (selectedFilter == SwapUiStatus.all) {
      return List<ChatHistory>.from(requests);
    }

    return requests.where((ChatHistory request) {
      return matchesFilter(
        request: request,
        userType: userType,
        selectedFilter: selectedFilter,
      );
    }).toList();
  }

  static SwapUiSummaryCounts buildSummaryCounts({
    required List<ChatHistory> requests,
    required UserType userType,
  }) {
    int waitingYourReplyCount = 0;
    int waitingOtherSideCount = 0;
    int inProgressCount = 0;
    int completedCount = 0;
    int cancelledOrRejectedCount = 0;

    for (final ChatHistory request in requests) {
      final SwapUiStatus status = resolveUiStatus(
        request: request,
        userType: userType,
      );

      switch (status) {
        case SwapUiStatus.all:
          break;
        case SwapUiStatus.waitingYourReply:
          waitingYourReplyCount++;
          break;
        case SwapUiStatus.waitingOtherSide:
          waitingOtherSideCount++;
          break;
        case SwapUiStatus.inProgress:
          inProgressCount++;
          break;
        case SwapUiStatus.completed:
          completedCount++;
          break;
        case SwapUiStatus.cancelledOrRejected:
          cancelledOrRejectedCount++;
          break;
      }
    }

    return SwapUiSummaryCounts(
      total: requests.length,
      waitingYourReplyCount: waitingYourReplyCount,
      waitingOtherSideCount: waitingOtherSideCount,
      inProgressCount: inProgressCount,
      completedCount: completedCount,
      cancelledOrRejectedCount: cancelledOrRejectedCount,
    );
  }

  static String primarySummaryLabelFor(UserType userType) {
    if (userType == UserType.seller) {
      return 'بانتظار ردك';
    }
    return 'بانتظار الطرف الآخر';
  }

  static int primarySummaryCountFor({
    required SwapUiSummaryCounts counts,
    required UserType userType,
  }) {
    if (userType == UserType.seller) {
      return counts.waitingYourReplyCount;
    }
    return counts.waitingOtherSideCount;
  }

  static String compactStatusLabel({
    required ChatHistory request,
    required UserType userType,
  }) {
    final SwapUiStatus status = resolveUiStatus(
      request: request,
      userType: userType,
    );

    return shortLabelForStatus(
      status,
      userType: userType,
    );
  }

  static int countForStatus({
    required List<ChatHistory> requests,
    required UserType userType,
    required SwapUiStatus status,
  }) {
    if (status == SwapUiStatus.all) {
      return requests.length;
    }

    return requests.where((ChatHistory request) {
      return resolveUiStatus(
        request: request,
        userType: userType,
      ) ==
          status;
    }).length;
  }

  static Map<SwapUiStatus, int> buildFilterCounts({
    required List<ChatHistory> requests,
    required UserType userType,
  }) {
    final Map<SwapUiStatus, int> counts = <SwapUiStatus, int>{
      SwapUiStatus.all: requests.length,
      SwapUiStatus.waitingYourReply: 0,
      SwapUiStatus.waitingOtherSide: 0,
      SwapUiStatus.inProgress: 0,
      SwapUiStatus.completed: 0,
      SwapUiStatus.cancelledOrRejected: 0,
    };

    for (final ChatHistory request in requests) {
      final SwapUiStatus status = resolveUiStatus(
        request: request,
        userType: userType,
      );

      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  static int countForOption({
    required SwapUiStatusOption option,
    required Map<SwapUiStatus, int> counts,
  }) {
    return counts[option.status] ?? 0;
  }

  static bool isOptionEmpty({
    required SwapUiStatusOption option,
    required Map<SwapUiStatus, int> counts,
  }) {
    return countForOption(
      option: option,
      counts: counts,
    ) ==
        0;
  }

  static int visualPriorityForStatus(SwapUiStatus status) {
    switch (status) {
      case SwapUiStatus.waitingYourReply:
      case SwapUiStatus.waitingOtherSide:
        return 1;
      case SwapUiStatus.inProgress:
        return 2;
      case SwapUiStatus.completed:
        return 3;
      case SwapUiStatus.cancelledOrRejected:
        return 4;
      case SwapUiStatus.all:
        return 99;
    }
  }

  static bool isActionableStatus(SwapUiStatus status) {
    switch (status) {
      case SwapUiStatus.waitingYourReply:
      case SwapUiStatus.waitingOtherSide:
      case SwapUiStatus.inProgress:
        return true;
      case SwapUiStatus.completed:
      case SwapUiStatus.cancelledOrRejected:
      case SwapUiStatus.all:
        return false;
    }
  }

  static String groupPrimaryLabel({
    required List<ChatHistory> requests,
    required UserType userType,
  }) {
    if (requests.isEmpty) {
      return primarySummaryLabelFor(userType);
    }

    final SwapUiSummaryCounts counts = buildSummaryCounts(
      requests: requests,
      userType: userType,
    );

    final int primaryCount = primarySummaryCountFor(
      counts: counts,
      userType: userType,
    );

    if (primaryCount > 0) {
      return primarySummaryLabelFor(userType);
    }

    if (counts.inProgressCount > 0) {
      return 'جارٍ الاتفاق';
    }

    if (counts.completedCount > 0) {
      return 'مكتمل';
    }

    if (counts.cancelledOrRejectedCount > 0) {
      return 'ملغي / مرفوض';
    }

    return primarySummaryLabelFor(userType);
  }

  static List<ChatHistory> sortRequestsByVisualPriority({
    required List<ChatHistory> requests,
    required UserType userType,
  }) {
    final List<ChatHistory> sorted = List<ChatHistory>.from(requests);

    sorted.sort((a, b) {
      final SwapUiStatus statusA = resolveUiStatus(
        request: a,
        userType: userType,
      );
      final SwapUiStatus statusB = resolveUiStatus(
        request: b,
        userType: userType,
      );

      final int priorityA = visualPriorityForStatus(statusA);
      final int priorityB = visualPriorityForStatus(statusB);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      final String dateA = (a.addedDateStr ?? '').trim();
      final String dateB = (b.addedDateStr ?? '').trim();

      return dateB.compareTo(dateA);
    });

    return sorted;
  }
}