// features/auth/domain/models/otp_model.dart

class OtpModel {
  final String email;
  final String mailVerifyCode;

  OtpModel({required this.email, required this.mailVerifyCode});

  Map<String, dynamic> toJson() => {
    'email': email,
    'mailVerifyCode': mailVerifyCode,
  };
}
