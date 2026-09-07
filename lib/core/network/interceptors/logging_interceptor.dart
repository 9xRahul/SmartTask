import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Clean logging interceptor for debugging network requests and responses in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('➡️ [DIO REQ] ${options.method} ${options.uri}');
      if (options.data != null) {
        debugPrint('   Body: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint('   QueryParams: ${options.queryParameters}');
      }
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('⬅️ [DIO RES ${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('❌ [DIO ERR ${err.response?.statusCode}] ${err.requestOptions.method} ${err.requestOptions.uri}');
      debugPrint('   Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('   Data: ${err.response?.data}');
      }
    }
    return handler.next(err);
  }
}
