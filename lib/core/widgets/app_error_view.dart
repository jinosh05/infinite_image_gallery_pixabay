// Path: core/widgets/app_error_view.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_typography.dart";
import "package:infinite_image_gallery_pixabay/core/config/space.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";

/// Full-screen / inline error with retry. Used by gallery, detail and
/// favorites screens so error handling looks identical everywhere.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    required this.onRetry,
    super.key,
    this.icon = Icons.broken_image_outlined,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Space.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56),
            Space.yf(1),
            Text(
              message,
              style: AppText.b1,
              textAlign: TextAlign.center,
            ),
            Space.yf(1.5),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(S.retry),
            ),
          ],
        ),
      ),
    );
  }
}
