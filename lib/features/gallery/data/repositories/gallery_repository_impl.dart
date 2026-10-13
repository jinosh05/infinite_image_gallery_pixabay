// Path: features/gallery/data/repositories/gallery_repository_impl.dart
import "package:dartz/dartz.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/core/utils/network_check.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/datasources/gallery_remote_data_source.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_page_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo_page.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";

/// [GalleryRepository] implementation: offline-first, exception→failure
/// mapping at the boundary so no exception ever leaks to the UI (OCP: new
/// failure kinds extend [Failure] without touching callers).
class GalleryRepositoryImpl implements GalleryRepository {
  GalleryRepositoryImpl({required this.remote, required this.networkCheck});

  final GalleryRemoteDataSource remote;
  final NetworkCheck networkCheck;

  @override
  Future<Either<Failure, PhotoPage>> getPhotos(GalleryParams params) async {
    if (!await networkCheck.check()) {
      return const Left<Failure, PhotoPage>(NetworkFailure());
    }
    try {
      final PhotoPageModel result = await remote.fetchPhotos(params);
      return Right<Failure, PhotoPage>(result.toEntity());
    } on UnauthorizedException catch (e) {
      return Left<Failure, PhotoPage>(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left<Failure, PhotoPage>(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left<Failure, PhotoPage>(ServerFailure(e.message));
    } catch (_) {
      return const Left<Failure, PhotoPage>(UnknownFailure());
    }
  }
}
