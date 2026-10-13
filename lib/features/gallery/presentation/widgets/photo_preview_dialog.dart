// Path: features/gallery/presentation/widgets/photo_preview_dialog.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/appimage.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

/// Interim full-screen preview (pinch-zoom) behind the same Hero tag.
/// Phase 3 replaces this call site with `DetailPage`; the tile's `onTap`
/// seam stays unchanged.
class PhotoPreviewDialog extends StatelessWidget {
  const PhotoPreviewDialog({required this.photo, super.key});

  final Photo photo;

  static Future<void> show(BuildContext context, Photo photo) =>
      showDialog<void>(
        context: context,
        barrierColor: Colors.black87,
        builder: (_) => PhotoPreviewDialog(photo: photo),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Center(
            child: Hero(
              tag: "photo-${photo.id}",
              child: InteractiveViewer(
                child: AppImage(
                  imageUrl: photo.detailImageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
