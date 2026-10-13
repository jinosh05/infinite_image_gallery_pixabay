// Path: test/features/favorites/presentation/pages/favorites_page_test.dart
import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_empty_view.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_error_view.dart";
import "package:infinite_image_gallery_pixabay/features/detail/data/services/image_download_service.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/cubit/download_cubit.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/pages/detail_page.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/domain/repositories/favorites_repository.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_event.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/pages/favorites_page.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/widgets/photo_tile.dart";
import "package:infinite_image_gallery_pixabay/features/theme/presentation/bloc/theme_cubit.dart";
import "package:infinite_image_gallery_pixabay/injection_container.dart";
import "package:mocktail/mocktail.dart";

import "../../../gallery/gallery_fixtures.dart";
import "../../../gallery/test_doubles.dart";

Future<void> pumpFrames(
  WidgetTester tester, {
  int count = 8,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (int i = 0; i < count; i++) {
    await tester.pump(step);
  }
}

void main() {
  late MockFavoritesRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      PhotoModel.fromJson(sampleHitJson()).toEntity(),
    );
  });

  setUp(() {
    mockRepository = MockFavoritesRepository();
    // DetailPage resolves its cubit via sl on tile tap.
    sl.registerLazySingleton<ImageDownloadService>(
      () => NoopImageDownloadService(),
    );
    sl.registerFactory<DownloadCubit>(
      () => DownloadCubit(service: sl<ImageDownloadService>()),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Photo samplePhoto({int id = 1}) =>
      PhotoModel.fromJson(sampleHitJson(id: id)).toEntity();

  Future<void> pumpFavorites(WidgetTester tester) async {
    final ThemeCubit themeCubit = await createTestThemeCubit();
    await tester.pumpWidget(
      BlocProvider<FavoritesBloc>(
        create: (_) => FavoritesBloc(repository: mockRepository)
          ..add(const FavoritesStarted()),
        child: BlocProvider<ThemeCubit>.value(
          value: themeCubit,
          child: const MaterialApp(home: FavoritesPage()),
        ),
      ),
    );
    await pumpFrames(tester);
  }

  group("FavoritesPage", () {
    testWidgets("shows empty state when nothing saved",
        (WidgetTester tester) async {
      when(() => mockRepository.getFavorites()).thenAnswer(
        (_) async => const Right<Failure, List<Photo>>(<Photo>[]),
      );

      await pumpFavorites(tester);

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text(S.emptyFavorites), findsOneWidget);
      expect(find.byIcon(Icons.delete_sweep_outlined), findsNothing);
    });

    testWidgets("renders saved photos with live hearts",
        (WidgetTester tester) async {
      when(() => mockRepository.getFavorites()).thenAnswer(
        (_) async => Right<Failure, List<Photo>>(
          <Photo>[samplePhoto(id: 1), samplePhoto(id: 2)],
        ),
      );
      when(() => mockRepository.toggleFavorite(any())).thenAnswer(
        (_) async => Right<Failure, ToggleResult>((
          photos: <Photo>[samplePhoto(id: 2)],
          isFavorite: false,
        )),
      );

      await pumpFavorites(tester);

      expect(find.byType(PhotoTile), findsWidgets);
      expect(find.byIcon(Icons.delete_sweep_outlined), findsOneWidget);

      // Unfavorite inline → repository toggle fires.
      await tester.tap(find.byTooltip("Remove from favorites").first);
      await pumpFrames(tester);

      verify(() => mockRepository.toggleFavorite(any())).called(1);
    });

    testWidgets("tile tap opens the detail page",
        (WidgetTester tester) async {
      when(() => mockRepository.getFavorites()).thenAnswer(
        (_) async => Right<Failure, List<Photo>>(
          <Photo>[samplePhoto(id: 1)],
        ),
      );

      await pumpFavorites(tester);
      await tester.tap(find.byType(PhotoTile).first);
      await pumpFrames(tester, count: 10);

      expect(find.byType(DetailPage), findsOneWidget);
    });

    testWidgets("clear-all asks first, then clears",
        (WidgetTester tester) async {
      when(() => mockRepository.getFavorites()).thenAnswer(
        (_) async => Right<Failure, List<Photo>>(
          <Photo>[samplePhoto(id: 1)],
        ),
      );
      when(() => mockRepository.clearFavorites()).thenAnswer(
        (_) async => const Right<Failure, List<Photo>>(<Photo>[]),
      );

      await pumpFavorites(tester);
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await pumpFrames(tester, count: 4);

      // Confirm dialog, no clearing yet.
      expect(find.text("Clear favorites?"), findsOneWidget);
      verifyNever(() => mockRepository.clearFavorites());

      await tester.tap(find.text("Clear"));
      await pumpFrames(tester);

      verify(() => mockRepository.clearFavorites()).called(1);
      expect(find.text(S.favoritesCleared), findsOneWidget);
    });

    testWidgets("load failure shows error with retry",
        (WidgetTester tester) async {
      when(() => mockRepository.getFavorites()).thenAnswer(
        (_) async => const Left<Failure, List<Photo>>(
          CacheFailure("disk gone"),
        ),
      );

      await pumpFavorites(tester);

      // Bloc maps to failure state; page shows error + retry.
      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text("disk gone"), findsOneWidget);
    });
  });
}
