// ─────────────────────────────────────────────────────────────────────────────
// group_detection_service.dart
// Bulk AI detection service for Taapdeel.
//
// Final direction:
// - Flutter does NOT contain any AI key.
// - Flutter sends ONE group image to Taapdeel backend.
// - Backend uses Gemini and returns all product metadata.
// - Flutter keeps both: cropped product image + original group image.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'bulk_item_data.dart';

class GroupDetectionService {
  static const String _baseUrl = 'https://taapdeel.com/ai';
  static const String _bulkEndpoint = '$_baseUrl/bulk_product_info';

  /// Detects multiple products from ONE group image.
  ///
  /// The UI should allow one image only. This method still accepts a list for
  /// backward compatibility, but it intentionally analyzes only the first image.
  static Future<List<BulkItemData>> detectItemsFromImages({
    required List<String> imagePaths,
    String? categoryContext,
    void Function(String message)? onProgress,
  }) async {
    if (imagePaths.isEmpty) return <BulkItemData>[];

    final String imagePath = imagePaths.first;
    final File imageFile = File(imagePath);

    if (!imageFile.existsSync()) {
      debugPrint('GroupDetectionService: image not found: $imagePath');
      return <BulkItemData>[];
    }

    if (imagePaths.length > 1) {
      debugPrint(
        'GroupDetectionService: multiple images were provided, only the first image will be analyzed.',
      );
    }

    onProgress?.call('جاري رفع الصورة للتحليل...');

    try {
      return await _detectItemsFromSingleImage(
        imageFile: imageFile,
        categoryContext: categoryContext,
        onProgress: onProgress,
      );
    } catch (e, stackTrace) {
      debugPrint('GroupDetectionService error: $e');
      debugPrint('$stackTrace');
      return <BulkItemData>[];
    }
  }

  static Future<List<BulkItemData>> _detectItemsFromSingleImage({
    required File imageFile,
    String? categoryContext,
    void Function(String message)? onProgress,
  }) async {
    final Uri uri = Uri.parse(_bulkEndpoint);

    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    if (categoryContext != null && categoryContext.trim().isNotEmpty) {
      request.fields['category_context'] = categoryContext.trim();
    }

    onProgress?.call('AI يحلل المنتجات في الصورة...');

    final http.StreamedResponse streamedResponse =
        await request.send().timeout(const Duration(seconds: 90));

    final http.Response response = await http.Response.fromStream(streamedResponse);
    final String decodedBody = utf8.decode(response.bodyBytes);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('GroupDetectionService backend error: ${response.statusCode}');
      debugPrint(decodedBody);
      return <BulkItemData>[];
    }

    final dynamic decoded = jsonDecode(decodedBody);
    if (decoded is! Map<String, dynamic>) {
      debugPrint('GroupDetectionService invalid backend response: $decodedBody');
      return <BulkItemData>[];
    }

    final bool success = decoded['success'] == true ||
        decoded['status'] == 'success' ||
        decoded['status'] == true;

    if (!success) {
      debugPrint('GroupDetectionService backend returned failure: $decodedBody');
      return <BulkItemData>[];
    }

    final dynamic itemsRaw = decoded['items'] ??
        (decoded['data'] is Map ? (decoded['data'] as Map)['items'] : null) ??
        decoded['products'];

    if (itemsRaw is! List) {
      debugPrint('GroupDetectionService response has no items list: $decodedBody');
      return <BulkItemData>[];
    }

    onProgress?.call('جاري تجهيز صور المنتجات...');

