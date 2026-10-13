// Path: features/gallery/domain/use_cases/get_photos.dart
import "package:dartz/dartz.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo_page.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";

/// Thin application-business-rule wrapper around [GalleryRepository].
/// Keeps the Bloc dependent on a use case (DIP) rather than the repository
/// directly, so paging/filter orchestration stays out of the UI layer.
class GetPhotos {
  GetPhotos(this._repository);

  final GalleryRepository _repository;

  Future<Either<Failure, PhotoPage>> call(GalleryParams params) =>
      _repository.getPhotos(params);
}
