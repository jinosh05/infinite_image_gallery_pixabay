// Path: features/gallery/data/datasources/gallery_remote_data_source.dart
import "package:dio/dio.dart";
import "package:infinite_image_gallery_pixabay/core/config/env_config.dart";
import "package:infinite_image_gallery_pixabay/core/constants/api_constants.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/core/network/dio_client.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_page_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";

/// Remote-only contract (ISP: fetching — caching/persistence are separate).
abstract class GalleryRemoteDataSource {
  Future<PhotoPageModel> fetchPhotos(GalleryParams params);
}

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {
  /// [dio] defaults to the app singleton but is injectable (DIP +
  /// testability: tests pass a mocked Dio without touching singletons).
  /// [apiKey] overrides `.env` (tests use a fake key); when null the key is
  /// read lazily per-request so construction never touches `dotenv`.
  GalleryRemoteDataSourceImpl({Dio? dio, String? apiKey})
      : _dio = dio ?? DioClient.instance,
        _apiKeyOverride = apiKey;

  final Dio _dio;
  final String? _apiKeyOverride;

  String get _effectiveKey => _apiKeyOverride ?? EnvConfig.pixabayApiKey;

  @override
  Future<PhotoPageModel> fetchPhotos(GalleryParams params) async {
    final String apiKey = _effectiveKey;
    if (apiKey.isEmpty) {
      throw const UnauthorizedException(
        "Missing PIXABAY_API_KEY. Add it to your .env file.",
      );
    }

    final int perPage = params.perPage.clamp(3, ApiConstants.maxPerPage);
    final Map<String, dynamic> queryParameters = <String, dynamic>{
      ApiConstants.keyParam: apiKey,
      ApiConstants.imageTypeParam: ApiConstants.defaultImageType,
      ApiConstants.pageParam: params.page,
      ApiConstants.perPageParam: perPage,
      ApiConstants.safesearchParam: ApiConstants.defaultSafesearch,
      ApiConstants.orderParam: params.order,
      if (params.query.trim().isNotEmpty)
        ApiConstants.queryParam: params.query.trim(),
      // Pixabay treats an omitted category as "all" — never send "all".
      if (params.category != "all")
        ApiConstants.categoryParam: params.category,
    };

    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        "",
        queryParameters: queryParameters,
      );
      final int? status = response.statusCode;
      if (status == 401 || status == 403) {
        throw const UnauthorizedException(
          "Invalid API key. Check your .env configuration.",
        );
      }
      if (status == null || status < 200 || status >= 300) {
        throw ServerException("Server error (HTTP $status).");
      }
      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException("Unexpected response format.");
      }
      return PhotoPageModel.fromJson(data, page: params.page, perPage: perPage);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on UnauthorizedException {
      rethrow;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (_) {
      throw const ServerException("Unexpected response format.");
    }
  }

  Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException("No internet connection.");
      case DioExceptionType.badResponse:
        final int? status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          return const UnauthorizedException(
            "Invalid API key. Check your .env configuration.",
          );
        }
        return ServerException("Server error (HTTP $status).");
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        // A response-less "unknown" is usually a socket/DNS failure.
        if (e.response == null) {
          return const NetworkException("No internet connection.");
        }
        return const ServerException("Server error. Please try again later.");
    }
  }
}
