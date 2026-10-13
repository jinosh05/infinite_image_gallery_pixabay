// Path: features/favorites/data/repositories/favorites_repository_impl.dart
import "package:dartz/dartz.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/data/datasources/favorites_local_data_source.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/domain/repositories/favorites_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

/// [FavoritesRepository] over `SharedPreferences` (via the local data
/// source). Entities detach at the boundary via `toEntity`/`fromEntity` —
/// the domain never sees [PhotoModel].
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({required this.local});

  final FavoritesLocalDataSource local;

  @override
  Future<Either<Failure, List<Photo>>> getFavorites() async {
    try {
      final List<PhotoModel> models = await local.getFavorites();
      return Right<Failure, List<Photo>>(
        <Photo>[for (final PhotoModel m in models) m.toEntity()],
      );
    } on CacheException catch (e) {
      return Left<Failure, List<Photo>>(CacheFailure(e.message));
    } catch (_) {
      return const Left<Failure, List<Photo>>(
        CacheFailure("Could not load favorites."),
      );
    }
  }

  @override
  Future<Either<Failure, ToggleResult>> toggleFavorite(Photo photo) async {
    try {
      final List<PhotoModel> current = await local.getFavorites();
      final bool exists = current.any((PhotoModel m) => m.id == photo.id);
      final List<PhotoModel> updated = exists
          ? <PhotoModel>[
              for (final PhotoModel m in current)
                if (m.id != photo.id) m,
            ]
          : <PhotoModel>[...current, PhotoModel.fromEntity(photo)];
      await local.saveFavorites(updated);
      return Right<Failure, ToggleResult>((
        photos: <Photo>[for (final PhotoModel m in updated) m.toEntity()],
        isFavorite: !exists,
      ));
    } on CacheException catch (e) {
      return Left<Failure, ToggleResult>(CacheFailure(e.message));
    } catch (_) {
      return const Left<Failure, ToggleResult>(
        CacheFailure("Could not save favorites."),
      );
    }
  }

  @override
  Future<Either<Failure, List<Photo>>> clearFavorites() async {
    try {
      await local.saveFavorites(<PhotoModel>[]);
      return const Right<Failure, List<Photo>>(<Photo>[]);
    } on CacheException catch (e) {
      return Left<Failure, List<Photo>>(CacheFailure(e.message));
    } catch (_) {
      return const Left<Failure, List<Photo>>(
        CacheFailure("Could not clear favorites."),
      );
    }
  }
}
