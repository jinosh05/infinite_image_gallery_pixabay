// Path: test/features/gallery/presentation/bloc/gallery_bloc_test.dart
import "package:bloc_test/bloc_test.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_event.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_state.dart";
import "package:mocktail/mocktail.dart";

import "../../test_doubles.dart";

void main() {
  late MockGetPhotos mockGetPhotos;

  setUpAll(() {
    registerFallbackValue(const GalleryParams());
  });

  setUp(() {
    mockGetPhotos = MockGetPhotos();
  });

  GalleryBloc buildBloc() =>
      GalleryBloc(getPhotos: mockGetPhotos, perPage: 20);

  group("GalleryPageRequested", () {
    blocTest<GalleryBloc, GalleryState>(
      "emits loading then success tagged with the page key",
      build: () {
        stubGalleryPages(
          mockGetPhotos,
          <int, List<Photo>>{1: samplePhotos(6)},
          totalHits: 45,
        );
        return buildBloc();
      },
      act: (GalleryBloc bloc) => bloc.add(const GalleryPageRequested(1)),
      expect: () => <GalleryState>[
        const GalleryState(status: GalleryStatus.loading),
        GalleryState(
          status: GalleryStatus.success,
          pageItems: samplePhotos(6),
          resolvedPageKey: 1,
          totalHits: 45,
        ),
      ],
      verify: (_) {
        final List<GalleryParams> calls = galleryCalls(mockGetPhotos);
        expect(calls.single.page, 1);
        expect(calls.single.perPage, 20);
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      "passes current filters into params",
      build: () {
        stubGalleryPages(
          mockGetPhotos,
          <int, List<Photo>>{2: samplePhotos(2)},
          totalHits: 45,
        );
        return buildBloc();
      },
      seed: () => const GalleryState(query: "ocean", category: "nature"),
      act: (GalleryBloc bloc) => bloc.add(const GalleryPageRequested(2)),
      verify: (_) {
        final List<GalleryParams> calls = galleryCalls(mockGetPhotos);
        expect(calls.single.query, "ocean");
        expect(calls.single.category, "nature");
        expect(calls.single.page, 2);
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      "emits failure tagged with the page key",
      build: () {
        stubGalleryFailure(
          mockGetPhotos,
          const ServerFailure("boom"),
        );
        return buildBloc();
      },
      act: (GalleryBloc bloc) => bloc.add(const GalleryPageRequested(1)),
      expect: () => const <GalleryState>[
        GalleryState(status: GalleryStatus.loading),
        GalleryState(
          status: GalleryStatus.failure,
          resolvedPageKey: 1,
          errorMessage: "boom",
        ),
      ],
    );
  });

  group("GalleryQueryChanged", () {
    blocTest<GalleryBloc, GalleryState>(
      "resets paging state on new query",
      build: buildBloc,
      seed: () => GalleryState(
        status: GalleryStatus.success,
        pageItems: samplePhotos(6),
        resolvedPageKey: 1,
        totalHits: 45,
      ),
      act: (GalleryBloc bloc) =>
          bloc.add(const GalleryQueryChanged("ocean")),
      expect: () => const <GalleryState>[
        GalleryState(query: "ocean", status: GalleryStatus.initial),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      "ignores duplicate query",
      build: buildBloc,
      seed: () => const GalleryState(query: "ocean"),
      act: (GalleryBloc bloc) =>
          bloc.add(const GalleryQueryChanged("  ocean  ")),
      expect: () => <GalleryState>[],
    );
  });

  group("GalleryCategoryChanged", () {
    blocTest<GalleryBloc, GalleryState>(
      "resets paging state on new category",
      build: buildBloc,
      act: (GalleryBloc bloc) =>
          bloc.add(const GalleryCategoryChanged("nature")),
      expect: () => const <GalleryState>[
        GalleryState(category: "nature", status: GalleryStatus.initial),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      "ignores duplicate category",
      build: buildBloc,
      act: (GalleryBloc bloc) =>
          bloc.add(const GalleryCategoryChanged("all")),
      expect: () => <GalleryState>[],
    );
  });

  test("emits nothing initially", () {
    expect(buildBloc().state, const GalleryState());
  });
}
