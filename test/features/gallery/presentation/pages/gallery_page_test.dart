// Path: test/features/gallery/presentation/pages/gallery_page_test.dart
import "package:custom_masonry_grid/custom_masonry_grid.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/config/app.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_empty_view.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_error_view.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/pages/gallery_page.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/widgets/photo_tile.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:mocktail/mocktail.dart";

import "../../test_doubles.dart";

/// Why fixed pumps instead of pumpAndSettle: tile images load over HTTP and
/// the sandbox blackholes those connections, so shimmer placeholders spin
/// forever. All fetches are immediate mocked futures — ten 100 ms pumps are
/// ample and deterministic.
Future<void> pumpFrames(
  WidgetTester tester, {
  int count = 10,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (int i = 0; i < count; i++) {
    await tester.pump(step);
  }
}

void main() {
  late MockGetPhotos mockGetPhotos;

  setUpAll(() {
    registerFallbackValue(const GalleryParams());
  });

  setUp(() {
    mockGetPhotos = MockGetPhotos();
  });

  Future<void> pumpGallery(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<GalleryBloc>(
          create: (_) => GalleryBloc(getPhotos: mockGetPhotos, perPage: 20),
          child: const GalleryPage(),
        ),
      ),
    );
    await tester.pump();
    // Mirrors the production bootstrap contract (GalleryApp._Bootstrap):
    // responsive metrics must be initialized before core widgets build.
    App.init(tester.element(find.byType(GalleryPage)));
    await pumpFrames(tester);
  }

  group("GalleryPage grid", () {
    testWidgets("renders tiles from the first page", (WidgetTester tester) async {
      stubGalleryPages(
        mockGetPhotos,
        <int, List<Photo>>{1: samplePhotos(6)},
        totalHits: 6, // exact stop: no cascading fetches
      );

      await pumpGallery(tester);

      expect(find.text(S.galleryTitle), findsOneWidget);
      expect(find.byType(PhotoTile), findsWidgets);
      expect(find.byType(PagedGridView<int, Photo>), findsOneWidget);
    });

    testWidgets("loads the next page on scroll", (WidgetTester tester) async {
      stubGalleryPages(
        mockGetPhotos,
        <int, List<Photo>>{
          1: samplePhotos(6),
          2: samplePhotos(6, startId: 100),
        },
        totalHits: 45,
      );

      await pumpGallery(tester);
      await tester.drag(
        find.byType(PagedGridView<int, Photo>),
        const Offset(0, -3000),
      );
      await pumpFrames(tester);

      final List<int> pages =
          galleryCalls(mockGetPhotos).map((p) => p.page).toList();
      expect(pages, contains(2));
    });

    testWidgets("shows error with working retry", (WidgetTester tester) async {
      stubGalleryFailure(
        mockGetPhotos,
        const ServerFailure("bad server"),
      );

      await pumpGallery(tester);

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text("bad server"), findsOneWidget);

      await tester.tap(find.text(S.retry));
      await pumpFrames(tester);

      expect(galleryCalls(mockGetPhotos), hasLength(2));
    });

    testWidgets("shows empty state when no items", (WidgetTester tester) async {
      stubGalleryPages(
        mockGetPhotos,
        <int, List<Photo>>{1: <Photo>[]},
        totalHits: 0,
      );

      await pumpGallery(tester);

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text(S.emptyGallery), findsOneWidget);
    });
  });

  group("GalleryPage search + filter", () {
    testWidgets("debounced search refetches with the query",
        (WidgetTester tester) async {
      stubGalleryPages(
        mockGetPhotos,
        <int, List<Photo>>{1: samplePhotos(6)},
        totalHits: 6,
      );

      await pumpGallery(tester);
      await tester.enterText(find.byType(TextField), "ocean");
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      final calls = galleryCalls(mockGetPhotos);
      expect(calls.last.query, "ocean");
      expect(calls.last.page, 1);
    });

    testWidgets("category chip refetches with the category",
        (WidgetTester tester) async {
      stubGalleryPages(
        mockGetPhotos,
        <int, List<Photo>>{1: samplePhotos(6)},
        totalHits: 6,
      );

      await pumpGallery(tester);
      await tester.tap(find.text("Nature"));
      await pumpFrames(tester);

      final calls = galleryCalls(mockGetPhotos);
      expect(calls.last.category, "nature");
      expect(calls.last.page, 1);
    });
  });

  group("GalleryPage masonry + preview", () {
    testWidgets("toggles to masonry layout", (WidgetTester tester) async {
      stubGalleryPages(
        mockGetPhotos,
        <int, List<Photo>>{1: samplePhotos(6)},
        totalHits: 6,
      );

      await pumpGallery(tester);
      await tester.tap(find.byIcon(Icons.dashboard_outlined));
      await pumpFrames(tester);

      expect(find.byType(CustomMasonryGrid), findsOneWidget);
    });

    testWidgets("tile tap opens the preview", (WidgetTester tester) async {
      stubGalleryPages(
        mockGetPhotos,
        <int, List<Photo>>{1: samplePhotos(6)},
        totalHits: 6,
      );

      await pumpGallery(tester);
      await tester.tap(find.byType(PhotoTile).first);
      await pumpFrames(tester, count: 6);

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });
  });

  group("PhotoTile favorite seam", () {
    testWidgets("hides the heart without a toggle handler",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoTile(
              photo: samplePhotos(1).single,
              onTap: () {},
            ),
          ),
        ),
      );

      // Only the likes-chip heart remains; no toggle tooltip exists.
      expect(find.byTooltip("Add to favorites"), findsNothing);
      expect(find.byTooltip("Remove from favorites"), findsNothing);
    });

    testWidgets("heart fires the toggle handler", (WidgetTester tester) async {
      bool fired = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoTile(
              photo: samplePhotos(1).single,
              onTap: () {},
              isFavorite: true,
              onFavoriteToggle: () => fired = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip("Remove from favorites"));
      expect(fired, isTrue);
    });
  });
}
