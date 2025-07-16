// features/auth/presentation/viewmodels/auth_viewmodel.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/storage/hive_manager.dart';
import 'package:flutter_app/features/auth/data/remote/auth_api_service.dart';
import 'package:flutter_app/features/auth/domain/models/auth_request.dart';
import 'package:flutter_app/features/auth/domain/models/auth_state.dart';
import 'package:flutter_app/features/auth/domain/models/otp_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/json_helper.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>(
      (ref) => AuthViewModel(),
    );

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthApiService _api;

  AuthViewModel({AuthApiService? api})
      : _api = api ?? AuthApiService(),
        super(AuthState.initial());

  factory AuthViewModel.withMock(AuthApiService mockApi) {
    return AuthViewModel(api: mockApi);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, message: null, isSuccess: false);

    try {
      final response = await _api.login(AuthRequest(email: email, password: password));
      print('Login successful: ${response.data}');

      final json = JSONHelper(response.data);
      final userId = json.nested("data").string("id");

      if (userId != null) {
        HiveManager.box.put("user_id", userId);
        print('User ID saved: $userId');
      } else {
        print('User ID not found in response');
      }

      state = state.copyWith(
        isLoading: false,
        message: 'Login successful!',
        isSuccess: true,
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final message = errorData is Map<String, dynamic> && errorData.containsKey('message')
          ? errorData['message']
          : 'Something went wrong.';

      print('Login failed: $message');

      state = state.copyWith(
        isLoading: false,
        message: message,
        isSuccess: false,
      );
    } catch (e) {
      print('Unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        message: 'An unexpected error occurred.',
        isSuccess: false,
      );
    }
  }


  void clearMessage() {
    state = state.copyWith(message: null);
  }


  void resetSentEmail() {
    if (state.sentEmail) { // Only update if needed
      state = state.copyWith(sentEmail: false);
    }
  }
  Future<void> signup(String email, String password) async {
    state = state.copyWith(isLoading: true, message: null, isSuccess: false);


    try {
      final response = await _api.signup(AuthRequest(email: email, password: password));
      print('Signup successful: ${response.data}');

      HiveManager.box.put('user_email', email);

      state = state.copyWith(
        isLoading: false,
        message: 'Signup successful!',
        isSuccess: true,
        sentEmail: true,
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final message = errorData is Map<String, dynamic> && errorData.containsKey('message')
          ? errorData['message']
          : 'Something went wrong.';

      print('Signup failed: $message');

      state = state.copyWith(
        isLoading: false,
        message: message,
        isSuccess: false,
        sentEmail: false,
      );
    }
  }


  Future<void> verifyOtp(String email, String code) async {
    state = state.copyWith(isLoading: true, message: null, isSuccess: false);

    try {
      final response = await _api.verifyOtp(OtpModel(email: email, mailVerifyCode: code));
      print('OTP Verified: ${response.data}');

      state = state.copyWith(
        isLoading: false,
        message: 'Email verified successfully!',
        isSuccess: true,
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final message = errorData is Map<String, dynamic> && errorData.containsKey('message')
          ? errorData['message']
          : 'OTP verification failed.';

      print('OTP verification failed: $message');

      state = state.copyWith(
        isLoading: false,
        message: message,
        isSuccess: false,
      );
    }
  }


}
