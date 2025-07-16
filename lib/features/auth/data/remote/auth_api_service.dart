// features/auth/data/remote/auth_api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/features/auth/domain/models/otp_model.dart';

import '../../domain/models/auth_request.dart';

class AuthApiService {
  final Dio _dio = DioClient.instance;

  Future<Response> login(AuthRequest request) {
    return _dio.post('/api/v2/auth/login', data: request.toJson());
  }

  Future<Response> signup(AuthRequest request) {
    return _dio.post('/api/v2/auth/signup', data: request.toJson());
  }

  Future<Response> verifyOtp(OtpModel otp) {
    return _dio.post('/api/v2/auth/verify', data: otp.toJson());
  }
}
