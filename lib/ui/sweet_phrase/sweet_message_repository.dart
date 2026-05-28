import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../config/ps_config.dart';
import 'sweet_message_api_response.dart';
import 'sweet_phrase.dart';

class SweetMessageRepository {
  SweetMessageRepository({
    required this.baseUrl,
    required this.headers,
  });

  final String baseUrl;
  final Map<String, String> headers;

  Uri _buildUri(String path) {
    final String cleanBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse('$cleanBase$path');
  }

  Future<SweetMessageApiResponse<List<SweetPhrase>>> getPhraseSuggestions({
    required String loginUserId,
    required String receiverUserId,
    required String messageCategory,
    int limit = 30,
  }) async {
    final Uri uri = _buildUri(
      'rest/sweet_messages/get_phrase_suggestions/api_key/${PsConfig.ps_api_key}',
    );

    final Map<String, String> body = <String, String>{
      'login_user_id': loginUserId,
      'receiver_user_id': receiverUserId,
      'message_category': messageCategory,
      'limit': limit.toString(),
    };

    debugPrint('SWEET getPhraseSuggestions URL = $uri');
    debugPrint('SWEET getPhraseSuggestions BODY = $body');

    final http.Response response = await http
        .post(
      uri,
      headers: headers,
      body: body,
    )
        .timeout(const Duration(seconds: 20));

    debugPrint('SWEET getPhraseSuggestions STATUS = ${response.statusCode}');
    debugPrint('SWEET getPhraseSuggestions RAW = ${response.body}');

    if (response.body.trim().isEmpty) {
      throw Exception('Empty response from getPhraseSuggestions');
    }

    final dynamic decoded = json.decode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response format from getPhraseSuggestions');
    }

    return SweetMessageApiResponse<List<SweetPhrase>>.fromMap(
      decoded,
          (dynamic data) {
        if (data is! List) {
          return <SweetPhrase>[];
        }

        final List<SweetPhrase> phrases = <SweetPhrase>[];

        for (final dynamic e in data) {
          if (e is Map<String, dynamic>) {
            phrases.add(SweetPhrase.fromMap(e));
          } else if (e is Map) {
            phrases.add(
              SweetPhrase.fromMap(Map<String, dynamic>.from(e)),
            );
          }
        }

        return phrases;
      },
    );
  }

  Future<SweetMessageApiResponse<Map<String, dynamic>>> sendSweetMessage({
    required String loginUserId,
    required String receiverUserId,
    required String itemId,
    required int relationType,
    required String phraseGroupId,
    required String phraseId,
    required String messageCategory,
    required String messageText,
    String messageSource = 'product_owner',
  }) async {
    final Uri uri = _buildUri(
      'rest/sweet_messages/send/api_key/${PsConfig.ps_api_key}',
    );

    final Map<String, String> body = <String, String>{
      'login_user_id': loginUserId,
      'receiver_user_id': receiverUserId,
      'item_id': itemId,
      'relation_type': relationType.toString(),
      'phrase_group_id': phraseGroupId,
      'phrase_id': phraseId,
      'message_category': messageCategory,
      'message_text': messageText,
      'message_source': messageSource,
    };

    debugPrint('SWEET sendSweetMessage URL = $uri');
    debugPrint('SWEET sendSweetMessage BODY = $body');

    final http.Response response = await http
        .post(
      uri,
      headers: headers,
      body: body,
    )
        .timeout(const Duration(seconds: 20));

    debugPrint('SWEET sendSweetMessage STATUS = ${response.statusCode}');
    debugPrint('SWEET sendSweetMessage RAW = ${response.body}');

    if (response.body.trim().isEmpty) {
      throw Exception('Empty response from sendSweetMessage');
    }

    final dynamic decoded = json.decode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response format from sendSweetMessage');
    }

    return SweetMessageApiResponse<Map<String, dynamic>>.fromMap(
      decoded,
          (dynamic data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        return <String, dynamic>{};
      },
    );
  }
}