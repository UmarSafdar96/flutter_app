import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/auth/data/remote/user_api_service.dart';
import 'package:flutter_app/features/auth/domain/models/auth_state.dart';
import 'package:flutter_app/features/auth/domain/models/user_id.dart';
import '../../../../core/storage/hive_manager.dart';
import '../../utils/json_helper.dart';
import '../../utils/secure_encryption.dart';


final encryptionServiceProvider = Provider<SecureEncryptionService>((ref) {
  return SecureEncryptionService();
});

// Provide the ViewModel using Riverpod
// Modify the userViewModelProvider to inject SecureEncryptionService
final userViewModelProvider = StateNotifierProvider<UserViewModel, AuthState>(
      (ref) {
    final encryptionService = ref.read(encryptionServiceProvider);
    return UserViewModel(encryptionService: encryptionService);
  },
);

class UserViewModel extends StateNotifier<AuthState> {
  final UserApiService _api;
  final SecureEncryptionService _encryptionService; // Add encryption service


  UserViewModel({UserApiService? api, required SecureEncryptionService encryptionService})
      : _api = api ?? UserApiService(),
        _encryptionService = encryptionService, // Initialize encryption service
        super(AuthState.initial());

  Future<void> fetchUserProfile() async {
    final userId = HiveManager.box.get("user_id");

    state = state.copyWith(isLoading: true, message: null, isSuccess: false);

    try {
      final response = await _api.getuser(UserId(userId: userId));
      final json = JSONHelper(response.data);
      final message = json.string("message") ?? "User profile fetch completed.";

      final coreData = json.nested("data").get("userCoreData");

      if (coreData is List && coreData.isNotEmpty) {
        final userList = coreData.map<Map<String, String>>((entry) {
          final userJson = JSONHelper(entry);
          return {
            "user_id": userJson.string("user_id") ?? "N/A",
            "first_name": userJson.string("firstName") ?? "N/A",
            "last_name": userJson.string("lastName") ?? "N/A",
            "phone": userJson.string("phone") ?? "N/A",
            "wallet": userJson.string("walletAddress") ?? "N/A",
            "created_at": userJson.string("createdAt") ?? "N/A",
          };
        }).toList();

        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          message: message,
          userList: userList,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          message: "User profile is empty.",
          userList: [],
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? "Failed to fetch user profile.";
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        message: message,
        userList: [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        message: "An unexpected error occurred while fetching user profile.",
        userList: [],
      );
    }
  }

  // Example of using encryption for a hypothetical save operation
  Future<void> saveSensitiveData(String data) async {
    try {
      final encryptedData = await _encryptionService.encrypt(data);
      // Now you can send 'encryptedData' to your API or save it securely
      print('Encrypted data: $encryptedData');
      // ... call API to save encrypted data
    } catch (e) {
      print('Error encrypting data: $e');
    }
  }
}

