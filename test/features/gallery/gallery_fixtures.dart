// Shared Pixabay-like JSON fixtures for gallery tests.
Map<String, dynamic> sampleHitJson({int id = 123456}) => <String, dynamic>{
      "id": id,
      "pageURL": "https://pixabay.com/photos/mountain-lake-123456/",
      "type": "photo",
      "tags": "nature, mountain, lake",
      "previewURL": "https://cdn.pixabay.com/photo/preview.jpg",
      "previewWidth": 150,
      "previewHeight": 100,
      "webformatURL": "https://pixabay.com/get/webformat_640.jpg",
      "webformatWidth": 640,
      "webformatHeight": 426,
      "largeImageURL": "https://pixabay.com/get/large_1280.jpg",
      "imageWidth": 1280,
      "imageHeight": 853,
      "views": 1000,
      "downloads": 500,
      "likes": 42,
      "user": "johndoe",
      "userImageURL": "https://cdn.pixabay.com/user/avatar.jpg",
    };

Map<String, dynamic> samplePageJson({
  int totalHits = 45,
  int hitCount = 2,
}) =>
    <String, dynamic>{
      "total": totalHits,
      "totalHits": totalHits,
      "hits": List<Map<String, dynamic>>.generate(
        hitCount,
        (int i) => sampleHitJson(id: 1000 + i),
      ),
    };
