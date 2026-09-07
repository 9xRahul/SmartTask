/// Base class for all custom application exceptions.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'AppException(statusCode: $statusCode, message: $message, details: $details)';
}

/// Thrown when there is no internet connection or a socket/network timeout occurs.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Unable to connect to the internet. Please check your network connection.',
    super.statusCode,
    super.details,
  });
}

/// Thrown when the remote REST API returns a non-200 error code (e.g. 500, 404, 422).
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// Thrown when local Hive or cache operations fail.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// Thrown when Firebase Authentication or authorization operations fail.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// Thrown when client-side or server-side input validation fails (e.g., 422 Unprocessable Entity).
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode,
    super.details,
  });
}
