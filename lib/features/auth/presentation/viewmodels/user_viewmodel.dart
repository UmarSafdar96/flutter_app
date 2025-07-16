import 'package:dio/dio.dart';
import 'package:flutter_app/features/auth/data/remote/user_api_service.dart';
import 'package:flutter_app/features/auth/domain/models/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/storage/hive_manager.dart';
import 'package:flutter_app/features/auth/domain/models/user_id.dart';
import '../../utils/json_helper.dart';

final userViewModelProvider = StateNotifierProvider<UserViewModel, AuthState>(
      (ref) => UserViewModel(),
);

class UserViewModel extends StateNotifier<AuthState> {
  final UserApiService _api;

  UserViewModel({UserApiService? api})
      : _api = api ?? UserApiService(),
        super(AuthState.initial());

  Future<void> fetchUserProfile(String userId) async {
    print("🔄 Fetching user profile for userId: $userId");

    state = state.copyWith(isLoading: true, message: null, isSuccess: false);
    print("🚀 State set to loading...");

    try {
      final response = await _api.getuser(UserId(userId: userId));
      print("✅ API call success, response: ${response.data}");

      final json = JSONHelper(response.data);
      final message = json.string("message") ?? "User profile fetch completed.";

      final coreData = json.nested("data").get("userCoreData");

      if (coreData is List && coreData.isNotEmpty) {
        final userJson = JSONHelper(coreData[0]);

        // Save values to Hive
        HiveManager.box.put("user_id", userJson.string("user_id"));
        HiveManager.box.put("first_name", userJson.string("firstName"));
        HiveManager.box.put("last_name", userJson.string("lastName"));
        HiveManager.box.put("phone", userJson.string("phone"));
        HiveManager.box.put("wallet", userJson.string("walletAddress"));
        HiveManager.box.put("created_at", userJson.string("createdAt"));

        print("📦 Saved user data to Hive");

        state = state.copyWith(
          isLoading: false,
          message: message,
          isSuccess: true,
        );
        print("✅ State updated: Success");
      } else {
        print("⚠️ No userCoreData found.");
        state = state.copyWith(
          isLoading: false,
          message: "User profile is empty.",
          isSuccess: false,
        );
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final message = errorData is Map<String, dynamic> && errorData.containsKey('message')
          ? errorData['message']
          : 'Failed to fetch user profile.';

      print("❌ DioException: $message");

      state = state.copyWith(
        isLoading: false,
        message: message,
        isSuccess: false,
      );
    } catch (e, st) {
      print("❌ Unexpected error: $e");
      state = state.copyWith(
        isLoading: false,
        message: "An unexpected error occurred while fetching user profile.",
        isSuccess: false,
      );
    }
  }
}
