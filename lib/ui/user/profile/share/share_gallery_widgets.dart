part of 'profile_share_gallery.dart';

class _CanvasFrame extends StatelessWidget {
  const _CanvasFrame({required this.width, required this.height, required this.child});
  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        child: Directionality(textDirection: TextDirection.rtl, child: child),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.dark = false, this.compact = false});
  final bool dark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color text = dark ? Colors.white : _ShareGalleryColors.navy;
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        if (!compact) _SwapIcon(size: 30),
        if (!compact) const SizedBox(width: 7),
        RichText(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: 'Taapdee',
                style: TextStyle(
                  fontSize: compact ? 26 : 22,
                  fontWeight: FontWeight.w700,
                  color: text,
                  fontFamily: 'serif',
                ),
              ),
              TextSpan(
                text: 'L',
                style: TextStyle(
                  fontSize: compact ? 26 : 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16B6B6),
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwapIcon extends StatelessWidget {
  const _SwapIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Taapdeel_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }
}

class _ProductImageView extends StatelessWidget {
  const _ProductImageView({required this.image, this.fit = BoxFit.cover});

  final String? image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final String? resolved = ShareGalleryImageResolver.normalize(image);
    if (resolved == null) return const _EmptyImageBox();

    if (ShareGalleryImageResolver.isAssetImagePath(resolved)) {
      return Image.asset(
        resolved,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const _EmptyImageBox(),
      );
    }

    if (ShareGalleryImageResolver.isLocalFilePath(resolved)) {
      return Image.file(
        File(resolved.startsWith('file:/')
            ? Uri.parse(resolved).toFilePath()
            : resolved),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const _EmptyImageBox(),
      );
    }

    return PsNetworkImageWithUrl(
      photoKey: '',
      imagePath: resolved,
      width: double.infinity,
      height: double.infinity,
      imageAspectRation: PsConst.Aspect_Ratio_1x,
      boxfit: fit,
    );
  }
}
class _EmptyImageBox extends StatelessWidget {
  const _EmptyImageBox({this.loading = false});
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFF7FCFE), Color(0xFFEAF8FB)],
        ),
      ),
      child: loading
          ? const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : const SizedBox.expand(),
    );
  }
}

class _MiniProductTile extends StatelessWidget {
  const _MiniProductTile({
    required this.product,
    this.dark = false,
    this.sticker = false,
    this.compact = false,
  });

  final ShareProductViewData product;
  final bool dark;
  final bool sticker;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF061A32) : Colors.white,
        borderRadius: BorderRadius.circular(sticker ? 20 : 16),
        border: Border.all(
          width: sticker ? 3 : 1,
          color: sticker ? Colors.white : (dark ? const Color(0xFF18D9E1) : const Color(0xFFE0EAF0)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dark ? _ShareGalleryColors.aqua.withOpacity(0.22) : Colors.black.withOpacity(0.10),
            blurRadius: sticker ? 10 : 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sticker ? 17 : 15),
        child: Column(
          children: <Widget>[
            Expanded(child: _ProductImageView(image: product.imageUrl)),
            if (product.hasTitle || (!compact && product.hasCategory))
              Padding(
                padding: EdgeInsets.fromLTRB(5, compact ? 3 : 5, 5, compact ? 4 : 6),
                child: Column(
                  children: <Widget>[
                    if (product.hasTitle)
                      Text(
                        product.title!,
                        maxLines: compact ? 1 : 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 9 : 10.5,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: dark ? Colors.white : _ShareGalleryColors.navy,
                        ),
                      ),
                    if (!compact && product.hasCategory) const SizedBox(height: 3),
                    if (!compact && product.hasCategory)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _ShareGalleryColors.aqua.withOpacity(dark ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.category!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            color: dark ? Colors.white : _ShareGalleryColors.teal,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CuteLinePill extends StatelessWidget {
  const _CuteLinePill({required this.text, this.dark = false, this.compact = false});
  final String text;
  final bool dark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String clean = text.trim();
    if (clean.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 5 : 7),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.14) : Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: dark ? Colors.white.withOpacity(0.25) : const Color(0xFFE5EEF5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.auto_awesome_rounded,
            size: compact ? 13 : 15,
            color: dark ? const Color(0xFF7CF3F3) : _ShareGalleryColors.teal,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              clean,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: dark ? Colors.white : _ShareGalleryColors.navy,
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalProducts extends StatelessWidget {
  const _HorizontalProducts({required this.products, this.compact = false});
  final List<ShareProductViewData> products;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Row(
      children: List<Widget>.generate(products.length, (int i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _MiniProductTile(product: products[i], compact: compact),
          ),
        );
      }),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)),
      );
}

class _SmallBenefit extends StatelessWidget {
  const _SmallBenefit({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE7DCCD)),
        color: Colors.white.withOpacity(0.7),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 15, color: const Color(0xFF1AA7A8)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: _ShareGalleryColors.navy, fontWeight: FontWeight.w900, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ResponsiveProductGrid extends StatelessWidget {
  const _ResponsiveProductGrid({required this.products, required this.cardBuilder});
  final List<ShareProductViewData> products;
  final Widget Function(ShareProductViewData product) cardBuilder;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    if (products.length == 1) return Center(child: SizedBox(width: 170, child: cardBuilder(products.first)));
    if (products.length == 2) {
      return Row(children: <Widget>[
        Expanded(child: cardBuilder(products[0])),
        const SizedBox(width: 10),
        Expanded(child: cardBuilder(products[1])),
      ]);
    }

    final List<ShareProductViewData> top = products.take(2).toList(growable: false);
    final List<ShareProductViewData> bottom = products.skip(2).take(3).toList(growable: false);
    return Column(
      children: <Widget>[
        Expanded(
          child: Row(
            children: List<Widget>.generate(top.length, (int i) => Expanded(child: Padding(padding: EdgeInsetsDirectional.only(end: i == top.length - 1 ? 0 : 8), child: cardBuilder(top[i])))),
          ),
        ),
        if (bottom.isNotEmpty) const SizedBox(height: 8),
        if (bottom.isNotEmpty)
          Expanded(
            child: Row(
              children: List<Widget>.generate(bottom.length, (int i) => Expanded(child: Padding(padding: EdgeInsetsDirectional.only(end: i == bottom.length - 1 ? 0 : 8), child: cardBuilder(bottom[i])))),
            ),
          ),
      ],
    );
  }
}

class _GenericProductCard extends StatelessWidget {
  const _GenericProductCard({required this.product, required this.accent, this.dark = false, this.soft = false});
  final ShareProductViewData product;
  final Color accent;
  final bool dark;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF061A32) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: soft ? const Color(0xFFE1D4C2) : accent.withOpacity(0.18)),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(dark ? 0.18 : 0.09), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          children: <Widget>[
            Expanded(child: Padding(padding: const EdgeInsets.all(6), child: ClipRRect(borderRadius: BorderRadius.circular(13), child: _ProductImageView(image: product.imageUrl, fit: BoxFit.cover)))),
            if (product.hasTitle || product.hasCategory)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 7),
                child: Column(
                  children: <Widget>[
                    if (product.hasTitle)
                      Text(product.title!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: dark ? Colors.white : _ShareGalleryColors.navy, fontSize: 10, height: 1.1, fontWeight: FontWeight.w900)),
                    if (product.hasCategory) ...<Widget>[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: accent.withOpacity(dark ? 0.28 : 0.12), borderRadius: BorderRadius.circular(999)),
                        child: Text(product.category!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: dark ? Colors.white : accent, fontSize: 7.2, height: 1, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
