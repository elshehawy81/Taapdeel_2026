import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';

import '../../../viewobject/product.dart';
import '../home_provider.dart';

class MyProductsPickerSection extends StatefulWidget {
  const MyProductsPickerSection({
    Key? key,
    required this.homeProvider,
  }) : super(key: key);

  final HomeProvider homeProvider;

  @override
  State<MyProductsPickerSection> createState() =>
      _MyProductsPickerSectionState();
}

class _MyProductsPickerSectionState extends State<MyProductsPickerSection> {
  bool _selectionEnabled = false;

  static const Color _kPrimary = Color(0xFF0C587A);
  static const Color _kPrimaryDark = Color(0xFF011934);
  static const Color _kAccent = Color(0xFF24A9C4);
  static const Color _kSoftBg = Color(0xFFF4FAFC);
  static const Color _kBorder = Color(0xFFD8EDF3);
  static const Color _kMuted = Color(0xFF607684);
  static const Color _kWarningBg = Color(0xFFFFF6E8);
  static const Color _kWarningText = Color(0xFFB26A00);

  @override
  void didUpdateWidget(covariant MyProductsPickerSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final String? oldId = oldWidget.homeProvider.myProduct?.id;
    final String? newId = widget.homeProvider.myProduct?.id;

    if (!_selectionEnabled && newId != null) {
      setState(() => _selectionEnabled = true);
    }

    if (oldId != newId && newId != null && !_selectionEnabled) {
      setState(() => _selectionEnabled = true);
    }
  }

  ImageProvider _imageProviderFor(Product p) {
    final String? raw = p.defaultPhoto?.imgPath;

    if (raw == null || raw.trim().isEmpty) {
      return const AssetImage('assets/images/img_placeholder.png');
    }

    final String path = raw.trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    return NetworkImage('${PsConfig.ps_app_image_url}$path');
  }

  String _productTitle(Product p) {
    final String title = (p.title ?? '').trim();
    if (title.isNotEmpty) return title;
    return 'منتج بدون اسم';
  }