    return _parseItemsWithCrop(
      itemsRaw: itemsRaw,
      sourceImagePath: imageFile.path,
    );
  }

  static Future<List<BulkItemData>> _parseItemsWithCrop({
    required List<dynamic> itemsRaw,
    required String sourceImagePath,
  }) async {
    final List<BulkItemData> result = <BulkItemData>[];

    for (final dynamic raw in itemsRaw) {
      if (raw is! Map) continue;

      final Map<dynamic, dynamic> item = raw;
      final String title = _readString(item, <String>['title', 'name']).trim();
      if (title.isEmpty) continue;

      String? croppedPath;
      final dynamic regionRaw = item['region'] ?? item['bbox'] ?? item['bounding_box'];
      if (regionRaw is Map && sourceImagePath.isNotEmpty) {
        try {
          final double x = _toDouble(regionRaw['x']);
          final double y = _toDouble(regionRaw['y']);
          final double w = _toDouble(regionRaw['w'] ?? regionRaw['width']);
          final double h = _toDouble(regionRaw['h'] ?? regionRaw['height']);

          // Avoid tiny/invalid boxes. Cropping from AI coordinates is helpful,
          // but it is not treated as a mandatory source of truth.
          if (w > 0.04 && h > 0.04 && w <= 1.0 && h <= 1.0) {
            croppedPath = await _cropImage(
              sourceImagePath: sourceImagePath,
              rx: x,
              ry: y,
              rw: w,
              rh: h,
              itemTitle: title,
            );
          }
        } catch (e) {
          debugPrint('Crop failed for "$title": $e');
        }
      }

      final dynamic tagsRaw = item['tags'];
      final Map<dynamic, dynamic>? tagsMap = tagsRaw is Map ? tagsRaw : null;

      result.add(
        BulkItemData(
          title: title,
          description: _nullableString(
            _readString(item, <String>['description', 'short_description']),
          ),
          categoryHint: _nullableString(
            _readString(item, <String>['categoryHint', 'category_hint', 'category_name', 'category']),
          ),
          subCategoryHint: _nullableString(
            _readString(item, <String>['subCategoryHint', 'sub_category_hint', 'subcategory_name', 'subcategory', 'sub_category']),
          ),
          conditionHint: _nullableString(
            _readString(item, <String>['conditionHint', 'condition_hint', 'condition']),
          ),
          priceRangeHint: _nullableString(
            _readString(item, <String>['priceRangeHint', 'price_range_hint', 'price_range']),
          ),
          brandHint: _nullableString(
            _readString(item, <String>['brandHint', 'brand_hint', 'brand']),
          ),
          categoryId: _nullableString(
            _readString(item, <String>['categoryId', 'category_id', 'cat_id']),
          ),
          subCategoryId: _nullableString(
            _readString(item, <String>['subCategoryId', 'sub_category_id', 'sub_cat_id']),
          ),
          averagePrice: _nullableString(
            _readString(item, <String>['averagePrice', 'average_price', 'avg_price']),
          ),
          croppedImagePath: croppedPath,
          sourceImagePath: sourceImagePath,
          tagsAr: _stringListFromDynamic(
            item['tagsAr'] ?? item['tags_ar'] ?? tagsMap?['ar'],
          ),
          tagsEn: _stringListFromDynamic(
            item['tagsEn'] ?? item['tags_en'] ?? tagsMap?['en'],
          ),
          tagsConfidence: _nullableString(
            (item['tagsConfidence'] ?? item['tags_confidence'] ?? tagsMap?['confidence'])?.toString(),
          ),
        ),
      );
    }

    return result;
  }

  static String _readString(Map<dynamic, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = map[key];
      if (value == null) continue;

      if (value is Map) {
        final dynamic nested = value['value'] ?? value['ar'] ?? value['en'] ?? value['name'];
        if (nested != null && nested.toString().trim().isNotEmpty) {
          return nested.toString().trim();
        }
        continue;
      }

      if (value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  static String? _nullableString(String? value) {
    final String normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  static List<String>? _stringListFromDynamic(dynamic value) {
    if (value == null) return null;

    if (value is List) {
      final List<String> result = value
          .map((dynamic e) => e?.toString().trim() ?? '')
          .where((String e) => e.isNotEmpty)
          .toList();
      return result.isEmpty ? null : result;
    }

    if (value is String && value.trim().isNotEmpty) {
      final List<String> result = value
          .split(RegExp(r'[,،]'))
          .map((String e) => e.trim())
          .where((String e) => e.isNotEmpty)
          .toList();
      return result.isEmpty ? null : result;
    }

    return null;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Crops a product preview from the original group image.
  /// We keep generous padding because AI boxes are approximate.
  static Future<String?> _cropImage({
    required String sourceImagePath,
    required double rx,
    required double ry,
    required double rw,
    required double rh,
    required String itemTitle,
  }) async {
    try {
      final Uint8List bytes = await File(sourceImagePath).readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image srcImage = frame.image;

      final int imgW = srcImage.width;
      final int imgH = srcImage.height;

      const double pad = 0.05;
      final double left = (rx - pad).clamp(0.0, 1.0);
      final double top = (ry - pad).clamp(0.0, 1.0);
      final double right = (rx + rw + pad).clamp(0.0, 1.0);
      final double bottom = (ry + rh + pad).clamp(0.0, 1.0);

      final int cropX = (left * imgW).round();
      final int cropY = (top * imgH).round();
      final int cropW = ((right - left) * imgW).round();
      final int cropH = ((bottom - top) * imgH).round();

      if (cropW < 40 || cropH < 40) {
        srcImage.dispose();
        return null;
      }

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      canvas.drawImageRect(
        srcImage,
        Rect.fromLTWH(cropX.toDouble(), cropY.toDouble(), cropW.toDouble(), cropH.toDouble()),
        Rect.fromLTWH(0, 0, cropW.toDouble(), cropH.toDouble()),
        Paint(),
      );
      final ui.Picture picture = recorder.endRecording();
      final ui.Image cropped = await picture.toImage(cropW, cropH);

      final ByteData? pngData = await cropped.toByteData(format: ui.ImageByteFormat.png);
      if (pngData == null) {
        srcImage.dispose();
        cropped.dispose();
        return null;
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String normalizedTitle = itemTitle.replaceAll(RegExp(r'[^\w\u0600-\u06FF]'), '_');
      final int maxNameLength = normalizedTitle.length < 20 ? normalizedTitle.length : 20;
      final String safeName = normalizedTitle.substring(0, maxNameLength).isEmpty ? 'item' : normalizedTitle.substring(0, maxNameLength);
      final String outPath = '${tempDir.path}/bulk_crop_${safeName}_${DateTime.now().millisecondsSinceEpoch}.png';

      await File(outPath).writeAsBytes(pngData.buffer.asUint8List());

      srcImage.dispose();
      cropped.dispose();

      return outPath;
    } catch (e) {
      debugPrint('_cropImage error: $e');
      return null;
    }
  }
}
