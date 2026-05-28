part of 'profile_share_gallery.dart';

class ShareGalleryImageResolver {
  const ShareGalleryImageResolver._();

  static String? normalize(String? raw) {
    final String value = (raw ?? '').trim();

    if (value.isEmpty || value == 'null') {
      return null;
    }

    return value.replaceAll('\\', '/').trim();
  }

  static String? resolve(Iterable<String> candidates) {
    for (final String candidate in candidates) {
      final String? value = normalize(candidate);
      if (value != null) {
        return value;
      }
    }

    return null;
  }

  static bool isAssetImagePath(String path) {
    return path.startsWith('assets/') ||
        path.startsWith('asset/') ||
        path.startsWith('packages/');
  }

  static bool isLocalFilePath(String path) {
    return path.startsWith('file:/') ||
        path.startsWith('/') ||
        path.startsWith('content:/');
  }
}