// Bootstrap smoke test: app boots with/without an API key.
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/app.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";

void main() {
  testWidgets("shows key-missing guidance when .env has no key",
      (WidgetTester tester) async {
    dotenv.loadFromString(envString: "SOME_OTHER_VAR=1");
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    expect(find.text(S.appName), findsWidgets);
    expect(find.text("API key missing"), findsOneWidget);
  });

  testWidgets("shows gallery placeholder when a key exists",
      (WidgetTester tester) async {
    dotenv.loadFromString(envString: "PIXABAY_API_KEY=TEST_KEY");
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    expect(find.text(S.galleryTitle), findsOneWidget);
  });
}
