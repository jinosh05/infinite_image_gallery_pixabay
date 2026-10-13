// Path: test/features/gallery/data/datasources/gallery_remote_data_source_test.dart
import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/datasources/gallery_remote_data_source.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_page_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:mocktail/mocktail.dart";

import "../../gallery_fixtures.dart";

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  const String fakeKey = "TEST_KEY";

  GalleryRemoteDataSourceImpl dataSource({String apiKey = fakeKey}) =>
      GalleryRemoteDataSourceImpl(dio: mockDio, apiKey: apiKey);

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue("");
  });

  setUp(() => mockDio = MockDio());

  Response<dynamic> okResponse(Map<String, dynamic> data) =>
      Response<dynamic>(
        requestOptions: RequestOptions(path: ""),
        data: data,
        statusCode: 200,
      );

  void stubOk(Map<String, dynamic> data) {
    when(
      () => mockDio.get<dynamic>(
        "",
        queryParameters: any(named: "queryParameters"),
      ),
    ).thenAnswer((_) async => okResponse(data));
  }

  Map<String, dynamic> capturedParams() {
    final List<dynamic> captured = verify(
      () => mockDio.get<dynamic>(
        "",
        queryParameters: captureAny(named: "queryParameters"),
      ),
    ).captured;
    return captured.single as Map<String, dynamic>;
  }

  group("fetchPhotos request building", () {
    test("sends key, paging, safesearch, image_type; omits category 'all'",
        () async {
      stubOk(samplePageJson());

      final PhotoPageModel result = await dataSource().fetchPhotos(
        const GalleryParams(query: "nature", page: 2, perPage: 20),
      );

      expect(result.photos, hasLength(2));
      final Map<String, dynamic> params = capturedParams();
      expect(params["key"], fakeKey);
      expect(params["q"], "nature");
      expect(params["page"], 2);
      expect(params["per_page"], 20);
      expect(params["image_type"], "photo");
      expect(params, isNot(contains("category")));
    });

    test("sends category when it is not 'all', omits blank query", () async {
      stubOk(samplePageJson(hitCount: 1));

      await dataSource().fetchPhotos(
        const GalleryParams(query: "   ", category: "animals"),
      );

      final Map<String, dynamic> params = capturedParams();
      expect(params["category"], "animals");
      expect(params, isNot(contains("q")));
    });

    test("throws UnauthorizedException without calling Dio when key is empty",
        () async {
      final GalleryRemoteDataSourceImpl noKey = dataSource(apiKey: "");

      await expectLater(
        noKey.fetchPhotos(const GalleryParams()),
        throwsA(isA<UnauthorizedException>()),
      );
      verifyNever(
        () => mockDio.get<dynamic>(
          any(),
          queryParameters: any(named: "queryParameters"),
        ),
      );
    });
  });

  group("fetchPhotos error mapping", () {
    test("401 response body maps to UnauthorizedException", () async {
      when(
        () => mockDio.get<dynamic>(
          "",
          queryParameters: any(named: "queryParameters"),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ""),
          data: "",
          statusCode: 401,
        ),
      );

      await expectLater(
        dataSource().fetchPhotos(const GalleryParams()),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test("connection error maps to NetworkException", () async {
      when(
        () => mockDio.get<dynamic>(
          "",
          queryParameters: any(named: "queryParameters"),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ""),
          type: DioExceptionType.connectionError,
        ),
      );

      await expectLater(
        dataSource().fetchPhotos(const GalleryParams()),
        throwsA(isA<NetworkException>()),
      );
    });

    test("500 bad-response maps to ServerException", () async {
      when(
        () => mockDio.get<dynamic>(
          "",
          queryParameters: any(named: "queryParameters"),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ""),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: ""),
            statusCode: 500,
          ),
        ),
      );

      await expectLater(
        dataSource().fetchPhotos(const GalleryParams()),
        throwsA(isA<ServerException>()),
      );
    });

    test("non-JSON body maps to ServerException", () async {
      // Wrong envelope shape (list instead of {hits, totalHits}).
      when(
        () => mockDio.get<dynamic>(
          "",
          queryParameters: any(named: "queryParameters"),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ""),
          data: <dynamic>[],
          statusCode: 200,
        ),
      );

      await expectLater(
        dataSource().fetchPhotos(const GalleryParams()),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
