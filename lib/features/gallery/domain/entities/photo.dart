// Path: features/gallery/domain/entities/photo.dart
import "package:equatable/equatable.dart";

/// Immutable gallery photo (domain entity).
/// Framework-free: no JSON, no Dio, no widgets — pure data + derived getters.
class Photo extends Equatable {
  const Photo({
    required this.id,
    required this.pageURL,
    required this.type,
    required this.tags,
    required this.previewURL,
    required this.previewWidth,
    required this.previewHeight,
    required this.webformatURL,
    required this.webformatWidth,
    required this.webformatHeight,
    required this.largeImageURL,
    required this.imageWidth,
    required this.imageHeight,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.user,
    required this.userImageURL,
  });

  final int id;
  final String pageURL;
  final String type;
  final String tags;
  final String previewURL;
  final int previewWidth;
  final int previewHeight;
  final String webformatURL;
  final int webformatWidth;
  final int webformatHeight;
  final String largeImageURL;
  final int imageWidth;
  final int imageHeight;
  final int views;
  final int downloads;
  final int likes;
  final String user;
  final String userImageURL;

  /// Best URL for the detail/download/share flows.
  /// `largeImageURL` is occasionally absent — fall back gracefully (SRP:
  /// single place encoding the fallback chain).
  String get detailImageUrl {
    if (largeImageURL.isNotEmpty) return largeImageURL;
    if (webformatURL.isNotEmpty) return webformatURL;
    return previewURL;
  }

  /// `tags` come as a comma-separated string ("nature, mountain, lake").
  List<String> get tagList => tags
      .split(",")
      .map((String t) => t.trim())
      .where((String t) => t.isNotEmpty)
      .toList();

  /// Aspect ratio for masonry/grid cell sizing (0 when unknown).
  double get aspectRatio {
    if (webformatWidth <= 0 || webformatHeight <= 0) return 0;
    return webformatWidth / webformatHeight;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        pageURL,
        type,
        tags,
        previewURL,
        previewWidth,
        previewHeight,
        webformatURL,
        webformatWidth,
        webformatHeight,
        largeImageURL,
        imageWidth,
        imageHeight,
        views,
        downloads,
        likes,
        user,
        userImageURL,
      ];
}
