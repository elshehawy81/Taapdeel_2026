import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'orbit_tags_around.dart';
import 'item_entry_image_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/provider/entry/item_entry_provider.dart';
import 'package:taapdeel/provider/gallery/gallery_provider.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/default_photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

bool _isWishlist = false;

class ImageUploadHorizontalList extends StatefulWidget {
  const ImageUploadHorizontalList({
    Key? key,
    required this.flag,
    required this.images,
    required this.selectedImageList,
    required this.updateImages,
    this.updateImagesFromCustomCamera,
    this.updateImagesFromVideo,
    this.selectedVideoImagePath,
    this.videoFilePath,
    this.videoFileThumbnailPath,
    this.selectedVideoPath,
    required this.galleryImagePath,
    required this.cameraImagePath,
    this.getImageFromVideo,
    required this.imageDesc1Controller,
    required this.galleryProvider,
    required this.onReorder,
    this.provider,
    this.enableOrbit = false,
    this.ringCount = 2,
    this.orbitPadding = const EdgeInsets.fromLTRB(14, 40, 14, 14),
    this.orbitCategoryLabel,
    this.orbitSubCategoryLabel,
    this.orbitTags = const <String>[],

    /// ✅ NEW: thumbnails controls (SHOW/HIDE ONLY)
    this.showThumbs = true,
    this.showVideoThumb = true,

    // ── AI scan control ──────────────────────────────────────────────────────
    /// يُضبط على true لما الـ AI يبدأ التحليل، false لما يخلص
    this.isAiScanning = false,
  }) : super(key: key);

  final String? flag;
  final List<XFile>? images;
  final List<DefaultPhoto?>? selectedImageList;

  final Function(List<XFile>, int, int)? updateImages;

  final bool enableOrbit;
  final int ringCount;
  final EdgeInsets orbitPadding;
  final String? orbitCategoryLabel;
  final String? orbitSubCategoryLabel;
  final List<String> orbitTags;

  final bool showThumbs;
  final bool showVideoThumb;

  final Function(String, int)? updateImagesFromCustomCamera;
  final Function(String, int)? updateImagesFromVideo;

  final String? selectedVideoImagePath;
  final String? videoFilePath;
  final String? selectedVideoPath;
  final String? videoFileThumbnailPath;

  final List<XFile?> galleryImagePath;
  final List<String?> cameraImagePath;

  final Function(String)? getImageFromVideo;

  final TextEditingController? imageDesc1Controller;
  final ItemEntryProvider? provider;
  final GalleryProvider? galleryProvider;

  final void Function(int, int) onReorder;

  // ── AI scan ──────────────────────────────────────────────────────────────
  final bool isAiScanning;

  @override
  State<StatefulWidget> createState() => ImageUploadHorizontalListState();
}

