// lib/features/auth/domain/models/otp_model.dart

class UserId {
  final String userId;

  UserId({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
    };
  }
}
