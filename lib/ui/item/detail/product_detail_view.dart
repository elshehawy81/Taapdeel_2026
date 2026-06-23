import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/about_us/about_us_provider.dart';
import 'package:taapdeel/provider/app_info/app_info_provider.dart';
import 'package:taapdeel/provider/gallery/gallery_provider.dart';
import 'package:taapdeel/provider/history/history_provider.dart';
import 'package:taapdeel/provider/product/favourite_item_provider.dart';
import 'package:taapdeel/provider/product/mark_sold_out_item_provider.dart';
import 'package:taapdeel/provider/product/product_provider.dart';
import 'package:taapdeel/provider/product/similar_items_by_tags_provider.dart';
import 'package:taapdeel/provider/product/touch_count_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/about_us_repository.dart';
import 'package:taapdeel/repository/app_info_repository.dart';
import 'package:taapdeel/repository/gallery_repository.dart';
import 'package:taapdeel/repository/history_repsitory.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/base/ps_widget_with_multi_provider.dart';
import 'package:taapdeel/ui/common/ps_back_button_with_circle_bg_widget.dart';
import 'package:taapdeel/ui/item/detail/widgets/action_buttons.dart';
import 'package:taapdeel/ui/item/detail/widgets/product_header.dart';
import 'package:taapdeel/ui/item/detail/widgets/seller_info_tile_view.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/default_photo.dart';
import 'package:taapdeel/viewobject/holder/mark_sold_out_item_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/touch_count_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../api/ps_api_service.dart';
import '../../../provider/subcategory/owner_subcat_subscribe_provider.dart';
import '../../../repository/owner_subcat_subscribe_repository.dart';
import '../../../viewobject/product.dart';

// ✅ NEW: Taapdeel Scaffold
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

