import 'package:flutter/material.dart';
import 'sweet_message_repository.dart';
import 'sweet_phrase.dart';

class SweetMessageProvider extends ChangeNotifier {
  SweetMessageProvider({
    required SweetMessageRepository repository,
  }) : _repository = repository;

  final SweetMessageRepository _repository;

  bool _isLoadingPhrases = false;
  bool get isLoadingPhrases => _isLoadingPhrases;

  bool _isSending = false;
  bool get isSending => _isSending;

  String _messageCategory = 'sweet';
  String get messageCategory => _messageCategory;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SweetPhrase> _phrases = <SweetPhrase>[];
  List<SweetPhrase> get phrases => _phrases;

  SweetPhrase? _selectedPhrase;
  SweetPhrase? get selectedPhrase => _selectedPhrase;

  void setMessageCategory(String value) {
    if (_messageCategory == value) {
      return;
    }
    _messageCategory = value;
    _selectedPhrase = null;
    notifyListeners();
  }

  void selectPhrase(SweetPhrase phrase) {
    _selectedPhrase = phrase;
    notifyListeners();
  }

  Future<bool> loadPhraseSuggestions({
    required String loginUserId,
    required String receiverUserId,
    int limit = 12,
  }) async {
    _isLoadingPhrases = true;
    _errorMessage = null;
    _phrases = <SweetPhrase>[];
    _selectedPhrase = null;
    notifyListeners();

    try {
      final result = await _repository.getPhraseSuggestions(
        loginUserId: loginUserId,
        receiverUserId: receiverUserId,
        messageCategory: _messageCategory,
        limit: limit,
      );

      if (!result.isSuccess) {
        _errorMessage = result.message.isNotEmpty
            ? result.message
            : 'تعذر تحميل الرسائل';
        _isLoadingPhrases = false;
        notifyListeners();
        return false;
      }

      _phrases = result.data ?? <SweetPhrase>[];
      if (_phrases.isNotEmpty) {
        _selectedPhrase = _phrases.first;
      }

      _isLoadingPhrases = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحميل الرسائل';
      _isLoadingPhrases = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendSelectedPhrase({
    required String loginUserId,
    required String receiverUserId,
    required String itemId,
    required int relationType,
  }) async {
    final SweetPhrase? phrase = _selectedPhrase;
    if (phrase == null) {
      _errorMessage = 'اختر رسالة أولاً';
      notifyListeners();
      return false;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.sendSweetMessage(
        loginUserId: loginUserId,
        receiverUserId: receiverUserId,
        itemId: itemId,
        relationType: relationType,
        phraseGroupId: phrase.groupId,
        phraseId: phrase.phraseId,
        messageCategory: _messageCategory,
        messageText: phrase.phraseText,
      );

      _isSending = false;
      if (!result.isSuccess) {
        _errorMessage = result.message.isNotEmpty
            ? result.message
            : 'تعذر إرسال الرسالة';
        notifyListeners();
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _isSending = false;
      _errorMessage = 'حدث خطأ أثناء الإرسال';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _isLoadingPhrases = false;
    _isSending = false;
    _messageCategory = 'sweet';
    _errorMessage = null;
    _phrases = <SweetPhrase>[];
    _selectedPhrase = null;
    notifyListeners();
  }
}