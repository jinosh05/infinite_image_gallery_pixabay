// Path: core/widgets/app_empty_view.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_dimensions.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_typography.dart";
import "package:infinite_image_gallery_pixabay/core/config/space.dart";

/// Empty-state illustration + message. One widget for gallery-empty and
/// favorites-empty (only copy differs — DRY).
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.message,
    required this.hint,
    super.key,
    this.icon = Icons.photo_library_outlined,
  });

  final String message;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Null-safe before bootstrap (see Tools.showSnackBar): tests and
    // ultra-early calls fall back to constants instead of crashing.
    final bool metricsReady = AppDimensions.padding != null;
    return Center(
      child: Padding(
        padding:
            metricsReady ? Space.all(2) : const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56),
            metricsReady ? Space.yf(1) : const SizedBox(height: 8),
            Text(message, style: AppText.h4b, textAlign: TextAlign.center),
            metricsReady ? Space.yf(0.5) : const SizedBox(height: 4),
            Text(hint, style: AppText.b2, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
