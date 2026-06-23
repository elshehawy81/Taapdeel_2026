import 'dart:io';

import 'package:flutter/material.dart';

import '../core/share_product_data.dart';

Widget shareNetworkImage(String url, {BoxFit fit = BoxFit.cover}) {
  final String cleanUrl = shareSafeString(url);

  if (!shareHas(cleanUrl)) {
    debugPrint('SHARE_IMAGE_ERROR => empty image url');
    return shareImagePlaceholder();
  }

  final bool isLocalFile = cleanUrl.startsWith('/data/') ||
      cleanUrl.startsWith('/storage/') ||
      cleanUrl.startsWith('file://');

  if (isLocalFile) {
    final String filePath = cleanUrl.replaceFirst('file://', '');
    final File file = File(filePath);

    if (!file.existsSync()) {
      debugPrint('SHARE_IMAGE_ERROR_LOCAL_NOT_FOUND => $filePath');
      return shareImagePlaceholder();
    }

    return Image.file(
      file,
      fit: fit,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        debugPrint('SHARE_IMAGE_LOCAL_ERROR_PATH => $filePath');
        debugPrint('SHARE_IMAGE_LOCAL_ERROR_DETAILS => $error');
        return shareImagePlaceholder();
      },
    );
  }

  return Image.network(
    cleanUrl,
    fit: fit,
    loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
        ) {
      if (loadingProgress == null) return child;

      return Container(
        color: const Color(0xFFE8E2D8),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    },
    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
      debugPrint('SHARE_IMAGE_ERROR_URL => $cleanUrl');
      debugPrint('SHARE_IMAGE_ERROR_DETAILS => $error');
      return shareImagePlaceholder();
    },
  );
}
Widget shareImagePlaceholder() {
  return Container(
    color: const Color(0xFFE8E2D8),
    child: const Center(
      child: Icon(
        Icons.image_outlined,
        size: 44,
        color: Colors.black26,
      ),
    ),
  );
}

Widget sharePill({
  required String text,
  required Color bg,
  required Color fg,
  IconData? icon,
  double fontSize = 10.5,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
}) {
  if (!shareHas(text)) return const SizedBox.shrink();

  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: fg.withOpacity(0.12)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: fontSize + 1.5, color: fg),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

String shareShortLocation(String location) {
  if (!shareHas(location)) return '';
  return location.split('،').first.trim();
}

String sharePriceText(ShareProductData data) {
  if (!shareHas(data.price)) return '';
  return data.isFree ? 'مجاني' : '${data.price} ج.م';
}

Widget shareBrandFooter({
  Color color = Colors.white60,
  String left = '',
  String right = 'GIVE STYLE ANOTHER STORY',
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(
        left,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        right,
        style: TextStyle(
          color: color.withOpacity(0.7),
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    ],
  );
}
