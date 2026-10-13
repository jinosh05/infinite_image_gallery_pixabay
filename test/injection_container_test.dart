// Path: test/injection_container_test.dart
import "package:dio/dio.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/utils/network_check.dart";
import "package:infinite_image_gallery_pixabay/features/detail/data/services/image_download_service.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/cubit/download_cubit.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/datasources/gallery_remote_data_source.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/use_cases/get_photos.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_bloc.dart";
import "package:infinite_image_gallery_pixabay/injection_container.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  setUp(() {
    dotenv.loadFromString(envString: "PIXABAY_API_KEY=TEST_KEY");
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

  test("gallery bloc is a factory (fresh instance per page)", () async {
    await initDependencies();

    expect(sl<GalleryBloc>(), isNotNull);
    expect(identical(sl<GalleryBloc>(), sl<GalleryBloc>()), isFalse);
  });

  test("resolves the detail download graph", () async {
    await initDependencies();

    expect(sl<ImageDownloadService>(), isNotNull);
    expect(sl<DownloadCubit>(), isNotNull);
    expect(identical(sl<DownloadCubit>(), sl<DownloadCubit>()), isFalse);
  });
}
