// Path: core/utils/tools.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_dimensions.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_typography.dart";
import "package:infinite_image_gallery_pixabay/core/config/space.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_colors.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";

/// App-wide UI helpers: snackbars + share.
///
/// Migrated from the jigsaw version — game/analytics/version-check code
/// removed. SRP: user feedback + system share only. Download + permission
/// logic lives in the gallery feature (data layer), not here.
class Tools {
  Tools._();

  /// Reusable SnackBar — use everywhere instead of
  /// `ScaffoldMessenger.of(context).showSnackBar` directly.
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    SnackBarAction? action,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    IconData? icon,
  }) {
    // Core metrics may be unavailable in unit/widget tests (or ultra-early
    // calls before bootstrap) — fall back to constants instead of crashing.
    final bool metricsReady = AppDimensions.padding != null;
    final ShapeBorder effectiveShape = shape ??
        RoundedRectangleBorder(
          borderRadius: metricsReady
              ? AppDimensions.borRadius(3)
              : BorderRadius.circular(12),
        );
    final EdgeInsetsGeometry effectiveMargin =
        margin ?? (metricsReady ? Space.all(1.5) : const EdgeInsets.all(12));
    final EdgeInsetsGeometry effectivePadding =
        padding ?? (metricsReady ? Space.all(1) : const EdgeInsets.all(12));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: icon == null
            ? Text(
                message,
                style: textColor != null
                    ? AppText.b2?.cl(textColor)
                    : AppText.b2b,
              )
            : Row(
                children: <Widget>[
                  Icon(icon, size: 20, color: textColor ?? AppColors.gold),
                  metricsReady
                      ? Space.xf(0.75)
                      : const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message,
                      style: textColor != null
                          ? AppText.b2?.cl(textColor)
                          : AppText.b2b,
                    ),
                  ),
                ],
              ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: behavior,
        action: action,
        shape: effectiveShape,
        margin: effectiveMargin,
        padding: effectivePadding,
      ),
    );
  }

  /// Success variant (green).
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  /// Error variant (red).
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  /// Info variant.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  /// Shows a [Failure]'s message as an error snackbar.
  static void showFailure(BuildContext context, Failure failure) {
    showError(context, failure.message);
  }
}
