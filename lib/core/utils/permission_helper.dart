// Path: core/utils/permission_helper.dart
import "dart:io";

import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/foundation.dart";
import "package:permission_handler/permission_handler.dart";

/// Central permission gateway for gallery-save (SRP: one place for the
/// Android SDK-version matrix + iOS photo-library rules).
///
/// Rules encoded:
/// - Android ≤ 12 (SDK ≤ 32): [Permission.storage] (needs manifest + runtime).
/// - Android 13+ (SDK ≥ 33): images use [Permission.photos]; no broad
///   storage permission needed for MediaStore inserts via
///   `image_gallery_saver_plus`.
/// - iOS: [Permission.photosAddOnly] suffices for saving (add-only, not full
///   library read). Falls back to [Permission.photos] where add-only is
///   unavailable.
/// - Web/desktop: no runtime permission — returns true.
class PermissionHelper {
  PermissionHelper._();

  static Future<bool> ensureSavePermission() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return true;

    if (Platform.isAndroid) {
      final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 33) {
        return _request(Permission.photos);
      }
      return _request(Permission.storage);
    }

    // iOS
    if (await _request(Permission.photosAddOnly)) return true;
    return _request(Permission.photos);
  }

  static Future<bool> _request(Permission permission) async {
    if (await permission.isGranted || await permission.isLimited) return true;
    final PermissionStatus status = await permission.request();
    return status.isGranted || status.isLimited;
  }
}
