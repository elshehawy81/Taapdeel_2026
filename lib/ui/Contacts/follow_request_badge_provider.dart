import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:http/http.dart' as http;

class FollowRequestBadgeProvider extends ChangeNotifier {
  int _pendingCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  int get pendingCount => _pendingCount;
  bool get hasPending => _pendingCount > 0;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPendingCount(String userId) async {
    final String uid = userId.trim();

    if (uid.isEmpty || uid == 'nologinuser') {
      clear();
      return;
    }

    _setLoading(true);

    try {
      final Uri uri = _buildPendingUri(uid);

      final http.Response response = await http
          .get(
            uri,
            headers: const <String, String>{
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (decoded['status'] != 'success') {
        throw Exception(decoded['message']?.toString() ?? 'Request failed');
      }

      _pendingCount = _extractPendingCount(decoded);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();

      if (kDebugMode) {
        debugPrint('FollowRequestBadgeProvider.loadPendingCount error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh(String userId) {
    return loadPendingCount(userId);
  }

  void setPendingCount(int count) {
    final int safeCount = count < 0 ? 0 : count;

    if (_pendingCount == safeCount) {
      return;
    }

    _pendingCount = safeCount;
    notifyListeners();
  }

  void decrementAfterHandled() {
    if (_pendingCount <= 0) {
      return;
    }

    _pendingCount -= 1;
    notifyListeners();
  }

  void clear() {
    bool changed = false;

    if (_pendingCount != 0) {
      _pendingCount = 0;
      changed = true;
    }

    if (_isLoading) {
      _isLoading = false;
      changed = true;
    }

    if (_errorMessage != null) {
      _errorMessage = null;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  int _extractPendingCount(Map<String, dynamic> json) {
    final dynamic directCount =
        json['pending_count'] ?? json['pendingCount'] ?? json['count'];

    if (directCount is int) {
      return directCount < 0 ? 0 : directCount;
    }

    if (directCount is num) {
      final int count = directCount.toInt();
      return count < 0 ? 0 : count;
    }

    if (directCount is String) {
      final int count = int.tryParse(directCount) ?? 0;
      return count < 0 ? 0 : count;
    }

    final dynamic requests = json['requests'];

    if (requests is List) {
      return requests.length;
    }

    if (requests is Map && requests['data'] is List) {
      return (requests['data'] as List).length;
    }

    return 0;
  }

  Uri _buildPendingUri(String userId) {
    final String base = PsConfig.ps_app_url.trim();
    final String normalizedBase = base.endsWith('/') ? base : '$base/';

    return Uri.parse(
      '${normalizedBase}rest/follow_request/pending?user_id=${Uri.encodeQueryComponent(userId)}',
    );
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }
}