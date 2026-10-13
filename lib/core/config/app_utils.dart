// Path: core/config/app_utils.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_typography.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";

/// [AppUtils] contains app-wide UI helpers (dialogs, confirmations).
/// Snackbars/toasts live in [Tools] — this file stays dialog-focused (SRP).
class AppUtils {
  /// Shows a simple OK dialog. Returns when dismissed.
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String okLabel = S.ok,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title, style: AppText.b1b),
        content: Text(message, style: AppText.b2),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  /// Shows a confirm/cancel dialog. Returns true when confirmed.
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = S.ok,
    String cancelLabel = S.cancel,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title, style: AppText.b1b),
        content: Text(message, style: AppText.b2),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
