/// Base class for all failures in the application.
///
/// This provides a unified way to handle errors across the application
/// following the functional error handling pattern.
abstract class Failure {
  const Failure(this.message);

  /// The error message describing the failure.
  final String message;

  @override
  String toString() => message;
}

/// Failure for server-side errors.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Failure for cache/database errors.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Failure for network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Failure for unexpected errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
