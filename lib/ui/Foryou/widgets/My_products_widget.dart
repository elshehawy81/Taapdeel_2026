import 'package:flutter/material.dart';
import '../../../../../constant/ps_constants.dart';
import '../../../../../constant/route_paths.dart';
import '../../../../../viewobject/chat_history.dart';
import '../../../../../viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import '../../../../../viewobject/product.dart';
import '../../../config/ps_config.dart';
import '../../Product/taapdeel_circular_product_frame.dart';
import '../home_provider.dart';
import '../../wish_Items/Wishlist_model.dart';
import '../../Product/product_widget.dart';

class ProductListWidget extends StatefulWidget {
  const ProductListWidget({
    Key? key,
    this.products,
    this.onTap,
    this.isSuccessSwapped = false,
    this.successSwappedProducts,
    this.myProduct = false,
    this.loading = false,
    this.wishlist = false,
    this.preferred = false,
    this.wishlistProducts,
  }) : super(key: key);

  final List<ChatHistory>? successSwappedProducts;
  final List<Product>? products;
  final List<WishlistProductModel>? wishlistProducts;

  final Function? onTap;
  final bool myProduct;
  final bool wishlist;
  final bool preferred;
  final bool isSuccessSwapped;
  final bool loading;

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  int _selectedItem = 0;

  // ==========================================================
  // ✅ Variant Resolver (Smart Default)
  // ==========================================================
  TaapdeelProductCardVariant _variantForProduct(Product p) {
    if (widget.preferred) return TaapdeelProductCardVariant.deal;
    if (widget.wishlist) return TaapdeelProductCardVariant.friend;
    return TaapdeelProductCardVariant.normal;
  }

  // ==========================================================
  // ✅ Image Provider from Product (Safe)
  // ==========================================================
  ImageProvider _imageProviderFor(Product p) {
    final String? raw = p.defaultPhoto?.imgPath;

    if (raw == null || raw.trim().isEmpty) {
      return const AssetImage('assets/images/img_placeholder.png');
    }

    final String path = raw.trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    final String fullUrl = '${PsConfig.ps_app_image_url}$path';
    return NetworkImage(fullUrl);
  }

  // ==========================================================
  // ✅ Build a single circular card
  // ==========================================================
  Widget _buildCircularCard({
    required Product p,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final double size = widget.preferred ? 90 : 100;

    return SizedBox(
      width: size,
      child: Stack(
        children: [
          TaapdeelCircularProductFrame(
            imageProvider: _imageProviderFor(p),
            title: (p.title ?? '').trim().isNotEmpty ? (p.title ?? '').trim() : 'منتج',
            subtitle: widget.preferred
                ? (p.price != null && p.price!.isNotEmpty ? '${p.price}' : null)
                : null,
            size: size,
            compact: true,
          ),

          // ✅ highlight + check
          if (isSelected)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Color(0xFF2CC2B7),
                ),
              ),
            ),

          // ✅ clickable layer
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ✅ Get the correct product list depending on mode
  // ==========================================================
  List<Product> _resolveProducts() {
    if (widget.wishlist) {

      return widget.products ?? <Product>[];
    }

    if (widget.isSuccessSwapped) {

      return widget.products ?? <Product>[];
    }

    return widget.products ?? <Product>[];
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> list = _resolveProducts();

    if (widget.loading) {
      return SizedBox(
        height: widget.preferred ? 140 : 130,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (list.isEmpty) {
      return SizedBox(
        height: widget.preferred ? 140 : 130,
        child: const SizedBox.shrink(),
      );
    }

    // ✅ sync selection with provider (important)
    final HomeProvider home = HomeProvider.of(context, listen: true);

    String? selectedId;
    if (widget.myProduct) {
      selectedId = home.myProduct?.id;
    } else {
      selectedId = home.selectedSwapProduct?.id;
    }

    return SizedBox(
      height: widget.preferred ? 140 : 130,
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (BuildContext context, int index) =>
        const SizedBox(width: 8),
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          final Product p = list[index];
          final bool isSelected = (p.id != null && selectedId != null && p.id == selectedId);

          return _buildCircularCard(
            p: p,
            isSelected: isSelected,
            onTap: () async {
              // =========================
              // ✅ My Product selection
              // =========================
              if (widget.myProduct) {
                // اختيار منتج المستخدم → تحميل recProducts من provider (مرة واحدة فقط)
                await home.setSelectedMyProduct(p, fetchRecommendations: false);

                // ✅ update local selection index (للـ UI فقط)
                _selectedItem = index;
                setState(() {});
                return;
              }

              // =========================
              // ✅ Swap Product selection
              // =========================
              final bool tappedSame = (_selectedItem == index);

              // tap أول مرة: اختيار
              if (!tappedSame) {
                _selectedItem = index;
                home.setSelectedSwapProduct(p);
                setState(() {});
                return;
              }

              // tap تاني على نفس المنتج: فتح التفاصيل
              if (p.id == null) return;

              final ProductDetailIntentHolder holder = ProductDetailIntentHolder(
                productId: p.id!,
                heroTagImage: p.hashCode.toString() + p.id! + PsConst.HERO_TAG__IMAGE,
                heroTagTitle: p.hashCode.toString() + p.id! + PsConst.HERO_TAG__TITLE,
              );

              Navigator.pushNamed(
                context,
                RoutePaths.productDetail,
                arguments: holder,
              );
            },
          );
        },
      ),
    );
  }
}