class ImageUploadHorizontalListState extends State<ImageUploadHorizontalList>
    with TickerProviderStateMixin {
  late ItemEntryProvider provider;
  late PsValueHolder psValueHolder;

  final ImagePicker _picker = ImagePicker();

  int _heroIndex = 0;
  late final PageController _heroController;

  // ── AI scan animation ────────────────────────────────────────────────────
  /// sweeps top→bottom while scanning, loops until isAiScanning = false
  late final AnimationController _scanController;

  /// فلاش بيضاء قصيرة لما الـ scan يخلص (اكتشاف ناجح)
  late final AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _heroController = PageController(initialPage: _heroIndex);

    // sweep: 1.6 ثانية per pass، بيلوب لما isAiScanning = true
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // flash: 400ms واحدة فقط لما الـ scan يخلص
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    if (widget.isAiScanning) {
      _scanController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ImageUploadHorizontalList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // بدأ الـ scan
    if (!oldWidget.isAiScanning && widget.isAiScanning) {
      _flashController.reset();
      _scanController.repeat();
    }

    // خلص الـ scan → flash ثم وقف
    if (oldWidget.isAiScanning && !widget.isAiScanning) {
      _scanController.stop();
      _scanController.reset();
      _flashController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _scanController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SCAN OVERLAY
  // ─────────────────────────────────────────────────────────────────────────

  /// يُعرض فوق الـ ClipOval بالضبط — يظهر فقط لما isAiScanning أو الـ flash شغال
  Widget _buildScanOverlay(double diameter) {
    final bool scanning = widget.isAiScanning;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_scanController, _flashController]),
      builder: (BuildContext ctx, _) {
        final double scanT = _scanController.value; // 0.0 → 1.0 loop
        final double flashT = _flashController.value; // 0.0 → 1.0 once

        // الـ flash يظهر بعد ما الـ scan يخلص
        final bool showFlash = !scanning && flashT > 0 && flashT < 1;
        final bool showScan = scanning;

        if (!showScan && !showFlash) return const SizedBox.shrink();

        return ClipOval(
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Stack(
              children: <Widget>[
                // ── 1. تظليل داكن فوق خط الـ scan ─────────────────────────
                if (showScan)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: scanT * diameter,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.black.withOpacity(0.30),
                            Colors.black.withOpacity(0.06),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── 2. خط الـ scan المضيء ───────────────────────────────────
                if (showScan)
                  Positioned(
                    top: (scanT * diameter) - 2,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.transparent,
                            Color(0xFF5DBBFF),
                            Colors.white,
                            Color(0xFF5DBBFF),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0x995DBBFF),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── 3. زوايا الـ scan frame ──────────────────────────────────
                if (showScan) ...<Widget>[
                  const Positioned(
                    top: 18,
                    left: 18,
                    child: _ScanCorner(flipX: false, flipY: false),
                  ),
                  const Positioned(
                    top: 18,
                    right: 18,
                    child: _ScanCorner(flipX: true, flipY: false),
                  ),
                  const Positioned(
                    bottom: 18,
                    left: 18,
                    child: _ScanCorner(flipX: false, flipY: true),
                  ),
                  const Positioned(
                    bottom: 18,
                    right: 18,
                    child: _ScanCorner(flipX: true, flipY: true),
                  ),
                ],

                // ── 4. نص "جاري التحليل" ─────────────────────────────────────
                if (showScan)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: diameter * 0.14,
                    child: _ScanningLabel(scanT: scanT),
                  ),

                // ── 5. فلاش بيضاء بعد نجاح الـ scan ─────────────────────────
                if (showFlash)
                  Opacity(
                    opacity: (1.0 - flashT).clamp(0.0, 1.0),
                    child: Container(color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _containsWebp(List<XFile> files) async {
    for (final XFile file in files) {
      if (file.name.toLowerCase().contains('.webp') ||
          file.path.toLowerCase().endsWith('.webp')) {
        return true;
      }
    }
    return false;
  }

  Future<void> _showWebpError() async {
    await showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(
          message: Utils.getString(context, 'error_dialog__webp_image'),
        );
      },
    );
  }

  Future<List<XFile>> _pickProfessionalMultiImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage();
      return files;
    } catch (e) {
      Utils.psPrint(e.toString());
      return <XFile>[];
    }
  }

  Future<List<XFile>> _pickProfessionalSingleImage() async {
    try {
      final XFile? single = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (single != null) {
        return <XFile>[single];
      }
      return <XFile>[];
    } catch (e) {
      Utils.psPrint(e.toString());
      return <XFile>[];
    }
  }

  Future<void> loadPickMultiImage(int index) async {
    final List<XFile> resultList = await _pickProfessionalMultiImages();

    if (!mounted) return;
    if (resultList.isEmpty) return;

    if (await _containsWebp(resultList)) {
      await _showWebpError();
      return;
    }

    widget.updateImages?.call(resultList, -1, index);
  }

  Future<void> loadSingleImage(int index) async {
    final List<XFile> resultList = await _pickProfessionalSingleImage();

    if (!mounted) return;
    if (resultList.isEmpty) return;

    if (await _containsWebp(resultList)) {
      await _showWebpError();
      return;
    }

    widget.updateImages?.call(resultList, index, index);
  }

  bool _slotHasImage(int slotIndex) {
    final bool hasGallery = widget.galleryImagePath.length > slotIndex &&
        widget.galleryImagePath[slotIndex] != null;

    final bool hasCamera = widget.cameraImagePath.length > slotIndex &&
        (widget.cameraImagePath[slotIndex] ?? '').trim().isNotEmpty;

    final bool hasNetwork = (widget.selectedImageList != null &&
        widget.selectedImageList!.length > slotIndex &&
        widget.selectedImageList![slotIndex] != null &&
        (widget.selectedImageList![slotIndex]!.imgPath ?? '').trim().isNotEmpty &&
        (widget.selectedImageList![slotIndex]!.imgId ?? '').trim().isNotEmpty);

    return hasGallery || hasCamera || hasNetwork;
  }

  Future<void> _openPickerForSlot(int slotIndex) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (widget.flag == PsConst.ADD_NEW_ITEM) {
      await loadPickMultiImage(slotIndex);
    } else {
      await loadSingleImage(slotIndex);
    }
  }

  Widget _buildHeroDisplayForSlot(int slotIndex) {
    XFile? defaultAssetImage;
    DefaultPhoto? defaultUrlImage;

    final double heroVisualSize =
    math.min(MediaQuery.of(context).size.width * 0.68, 320);

    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 2.6,
      child: Center(
        child: ItemEntryImageWidget(
          galleryProvider: widget.galleryProvider,
          index: slotIndex,
          images: (widget.galleryImagePath.length > slotIndex &&
              widget.galleryImagePath[slotIndex] != null)
              ? widget.galleryImagePath[slotIndex]
              : defaultAssetImage,
          selectedVideoImagePath: null,
          selectedVideoPath: widget.selectedVideoPath,
          videoFilePath: null,
          videoFileThumbnailPath: null,
          cameraImagePath: (widget.cameraImagePath.length > slotIndex)
              ? widget.cameraImagePath[slotIndex]
              : null,
          selectedImage: (widget.selectedImageList != null &&
              widget.selectedImageList!.length > slotIndex &&
              widget.galleryImagePath[slotIndex] == null &&
              widget.cameraImagePath[slotIndex] == null)
              ? widget.selectedImageList![slotIndex]
              : defaultUrlImage,
          hideDesc: false,
          size: heroVisualSize,
          fit: BoxFit.contain,
          onDeletItemImage: () {
            setState(() {
              if (widget.selectedImageList != null &&
                  widget.selectedImageList!.length > slotIndex &&
                  widget.selectedImageList![slotIndex] != null) {
                widget.selectedImageList![slotIndex]!.imgId = '';
                widget.selectedImageList![slotIndex] =
                    DefaultPhoto(imgId: '', imgPath: '');
              }
            });
          },
          onTap: () => _openPickerForSlot(slotIndex),
        ),
      ),
    );
  }

  // ── HERO ─────────────────────────────────────────────────────────────────

  Widget _buildHeroContent() {
    final ThemeData theme = Theme.of(context);
    final int max = psValueHolder.maxImageCount;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final double side = math.min(c.maxWidth, c.maxHeight);
            final double circle = side * 0.88;

            return Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    width: circle,
                    height: circle,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.04),
                    ),
                  ),
                ),

                // ── PageView داخل ClipOval ────────────────────────────────
                Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: circle,
                      height: circle,
                      child: PageView.builder(
                        controller: _heroController,
                        itemCount: max,
                        onPageChanged: (int i) =>
                            setState(() => _heroIndex = i),
                        itemBuilder: (_, int i) {
                          final bool hasImg = _slotHasImage(i);

                          return GestureDetector(
                            onTap: () => _openPickerForSlot(i),
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                if (hasImg)
                                  _buildHeroDisplayForSlot(i)
                                else
                                  Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            size: 42,
                                            color:
                                            Colors.black.withOpacity(0.35),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            Utils.getString(
                                              context,
                                              'item_entry__default_image',
                                            ),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: Colors.black
                                                  .withOpacity(0.55),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (!hasImg)
                                  Positioned(
                                    left: 10,
                                    right: 10,
                                    bottom: 40,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.40),
                                        borderRadius:
                                        BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        'اسحب يمين/شمال لتغيير الصورة الافتراضية',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ── AI Scan overlay — فوق الـ ClipOval بالضبط ───────────────
                Center(
                  child: _buildScanOverlay(circle),
                ),

                // ── "صور المنتج" label ────────────────────────────────────────
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.40),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'صور المنتج',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroPager() {
    final double w = MediaQuery.of(context).size.width;
    final double heroH = w * 0.82;

    return SizedBox(
      height: heroH,
      width: double.infinity,
      child: _buildHeroContent(),
    );
  }

  // ── VIDEO ─────────────────────────────────────────────────────────────────
  late Widget _videoWidget;

  // ── THUMBS ────────────────────────────────────────────────────────────────
  List<Widget> _thumbWidgets = <Widget>[];

  void _fixHeroIndexAfterReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    if (_heroIndex == oldIndex) {
      _heroIndex = newIndex;
    } else if (oldIndex < _heroIndex && newIndex >= _heroIndex) {
      _heroIndex -= 1;
    } else if (oldIndex > _heroIndex && newIndex <= _heroIndex) {
      _heroIndex += 1;
    }

    if (_heroController.hasClients) {
      _heroController.jumpToPage(_heroIndex);
    }
  }

  Widget _buildThumbsBar() {
    if (!widget.showThumbs) return const SizedBox.shrink();

    return SizedBox(
      height: 60,
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            _fixHeroIndexAfterReorder(oldIndex, newIndex);
            widget.onReorder(oldIndex, newIndex);
          });
        },
        header:
        widget.showVideoThumb ? _videoWidget : const SizedBox.shrink(),
        children: _thumbWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    XFile? defaultAssetImage;
    DefaultPhoto? defaultUrlImage;

    psValueHolder = Provider.of<PsValueHolder>(context);
    provider = Provider.of<ItemEntryProvider>(context, listen: false);

    final int max = psValueHolder.maxImageCount;
    if (_heroIndex >= max) {
      _heroIndex = 0;
      if (_heroController.hasClients) _heroController.jumpToPage(0);
    }

    _videoWidget = Visibility(
      visible: Utils.showUI(provider.psValueHolder!.video),
      child: ItemEntryImageWidget(
        galleryProvider: widget.galleryProvider,
        index: -1,
        images: defaultAssetImage,
        selectedVideoImagePath: widget.selectedVideoImagePath,
        videoFilePath: widget.videoFilePath,
        videoFileThumbnailPath: widget.videoFileThumbnailPath,
        selectedVideoPath: widget.selectedVideoPath,
        cameraImagePath: null,
        provider: provider,
        selectedImage:
        widget.selectedVideoImagePath == null ? defaultUrlImage : null,
        onDeletItemImage: () {
          setState(() {
            final ItemEntryProvider itemEntryProvider =
            Provider.of<ItemEntryProvider>(context, listen: false);
            if (itemEntryProvider.item != null) {
              itemEntryProvider.item!.video?.imgId = '';
              itemEntryProvider.item!.videoThumbnail?.imgId = '';
              itemEntryProvider.item!.video = null;
              itemEntryProvider.item!.videoThumbnail = null;
            }
          });
        },
        hideDesc: true,
        onTap: () async {
          List<PlatformFile>? videoFiles;

          try {
            final FilePickerResult? result =
            await FilePicker.platform.pickFiles(
              type: FileType.video,
              allowMultiple: false,
            );
            videoFiles = result?.files;
          } on PlatformException catch (e) {
            Utils.psPrint('Unsupported operation: $e');
          } catch (ex) {
            Utils.psPrint(ex.toString());
          }

          if (videoFiles == null || videoFiles.isEmpty) return;

          final File pickedVideo = File(videoFiles.first.path!);
          final VideoPlayerController videoPlayer =
          VideoPlayerController.file(pickedVideo);
          await videoPlayer.initialize();

          final int maximumMs =
              int.tryParse(psValueHolder.videoDuration ?? '60000') ?? 60000;
          final int videoDuration =
              videoPlayer.value.duration.inMilliseconds;

          if (videoDuration < maximumMs) {
            await widget.getImageFromVideo?.call(pickedVideo.path);
            widget.updateImagesFromVideo?.call(pickedVideo.path, -2);
          } else {
            await showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                    context,
                    'error_dialog__select_video',
                  ),
                );
              },
            );
          }
        },
      ),
    );

    _thumbWidgets = List<Widget>.generate(
      psValueHolder.maxImageCount,
          (int slotIndex) {
        final bool isSelected = slotIndex == _heroIndex;

        final Widget thumb = ItemEntryImageWidget(
          galleryProvider: widget.galleryProvider,
          key: Key('$slotIndex'),
          index: slotIndex,
          images: (widget.galleryImagePath[slotIndex] != null)
              ? widget.galleryImagePath[slotIndex]
              : defaultAssetImage,
          selectedVideoImagePath: null,
          selectedVideoPath: widget.selectedVideoPath,
          videoFilePath: null,
          videoFileThumbnailPath: null,
          cameraImagePath: widget.cameraImagePath[slotIndex],
          selectedImage: (widget.selectedImageList != null &&
              widget.selectedImageList!.length > slotIndex &&
              widget.galleryImagePath[slotIndex] == null &&
              widget.cameraImagePath[slotIndex] == null)
              ? widget.selectedImageList![slotIndex]
              : null,
          hideDesc: true,
          onDeletItemImage: () {
            setState(() {
              if (widget.selectedImageList != null &&
                  widget.selectedImageList!.length > slotIndex &&
                  widget.selectedImageList![slotIndex] != null) {
                widget.selectedImageList![slotIndex]!.imgId = '';
                widget.selectedImageList![slotIndex] =
                    DefaultPhoto(imgId: '', imgPath: '');
              }
            });
          },
          onTap: () => _openPickerForSlot(slotIndex),
        );

        return Container(
          key: Key('thumb_$slotIndex'),
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              width: isSelected ? 2 : 1,
              color: isSelected
                  ? const Color(0xFFB8D9FF)
                  : Colors.black.withOpacity(0.10),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color:
                Colors.black.withOpacity(isSelected ? 0.12 : 0.05),
                blurRadius: isSelected ? 14 : 10,
                offset: const Offset(0, 6),
              ),
            ],
            color: Colors.white.withOpacity(0.85),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: thumb),
                  if (slotIndex == 0)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Theme.of(context).textTheme.bodySmall == null
                            ? const Text(
                          'Hero',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                            : Text(
                          'Hero',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Builder(
          builder: (BuildContext context) {
            Widget hero = _buildHeroPager();

            if (widget.enableOrbit) {
              hero = OrbitTagsAround(
                enable: true,
                editable: true,
                ringCount: 1,
                padding: const EdgeInsets.fromLTRB(14, 44, 14, 14),
                innerHoleRadiusFactor: 0.64,
                minGapPx: 14,
                maxTagWidth: 132,
                child: hero,
                categoryLabel: widget.orbitCategoryLabel ?? '',
                subCategoryLabel: widget.orbitSubCategoryLabel ?? '',
                tags: widget.orbitTags,
                onTagsChanged: (updatedTags) {
                  setState(() {});
                  try {
                    provider.tags = updatedTags;
                  } catch (_) {}
                },
                onTap: ({required text, required kind, required tagIndex}) {},
                onDelete: ({required text, required kind, required tagIndex}) {},
              );
            }

            return hero;
          },
        ),
        const SizedBox(height: 12),
        _buildThumbsBar(),
        if (widget.showThumbs) const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCAN CORNER BRACKET
// ─────────────────────────────────────────────────────────────────────────────

class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.flipX, required this.flipY});

  final bool flipX;
  final bool flipY;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0),
      child: SizedBox(
        width: 22,
        height: 22,
        child: CustomPaint(painter: _CornerBracketPainter()),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF5DBBFF)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCANNING LABEL  (نبضة تحت الـ scan line)
// ─────────────────────────────────────────────────────────────────────────────

class _ScanningLabel extends StatelessWidget {
  const _ScanningLabel({required this.scanT});

  final double scanT; // 0.0 → 1.0

  @override
  Widget build(BuildContext context) {
    // نظهر النص في النصف الأخير من كل sweep
    final double labelOpacity = (scanT > 0.45 ? (scanT - 0.45) / 0.55 : 0.0)
        .clamp(0.0, 1.0);

    return Opacity(
      opacity: labelOpacity,
      child: Center(
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.52),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF5DBBFF).withOpacity(0.55),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF5DBBFF).withOpacity(0.22),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF5DBBFF),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'جاري التحليل بالذكاء الاصطناعي…',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.92),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
