import 'package:taapdeel/ui/item/detail/widgets/poduct_promote.dart';

import '../../../../paymob_payment/ui/pakages_screen/packages_screen.dart';
import '../../../../provider/product/favourite_item_provider.dart';
import '../../../../provider/product/product_provider.dart';
import '../../../../provider/app_info/app_info_provider.dart';
import '../../../../provider/product/mark_sold_out_item_provider.dart';
import '../../../../provider/user/user_provider.dart';
import '../../../../repository/product_repository.dart';
import '../../../../utils/taapdeel_share_links.dart';
import '../../../../viewobject/common/ps_value_holder.dart';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/api/ps_api_service.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/ui/common/dialog/choose_payment_type_dialog.dart';
import 'package:taapdeel/ui/common/dialog/confirm_dialog_view.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/item/entry/item_entry_view.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/holder/mark_sold_out_item_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/user_delete_item_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../viewobject/message.dart';
import '../../../../viewobject/owner_relation.dart';
import '../../../offer/add_swap_offer/AddSwapOfferScreen.dart';

class CallAndChatButtonWidget extends StatefulWidget {
  const CallAndChatButtonWidget({
    Key? key,
    required this.provider,
    required this.favouriteItemRepo,
    required this.psValueHolder,
  }) : super(key: key);

  final ItemDetailProvider provider;
  final ProductRepository? favouriteItemRepo;
  final PsValueHolder? psValueHolder;

  @override
  _CallAndChatButtonWidgetState createState() =>
      _CallAndChatButtonWidgetState();
}

