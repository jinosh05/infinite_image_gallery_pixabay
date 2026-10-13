// Path: core/constants/api_constants.dart
/// Pixabay API configuration + keys.
/// Values come from `--dart-define` / `.env`; defaults keep the app runnable.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "https://pixabay.com/api/";
  static const String defaultImageType = "photo";
  static const int defaultPerPage = 20;
  static const int maxPerPage = 200;
  static const bool defaultSafesearch = true;

  // Query keys
  static const String keyParam = "key";
  static const String queryParam = "q";
  static const String pageParam = "page";
  static const String perPageParam = "per_page";
  static const String imageTypeParam = "image_type";
  static const String categoryParam = "category";
  static const String safesearchParam = "safesearch";
  static const String orderParam = "order";

  // Pixabay categories (https://pixabay.com/api/docs/)
  static const List<String> categories = <String>[
    "all",
    "backgrounds",
    "fashion",
    "nature",
    "science",
    "education",
    "feelings",
    "health",
    "people",
    "religion",
    "places",
    "animals",
    "industry",
    "computer",
    "food",
    "sports",
    "transportation",
    "travel",
    "buildings",
    "business",
    "music",
  ];
}
