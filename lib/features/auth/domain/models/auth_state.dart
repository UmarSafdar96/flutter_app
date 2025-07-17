class AuthState {
  final bool isLoading;
  final String? message;
  final bool isSuccess;
  final bool sentEmail;
  final bool otpVerified;
  final List<Map<String, String>> userList;

  const AuthState({
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
    this.sentEmail = false,
    this.otpVerified = false,
    this.userList = const [],
  });

  AuthState copyWith({
    bool? isLoading,
    String? message,
    bool? isSuccess,
    bool? sentEmail,
    bool? otpVerified,
    List<Map<String, String>>? userList,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      isSuccess: isSuccess ?? this.isSuccess,
      sentEmail: sentEmail ?? this.sentEmail,
      otpVerified: otpVerified ?? this.otpVerified,
      userList: userList ?? this.userList,
    );
  }

  factory AuthState.initial() => const AuthState();
}
