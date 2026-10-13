// App composition test: GalleryApp boots through sl + shows the gallery.
//
// Fixed pumps (see gallery_page_test.dart): tile image loads hang in the
// sandbox, so pumpAndSettle can never settle. GalleryApp's own _Bootstrap
// runs App.init, so no manual core init is needed here.
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/app.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/widgets/photo_tile.dart";
import "package:infinite_image_gallery_pixabay/injection_container.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";

import "features/gallery/test_doubles.dart";

void main() {
  late MockGetPhotos mockGetPhotos;

  setUpAll(() {
    registerFallbackValue(const GalleryParams());
  });

  setUp(() {
    dotenv.loadFromString(envString: "PIXABAY_API_KEY=TEST_KEY");
    SharedPreferences.setMockInitialValues(<String, Object>{});
    mockGetPhotos = MockGetPhotos();
    stubGalleryPages(
      mockGetPhotos,
      <int, List<Photo>>{1: samplePhotos(4)},
      totalHits: 4,
    );
    // Composition under test: real sl graph, only the use case mocked.
    sl.registerLazySingleton<MockGetPhotos>(() => mockGetPhotos);
    sl.registerFactory<GalleryBloc>(
      () => GalleryBloc(getPhotos: sl<MockGetPhotos>()),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets("boots to the gallery with tiles", (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryApp());
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text(S.galleryTitle), findsOneWidget);
    expect(find.byType(PhotoTile), findsWidgets);
  });
}
