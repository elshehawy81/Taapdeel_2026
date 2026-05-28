import '../../../provider/chat/seller_chat_history_list_provider.dart';
import '../../../ui/chat/enum/user_type.dart';
import '../../chat_history.dart';

class RequestDetailsIntentHolder {
  const RequestDetailsIntentHolder({
    required this.request,
    required this.userType,
    required this.providerS,
  });

  final ChatHistory request;
  final UserType userType;
  final SellerChatHistoryListProvider providerS;
}
