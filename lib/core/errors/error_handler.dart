import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_exception.dart';
import 'failures.dart';

/// Helper utility for mapping exceptions and error codes into user-friendly messages.
class ErrorHandler {
  ErrorHandler._();

  /// Map Firebase Auth exception codes to clean user-friendly descriptions.
  static String mapFirebaseAuthError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No user account was found associated with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please verify your credentials and try again.';
      case 'email-already-in-use':
        return 'This email address is already registered with another account.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'The email address format is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return exception.message ?? 'An authentication error occurred. Please try again.';
    }
  }

  /// Map Dio exceptions to domain [AppException] objects.
  static AppException handleDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final int? statusCode = dioException.response?.statusCode;
        final dynamic responseData = dioException.response?.data;
        String errorMessage = 'Server returned an error ($statusCode).';

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message') && responseData['message'] != null) {
            errorMessage = responseData['message'].toString();
          } else if (responseData.containsKey('detail') && responseData['detail'] != null) {
            errorMessage = responseData['detail'].toString();
          }
        }

        if (statusCode == 404) {
          return ServerException(
            message: errorMessage.isNotEmpty ? errorMessage : 'The requested resource was not found.',
            statusCode: statusCode,
            details: responseData,
          );
        } else if (statusCode == 422) {
          return ValidationException(
            message: errorMessage.isNotEmpty ? errorMessage : 'Invalid data format submitted.',
            statusCode: statusCode,
            details: responseData,
          );
        } else if (statusCode == 401 || statusCode == 403) {
          return AuthException(
            message: errorMessage.isNotEmpty ? errorMessage : 'Authentication required to perform this action.',
            statusCode: statusCode,
            details: responseData,
          );
        } else {
          return ServerException(
            message: errorMessage,
            statusCode: statusCode,
            details: responseData,
          );
        }
      case DioExceptionType.cancel:
        return const AppException(message: 'Request was cancelled.');
      case DioExceptionType.unknown:
      default:
        if (dioException.error != null && dioException.error.toString().contains('SocketException')) {
          return const NetworkException();
        }
        return AppException(
          message: dioException.message ?? 'An unexpected network error occurred.',
        );
    }
  }

  /// Map [AppException] to corresponding domain [Failure].
  static Failure mapExceptionToFailure(dynamic exception) {
    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message, statusCode: exception.statusCode);
    } else if (exception is ServerException) {
      return ServerFailure(message: exception.message, statusCode: exception.statusCode);
    } else if (exception is CacheException) {
      return CacheFailure(message: exception.message, statusCode: exception.statusCode);
    } else if (exception is AuthException) {
      return AuthFailure(message: exception.message, statusCode: exception.statusCode);
    } else if (exception is ValidationException) {
      return ValidationFailure(message: exception.message, statusCode: exception.statusCode);
    } else if (exception is AppException) {
      return ServerFailure(message: exception.message, statusCode: exception.statusCode);
    }
    return ServerFailure(message: exception.toString());
  }
}
