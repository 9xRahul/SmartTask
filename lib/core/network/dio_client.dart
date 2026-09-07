import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Centralized Dio HTTP Client managing timeouts, interceptors, and request dispatching.
class DioClient {
  late final Dio _dio;

  DioClient({
    required AuthInterceptor authInterceptor,
    Dio? dioOverride,
  }) {
    _dio = dioOverride ??
        Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.addAll([
      authInterceptor,
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  /// HTTP GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// HTTP POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// HTTP PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// HTTP DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
