import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/features/auth/domain/auth_state.dart';
import 'package:retail_control_platform/features/auth/domain/user_model.dart';

part 'auth_provider.g.dart';

/// Auth state notifier - Backend API ашиглан authentication хийнэ
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Check if user has saved tokens
    _checkStoredAuth();
    return const AuthState.initial();
  }

  /// Хадгалагдсан token шалгах
  Future<void> _checkStoredAuth() async {
    try {
      final hasTokens = await apiClient.hasTokens();
      if (hasTokens) {
        // Try to get current user info
        await _fetchCurrentUser();
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Current user info авах
  Future<void> _fetchCurrentUser() async {
    try {
      final response = await apiClient.get(ApiEndpoints.me);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['user'];
        final user = UserModel(
          id: userData['id'],
          phone: userData['phone'],
          name: userData['name'],
          role: userData['role'],
          storeId: userData['storeId'],
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : null,
        );
        state = AuthState.authenticated(user);
      } else {
        await apiClient.clearTokens();
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      await apiClient.clearTokens();
      state = const AuthState.unauthenticated();
    }
  }

  /// Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    state = const AuthState.loading();

    try {
      // Format phone: +976XXXXXXXX
      final formattedPhone = phoneNumber.startsWith('+976')
          ? phoneNumber
          : '+976$phoneNumber';

      final response = await apiClient.post(
        ApiEndpoints.otpRequest,
        data: {'phone': formattedPhone},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        state = AuthState.otpSent(formattedPhone);
      } else {
        state = AuthState.error(
          response.data['message'] ?? 'OTP илгээхэд алдаа гарлаа',
        );
      }
    } catch (e) {
      state = AuthState.error('Сервертэй холбогдож чадсангүй. Дахин оролдоно уу.');
    }
  }

  /// Verify OTP code
  Future<void> verifyOtp(String phoneNumber, String otp) async {
    state = const AuthState.loading();

    try {
      final formattedPhone = phoneNumber.startsWith('+976')
          ? phoneNumber
          : '+976$phoneNumber';

      final response = await apiClient.post(
        ApiEndpoints.otpVerify,
        data: {
          'phone': formattedPhone,
          'otp': otp,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Save tokens
        final tokens = response.data['tokens'];
        await apiClient.saveTokens(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );

        // Get user data
        final userData = response.data['user'];
        final user = UserModel(
          id: userData['id'],
          phone: userData['phone'],
          name: userData['name'],
          role: userData['role'],
          storeId: userData['storeId'],
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : null,
        );

        state = AuthState.authenticated(user);
      } else {
        state = AuthState.error(
          response.data['message'] ?? 'OTP буруу байна',
        );
      }
    } catch (e) {
      state = AuthState.error('OTP баталгаажуулалт амжилтгүй боллоо');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState.loading();

    try {
      final refreshToken = await apiClient.getRefreshToken();
      if (refreshToken != null) {
        await apiClient.post(
          ApiEndpoints.logout,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (e) {
      // Ignore logout errors
    } finally {
      await apiClient.clearTokens();
      state = const AuthState.unauthenticated();
    }
  }

  /// Clear error state
  void clearError() {
    state.maybeWhen(
      error: (_) => state = const AuthState.unauthenticated(),
      orElse: () {},
    );
  }
}

/// Current user (convenience provider)
@riverpod
UserModel? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
}

/// Is authenticated (convenience provider)
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeMap(
    authenticated: (_) => true,
    orElse: () => false,
  );
}
