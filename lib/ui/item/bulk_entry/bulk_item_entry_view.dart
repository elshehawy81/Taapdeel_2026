// ─────────────────────────────────────────────────────────────────────────────
// bulk_item_entry_view.dart
//
// Main multi-product entry screen.
// This screen is opened from DashboardView using:
// const BulkItemEntryView(maxItems: 30)
//
// It selects group images, runs AI detection, then opens BulkDetectionReviewScreen.
// Do not use this file as the editor for one item inside the queue.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/utils/utils.dart';

import '../../common/taapdeel/taapdeel_button.dart';
import 'bulk_detection_review.dart';
import 'bulk_item_data.dart';
import 'bulk_item_defaults.dart';
import 'group_detection_service.dart';

class BulkItemEntryView extends StatefulWidget {
  const BulkItemEntryView({
    Key? key,
    this.maxItems = 10,
  }) : super(key: key);

  final int maxItems;

  @override
  State<BulkItemEntryView> createState() => _BulkItemEntryViewState();
}

class _BulkItemEntryViewState extends State<BulkItemEntryView> {
  final ImagePicker _picker = ImagePicker();

  final List<String> _imagePaths = <String>[];
  final BulkItemDefaults _defaults = const BulkItemDefaults();

  bool _isDetecting = false;
  String _progressMessage = '';

  bool get _canDetect => _imagePaths.isNotEmpty && !_isDetecting;

