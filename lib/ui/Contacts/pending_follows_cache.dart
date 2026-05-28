import 'dart:convert';

import '../../constant/ps_constants.dart';
import '../../db/common/ps_shared_preferences.dart';

/// Stores follow selections made before login.
///
/// Shape:
/// {
///   "updated_at": 1710000000000,
///   "payload": {
///     "usr_x": 1,
///     "usr_y": 6
///   }
/// }
///
/// payload = followed_user_id -> relation_type
class PendingFollowsCache {
  static const String _key = 'pending_follows_v1';

  static Future<void> save(Map<String, int> payload) async {
    final Map<String, int> cleaned = <String, int>{};

    payload.forEach((String key, int value) {
      final String userId = key.trim();
      if (userId.isEmpty || value <= 0) return;
      cleaned[userId] = value;
    });

    final Map<String, dynamic> wrapper = <String, dynamic>{
      'updated_at': DateTime.now().millisecondsSinceEpoch,
      'payload': cleaned,
    };

    await PsSharedPreferences.instance.shared.setString(
      _key,
      jsonEncode(wrapper),
    );
  }

  static Map<String, int> read() {
    final String? raw = PsSharedPreferences.instance.shared.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      return <String, int>{};
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, int>{};
      }

      final dynamic payload = decoded['payload'];
      if (payload is! Map) {
        return <String, int>{};
      }

      final Map<String, int> out = <String, int>{};
      payload.forEach((dynamic key, dynamic value) {
        final String userId = (key ?? '').toString().trim();
        final int relationType = int.tryParse((value ?? '').toString()) ?? 0;
        if (userId.isEmpty || relationType <= 0) return;
        out[userId] = relationType;
      });

      return out;
    } catch (_) {
      return <String, int>{};
    }
  }

  static Future<void> clear() async {
    await PsSharedPreferences.instance.shared.remove(_key);
  }

  static bool hasAny() => read().isNotEmpty;

  static String currentLoginUserId() {
    return (PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__USER_ID) ??
        '')
        .trim();
  }
}
