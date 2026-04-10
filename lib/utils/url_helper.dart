import 'package:raptor_pro/base_url.dart';

class UrlHelper {
  /// Safely joins the base [imageUrl] with a specific [path].
  /// Handles nulls, empty strings, redundant slashes, and absolute URLs.
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    // If it's already a full URL, return it as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Clean up base URL and path to avoid double slashes or missing slashes
    String base = imageUrl;
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    String cleanPath = path;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // Some records might mistakenly include the full storage path in the database
    // e.g. "public/storage/uploads/img.jpg"
    // If the base URL already ends with "public/storage", we should probably remove it from the path
    if (base.contains('public/storage') && cleanPath.startsWith('public/storage/')) {
        cleanPath = cleanPath.replaceFirst('public/storage/', '');
    } else if (base.endsWith('storage') && cleanPath.startsWith('storage/')) {
        cleanPath = cleanPath.replaceFirst('storage/', '');
    }

    return '$base/$cleanPath';
  }
}
