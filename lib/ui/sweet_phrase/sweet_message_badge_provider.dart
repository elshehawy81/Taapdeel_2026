import 'package:flutter/foundation.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_profile_repository.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_unread_count_request.dart';

/// Single source of truth for the unread-message badge count.
///
/// Both [SweetMessageBadgeProvider] (for the app-level badge widget) and
/// [SweetMessageProfileProvider] (for the profile screen) read/write the
/// count through this class, so the two views are always in sync without
/// duplicating state.
class SweetMessageBadgeProvider extends ChangeNotifier {
  SweetMessageBadgeProvider({
    required SweetMessageProfileRepository repository,
  }) : _repository = repository;

  final SweetMessageProfileRepository _repository;

  int _unreadCount = 0;
  bool _isLoading = false;
  String _error = '';

  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasUnread => _unreadCount > 0;

  /// Fetches the current unread count from the server and notifies listeners.
  ///
  /// Pass [notify] = false when batching multiple async calls and you want to
  /// call [notifyListeners] yourself at the end.
  Future<void> loadUnreadCount({
    required String loginUserId,
    String messageCategory = '',
    bool notify = true,
  }) async {
    if (loginUserId.isEmpty || loginUserId == 'nologinuser') {
      _unreadCount = 0;
      if (notify) notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    if (notify) notifyListeners();

    try {
      final int result = await _repository.getUnreadCount(
        SweetMessageUnreadCountRequest(
          loginUserId: loginUserId,
          messageCategory: messageCategory,
        ),
      );
      _unreadCount = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called by [SweetMessageProfileProvider.markAsRead] so the badge reflects
  /// the read action immediately without a round-trip to the server.
  void decrementUnread() {
    if (_unreadCount > 0) {
      _unreadCount -= 1;
      notifyListeners();
    }
  }

  /// Overrides the count directly (used by [SweetMessageProfileProvider] after
  /// it receives a fresh count from the server).
  void setUnreadCount(int value) {
    _unreadCount = value < 0 ? 0 : value;
    notifyListeners();
  }

  void clear() {
    _unreadCount = 0;
    _error = '';
    notifyListeners();
  }
}
