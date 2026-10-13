// Path: test/features/gallery/data/repositories/gallery_repository_impl_test.dart
import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/core/utils/network_check.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/datasources/gallery_remote_data_source.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_page_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/repositories/gallery_repository_impl.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo_page.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:mocktail/mocktail.dart";

import "../../gallery_fixtures.dart";

class MockRemote extends Mock implements GalleryRemoteDataSource {}

class MockNetworkCheck extends Mock implements NetworkCheck {}

void main() {
  late MockRemote mockRemote;
  late MockNetworkCheck mockNetwork;
  late GalleryRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const GalleryParams());
  });

  setUp(() {
    mockRemote = MockRemote();
    mockNetwork = MockNetworkCheck();
    repository =
        GalleryRepositoryImpl(remote: mockRemote, networkCheck: mockNetwork);
  });

  PhotoPageModel sampleModel() => PhotoPageModel(
        photos: <PhotoModel>[
          PhotoModel.fromJson(sampleHitJson(id: 1)),
          PhotoModel.fromJson(sampleHitJson(id: 2)),
        ],
        totalHits: 45,
        page: 1,
        perPage: 20,
      );

  void stubOnline() {
    when(() => mockNetwork.check()).thenAnswer((_) async => true);
  }

  group("getPhotos", () {
    test("returns entities on success (models detached at boundary)",
        () async {
      stubOnline();
      when(() => mockRemote.fetchPhotos(any()))
          .thenAnswer((_) async => sampleModel());

      final Either<Failure, PhotoPage> result =
          await repository.getPhotos(const GalleryParams());

      expect(result.isRight(), isTrue);
      final PhotoPage page = result.getOrElse(() => throw StateError("Left"));
      expect(page.photos, hasLength(2));
      expect(page.photos.any((p) => p is PhotoModel), isFalse);
      expect(page.totalHits, 45);
    });

    test("short-circuits to NetworkFailure offline (remote never called)",
        () async {
      when(() => mockNetwork.check()).thenAnswer((_) async => false);

      final Either<Failure, PhotoPage> result =
          await repository.getPhotos(const GalleryParams());

      expect(result, const Left<Failure, PhotoPage>(NetworkFailure()));
      verifyNever(() => mockRemote.fetchPhotos(any()));
    });

    test("UnauthorizedException maps to UnauthorizedFailure", () async {
      stubOnline();
      when(() => mockRemote.fetchPhotos(any()))
          .thenThrow(const UnauthorizedException("bad key"));

      final Either<Failure, PhotoPage> result =
          await repository.getPhotos(const GalleryParams());

      expect(
        result,
        const Left<Failure, PhotoPage>(UnauthorizedFailure("bad key")),
      );
    });

    test("NetworkException maps to NetworkFailure", () async {
      stubOnline();
      when(() => mockRemote.fetchPhotos(any()))
          .thenThrow(const NetworkException());

      final Either<Failure, PhotoPage> result =
          await repository.getPhotos(const GalleryParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (Failure f) => expect(f, isA<NetworkFailure>()),
        (_) => fail("expected Left"),
      );
    });

    test("ServerException maps to ServerFailure", () async {
      stubOnline();
      when(() => mockRemote.fetchPhotos(any()))
          .thenThrow(const ServerException("boom"));

      final Either<Failure, PhotoPage> result =
          await repository.getPhotos(const GalleryParams());

      expect(
        result,
        const Left<Failure, PhotoPage>(ServerFailure("boom")),
      );
    });

    test("unexpected errors map to UnknownFailure", () async {
      stubOnline();
      when(() => mockRemote.fetchPhotos(any())).thenThrow(StateError("?!"));

      final Either<Failure, PhotoPage> result =
          await repository.getPhotos(const GalleryParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (Failure f) => expect(f, isA<UnknownFailure>()),
        (_) => fail("expected Left"),
      );
    });
  });
}