import '../../Product/product_widget.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({
    required this.productId,
    required this.heroTagImage,
    required this.heroTagTitle,
    this.adminReviewMode = false,
  });

  final String? productId;
  final String? heroTagImage;
  final String? heroTagTitle;
  final bool adminReviewMode;

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetailView>
    with SingleTickerProviderStateMixin {
  ProductRepository? productRepo;
  HistoryRepository? historyRepo;
  HistoryProvider? historyProvider;
  ItemDetailProvider? itemDetailProvider;
  TouchCountProvider? touchCountProvider;
  AppInfoProvider? appInfoProvider;
  GalleryProvider? galleryProvider;
  late GalleryRepository galleryRepository;
  AppInfoRepository? appInfoRepository;
  PsValueHolder? psValueHolder;
  AnimationController? animationController;
  AboutUsRepository? aboutUsRepo;
  AboutUsProvider? aboutUsProvider;
  MarkSoldOutItemProvider? markSoldOutItemProvider;
  MarkSoldOutItemParameterHolder? markSoldOutItemHolder;
  UserProvider? userProvider;
  UserRepository? userRepo;
  FavouriteItemProvider? favouriteProvider;
  bool isReadyToShowAppBarIcons = false;
  bool isAddedToHistory = false;
  bool isHaveVideo = false;
  DefaultPhoto? currentDefaultPhoto;
  DefaultPhoto? _selectedGalleryPhoto;
  String? _selectedGalleryItemId;
  List<DefaultPhoto> _serverGalleryPhotos = <DefaultPhoto>[];
  String? _serverGalleryItemId;
  String? _loadingGalleryItemId;
  int _galleryRequestSerial = 0;
  late final ScrollController _swapChipsController;
  late final ScrollController _galleryThumbsController;


  // تعرض الصورة كاملة أولًا، ثم تعمل Zoom In/Out ناعم للاستفادة من مساحة الهيدر
  // بدون الاعتماد على BoxFit.cover الثابت الذي كان يقص أجزاء مهمة من المنتج.
  static const double _mainGalleryImageMinScale = 1.0;
  static const double _mainGalleryImageMaxScale = 1.58;
  static const double _mainGalleryZoomStartAt = 0.18;
  static const Alignment _mainGalleryImageAlignment = Alignment.center;
  static const Alignment _mainGalleryZoomAlignment = Alignment.topCenter;
  static const BoxFit _mainGalleryForegroundFit = BoxFit.contain;
  static const BoxFit _mainGalleryBackgroundFit = BoxFit.cover;

  // ✅ Similar-by-tags load guard
  String? _loadedSimilarForId;
  bool _similarQueued = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8200),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true);
    _swapChipsController = ScrollController();
    _galleryThumbsController = ScrollController();
  }

  @override
  void dispose() {
    _galleryRequestSerial++;
    animationController?.dispose();
    _swapChipsController.dispose();
    _galleryThumbsController.dispose();
    super.dispose();
  }

  dynamic _safeRead(dynamic Function() getter) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }

  bool _hasPhotoPath(DefaultPhoto? photo) {
    return (photo?.imgPath ?? '').toString().trim().isNotEmpty;
  }

  String _photoKey(DefaultPhoto? photo) {
    final String id = (photo?.imgId ?? '').toString().trim();
    if (id.isNotEmpty) return id;
    return (photo?.imgPath ?? '').toString().trim();
  }

  void _addGalleryPhoto({
    required List<DefaultPhoto> target,
    required Set<String> seen,
    required DefaultPhoto? photo,
  }) {
    if (!_hasPhotoPath(photo)) return;

    final String key = _photoKey(photo);
    if (key.isEmpty || seen.contains(key)) return;

    seen.add(key);
    target.add(photo!);
  }

  void _addDynamicGalleryCandidate({
    required List<DefaultPhoto> target,
    required Set<String> seen,
    required dynamic candidate,
  }) {
    if (candidate == null) return;

    if (candidate is DefaultPhoto) {
      _addGalleryPhoto(target: target, seen: seen, photo: candidate);
      return;
    }

    if (candidate is Iterable) {
      for (final dynamic item in candidate) {
        if (item is DefaultPhoto) {
          _addGalleryPhoto(target: target, seen: seen, photo: item);
        }
      }
    }
  }

  /// يجمع صور المنتج من أكثر من اسم محتمل داخل Product حتى يكون التعديل آمنًا
  /// مع اختلاف أسماء الحقول بين إصدارات الـ model.
  ///
  /// أهم نقطة: لا نعتمد على فتح RoutePaths.galleryGrid لأن الكراش يحدث عند فتحها.
  List<DefaultPhoto> _galleryPhotosForProduct(Product product) {
    final List<DefaultPhoto> photos = <DefaultPhoto>[];
    final Set<String> seen = <String>{};

    final String productId = (product.id ?? '').toString().trim();

    if (_serverGalleryItemId == productId) {
      for (final DefaultPhoto photo in _serverGalleryPhotos) {
        _addGalleryPhoto(
          target: photos,
          seen: seen,
          photo: photo,
        );
      }
    }

    // fallback سريع قبل تحميل صور السيرفر، أو لو السيرفر رجّع قائمة فاضية.
    _addGalleryPhoto(
      target: photos,
      seen: seen,
      photo: product.defaultPhoto,
    );

    final dynamic p = product;
    final List<dynamic> candidates = <dynamic>[
      _safeRead(() => p.photos),
      _safeRead(() => p.photoList),
      _safeRead(() => p.photo_list),
      _safeRead(() => p.images),
      _safeRead(() => p.imageList),
      _safeRead(() => p.image_list),
      _safeRead(() => p.itemImages),
      _safeRead(() => p.item_images),
      _safeRead(() => p.itemImageList),
      _safeRead(() => p.item_image_list),
      _safeRead(() => p.itemPhotoList),
      _safeRead(() => p.item_photo_list),
      _safeRead(() => p.gallery),
      _safeRead(() => p.galleryList),
      _safeRead(() => p.gallery_list),
      _safeRead(() => p.galleryProviderList),
      _safeRead(() => p.allImages),
      _safeRead(() => p.all_images),
    ];

    for (final dynamic candidate in candidates) {
      _addDynamicGalleryCandidate(
        target: photos,
        seen: seen,
        candidate: candidate,
      );
    }

    return photos;
  }

  DefaultPhoto? _resolveCurrentPhoto({
    required Product product,
    required List<DefaultPhoto> photos,
  }) {
    final String itemId = (product.id ?? '').toString().trim();

    if (_selectedGalleryItemId == itemId && _hasPhotoPath(_selectedGalleryPhoto)) {
      return _selectedGalleryPhoto;
    }

    // اعرض صور المنتج الأصلية أولًا.
    // لا نبدأ بـ videoThumbnail لأنه أحيانًا يكون نسخة thumbnail صغيرة أو مقصوصة،
    // وهذا يسبب ظهور المنتج كجزء طولي صغير داخل مساحة الصورة.
    if (photos.isNotEmpty) {
      return photos.first;
    }

    if (_hasPhotoPath(product.defaultPhoto)) {
      return product.defaultPhoto;
    }

    if (_hasPhotoPath(product.videoThumbnail)) {
      return product.videoThumbnail;
    }

    return product.defaultPhoto;
  }

  bool _isPhotoVideoThumbnail(Product product, DefaultPhoto? photo) {
    final String videoPath = (product.videoThumbnail?.imgPath ?? '').toString().trim();
    final String photoPath = (photo?.imgPath ?? '').toString().trim();
    return videoPath.isNotEmpty && videoPath == photoPath;
  }

  void _selectGalleryPhoto(Product product, DefaultPhoto photo) {
    if (!_hasPhotoPath(photo)) return;

    animationController
      ?..stop()
      ..reset()
      ..repeat(reverse: true);

    setState(() {
      _selectedGalleryItemId = (product.id ?? '').toString().trim();
      _selectedGalleryPhoto = photo;
      currentDefaultPhoto = photo;
      isHaveVideo = false;
    });
  }

  void _selectNextGalleryPhoto(Product product, List<DefaultPhoto> photos) {
    if (photos.length <= 1) return;

    final int currentIndex = _selectedGalleryIndex(
      photos: photos,
      selectedPhoto: currentDefaultPhoto,
    );
    final int nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % photos.length;

    _selectGalleryPhoto(product, photos[nextIndex]);
  }

  int _selectedGalleryIndex({
    required List<DefaultPhoto> photos,
    required DefaultPhoto? selectedPhoto,
  }) {
    final String selectedKey = _photoKey(selectedPhoto);
    if (selectedKey.isEmpty) return -1;

    return photos.indexWhere((DefaultPhoto photo) => _photoKey(photo) == selectedKey);
  }

  ImageProvider _imageProviderForPhoto(DefaultPhoto? photo) {
    final String raw = (photo?.imgPath ?? '').toString().trim();

    if (raw.isEmpty) {
      return const AssetImage('assets/images/img_placeholder.png');
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return NetworkImage(raw);
    }

    return NetworkImage('${PsConfig.ps_app_image_url}$raw');
  }

  double _galleryZoomValue() {
    final AnimationController? controller = animationController;
    if (controller == null) return 0.0;

    final double raw = controller.value.clamp(0.0, 1.0);
    if (raw <= _mainGalleryZoomStartAt) return 0.0;

    final double normalized =
    ((raw - _mainGalleryZoomStartAt) / (1.0 - _mainGalleryZoomStartAt))
        .clamp(0.0, 1.0);
    return Curves.easeInOutCubic.transform(normalized);
  }

  Widget _buildAnimatedMainGalleryForeground(DefaultPhoto selectedPhoto) {
    final ImageProvider imageProvider = _imageProviderForPhoto(selectedPhoto);
    final AnimationController? controller = animationController;

    Widget buildForeground(double zoomValue) {
      final double scale = _mainGalleryImageMinScale +
          ((_mainGalleryImageMaxScale - _mainGalleryImageMinScale) * zoomValue);
      final Alignment alignment = Alignment.lerp(
        _mainGalleryImageAlignment,
        _mainGalleryZoomAlignment,
        zoomValue,
      ) ??
          _mainGalleryImageAlignment;

      return Transform.scale(
        scale: scale,
        alignment: alignment,
        child: Image(
          image: imageProvider,
          width: double.infinity,
          height: double.infinity,
          fit: _mainGalleryForegroundFit,
          alignment: alignment,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: false,
          errorBuilder: (_, __, ___) {
            return Image.asset(
              'assets/images/img_placeholder.png',
              key: const ValueKey<String>('gallery_placeholder'),
              width: double.infinity,
              height: double.infinity,
              fit: _mainGalleryForegroundFit,
              alignment: alignment,
            );
          },
        ),
      );
    }

    if (controller == null) {
      return buildForeground(0.0);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => buildForeground(_galleryZoomValue()),
    );
  }

  Widget _buildMainGalleryImage({
    required Product product,
    required List<DefaultPhoto> photos,
    required DefaultPhoto selectedPhoto,
    required bool showVideoOverlay,
  }) {
    final String selectedKey = _photoKey(selectedPhoto);
    final String safeKey = selectedKey.isEmpty ? 'empty_gallery_photo' : selectedKey;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _selectNextGalleryPhoto(product, photos);
        },
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    for (final Widget child in previousChildren)
                      Positioned.fill(child: child),
                    if (currentChild != null) Positioned.fill(child: currentChild),
                  ],
                );
              },
              child: ClipRect(
                key: ValueKey<String>('main-gallery-$safeKey'),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    // خلفية خفيفة بنفس الصورة حتى لا تظهر فراغات حادة حول الصورة.
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.24,
                        child: Image(
                          image: _imageProviderForPhoto(selectedPhoto),
                          width: double.infinity,
                          height: double.infinity,
                          fit: _mainGalleryBackgroundFit,
                          alignment: _mainGalleryImageAlignment,
                          filterQuality: FilterQuality.low,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) {
                            return Image.asset(
                              'assets/images/img_placeholder.png',
                              key: const ValueKey<String>('gallery_background_placeholder'),
                              width: double.infinity,
                              height: double.infinity,
                              fit: _mainGalleryBackgroundFit,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    // الصورة الأساسية: تظهر كاملة في البداية ثم تعمل Zoom In/Out ناعم.
                    Positioned.fill(
                      child: _buildAnimatedMainGalleryForeground(selectedPhoto),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withOpacity(0.08),
                      Colors.transparent,
                      Colors.black.withOpacity(0.24),
                    ],
                  ),
                ),
              ),
            ),
            if (showVideoOverlay)
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.48),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCountPill({
    required List<DefaultPhoto> photos,
    required DefaultPhoto? selectedPhoto,
  }) {
    if (photos.length <= 1) return const SizedBox.shrink();

    final int selectedIndex = _selectedGalleryIndex(
      photos: photos,
      selectedPhoto: selectedPhoto,
    );
    final int displayIndex = selectedIndex >= 0 ? selectedIndex + 1 : 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.58),
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          '$displayIndex / ${photos.length}',
          textDirection: TextDirection.ltr,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomGalleryStrip({
    required Product product,
    required List<DefaultPhoto> photos,
    required DefaultPhoto? selectedPhoto,
  }) {
    if (photos.length <= 1) return const SizedBox.shrink();

    final int selectedIndex = _selectedGalleryIndex(
      photos: photos,
      selectedPhoto: selectedPhoto,
    );

    return Positioned(
      left: 14,
      right: 14,
      bottom: 14,
      child: Row(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _buildPhotoCountPill(
            photos: photos,
            selectedPhoto: selectedPhoto,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ListView.separated(
                controller: _galleryThumbsController,
                scrollDirection: Axis.horizontal,
                reverse: false,
                physics: const BouncingScrollPhysics(),
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final DefaultPhoto photo = photos[index];
                  final bool selected = index == selectedIndex;

                  return Semantics(
                    button: true,
                    label: 'عرض صورة ${index + 1} من ${photos.length}',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        debugPrint(
                          '[TAAPDEEL/DETAIL_GALLERY] thumb_tap index=$index key=${_photoKey(photo)}',
                        );
                        _selectGalleryPhoto(product, photo);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOutCubic,
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.all(selected ? 3 : 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF19D4E2)
                                : Colors.white.withOpacity(0.88),
                            width: selected ? 2.5 : 1.5,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(selected ? 0.22 : 0.14),
                              blurRadius: selected ? 12 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            image: _imageProviderForPhoto(photo),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Image.asset(
                                'assets/images/img_placeholder.png',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DefaultPhoto> _parseServerGalleryPhotos(dynamic decoded) {
    dynamic rows = decoded;

    if (decoded is Map) {
      rows = decoded['data'] ??
          decoded['items'] ??
          decoded['images'] ??
          decoded['photos'] ??
          decoded['gallery'];
    }

    if (rows is! Iterable) {
      return <DefaultPhoto>[];
    }

    final List<DefaultPhoto> out = <DefaultPhoto>[];
    final Set<String> seen = <String>{};

    for (final dynamic row in rows) {
      if (row == null) continue;

      DefaultPhoto? photo;
      try {
        if (row is DefaultPhoto) {
          photo = row;
        } else if (row is Map) {
          photo = DefaultPhoto().fromMap(row);
        }
      } catch (_) {
        photo = null;
      }

      _addGalleryPhoto(target: out, seen: seen, photo: photo);
    }

    return out;
  }

  String _itemGalleryUrl() {
    return '${PsConfig.ps_app_url}rest/items/get_item_gallery/api_key/${PsConfig.ps_api_key}';
  }

  void _ensureItemGalleryLoaded(Product product) {
    final String itemId = (product.id ?? '').toString().trim();
    if (itemId.isEmpty) return;

    if (_serverGalleryItemId == itemId || _loadingGalleryItemId == itemId) {
      return;
    }

    _loadingGalleryItemId = itemId;
    final int serial = ++_galleryRequestSerial;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || serial != _galleryRequestSerial) return;
      _loadItemGallery(itemId: itemId, serial: serial);
    });
  }

  Future<void> _loadItemGallery({
    required String itemId,
    required int serial,
  }) async {
    try {
      final http.Response response = await http
          .post(
        Uri.parse(_itemGalleryUrl()),
        body: <String, String>{'item_id': itemId},
      )
          .timeout(const Duration(seconds: 8));

      if (!mounted || serial != _galleryRequestSerial) return;

      if (response.statusCode != 200) {
        debugPrint(
          '[TAAPDEEL/DETAIL_GALLERY] item_id=$itemId status=${response.statusCode}',
        );
        setState(() {
          _serverGalleryItemId = itemId;
          _serverGalleryPhotos = <DefaultPhoto>[];
          _loadingGalleryItemId = null;
        });
        return;
      }

      final dynamic decoded = json.decode(response.body);
      final List<DefaultPhoto> photos = _parseServerGalleryPhotos(decoded);

      debugPrint(
        '[TAAPDEEL/DETAIL_GALLERY] item_id=$itemId photos=${photos.length}',
      );

      if (!mounted || serial != _galleryRequestSerial) return;

      setState(() {
        _serverGalleryItemId = itemId;
        _serverGalleryPhotos = photos;
        _loadingGalleryItemId = null;
      });
    } catch (error) {
      debugPrint('[TAAPDEEL/DETAIL_GALLERY] item_id=$itemId error=$error');
      if (!mounted || serial != _galleryRequestSerial) return;

      setState(() {
        _serverGalleryItemId = itemId;
        _serverGalleryPhotos = <DefaultPhoto>[];
        _loadingGalleryItemId = null;
      });
    }
  }

  Widget _buildPaidStatusBadge(ItemDetailProvider provider) {
    final Product p = provider.itemDetail.data!;
    final bool isMine = p.addedUserId == provider.psValueHolder!.loginUserId;

    if (!isMine) {
      return const SizedBox.shrink();
    }

    if (p.paidStatus == PsConst.ADSPROGRESS) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: PsColors.paidAdsColor,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_in_progress'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    if (p.paidStatus == PsConst.ADS_REJECT) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: Colors.red,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_in_rejected'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    if (p.paidStatus == PsConst.ADS_WAITING_FOR_APPROVAL) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: Colors.yellow,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_waiting'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    if (p.paidStatus == PsConst.ADSFINISHED) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: PsColors.black,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_in_completed'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    if (p.paidStatus == PsConst.ADSNOTYETSTART) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PsDimens.space4),
          color: Colors.yellow,
        ),
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Text(
          Utils.getString(context, 'paid__ads_is_not_yet_start'),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: PsColors.white),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _maybeLoadSimilarOnce({
    required BuildContext context,
    required String currentItemId,
  }) {
    if (currentItemId.trim().isEmpty) {
      return;
    }

    if (_loadedSimilarForId == currentItemId) {
      return;
    }

    if (_similarQueued) {
      return;
    }

    _similarQueued = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final SimilarItemsByTagsProvider similarProvider =
      context.read<SimilarItemsByTagsProvider>();
      final String? loginUserId = Utils.checkUserLoginId(psValueHolder!);

      similarProvider.loadSimilarItems(
        currentItemId,
        loginUserId,
      );

      _loadedSimilarForId = currentItemId;
      _similarQueued = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isReadyToShowAppBarIcons) {
      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) {
          return;
        }
        setState(() {
          isReadyToShowAppBarIcons = true;
        });
      });
    }

    psValueHolder = Provider.of<PsValueHolder>(context);

    historyRepo = Provider.of<HistoryRepository>(context);
    productRepo = Provider.of<ProductRepository>(context);
    aboutUsRepo = Provider.of<AboutUsRepository>(context);
    userRepo = Provider.of<UserRepository>(context);
    appInfoRepository = Provider.of<AppInfoRepository>(context);
    galleryRepository = Provider.of<GalleryRepository>(context);

    markSoldOutItemHolder =
        MarkSoldOutItemParameterHolder().markSoldOutItemHolder();
    markSoldOutItemHolder!.itemId = widget.productId;

    return PsWidgetWithMultiProvider(
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ItemDetailProvider?>(
            lazy: false,
            create: (BuildContext context) {
              itemDetailProvider = ItemDetailProvider(
                repo: productRepo,
                psValueHolder: psValueHolder,
              );

              final String? loginUserId = Utils.checkUserLoginId(psValueHolder!);
              itemDetailProvider!.loadProduct(widget.productId, loginUserId);

              return itemDetailProvider;
            },
          ),
          ChangeNotifierProvider<HistoryProvider?>(
            lazy: false,
            create: (BuildContext context) {
              historyProvider = HistoryProvider(repo: historyRepo);
              return historyProvider;
            },
          ),
          ChangeNotifierProvider<AboutUsProvider?>(
            lazy: false,
            create: (BuildContext context) {
              aboutUsProvider =
                  AboutUsProvider(repo: aboutUsRepo, psValueHolder: psValueHolder);
              aboutUsProvider!.loadAboutUsList();
              return aboutUsProvider;
            },
          ),
          ChangeNotifierProvider<MarkSoldOutItemProvider?>(
            lazy: false,
            create: (BuildContext context) {
              markSoldOutItemProvider = MarkSoldOutItemProvider(repo: productRepo);
              return markSoldOutItemProvider;
            },
          ),
          ChangeNotifierProvider<UserProvider?>(
            lazy: false,
            create: (BuildContext context) {
              userProvider = UserProvider(repo: userRepo, psValueHolder: psValueHolder);
              return userProvider;
            },
          ),
          ChangeNotifierProvider<TouchCountProvider?>(
            lazy: false,
            create: (BuildContext context) {
              touchCountProvider =
                  TouchCountProvider(repo: productRepo, psValueHolder: psValueHolder);

              final String? loginUserId = Utils.checkUserLoginId(psValueHolder!);

              final TouchCountParameterHolder touchCountParameterHolder =
              TouchCountParameterHolder(
                itemId: widget.productId,
                userId: loginUserId,
              );

              touchCountProvider!
                  .postTouchCount(touchCountParameterHolder.toMap());
              return touchCountProvider;
            },
          ),
          ChangeNotifierProvider<FavouriteItemProvider?>(
            lazy: false,
            create: (BuildContext context) {
              favouriteProvider =
                  FavouriteItemProvider(repo: productRepo, psValueHolder: psValueHolder);
              return favouriteProvider;
            },
          ),
          ChangeNotifierProvider<AppInfoProvider?>(
            lazy: false,
            create: (BuildContext context) {
              appInfoProvider =
                  AppInfoProvider(repo: appInfoRepository, psValueHolder: psValueHolder);
              appInfoProvider!.loadDeleteHistorywithNotifier();
              return appInfoProvider;
            },
          ),
          ChangeNotifierProvider<GalleryProvider?>(
            lazy: false,
            create: (BuildContext context) {
              galleryProvider = GalleryProvider(repo: galleryRepository);
              return galleryProvider;
            },
          ),
          ChangeNotifierProvider<SimilarItemsByTagsProvider>(
            lazy: false,
            create: (BuildContext context) {
              return SimilarItemsByTagsProvider(
                repo: productRepo!,
                psValueHolder: psValueHolder,
                limit: 10,
              );
            },
          ),
          ChangeNotifierProvider<OwnerSubcatSubscribeProvider>(
            lazy: false,
            create: (BuildContext context) {
              return OwnerSubcatSubscribeProvider(
                repo: OwnerSubcatSubscribeRepository(
                  psApiService: PsApiService(),
                ),
              );
            },
          ),
        ],
        child: Consumer<ItemDetailProvider>(
          builder:
              (BuildContext context, ItemDetailProvider provider, Widget? child) {
            if (provider.itemDetail.data != null &&
                markSoldOutItemProvider != null &&
                userProvider != null) {
              final Product product = provider.itemDetail.data!;
              _ensureItemGalleryLoaded(product);

              if (!isAddedToHistory) {
                historyProvider!.addHistoryList(product);
                isAddedToHistory = true;

                if (psValueHolder != null &&
                    psValueHolder!.detailOpenCount != null &&
                    psValueHolder!.detailOpenCount! >
                        psValueHolder!.itemDetailViewCountForAds! &&
                    psValueHolder!.isShowAdsInItemDetail!) {
                  itemDetailProvider!.replaceDetailOpenCount(0);
                } else if (psValueHolder != null) {
                  if (psValueHolder!.detailOpenCount == null) {
                    itemDetailProvider!.replaceDetailOpenCount(1);
                  } else {
                    final int i = psValueHolder!.detailOpenCount! + 1;
                    itemDetailProvider!.replaceDetailOpenCount(i);
                  }
                }
              }

              final List<DefaultPhoto> galleryPhotos =
              _galleryPhotosForProduct(product);
              currentDefaultPhoto = _resolveCurrentPhoto(
                product: product,
                photos: galleryPhotos,
              );
              isHaveVideo = _isPhotoVideoThumbnail(product, currentDefaultPhoto) &&
                  _selectedGalleryItemId != (product.id ?? '').toString().trim();

              final String currentItemId = product.id ?? '';
              if (currentItemId.isNotEmpty) {
                _maybeLoadSimilarOnce(
                  context: context,
                  currentItemId: currentItemId,
                );
              }

              return Consumer<MarkSoldOutItemProvider>(
                builder: (
                    BuildContext context,
                    MarkSoldOutItemProvider markSoldOutItemProvider,
                    Widget? child,
                    ) {
                  return TaapdeelScaffold(
                    safeTop: false,
                    safeBottom: false,
                    padding: EdgeInsets.zero,
                    body: Stack(
                      children: <Widget>[
                        CustomScrollView(
                          slivers: <Widget>[
                            SliverAppBar(
                              automaticallyImplyLeading: true,
                              systemOverlayStyle: SystemUiOverlayStyle(
                                statusBarIconBrightness:
                                Utils.getBrightnessForAppBar(context),
                              ),
                              expandedHeight: PsDimens.space300,
                              iconTheme: Theme.of(context)
                                  .iconTheme
                                  .copyWith(color: PsColors.primaryDarkWhite),
                              leading: PsBackButtonWithCircleBgWidget(
                                isReadyToShow: isReadyToShowAppBarIcons,
                              ),
                              floating: false,
                              pinned: false,
                              stretch: true,
                              actions: <Widget>[
                                Visibility(
                                  visible: isReadyToShowAppBarIcons,
                                  child: PopUpMenuWidget(
                                    context: context,
                                    itemDetailProvider: provider,
                                    userProvider: userProvider,
                                    itemId: product.id,
                                    itemUserId: product.user!.userId,
                                    addedUserId: product.addedUserId,
                                    reportedUserId: psValueHolder!.loginUserId,
                                    loginUserId: psValueHolder!.loginUserId,
                                    itemTitle: product.title,
                                    itemImage: product.defaultPhoto!.imgPath,
                                  ),
                                ),
                              ],
                              backgroundColor: PsColors.transparent,
                              flexibleSpace: FlexibleSpaceBar(
                                background: Container(
                                  color: Colors.transparent,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: <Widget>[
                                      _buildMainGalleryImage(
                                        product: product,
                                        photos: galleryPhotos,
                                        selectedPhoto: currentDefaultPhoto!,
                                        showVideoOverlay: isHaveVideo,
                                      ),
                                      _buildBottomGalleryStrip(
                                        product: product,
                                        photos: galleryPhotos,
                                        selectedPhoto: currentDefaultPhoto,
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            _buildPaidStatusBadge(provider),
                                            const SizedBox(
                                                height: PsDimens.space6),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              children: <Widget>[
                                                if (product.isSoldOut == '1')
                                                  Expanded(
                                                    child: Container(
                                                      margin: const EdgeInsets.only(
                                                        right: PsDimens.space4,
                                                      ),
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          PsDimens.space4,
                                                        ),
                                                        color:
                                                        PsColors.soldOutUIColor,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                          PsDimens.space12,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                          Alignment.center,
                                                          child: Text(
                                                            Utils.getString(
                                                              context,
                                                              'dashboard__sold_out',
                                                            ),
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                              color:
                                                              PsColors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                <Widget>[
                                  Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      children: <Widget>[
                                        HeaderBoxWidget(
                                          itemDetail: provider,
                                          galleryProvider: galleryProvider,
                                          product: product,
                                          heroTagTitle: widget.heroTagTitle,
                                          favouriteProvider: favouriteProvider!,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                <Widget>[
                                  Container(
                                    color: PsColors.transparent,
                                    child: Column(
                                      children: <Widget>[
                                        _DetailWidget(itemDetail: provider),
                                        Column(
                                          children: <Widget>[
                                            SellerInfoTileView(itemDetail: provider),
                                            _SimilarByTagsInlineSection(
                                              itemId: product.id ?? '',
                                              coreTagKey: widget.heroTagTitle ??
                                                  product.id ??
                                                  '',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: PsDimens.space80),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!widget.adminReviewMode)
                          if (product.addedUserId != null &&
                              product.addedUserId == psValueHolder!.loginUserId)
                            EditAndDeleteButtonWidget(
                              provider: provider,
                              markSoldOutItemProvider: markSoldOutItemProvider,
                              appInfoprovider: appInfoProvider!,
                              product: product,
                              markSoldOutItemHolder: markSoldOutItemHolder,
                            )
                          else
                            CallAndChatButtonWidget(
                              provider: provider,
                              favouriteItemRepo: productRepo,
                              psValueHolder: psValueHolder,
                            ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}

class _SimilarByTagsInlineSection extends StatelessWidget {
  const _SimilarByTagsInlineSection({
    Key? key,
    required this.itemId,
    required this.coreTagKey,
    this.title = 'منتجات نفس الفئة',
  }) : super(key: key);

  final String itemId;
  final String coreTagKey;
  final String title;

  void _openProduct(BuildContext context, Product p) {
    final String productId = (p.id ?? '').trim();
    if (productId.isEmpty) {
      return;
    }

    Navigator.pushNamed(
      context,
      RoutePaths.productDetail,
      arguments: ProductDetailIntentHolder(
        productId: productId,
        heroTagImage: p.defaultPhoto?.imgPath ?? productId,
        heroTagTitle: p.title ?? productId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (itemId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer<SimilarItemsByTagsProvider>(
      builder: (BuildContext context, SimilarItemsByTagsProvider p, _) {
        final List<Product> rawItems = p.similarItems.data ?? <Product>[];

        final List<Product> items = rawItems
            .where((Product e) => (e.id ?? '').trim() != itemId.trim())
            .toList();

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            PsDimens.space16,
            PsDimens.space12,
            PsDimens.space16,
            0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: PsColors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF9EE7E1),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(PsDimens.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PsColors.textColor1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: PsDimens.space12),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: PsDimens.space12),
                      itemBuilder: (BuildContext context, int index) {
                        final Product product = items[index];
                        return SizedBox(
                          width: 145,
                          child: TaapdeelProductCardItem(
                            coreTagKey: coreTagKey,
                            product: product,
                            onTap: () => _openProduct(context, product),
                            variant: TaapdeelProductCardVariant.deal,
                            showRotatingBanner: true,
                            showRelationPanel: false,
                            showConditionChip: false,
                            onTapFav: null,
                            selectedFav: false,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailWidget extends StatelessWidget {
  const _DetailWidget({
    Key? key,
    required this.itemDetail,
  }) : super(key: key);

  final ItemDetailProvider itemDetail;

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[],
    );
  }
}
