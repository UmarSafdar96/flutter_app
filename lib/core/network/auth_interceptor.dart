// core/network/interceptors/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter_app/core/storage/hive_manager.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip token for auth endpoints
    final path = options.path;
    final isAuthRoute = path.contains('/auth/login') ||
        path.contains('/auth/signup') ||
        path.contains('/auth/verify');

    if (!isAuthRoute) {
      final token = HiveManager.box.get('token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }
}
