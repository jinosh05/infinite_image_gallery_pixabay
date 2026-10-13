// Path: core/error/exceptions.dart
/// Low-level exceptions thrown by the data layer (remote / local).
/// Repositories catch these and return [Failure]s — never leak them to UI.
class ServerException implements Exception {
  const ServerException([this.message = "Server error"]);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = "No internet connection"]);
  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = "Unauthorized"]);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = "Cache error"]);
  final String message;
}

class DownloadException implements Exception {
  const DownloadException([this.message = "Download error"]);
  final String message;
}

class PermissionException implements Exception {
  const PermissionException(
      [this.message = "Storage permission is required to save images."]);
  final String message;
}
