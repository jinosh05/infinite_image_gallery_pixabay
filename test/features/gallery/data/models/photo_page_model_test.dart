// Path: test/features/gallery/data/models/photo_page_model_test.dart
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_page_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo_page.dart";

import "../../gallery_fixtures.dart";

void main() {
  group("PhotoPageModel.fromJson", () {
    test("parses hits + totalHits with paging echo", () {
      final PhotoPageModel model = PhotoPageModel.fromJson(
        samplePageJson(totalHits: 45, hitCount: 2),
        page: 1,
        perPage: 20,
      );

      expect(model.photos, hasLength(2));
      expect(model.photos.first, isA<PhotoModel>());
      expect(model.totalHits, 45);
      expect(model.page, 1);
      expect(model.perPage, 20);
    });

    test("tolerates missing hits/totalHits", () {
      final PhotoPageModel model = PhotoPageModel.fromJson(
        <String, dynamic>{},
        page: 3,
        perPage: 20,
      );

      expect(model.photos, isEmpty);
      expect(model.totalHits, 0);
    });
  });

  group("PhotoPageModel.toEntity", () {
    test("maps every model to a pure Photo entity", () {
      final PhotoPageModel model = PhotoPageModel.fromJson(
        samplePageJson(hitCount: 3),
        page: 2,
        perPage: 20,
      );
      final PhotoPage entity = model.toEntity();

      expect(entity.photos, hasLength(3));
      expect(entity.photos.any((p) => p is PhotoModel), isFalse);
      expect(entity.totalHits, model.totalHits);
      expect(entity.page, 2);
    });
  });
}
