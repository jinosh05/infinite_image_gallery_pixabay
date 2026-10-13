// Path: test/features/gallery/data/models/photo_model_test.dart
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

import "../../gallery_fixtures.dart";

void main() {
  group("PhotoModel.fromJson", () {
    test("parses a full Pixabay hit", () {
      final PhotoModel model = PhotoModel.fromJson(sampleHitJson());

      expect(model.id, 123456);
      expect(model.tags, "nature, mountain, lake");
      expect(model.webformatURL, "https://pixabay.com/get/webformat_640.jpg");
      expect(model.largeImageURL, "https://pixabay.com/get/large_1280.jpg");
      expect(model.likes, 42);
      expect(model.user, "johndoe");
    });

    test("defaults missing/nullable fields instead of throwing", () {
      final PhotoModel model = PhotoModel.fromJson(<String, dynamic>{
        "id": 7,
        // everything else absent (incl. largeImageURL)
      });

      expect(model.id, 7);
      expect(model.tags, "");
      expect(model.webformatURL, "");
      expect(model.largeImageURL, "");
      expect(model.views, 0);
      expect(model.user, "");
    });
  });

  group("PhotoModel.toJson", () {
    test("round-trips through fromJson losslessly", () {
      final PhotoModel original = PhotoModel.fromJson(sampleHitJson());
      final PhotoModel restored =
          PhotoModel.fromJson(original.toJson());

      expect(restored, original);
    });
  });

  group("PhotoModel.toEntity", () {    test("detaches an equal pure Photo entity", () {
      final PhotoModel model = PhotoModel.fromJson(sampleHitJson());
      final Photo entity = model.toEntity();

      expect(entity, isA<Photo>());
      expect(entity, isNot(isA<PhotoModel>()));
      expect(entity.id, model.id);
      expect(entity.largeImageURL, model.largeImageURL);
      expect(entity.likes, model.likes);
    });
  });

  group("PhotoModel.fromEntity", () {
    test("round-trips entity → model → json", () {
      final Photo entity =
          PhotoModel.fromJson(sampleHitJson()).toEntity();
      final PhotoModel model = PhotoModel.fromEntity(entity);

      // Equatable is runtime-type-strict, so compare via detached entities.
      expect(model.toEntity(), entity);
      expect(PhotoModel.fromJson(model.toJson()).toEntity(), entity);
    });
  });

  group("Photo derived getters", () {
    test("detailImageUrl prefers largeImageURL", () {
      final PhotoModel model = PhotoModel.fromJson(sampleHitJson());
      expect(model.detailImageUrl, model.largeImageURL);
    });

    test("detailImageUrl falls back to webformatURL then previewURL", () {
      final PhotoModel noLarge = PhotoModel.fromJson(
        sampleHitJson()..remove("largeImageURL"),
      );
      expect(noLarge.detailImageUrl, noLarge.webformatURL);

      final PhotoModel previewOnly = PhotoModel.fromJson(
        sampleHitJson()
          ..remove("largeImageURL")
          ..remove("webformatURL"),
      );
      expect(previewOnly.detailImageUrl, previewOnly.previewURL);
    });

    test("tagList splits and trims the tags string", () {
      final PhotoModel model = PhotoModel.fromJson(sampleHitJson());
      expect(model.tagList, <String>["nature", "mountain", "lake"]);
    });

    test("tagList is empty for blank tags", () {
      final PhotoModel model = PhotoModel.fromJson(<String, dynamic>{"id": 1});
      expect(model.tagList, isEmpty);
    });
  });
}
