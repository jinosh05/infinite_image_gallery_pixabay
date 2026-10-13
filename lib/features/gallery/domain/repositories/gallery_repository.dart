// Path: features/gallery/domain/repositories/gallery_repository.dart
import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo_page.dart";

/// Query parameters for one gallery page fetch.
/// Lives beside the contract (not in the use-case file) so data layer and
/// use cases share one definition without import cycles.
class GalleryParams extends Equatable {
  const GalleryParams({
    this.query = "",
    this.category = "all",
    this.page = 1,
    this.perPage = 20,
    this.order = "popular",
  });

  final String query;
  final String category;
  final int page;
  final int perPage;
  final String order;

  @override
  List<Object?> get props => <Object?>[query, category, page, perPage, order];
}

/// Domain contract for gallery fetching (ISP: fetching only — favorites and
/// downloads have their own contracts in their features).
abstract class GalleryRepository {
  Future<Either<Failure, PhotoPage>> getPhotos(GalleryParams params);
}