  Future<void> _pickFromGallery() async {
    if (_isDetecting) return;

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _imagePaths
        ..clear()
        ..add(picked.path);
    });
  }

  Future<void> _pickFromCamera() async {
    if (_isDetecting) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _imagePaths
        ..clear()
        ..add(image.path);
    });
  }

  void _removeImage(int index) {
    if (_isDetecting) return;
    if (index < 0 || index >= _imagePaths.length) return;

    setState(() => _imagePaths.removeAt(index));
  }

  Future<void> _detectItems() async {
    if (!_canDetect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر صورة واحدة واضحة أولاً')),
      );
      return;
    }

    setState(() {
      _isDetecting = true;
      _progressMessage = 'جاري تجهيز الصور...';
    });

    try {
      final List<BulkItemData> detectedItems =
      await GroupDetectionService.detectItemsFromImages(
        imagePaths: List<String>.from(_imagePaths),
        categoryContext: _defaults.categoryName,
        onProgress: (String message) {
          if (!mounted) return;
          setState(() => _progressMessage = message);
        },
      );

      if (!mounted) return;

      if (detectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم اكتشاف منتجات واضحة في الصورة'),
          ),
        );
        return;
      }

      final bool? completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (_) => BulkDetectionReviewScreen(
            detectedItems: detectedItems.take(widget.maxItems).toList(),
            sourceImagePaths: List<String>.from(_imagePaths),
            maxItems: widget.maxItems,
            defaults: _defaults,
          ),
        ),
      );

      if (!mounted) return;
      if (completed == true) {
        await _goToProfileAfterBulkCompleted();
        return;
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('BulkItemEntryView detection error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تحليل الصور. حاول مرة أخرى.'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isDetecting = false;
        _progressMessage = '';
      });
    }
  }


  Future<void> _goToProfileAfterBulkCompleted() async {
    bool handledByDashboard = false;

    // نفس فكرة المنتج الواحد: نطلب من الـ Dashboard تغيير التاب للبروفايل.
    context.visitAncestorElements((Element element) {
      if (element is StatefulElement) {
        final dynamic st = element.state;

        try {
          st.goToProfileTab(refresh: true);
          handledByDashboard = true;
          return false;
        } catch (_) {}

        try {
          st.goToProfileTab();
          handledByDashboard = true;
          return false;
        } catch (_) {}

        try {
          st.goToBottomTab(4);
          handledByDashboard = true;
          return false;
        } catch (_) {}
      }
      return true;
    });

    if (handledByDashboard) return;

    // fallback آمن لو الشاشة مفتوحة كـ route مستقل.
    // لا نستخدم popUntil(route.isFirst) حتى لا نرجع للـ Splash.
    try {
      await Navigator.of(context).pushNamed(RoutePaths.profile_container);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Utils.isLightMode(context);

    return Scaffold(
      backgroundColor: PsColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: PsColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'إضافة عدة منتجات',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: isLight
                ? PsColors.primary500
                : PsColors.primaryDarkWhite,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(PsDimens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _IntroCard(maxItems: 1),
                const SizedBox(height: PsDimens.space16),
                guideLine(
                  Icons.photo_camera_outlined,
                  'ارفع صورة واحدة واضحة تضم المنتجات المراد اكتشافها، ويفضل التصوير من أعلى بإضاءة جيدة.',
                ),
                const SizedBox(height: PsDimens.space8),
                guideLine(
                  Icons.info,
                  'اترك مسافة واضحة بين المنتجات، واجعل كل منتج ظاهرًا بالكامل بدون تداخل أو قص من الأطراف.',
                ),
                const SizedBox(height: PsDimens.space8),
                guideLine(
                  Icons.edit_note_rounded,
                  'بعد التحليل ستظهر لك المنتجات للمراجعة، ويمكنك تغيير بيانات كل منتج قبل نشره.',
                ),
                const SizedBox(height: PsDimens.space16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isDetecting ? null : _pickFromGallery,
                        icon: const Icon(Icons.photo_library_rounded),
                        label: const Text('اختيار صورة'),
                      ),
                    ),
                    const SizedBox(width: PsDimens.space12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isDetecting ? null : _pickFromCamera,
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: const Text('تصوير'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PsDimens.space12),
                Text(
                  _imagePaths.isEmpty
                      ? 'لم يتم اختيار صورة بعد'
                      : 'تم اختيار صورة واحدة',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PsDimens.space12),
                Expanded(
                  child: _imagePaths.isEmpty
                      ? const _EmptyImagesState()
                      : GridView.builder(
                    itemCount: _imagePaths.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return _SelectedImageTile(
                        path: _imagePaths[index],
                        onRemove: () => _removeImage(index),
                      );
                    },
                  ),
                ),
                if (_isDetecting) ...<Widget>[
                  const SizedBox(height: PsDimens.space12),
                  LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: PsColors.primary500.withOpacity(0.12),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(PsColors.primary500),
                  ),
                  const SizedBox(height: PsDimens.space8),
                  Text(
                    _progressMessage.isEmpty
                        ? 'جاري التحليل...'
                        : _progressMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PsColors.primary500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: PsDimens.space16),
                TaapdeelButton(
                  label: 'اكتشاف المنتجات بالذكاء الاصطناعي',
                  onPressed: _canDetect ? _detectItems : null,
                  isPrimary: true,
                  isExpanded: true,
                  height: 54,
                  icon: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
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



class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.maxItems});

  final int maxItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsDimens.space16),
      decoration: BoxDecoration(
        color: Utils.isLightMode(context) ? Colors.white : Colors.grey[900],
        borderRadius: BorderRadius.circular(PsDimens.space16),
        border: Border.all(color: PsColors.primary500.withOpacity(0.16)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: PsColors.primary500.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: PsColors.primary500.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: PsColors.primary500,
            ),
          ),
          const SizedBox(width: PsDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'صوّر مجموعة منتجات مرة واحدة',
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سنكتشف المنتجات ثم تراجعها وتدخلها واحداً تلو الآخر. الحد الأقصى $maxItems منتج.',
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyImagesState extends StatelessWidget {
  const _EmptyImagesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'اختر صورة واضحة تحتوي على عدة منتجات',
        textDirection: TextDirection.rtl,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Widget guideLine(IconData icon, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    textDirection: TextDirection.rtl,
    children: <Widget>[
      Icon(icon, size: 16, color: PsColors.primary500),
      const SizedBox(width: PsDimens.space8),
      Expanded(
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: const Color(0xFF0F2E57).withOpacity(0.76),
            fontWeight: FontWeight.w700,
            height: 1.35,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

class _SelectedImageTile extends StatelessWidget {
  const _SelectedImageTile({
    required this.path,
    required this.onRemove,
  });

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PsDimens.space12),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.withOpacity(0.15),
              child: const Icon(Icons.broken_image_rounded),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
