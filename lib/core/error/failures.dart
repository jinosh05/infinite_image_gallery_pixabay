// Path: core/error/failures.dart
import "package:equatable/equatable.dart";

/// Domain-level failures. Data layer maps exceptions → these;
/// presentation layer maps these → user messages (see [failureMessage]).
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = "Server error. Please try again later."]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "No internet connection."]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(
      [super.message = "Invalid API key. Check your .env configuration."]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = "Local storage error."]);
}

class PermissionFailure extends Failure {
  const PermissionFailure(
      [super.message = "Storage permission is required to save images."]);
}

class DownloadFailure extends Failure {
  const DownloadFailure([super.message = "Download failed. Please try again."]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = "Something went wrong. Please try again."]);
}
