// Path: core/constants/app_strings.dart
/// Centralized user-facing strings (avoids hardcoded literals in UI).
class S {
  S._();

  static const String appName = "Pixabay Gallery";
  static const String galleryTitle = "Gallery";
  static const String favoritesTitle = "Favorites";
  static const String detailTitle = "Photo";

  static const String searchHint = "Search images…";
  static const String pullToRefresh = "Pull to refresh";
  static const String retry = "Retry";
  static const String cancel = "Cancel";
  static const String ok = "OK";
  static const String share = "Share";
  static const String download = "Download";
  static const String downloading = "Downloading…";
  static const String downloadSuccess = "Image saved to gallery";
  static const String downloadFailed = "Download failed. Please try again.";
  static const String favoriteAdded = "Added to favorites";
  static const String favoriteRemoved = "Removed from favorites";

  static const String emptyGallery = "No images found";
  static const String emptyGalleryHint = "Try a different search or pull to refresh.";
  static const String emptyFavorites = "No favorites yet";
  static const String emptyFavoritesHint = "Tap the heart icon on any photo to save it here.";
  static const String favoritesCleared = "Favorites cleared";

  static const String errorGeneric = "Something went wrong. Please try again.";
  static const String errorNoInternet = "No internet connection.";
  static const String errorServer = "Server error. Please try again later.";
  static const String errorUnauthorized =
      "Invalid API key. Check your .env configuration.";
  static const String errorPermission =
      "Storage permission is required to save images.";

  static const String byAuthor = "by";
  static const String views = "views";
  static const String likes = "likes";
  static const String downloads = "downloads";
}
