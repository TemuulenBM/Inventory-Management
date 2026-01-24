import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retail_control_platform/features/auth/domain/user_model.dart';

part 'auth_state.freezed.dart';

/// Authentication state (Freezed union)
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.otpSent(String phone) = _OtpSent;
  const factory AuthState.authenticated(UserModel user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
