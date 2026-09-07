import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Interceptor that automatically injects the active Firebase `user_id`
/// into request query parameters as required by the Task Manager API.
class AuthInterceptor extends Interceptor {
  final FirebaseAuth firebaseAuth;

  AuthInterceptor({required this.firebaseAuth});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Inject user_id if not already explicitly provided in query parameters
    if (!options.queryParameters.containsKey('user_id') ||
        options.queryParameters['user_id'] == null ||
        options.queryParameters['user_id'].toString().isEmpty) {
      final User? currentUser = firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid.isNotEmpty) {
        options.queryParameters['user_id'] = currentUser.uid;
      }
    }

    // Set common headers
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }
}
