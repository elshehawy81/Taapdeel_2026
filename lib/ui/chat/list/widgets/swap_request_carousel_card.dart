import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/SwapProductsProvider.dart';
import 'package:taapdeel/provider/chat/buyer_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/seller_chat_history_list_provider.dart';
import 'package:taapdeel/provider/mainBuyer_provider.dart';
import 'package:taapdeel/provider/main_provider.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/chat_history.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/chat_history_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/make_mark_as_sold_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/make_offer_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/taapdeel/taapdeel_button.dart';
import '../../../offer/add_swap_offer/AddSwapOfferScreen.dart';
import '../../../rating/entry/rating_input_dialog.dart';
import '../../enum/user_type.dart';
import 'swap_request_compare_strip.dart';
import 'package:taapdeel/ui/Foryou/widgets/swap_rating.dart';
import 'swap_request_status_badge.dart';

class SwapRequestCarouselCard extends StatelessWidget {
  const SwapRequestCarouselCard({
    Key? key,
    required this.request,
    required this.userType,
    required this.index,
    required this.totalCount,
    this.providerS,
    this.providerB,
    this.onTapCard,
  }) : super(key: key);

  final ChatHistory request;
  final UserType userType;
  final int index;
  final int totalCount;
  final SellerChatHistoryListProvider? providerS;
  final BuyerChatHistoryListProvider? providerB;
  final VoidCallback? onTapCard;

  static const Color _brandDark = Color(0xFF062C55);
  static const Color _brandTeal = Color(0xFF13A8AA);
  static const Color _danger = Color(0xFFB33951);
  static const Color _softDangerBg = Color(0xFFFFF8F9);
  static const Color _softBlueBg = Color(0xFFF4FBFD);
  static const Color _whatsAppGreen = Color(0xFF25D366);

  Product? get _myProduct {
    if (userType == UserType.seller) {
      return request.item;
    }
    return request.buyerItem;
  }

  Product? get _otherProduct {
    if (userType == UserType.seller) {
      return request.buyerItem;
    }
    return request.item;
  }

  int? _requestRelationType() {
    final dynamic r = request;

    final List<dynamic Function()> readers = <dynamic Function()>[
          () => r.relationType,
          () => r.relation_type,
          () => r.ownerRelationType,
          () => r.owner_relation_type,
          () => r.toJson()['relation_type'],
          () => r.toJson()['relationType'],
          () => r.toMap()['relation_type'],
          () => r.toMap()['relationType'],
    ];

    for (final dynamic Function() reader in readers) {
      try {
        final dynamic value = reader();
        final int? parsed = _parseNullableInt(value);
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      } catch (_) {
        // Ignore missing dynamic field.
      }
    }

    final String relationCode = _requestRelationCode();
    return _relationTypeFromCode(relationCode);
  }

  String _requestRelationCode() {
    final dynamic r = request;

    final List<dynamic Function()> readers = <dynamic Function()>[
          () => r.relationCode,
          () => r.relation_code,
          () => r.ownerRelationCode,
          () => r.owner_relation_code,
          () => r.toJson()['relation_code'],
          () => r.toJson()['relationCode'],
          () => r.toMap()['relation_code'],
          () => r.toMap()['relationCode'],
    ];

    for (final dynamic Function() reader in readers) {
      try {
        final String value = (reader() ?? '').toString().trim().toUpperCase();
        if (value.isNotEmpty && value != 'NULL' && value != 'NONE') {
          return value;
        }
      } catch (_) {
        // Ignore missing dynamic field.
      }
    }

    return '';
  }

