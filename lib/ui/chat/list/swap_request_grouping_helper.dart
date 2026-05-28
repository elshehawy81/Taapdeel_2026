import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/viewobject/chat_history.dart';
import 'package:taapdeel/viewobject/product.dart';

import '../enum/user_type.dart';

class GroupedSwapRequests {
  GroupedSwapRequests({
    required this.groupKey,
    required this.anchorProduct,
    required this.requests,
    required this.userType,
  });

  final String groupKey;
  final Product anchorProduct;
  final List<ChatHistory> requests;
  final UserType userType;

  int get totalCount => requests.length;

  int get pendingCount => requests
      .where((ChatHistory r) => r.offerStatus == PsConst.REQUEST_PENDING)
      .length;

  int get acceptedCount => requests
      .where((ChatHistory r) => r.offerStatus == PsConst.REQUEST_ACCEPTED)
      .length;

  int get swappedCount => requests
      .where((ChatHistory r) => r.offerStatus == PsConst.REQUEST_SWAPPED)
      .length;

  int get rejectedCount => requests
      .where((ChatHistory r) => r.offerStatus == PsConst.REQUEST_REJECTED)
      .length;

  bool get hasMultipleRequests => requests.length > 1;

  List<ChatHistory> get previewRequests {
    if (requests.length <= 2) {
      return requests;
    }
    return requests.take(2).toList();
  }

  ChatHistory get latestRequest => requests.first;
}

class SwapRequestGroupingHelper {
  static List<GroupedSwapRequests> groupRequests({
    required List<ChatHistory> requests,
    required UserType userType,
  }) {
    final Map<String, List<ChatHistory>> groupedMap =
    <String, List<ChatHistory>>{};

    for (final ChatHistory request in requests) {
      final Product? anchorProduct =
      _resolveAnchorProduct(request: request, userType: userType);

      if (anchorProduct == null) {
        continue;
      }

      final String? productId = anchorProduct.id;
      if (productId == null || productId.isEmpty) {
        continue;
      }

      groupedMap.putIfAbsent(productId, () => <ChatHistory>[]).add(request);
    }

    final List<GroupedSwapRequests> groups = groupedMap.entries
        .map((MapEntry<String, List<ChatHistory>> entry) {
      final List<ChatHistory> groupedRequests =
      List<ChatHistory>.from(entry.value);

      groupedRequests.sort(_sortRequestsDescending);

      final Product? anchorProduct = _resolveAnchorProduct(
        request: groupedRequests.first,
        userType: userType,
      );

      if (anchorProduct == null) {
        throw StateError(
          'Anchor product cannot be null for grouped request: ${entry.key}',
        );
      }

      return GroupedSwapRequests(
        groupKey: entry.key,
        anchorProduct: anchorProduct,
        requests: groupedRequests,
        userType: userType,
      );
    }).toList();

    groups.sort((GroupedSwapRequests a, GroupedSwapRequests b) {
      return _sortRequestsDescending(a.latestRequest, b.latestRequest);
    });

    return groups;
  }

  static Product? _resolveAnchorProduct({
    required ChatHistory request,
    required UserType userType,
  }) {
    if (userType == UserType.seller) {
      return request.item;
    }
    return request.buyerItem;
  }

  static int _sortRequestsDescending(ChatHistory a, ChatHistory b) {
    final DateTime? aDate = _parseDate(a);
    final DateTime? bDate = _parseDate(b);

    if (aDate != null && bDate != null) {
      return bDate.compareTo(aDate);
    }

    if (aDate != null) {
      return -1;
    }

    if (bDate != null) {
      return 1;
    }

    return 0;
  }

  static DateTime? _parseDate(ChatHistory request) {
    final List<String?> rawValues = <String?>[
      request.addedDate,
      request.addedDateStr,
    ];

    for (final String? raw in rawValues) {
      final String value = (raw ?? '').trim();
      if (value.isEmpty) {
        continue;
      }

      final DateTime? parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }
}