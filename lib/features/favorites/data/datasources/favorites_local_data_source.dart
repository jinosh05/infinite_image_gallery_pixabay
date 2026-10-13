// Path: features/favorites/data/datasources/favorites_local_data_source.dart
import "dart:convert";

import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Local-only contract (ISP: favorites persistence — nothing else).
abstract class FavoritesLocalDataSource {
  Future<List<PhotoModel>> getFavorites();
  Future<void> saveFavorites(List<PhotoModel> photos);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  FavoritesLocalDataSourceImpl({required this.prefs});

  final SharedPreferences prefs;

  static const String storageKey = "favorite_photos_v1";

  @override
  Future<List<PhotoModel>> getFavorites() async {
    final List<String> raw = prefs.getStringList(storageKey) ?? <String>[];
    final List<PhotoModel> photos = <PhotoModel>[];
    for (final String entry in raw) {
      try {
        final dynamic decoded = jsonDecode(entry);
        if (decoded is Map<String, dynamic>) {
          photos.add(PhotoModel.fromJson(decoded));
        }
      } catch (_) {
        // Skip corrupt entries (e.g. hand-edited prefs) — one bad apple
        // must not wipe the whole favorites list.
      }
    }
    return photos;
  }

  @override
  Future<void> saveFavorites(List<PhotoModel> photos) async {
    await prefs.setStringList(
      storageKey,
      <String>[for (final PhotoModel p in photos) jsonEncode(p.toJson())],
    );
  }
}
