import 'package:dio/dio.dart';
import 'package:flutter_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_api_service.mocks.dart';


void main() {
  late MockAuthApiService mockApiService;
  late AuthViewModel viewModel;

  setUp(() {
    mockApiService = MockAuthApiService();
    viewModel = AuthViewModel.withMock(mockApiService); // Add withMock constructor
  });

  group('AuthViewModel', () {
    test('Login success sets isSuccess true and message', () async {
      // Arrange
      when(mockApiService.login(any)).thenAnswer(
            (_) async => Response(
          data: {'token': 'abc123'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      await viewModel.login('test@example.com', 'password123');

      // Assert
      final state = viewModel.state;
      expect(state.isLoading, false);
      expect(state.isSuccess, true);
      expect(state.message, 'Login successful!');
    });

    test('Login failure sets isSuccess false and error message', () async {
      // Arrange
      when(mockApiService.login(any)).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Invalid credentials'},
            statusCode: 400,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      await viewModel.login('fail@example.com', 'wrong');

      // Assert
      final state = viewModel.state;
      expect(state.isSuccess, false);
      expect(state.message, 'Invalid credentials');
    });

    test('Signup success updates state correctly', () async {
      // Arrange
      when(mockApiService.signup(any)).thenAnswer(
            (_) async => Response(
          data: {'token': 'signup123'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      await viewModel.signup('new@example.com', 'password');

      // Assert
      final state = viewModel.state;
      expect(state.isSuccess, true);
      expect(state.message, 'Signup successful!');
    });
  });
}
