import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/provider/product/product_provider.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/ui/Product/product_widget.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/Foryou/widgets/swap_rating.dart';
import 'package:taapdeel/ui/offer/item/check_swap_item.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../constant/ps_constants.dart';
import '../../../provider/SwapProductsProvider.dart';
import '../../../utils/utils.dart';
import '../../../viewobject/chat_history.dart';
import '../../../viewobject/holder/make_offer_parameter_holder.dart';
import '../../../viewobject/holder/sync_chat_history_parameter_holder.dart';

class AddSwapOfferScreen extends StatefulWidget {
  const AddSwapOfferScreen({Key? key, required this.args}) : super(key: key);

  final Map? args;

  @override
  State<AddSwapOfferScreen> createState() => _AddSwapOfferScreenState();
}

class _AddSwapOfferScreenState extends State<AddSwapOfferScreen> {
  String? productId;
  String? productPriceType;
  String? productLowPriceType;
  String? productSellerId;
  bool chooseAnotherPro = false;
  bool asBottomSheet = true;

  int checkedItemIndex = 0;
  bool isSubmitting = false;
  ChatHistory? request;
  bool isLoading = false;
  bool _didLoad = false;

  late final PageController _pageController;

  List<Product> _swapProducts = <Product>[];
  List<Product>? _preloadedSwapProducts;
  Product? _selectedSwapProduct;
  List<Product>? _swapLowRangeProducts;
  List<Product> _higherRangeSwapProducts = <Product>[];
  int _selectedOfferTabIndex = 0;

  ItemDetailProvider? _primaryItemProvider;
  Product? _primaryProduct;
  bool _isPrimaryLoading = false;

