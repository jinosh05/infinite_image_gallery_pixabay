// Path: lib/injection_container.dart
import "package:dio/dio.dart";
import "package:get_it/get_it.dart";
import "package:infinite_image_gallery_pixabay/core/config/env_config.dart";
import "package:infinite_image_gallery_pixabay/core/network/dio_client.dart";
import "package:infinite_image_gallery_pixabay/core/utils/network_check.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/datasources/gallery_remote_data_source.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/repositories/gallery_repository_impl.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:infinite_image_gallery_pixabay/features/detail/data/services/image_download_service.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/cubit/download_cubit.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/use_cases/get_photos.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Global service locator. Call [initDependencies] once in `main()` before
/// `runApp` — presentation (Blocs) then reads use cases via `sl<T>()`
/// instead of constructing the object graph by hand (DIP: UI depends on
/// abstractions, composition root wires concretes).
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---- Core (singletons: stateless + shared) ----
  sl.registerLazySingleton<Dio>(() => DioClient.instance);
  sl.registerLazySingleton<NetworkCheck>(NetworkCheck.new);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingleton<SharedPreferences>(prefs);
  }

  // ---- Gallery feature (Phase 1; detail/favorites/theme extend this) ----
  sl.registerLazySingleton<GalleryRemoteDataSource>(
    () => GalleryRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<GalleryRepository>(
    () => GalleryRepositoryImpl(
      remote: sl<GalleryRemoteDataSource>(),
      networkCheck: sl<NetworkCheck>(),
    ),
  );
  sl.registerLazySingleton<GetPhotos>(() => GetPhotos(sl<GalleryRepository>()));

  // Factory: GalleryPage owns its Bloc instance (disposed with the page).
  sl.registerFactory<GalleryBloc>(
    () => GalleryBloc(
      getPhotos: sl<GetPhotos>(),
      perPage: EnvConfig.defaultPerPage,
    ),
  );

  // ---- Detail feature (Phase 3) ----
  sl.registerLazySingleton<ImageDownloadService>(
    () => ImageDownloadServiceImpl(dio: sl<Dio>()),
  );
  // Factory: DetailPage owns its Cubit instance (disposed with the page).
  sl.registerFactory<DownloadCubit>(
    () => DownloadCubit(service: sl<ImageDownloadService>()),
  );
}
