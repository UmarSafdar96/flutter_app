// auth_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoading;
  final String? message;
  final bool isSuccess;
  final bool sentEmail;
  final bool otpVerified;

  const AuthState({
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
    this.sentEmail = false,
    this.otpVerified = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? message,
    bool? isSuccess,
    bool? sentEmail,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
      sentEmail: sentEmail ?? this.sentEmail,
      otpVerified: otpVerified ?? this.otpVerified,
    );
  }

  factory AuthState.initial() => const AuthState();
}
