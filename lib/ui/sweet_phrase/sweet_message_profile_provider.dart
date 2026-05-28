import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_badge_provider.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_mark_read_request.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_profile_repository.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_received_request.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_unread_count_request.dart';

class SweetMessageProfileProvider extends ChangeNotifier {
  SweetMessageProfileProvider({
    required SweetMessageProfileRepository repository,
    // [FIX] inject BadgeProvider so both stay in sync
    SweetMessageBadgeProvider? badgeProvider,
  })  : _repository = repository,
        _badgeProvider = badgeProvider;

  final SweetMessageProfileRepository _repository;

  // [FIX] optional reference to BadgeProvider – set it after construction if
  // you can't pass it in the constructor (e.g. when using MultiProvider).
  SweetMessageBadgeProvider? _badgeProvider;

  void attachBadgeProvider(SweetMessageBadgeProvider badgeProvider) {
    _badgeProvider = badgeProvider;
  }

  List<SweetMessage> _messages = <SweetMessage>[];
  bool _isLoadingMessages = false;
  bool _isLoadingUnreadCount = false;
  bool _isMarkingRead = false;
  String _errorMessage = '';
  int _currentIndex = 0;

  // [FIX] unreadCount is now a single source of truth: read from BadgeProvider
  // when available, fall back to a local copy otherwise.
  int _localUnreadCount = 0;

  PageController? _pageController;
  Timer? _autoRotateTimer;

  List<SweetMessage> get messages => _messages;

  /// Always reflects the latest unread count whether it came from a direct
  /// [loadUnreadCount] call on this provider or from [BadgeProvider].
  int get unreadCount =>
      _badgeProvider != null ? _badgeProvider!.unreadCount : _localUnreadCount;

  bool get isLoadingMessages => _isLoadingMessages;
  bool get isLoadingUnreadCount => _isLoadingUnreadCount;
  bool get isMarkingRead => _isMarkingRead;
  bool get hasMessages => _messages.isNotEmpty;
  String get errorMessage => _errorMessage;
  int get currentIndex => _currentIndex;

  SweetMessage? get currentMessage {
    if (_messages.isEmpty) {
      return null;
    }
    if (_currentIndex < 0 || _currentIndex >= _messages.length) {
      return _messages.first;
    }
    return _messages[_currentIndex];
  }

  // ─── Page / auto-rotate ───────────────────────────────────────────────────

  void attachPageController(
    PageController controller, {
    int autoRotateSeconds = 6,
  }) {
    _pageController = controller;
    resumeAutoRotate(autoRotateSeconds: autoRotateSeconds);
  }

  void detachPageController() {
    pauseAutoRotate();
    _pageController = null;
  }

  void pauseAutoRotate() {
    _autoRotateTimer?.cancel();
    _autoRotateTimer = null;
  }

  void resumeAutoRotate({
    int autoRotateSeconds = 6,
  }) {
    pauseAutoRotate();

    if (_messages.length <= 1 || _pageController == null) {
      return;
    }

    _autoRotateTimer = Timer.periodic(
      Duration(seconds: autoRotateSeconds),
      (_) {
        if (_messages.isEmpty || _pageController == null) {
          return;
        }

        goNext(notify: false);

        _pageController!.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
        );

        notifyListeners();
      },
    );
  }

  // ─── Data loading ─────────────────────────────────────────────────────────

  Future<void> loadMessages({
    required String loginUserId,
    int limit = 10,
    int offset = 0,
    String messageCategory = '',
    bool notify = true,
  }) async {
    _isLoadingMessages = true;
    _errorMessage = '';
    if (notify) {
      notifyListeners();
    }

    try {
      final List<SweetMessage> result =
          await _repository.getReceivedSweetMessages(
        SweetMessageReceivedRequest(
          loginUserId: loginUserId,
          limit: limit,
          offset: offset,
          messageCategory: messageCategory,
        ),
      );

      _messages = result;

      if (_messages.isEmpty) {
        _currentIndex = 0;
      } else if (_currentIndex >= _messages.length) {
        _currentIndex = 0;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount({
    required String loginUserId,
    String messageCategory = '',
    bool notify = true,
  }) async {
    _isLoadingUnreadCount = true;
    _errorMessage = '';
    if (notify) {
      notifyListeners();
    }

    try {
      final int result = await _repository.getUnreadCount(
        SweetMessageUnreadCountRequest(
          loginUserId: loginUserId,
          messageCategory: messageCategory,
        ),
      );

      // [FIX] write the count into BadgeProvider (single source of truth).
      // If BadgeProvider is not injected yet, keep a local copy.
      if (_badgeProvider != null) {
        _badgeProvider!.setUnreadCount(result);
      } else {
        _localUnreadCount = result;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingUnreadCount = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll({
    required String loginUserId,
    int limit = 10,
    int offset = 0,
    String messageCategory = '',
  }) async {
    await Future.wait(<Future<void>>[
      loadMessages(
        loginUserId: loginUserId,
        limit: limit,
        offset: offset,
        messageCategory: messageCategory,
        notify: false,
      ),
      loadUnreadCount(
        loginUserId: loginUserId,
        messageCategory: messageCategory,
        notify: false,
      ),
    ]);

    notifyListeners();
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void setCurrentIndex(int index) {
    if (index < 0 || index >= _messages.length) {
      return;
    }
    _currentIndex = index;
    notifyListeners();
  }

  void goNext({bool notify = true}) {
    if (_messages.isEmpty) {
      return;
    }
    _currentIndex = (_currentIndex + 1) % _messages.length;
    if (notify) {
      notifyListeners();
    }
  }

  void goPrevious({bool notify = true}) {
    if (_messages.isEmpty) {
      return;
    }
    _currentIndex = (_currentIndex - 1 + _messages.length) % _messages.length;
    if (notify) {
      notifyListeners();
    }
  }

  // ─── Mark as read ─────────────────────────────────────────────────────────

  Future<void> markAsRead({
    required String loginUserId,
    required String sweetMessageId,
  }) async {
    final int index = _messages.indexWhere(
      (SweetMessage e) => e.sweetMessageId == sweetMessageId,
    );

    if (index == -1) {
      return;
    }

    // Already marked – nothing to do.
    if (_messages[index].isRead == 1) {
      return;
    }

    _isMarkingRead = true;
    notifyListeners();

    try {
      await _repository.markMessageRead(
        SweetMessageMarkReadRequest(
          loginUserId: loginUserId,
          sweetMessageId: sweetMessageId,
        ),
      );

      // Update the message in the local list.
      _messages[index] = _messages[index].copyWith(isRead: 1);

      // [FIX] decrement through BadgeProvider so the badge widget rebuilds
      // automatically.  Fall back to local counter when badge is not injected.
      if (_badgeProvider != null) {
        _badgeProvider!.decrementUnread();
      } else {
        if (_localUnreadCount > 0) {
          _localUnreadCount -= 1;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isMarkingRead = false;
      notifyListeners();
    }
  }

  // ─── Misc ─────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _autoRotateTimer?.cancel();
    super.dispose();
  }
}