  int? _parsePositiveInt(String? value) {
    final String v = (value ?? '').trim();
    final int? parsed = int.tryParse(v);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  num _resolveProductValue(Product p) {
    final int? low = _parsePositiveInt(p.lowPrice);
    final int? high = _parsePositiveInt(p.highPrice);
    final int? price = _parsePositiveInt(p.price);

    if (low != null && high != null) return (low + high) / 2;
    if (price != null) return price;
    if (high != null) return high;
    if (low != null) return low;

    return 0;
  }

  num _totalProductsValue(List<Product> products) {
    num total = 0;
    for (final Product product in products) {
      total += _resolveProductValue(product);
    }
    return total;
  }

  String _formatMoneyValue(num value) {
    if (value >= 1000000) {
      final num v = value / 1000000;
      final String text =
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
      return '$text مليون جنيه';
    }

    if (value >= 1000) {
      final num v = value / 1000;
      final String text =
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
      return '$text ألف جنيه';
    }

    return '${value.toStringAsFixed(0)} جنيه';
  }

  String _resolvePriceRange(Product p) {
    final int? low = _parsePositiveInt(p.lowPrice);
    final int? high = _parsePositiveInt(p.highPrice);
    final int? price = _parsePositiveInt(p.price);

    if (low != null && high != null) {
      if (low == high) return '$low جنيه';

      final int minValue = low < high ? low : high;
      final int maxValue = low < high ? high : low;
      return '$minValue - $maxValue جنيه';
    }

    if (low != null) return '$low جنيه';
    if (high != null) return '$high جنيه';
    if (price != null) return '$price جنيه';

    return 'السعر غير محدد';
  }

  String _resolveCondition(Product p) {
    final String value = (p.conditionOfItem?.name ?? '').trim();
    if (value.isEmpty) return 'حالة غير محددة';
    return value;
  }

  bool _isPending(Product p) {
    return (p.status ?? '1').toString().trim() == '0';
  }

  Future<void> _selectProduct(Product product) async {
    if (!_selectionEnabled) {
      setState(() => _selectionEnabled = true);
    }

    await widget.homeProvider.setSelectedMyProduct(
      product,
      fetchRecommendations: true,
    );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final HomeProvider homeProvider = widget.homeProvider;
    final List<Product> list = homeProvider.myProducts;
    final String? selectedMyId = homeProvider.myProduct?.id;
    final String totalProductsValueText =
    _formatMoneyValue(_totalProductsValue(list));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[
              Color(0xFFBFEAF2),
              Color(0xFF74D2E4),
              Color(0xFF24A9C4),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x160C587A),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(1.25),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _CompactPickerHeader(
                title: 'أفضل عروض التبديل',
                count: list.length,
                totalValueText: totalProductsValueText,
              ),
              const SizedBox(height: 20),
              if (homeProvider.myProductLoading)
                const SizedBox(
                  height: 88,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                )
              else if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'مفيش منتجات عندك لعرض فرص التبديل',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PsColors.textColor3,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: false,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final Product product = list[index];
                      final bool isSelected = _selectionEnabled &&
                          selectedMyId != null &&
                          selectedMyId == product.id;
                      final bool isPending = _isPending(product);

                      return _CompactMyProductCard(
                        title: _productTitle(product),
                        image: _imageProviderFor(product),
                        priceLabel: _resolvePriceRange(product),
                        conditionLabel: _resolveCondition(product),
                        isPending: isPending,
                        isSelected: isSelected,
                        onTap: () => _selectProduct(product),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactPickerHeader extends StatelessWidget {
  const _CompactPickerHeader({
    required this.title,
    required this.count,
    required this.totalValueText,
  });

  final String title;
  final int count;
  final String totalValueText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD8EDF3),
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x120C587A),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: <Color>[
                        Color(0xFF072D56),
                        Color(0xFF0D5E7B),
                        Color(0xFF24A9C4),
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر منتجك لعرض ترشيحات التبديل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF072D56),
                    fontWeight: FontWeight.w700,
                    fontSize: 10.3,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: <Color>[
                    Color(0xFFFFFFFF),
                    Color(0xFFEAF8FC),
                    Color(0xFFDDF4FA),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFBFE3EC),
                  width: 1,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x120C587A),
                    blurRadius: 7,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$count منتج - $totalValueText',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF0C587A),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactMyProductCard extends StatelessWidget {
  const _CompactMyProductCard({
    required this.title,
    required this.image,
    required this.priceLabel,
    required this.conditionLabel,
    required this.isPending,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final ImageProvider image;
  final String priceLabel;
  final String conditionLabel;
  final bool isPending;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(18);
    final Color borderColor = isSelected ? const Color(0xFF63CAD6) : Colors.grey;

    final String statusLabel =
    isPending ? 'بانتظار الموافقة للنشر' : conditionLabel;
    final Color statusBg = isPending
        ? _MyProductsPickerSectionState._kWarningBg
        : const Color(0xFFEAF7FA);
    final Color statusText = isPending
        ? _MyProductsPickerSectionState._kWarningText
        : _MyProductsPickerSectionState._kPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: borderColor,
          width: isSelected || isPending ? 1.8 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isSelected
                ? const Color(0x1F24A9C4)
                : isPending
                ? const Color(0x1FF4B23E)
                : const Color(0x09011934),
            blurRadius: isSelected || isPending ? 14 : 7,
            offset: Offset(0, isSelected || isPending ? 6 : 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Row(
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 54,
                        height: 68,
                        child: Image(
                          image: image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xFFEAF6FA),
                              child: const Icon(
                                Icons.image_outlined,
                                color: Color(0xFF8AA6B8),
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (isPending)
                      PositionedDirectional(
                        top: -5,
                        end: -5,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4B23E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      )
                    else if (isSelected)
                      PositionedDirectional(
                        top: -5,
                        end: -5,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: BoxDecoration(
                            color: _MyProductsPickerSectionState._kAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                          _MyProductsPickerSectionState._kPrimaryDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        priceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _MyProductsPickerSectionState._kMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.2,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusText,
                              fontWeight: FontWeight.w900,
                              fontSize: 9.4,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}