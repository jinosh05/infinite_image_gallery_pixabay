// Path: features/detail/data/services/image_download_service.dart
import "dart:io";

import "package:dio/dio.dart";
import "package:image_gallery_saver_plus/image_gallery_saver_plus.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/core/network/dio_client.dart";
import "package:infinite_image_gallery_pixabay/core/utils/permission_helper.dart";
import "package:path_provider/path_provider.dart";

/// Device-side download contract (ISP: gallery-saving only — sharing and
/// favorites have their own paths). Returns the saved file path/name.
abstract class ImageDownloadService {
  Future<String> downloadToGallery(
    String imageUrl, {
    required void Function(double progress) onProgress,
    String? fileName,
  });
}

class ImageDownloadServiceImpl implements ImageDownloadService {
  /// [dio] defaults to the app singleton but is injectable (DIP: tests and
  /// future callers never touch [DioClient] directly).
  ImageDownloadServiceImpl({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  @override
  Future<String> downloadToGallery(
    String imageUrl, {
    required void Function(double progress) onProgress,
    String? fileName,
  }) async {
    if (imageUrl.isEmpty) {
      throw const DownloadException("Image URL is missing.");
    }

    final bool granted = await PermissionHelper.ensureSavePermission();
    if (!granted) {
      throw const PermissionException();
    }

    final Directory tmp = await getTemporaryDirectory();
    final String safeName =
        (fileName ?? "pixabay_${DateTime.now().millisecondsSinceEpoch}")
            .replaceAll(RegExp(r"[^\w\-]+"), "_");
    final String savePath = "${tmp.path}/$safeName.jpg";

    try {
      await _dio.download(
        imageUrl,
        savePath,
        onReceiveProgress: (int received, int total) {
          if (total > 0) onProgress(received / total);
        },
      );
    } on DioException {
      throw const DownloadException(
        "Download failed. Check your connection and try again.",
      );
    }

    dynamic result;
    try {
      result = await ImageGallerySaverPlus.saveFile(savePath, name: safeName);
    } catch (_) {
      throw const DownloadException(
        "Could not save to gallery. Please try again.",
      );
    }
    // Plugin contract: {"isSuccess": true, "filePath": ...} (map), true, or
    // a path string depending on platform/version — accept all truthy forms.
    final bool ok = result == true ||
        (result is Map && result["isSuccess"] == true) ||
        (result is String && result.isNotEmpty);
    if (!ok) {
      throw const DownloadException(
        "Could not save to gallery. Please try again.",
      );
    }
    if (result is Map && result["filePath"] is String) {
      return result["filePath"] as String;
    }
    return safeName;
  }
}
