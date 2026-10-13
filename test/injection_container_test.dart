// Path: test/injection_container_test.dart
import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/utils/network_check.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/datasources/gallery_remote_data_source.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/use_cases/get_photos.dart";
import "package:infinite_image_gallery_pixabay/injection_container.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() async {
    await sl.reset();
  });

  test("resolves the full Phase 1 object graph from get_it", () async {
    await initDependencies();

    expect(sl<Dio>(), isNotNull);
    expect(sl<NetworkCheck>(), isNotNull);
    expect(sl<SharedPreferences>(), isNotNull);
    expect(sl<GalleryRemoteDataSource>(), isNotNull);
    expect(sl<GalleryRepository>(), isNotNull);
    expect(sl<GetPhotos>(), isNotNull);
  });

  test("core dependencies are singletons", () async {
    await initDependencies();

    expect(identical(sl<Dio>(), sl<Dio>()), isTrue);
    expect(
      identical(
        sl<GalleryRepository>(),
        sl<GalleryRepository>(),
      ),
      isTrue,
    );
  });
}
