import 'dart:convert';
import 'package:http/http.dart' as http;

class OwnerRelationData {
  final int level;
  final String relationText;

  OwnerRelationData({required this.level, required this.relationText});

  factory OwnerRelationData.fromJson(Map<String, dynamic> json) {
    return OwnerRelationData(
      level: (json['level'] ?? 0) as int,
      relationText: (json['relation_text'] ?? '') as String,
    );
  }
}

class OwnerRelationService {
  OwnerRelationService({required this.baseUrl, required this.apiKey});

  final String baseUrl; // مثال: http://localhost/taapdeel/index.php/rest
  final String apiKey;

  Future<OwnerRelationData?> fetch({
    required String viewerId,
    required String ownerId,
  }) async {
    final uri = Uri.parse('$baseUrl/items/get_owner_relation/api_key/$apiKey');

    final res = await http.post(uri, body: {
      'viewer_id': viewerId,
      'owner_id': ownerId,
    });

    if (res.statusCode != 200) return null;

    final Map<String, dynamic> decoded = json.decode(res.body);
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return OwnerRelationData.fromJson(data);
    }
    return null;
  }
}