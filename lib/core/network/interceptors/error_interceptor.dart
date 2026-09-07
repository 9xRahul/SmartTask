import 'package:dio/dio.dart';
import '../../errors/error_handler.dart';

/// Interceptor to normalize Dio errors and attach custom AppException to DioException error payload.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = ErrorHandler.handleDioError(err);
    final modifiedError = err.copyWith(
      error: appException,
      message: appException.message,
    );
    return handler.next(modifiedError);
  }
}