  static const double _primaryCardWidth = 160;
  static const double _primaryCardHeight = 240;
  static const double _carouselCardHeight = 240;
  static const double _selectedCardWidth = 250;
  static const double _sideCardWidth = 150;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.50);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Product> get _allSwapProducts {
    final bool hasScoredGroups =
        (productId ?? '').trim().isNotEmpty || _higherRangeSwapProducts.isNotEmpty;

    if (hasScoredGroups) {
      return _selectedOfferTabIndex == 1 ? _higherRangeSwapProducts : _swapProducts;
    }

    final List<Product> out = <Product>[];
    out.addAll(_swapProducts);

    if (_swapLowRangeProducts != null) {
      out.addAll(_swapLowRangeProducts!);
    }

    return out;
  }

  bool _isLowRangeIndex(int index) {
    final bool hasScoredGroups =
        (productId ?? '').trim().isNotEmpty || _higherRangeSwapProducts.isNotEmpty;

    return !hasScoredGroups &&
        chooseAnotherPro &&
        index >= _swapProducts.length &&
        (_swapLowRangeProducts?.isNotEmpty ?? false);
  }

  bool get _showOfferTabs =>
      (productId ?? '').trim().isNotEmpty &&
          (_swapProducts.isNotEmpty || _higherRangeSwapProducts.isNotEmpty);

  bool get _hasSameRangeOffers => _swapProducts.isNotEmpty;

  bool get _hasHigherRangeOffers => _higherRangeSwapProducts.isNotEmpty;

  bool get _hasAnyAvailableSwapProduct =>
      _swapProducts.isNotEmpty ||
          _higherRangeSwapProducts.isNotEmpty ||
          (_swapLowRangeProducts?.isNotEmpty ?? false);

  bool get _showAddProductEmptyState =>
      !isLoading && !_hasAnyAvailableSwapProduct;

  Future<void> _openAddProductAction() async {
    final dynamic onAddProduct = widget.args?['onAddProduct'];

    final Map<String, dynamic> result = <String, dynamic>{
      'action': 'add_product',
      'reason': 'no_same_price_range_products',
    };

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    } else {
      Navigator.of(context, rootNavigator: true).pop(result);
    }

    if (onAddProduct is VoidCallback) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      onAddProduct();
    }
  }

  Widget _buildNoSwapProductsState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFC),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFD9EEF3),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0C587A).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: <Color>[
                  Color(0xFF0C587A),
                  Color(0xFF24A9C4),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF0C587A).withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_box_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا يوجد منتج مناسب بنفس متوسط السعر',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF102E5C),
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'منتجاتك الحالية ليست قريبة من سعر المنتج المطلوب. أضف منتجًا آخر بقيمة مناسبة عشان تقدر تقدم عرض تبديل أقوى.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7A90),
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          TaapdeelButton(
            label: 'أضف منتج جديد',
            onPressed: _openAddProductAction,
            isPrimary: true,
            isExpanded: true,
            outlined: false,
            height: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'بعد إضافة المنتج ارجع وقدم عرض التبديل',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: PsColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }


  String _productScorePercent(Product product) {
    try {
      final dynamic d = product;
      return (d.swapScorePercent ?? '').toString().trim();
    } catch (_) {
      return '';
    }
  }

  String _productScoreLabel(Product product) {
    try {
      final dynamic d = product;
      return (d.swapLabel ?? '').toString().trim();
    } catch (_) {
      return '';
    }
  }

  List<String> _productReasons(Product product) {
    final List<String> out = <String>[];

    try {
      final dynamic d = product;
      final dynamic raw = d.swapScoreBreakdown;

      if (raw is List) {
        for (final dynamic item in raw) {
          if (item is Map) {
            final int points = int.tryParse((item['points'] ?? '0').toString()) ?? 0;
            if (points <= 0) continue;

            final String why = (item['why'] ?? '').toString().trim();
            final String title = (item['title'] ?? '').toString().trim();
            final String value = why.isNotEmpty ? why : title;

            if (value.isNotEmpty && !out.contains(value)) {
              out.add(value);
            }
          }
        }
      }
    } catch (_) {}

    return out.take(6).toList();
  }

  Future<void> getSwapProducts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final String? loginUserId = PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__USER_ID);

    if ((productId ?? '').trim().isNotEmpty) {
      final SwapOfferCandidateItemsResult result =
      await Provider.of<SwapProductsProvider>(
        context,
        listen: false,
      ).getSwapOfferCandidateItems(
        targetItemId: productId!.trim(),
        addedUserId: (loginUserId ?? '').trim(),
      );

      _swapProducts = result.sameRange;
      _higherRangeSwapProducts = result.higherRange;

      if (_swapProducts.isEmpty && _higherRangeSwapProducts.isNotEmpty) {
        _selectedOfferTabIndex = 1;
      } else {
        _selectedOfferTabIndex = 0;
      }
    } else {
      final String targetUserId =
      chooseAnotherPro ? (request?.buyerUserId ?? '') : (loginUserId ?? '');

      _swapProducts = await Provider.of<SwapProductsProvider>(
        context,
        listen: false,
      ).getSwapProducts(productPriceType, targetUserId);
      _higherRangeSwapProducts = <Product>[];
      _selectedOfferTabIndex = 0;
    }

    final List<Product> visibleProducts = _allSwapProducts;
    if (visibleProducts.isNotEmpty) {
      checkedItemIndex = 0;
      _selectedSwapProduct = visibleProducts[0];
      log(_selectedSwapProduct!.title ?? '');
      log(_selectedSwapProduct!.id ?? '');
    } else {
      checkedItemIndex = 0;
      _selectedSwapProduct = null;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getSwapLowRangeProducts() async {
    if (!chooseAnotherPro ||
        request == null ||
        (request!.buyerUserId?.isEmpty ?? true)) {
      _swapLowRangeProducts = <Product>[];
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    _swapLowRangeProducts = await Provider.of<SwapProductsProvider>(
      context,
      listen: false,
    ).getSwapLowRangeProducts(productPriceType, request!.buyerUserId!);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPrimaryProduct() async {
    if ((productId ?? '').trim().isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _isPrimaryLoading = true;
      });
    }

    try {
      final ProductRepository productRepo =
      Provider.of<ProductRepository>(context, listen: false);

      final PsValueHolder psValueHolder =
      Provider.of<PsValueHolder>(context, listen: false);

      _primaryItemProvider = ItemDetailProvider(
        repo: productRepo,
        psValueHolder: psValueHolder,
      );

      final String? loginUserId = Utils.checkUserLoginId(psValueHolder);

      await _primaryItemProvider!.loadProduct(productId, loginUserId);
      _primaryProduct = _primaryItemProvider!.itemDetail.data;
    } catch (e) {
      log('_loadPrimaryProduct error: $e');
    }

    if (mounted) {
      setState(() {
        _isPrimaryLoading = false;
      });
    }
  }

  Future<void> _loadDataOnce() async {
    if (_didLoad) return;
    _didLoad = true;

    final bool shouldUseScoredCandidateApi =
        (productId ?? '').trim().isNotEmpty;


    if (shouldUseScoredCandidateApi) {
      // Always use the scored endpoint when we know the target item.
      // Preloaded products may come from the old price-range endpoint and will not contain score breakdown.
      await getSwapProducts();
    } else if (_preloadedSwapProducts != null) {
      _swapProducts = _preloadedSwapProducts!;

      if (_swapProducts.isNotEmpty) {
        checkedItemIndex = 0;
        _selectedSwapProduct = _swapProducts[0];
      }
    } else {
      await getSwapProducts();
    }

    if (!asBottomSheet) {
      await _loadPrimaryProduct();
    }

    if (!shouldUseScoredCandidateApi &&
        chooseAnotherPro &&
        request != null &&
        (request!.buyerUserId?.isNotEmpty ?? false)) {
      await getSwapLowRangeProducts();
    }

    if (mounted && _allSwapProducts.isNotEmpty) {
      checkedItemIndex = checkedItemIndex.clamp(0, _allSwapProducts.length - 1);
      _selectedSwapProduct = _allSwapProducts[checkedItemIndex];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(checkedItemIndex);
        }
      });

      setState(() {});
    }
  }

  Future<void> _rejectRequest() async {
    if (mounted) {
      setState(() {
        isSubmitting = true;
      });
    }

    final ChatHistory? modelRequest = request;
    if (modelRequest == null) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
      return;
    }

    final MakeOfferParameterHolder requestBody = MakeOfferParameterHolder(
      itemId: modelRequest.item?.id,
      buyerUserId: modelRequest.buyerUserId,
      sellerUserId: modelRequest.sellerUserId,
      isUserOnline: '0',
      buyerItemId: modelRequest.buyerItem?.id,
      negoPrice: '0',
      type: PsConst.CHAT_TO_BUYER,
    );

    final String s =
    await Provider.of<SwapProductsProvider>(context, listen: false)
        .rejectOffer(requestBody.toMap());

    if (s == 'success') {
      await _submitSwap();
      return;
    }

    if (mounted) {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _submitSwap() async {
    if (_selectedSwapProduct == null) return;

    if (mounted) {
      setState(() {
        isSubmitting = true;
      });
    }

    final Product selectedProduct = _selectedSwapProduct!;

    final String? loginUserId = PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__USER_ID);

    final SyncChatHistoryParameterHolder syncChatHistoryParameterHolder =
    SyncChatHistoryParameterHolder(
      itemId: chooseAnotherPro ? selectedProduct.id : productId,
      buyerUserId: chooseAnotherPro ? productSellerId : loginUserId,
      sellerUserId:
      !chooseAnotherPro ? productSellerId : selectedProduct.addedUserId,
      type: chooseAnotherPro ? PsConst.CHAT_TO_BUYER : PsConst.CHAT_TO_SELLER,
      isUserOnline: '0',
      buyerItemId: !chooseAnotherPro ? selectedProduct.id : productId,
      message: '',
    );

    final String response =
    await Provider.of<SwapProductsProvider>(context, listen: false)
        .addPriceOffer(syncChatHistoryParameterHolder.toMap());

    if (response == 'success') {
      Fluttertoast.showToast(msg: 'Swap request sent successfully');

      Provider.of<SwapProductsProvider>(context, listen: false)
          .decrementSwapBalance((loginUserId ?? '').toString());

      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      Fluttertoast.showToast(
        msg: '!!Not Applicable \nSame Product Requested Before',
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }

    if (mounted) {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    productId = widget.args?['productId'];
    productPriceType = widget.args?['productPriceType'];
    productLowPriceType = widget.args?['productLowPriceType'];
    productSellerId = widget.args?['productSellerId'];
    chooseAnotherPro = widget.args?['chooseAnotherPro'] == true;
    request = widget.args?['chatModel'];

    asBottomSheet = widget.args?['asBottomSheet'] != false;

    final dynamic preloaded = widget.args?['preloadedSwapProducts'];
    if (preloaded is List<Product>) {
      _preloadedSwapProducts = preloaded;
    }

    _loadDataOnce();
  }

  void _selectIndex(int index) {
    final List<Product> products = _allSwapProducts;
    if (index < 0 || index >= products.length) return;

    setState(() {
      checkedItemIndex = index;
      _selectedSwapProduct = products[index];
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  dynamic _primarySource() {
    if (_primaryProduct != null) {
      return _primaryProduct;
    }

    final dynamic fromArgsProduct = widget.args?['product'];
    if (fromArgsProduct != null) return fromArgsProduct;

    final dynamic fromArgsItem = widget.args?['item'];
    if (fromArgsItem != null) return fromArgsItem;

    final dynamic fromChat = request?.item;
    if (fromChat != null) return fromChat;

    return null;
  }

  Widget _buildSectionTitle(
      String title, {
        String? trailingText,
        Widget? leading,
      }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Color(0xFFB9EDF5),
            Color(0xFF62C6DB),
            Color(0xFF0D8EB5),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x220C95B9),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          if (trailingText != null && trailingText.isNotEmpty) ...<Widget>[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.30),
                ),
              ),
              child: Text(
                trailingText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrimaryLoadingCard() {
    return SizedBox(
      width: _primaryCardWidth,
      height: _primaryCardHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF60A5FA).withOpacity(0.45),
                width: 4,
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: Color(0xFF19A3B8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryProductPreview() {
    if (_isPrimaryLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildSectionTitle('المنتج المراد استبداله'),
          const SizedBox(height: 12),
          Center(child: _buildPrimaryLoadingCard()),
        ],
      );
    }

    final dynamic source = _primarySource();
    final Product? product = source is Product ? source : _primaryProduct;

    if (product == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildSectionTitle('المنتج المراد استبداله'),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: _primaryCardWidth,
            height: _primaryCardHeight,
            child: TaapdeelProductCardItem(
              coreTagKey: 'swap_primary_${product.id ?? "primary"}_',
              product: product,
              onTap: () {},
              variant: TaapdeelProductCardVariant.family,
              showRotatingBanner: true,
              showRelationPanel: true,
              showConditionChip: true,
              onTapFav: null,
              selectedFav: false,
              cardWidth: double.infinity,
              cardHeight: 214,
              outerMargin: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapLogo() {
    return const SizedBox(
      width: 40,
      height: 40,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Image(
          image: AssetImage('assets/images/Taapdeel_icon.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  void _changeOfferTab(int index) {
    if (_selectedOfferTabIndex == index) return;

    final List<Product> nextList = index == 1 ? _higherRangeSwapProducts : _swapProducts;

    setState(() {
      _selectedOfferTabIndex = index;
      checkedItemIndex = 0;
      _selectedSwapProduct = nextList.isNotEmpty ? nextList[0] : null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  Widget _buildOfferTabs() {
    if (!_showOfferTabs) return const SizedBox.shrink();

    final List<Widget> chips = <Widget>[];

    if (_hasSameRangeOffers) {
      chips.add(
        Expanded(
          child: _buildOfferTabChip(
            index: 0,
            label: 'منتجات بنفس متوسط السعر',
            count: _swapProducts.length,
          ),
        ),
      );
    }

    if (_hasHigherRangeOffers) {
      if (chips.isNotEmpty) {
        chips.add(const SizedBox(width: 6));
      }

      chips.add(
        Expanded(
          child: _buildOfferTabChip(
            index: 1,
            label: 'منتجات بقيمة اعلي',
            count: _higherRangeSwapProducts.length,
          ),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    // لو عندنا مجموعة واحدة فقط، نخفي شكل التابات بالكامل عشان لا يظهر تاب وحيد بلا معنى.
    // الشرط الأهم هنا: لو مفيش منتجات أعلى، تاب "قيمة أعلى" لن يظهر نهائيًا.
    if (chips.length == 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8EFF4)),
      ),
      child: Row(children: chips),
    );
  }

  Widget _buildOfferTabChip({
    required int index,
    required String label,
    required int count,
  }) {
    final bool selected = _selectedOfferTabIndex == index;
    final bool disabled = count == 0;

    return IgnorePointer(
      ignoring: disabled,
      child: Opacity(
        opacity: disabled ? 0.45 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => _changeOfferTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                colors: <Color>[
                  Color(0xFF063B63),
                  Color(0xFF11A4B8),
                ],
              )
                  : null,
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? Colors.transparent : const Color(0xFFD7EAF0),
              ),
              boxShadow: selected
                  ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF0C587A).withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white : const Color(0xFF143B5B),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(0.20)
                        : const Color(0xFFEAF7FA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white : const Color(0xFF0C587A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildReasonsHorizontalRow(List<SwapCriterionItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 34,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: false,
        physics: const BouncingScrollPhysics(),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(items.length, (int index) {
            final SwapCriterionItem item = items[index];

            return Padding(
              padding: EdgeInsetsDirectional.only(
                start: index == 0 ? 0 : 7,
              ),
              child: _buildReasonPill(item),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildReasonPill(SwapCriterionItem item) {
    final bool isWarning = item.isWarning;

    final Color bg =
    isWarning ? const Color(0xFFFFF1F1) : const Color(0xFFEAF8FB);
    final Color border =
    isWarning ? const Color(0xFFF2C7C7) : const Color(0xFFBFEAF0);
    final Color text =
    isWarning ? const Color(0xFF9E3A3A) : const Color(0xFF17425E);
    final Color icon =
    isWarning ? const Color(0xFFD65A5A) : const Color(0xFF149EB7);

    return Container(
      height: 30,
      padding: const EdgeInsetsDirectional.only(
        start: 9,
        end: 10,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0C587A).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Icon(
            item.icon,
            size: 13,
            color: icon,
          ),
          const SizedBox(width: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: text,
              fontWeight: FontWeight.w900,
              fontSize: 10.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  int _productScorePercentInt(Product product) {
    final String raw = _productScorePercent(product).replaceAll('%', '').trim();
    return int.tryParse(raw) ?? 0;
  }

  int _breakdownPoints(Map<String, dynamic> item) {
    final dynamic raw = item['points'];
    if (raw is int) return raw;
    return int.tryParse((raw ?? '0').toString()) ?? 0;
  }

  String _breakdownText(Map<String, dynamic> item, String key) {
    return (item[key] ?? '').toString().trim();
  }

  IconData _iconForBreakdownKey(String key) {
    switch (key) {
      case 'condition':
        return Icons.verified_rounded;
      case 'location':
        return Icons.place_rounded;
      case 'relation':
        return Icons.hub_rounded;
      case 'item_type':
        return Icons.schedule_rounded;
      case 'brand':
        return Icons.local_offer_rounded;
      case 'business_mode':
        return Icons.public_rounded;
      case 'interest_match':
        return Icons.favorite_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  bool _isWarningBreakdownItem(String key, int points, String label) {
    if (key == 'location') {
      return points <= 0 || label.contains('مختلف');
    }

    if (key == 'interest_match') {
      return points <= 0 || label.contains('ليس');
    }

    return false;
  }

  String _normalizedOfferReasonLabel(Map<String, dynamic> item) {
    final String key = _breakdownText(item, 'key').toLowerCase();
    final int points = _breakdownPoints(item);
    String why = _breakdownText(item, 'why');

    // هذه الشاشة تعرض منتجاتي أنا كعروض على منتج شخص آخر، لذلك يجب أن تكون النصوص من منظور صاحب المنتج الآخر.
    if (key == 'interest_match') {
      final String matchType = _breakdownText(item, 'match_type').toLowerCase();

      if (points > 0 || (matchType.isNotEmpty && matchType != 'none')) {
        if (why.isEmpty || why.contains('اهتماماتك') || why.contains('الفئات المفضلة لك')) {
          if (matchType == 'family') {
            final String ownerRelation = _breakdownText(item, 'owner_relation_label');
            final String ownerName = _breakdownText(item, 'owner_name');
            final String who = ownerRelation.isNotEmpty ? ownerRelation : 'عائلة صاحب المنتج';
            why = ownerName.isNotEmpty ? 'من اهتمامات $who - $ownerName' : 'من اهتمامات $who';
          } else {
            why = 'من اهتمامات صاحب المنتج';
          }
        }
      } else {
        why = 'ليس من اهتمامات صاحب المنتج';
      }
    }

    if (key == 'relation') {
      // لا نستخدم نصوص swap_rating العامة مثل "من أقاربك" لأنها من منظور المستخدم الحالي.
      if (why.isEmpty || why.contains('أقاربك') || why.contains('عائلتك')) {
        why = 'علاقة موثوقة مع صاحب المنتج';
      }
    }

    if (key == 'location') {
      // الموقع يجب أن يأتي من الباك إند لأنه محسوب بين المنتج المطلوب ومنتج العرض.
      if (why.isEmpty) {
        why = points > 0 ? 'نفس المحافظة' : 'محافظة مختلفة';
      }
    }

    return why;
  }

  bool _shouldShowOfferReason(String key, int points, String label) {
    if (label.isEmpty) return false;

    // لا نعرض نقاطًا صفرية غير مفيدة، باستثناء الاهتمامات والموقع لأنها تشرح سبب قوة/ضعف العرض.
    if (points <= 0 && key != 'interest_match' && key != 'location') {
      return false;
    }

    if (key == 'business_mode' && points <= 0) {
      return false;
    }

    return true;
  }

  List<SwapCriterionItem> _buildOfferCriteriaFromBackend(Product product) {
    final List<Map<String, dynamic>> breakdown = castSwapBreakdown(product.swapScoreBreakdown);
    final List<SwapCriterionItem> items = <SwapCriterionItem>[];
    final Set<String> seen = <String>{};

    const List<String> preferredOrder = <String>[
      'interest_match',
      'location',
      'condition',
      'relation',
      'item_type',
      'brand',
      'business_mode',
    ];

    for (final String wantedKey in preferredOrder) {
      for (final Map<String, dynamic> rawItem in breakdown) {
        final String key = _breakdownText(rawItem, 'key').toLowerCase();
        if (key != wantedKey) continue;

        final int points = _breakdownPoints(rawItem);
        final String label = _normalizedOfferReasonLabel(rawItem);
        if (!_shouldShowOfferReason(key, points, label)) continue;
        if (seen.contains(label)) continue;

        seen.add(label);
        items.add(
          SwapCriterionItem(
            icon: _iconForBreakdownKey(key),
            label: label,
            enabled: true,
            isWarning: _isWarningBreakdownItem(key, points, label),
          ),
        );
      }
    }

    return items;
  }

  Widget _buildSelectedScoreStrip(Product product) {
    final int percent = _productScorePercentInt(product);
    final String label = _productScoreLabel(product);

    final InlineSwapVM vm = buildInlineSwapVM(
      percent: percent,
      breakdown: castSwapBreakdown(product.swapScoreBreakdown),
    );

    List<SwapCriterionItem> criteria = _buildOfferCriteriaFromBackend(product)
        .where((SwapCriterionItem item) => item.enabled && item.label.trim().isNotEmpty)
        .toList();

    if (criteria.isEmpty && percent > 0) {
      criteria = buildSuggestedSwapFallbackCriteria(vm);
    }

    if (percent <= 0 && label.isEmpty && criteria.isEmpty) {
      return const SizedBox.shrink();
    }

    final String badgeTitle = label.isNotEmpty ? label : vm.badge.title;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9F0F5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0C587A).withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFF063B63),
                      Color(0xFF11A4B8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  percent > 0 ? 'فرصة القبول $percent%' : badgeTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
              if (badgeTitle.isNotEmpty && percent > 0) ...<Widget>[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    badgeTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF123E70),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (criteria.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            _buildReasonsHorizontalRow(
              criteria.take(7).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCarouselSection() {
    final List<Product> list = _allSwapProducts;

    if (isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: SizedBox(
            width: 35,
            height: 35,
            child: CircularProgressIndicator(
              color: Color(0xFF12B7C6),
            ),
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return _buildNoSwapProductsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildSectionTitle(
          asBottomSheet
              ? 'منتجاتك المناسبة للتبديل'
              : 'اختر احدي منتجاتك لطلب التبديل',
          trailingText: '${list.length} منتج',
          leading: _buildSwapLogo(),
        ),
        const SizedBox(height: 10),
        _buildOfferTabs(),
        const SizedBox(height: 12),
        SizedBox(
          height: _carouselCardHeight + 15,
          child: PageView.builder(
            controller: _pageController,
            itemCount: list.length,
            padEnds: true,
            onPageChanged: (int index) {
              setState(() {
                checkedItemIndex = index;
                _selectedSwapProduct = list[index];
              });
            },
            itemBuilder: (BuildContext context, int index) {
              final Product product = list[index];
              final bool isSelected = checkedItemIndex == index;

              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? _selectedCardWidth : _sideCardWidth,
                  height: _carouselCardHeight,
                  margin: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: isSelected ? 0 : 16,
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.90,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: CheckSwapItem(
                      product: product,
                      isChecked: isSelected,
                      isFocused: isSelected,
                      ribbonText: _selectedOfferTabIndex == 1
                          ? 'قيمة أعلى'
                          : (_isLowRangeIndex(index) ? 'أقل' : 'مختار'),
                      onTap: () => _selectIndex(index),
                      onChecked: (_) => _selectIndex(index),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedSwapProduct != null)
          _buildSelectedScoreStrip(_selectedSwapProduct!),
      ],
    );
  }

  Widget _buildBottomAction(bool canSubmit) {
    if (_showAddProductEmptyState) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TaapdeelButton(
              label: 'أضف منتج جديد',
              onPressed: _openAddProductAction,
              isPrimary: true,
              isExpanded: true,
              outlined: false,
              height: 50,
            ),
            const SizedBox(height: 8),
            Text(
              'لا يوجد منتج مناسب بنفس متوسط السعر حاليًا',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PsColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IgnorePointer(
            ignoring: !canSubmit || isSubmitting,
            child: Opacity(
              opacity: (!canSubmit || isSubmitting) ? 0.45 : 1.0,
              child: TaapdeelButton(
                label: isSubmitting
                    ? 'جاري الإرسال...'
                    : Utils.getString(
                  context,
                  !chooseAnotherPro
                      ? 'submit__swap'
                      : 'choose_another_product',
                ),
                onPressed: () {
                  if (!canSubmit) return;

                  if (!chooseAnotherPro) {
                    _submitSwap();
                  } else {
                    _rejectRequest();
                  }
                },
                isPrimary: true,
                isExpanded: true,
                outlined: false,
                height: 50,
              ),
            ),
          ),
          if (!canSubmit)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                asBottomSheet
                    ? 'اختر أحد منتجاتك أولاً'
                    : 'اختر منتجك ومنتج للتبديل أولاً',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PsColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetView() {
    final bool canSubmit = _selectedSwapProduct != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.80,
        minChildSize: 0.55,
        maxChildSize: 0.90,
        expand: false,
        builder: (
            BuildContext context,
            ScrollController scrollController,
            ) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7E3EA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: <Color>[
                              Color(0xFF0C587A),
                              Color(0xFF24A9C4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xFF0C587A).withOpacity(0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'اختر أفضل منتج للتبديل',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF102E5C),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'رتبنا منتجاتك حسب السعر، الاهتمامات، الحالة، الموقع، والعلاقة',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: const Color(0xFF6B7A90),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F7FA),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFFE1EAF0),
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xFF102E5C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: Column(
                      children: <Widget>[
                        _buildCarouselSection(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: _buildBottomAction(canSubmit),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBottomSheetView();
  }
}