class _CallAndChatButtonWidgetState extends State<CallAndChatButtonWidget>
    with SingleTickerProviderStateMixin {
  FavouriteItemProvider? favouriteProvider;
  Widget? icon;
  FirebaseApp? firebaseApp;
  UserProvider? userProvider;

  bool isLoading = false;

  Future<PsResource<OwnerRelation>>? _ownerRelationFuture;
  String _ownerRelationFutureKey = '';

  late final AnimationController _itemEntryAnimationController;

  @override
  void initState() {
    super.initState();
    _itemEntryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _itemEntryAnimationController.dispose();
    super.dispose();
  }

  bool get _canShowCallButton {
    final user = widget.provider.itemDetail.data?.user;
    return user?.userPhone != null &&
        user!.userPhone!.isNotEmpty &&
        user.isShowPhone == '1';
  }

  bool _isGuestUserId(String userId) {
    final String id = userId.trim();
    return id.isEmpty || id == 'nologinuser';
  }

  String _currentLoginUserId() {
    final String direct = (widget.psValueHolder?.loginUserId ?? '').trim();
    if (direct.isNotEmpty) return direct;

    try {
      return (Provider.of<PsValueHolder>(context, listen: false).loginUserId ?? '')
          .trim();
    } catch (_) {
      return '';
    }
  }

  String _normalizePhoneForWhatsApp(String rawPhone) {
    String phone = rawPhone.trim();
    if (phone.isEmpty) return '';

    const Map<String, String> arabicDigits = <String, String>{
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

    arabicDigits.forEach((String from, String to) {
      phone = phone.replaceAll(from, to);
    });

    phone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    if (phone.startsWith('00')) {
      phone = phone.substring(2);
    }

    // أغلب أرقام التطبيق مصرية. واتساب يحتاج كود الدولة بدل الصفر المحلي.
    if (phone.startsWith('0') && phone.length >= 10) {
      phone = '20${phone.substring(1)}';
    }

    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _hasWhatsAppPhone(Product? product) {
    final String phone = _normalizePhoneForWhatsApp(
      product?.user?.userPhone ?? '',
    );
    return phone.isNotEmpty;
  }

  Future<PsResource<OwnerRelation>>? _relationFutureForProduct(Product? product) {
    final String viewerId = _currentLoginUserId();
    final String ownerId = (product?.addedUserId ?? '').trim();

    if (_isGuestUserId(viewerId) || ownerId.isEmpty || viewerId == ownerId) {
      _ownerRelationFutureKey = '';
      _ownerRelationFuture = null;
      return null;
    }

    final String nextKey = '$viewerId|$ownerId';
    if (_ownerRelationFutureKey != nextKey) {
      _ownerRelationFutureKey = nextKey;
      _ownerRelationFuture = PsApiService().getOwnerRelation(
        viewerId: viewerId,
        ownerId: ownerId,
      );
    }

    return _ownerRelationFuture;
  }

  String _extractRelationText(OwnerRelation rel) {
    try {
      final dynamic d = rel;
      return (d.relationText ??
          d.relation_text ??
          d.relationTextLabel ??
          d.relation ??
          d.text ??
          '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  int _extractRelationType(OwnerRelation rel) {
    try {
      final int directType = rel.viewerToOwnerType ?? 0;
      if (directType >= 1 && directType <= 6) {
        return directType;
      }

      final String txt = _extractRelationText(rel).trim();

      if (txt.contains('صديق')) return 1;
      if (txt.contains('زوج') || txt.contains('زوجة')) return 2;
      if (txt.contains('ابنك') ||
          txt.contains('ابنتك') ||
          txt.contains('بنتك')) {
        return 3;
      }
      if (txt.contains('أبوك') ||
          txt.contains('أمك') ||
          txt.contains('والد') ||
          txt.contains('والدتك') ||
          txt.contains('والدك')) {
        return 4;
      }
      if (txt.contains('أخ') || txt.contains('أخت')) return 5;
      if (txt.contains('قريب')) return 6;

      return 0;
    } catch (_) {
      return 0;
    }
  }

  bool _hasOwnerRelation(OwnerRelation rel) {
    final int relationType = _extractRelationType(rel);
    if (relationType >= 1 && relationType <= 6) {
      return true;
    }

    final String relationText = _extractRelationText(rel);
    if (relationText.isEmpty) return false;

    final String compactText = relationText.replaceAll(RegExp(r'\s+'), '');
    if (compactText.contains('لاتوجد') ||
        compactText.contains('لايوجد') ||
        compactText.contains('بدونعلاقة') ||
        compactText.contains('غيرمرتبط')) {
      return false;
    }

    return true;
  }

  bool _canShowWhatsAppButton({
    required Product? product,
    required AsyncSnapshot<PsResource<OwnerRelation>> snapshot,
  }) {
    if (!_hasWhatsAppPhone(product)) return false;

    final PsResource<OwnerRelation>? res = snapshot.data;
    if (res == null || res.status != PsStatus.SUCCESS || res.data == null) {
      return false;
    }

    return _hasOwnerRelation(res.data!);
  }

  Future<void> _handleWhatsAppPressed() async {
    final Product? product = widget.provider.itemDetail.data;
    if (product == null) return;

    final String phone = _normalizePhoneForWhatsApp(
      product.user?.userPhone ?? '',
    );

    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: 'رقم واتساب صاحب المنتج غير متاح');
      return;
    }

    final String title = (product.title ?? '').trim();
    final String link = TaapdeelShareLinks.productOrFallback(
      productId: product.id,
      existingLink: product.dynamicLink,
    );

    final String message = title.isEmpty
        ? 'مرحبًا، شفت منتجك على تطبيق تبديل وحابب أتكلم معاك بخصوص التبديل.\n$link'
        : 'مرحبًا، شفت منتجك "$title" على تطبيق تبديل وحابب أتكلم معاك بخصوص التبديل.\n$link';

    final Uri whatsappAppUri = Uri.parse(
      'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}',
    );
    final Uri whatsappWebUri = Uri.https(
      'wa.me',
      '/$phone',
      <String, String>{'text': message},
    );

    try {
      final bool openedApp = await launchUrl(
        whatsappAppUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedApp) return;
    } catch (_) {}

    try {
      final bool openedWeb = await launchUrl(
        whatsappWebUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedWeb) return;
    } catch (_) {}

    Fluttertoast.showToast(msg: 'تعذر فتح واتساب على هذا الجهاز');
  }

  Widget _buildVisitorActionsRow({required bool showWhatsAppButton}) {
    return Row(
      children: <Widget>[

        Expanded(
          child: _MainActionButton(
            icon: isLoading ? null : Icons.swap_horiz_rounded,
            title: isLoading
                ? 'جارٍ التحميل...'
                : Utils.getString(
              context,
              'make_offer_dialog__make_offer_btn_name',
            ),
            onPressed: isLoading ? null : _handleSwapPressed,
            isPrimary: true,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 10),
        if (showWhatsAppButton) ...[
          _SideActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'محادثة',
            onPressed: _handleWhatsAppPressed,
            width: 120,
            tooltip: 'محادثة واتساب',
          ),

        ],
      ],
    );
  }

  Widget _buildVisitorBottomBarContent() {
    final Product? product = widget.provider.itemDetail.data;
    final Future<PsResource<OwnerRelation>>? relationFuture =
    _relationFutureForProduct(product);

    if (relationFuture == null || !_hasWhatsAppPhone(product)) {
      return _buildVisitorActionsRow(showWhatsAppButton: false);
    }

    return FutureBuilder<PsResource<OwnerRelation>>(
      future: relationFuture,
      builder: (
          BuildContext context,
          AsyncSnapshot<PsResource<OwnerRelation>> snapshot,
          ) {
        return _buildVisitorActionsRow(
          showWhatsAppButton: _canShowWhatsAppButton(
            product: product,
            snapshot: snapshot,
          ),
        );
      },
    );
  }

  Future<void> _openAddProductEntryScreen() async {
    if (!mounted) return;

    final PsValueHolder holder =
    Provider.of<PsValueHolder>(context, listen: false);

    final String loginUserId = (holder.loginUserId ?? '').trim();
    if (loginUserId.isEmpty || loginUserId == 'nologinuser') {
      Navigator.pushNamed(context, RoutePaths.home);
      return;
    }

    await Navigator.of(context, rootNavigator: true).push<dynamic>(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext entryContext) {
          return ItemEntryView(
            animationController: _itemEntryAnimationController,
            flag: PsConst.ADD_NEW_ITEM,
            item: Product(),
            maxImageCount: holder.maxImageCount ?? 5,
            onItemUploaded: (String itemId) {
              if (Navigator.of(entryContext).canPop()) {
                Navigator.of(entryContext).pop(itemId);
              }

              Fluttertoast.showToast(
                msg: 'تم إضافة المنتج بنجاح، يمكنك الرجوع وتقديم عرض التبديل',
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleSwapPressed() async {
    final UserProvider userProvider =
    Provider.of<UserProvider>(context, listen: false);
    final PsValueHolder holder =
    Provider.of<PsValueHolder>(context, listen: false);

    final String? id = userProvider.psValueHolder?.loginUserId;
    final String loginUserId = holder.loginUserId ?? '';

    if (loginUserId.isEmpty) {
      Navigator.pushNamed(
        context,
        RoutePaths.home,
      );
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    await userProvider.getUser(id);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    final dynamic rawSwapBalance = userProvider.user?.data?.swapBalance;
    final int swapBalance =
        int.tryParse(rawSwapBalance?.toString() ?? '0') ?? 0;

    if (swapBalance < 1) {
      Navigator.push<Widget>(
        context,
        MaterialPageRoute(
          builder: (context) => PackagesScreen(
            afterPayment: false,
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (BuildContext sheetContext) {
        return AddSwapOfferScreen(
          args: {
            'productId': widget.provider.itemDetail.data?.id,
            'productPriceType': widget.provider.itemDetail.data?.price,
            'productSellerId': widget.provider.itemDetail.data?.addedUserId,
            'chooseAnotherPro': false,
            'asBottomSheet': true,
            'product': widget.provider.itemDetail.data,
            'onAddProduct': () {
              unawaited(_openAddProductEntryScreen());
            },
          },
        );
      },
    );
  }

  Future<void> _handleCallPressed() async {
    final String phone =
        widget.provider.itemDetail.data?.user?.userPhone?.trim() ?? '';
    if (phone.isEmpty) return;

    final Uri uri = Uri.parse('tel://$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not Call Phone';
    }
  }

  Future<void> _handleSharePressed() async {
    final Product? product = widget.provider.itemDetail.data;
    if (product == null) return;

    final String link = TaapdeelShareLinks.productOrFallback(
      productId: product.id,
      existingLink: product.dynamicLink,
    );

    final String title = (product.title ?? '').trim();
    final String message = title.isEmpty
        ? 'شوف المنتج ده على تبديل'
        : 'شوف المنتج ده على تبديل: $title';

    await Share.share(
      '$message\n\n'
          'لو التطبيق عندك هيفتح المنتج مباشرة، ولو مش عندك هتقدر تشوفه من الرابط:\n'
          '$link',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.provider.itemDetail.data != null) {
      return ChangeNotifierProvider<FavouriteItemProvider?>(
        lazy: false,
        create: (BuildContext context) {
          favouriteProvider = FavouriteItemProvider(
            repo: widget.favouriteItemRepo,
            psValueHolder: widget.psValueHolder,
          );
          return favouriteProvider;
        },
        child: Consumer<FavouriteItemProvider>(
          builder: (BuildContext context, FavouriteItemProvider provider,
              Widget? child) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: _BottomBarShell(
                child: _buildVisitorBottomBarContent(),
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> insertDataToFireBase(
      String id,
      bool isSold,
      bool isUserBought,
      String itemId,
      String message,
      int offerStatus,
      String sendByUserId,
      String sessionId,
      int type,
      ) async {
    final Message messages = Message();
    messages.addedDate = Utils.getTimeStamp();
    messages.id = id;
    messages.isSold = isSold;
    messages.isUserBought = isUserBought;
    messages.itemId = itemId;
    messages.message = message;
    messages.offerStatus = offerStatus;
    messages.sendByUserId = sendByUserId;
    messages.sessionId = sessionId;
    messages.type = type;

    final FirebaseDatabase database = FirebaseDatabase(app: firebaseApp);
    final DatabaseReference messagesRef = database.reference().child('Message');

    final String? newkey = messagesRef.child(sessionId).push().key;
    messages.id = newkey;

    messagesRef
        .child(sessionId)
        .child(newkey ?? '')
        .set(messages.toInsertMap(messages));
  }
}

class EditAndDeleteButtonWidget extends StatelessWidget {
  const EditAndDeleteButtonWidget({
    Key? key,
    required this.provider,
    required this.markSoldOutItemProvider,
    required this.appInfoprovider,
    required this.product,
    required this.markSoldOutItemHolder,
  }) : super(key: key);

  final ItemDetailProvider provider;
  final MarkSoldOutItemProvider markSoldOutItemProvider;
  final AppInfoProvider appInfoprovider;
  final Product? product;
  final MarkSoldOutItemParameterHolder? markSoldOutItemHolder;

  Future<void> _handleDelete(
      BuildContext context,
      PsValueHolder psValueHolder,
      ) async {
    final NavigatorState rootNavigator = Navigator.of(context);
    final String? itemId = provider.itemDetail.data?.id;

    if (itemId == null || itemId.isEmpty) {
      return;
    }

    showDialog<dynamic>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmDialogView(
          description: Utils.getString(dialogContext, 'item_detail__delete_desc'),
          leftButtonText: Utils.getString(dialogContext, 'dialog__cancel'),
          rightButtonText: Utils.getString(dialogContext, 'dialog__ok'),
          onAgreeTap: () async {
            final UserDeleteItemParameterHolder userDeleteItemParameterHolder =
            UserDeleteItemParameterHolder(
              itemId: itemId,
            );

            await PsProgressDialog.showDialog(dialogContext);

            final PsResource<ApiStatus> apiStatus =
            await provider.userDeleteItem(
              userDeleteItemParameterHolder.toMap(),
            );

            PsProgressDialog.dismissDialog();

            if (apiStatus.data?.status == 'success') {
              await provider.deleteLocalProductCacheById(
                itemId,
                psValueHolder.loginUserId,
              );

              Fluttertoast.showToast(
                msg: 'Item Deleted',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.blueGrey,
                textColor: Colors.white,
              );

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }

              if (!rootNavigator.mounted) {
                return;
              }

              rootNavigator.pushReplacementNamed(RoutePaths.home);
            } else {
              Fluttertoast.showToast(
                msg: 'Item is not Deleted',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.blueGrey,
                textColor: Colors.white,
              );
            }
          },
        );
      },
    );
  }

  Future<void> _handleMarkSold(
      BuildContext context,
      PsValueHolder psValueHolder,
      ) async {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmDialogView(
          description: Utils.getString(dialogContext, 'item_detail__sold_out_item'),
          leftButtonText: Utils.getString(
            dialogContext,
            'item_detail__sold_out_dialog_cancel_button',
          ),
          rightButtonText: Utils.getString(
            dialogContext,
            'item_detail__sold_out_dialog_ok_button',
          ),
          onAgreeTap: () async {
            await PsProgressDialog.showDialog(dialogContext);

            await markSoldOutItemProvider.loadmarkSoldOutItem(
              psValueHolder.loginUserId,
              markSoldOutItemHolder,
            );

            PsProgressDialog.dismissDialog();

            if (markSoldOutItemProvider.markSoldOutItem.data != null &&
                provider.itemDetail.data != null) {
              provider.itemDetail.data!.isSoldOut =
                  markSoldOutItemProvider.markSoldOutItem.data!.isSoldOut;
            }

            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
        );
      },
    );
  }

  Future<void> _handlePromote(BuildContext context) async {
    if (appInfoprovider.appInfo.data!.inAppPurchasedEnabled == PsConst.ONE &&
        appInfoprovider.appInfo.data!.payStackEnabled == PsConst.ZERO &&
        appInfoprovider.appInfo.data!.offlineEnabled == PsConst.ZERO) {
      final dynamic returnData = await Navigator.pushNamed(
        context,
        RoutePaths.inAppPurchase,
        arguments: <String, dynamic>{
          'productId': product!.id,
          'appInfo': appInfoprovider.appInfo.data
        },
      );

      if (returnData == true || returnData == null) {
        final String? loginUserId =
        Utils.checkUserLoginId(provider.psValueHolder!);
        provider.loadProduct(product!.id, loginUserId);
      }
    } else if (appInfoprovider.appInfo.data!.inAppPurchasedEnabled ==
        PsConst.ZERO) {
      final dynamic returnData = await Navigator.pushNamed(
        context,
        RoutePaths.itemPromote,
        arguments: product,
      );

      if (returnData == true || returnData == null) {
        final String? loginUserId =
        Utils.checkUserLoginId(provider.psValueHolder!);
        provider.loadProduct(product!.id, loginUserId);
      }
    } else {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ChoosePaymentTypeDialog(
            onInAppPurchaseTap: () async {
              final dynamic returnData = await Navigator.pushNamed(
                context,
                RoutePaths.inAppPurchase,
                arguments: <String, dynamic>{
                  'productId': product!.id,
                  'appInfo': appInfoprovider.appInfo.data
                },
              );
              if (returnData == true || returnData == null) {
                final String? loginUserId =
                Utils.checkUserLoginId(provider.psValueHolder!);
                provider.loadProduct(product!.id, loginUserId);
              }
            },
            onOtherPaymentTap: () async {
              final dynamic returnData = await Navigator.pushNamed(
                context,
                RoutePaths.itemPromote,
                arguments: product,
              );
              if (returnData == true || returnData == null) {
                final String? loginUserId =
                Utils.checkUserLoginId(provider.psValueHolder!);
                provider.loadProduct(product!.id, loginUserId);
              }
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final PsValueHolder? psValueHolder = Provider.of<PsValueHolder>(context);

    if (provider.itemDetail.data != null && psValueHolder != null) {
      final bool isSoldOut = provider.itemDetail.data!.isSoldOut == '1';

      final bool canPromote =
          provider.itemDetail.data!.isOwner == PsConst.ONE &&
              provider.itemDetail.data!.status == PsConst.ONE &&
              provider.itemDetail.data!.isSoldOut == PsConst.ZERO &&
              (provider.itemDetail.data!.paidStatus == PsConst.ADSNOTAVAILABLE ||
                  provider.itemDetail.data!.paidStatus == PsConst.ADSFINISHED) &&
              appInfoprovider.appInfo.data != null &&
              !isAllPaymentDisable(appInfoprovider);

      final bool showDeleteOnly = isSoldOut && !canPromote;

      return Align(
        alignment: Alignment.bottomCenter,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: PsDimens.space12),
                _BottomBarShell(
                  backgroundColor: PsColors.backgroundColor,
                  child: showDeleteOnly
                      ? _MainActionButton(
                    icon: Icons.delete_outline_rounded,
                    title: Utils.getString(context, 'item_detail__delete'),
                    onPressed: () => _handleDelete(context, psValueHolder),
                    isPrimary: false,
                  )
                      : _OwnerProductActionsBar(
                    onDelete: () => _handleDelete(context, psValueHolder),
                    markSoldButton: !isSoldOut
                        ? _OwnerActionPill(
                      icon: Icons.check_circle_outline_rounded,
                      title: Utils.getString(
                        context,
                        'item_detail__mark_sold',
                      ),
                      onPressed: () =>
                          _handleMarkSold(context, psValueHolder),
                      isPrimary: false,
                    )
                        : null,
                    /* promoteButton: canPromote
                        ? _OwnerActionPill(
                      icon: Icons.campaign_rounded,
                      title: Utils.getString(
                        context,
                        'item_detail__promte',
                      ),
                      onPressed: () => _handlePromote(context),
                      isPrimary: true,
                    )
                        : null,*/
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class _OwnerProductActionsBar extends StatelessWidget {
  const _OwnerProductActionsBar({
    Key? key,
    required this.onDelete,
    this.markSoldButton,
    this.promoteButton,
  }) : super(key: key);

  final VoidCallback onDelete;
  final Widget? markSoldButton;
  final Widget? promoteButton;

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = <Widget>[
      if (promoteButton != null) promoteButton!,
      if (markSoldButton != null) markSoldButton!,
    ];

    if (actions.isEmpty) {
      return Row(
        children: <Widget>[
          _OwnerDeleteButton(onPressed: onDelete),
        ],
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth;
        final bool useStackedActions = availableWidth < 385 || actions.length > 2;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _OwnerDeleteButton(onPressed: onDelete),
            const SizedBox(width: 10),
            Expanded(
              child: useStackedActions
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: actions
                    .map(
                      (Widget action) => Padding(
                    padding: EdgeInsets.only(
                      bottom: action == actions.last ? 0 : 8,
                    ),
                    child: action,
                  ),
                )
                    .toList(),
              )
                  : Row(
                children: actions
                    .map(
                      (Widget action) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: action == actions.first ? 0 : 10,
                      ),
                      child: action,
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OwnerActionPill extends StatelessWidget {
  const _OwnerActionPill({
    Key? key,
    required this.icon,
    required this.title,
    required this.onPressed,
    required this.isPrimary,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return TaapdeelButton(
      label: title,
      onPressed: onPressed,
      isPrimary: isPrimary,
      outlined: !isPrimary,
      isExpanded: true,
      height: 48,
      icon: Icon(
        icon,
        size: 17,
        color: isPrimary ? Colors.white : const Color(0xFF102E5C),
      ),
    );
  }
}

class _OwnerDeleteButton extends StatelessWidget {
  const _OwnerDeleteButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: const Color(0x220FA3A6),
          side: const BorderSide(
            color: const Color(0x220FA3A6),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Icon(
          Icons.delete_forever,
          size: 25,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _BottomBarShell extends StatelessWidget {
  const _BottomBarShell({
    Key? key,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? PsColors.baseColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.96),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        border: Border.all(
          color: const Color(0x220FA3A6),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  const _MainActionButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
  }) : super(key: key);

  final String title;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return TaapdeelButton(
      label: title,
      onPressed: onPressed,
      isPrimary: isPrimary,
      isExpanded: true,
      height: 50,
      outlined: !isPrimary,
      icon: isLoading
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : (icon != null
          ? Icon(
        icon,
        size: 18,
        color: isPrimary ? Colors.white : const Color(0xFF102E5C),
      )
          : null),
    );
  }
}

class _SideActionButton extends StatelessWidget {
  const _SideActionButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.label = '',
    this.isPrimary = false,
    this.width = 120,
    this.tooltip,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onPressed;
  final String label;
  final bool isPrimary;
  final double width;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final String effectiveLabel = label.trim();

    final Widget button = Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        width: width,
        height: 42,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0xFFFFFFFF),
                border: Border.all(
                  color: const Color(0xFF22C55E),
                  width: 1.2,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x1A22C55E),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 23,
                    height: 23,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                  if (effectiveLabel.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        effectiveLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF166534),
                          fontWeight: FontWeight.w900,
                          fontSize: 11.6,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return button;
    }

    return Tooltip(
      message: tooltip!,
      child: button,
    );
  }
}