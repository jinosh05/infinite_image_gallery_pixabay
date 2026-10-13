// Path: test/features/detail/presentation/pages/detail_page_test.dart
import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/features/detail/data/services/image_download_service.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/cubit/download_cubit.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/pages/detail_page.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/injection_container.dart";
import "package:mocktail/mocktail.dart";

import "../../../gallery/gallery_fixtures.dart";

class MockImageDownloadService extends Mock implements ImageDownloadService {}

void _noopProgress(double _) {}

// Fixed pumps: detail images hang on sandbox HTTP like gallery tiles do.
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
  late MockImageDownloadService mockService;

  setUpAll(() {
    registerFallbackValue("");
    registerFallbackValue(_noopProgress);
  });

  setUp(() {
    mockService = MockImageDownloadService();
    sl.registerLazySingleton<ImageDownloadService>(() => mockService);
    sl.registerFactory<DownloadCubit>(
      () => DownloadCubit(service: sl<ImageDownloadService>()),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Photo samplePhoto() =>
      PhotoModel.fromJson(sampleHitJson()).toEntity();

  Future<void> pumpDetail(WidgetTester tester, Photo photo) async {
    await tester.pumpWidget(
      MaterialApp(home: DetailPage(photo: photo)),
    );
    await pumpFrames(tester);
  }

  group("DetailPage content", () {
    testWidgets("renders description block + actions", (WidgetTester tester) async {
      await pumpDetail(tester, samplePhoto());

      // Tags from "nature, mountain, lake".
      expect(find.text("nature"), findsOneWidget);
      expect(find.text("mountain"), findsOneWidget);
      // Attribution, stats, resolution, source link.
      expect(find.textContaining("johndoe"), findsOneWidget);
      expect(find.text(S.views), findsOneWidget);
      expect(find.text(S.likes), findsOneWidget);
      expect(find.text(S.downloads), findsOneWidget);
      expect(find.text("1280 × 853"), findsOneWidget);
      expect(find.text("View on Pixabay"), findsOneWidget);
      // Hero + actions.
      expect(find.byType(Hero), findsOneWidget);
      expect(find.text(S.download), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets("hides favorite without a toggle handler",
        (WidgetTester tester) async {
      await pumpDetail(tester, samplePhoto());

      expect(find.byTooltip("Add to favorites"), findsNothing);
    });
  });

  group("DetailPage download", () {
    testWidgets("shows progress then success", (WidgetTester tester) async {
      final Completer<String> gate = Completer<String>();
      late void Function(double) capturedProgress;
      when(
        () => mockService.downloadToGallery(
          any(),
          onProgress: any(named: "onProgress"),
          fileName: any(named: "fileName"),
        ),
      ).thenAnswer((Invocation inv) {
        capturedProgress =
            inv.namedArguments[#onProgress] as void Function(double);
        return gate.future;
      });

      await pumpDetail(tester, samplePhoto());
      await tester.tap(find.text(S.download));
      capturedProgress(0.5);
      await pumpFrames(tester, count: 3);

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining("50%"), findsOneWidget);

      gate.complete("saved.jpg");
      await pumpFrames(tester);

      expect(find.text(S.downloadSuccess), findsOneWidget);
      verify(
        () => mockService.downloadToGallery(
          "https://pixabay.com/get/large_1280.jpg",
          onProgress: any(named: "onProgress"),
          fileName: "pixabay_123456",
        ),
      ).called(1);
    });

    testWidgets("shows failure message", (WidgetTester tester) async {
      when(
        () => mockService.downloadToGallery(
          any(),
          onProgress: any(named: "onProgress"),
          fileName: any(named: "fileName"),
        ),
      ).thenThrow(const DownloadException("disk full"));

      await pumpDetail(tester, samplePhoto());
      await tester.tap(find.text(S.download));
      await pumpFrames(tester);

      expect(find.text("disk full"), findsOneWidget);
    });
  });

  group("DetailPage external actions", () {
    // share_plus / url_launcher have no platform plugins in widget tests
    // (calls no-op or hang), so these assert crash-freedom + presence.
    // Failure surfacing (try/catch → snackbar) is verified on-device.
    testWidgets("share tap never crashes",
        (WidgetTester tester) async {
      await pumpDetail(tester, samplePhoto());
      await tester.tap(find.byIcon(Icons.share_outlined));
      await pumpFrames(tester);

      expect(find.byType(DetailPage), findsOneWidget);
    });

    testWidgets("pixabay link is present and enabled",
        (WidgetTester tester) async {
      await pumpDetail(tester, samplePhoto());

      final Finder link = find.text("View on Pixabay");
      expect(link, findsOneWidget);
      expect(tester.widget<OutlinedButton>(find.ancestor(
        of: link,
        matching: find.byType(OutlinedButton),
      )).onPressed, isNotNull);
    });
  });
}
