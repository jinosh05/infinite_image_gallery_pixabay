// Path: features/gallery/data/models/photo_model.dart
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

/// Pixabay `hits[]` DTO. Extends [Photo] so it can travel through layers
/// typed as the entity; [toEntity] detaches a pure domain copy at the
/// repository boundary (layers stay decoupled).
class PhotoModel extends Photo {
  const PhotoModel({
    required super.id,
    required super.pageURL,
    required super.type,
    required super.tags,
    required super.previewURL,
    required super.previewWidth,
    required super.previewHeight,
    required super.webformatURL,
    required super.webformatWidth,
    required super.webformatHeight,
    required super.largeImageURL,
    required super.imageWidth,
    required super.imageHeight,
    required super.views,
    required super.downloads,
    required super.likes,
    required super.user,
    required super.userImageURL,
  });

  static int _asInt(dynamic value) => (value as num?)?.toInt() ?? 0;
  static String _asString(dynamic value) => value as String? ?? "";

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
        id: _asInt(json["id"]),
        pageURL: _asString(json["pageURL"]),
        type: _asString(json["type"]),
        tags: _asString(json["tags"]),
        previewURL: _asString(json["previewURL"]),
        previewWidth: _asInt(json["previewWidth"]),
        previewHeight: _asInt(json["previewHeight"]),
        webformatURL: _asString(json["webformatURL"]),
        webformatWidth: _asInt(json["webformatWidth"]),
        webformatHeight: _asInt(json["webformatHeight"]),
        largeImageURL: _asString(json["largeImageURL"]),
        imageWidth: _asInt(json["imageWidth"]),
        imageHeight: _asInt(json["imageHeight"]),
        views: _asInt(json["views"]),
        downloads: _asInt(json["downloads"]),
        likes: _asInt(json["likes"]),
        user: _asString(json["user"]),
        userImageURL: _asString(json["userImageURL"]),
      );

  /// Serialized for favorites persistence (`shared_preferences`).
  Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id,
        "pageURL": pageURL,
        "type": type,
        "tags": tags,
        "previewURL": previewURL,
        "previewWidth": previewWidth,
        "previewHeight": previewHeight,
        "webformatURL": webformatURL,
        "webformatWidth": webformatWidth,
        "webformatHeight": webformatHeight,
        "largeImageURL": largeImageURL,
        "imageWidth": imageWidth,
        "imageHeight": imageHeight,
        "views": views,
        "downloads": downloads,
        "likes": likes,
        "user": user,
        "userImageURL": userImageURL,
      };

  Photo toEntity() => Photo(
        id: id,
        pageURL: pageURL,
        type: type,
        tags: tags,
        previewURL: previewURL,
        previewWidth: previewWidth,
        previewHeight: previewHeight,
        webformatURL: webformatURL,
        webformatWidth: webformatWidth,
        webformatHeight: webformatHeight,
        largeImageURL: largeImageURL,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        views: views,
        downloads: downloads,
        likes: likes,
        user: user,
        userImageURL: userImageURL,
      );
}
