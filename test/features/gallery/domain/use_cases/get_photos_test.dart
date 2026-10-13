// Path: test/features/gallery/domain/use_cases/get_photos_test.dart
import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo_page.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/use_cases/get_photos.dart";
import "package:mocktail/mocktail.dart";

class MockGalleryRepository extends Mock implements GalleryRepository {}

void main() {
  late MockGalleryRepository mockRepository;
  late GetPhotos useCase;

  setUpAll(() {
    registerFallbackValue(const GalleryParams());
  });

  setUp(() {
    mockRepository = MockGalleryRepository();
    useCase = GetPhotos(mockRepository);
  });

  const GalleryParams params =
      GalleryParams(query: "ocean", category: "nature", page: 2);
  const PhotoPage page =
      PhotoPage(photos: [], totalHits: 0, page: 2, perPage: 20);

  test("passes params through and returns the repository result", () async {
    when(() => mockRepository.getPhotos(any())).thenAnswer(
      (_) async => const Right<Failure, PhotoPage>(page),
    );

    final Either<Failure, PhotoPage> result = await useCase(params);

    expect(result, const Right<Failure, PhotoPage>(page));
    verify(() => mockRepository.getPhotos(params)).called(1);
  });
}
