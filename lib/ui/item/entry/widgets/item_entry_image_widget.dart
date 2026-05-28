import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/entry/item_entry_provider.dart';
import 'package:taapdeel/provider/gallery/gallery_provider.dart';
import 'package:taapdeel/ui/common/dialog/confirm_dialog_view.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/ps_button_widget.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/default_photo.dart';
import 'package:taapdeel/viewobject/holder/delete_item_image_holder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

bool _isWishlist = false;

class ItemEntryImageWidget extends StatefulWidget {
  const ItemEntryImageWidget({
    Key? key,
    required this.index,
    required this.images,
    required this.cameraImagePath,
    required this.selectedVideoImagePath,
    required this.selectedVideoPath,
    required this.videoFilePath,
    required this.videoFileThumbnailPath,
    required this.selectedImage,
    required this.hideDesc,
    this.onTap,
    this.provider,
    required this.galleryProvider,
    required this.onDeletItemImage,
    this.size = 80,
    this.borderRadius,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  final Function()? onTap;
  final Function? onDeletItemImage;
  final int? index;
  final XFile? images;
  final String? cameraImagePath;
  final String? selectedVideoImagePath;
  final String? selectedVideoPath;
  final String? videoFilePath;
  final String? videoFileThumbnailPath;
  final DefaultPhoto? selectedImage;
  final ItemEntryProvider? provider;
  final GalleryProvider? galleryProvider;
  final bool hideDesc;

  final double size;
  final double? borderRadius;
  final BoxFit fit;

  @override
  State<StatefulWidget> createState() => ItemEntryImageWidgetState();
}

class ItemEntryImageWidgetState extends State<ItemEntryImageWidget> {
  GalleryProvider? galleryProvider;
  PsValueHolder? valueHolder;

  double get _size => widget.size;
  bool get _compact => widget.hideDesc;

  double get _radius =>
      widget.borderRadius ?? (_size >= 140 ? 26 : PsDimens.space20);

  bool get _isHeroLike => !_compact || _size >= 120;

  @override
  Widget build(BuildContext context) {
    galleryProvider = widget.galleryProvider;
    valueHolder = Provider.of<PsValueHolder>(context, listen: false);

    Widget _box({required Widget child}) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: SizedBox(
          width: _size,
          height: _size,
          child: child,
        ),
      );
    }

    Widget _wrapPad(Widget child) {
      if (_compact) {
        return child;
      }
      return Padding(
        padding: const EdgeInsets.only(right: 4, left: 4),
        child: child,
      );
    }

    Widget _playOverlay() {
      return Center(
        child: Icon(
          Icons.play_circle,
          color: Colors.black54,
          size: (_size * 0.52).clamp(24, 64),
        ),
      );
    }

    Widget _enhancedImageFromProvider(
        ImageProvider imageProvider, {
          BoxFit? fit,
        }) {
      return _box(
        child: _ProfessionalImageFrame(
          fit: fit ?? widget.fit,
          isHeroLike: _isHeroLike,
          imageProvider: imageProvider,
        ),
      );
    }

    Widget _professionalLocalImage(
        String filePath, {
          BoxFit? fit,
        }) {
      return _enhancedImageFromProvider(
        FileImage(File(filePath)),
        fit: fit ?? widget.fit,
      );
    }

    Widget _professionalNetworkImage(
        String imagePath, {
          BoxFit? fit,
        }) {
      return _enhancedImageFromProvider(
        NetworkImage(imagePath),
        fit: fit ?? widget.fit,
      );
    }

    final Widget _deleteWidget = Container(
      width: PsDimens.space32,
      height: PsDimens.space32,
      decoration: BoxDecoration(
        color: PsColors.backgroundColor,
        borderRadius: BorderRadius.circular(PsDimens.space28),
      ),
      child: IconButton(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: PsDimens.space2),
        iconSize: PsDimens.space24,
        icon: const Icon(Icons.delete, color: Colors.grey),
        onPressed: () async {
          showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialogView(
                description: Utils.getString(
                  context,
                  'item_entry__confirm_delete_item_image',
                ),
                leftButtonText: Utils.getString(context, 'dialog__cancel'),
                rightButtonText: Utils.getString(context, 'dialog__ok'),
                onAgreeTap: () async {
                  Navigator.pop(context);

                  final DeleteItemImageHolder deleteItemImageHolder =
                  DeleteItemImageHolder(
                    imageId: widget.selectedImage!.imgId,
                  );

                  await PsProgressDialog.showDialog(context);
                  final PsResource<ApiStatus> apiStatus =
                  await galleryProvider!.deleItemImage(
                    deleteItemImageHolder.toMap(),
                    valueHolder!.loginUserId!,
                  );
                  PsProgressDialog.dismissDialog();

                  if (apiStatus.data != null) {
                    widget.onDeletItemImage!();
                    galleryProvider!.loadImageList(
                      widget.selectedImage!.imgParentId,
                      PsConst.ITEM_TYPE,
                    );
                  } else {
                    showDialog<dynamic>(
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorDialog(message: apiStatus.message);
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );

    final Widget _deleteVideoWidget = Container(
      width: PsDimens.space32,
      height: PsDimens.space32,
      decoration: BoxDecoration(
        color: PsColors.backgroundColor,
        borderRadius: BorderRadius.circular(PsDimens.space28),
      ),
      child: IconButton(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: PsDimens.space2),
        iconSize: PsDimens.space24,
        icon: const Icon(Icons.delete, color: Colors.grey),
        onPressed: () async {
          showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialogView(
                description: Utils.getString(
                  context,
                  'item_entry__confirm_delete_item_video',
                ),
                leftButtonText: Utils.getString(context, 'dialog__cancel'),
                rightButtonText: Utils.getString(context, 'dialog__ok'),
                onAgreeTap: () async {
                  Navigator.pop(context);

                  valueHolder =
                      Provider.of<PsValueHolder>(context, listen: false);

                  final DeleteItemImageHolder holder1 = DeleteItemImageHolder(
                    imageId: widget.provider!.item!.video!.imgId,
                  );
                  final DeleteItemImageHolder holder2 = DeleteItemImageHolder(
                    imageId: widget.provider!.item!.videoThumbnail!.imgId,
                  );

                  await PsProgressDialog.showDialog(context);

                  final PsResource<ApiStatus> api1 =
                  await galleryProvider!.deleItemVideo(
                    holder1.toMap(),
                    valueHolder!.loginUserId!,
                  );
                  final PsResource<ApiStatus> api2 =
                  await galleryProvider!.deleItemVideo(
                    holder2.toMap(),
                    valueHolder!.loginUserId!,
                  );

                  PsProgressDialog.dismissDialog();

                  if (api1.data != null && api2.data != null) {
                    widget.onDeletItemImage!();
                  } else {
                    showDialog<dynamic>(
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorDialog(message: api1.message);
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );

    // =========================================================
    // 1) Existing network image
    // =========================================================
    if (widget.selectedImage != null &&
        (widget.selectedImage!.imgPath ?? '').isNotEmpty) {
      return _wrapPad(
        InkWell(
          onTap: widget.onTap,
          child: Stack(
            children: <Widget>[
              _professionalNetworkImage(
                widget.selectedImage!.imgPath!,
                fit: widget.fit,
              ),
              if (!_compact)
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: widget.index == 0 ? const SizedBox() : _deleteWidget,
                ),
            ],
          ),
        ),
      );
    }

    // =========================================================
    // 2) Video local thumbnail
    // =========================================================
    if (widget.videoFilePath != null || widget.videoFileThumbnailPath != null) {
      if (_compact) {
        return InkWell(
          onTap: widget.onTap,
          child: Stack(
            children: [
              (widget.videoFileThumbnailPath ?? '').isNotEmpty
                  ? _professionalLocalImage(
                widget.videoFileThumbnailPath!,
                fit: BoxFit.cover,
              )
                  : _box(
                child: Container(color: Colors.black.withOpacity(0.04)),
              ),
              Positioned.fill(child: _playOverlay()),
            ],
          ),
        );
      }

      return _wrapPad(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                InkWell(
                  onTap: widget.onTap,
                  child: (widget.videoFileThumbnailPath ?? '').isNotEmpty
                      ? _professionalLocalImage(
                    widget.videoFileThumbnailPath!,
                    fit: BoxFit.cover,
                  )
                      : _box(
                    child:
                    Container(color: Colors.black.withOpacity(0.04)),
                  ),
                ),
                Positioned.fill(child: _playOverlay()),
              ],
            ),
            Visibility(
              visible: Utils.showUI(valueHolder!.video),
              child: SizedBox(
                width: _size,
                child: Padding(
                  padding: const EdgeInsets.only(top: PsDimens.space10),
                  child: InkWell(
                    child: PSButtonWidget(
                      colorData: PsColors.buttonColor,
                      width: 30,
                      titleText: Utils.getString(context, 'Play'),
                    ),
                    onTap: () {
                      if (widget.videoFilePath == null) {
                        Navigator.pushNamed(
                          context,
                          RoutePaths.video_online,
                          arguments: widget.selectedVideoPath,
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          RoutePaths.video,
                          arguments: widget.videoFilePath,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // =========================================================
    // 3) Picked gallery XFile
    // =========================================================
    if (widget.images != null) {
      final XFile asset = widget.images!;
      return _wrapPad(
        InkWell(
          onTap: widget.onTap,
          child: _professionalLocalImage(asset.path),
        ),
      );
    }

    // =========================================================
    // 4) Camera image path
    // =========================================================
    if (widget.cameraImagePath != null &&
        widget.cameraImagePath!.trim().isNotEmpty) {
      return _wrapPad(
        InkWell(
          onTap: widget.onTap,
          child: _professionalLocalImage(widget.cameraImagePath!),
        ),
      );
    }

    // =========================================================
    // 5) Selected video thumbnail from network
    // =========================================================
    if (widget.selectedVideoImagePath != null) {
      if (_compact) {
        return InkWell(
          onTap: widget.onTap,
          child: Stack(
            children: [
              (widget.selectedVideoImagePath ?? '').isNotEmpty
                  ? _professionalNetworkImage(
                widget.selectedVideoImagePath!,
                fit: BoxFit.cover,
              )
                  : _box(
                child: Container(color: Colors.black.withOpacity(0.04)),
              ),
              Positioned.fill(child: _playOverlay()),
            ],
          ),
        );
      }

      return _wrapPad(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                InkWell(
                  onTap: widget.onTap,
                  child: (widget.selectedVideoImagePath ?? '').isNotEmpty
                      ? _professionalNetworkImage(
                    widget.selectedVideoImagePath!,
                    fit: BoxFit.cover,
                  )
                      : _box(
                    child:
                    Container(color: Colors.black.withOpacity(0.04)),
                  ),
                ),
                Positioned.fill(child: _playOverlay()),
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.provider!.item!.video == null &&
                          widget.provider!.item!.videoThumbnail == null)
                        const SizedBox()
                      else
                        _deleteVideoWidget,
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: _size,
              child: Padding(
                padding: const EdgeInsets.only(top: PsDimens.space10),
                child: InkWell(
                  child: PSButtonWidget(
                    colorData: PsColors.buttonColor,
                    width: 30,
                    titleText: Utils.getString(context, 'Play'),
                  ),
                  onTap: () {
                    if (widget.videoFilePath == null) {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.video_online,
                        arguments: widget.selectedVideoPath,
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.video,
                        arguments: widget.videoFilePath,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    // =========================================================
    // 6) Default placeholder
    // =========================================================
    if (_compact) {
      return InkWell(
        onTap: widget.onTap,
        child: _box(
          child: Image.asset(
            'assets/images/default_image.png',
            fit: widget.fit,
          ),
        ),
      );
    }

    return _wrapPad(
      InkWell(
        onTap: widget.onTap,
        child: _box(
          child: Image.asset(
            'assets/images/default_image.png',
            fit: widget.fit,
          ),
        ),
      ),
    );
  }
}

class _ProfessionalImageFrame extends StatelessWidget {
  const _ProfessionalImageFrame({
    Key? key,
    required this.imageProvider,
    required this.fit,
    required this.isHeroLike,
  }) : super(key: key);

  final ImageProvider imageProvider;
  final BoxFit fit;
  final bool isHeroLike;

  static const List<double> _enhanceMatrix = <double>[
    1.08, 0.00, 0.00, 0.00, 4.0,
    0.00, 1.08, 0.00, 0.00, 4.0,
    0.00, 0.00, 1.08, 0.00, 4.0,
    0.00, 0.00, 0.00, 1.00, 0.0,
  ];

  @override
  Widget build(BuildContext context) {
    final double contentPadding = isHeroLike ? 14 : 6;
    final double blurSigma = isHeroLike ? 18 : 8;
    final double shadowWidth = isHeroLike ? 0.40 : 0.34;
    final double shadowHeight = isHeroLike ? 0.085 : 0.07;
    final double imageScale = isHeroLike ? 1.03 : 1.0;

    Widget enhancedImage({
      required BoxFit fit,
      Alignment alignment = Alignment.center,
      double opacity = 1,
    }) {
      return Opacity(
        opacity: opacity,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(_enhanceMatrix),
          child: Image(
            image: imageProvider,
            fit: fit,
            alignment: alignment,
            filterQuality: FilterQuality.medium,
            isAntiAlias: true,
            gaplessPlayback: true,
            frameBuilder: (
                BuildContext context,
                Widget child,
                int? frame,
                bool wasSynchronouslyLoaded,
                ) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: child,
              );
            },
            errorBuilder: (_, __, ___) {
              return Image.asset(
                'assets/images/default_image.png',
                fit: fit,
              );
            },
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFFF4F6F8),
        ),

        // Background cleanup عملي:
        // نفس الصورة كخلفية blurred + dim
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: enhancedImage(
              fit: BoxFit.cover,
              opacity: 0.52,
            ),
          ),
        ),

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.02),
                  Colors.black.withOpacity(0.10),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.10),
                ],
                stops: const [0.0, 0.70, 1.0],
              ),
            ),
          ),
        ),

        // soft floor shadow
        Align(
          alignment: const Alignment(0, 0.76),
          child: FractionallySizedBox(
            widthFactor: shadowWidth,
            child: FractionallySizedBox(
              heightFactor: shadowHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: isHeroLike ? 24 : 14,
                      spreadRadius: isHeroLike ? 1 : 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // radial glow خفيف خلف المنتج
        Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: isHeroLike ? 0.70 : 0.78,
            heightFactor: isHeroLike ? 0.70 : 0.78,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(isHeroLike ? 0.22 : 0.14),
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Smart framing عملي: contain + padding ثابت + تكبير بسيط
        Padding(
          padding: EdgeInsets.all(contentPadding),
          child: Transform.scale(
            scale: imageScale,
            child: enhancedImage(
              fit: BoxFit.contain,
            ),
          ),
        ),

        // glossy top light
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.white.withOpacity(0.13),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.24),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}