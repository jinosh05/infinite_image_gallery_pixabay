// Path: test/features/favorites/data/datasources/favorites_local_data_source_test.dart
import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/data/datasources/favorites_local_data_source.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../gallery/gallery_fixtures.dart";

void main() {
  late FavoritesLocalDataSourceImpl dataSource;

  PhotoModel sampleModel({int id = 1}) =>
      PhotoModel.fromJson(sampleHitJson(id: id));

  Future<void> seed(List<PhotoModel> photos) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      FavoritesLocalDataSourceImpl.storageKey: <String>[
        for (final PhotoModel p in photos) jsonEncode(p.toJson()),
      ],
    });
    dataSource = FavoritesLocalDataSourceImpl(
      prefs: await SharedPreferences.getInstance(),
    );
  }

  group("FavoritesLocalDataSource", () {
    test("round-trips saved favorites", () async {
      await seed(<PhotoModel>[sampleModel(id: 1), sampleModel(id: 2)]);

      final List<PhotoModel> loaded = await dataSource.getFavorites();

      expect(loaded.map((p) => p.id), <int>[1, 2]);
      expect(loaded.first.tags, "nature, mountain, lake");
    });

    test("returns empty when nothing saved", () async {
      await seed(<PhotoModel>[]);

      expect(await dataSource.getFavorites(), isEmpty);
    });

    test("skips corrupt entries instead of failing", () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        FavoritesLocalDataSourceImpl.storageKey: <String>[
          jsonEncode(sampleModel(id: 1).toJson()),
          "not-json{{{",
          jsonEncode(<String, dynamic>{"id": "mistyped"}),
        ],
      });
      dataSource = FavoritesLocalDataSourceImpl(
        prefs: await SharedPreferences.getInstance(),
      );

      final List<PhotoModel> loaded = await dataSource.getFavorites();

      // Only the valid entry survives; garbage is skipped, not fatal.
      expect(loaded.map((p) => p.id), <int>[1]);
    });

    test("persists what it is given", () async {
      await seed(<PhotoModel>[]);
      await dataSource.saveFavorites(<PhotoModel>[sampleModel(id: 9)]);

      final List<PhotoModel> reloaded = await dataSource.getFavorites();
      expect(reloaded.map((p) => p.id), <int>[9]);
    });
  });
}
