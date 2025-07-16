import 'package:dio/dio.dart';
import 'package:flutter_app/features/auth/domain/models/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/storage/hive_manager.dart';
import 'package:flutter_app/features/auth/data/remote/auth_api_service.dart';
import 'package:flutter_app/features/auth/domain/models/otp_model.dart';

final otpViewModelProvider =
StateNotifierProvider<OtpViewModel, AuthState>(
      (ref) => OtpViewModel(),
);

class OtpViewModel extends StateNotifier<AuthState> {
  final AuthApiService _api;

  OtpViewModel({AuthApiService? api})
      : _api = api ?? AuthApiService(),
        super(AuthState.initial());

  Future<void> verifyOtp(String code) async {
    final email = HiveManager.box.get('user_email');

    if (email == null) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        message: "No email found in local storage",
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      message: null,
    );

    try {
      final response = await _api.verifyOtp(OtpModel(email: email, mailVerifyCode: code));
      print('OTP Verified: ${response.data}');

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        message: 'Email verified successfully!',
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final message = errorData is Map<String, dynamic> && errorData.containsKey('message')
          ? errorData['message']
          : 'OTP verification failed.';

      print('OTP verification failed: $message');

      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        message: message,
      );
    } catch (e) {
      print('Unexpected error: $e');

      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        message: 'An unexpected error occurred.',
      );
    }
  }

}
