import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/auth/data/remote/user_api_service.dart';
import 'package:flutter_app/features/auth/domain/models/auth_state.dart';
import 'package:flutter_app/features/auth/domain/models/user_id.dart';
import '../../../../core/storage/hive_manager.dart';
import '../../utils/json_helper.dart';

// Provide the ViewModel using Riverpod
final userViewModelProvider = StateNotifierProvider<UserViewModel, AuthState>(
      (ref) => UserViewModel(),
);

class UserViewModel extends StateNotifier<AuthState> {
  final UserApiService _api;

  UserViewModel({UserApiService? api})
      : _api = api ?? UserApiService(),
        super(AuthState.initial());

  Future<List<Map<String, String>>> fetchUserProfile() async {
    final userId = HiveManager.box.get("user_id");

    state = state.copyWith(isLoading: true, message: null, isSuccess: false);

    try {
      final response = await _api.getuser(UserId(userId: userId));

      final json = JSONHelper(response.data);
      final message = json.string("message") ?? "User profile fetch completed.";

      final coreData = json.nested("data").get("userCoreData");

      if (coreData is List && coreData.isNotEmpty) {
        // Map each user entry to a Map<String, String>
        final List<Map<String, String>> userList = coreData.map<Map<String, String>>((entry) {
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
          message: message,
          isSuccess: true,
        );

        return userList;
      } else {
        state = state.copyWith(
          isLoading: false,
          message: "User profile is empty.",
          isSuccess: false,
        );
        return [];
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final message = errorData is Map<String, dynamic> && errorData.containsKey('message')
          ? errorData['message']
          : 'Failed to fetch user profile.';

      state = state.copyWith(
        isLoading: false,
        message: message,
        isSuccess: false,
      );

      return [];
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: "An unexpected error occurred while fetching user profile.",
        isSuccess: false,
      );

      return [];
    }
  }
}
