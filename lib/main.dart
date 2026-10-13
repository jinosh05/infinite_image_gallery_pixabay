// Path: lib/main.dart
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:infinite_image_gallery_pixabay/app.dart";
import "package:infinite_image_gallery_pixabay/injection_container.dart";

/// Composition root: env → DI → app. Feature Blocs are provided in [App]
/// (see `lib/app.dart`); this file only guarantees ordering.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Missing/unreadable .env: boot anyway — the placeholder home shows
    // setup instructions (EnvConfig.hasApiKey == false).
    debugPrint(".env not found — running without API key.");
  }

  await initDependencies();

  runApp(const GalleryApp());
}
