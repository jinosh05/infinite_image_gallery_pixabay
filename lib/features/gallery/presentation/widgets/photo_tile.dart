// Path: features/gallery/presentation/widgets/photo_tile.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/utils/format_utils.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/appimage.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

/// One gallery cell: Hero image + stats overlay.
///
/// [aspectRatio] is set in masonry mode (natural photo proportions) and left
/// null in grid mode (the cell constraints size the tile).
/// The favorite button only renders when [onFavoriteToggle] is provided —
/// Phase 4 wires it to `FavoritesBloc`; until then no dead button is shown.
class PhotoTile extends StatelessWidget {
  const PhotoTile({
    required this.photo,
    required this.onTap,
    super.key,
    this.aspectRatio,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final Photo photo;
  final VoidCallback onTap;
  final double? aspectRatio;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  String get heroTag => "photo-${photo.id}";

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    Widget content = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Hero(
          tag: heroTag,
          child: AppImage(
            imageUrl: photo.webformatURL,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Bottom gradient + stats.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.favorite, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  compactCount(photo.likes),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.visibility, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  compactCount(photo.views),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        if (onFavoriteToggle != null)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              tooltip: isFavorite
                  ? "Remove from favorites"
                  : "Add to favorites",
              onPressed: onFavoriteToggle,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isFavorite ? scheme.secondary : Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                minimumSize: const Size(32, 32),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );

    if (aspectRatio != null) {
      content = AspectRatio(aspectRatio: aspectRatio!, child: content);
    }

    return GestureDetector(onTap: onTap, child: content);
  }
}
