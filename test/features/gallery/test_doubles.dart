// Shared doubles + stub helpers for gallery presentation tests.
import "package:dartz/dartz.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/features/detail/data/services/image_download_service.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/data/datasources/favorites_local_data_source.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/domain/repositories/favorites_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo_page.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/use_cases/get_photos.dart";
import "package:infinite_image_gallery_pixabay/features/theme/presentation/bloc/theme_cubit.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";

import "gallery_fixtures.dart";

class MockGetPhotos extends Mock implements GetPhotos {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockFavoritesLocalDataSource extends Mock
    implements FavoritesLocalDataSource {}

/// Stand-in download service so pages can resolve their cubit via sl
/// without touching platform plugins. Real download behavior is covered
/// in detail_page_test.dart with a mocked service.
class NoopImageDownloadService implements ImageDownloadService {
  @override
  Future<String> downloadToGallery(
    String imageUrl, {
    required void Function(double) onProgress,
    String? fileName,
  }) async =>
      "noop.jpg";
}

/// Fresh [ThemeCubit] backed by mock prefs (each call resets the store).
Future<ThemeCubit> createTestThemeCubit({String? seedMode}) async {
  SharedPreferences.setMockInitialValues(
    seedMode == null
        ? <String, Object>{}
        : <String, Object>{ThemeCubit.storageKey: seedMode},
  );
  return ThemeCubit(prefs: await SharedPreferences.getInstance());
}

List<Photo> samplePhotos(int count, {int startId = 1}) =>
    List<Photo>.generate(
      count,
      (int i) =>
          PhotoModel.fromJson(sampleHitJson(id: startId + i)).toEntity(),
    );

/// Stubs [mock] to serve [pages] by 1-based page key; unknown pages return
/// an empty page (signals end-of-list). [totalHits] is echoed on every page.
void stubGalleryPages(
  MockGetPhotos mock,
  Map<int, List<Photo>> pages, {
  required int totalHits,
}) {
  when(() => mock(any())).thenAnswer((Invocation inv) async {
    final GalleryParams params =
        inv.positionalArguments.single as GalleryParams;
    final List<Photo>? photos = pages[params.page];
    if (photos == null) {
      return Right<Failure, PhotoPage>(
        PhotoPage(
          photos: const <Photo>[],
          totalHits: totalHits,
          page: params.page,
          perPage: params.perPage,
        ),
      );
    }
    return Right<Failure, PhotoPage>(
      PhotoPage(
        photos: photos,
        totalHits: totalHits,
        page: params.page,
        perPage: params.perPage,
      ),
    );
  });
}

void stubGalleryFailure(MockGetPhotos mock, Failure failure) {
  when(() => mock(any()))
      .thenAnswer((_) async => Left<Failure, PhotoPage>(failure));
}

List<GalleryParams> galleryCalls(MockGetPhotos mock) =>
    verify(() => mock(captureAny()))
        .captured
        .map((dynamic c) => c as GalleryParams)
        .toList();
