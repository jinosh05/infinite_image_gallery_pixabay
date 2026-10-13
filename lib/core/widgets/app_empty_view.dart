// Path: core/widgets/app_empty_view.dart
import "package:flutter/material.dart";
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
    return Center(
      child: Padding(
        padding: Space.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56),
            Space.yf(1),
            Text(message, style: AppText.h4b, textAlign: TextAlign.center),
            Space.yf(0.5),
            Text(hint, style: AppText.b2, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
