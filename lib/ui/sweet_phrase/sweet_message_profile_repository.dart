import 'package:taapdeel/api/ps_api_service.dart';
import 'package:taapdeel/repository/Common/ps_repository.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_mark_read_request.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_received_request.dart';
import 'package:taapdeel/ui/sweet_phrase/sweet_message_unread_count_request.dart';

class SweetMessageProfileRepository extends PsRepository {
  SweetMessageProfileRepository({
    required PsApiService psApiService,
  }) {
    _psApiService = psApiService;
  }

  late PsApiService _psApiService;

  Future<List<SweetMessage>> getReceivedSweetMessages(
      SweetMessageReceivedRequest request,
      ) async {
    return await _psApiService.getReceivedSweetMessages(request.toMap());
  }

  Future<int> getUnreadCount(
      SweetMessageUnreadCountRequest request,
      ) async {
    return await _psApiService.getSweetMessagesUnreadCount(request.toMap());
  }

  Future<bool> markMessageRead(
      SweetMessageMarkReadRequest request,
      ) async {
    return await _psApiService.markSweetMessageRead(request.toMap());
  }
}