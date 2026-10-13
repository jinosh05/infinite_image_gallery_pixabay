// Path: core/network/dio_client.dart
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:infinite_image_gallery_pixabay/core/constants/api_constants.dart";

/// Single Dio instance for the whole app (SRP: only builds/configures HTTP).
/// Interceptors live here; feature data sources only call `dio.get(...)`.
class DioClient {
  DioClient._();

  static Dio? _dio;

  /// Returns the shared instance, creating it on first use.
  static Dio get instance {
    final Dio? existing = _dio;
    if (existing != null) return existing;
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(
      LogInterceptor(
        request: kDebugMode,
        requestBody: false,
        responseBody: false,
        error: true,
      ),
    );
    _dio = dio;
    return dio;
  }

  /// Test/seeding hook — replaces the shared instance (e.g. with a mock).
  @visibleForTesting
  static void setForTesting(Dio dio) => _dio = dio;

  /// Resets the singleton (used in tests to avoid cross-test leakage).
  @visibleForTesting
  static void reset() => _dio = null;
}
