import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/rendering.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/category/list/category_list_view.dart';
import 'package:taapdeel/ui/Contacts/contact_network_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Product/product_widget.dart';
import '../../chat/list/chat_list_screen.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_glass_bottom_sheet.dart';
import '../widgets/swap_rating.dart';
import '../widgets/swap_consult_share_sheet.dart';

import '../../../../../api/ps_url.dart';
import '../../../../../constant/ps_constants.dart';
import '../../../../../constant/route_paths.dart';
import '../../../../../viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import '../../../../../viewobject/product.dart';

import '../home_provider.dart';

part 'suggested_swap_filters.dart';
part 'suggested_swap_widgets.dart';

final ValueNotifier<Set<String>> suggestedSwapHiddenRequestedIdsNotifier =
ValueNotifier<Set<String>>(<String>{});

final ValueNotifier<String?> explicitlySelectedSuggestedSwapIdNotifier =
ValueNotifier<String?>(null);

class SuggestedSwapHiddenState {
  const SuggestedSwapHiddenState({
    this.hiddenForAllProductIds = const <String>{},
    this.hiddenForMyProductIds = const <String, Set<String>>{},
  });

  final Set<String> hiddenForAllProductIds;
  final Map<String, Set<String>> hiddenForMyProductIds;

  bool isHidden({
    required Product? myProduct,
    required Product suggestedProduct,
  }) {
    final String suggestedId = _safeProductId(suggestedProduct);
    if (suggestedId.isEmpty) return false;

    if (hiddenForAllProductIds.contains(suggestedId)) return true;

    final String myProductId = _safeProductId(myProduct);
    if (myProductId.isEmpty) return false;

    return hiddenForMyProductIds[myProductId]?.contains(suggestedId) == true;
  }

  SuggestedSwapHiddenState hideForAllProducts(Product suggestedProduct) {
    final String suggestedId = _safeProductId(suggestedProduct);
    if (suggestedId.isEmpty) return this;

    return SuggestedSwapHiddenState(
      hiddenForAllProductIds: <String>{
        ...hiddenForAllProductIds,
        suggestedId,
      },
      hiddenForMyProductIds: hiddenForMyProductIds,
    );
  }

  SuggestedSwapHiddenState hideForThisProductOnly({
    required Product? myProduct,
    required Product suggestedProduct,
  }) {
    final String myProductId = _safeProductId(myProduct);
    final String suggestedId = _safeProductId(suggestedProduct);
    if (myProductId.isEmpty || suggestedId.isEmpty) return this;

    final Map<String, Set<String>> nextMap = <String, Set<String>>{};
    hiddenForMyProductIds.forEach((String key, Set<String> value) {
      nextMap[key] = Set<String>.from(value);
    });

    nextMap.putIfAbsent(myProductId, () => <String>{}).add(suggestedId);

    return SuggestedSwapHiddenState(
      hiddenForAllProductIds: hiddenForAllProductIds,
      hiddenForMyProductIds: nextMap,
    );
  }
}

final ValueNotifier<SuggestedSwapHiddenState> suggestedSwapHiddenStateNotifier =
ValueNotifier<SuggestedSwapHiddenState>(const SuggestedSwapHiddenState());

enum _SuggestedSwapAudienceFilter {
  forYou,
  forFamily,
}


const String _suggestedSwapHiddenRequestedPrefsKey =
    'taapdeel_suggested_swap_hidden_requested_ids';
const String _suggestedSwapHiddenForAllPrefsKey =
    'taapdeel_suggested_swap_hidden_for_all_ids';
const String _suggestedSwapHiddenForMyProductPrefsKey =
    'taapdeel_suggested_swap_hidden_for_my_product_map';
const String _suggestedSwapPreferredCategoriesHintSeenPrefsKey =
    'taapdeel_suggested_swap_preferred_categories_hint_seen';
const String _suggestedSwapTrustedNetworkHintSeenPrefsKey =
    'taapdeel_suggested_swap_trusted_network_hint_seen';
const String _suggestedSwapPreferredCategoriesButtonPulseSeenPrefsKey =
    'taapdeel_suggested_swap_preferred_categories_button_pulse_seen';
const String _suggestedSwapTrustedNetworkButtonPulseSeenPrefsKey =
    'taapdeel_suggested_swap_trusted_network_button_pulse_seen';
const String _suggestedSwapConsultFriendsButtonPulseSeenPrefsKey =
    'taapdeel_suggested_swap_consult_friends_button_pulse_seen';

Future<void> _loadSuggestedSwapHiddenPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final List<String> requestedIds =
      prefs.getStringList(_suggestedSwapHiddenRequestedPrefsKey) ??
          const <String>[];
  suggestedSwapHiddenRequestedIdsNotifier.value = requestedIds
      .map((String id) => id.trim())
      .where((String id) => id.isNotEmpty)
      .toSet();

  final List<String> hiddenForAllIds =
      prefs.getStringList(_suggestedSwapHiddenForAllPrefsKey) ??
          const <String>[];

  final Map<String, Set<String>> hiddenForMyProductIds =
  <String, Set<String>>{};
  final String? rawMap = prefs.getString(_suggestedSwapHiddenForMyProductPrefsKey);
  if (rawMap != null && rawMap.trim().isNotEmpty) {
    try {
      final dynamic decoded = jsonDecode(rawMap);
      if (decoded is Map) {
        decoded.forEach((dynamic key, dynamic value) {
          final String myProductId = key.toString().trim();
          if (myProductId.isEmpty || value is! List) return;

          hiddenForMyProductIds[myProductId] = value
              .map((dynamic id) => id.toString().trim())
              .where((String id) => id.isNotEmpty)
              .toSet();
        });
      }
    } catch (_) {
      // Ignore corrupted local cache and keep the app usable.
    }
  }

  suggestedSwapHiddenStateNotifier.value = SuggestedSwapHiddenState(
    hiddenForAllProductIds: hiddenForAllIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet(),
    hiddenForMyProductIds: hiddenForMyProductIds,
  );
}

Future<void> _persistSuggestedSwapHiddenRequestedIds(Set<String> ids) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _suggestedSwapHiddenRequestedPrefsKey,
    ids.where((String id) => id.trim().isNotEmpty).toList(growable: false),
  );
}

Future<void> _persistSuggestedSwapHiddenState(
    SuggestedSwapHiddenState state,
    ) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setStringList(
    _suggestedSwapHiddenForAllPrefsKey,
    state.hiddenForAllProductIds
        .where((String id) => id.trim().isNotEmpty)
        .toList(growable: false),
  );

  final Map<String, List<String>> encodedMap = <String, List<String>>{};
  state.hiddenForMyProductIds.forEach((String myProductId, Set<String> ids) {
    final String cleanMyProductId = myProductId.trim();
    if (cleanMyProductId.isEmpty) return;

    encodedMap[cleanMyProductId] = ids
        .where((String id) => id.trim().isNotEmpty)
        .toList(growable: false);
  });

  await prefs.setString(
    _suggestedSwapHiddenForMyProductPrefsKey,
    jsonEncode(encodedMap),
  );
}

