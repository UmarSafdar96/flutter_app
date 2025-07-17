// lib/features/user/data/remote/user_api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_app/features/auth/domain/models/user_id.dart';

import '../../../../core/network/dio_client.dart';

class UserApiService {
  final Dio _dio = DioClient.instance;

  Future<Response> getuser(UserId id) {
    return _dio.post('/api/v2/dashboard/user_profile', data: id.toJson());
  }
}


