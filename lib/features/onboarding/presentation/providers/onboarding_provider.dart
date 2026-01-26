import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/features/onboarding/domain/onboarding_state.dart';

part 'onboarding_provider.g.dart';

/// Onboarding flow state management
/// Store үүсгэх, бараа нэмэх, худалдагч урих үйлдлүүд
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  String? _storeId;

  @override
  OnboardingState build() {
    return const OnboardingState.initial();
  }

  /// Үүссэн store ID авах
  String? get storeId => _storeId;

  /// Store үүсгэх
  Future<bool> createStore({
    required String name,
    String? location,
  }) async {
    state = const OnboardingState.loading();

    try {
      final response = await apiClient.post(
        ApiEndpoints.stores,
        data: {
          'name': name,
          if (location != null && location.isNotEmpty) 'location': location,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        _storeId = response.data['store']['id'];
        state = OnboardingState.storeCreated(_storeId!);
        return true;
      } else {
        state = OnboardingState.error(
          response.data['message'] ?? 'Дэлгүүр үүсгэхэд алдаа гарлаа',
        );
        return false;
      }
    } catch (e) {
      state = const OnboardingState.error('Сервертэй холбогдож чадсангүй');
      return false;
    }
  }

  /// Бараа нэмэх
  Future<bool> addProduct({
    required String name,
    required String sku,
    required double sellPrice,
    double? costPrice,
    int? initialStock,
  }) async {
    if (_storeId == null) return false;

    try {
      final response = await apiClient.post(
        ApiEndpoints.products(_storeId!),
        data: {
          'name': name,
          'sku': sku,
          'sellPrice': sellPrice,
          if (costPrice != null) 'costPrice': costPrice,
          if (initialStock != null) 'initialStock': initialStock,
          'unit': 'ширхэг',
        },
      );

      return response.statusCode == 201 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Худалдагч урих
  Future<bool> inviteSeller({
    required String phone,
    String? name,
    String role = 'seller',
  }) async {
    if (_storeId == null) return false;

    try {
      final formattedPhone =
          phone.startsWith('+976') ? phone : '+976$phone';

      final response = await apiClient.post(
        ApiEndpoints.users(_storeId!),
        data: {
          'phone': formattedPhone,
          if (name != null && name.isNotEmpty) 'name': name,
          'role': role,
        },
      );

      return response.statusCode == 201 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Алдаа цэвэрлэх
  void clearError() {
    state = const OnboardingState.initial();
  }
}
