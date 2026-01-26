import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

/// Onboarding flow-ийн state
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState.initial() = _Initial;
  const factory OnboardingState.loading() = _Loading;
  const factory OnboardingState.storeCreated(String storeId) = _StoreCreated;
  const factory OnboardingState.productsAdded(int count) = _ProductsAdded;
  const factory OnboardingState.completed() = _Completed;
  const factory OnboardingState.error(String message) = _Error;
}
