// Path: core/config/env_config.dart
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:infinite_image_gallery_pixabay/core/constants/api_constants.dart";

/// Typed access to `.env` values. Loaded once in `main()` via
/// `dotenv.load()`; every reader goes through here (no raw
/// `dotenv.env[...]` scattered in features — SRP + testability).
class EnvConfig {
  EnvConfig._();

  static String get pixabayApiKey =>
      dotenv.env["PIXABAY_API_KEY"]?.trim() ?? "";

  static String get baseUrl =>
      dotenv.env["PIXABAY_BASE_URL"]?.trim() ?? ApiConstants.baseUrl;

  static int get defaultPerPage =>
      int.tryParse(dotenv.env["PIXABAY_DEFAULT_PER_PAGE"] ?? "") ??
      ApiConstants.defaultPerPage;

  static bool get hasApiKey => pixabayApiKey.isNotEmpty;
}
