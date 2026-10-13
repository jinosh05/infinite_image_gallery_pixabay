// Path: features/gallery/data/models/photo_page_model.dart
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo_page.dart";

/// Top-level Pixabay response DTO (`{ total, totalHits, hits }`).
class PhotoPageModel extends PhotoPage {
  const PhotoPageModel({
    required super.photos,
    required super.totalHits,
    required super.page,
    required super.perPage,
  });

  factory PhotoPageModel.fromJson(
    Map<String, dynamic> json, {
    required int page,
    required int perPage,
  }) {
    final List<dynamic> hits = json["hits"] as List<dynamic>? ?? <dynamic>[];
    return PhotoPageModel(
      photos: hits
          .whereType<Map<String, dynamic>>()
          .map(PhotoModel.fromJson)
          .toList(),
      totalHits: (json["totalHits"] as num?)?.toInt() ?? 0,
      page: page,
      perPage: perPage,
    );
  }

  PhotoPage toEntity() => PhotoPage(
        photos: photos
            .map<Photo>(
              (Photo p) =>
                  p is PhotoModel ? p.toEntity() : p,
            )
            .toList(),
        totalHits: totalHits,
        page: page,
        perPage: perPage,
      );
}
