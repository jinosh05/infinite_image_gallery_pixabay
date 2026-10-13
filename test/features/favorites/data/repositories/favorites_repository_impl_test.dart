// Path: test/features/favorites/data/repositories/favorites_repository_impl_test.dart
import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/data/repositories/favorites_repository_impl.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/domain/repositories/favorites_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:mocktail/mocktail.dart";

import "../../../gallery/gallery_fixtures.dart";
import "../../../gallery/test_doubles.dart";

void main() {
  late MockFavoritesLocalDataSource mockLocal;
  late FavoritesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<PhotoModel>[]);
  });

  setUp(() {
    mockLocal = MockFavoritesLocalDataSource();
    repository = FavoritesRepositoryImpl(local: mockLocal);
  });

  PhotoModel model({int id = 1}) =>
      PhotoModel.fromJson(sampleHitJson(id: id));

  group("getFavorites", () {
    test("detaches entities at the boundary", () async {
      when(() => mockLocal.getFavorites()).thenAnswer(
        (_) async => <PhotoModel>[model(id: 1)],
      );

      final Either<Failure, List<Photo>> result =
          await repository.getFavorites();

      expect(result.isRight(), isTrue);
      final List<Photo> photos =
          result.getOrElse(() => throw StateError("Left"));
      expect(photos.single.id, 1);
      expect(photos.any((p) => p is PhotoModel), isFalse);
    });

    test("maps storage errors to CacheFailure", () async {
      when(() => mockLocal.getFavorites())
          .thenThrow(const CacheException("disk gone"));

      final Either<Failure, List<Photo>> result =
          await repository.getFavorites();

      expect(
        result,
        const Left<Failure, List<Photo>>(CacheFailure("disk gone")),
      );
    });
  });

  group("toggleFavorite", () {
    test("adds a missing photo and reports isFavorite true", () async {
      when(() => mockLocal.getFavorites())
          .thenAnswer((_) async => <PhotoModel>[]);
      when(() => mockLocal.saveFavorites(any())).thenAnswer((_) async {});

      final Either<Failure, ToggleResult> result = await repository
          .toggleFavorite(model(id: 7).toEntity());

      expect(result.isRight(), isTrue);
      final ToggleResult toggle =
          result.getOrElse(() => throw StateError("Left"));
      expect(toggle.isFavorite, isTrue);
      expect(toggle.photos.map((p) => p.id), <int>[7]);
      verify(() => mockLocal.saveFavorites(any())).called(1);
    });

    test("removes an existing photo and reports isFavorite false", () async {
      when(() => mockLocal.getFavorites()).thenAnswer(
        (_) async => <PhotoModel>[model(id: 1), model(id: 2)],
      );
      when(() => mockLocal.saveFavorites(any())).thenAnswer((_) async {});

      final Either<Failure, ToggleResult> result = await repository
          .toggleFavorite(model(id: 1).toEntity());

      final ToggleResult toggle =
          result.getOrElse(() => throw StateError("Left"));
      expect(toggle.isFavorite, isFalse);
      expect(toggle.photos.map((p) => p.id), <int>[2]);
    });

    test("maps save errors to CacheFailure", () async {
      when(() => mockLocal.getFavorites())
          .thenAnswer((_) async => <PhotoModel>[]);
      when(() => mockLocal.saveFavorites(any()))
          .thenThrow(const CacheException("read-only"));

      final Either<Failure, ToggleResult> result = await repository
          .toggleFavorite(model(id: 1).toEntity());

      expect(result.isLeft(), isTrue);
    });
  });

  group("clearFavorites", () {
    test("saves empty and returns empty list", () async {
      when(() => mockLocal.saveFavorites(any())).thenAnswer((_) async {});

      final Either<Failure, List<Photo>> result =
          await repository.clearFavorites();

      expect(result, const Right<Failure, List<Photo>>(<Photo>[]));
      verify(() => mockLocal.saveFavorites(any())).called(1);
    });
  });
}
