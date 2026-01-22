import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:retail_control_platform/core/supabase/supabase_client.dart';
import 'package:retail_control_platform/features/auth/domain/auth_state.dart';

part 'auth_provider.g.dart';

/// Auth state notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  SupabaseClient get _supabase => SupabaseClientManager.client;

  @override
  AuthState build() {
    // Check current auth state on initialization
    final session = _supabase.auth.currentSession;
    if (session != null && session.user != null) {
      return AuthState.authenticated(session.user!);
    }
    return const AuthState.unauthenticated();
  }

  /// Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    state = const AuthState.loading();

    try {
      // Format phone: +976XXXXXXXX
      final formattedPhone = phoneNumber.startsWith('+976')
          ? phoneNumber
          : '+976$phoneNumber';

      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
      );

      // Stay in loading state until OTP is verified
      state = const AuthState.loading();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Verify OTP code
  Future<void> verifyOtp(String phoneNumber, String otp) async {
    state = const AuthState.loading();

    try {
      final formattedPhone = phoneNumber.startsWith('+976')
          ? phoneNumber
          : '+976$phoneNumber';

      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        state = const AuthState.error('Нэвтрэх амжилтгүй боллоо');
      }
    } catch (e) {
      state = AuthState.error('OTP буруу байна. Дахин оролдоно уу.');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState.loading();

    try {
      await _supabase.auth.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Clear error state
  void clearError() {
    if (state is _Error) {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Auth state changes stream
@riverpod
Stream<AuthState> authStateChanges(AuthStateChangesRef ref) async* {
  final supabase = SupabaseClientManager.client;

  yield* supabase.auth.onAuthStateChange.map((data) {
    final session = data.session;
    if (session != null && session.user != null) {
      return AuthState.authenticated(session.user!);
    }
    return const AuthState.unauthenticated();
  });
}

/// Current user (convenience provider)
@riverpod
User? currentUser(CurrentUserRef ref) {
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
  return authState is _Authenticated;
}
