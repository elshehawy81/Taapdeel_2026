import 'dart:convert';

import '../../constant/ps_constants.dart';
import '../../db/common/ps_shared_preferences.dart';

/// Stores follow selections made before login.
///
/// Shape:
/// {
///   "updated_at": 1710000000000,
///   "payload": {
///     "usr_x": {"relation_type": 1, "receive_recommendations": 1},
///     "usr_y": {"relation_type": 5, "receive_recommendations": 0}
///   }
/// }
///
/// payload = followed_user_id -> relation_type + receive recommendations flag.
class PendingFollowSelection {
  const PendingFollowSelection({
    required this.relationType,
    required this.receiveRecommendations,
  });

  final int relationType;
  final bool receiveRecommendations;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'relation_type': relationType,
        'receive_recommendations': receiveRecommendations ? 1 : 0,
      };

  static PendingFollowSelection? fromJson(dynamic value) {
    if (value is Map) {
      final int relationType = int.tryParse(
            (value['relation_type'] ?? value['relationType'] ?? '').toString(),
          ) ??
          0;
      final String receiveText = (value['receive_recommendations'] ??
              value['receiveRecommendations'] ??
              value['receive_swap_recommendations'] ??
              '')
          .toString()
          .trim()
          .toLowerCase();
      final bool receive = receiveText == '1' ||
          receiveText == 'true' ||
          receiveText == 'yes' ||
          receiveText == 'on';

      if (relationType <= 0) return null;
      return PendingFollowSelection(
        relationType: relationType,
        receiveRecommendations: receive,
      );
    }

    // Backward compatibility with old cache shape:
    // "usr_x": 5
    final int relationType = int.tryParse((value ?? '').toString()) ?? 0;
    if (relationType <= 0) return null;
    return PendingFollowSelection(
      relationType: relationType,
      receiveRecommendations: relationType == 1 || relationType == 6,
    );
  }
}

class PendingFollowsCache {
  static const String _key = 'pending_follows_v1';

  static Future<void> save(Map<String, PendingFollowSelection> payload) async {
    final Map<String, dynamic> cleaned = <String, dynamic>{};

    payload.forEach((String key, PendingFollowSelection value) {
      final String userId = key.trim();
      if (userId.isEmpty || value.relationType <= 0) return;
      cleaned[userId] = value.toJson();
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

  static Map<String, PendingFollowSelection> read() {
    final String? raw = PsSharedPreferences.instance.shared.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      return <String, PendingFollowSelection>{};
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, PendingFollowSelection>{};
      }

      final dynamic payload = decoded['payload'];
      if (payload is! Map) {
        return <String, PendingFollowSelection>{};
      }

      final Map<String, PendingFollowSelection> out = <String, PendingFollowSelection>{};
      payload.forEach((dynamic key, dynamic value) {
        final String userId = (key ?? '').toString().trim();
        final PendingFollowSelection? selection = PendingFollowSelection.fromJson(value);
        if (userId.isEmpty || selection == null) return;
        out[userId] = selection;
      });

      return out;
    } catch (_) {
      return <String, PendingFollowSelection>{};
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