String _safeProductId(Product? product) {
  return (product?.id ?? '').toString().trim();
}

bool isProductPendingApproval(Product? product) {
  if (product == null) return false;

  dynamic rawValue;

  try {
    final dynamic dynamicProduct = product as dynamic;
    rawValue =
        dynamicProduct.status ??
            dynamicProduct.itemStatus ??
            dynamicProduct.productStatus ??
            dynamicProduct.approvalStatus ??
            dynamicProduct.approveStatus ??
            dynamicProduct.publishStatus;
  } catch (_) {
    rawValue = null;
  }

  final String normalized = (rawValue ?? '').toString().trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'null') return false;

  const Set<String> pendingValues = <String>{
    '0',
    'pending',
    'wait',
    'waiting',
    'under_review',
    'under review',
    'review',
    'in_review',
    'in review',
    'admin_pending',
    'need_approval',
    'needs_approval',
    'awaiting_approval',
    'awaiting approval',
    'not_approved',
    'not approved',
  };

  if (pendingValues.contains(normalized)) {
    return true;
  }

  return normalized.contains('pending') ||
      normalized.contains('review') ||
      normalized.contains('approval');
}

void hideSuggestedSwapAfterRequest(Product? product) {
  final String id = _safeProductId(product);
  if (id.isEmpty) return;

  final Set<String> updatedIds = Set<String>.from(
    suggestedSwapHiddenRequestedIdsNotifier.value,
  )..add(id);

  suggestedSwapHiddenRequestedIdsNotifier.value = updatedIds;
  _persistSuggestedSwapHiddenRequestedIds(updatedIds);

  if (explicitlySelectedSuggestedSwapIdNotifier.value == id) {
    explicitlySelectedSuggestedSwapIdNotifier.value = null;
  }
}

