// Path: test/features/gallery/domain/entities/photo_page_test.dart
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo_page.dart";

import "../../gallery_fixtures.dart";

PhotoPage _page({required int photoCount, required int totalHits}) =>
    PhotoPage(
      photos: List<PhotoModel>.generate(
        photoCount,
        (int i) => PhotoModel.fromJson(sampleHitJson(id: i)),
      ),
      totalHits: totalHits,
      page: 1,
      perPage: 20,
    );

void main() {
  group("PhotoPage.isLastPage", () {
    test("false mid-list", () {
      expect(_page(photoCount: 20, totalHits: 45).isLastPage(20), isFalse);
    });

    test("true when accumulated reaches totalHits", () {
      expect(_page(photoCount: 5, totalHits: 45).isLastPage(45), isTrue);
    });

    test("true on empty page regardless of totalHits (deep-paging cap)", () {
      expect(_page(photoCount: 0, totalHits: 500).isLastPage(100), isTrue);
    });
  });

  group("PhotoPage.nextPageKey", () {
    test("returns page+1 mid-list, null when finished", () {
      expect(_page(photoCount: 20, totalHits: 45).nextPageKey(20), 2);
      expect(_page(photoCount: 0, totalHits: 500).nextPageKey(100), isNull);
    });
  });
}
