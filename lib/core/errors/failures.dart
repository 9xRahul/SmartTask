import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures returned by Repositories.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents failure originating from the REST API or server errors.
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Represents failure originating from lack of internet or network timeouts.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Changes will be saved locally and synchronized once online.',
    super.statusCode,
  });
}

/// Represents failure during local database/cache retrieval or persistence.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.statusCode,
  });
}

/// Represents failure during Firebase Authentication / session operations.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// Represents validation failures (e.g. invalid inputs or 422 errors).
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.statusCode,
  });
}