void showSwapRequestSentSnackBar(BuildContext context) {
  ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (BuildContext sheetContext) {
      final ThemeData theme = Theme.of(sheetContext);

      Future<void> closeSheet() async {
        if (Navigator.of(sheetContext, rootNavigator: true).canPop()) {
          Navigator.of(sheetContext, rootNavigator: true).pop();
        }
      }

      Future<void> closeAndOpenRequests() async {
        await closeSheet();
        await Future<void>.delayed(const Duration(milliseconds: 110));
        Navigator.of(context).push(
          MaterialPageRoute<dynamic>(
            builder: (_) => const ChatListScreen(),
          ),
        );
      }

      return Directionality(
        textDirection: TextDirection.rtl,
        child: TaapdeelGlassBottomSheet(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF065F46),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'تم إرسال طلب التبديل بنجاح 🎉',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'يمكنك متابعة حالة الطلب والردود من صفحة طلبات التبديل.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(0.65),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TaapdeelButton(
                  label: 'إغلاق',
                  isPrimary: false,
                  isExpanded: true,
                  onPressed: closeSheet,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


void notifySuggestedSwapRequestSent({
  required BuildContext context,
  required Product? requestedProduct,
})
{
  // HomeProvider.submitSwap is responsible for showing the result sheet.
  // This helper only hides the requested recommendation so we do not show
  // duplicate bottom sheets after sending a swap request.
  hideSuggestedSwapAfterRequest(requestedProduct);
}

String? _getRelationCode(Product p) {
  try {
    final String typed = (p.relationCode ?? '').toString().trim();
    if (typed.isNotEmpty && typed.toLowerCase() != 'null') return typed;

    final d = p as dynamic;
    final v = (d.relation_code ?? d.relationCode ?? '').toString().trim();
    return v.isEmpty || v.toLowerCase() == 'null' ? null : v;
  } catch (_) {
    return null;
  }
}


dynamic _readSuggestedSwapDynamicValue(dynamic Function() read) {
  try {
    return read();
  } catch (_) {
    return null;
  }
}

String _cleanSuggestedSwapText(dynamic value) {
  final String text = (value ?? '').toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return '';
  return text;
}

String _normalizeSuggestedSwapToken(dynamic value) {
  return _cleanSuggestedSwapText(value)
      .toLowerCase()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');
}

bool _isDirectRelationToken(dynamic value) {
  final String token = _normalizeSuggestedSwapToken(value);
  if (token.isEmpty) return false;

  const Set<String> nonDirectTokens = <String>{
    '0',
    'none',
    'no',
    'null',
    'public',
    'all',
    'unknown',
    'stranger',
    'market',
    'global',
    'self',
    'me',
    'mine',
    '777',
  };

  if (nonDirectTokens.contains(token)) return false;

  final int? numericRelation = int.tryParse(token);
  if (numericRelation != null) {
    return numericRelation > 0 && numericRelation != 777;
  }

  const Set<String> directTokens = <String>{
    'friend',
    'friends',
    'direct_friend',
    'close_friend',
    'family',
    'families',
    'relative',
    'relatives',
    'direct_relative',
    'parent',
    'parents',
    'father',
    'mother',
    'son',
    'daughter',
    'brother',
    'sister',
    'spouse',
    'wife',
    'husband',
    'child',
    'children',
    'family_member',
    'family_members',
    'member_family',
    'my_family',
    'صديق',
    'صديقه',
    'صديقة',
    'اصدقاء',
    'أصدقاء',
    'قريب',
    'قريبه',
    'قريبة',
    'اقارب',
    'أقارب',
    'عائلة',
    'العائلة',
    'اسرة',
    'أسرة',
    'اخ',
    'أخ',
    'اخت',
    'أخت',
    'اب',
    'أب',
    'ام',
    'أم',
    'ابن',
    'بنت',
    'زوج',
    'زوجة',
  };

  return directTokens.contains(token) ||
      token.contains('friend') ||
      token.contains('family') ||
      token.contains('relative') ||
      token.contains('direct') ||
      token.contains('عائل') ||
      token.contains('قريب') ||
      token.contains('قري') ||
      token.contains('صديق') ||
      token.contains('صدي') ||
      token.contains('اقارب') ||
      token.contains('أقارب');
}

bool _isDirectRelationshipSuggestion({
  required Product product,
  String? relationBackendCode,
}) {
  if (_isDirectRelationToken(relationBackendCode)) return true;
  if (_isDirectRelationToken(_getRelationCode(product))) return true;

  final dynamic d = product as dynamic;

  final List<dynamic Function()> readers = <dynamic Function()>[
    () => d.relationType,
    () => d.relation_type,
    () => d.ownerRelationType,
    () => d.owner_relation_type,
    () => d.sellerRelationType,
    () => d.seller_relation_type,
    () => d.addedUserRelationType,
    () => d.added_user_relation_type,
    () => d.relationLabel,
    () => d.relation_label,
    () => d.ownerRelationLabel,
    () => d.owner_relation_label,
    () => d.sellerRelationLabel,
    () => d.seller_relation_label,
    () => d.matchRelation,
    () => d.match_relation,
    () => d.recommendationRelation,
    () => d.recommendation_relation,
  ];

  for (final dynamic Function() read in readers) {
    if (_isDirectRelationToken(_readSuggestedSwapDynamicValue(read))) {
      return true;
    }
  }

  return false;
}

String _normalizeArabicIndicDigits(String value) {
  const Map<String, String> digits = <String, String>{
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
    '۰': '0',
    '۱': '1',
    '۲': '2',
    '۳': '3',
    '۴': '4',
    '۵': '5',
    '۶': '6',
    '۷': '7',
    '۸': '8',
    '۹': '9',
  };

  String normalized = value;
  digits.forEach((String from, String to) {
    normalized = normalized.replaceAll(from, to);
  });
  return normalized;
}

String? _normalizeWhatsAppPhone(dynamic value) {
  String raw = _cleanSuggestedSwapText(value);
  if (raw.isEmpty) return null;

  raw = _normalizeArabicIndicDigits(raw);

  String phone = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (phone.isEmpty) return null;

  if (phone.startsWith('+')) {
    phone = phone.substring(1);
  } else if (phone.startsWith('00')) {
    phone = phone.substring(2);
  } else if (phone.startsWith('0') && phone.length == 11) {
    // Egyptian local mobile format: 01xxxxxxxxx -> 201xxxxxxxxx.
    phone = '20${phone.substring(1)}';
  } else if (phone.startsWith('1') && phone.length == 10) {
    // Egyptian mobile without leading 0.
    phone = '20$phone';
  }

  phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (phone.length < 8) return null;
  return phone;
}

String? _suggestionOwnerWhatsAppPhone(Product product) {
  final dynamic d = product as dynamic;
  final dynamic user = _readSuggestedSwapDynamicValue(() => d.user);
  final dynamic owner = _readSuggestedSwapDynamicValue(() => d.owner);
  final dynamic seller = _readSuggestedSwapDynamicValue(() => d.seller);
  final dynamic addedUser =
      _readSuggestedSwapDynamicValue(() => d.addedUser) ??
          _readSuggestedSwapDynamicValue(() => d.added_user);

  final List<dynamic Function()> readers = <dynamic Function()>[
    () => d.whatsappPhone,
    () => d.whatsapp_phone,
    () => d.whatsappNumber,
    () => d.whatsapp_number,
    () => d.whatsappNo,
    () => d.whatsapp_no,
    () => d.whatsapp,
    () => d.ownerPhone,
    () => d.owner_phone,
    () => d.ownerMobile,
    () => d.owner_mobile,
    () => d.sellerPhone,
    () => d.seller_phone,
    () => d.sellerMobile,
    () => d.seller_mobile,
    () => d.addedUserPhone,
    () => d.added_user_phone,
    () => d.addedUserMobile,
    () => d.added_user_mobile,
    () => d.userPhone,
    () => d.user_phone,
    () => d.userMobile,
    () => d.user_mobile,
    () => d.contactPhone,
    () => d.contact_phone,
    () => d.phone,
    () => d.mobile,
    () => d.mobileNo,
    () => d.mobile_no,
    () => user?.whatsappPhone,
    () => user?.whatsapp_phone,
    () => user?.whatsappNumber,
    () => user?.whatsapp_number,
    () => user?.whatsapp,
    () => user?.userPhone,
    () => user?.user_phone,
    () => user?.phone,
    () => user?.mobile,
    () => user?.mobileNo,
    () => user?.mobile_no,
    () => owner?.whatsappPhone,
    () => owner?.whatsapp_phone,
    () => owner?.whatsappNumber,
    () => owner?.whatsapp_number,
    () => owner?.whatsapp,
    () => owner?.userPhone,
    () => owner?.user_phone,
    () => owner?.phone,
    () => owner?.mobile,
    () => owner?.mobileNo,
    () => owner?.mobile_no,
    () => seller?.whatsappPhone,
    () => seller?.whatsapp_phone,
    () => seller?.whatsappNumber,
    () => seller?.whatsapp_number,
    () => seller?.whatsapp,
    () => seller?.userPhone,
    () => seller?.user_phone,
    () => seller?.phone,
    () => seller?.mobile,
    () => seller?.mobileNo,
    () => seller?.mobile_no,
    () => addedUser?.whatsappPhone,
    () => addedUser?.whatsapp_phone,
    () => addedUser?.whatsappNumber,
    () => addedUser?.whatsapp_number,
    () => addedUser?.whatsapp,
    () => addedUser?.userPhone,
    () => addedUser?.user_phone,
    () => addedUser?.phone,
    () => addedUser?.mobile,
    () => addedUser?.mobileNo,
    () => addedUser?.mobile_no,
  ];

  for (final dynamic Function() read in readers) {
    final String? phone = _normalizeWhatsAppPhone(
      _readSuggestedSwapDynamicValue(read),
    );
    if (phone != null) return phone;
  }

  return null;
}

bool _shouldShowDirectWhatsAppButton({
  required Product product,
  String? relationBackendCode,
}) {
  return _isDirectRelationshipSuggestion(
        product: product,
        relationBackendCode: relationBackendCode,
      ) &&
      _suggestionOwnerWhatsAppPhone(product) != null;
}

String _productTitleForWhatsApp(Product? product, String fallback) {
  final String title = _cleanSuggestedSwapText(product?.title);
  return title.isEmpty ? fallback : title;
}

String _buildDirectWhatsAppMessage({
  required Product? myProduct,
  required Product suggestedProduct,
}) {
  final String suggestedTitle = _productTitleForWhatsApp(
    suggestedProduct,
    'منتجك',
  );
  final String myTitle = _productTitleForWhatsApp(
    myProduct,
    'منتجي',
  );

  return 'أهلاً، شفت منتج "$suggestedTitle" على تطبيق Taapdeel '
      'وحابب أتواصل معاك بخصوص تبديله مع "$myTitle".';
}

Future<void> _openDirectWhatsAppForSuggestion({
  required Product? myProduct,
  required Product suggestedProduct,
}) async {
  final String? phone = _suggestionOwnerWhatsAppPhone(suggestedProduct);

  if (phone == null) {
    Fluttertoast.showToast(msg: 'رقم الواتساب غير متاح لهذا المنتج');
    return;
  }

  final String message = _buildDirectWhatsAppMessage(
    myProduct: myProduct,
    suggestedProduct: suggestedProduct,
  );

  final Uri appUri = Uri.parse(
    'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}',
  );
  final Uri webUri = Uri.https(
    'wa.me',
    '/$phone',
    <String, String>{'text': message},
  );

  try {
    final bool openedWhatsApp = await launchUrl(
      appUri,
      mode: LaunchMode.externalApplication,
    );
    if (openedWhatsApp) return;
  } catch (_) {
    // Fall back to wa.me below.
  }

  try {
    final bool openedWebWhatsApp = await launchUrl(
      webUri,
      mode: LaunchMode.externalApplication,
    );
    if (openedWebWhatsApp) return;
  } catch (_) {
    // Show a friendly message below.
  }

  Fluttertoast.showToast(msg: 'تعذر فتح واتساب الآن');
}

class SuggestedSwapsSection extends StatefulWidget {
  const SuggestedSwapsSection({
    Key? key,
    required this.homeProvider,
  }) : super(key: key);

  final HomeProvider homeProvider;

  @override
  State<SuggestedSwapsSection> createState() => SuggestedSwapsSectionState();
}

class SuggestedSwapsSectionState extends State<SuggestedSwapsSection> {
  int _currentIndex = 0;
  bool _didInitSync = false;
  bool _didAutoSelectLastMyProduct = false;
  bool _isSelectingMyProduct = false;
  bool _showRecommendationBooster = false;
  bool _showRecommendationActions = false;
  bool _preferredCategoriesHintSeenLoaded = false;
  bool _showPreferredCategoriesHint = false;
  bool _didMarkPreferredCategoriesHintShown = false;
  bool _trustedNetworkHintSeenLoaded = false;
  bool _showTrustedNetworkHint = false;
  bool _didMarkTrustedNetworkHintShown = false;
  bool _oneShotAttentionStateLoaded = false;
  bool _playPreferredCategoriesButtonAttention = false;
  bool _playTrustedNetworkButtonAttention = false;
  bool _playConsultFriendsButtonAttention = false;
  bool _didMarkPreferredCategoriesButtonAttentionShown = false;
  bool _didMarkTrustedNetworkButtonAttentionShown = false;
  bool _didMarkConsultFriendsButtonAttentionShown = false;
  _SuggestedSwapFilters _filters = const _SuggestedSwapFilters();

  @override
  void initState() {
    super.initState();
    _loadSuggestedSwapHiddenPrefs();
    _loadPreferredCategoriesHintState();
    _loadTrustedNetworkHintState();
    _loadOneShotAttentionState();
    suggestedSwapHiddenRequestedIdsNotifier.addListener(
      _handleHiddenRequestedSuggestionsChanged,
    );
    suggestedSwapHiddenStateNotifier.addListener(
      _handleHiddenRequestedSuggestionsChanged,
    );
    explicitlySelectedSuggestedSwapIdNotifier.addListener(
      _handleExplicitSelectedSuggestionChanged,
    );
  }

  @override
  void dispose() {
    suggestedSwapHiddenRequestedIdsNotifier.removeListener(
      _handleHiddenRequestedSuggestionsChanged,
    );
    suggestedSwapHiddenStateNotifier.removeListener(
      _handleHiddenRequestedSuggestionsChanged,
    );
    explicitlySelectedSuggestedSwapIdNotifier.removeListener(
      _handleExplicitSelectedSuggestionChanged,
    );
    super.dispose();
  }

  void _handleHiddenRequestedSuggestionsChanged() {
    if (!mounted) return;

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
    });
  }

  void _handleExplicitSelectedSuggestionChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _clearExplicitSelectedSuggestion() {
    if (explicitlySelectedSuggestedSwapIdNotifier.value != null) {
      explicitlySelectedSuggestedSwapIdNotifier.value = null;
    }
  }

  void _selectSuggestedSwapProduct(HomeProvider home, Product product) {
    if (home.isMyProductPending) {
      return;
    }

    final String id = _safeProductId(product);
    if (id.isEmpty) return;

    home.setSelectedSwapProduct(product);
    explicitlySelectedSuggestedSwapIdNotifier.value = id;
  }

  Future<void> _requestSwapForSuggestion(
      HomeProvider home,
      Product product,
      ) async {
    if (!mounted) return;
    if (home.isSubmitting || home.isMyProductPending) return;

    _selectSuggestedSwapProduct(home, product);
    await home.submitSwap(context: context);
    hideSuggestedSwapAfterRequest(product);
  }

  List<Product> _removeHiddenSuggestions(
      List<Product> products, {
        required Product? myProduct,
      }) {
    final Set<String> requestedHiddenIds =
        suggestedSwapHiddenRequestedIdsNotifier.value;
    final SuggestedSwapHiddenState hiddenState =
        suggestedSwapHiddenStateNotifier.value;

    if (requestedHiddenIds.isEmpty &&
        hiddenState.hiddenForAllProductIds.isEmpty &&
        hiddenState.hiddenForMyProductIds.isEmpty) {
      return products;
    }

    return products.where((Product p) {
      final String id = _safeProductId(p);
      if (id.isEmpty) return false;
      if (requestedHiddenIds.contains(id)) return false;

      return !hiddenState.isHidden(
        myProduct: myProduct,
        suggestedProduct: p,
      );
    }).toList(growable: false);
  }

  void markSwapRequestSent(Product? requestedProduct) {
    hideSuggestedSwapAfterRequest(requestedProduct);

    if (!mounted) return;
    showSwapRequestSentSnackBar(context);
  }

  void _syncSelectedSwapFromVisible(
      HomeProvider home,
      List<Product> visibleProducts,
      int index, {
        bool animate = false,
      })
  {
    if (visibleProducts.isEmpty) return;
    if (index < 0 || index >= visibleProducts.length) return;

    if (_currentIndex != index && mounted) {
      setState(() => _currentIndex = index);
    }

  }

  InlineSwapVM _buildVm(Product p) {
    final int percent =
        int.tryParse((p.swapScorePercent ?? '').toString().trim()) ?? 0;
    final breakdown = castSwapBreakdown(p.swapScoreBreakdown);
    return buildInlineSwapVM(percent: percent, breakdown: breakdown);
  }

  Future<void> _loadPreferredCategoriesHintState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool seen =
        prefs.getBool(_suggestedSwapPreferredCategoriesHintSeenPrefsKey) ?? false;

    if (!mounted) return;

    setState(() {
      _preferredCategoriesHintSeenLoaded = true;
      _showPreferredCategoriesHint = !seen;
      _didMarkPreferredCategoriesHintShown = seen;
    });
  }

  Future<void> _markPreferredCategoriesHintShown() async {
    if (_didMarkPreferredCategoriesHintShown) return;

    _didMarkPreferredCategoriesHintShown = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _suggestedSwapPreferredCategoriesHintSeenPrefsKey,
      true,
    );
  }

  Future<void> _openEditInterestsFromPreferredHint() async {
    if (!mounted) return;

    if (_showPreferredCategoriesHint) {
      setState(() {
        _showPreferredCategoriesHint = false;
      });
    }

    await _markPreferredCategoriesHintShown();
    await _openEditInterests();
  }

  Future<void> _loadTrustedNetworkHintState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool seen =
        prefs.getBool(_suggestedSwapTrustedNetworkHintSeenPrefsKey) ?? false;

    if (!mounted) return;

    setState(() {
      _trustedNetworkHintSeenLoaded = true;
      _showTrustedNetworkHint = !seen;
      _didMarkTrustedNetworkHintShown = seen;
    });
  }

  Future<void> _markTrustedNetworkHintShown() async {
    if (_didMarkTrustedNetworkHintShown) return;

    _didMarkTrustedNetworkHintShown = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _suggestedSwapTrustedNetworkHintSeenPrefsKey,
      true,
    );
  }

  void _handleTrustedNetworkHintVisible() {
    // لا يتم إخفاء سيكشن الثقة بمجرد ظهوره أثناء الاسكرول.
    // يظل ظاهرًا حتى يفتح المستخدم تجربة إضافة الأصدقاء والعائلة من الزر.
  }

  Future<void> _openTrustedNetworkHint() async {
    if (!mounted) return;

    // ContactNetworkBottomSheet.show(context) currently returns void, so this
    // section must not be marked as seen merely because the user opened or
    // dismissed the sheet. It stays visible until the contact intro/permission
    // flow explicitly persists success from its own screen/provider.
    await _openRecommendationNetworkSheet();
  }

  Future<void> _loadOneShotAttentionState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool preferredSeen = prefs.getBool(
      _suggestedSwapPreferredCategoriesButtonPulseSeenPrefsKey,
    ) ??
        false;
    final bool trustedSeen = prefs.getBool(
      _suggestedSwapTrustedNetworkButtonPulseSeenPrefsKey,
    ) ??
        false;
    final bool consultSeen = prefs.getBool(
      _suggestedSwapConsultFriendsButtonPulseSeenPrefsKey,
    ) ??
        false;

    if (!mounted) return;

    setState(() {
      _oneShotAttentionStateLoaded = true;
      _playPreferredCategoriesButtonAttention = !preferredSeen;
      _playTrustedNetworkButtonAttention = !trustedSeen;
      _playConsultFriendsButtonAttention = false;
      _didMarkPreferredCategoriesButtonAttentionShown = preferredSeen;
      _didMarkTrustedNetworkButtonAttentionShown = trustedSeen;
      _didMarkConsultFriendsButtonAttentionShown = consultSeen;
    });
  }

  Future<void> _markPreferredCategoriesButtonAttentionShown() async {
    if (_didMarkPreferredCategoriesButtonAttentionShown) return;

    _didMarkPreferredCategoriesButtonAttentionShown = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _suggestedSwapPreferredCategoriesButtonPulseSeenPrefsKey,
      true,
    );
  }

  Future<void> _markTrustedNetworkButtonAttentionShown() async {
    if (_didMarkTrustedNetworkButtonAttentionShown) return;

    _didMarkTrustedNetworkButtonAttentionShown = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _suggestedSwapTrustedNetworkButtonPulseSeenPrefsKey,
      true,
    );
  }

  Future<void> _markConsultFriendsButtonAttentionShown() async {
    if (_didMarkConsultFriendsButtonAttentionShown) return;

    _didMarkConsultFriendsButtonAttentionShown = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _suggestedSwapConsultFriendsButtonPulseSeenPrefsKey,
      true,
    );
  }

  void _markVisibleOneShotAttentionIfNeeded({
    required bool showPreferredCategoriesHint,
    required bool showTrustedNetworkHint,
  }) {
    if (!_oneShotAttentionStateLoaded) return;

    if (showPreferredCategoriesHint &&
        _playPreferredCategoriesButtonAttention &&
        !_didMarkPreferredCategoriesButtonAttentionShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markPreferredCategoriesButtonAttentionShown();
      });
    }

    if (showTrustedNetworkHint &&
        _playTrustedNetworkButtonAttention &&
        !_didMarkTrustedNetworkButtonAttentionShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markTrustedNetworkButtonAttentionShown();
      });
    }
  }

  void _handleRecommendationsReachedEnd() {
    if (!_oneShotAttentionStateLoaded ||
        _didMarkConsultFriendsButtonAttentionShown ||
        _playConsultFriendsButtonAttention) {
      return;
    }

    setState(() {
      _playConsultFriendsButtonAttention = true;
    });

    _markConsultFriendsButtonAttentionShown();
  }

  Future<void> _openEditInterests() async {
    if (!mounted) return;
    final bool? changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (BuildContext context) {
            return const CategoryListView(home: true);
          },
        ));

    if (!mounted) return;

    if (changed == true) {
      final HomeProvider home = context.read<HomeProvider>();

      setState(() {
        _currentIndex = 0;
        _didInitSync = false;
      });

      if (home.myItemId.trim().isNotEmpty) {
        await home.topRecProduct(PsUrl.ps_top_recom_url);
      }
    }
  }

  Future<void> _openRecommendationNetworkSheet() async {
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await ContactNetworkBottomSheet.show(context);

    if (!mounted) return;

    final HomeProvider home = context.read<HomeProvider>();
    if (home.myItemId.trim().isEmpty) return;

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
    });

    await home.topRecProduct(PsUrl.ps_top_recom_url);
  }

  void _toggleRecommendationActions() {
    setState(() {
      _showRecommendationActions = !_showRecommendationActions;
      if (!_showRecommendationActions) {
        _showRecommendationBooster = false;
      }
    });
  }

  void _toggleImproveToolsByUser() {
    setState(() {
      _showRecommendationBooster = !_showRecommendationBooster;
    });
  }

  void _closeRecommendationToolsOnUserScroll() {
    if (!_showRecommendationActions && !_showRecommendationBooster) return;
    if (!mounted) return;

    setState(() {
      _showRecommendationActions = false;
      _showRecommendationBooster = false;
    });
  }

  void _openProductDetails(BuildContext context, Product p) {
    if (p.id == null) return;

    final holder = ProductDetailIntentHolder(
      productId: p.id!,
      heroTagImage: '${p.hashCode}${p.id}${PsConst.HERO_TAG__IMAGE}',
      heroTagTitle: '${p.hashCode}${p.id}${PsConst.HERO_TAG__TITLE}',
    );

    Navigator.pushNamed(
      context,
      RoutePaths.productDetail,
      arguments: holder,
    );
  }


  Future<void> _autoSelectFirstMyProductIfNeeded(HomeProvider home) async {
    if (_didAutoSelectLastMyProduct) return;
    if (home.myProducts.isEmpty) return;

    // ✅ مهم: لو المستخدم اختار منتج بالفعل من الـ Bottom Sheet
    // لا نرجع نغيّره تلقائيًا لآخر منتج.
    final String currentProductId =
    (home.myProduct?.id ?? '').toString().trim();
    if (currentProductId.isNotEmpty) {
      _didAutoSelectLastMyProduct = true;
      return;
    }

    // أول منتج في قائمة منتجات المستخدم هو الذي سيتم اختياره تلقائيًا.
    final Product firstProduct = home.myProducts.first;
    final String firstProductId = (firstProduct.id ?? '').toString().trim();
    if (firstProductId.isEmpty) return;

    _didAutoSelectLastMyProduct = true;

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
    });

    await home.setSelectedMyProduct(
      firstProduct,
      fetchRecommendations: true,
    );
  }


  Future<void> _selectMyProductByIndex(
      HomeProvider home,
      int index,
      ) async
  {
    if (!mounted) return;
    if (_isSelectingMyProduct) return;
    if (index < 0 || index >= home.myProducts.length) return;

    final Product selected = home.myProducts[index];
    final String selectedId = (selected.id ?? '').toString().trim();
    final String currentId = (home.myProduct?.id ?? '').toString().trim();

    if (selectedId.isEmpty) return;

    // نفس المنتج الحالي: لا نعيد تحميل الترشيحات حتى لا ترجع النتائج لمنتج سابق.
    if (selectedId == currentId) {
      return;
    }

    _isSelectingMyProduct = true;

    _clearExplicitSelectedSuggestion();

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
      _didAutoSelectLastMyProduct = true;
    });

    await home.setSelectedMyProduct(
      selected,
      fetchRecommendations: true,
    );

    if (!mounted) {
      _isSelectingMyProduct = false;
      return;
    }

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
      _didAutoSelectLastMyProduct = true;
      _isSelectingMyProduct = false;
    });
  }



  Future<void> _openHideSuggestedSwapSheet(Product product) async {
    if (!mounted) return;

    final _SuggestedSwapHideScope? scope =
    await showModalBottomSheet<_SuggestedSwapHideScope>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return const _SuggestedSwapHideBottomSheet();
      },
    );

    if (!mounted || scope == null) return;

    final HomeProvider home = context.read<HomeProvider>();

    final SuggestedSwapHiddenState nextHiddenState =
    scope == _SuggestedSwapHideScope.allProducts
        ? suggestedSwapHiddenStateNotifier.value.hideForAllProducts(product)
        : suggestedSwapHiddenStateNotifier.value.hideForThisProductOnly(
      myProduct: home.myProduct,
      suggestedProduct: product,
    );

    suggestedSwapHiddenStateNotifier.value = nextHiddenState;
    _persistSuggestedSwapHiddenState(nextHiddenState);

    setState(() {
      _currentIndex = 0;
      _didInitSync = false;
    });

    final String hiddenId = _safeProductId(product);
    if (explicitlySelectedSuggestedSwapIdNotifier.value == hiddenId) {
      _clearExplicitSelectedSuggestion();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF073B5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Text(
            scope == _SuggestedSwapHideScope.allProducts
                ? 'تم إخفاء الترشيح مع كل منتجاتك.'
                : 'تم إخفاء الترشيح مع هذا المنتج فقط.',
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      );
  }

  Future<void> _openSuggestedSwapFiltersSheet(List<Product> allProducts) async {
    if (!mounted) return;

    final _SuggestedSwapFilters? selectedFilters =
    await showModalBottomSheet<_SuggestedSwapFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _SuggestedSwapFiltersBottomSheet(
          products: allProducts,
          myProduct: context.read<HomeProvider>().myProduct,
          initialFilters: _filters,
        );
      },
    );

    if (!mounted || selectedFilters == null) return;

    _clearExplicitSelectedSuggestion();

    setState(() {
      _filters = selectedFilters;
      _currentIndex = 0;
      _didInitSync = false;
    });
  }


  bool _hasFamilyRecommendationSignal({
    required Product product,
    required Product? myProduct,
  }) {
    final Set<String> rawAudienceValues = <String>{};

    void addAudienceValue(dynamic value) {
      final String normalized = (value ?? '')
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll('-', '_')
          .replaceAll(' ', '_');
      if (normalized.isNotEmpty && normalized != 'null') {
        rawAudienceValues.add(normalized);
      }
    }

    addAudienceValue(_getRelationCode(product));

    final dynamic d = product as dynamic;

    void tryAddAudienceValue(dynamic Function() read) {
      try {
        addAudienceValue(read());
      } catch (_) {
        // Optional API field is not exposed by this Product model.
      }
    }

    tryAddAudienceValue(() => d.recommendationAudience);
    tryAddAudienceValue(() => d.recommendation_audience);
    tryAddAudienceValue(() => d.recommendationScope);
    tryAddAudienceValue(() => d.recommendation_scope);
    tryAddAudienceValue(() => d.targetAudience);
    tryAddAudienceValue(() => d.target_audience);
    tryAddAudienceValue(() => d.interestOwner);
    tryAddAudienceValue(() => d.interest_owner);
    tryAddAudienceValue(() => d.preferredCategoryOwner);
    tryAddAudienceValue(() => d.preferred_category_owner);
    tryAddAudienceValue(() => d.ownerType);
    tryAddAudienceValue(() => d.owner_type);
    tryAddAudienceValue(() => d.matchScope);
    tryAddAudienceValue(() => d.match_scope);
    tryAddAudienceValue(() => d.suitabilityScope);
    tryAddAudienceValue(() => d.suitability_scope);

    const Set<String> familyRelationCodes = <String>{
      'family',
      'families',
      'relative',
      'relatives',
      'parent',
      'parents',
      'father',
      'mother',
      'son',
      'daughter',
      'brother',
      'sister',
      'spouse',
      'wife',
      'husband',
      'child',
      'children',
      'family_member',
      'family_members',
      'member_family',
      'my_family',
      'عائلة',
      'العائلة',
      'اهلي',
      'أهلي',
      'قريب',
      'اقارب',
      'أقارب',
      'family_interest',
      'family_interests',
      'for_family',
      'suitable_for_family',
      '3',
    };

    final bool hasFamilyAudienceSignal = rawAudienceValues.any(
          (String value) => familyRelationCodes.contains(value) ||
          value.contains('family') ||
          value.contains('relative') ||
          value.contains('parent') ||
          value.contains('عائل') ||
          value.contains('أقارب') ||
          value.contains('اقارب'),
    );

    if (hasFamilyAudienceSignal) {
      return true;
    }

    final InlineSwapVM vm = _buildVm(product);
    return buildSuggestedSwapCriteria(
      product,
      vm,
      myProduct: myProduct,
    ).any((SwapCriterionItem item) => item.isFamilyInterest);
  }

  List<Product> _applyAudienceFilter({
    required List<Product> products,
    required Product? myProduct,
    required _SuggestedSwapAudienceFilter audienceFilter,
  }) {
    return products.where((Product product) {
      final bool isFamily = _hasFamilyRecommendationSignal(
        product: product,
        myProduct: myProduct,
      );

      switch (audienceFilter) {
        case _SuggestedSwapAudienceFilter.forFamily:
          return isFamily;
        case _SuggestedSwapAudienceFilter.forYou:
          return !isFamily;
      }
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        final List<Product> allProducts = _removeHiddenSuggestions(
          home.recProducts,
          myProduct: home.myProduct,
        );
        final bool hasItems = allProducts.isNotEmpty;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _autoSelectFirstMyProductIfNeeded(home);
        });

        final List<Product> productsAfterFilters = _filters.apply(
          allProducts,
          myProduct: home.myProduct,
        );

        final List<Product> visibleProducts = productsAfterFilters;

        final bool hasVisibleItems = visibleProducts.isNotEmpty;
        final bool showPreferredCategoriesHint =
            _preferredCategoriesHintSeenLoaded && _showPreferredCategoriesHint;
        final bool showHeaderActions = showPreferredCategoriesHint ||
            productsAfterFilters.isNotEmpty ||
            allProducts.isNotEmpty;
        final bool showTrustedNetworkHint =
            _trustedNetworkHintSeenLoaded &&
                _showTrustedNetworkHint &&
                visibleProducts.length >= 4;
        final bool playPreferredCategoriesButtonAttention =
            showPreferredCategoriesHint && _playPreferredCategoriesButtonAttention;
        final bool playTrustedNetworkButtonAttention =
            showTrustedNetworkHint && _playTrustedNetworkButtonAttention;

        _markVisibleOneShotAttentionIfNeeded(
          showPreferredCategoriesHint: showPreferredCategoriesHint,
          showTrustedNetworkHint: showTrustedNetworkHint,
        );

        if (!hasItems || !hasVisibleItems) {
          _didInitSync = false;
          if (_currentIndex != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _currentIndex = 0);
              }
            });
          }
        } else if (!_didInitSync) {
          _didInitSync = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || visibleProducts.isEmpty) return;

            int startIndex = 0;
            final String? selectedId = home.selectedSwapProduct?.id;
            if (selectedId != null) {
              final int i =
              visibleProducts.indexWhere((Product e) => e.id == selectedId);
              if (i >= 0) {
                startIndex = i;
              }
            }

            _syncSelectedSwapFromVisible(home, visibleProducts, startIndex);
          });
        } else if (hasVisibleItems) {
          final String? selectedId = home.selectedSwapProduct?.id;
          final bool selectedStillVisible = selectedId != null &&
              visibleProducts.any((Product e) => e.id == selectedId);

          if (!selectedStillVisible && _currentIndex == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || visibleProducts.isEmpty) return;
              _syncSelectedSwapFromVisible(home, visibleProducts, 0);
            });
          }

          if (_currentIndex >= visibleProducts.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || visibleProducts.isEmpty) return;
              final int fixedIndex = visibleProducts.length - 1;
              _syncSelectedSwapFromVisible(home, visibleProducts, fixedIndex);
            });
          }
        }

        final double screenW = MediaQuery.of(context).size.width;
        final bool smallLayout = screenW < 390;
        final bool compact = MediaQuery.of(context).size.height < 760;

        final double screenH = MediaQuery.of(context).size.height;
        final double sectionHeight = (screenH -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom -
            150)
            .clamp(520.0, 760.0);

        final double mainHeaderHeight = compact ? 54 : 56;
        final double productsBarHeight = home.myProducts.isEmpty
            ? (compact ? 44 : 46)
            : (compact ? 66 : 68);
        const double headerGap = 8;

        final double fixedHeaderHeight = mainHeaderHeight +
            headerGap +
            productsBarHeight;
        final bool showFloatingConsultButton =
            hasVisibleItems && !home.recLoading && !home.isMyProductPending;
        final List<Product> consultSuggestions = visibleProducts
            .take(5)
            .toList(growable: false);
        return SizedBox(
          height: sectionHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              PositionedDirectional(
                start: 0,
                end: 0,
                top: 0,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6FBFD),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: mainHeaderHeight,
                        margin: const EdgeInsetsDirectional.only(
                          start: 2,
                          end: 2,
                          top: 2,
                        ),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          10,
                          9,
                          10,
                          9,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: AlignmentDirectional.topStart,
                            end: AlignmentDirectional.bottomEnd,
                            colors: <Color>[
                              Color(0xFF0C587A),
                              Color(0xFF0A7EA0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x220C587A),
                              blurRadius: 14,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'ترشيحات التبديل',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15.2,
                                  height: 1.05,
                                ),
                              ),
                            ),
                            if (showHeaderActions) ...<Widget>[
                              const SizedBox(width: 8),
                              _SuggestedSwapHeaderActions(
                                activeFilterCount: _filters.activeCount,
                                filteredCount: productsAfterFilters.length,
                                totalCount: allProducts.length,
                                showEditInterestsLabel: showPreferredCategoriesHint,
                                playEditInterestsAttention:
                                playPreferredCategoriesButtonAttention,
                                onEditInterests: _openEditInterestsFromPreferredHint,
                                onOpenFilters: () {
                                  _openSuggestedSwapFiltersSheet(allProducts);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: headerGap),
                      _SuggestedSwapsProductsBar(
                        products: home.myProducts,
                        selectedProductId: home.myProduct?.id,
                        selectedRecommendationsCount: productsAfterFilters.length,
                        onTapProduct: (int index) =>
                            _selectMyProductByIndex(home, index),
                      ),
                    ],
                  ),
                ),
              ),

              PositionedDirectional(
                start: 0,
                end: 0,
                top: fixedHeaderHeight,
                bottom: 0,
                child: !hasItems || !hasVisibleItems
                    ? Center(
                  child: home.recLoading
                      ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(),
                  )
                      : Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      Utils.getString(context, 'no__suggestions'),
                    ),
                  ),
                )
                    : home.myProducts.isEmpty
                    ? _SuggestedRecommendationsFeedPage(
                  myProduct: home.myProduct,
                  suggestions: visibleProducts,
                  compact: compact,
                  smallLayout: smallLayout,
                  isCurrentPage: true,
                  totalSuggestionsCount: visibleProducts.length,
                  myProductsCount: home.myProducts.length,
                  buildVm: _buildVm,
                  relationCodeOf: _getRelationCode,
                  onTapMyProduct: (Product? product) {
                    if (product != null) {
                      _openProductDetails(context, product);
                    }
                  },
                  selectedSuggestedProductId:
                  explicitlySelectedSuggestedSwapIdNotifier.value,
                  disableSelection: home.isMyProductPending,
                  onSelectSuggestedProduct: (Product product) =>
                      _selectSuggestedSwapProduct(home, product),
                  onRequestSwapProduct: (Product product) =>
                      _requestSwapForSuggestion(home, product),
                  onHideSuggestedProduct: _openHideSuggestedSwapSheet,
                  onTapSuggestedProduct: (Product product) {
                    _openProductDetails(context, product);
                  },
                  onEditInterests: _openEditInterests,
                  onOpenNetworkSheet: _openRecommendationNetworkSheet,
                  showTrustedNetworkHint: showTrustedNetworkHint,
                  playTrustedNetworkButtonAttention: playTrustedNetworkButtonAttention,
                  onTrustedNetworkHintVisible: _handleTrustedNetworkHintVisible,
                  onTrustedNetworkHintTap: _openTrustedNetworkHint,
                  onUserScroll: _closeRecommendationToolsOnUserScroll,
                  onReachedEnd: _handleRecommendationsReachedEnd,
                )
                    : _SuggestedRecommendationsFeedPage(
                  myProduct: home.myProduct,
                  suggestions: visibleProducts,
                  compact: compact,
                  smallLayout: smallLayout,
                  isCurrentPage: true,
                  totalSuggestionsCount: visibleProducts.length,
                  myProductsCount: home.myProducts.length,
                  buildVm: _buildVm,
                  relationCodeOf: _getRelationCode,
                  onTapMyProduct: (Product? product) {
                    if (product != null) {
                      _openProductDetails(context, product);
                    }
                  },
                  selectedSuggestedProductId:
                  explicitlySelectedSuggestedSwapIdNotifier.value,
                  disableSelection: home.isMyProductPending,
                  onSelectSuggestedProduct: (Product product) =>
                      _selectSuggestedSwapProduct(home, product),
                  onRequestSwapProduct: (Product product) =>
                      _requestSwapForSuggestion(home, product),
                  onHideSuggestedProduct: _openHideSuggestedSwapSheet,
                  onTapSuggestedProduct: (Product product) {
                    _openProductDetails(context, product);
                  },
                  onEditInterests: _openEditInterests,
                  onOpenNetworkSheet: _openRecommendationNetworkSheet,
                  showTrustedNetworkHint: showTrustedNetworkHint,
                  playTrustedNetworkButtonAttention: playTrustedNetworkButtonAttention,
                  onTrustedNetworkHintVisible: _handleTrustedNetworkHintVisible,
                  onTrustedNetworkHintTap: _openTrustedNetworkHint,
                  onUserScroll: _closeRecommendationToolsOnUserScroll,
                  onReachedEnd: _handleRecommendationsReachedEnd,
                ),
              ),

              if (showFloatingConsultButton)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 60,
                  child: Center(
                    child: _FloatingConsultFriendsButton(
                      enabled: true,
                      myProduct: home.myProduct,
                      suggestions: consultSuggestions,
                      playAttention: _playConsultFriendsButtonAttention,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}


class _SuggestedRecommendationsFeedPage extends StatelessWidget {
  const _SuggestedRecommendationsFeedPage({
    required this.myProduct,
    required this.suggestions,
    required this.compact,
    required this.smallLayout,
    required this.isCurrentPage,
    required this.totalSuggestionsCount,
    required this.myProductsCount,
    required this.buildVm,
    required this.relationCodeOf,
    required this.selectedSuggestedProductId,
    required this.disableSelection,
    required this.onSelectSuggestedProduct,
    required this.onRequestSwapProduct,
    required this.onHideSuggestedProduct,
    required this.onTapMyProduct,
    required this.onTapSuggestedProduct,
    required this.onEditInterests,
    required this.onOpenNetworkSheet,
    required this.showTrustedNetworkHint,
    required this.playTrustedNetworkButtonAttention,
    required this.onTrustedNetworkHintVisible,
    required this.onTrustedNetworkHintTap,
    required this.onUserScroll,
    required this.onReachedEnd,
  });

  final Product? myProduct;
  final List<Product> suggestions;
  final bool compact;
  final bool smallLayout;
  final bool isCurrentPage;
  final int totalSuggestionsCount;
  final int myProductsCount;
  final InlineSwapVM Function(Product product) buildVm;
  final String? Function(Product product) relationCodeOf;
  final String? selectedSuggestedProductId;
  final bool disableSelection;
  final ValueChanged<Product> onSelectSuggestedProduct;
  final ValueChanged<Product> onRequestSwapProduct;
  final ValueChanged<Product> onHideSuggestedProduct;
  final ValueChanged<Product?> onTapMyProduct;
  final ValueChanged<Product> onTapSuggestedProduct;
  final VoidCallback onEditInterests;
  final VoidCallback onOpenNetworkSheet;
  final bool showTrustedNetworkHint;
  final bool playTrustedNetworkButtonAttention;
  final VoidCallback onTrustedNetworkHintVisible;
  final VoidCallback onTrustedNetworkHintTap;
  final VoidCallback onUserScroll;
  final VoidCallback onReachedEnd;


  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final int trustedHintIndex = suggestions.length >= 4 ? 3 : suggestions.length;
    final int listItemCount = suggestions.length + (showTrustedNetworkHint ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is UserScrollNotification &&
            notification.direction != ScrollDirection.idle) {
          onUserScroll();
        }

        if (notification.metrics.pixels > 0 &&
            notification.metrics.extentAfter <= 80) {
          onReachedEnd();
        }

        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 92),
        physics: const BouncingScrollPhysics(),
        itemCount: listItemCount,
        itemBuilder: (BuildContext context, int index) {
          if (showTrustedNetworkHint && index == trustedHintIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TrustedNetworkHintSection(
                onVisible: onTrustedNetworkHintVisible,
                onTap: onTrustedNetworkHintTap,
                playButtonAttention: playTrustedNetworkButtonAttention,
              ),
            );
          }

          final int suggestionIndex =
          showTrustedNetworkHint && index > trustedHintIndex ? index - 1 : index;
          final Product suggestion = suggestions[suggestionIndex];
          final InlineSwapVM vm = buildVm(suggestion);

          final Widget suggestionCard = _SuggestionCompareCard(
            myProduct: myProduct,
            product: suggestion,
            vm: vm,
            compact: compact,
            smallLayout: smallLayout,
            isActive: isCurrentPage &&
                selectedSuggestedProductId != null &&
                selectedSuggestedProductId == (suggestion.id ?? '').toString().trim(),
            relationBackendCode: relationCodeOf(suggestion),
            index: suggestionIndex,
            selectionEnabled: !disableSelection,
            myProductPending: disableSelection,
            onSelectCard: () => onSelectSuggestedProduct(suggestion),
            onRequestSwap: () => onRequestSwapProduct(suggestion),
            onHideCard: () => onHideSuggestedProduct(suggestion),
            onTapSuggestedProduct: () => onTapSuggestedProduct(suggestion),
            onTapMyProduct: () => onTapMyProduct(myProduct),
            onEditInterests: onEditInterests,
            onOpenNetworkSheet: onOpenNetworkSheet,
            showTopControls: false,
          );

          return Padding(
            padding: EdgeInsets.only(
              bottom: suggestionIndex == suggestions.length - 1 ? 6 : 14,
            ),
            child: disableSelection && suggestionIndex == 0
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const _PendingMyProductReviewNotice(),
                      suggestionCard,
                    ],
                  )
                : suggestionCard,
          );
        },
      ),
    );
  }
}



