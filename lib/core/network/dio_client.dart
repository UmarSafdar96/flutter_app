// core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://demo-backend-app-987232490.eu-north-1.elb.amazonaws.com',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(AuthInterceptor());

  static Dio get instance => _dio;
}
