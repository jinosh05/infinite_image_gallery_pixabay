// Path: features/favorites/domain/repositories/favorites_repository.dart
import "package:dartz/dartz.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

/// Result of a toggle: the new list + whether [photo] is now a favorite.
typedef ToggleResult = ({List<Photo> photos, bool isFavorite});

/// Domain contract for favorites (ISP: favorites only).
abstract class FavoritesRepository {
  Future<Either<Failure, List<Photo>>> getFavorites();
  Future<Either<Failure, ToggleResult>> toggleFavorite(Photo photo);
  Future<Either<Failure, List<Photo>>> clearFavorites();
}