  int? _relationTypeFromCode(String code) {
    switch (code.trim().toUpperCase()) {
      case 'FRIEND':
        return 1;
      case 'SPOUSE':
        return 2;
      case 'CHILD':
        return 3;
      case 'PARENT':
      case 'PARENTS':
        return 4;
      case 'SIBLING':
        return 5;
      case 'BIG_FAMILY':
      case 'FAMILY':
        return 6;
      case 'SELF':
        return 777;
      case 'FRIEND_OF_FRIEND':
        return 999;
      case 'FRIENDS_FAMILY':
        return 1001;
      case 'FRIENDS_BIG_FAMILY':
        return 1002;
      case 'FRIEND_OF_FAMILY':
        return 1003;
      case 'FRIEND_OF_BIG_FAMILY':
        return 1004;
      case 'RELATIVES':
      case 'RELATIVE':
        return 1005;
      default:
        return null;
    }
  }

  int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    final double? asDouble = double.tryParse(text);
    if (asDouble != null) {
      return asDouble.round();
    }

    return int.tryParse(text);
  }

  List<SwapCriterionItem> _buildUnifiedReasonItems({
    required Product? myProduct,
    required Product? otherProduct,
    required String otherUserName,
  }) {
    if (otherProduct == null) {
      return const <SwapCriterionItem>[];
    }

    final InlineSwapVM vm = buildInlineSwapVM(
      percent: 0,
      breakdown: const <Map<String, dynamic>>[],
    );

    return buildSuggestedSwapCriteria(
      otherProduct,
      vm,
      myProduct: myProduct,
      relationTypeOverride: _requestRelationType(),
      relationOwnerNameOverride: otherUserName,
    ).where((SwapCriterionItem item) => item.enabled).toList(growable: false);
  }

  String _otherUserName(BuildContext context) {
    if (userType == UserType.seller) {
      return (request.buyer?.userName ?? '').trim().isEmpty
          ? Utils.getString(context, 'default__user_name')
          : request.buyer!.userName!;
    }

    return (request.seller?.userName ?? '').trim().isEmpty
        ? Utils.getString(context, 'default__user_name')
        : request.seller!.userName!;
  }

  Future<bool> _showConfirmSheet(
      BuildContext context, {
        required String title,
        required String message,
        required String confirmText,
        bool danger = false,
      }) async {
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 22,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7E3EA),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: danger ? _softDangerBg : _softBlueBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: danger
                                ? _danger.withOpacity(0.22)
                                : _brandTeal.withOpacity(0.22),
                          ),
                        ),
                        child: Icon(
                          danger
                              ? Icons.warning_amber_rounded
                              : Icons.swap_horiz_rounded,
                          color: danger ? _danger : _brandTeal,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.right,
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _brandDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PsColors.textColor3,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TaapdeelButton(
                          label: Utils.getString(context, 'dialog__cancel'),
                          onPressed: () => Navigator.pop(sheetContext, false),
                          isPrimary: false,
                          outlined: true,
                          height: 44,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TaapdeelButton(
                          label: confirmText,
                          onPressed: () => Navigator.pop(sheetContext, true),
                          isPrimary: !danger,
                          outlined: false,
                          height: 44,
                          backgroundColorOverride: danger ? _danger : null,
                          foregroundColorOverride:
                          danger ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return result == true;
  }

  Future<void> _cancelRequest(BuildContext context) async {
    final bool confirmed = await _showConfirmSheet(
      context,
      title: 'إلغاء الطلب',
      message: 'هل تريد إلغاء طلب التبديل؟ سيتم نقل الطلب إلى حالة الرفض.',
      confirmText: 'إلغاء الطلب',
      danger: true,
    );

    if (!confirmed) return;

    final BuyerChatHistoryListProvider buyerProvider =
    Provider.of<BuyerChatHistoryListProvider>(context, listen: false);

    EasyLoading.show();

    final MakeOfferParameterHolder requestBody = MakeOfferParameterHolder(
      itemId: request.item?.id,
      buyerUserId: request.buyerUserId,
      sellerUserId: request.sellerUserId,
      isUserOnline: '0',
      buyerItemId: request.buyerItem?.id,
      negoPrice: '0',
      type: PsConst.CHAT_TO_BUYER,
    );

    final dynamic response = await buyerProvider.cancelRequest(
      requestBody.toMap(),
    );

    EasyLoading.dismiss();

    if (response == 'success') {
      request.offerStatus = PsConst.REQUEST_REJECTED;
      buyerProvider.notifyListeners();

      if (providerB != null) {
        MainBuyerProvider.of(context, listen: false)
            .getSentList(context, providerB!);
      }

      EasyLoading.showToast('Request cancelled');
    }
  }

  Future<void> _buyerConfirmItemDelivery(BuildContext context) async {
    final bool confirmed = await _showConfirmSheet(
      context,
      title: 'تأكيد إتمام التبديل',
      message:
      'اضغط تأكيد فقط إذا تم الاتفاق النهائي مع الطرف الآخر وتريد اعتبار عملية التبديل مكتملة.',
      confirmText: 'تأكيد التبديل',
      danger: false,
    );

    if (!confirmed) return;

    EasyLoading.show();

    final MakeMarkAsSoldParameterHolder markAsSold =
    MakeMarkAsSoldParameterHolder(
      itemId: request.itemId,
      buyerUserId: request.buyerUserId,
      sellerUserId: request.sellerUserId,
      buyerItemId: request.buyerItem?.id,
    );

    await Provider.of<SwapProductsProvider>(context, listen: false)
        .BuyermakeMarkAsSold(markAsSold.toMap(), request.buyerUserId);

    EasyLoading.dismiss();

    request.offerStatus = PsConst.REQUEST_SWAPPED;

    if (providerB != null) {
      providerB!.notifyListeners();
      MainBuyerProvider.of(context, listen: false)
          .getSentList(context, providerB!);
    }

    EasyLoading.showToast('Request Swapped');
  }

  Future<void> _sellerApproveRequest(BuildContext context) async {
    if (providerS == null) return;

    final bool confirmed = await _showConfirmSheet(
      context,
      title: 'قبول العرض للمناقشة',
      message:
      'قبول العرض لا يعني إتمام التبديل.\n\n سيتم نقل الطلب إلى مرحلة مناقشة التفاصيل مع الطرف الآخر \n\n سيتم اظهار رقم الهاتف الخاص بك للطرف الاخر للتواصل على واتساب.',
      confirmText: 'ابدأ المناقشة',
      danger: false,
    );

    if (!confirmed) return;

    EasyLoading.show();

    final MakeOfferParameterHolder requestBody = MakeOfferParameterHolder(
      itemId: request.item?.id,
      buyerUserId: request.buyerUserId,
      sellerUserId: request.sellerUserId,
      isUserOnline: '0',
      buyerItemId: request.buyerItem?.id,
      negoPrice: '1',
      type: PsConst.CHAT_TO_BUYER,
    );

    await Provider.of<SwapProductsProvider>(context, listen: false)
        .approveRequest(requestBody.toMap());

    EasyLoading.dismiss();

    request.offerStatus = PsConst.REQUEST_ACCEPTED;
    providerS!.notifyListeners();

    MainProvider.of(context, listen: false).getSentList(context, providerS!);

    EasyLoading.showToast('Request accepted');
  }

  Future<void> _sellerRejectRequest(BuildContext context) async {
    if (providerS == null) return;

    final bool confirmed = await _showConfirmSheet(
      context,
      title: 'رفض العرض',
      message: 'هل تريد رفض عرض التبديل؟ لن يظهر هذا العرض كطلب نشط بعد الرفض.',
      confirmText: 'رفض العرض',
      danger: true,
    );

    if (!confirmed) return;

    EasyLoading.show();

    final MakeOfferParameterHolder requestBody = MakeOfferParameterHolder(
      itemId: request.item?.id,
      buyerUserId: request.buyerUserId,
      sellerUserId: request.sellerUserId,
      isUserOnline: '0',
      buyerItemId: request.buyerItem?.id,
      negoPrice: '0',
      type: PsConst.CHAT_TO_BUYER,
    );

    final dynamic response =
    await Provider.of<SwapProductsProvider>(context, listen: false)
        .rejectOffer(requestBody.toMap());

    EasyLoading.dismiss();

    if (response == 'success') {
      request.offerStatus = PsConst.REQUEST_REJECTED;
      providerS!.notifyListeners();

      MainProvider.of(context, listen: false).getSentList(context, providerS!);

      EasyLoading.showToast('Request rejected');
    }
  }

  Future<void> _sellerCancelAgreement(BuildContext context) async {
    if (providerS == null) return;

    final bool confirmed = await _showConfirmSheet(
      context,
      title: 'إلغاء الاتفاق',
      message:
      'هل تريد إلغاء الاتفاق الحالي؟ سيتم اعتبار الطلب مرفوضًا ولن يتم إتمام التبديل.',
      confirmText: 'إلغاء الاتفاق',
      danger: true,
    );

    if (!confirmed) return;

    EasyLoading.show();

    final MakeOfferParameterHolder requestBody = MakeOfferParameterHolder(
      itemId: request.item?.id,
      buyerUserId: request.buyerUserId,
      sellerUserId: request.sellerUserId,
      isUserOnline: '0',
      buyerItemId: request.buyerItem?.id,
      negoPrice: '0',
      type: PsConst.CHAT_TO_BUYER,
    );

    final dynamic response =
    await Provider.of<SwapProductsProvider>(context, listen: false)
        .rejectOffer(requestBody.toMap());

    EasyLoading.dismiss();

    if (response == 'success') {
      request.offerStatus = PsConst.REQUEST_REJECTED;
      providerS!.notifyListeners();

      MainProvider.of(context, listen: false).getSentList(context, providerS!);

      EasyLoading.showToast('Agreement cancelled');
    }
  }

  Future<void> _sellerConfirmItemDelivery(BuildContext context) async {
    if (providerS == null) return;

    final bool confirmed = await _showConfirmSheet(
      context,
      title: 'تأكيد إتمام التبديل',
      message:
      'اضغط تأكيد فقط إذا تم الاتفاق النهائي مع الطرف الآخر وتريد اعتبار عملية التبديل مكتملة.',
      confirmText: 'تأكيد التبديل',
      danger: false,
    );

    if (!confirmed) return;

    EasyLoading.show();

    final MakeMarkAsSoldParameterHolder makeMarkAsSoldHolder =
    MakeMarkAsSoldParameterHolder(
      itemId: request.itemId,
      buyerUserId: request.buyerUserId,
      sellerUserId: request.sellerUserId,
      buyerItemId: request.buyerItem?.id,
    );

    await Provider.of<SwapProductsProvider>(context, listen: false)
        .makeMarkAsSold(makeMarkAsSoldHolder.toMap(), request.sellerUserId);

    EasyLoading.dismiss();

    request.offerStatus = PsConst.REQUEST_SWAPPED;
    providerS!.notifyListeners();

    MainProvider.of(context, listen: false).getSentList(context, providerS!);

    EasyLoading.showToast('Request Swapped');
  }

  Future<void> _sellerChooseAnotherProduct(BuildContext context) async {
    final bool? changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (BuildContext sheetContext) {
        return AddSwapOfferScreen(
          args: <String, dynamic>{
            'productId': request.item?.id,
            'productPriceType': request.item?.price,
            'productSellerId': request.item?.addedUserId,
            'chatModel': request,
            'chooseAnotherPro': true,
            'asBottomSheet': true,
          },
        );
      },
    );

    if (changed != true || providerS == null) {
      return;
    }

    request.offerStatus = PsConst.REQUEST_REJECTED;
    providerS!.notifyListeners();
    MainProvider.of(context, listen: false).getSentList(context, providerS!);
  }



  String _readDynamicString(dynamic source, List<String> fieldNames) {
    if (source == null) return '';

    for (final String fieldName in fieldNames) {
      try {
        final dynamic value = source.toJson != null ? source.toJson()[fieldName] : null;
        final String text = (value ?? '').toString().trim();
        if (text.isNotEmpty && text != 'null') {
          return text;
        }
      } catch (_) {
        // Ignore and try direct dynamic access below.
      }
    }

    try {
      final String text = (source.userPhone ?? '').toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    } catch (_) {}

    try {
      final String text = (source.phone ?? '').toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    } catch (_) {}

    try {
      final String text = (source.user_phone ?? '').toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    } catch (_) {}

    try {
      final String text = (source.contactPhone ?? '').toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    } catch (_) {}

    return '';
  }

  String _otherUserPhone() {
    final dynamic otherUser =
    userType == UserType.seller ? request.buyer : request.seller;

    return _readDynamicString(
      otherUser,
      <String>[
        'user_phone',
        'userPhone',
        'phone',
        'contact_phone',
        'contactPhone',
      ],
    );
  }

  String _normalizeEgyptPhoneForWhatsApp(String rawPhone) {
    String phone = rawPhone.trim();

    phone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    if (phone.startsWith('00')) {
      phone = phone.substring(2);
    }

    if (phone.startsWith('0') && phone.length == 11) {
      phone = '20${phone.substring(1)}';
    }

    if (phone.length == 10 && phone.startsWith('1')) {
      phone = '20$phone';
    }

    return phone;
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    if (!await Utils.checkInternetConnectivity()) {
      EasyLoading.showToast('لا يوجد اتصال بالإنترنت');
      return;
    }

    final String rawPhone = _otherUserPhone();

    if (rawPhone.isEmpty || rawPhone == 'null') {
      EasyLoading.showToast('رقم الهاتف غير متاح لهذا المستخدم');
      return;
    }

    final String phone = _normalizeEgyptPhoneForWhatsApp(rawPhone);

    if (phone.isEmpty || phone.length < 10) {
      EasyLoading.showToast('رقم الهاتف غير صحيح');
      return;
    }

    final String message = Uri.encodeComponent(
      'مرحبًا، أنا من تطبيق تبديل. حابب نتناقش بخصوص طلب التبديل.',
    );

    final Uri whatsAppUri = Uri.parse('https://wa.me/$phone?text=$message');

    final bool launched = await launchUrl(
      whatsAppUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      EasyLoading.showToast('تعذر فتح واتساب');
    }
  }

  Future<void> _openReviewDialog(BuildContext context) async {
    await showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        if (userType == UserType.seller) {
          return RatingInputDialog(
            buyerUserId: request.sellerUserId,
            sellerUserId: request.buyerUserId,
          );
        }

        return RatingInputDialog(
          buyerUserId: request.buyerUserId,
          sellerUserId: request.sellerUserId,
        );
      },
    );
  }

  String _safeProductId(Product? product) {
    final String productId = (product?.id ?? '').toString().trim();
    if (productId.isNotEmpty && productId != 'null') {
      return productId;
    }

    return '';
  }

  void _openProduct(BuildContext context, Product? product) {
    final String productId = _safeProductId(product);
    if (productId.isEmpty) {
      return;
    }

    final ProductDetailIntentHolder holder = ProductDetailIntentHolder(
      productId: productId,
      heroTagImage: '${productId.hashCode}$productId${PsConst.HERO_TAG__IMAGE}',
      heroTagTitle: '${productId.hashCode}$productId${PsConst.HERO_TAG__TITLE}',
    );

    Navigator.pushNamed(
      context,
      RoutePaths.productDetail,
      arguments: holder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Product? myProduct = _myProduct;
    final Product? otherProduct = _otherProduct;
    final String otherUserName = _otherUserName(context);
    final String addedDate = (request.addedDateStr ?? '').trim();

    final Widget content = Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isTight = constraints.maxHeight <= 370;
          final double buttonHeight = isTight ? 28 : 34;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            padding: EdgeInsets.fromLTRB(10, isTight ? 8 : 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF127E95),
                width: 1,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0F011934),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _CarouselCardTopBar(
                  request: request,
                  userType: userType,
                  otherUserName: otherUserName,
                  addedDate: addedDate,
                  currentIndex: index,
                  totalCount: totalCount,
                  compact: isTight,
                ),
                SizedBox(height: isTight ? 7 : 9),
                Container(

                  child: SwapRequestCompareStrip(
                    myProduct: myProduct,
                    otherProduct: otherProduct,
                    onTapMyProduct: () => _openProduct(context, myProduct),
                    onTapOtherProduct: () => _openProduct(context, otherProduct),
                  ),
                ),
                SizedBox(height: isTight ? 7 : 9),
                SuggestedSwapReasonsGrid(
                  items: _buildUnifiedReasonItems(
                    myProduct: myProduct,
                    otherProduct: otherProduct,
                    otherUserName: otherUserName,
                  ),
                  compact: isTight,
                ),
                SizedBox(height: isTight ? 7 : 9),
                _ActionsSection(
                  child: _buildActions(context, buttonHeight: buttonHeight),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (onTapCard == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTapCard,
        borderRadius: BorderRadius.circular(24),
        child: content,
      ),
    );
  }

  Widget _buildActions(BuildContext context, {required double buttonHeight}) {
    if (userType == UserType.seller) {
      return _buildSellerActions(context, buttonHeight: buttonHeight);
    }

    return _buildBuyerActions(context, buttonHeight: buttonHeight);
  }

  Widget _buildBuyerActions(
      BuildContext context, {
        required double buttonHeight,
      }) {
    switch (request.offerStatus) {
      case PsConst.REQUEST_PENDING:
        return _buildSingleButton(
          child: TaapdeelButton(
            label: Utils.getString(context, 'cancel_request'),
            onPressed: () async {
              await _cancelRequest(context);
            },
            isPrimary: false,
            outlined: false,
            height: buttonHeight,
            backgroundColorOverride: const Color(0xFFFFFFFF),
            foregroundColorOverride: _danger,
            outerBorderColor: _danger,
            outerBorderWidth: 1.2,
          ),
        );

      case PsConst.REQUEST_ACCEPTED:
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TaapdeelButton(
                    label: 'مناقشة الاتفاق-واتساب',
                    onPressed: () async {
                      await _openWhatsApp(context);
                    },
                    isPrimary: false,
                    outlined: false,
                    height: buttonHeight,
                    backgroundColorOverride: _whatsAppGreen,
                    foregroundColorOverride: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TaapdeelButton(
                    label: 'تأكيد إتمام التبديل',
                    onPressed: () async {
                      await _buyerConfirmItemDelivery(context);
                    },
                    isPrimary: true,
                    outlined: false,
                    height: buttonHeight,
                  ),
                ),


              ],
            ),
            const SizedBox(height: 7),
            _buildSingleButton(
              child: TaapdeelButton(
                label: 'إلغاء الاتفاق',
                onPressed: () async {
                  await _cancelRequest(context);
                },
                isPrimary: false,
                outlined: false,
                height: buttonHeight,
                backgroundColorOverride: const Color(0xFFFFFFFF),
                foregroundColorOverride: _danger,
                outerBorderColor: _danger,
                outerBorderWidth: 1.2,
              ),
            ),
          ],
        );

      case PsConst.REQUEST_SWAPPED:
        return _buildSingleButton(
          child: TaapdeelButton(
            label: Utils.getString(context, 'chat_view__give_review_button'),
            onPressed: () async {
              await _openReviewDialog(context);
            },
            isPrimary: true,
            outlined: false,
            height: buttonHeight,
          ),
        );

      case PsConst.REQUEST_REJECTED:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSellerActions(
      BuildContext context, {
        required double buttonHeight,
      }) {
    switch (request.offerStatus) {
      case PsConst.REQUEST_PENDING:
        return Column(
          children: <Widget>[
            _buildSingleButton(
              child: TaapdeelButton(
                label: 'قبول مبدئي ومناقشة',
                onPressed: () async {
                  await _sellerApproveRequest(context);
                },
                isPrimary: true,
                outlined: false,
                height: buttonHeight,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: <Widget>[
                Expanded(
                  child: TaapdeelButton(
                    label: 'منتج آخر',
                    onPressed: () async {
                      await _sellerChooseAnotherProduct(context);
                    },
                    isPrimary: false,
                    outlined: true,
                    height: buttonHeight,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TaapdeelButton(
                    label: 'رفض',
                    onPressed: () async {
                      await _sellerRejectRequest(context);
                    },
                    isPrimary: false,
                    outlined: false,
                    height: buttonHeight,
                    backgroundColorOverride: const Color(0xFFFFFFFF),
                    foregroundColorOverride: _danger,
                    outerBorderColor: _danger,
                    outerBorderWidth: 1.2,
                  ),
                ),
              ],
            ),
          ],
        );

      case PsConst.REQUEST_ACCEPTED:
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TaapdeelButton(
                    label: 'مناقشة الاتفاق-واتساب',
                    onPressed: () async {
                      await _openWhatsApp(context);
                    },
                    isPrimary: false,
                    outlined: false,
                    height: buttonHeight,
                    backgroundColorOverride: _whatsAppGreen,
                    foregroundColorOverride: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TaapdeelButton(
                    label: 'تأكيد إتمام التبديل',
                    onPressed: () async {
                      await _sellerConfirmItemDelivery(context);
                    },
                    isPrimary: true,
                    outlined: false,
                    height: buttonHeight,
                  ),
                ),


              ],
            ),
            const SizedBox(height: 7),
            _buildSingleButton(
              child: TaapdeelButton(
                label: 'إلغاء الاتفاق',
                onPressed: () async {
                  await _sellerCancelAgreement(context);
                },
                isPrimary: false,
                outlined: false,
                height: buttonHeight,
                backgroundColorOverride: const Color(0xFFFFFFFF),
                foregroundColorOverride: _danger,
                outerBorderColor: _danger,
                outerBorderWidth: 1.2,
              ),
            ),
          ],
        );

      case PsConst.REQUEST_SWAPPED:
        return _buildSingleButton(
          child: TaapdeelButton(
            label: Utils.getString(context, 'chat_view__give_review_button'),
            onPressed: () async {
              await _openReviewDialog(context);
            },
            isPrimary: true,
            outlined: false,
            height: buttonHeight,
          ),
        );

      case PsConst.REQUEST_REJECTED:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSingleButton({required Widget child}) {
    return Row(
      children: <Widget>[
        Expanded(child: child),
      ],
    );
  }
}

class _CarouselCardTopBar extends StatelessWidget {
  const _CarouselCardTopBar({
    Key? key,
    required this.request,
    required this.userType,
    required this.otherUserName,
    required this.addedDate,
    required this.currentIndex,
    required this.totalCount,
    this.compact = false,
  }) : super(key: key);

  final ChatHistory request;
  final UserType userType;
  final String otherUserName;
  final String addedDate;
  final int currentIndex;
  final int totalCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String titlePrefix = userType == UserType.seller ? 'عرض من' : 'إلى';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '$titlePrefix ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PsColors.textColor3,
                        fontWeight: FontWeight.w600,
                        fontSize: compact ? 9.8 : 10.5,
                      ),
                    ),
                    TextSpan(
                      text: otherUserName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: PsColors.textColor2,
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 12.8 : 13.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            SwapRequestStatusBadge(
              request: request,
              userType: userType,
              compact: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (child is SizedBox) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
      child: child,
    );
  }
}