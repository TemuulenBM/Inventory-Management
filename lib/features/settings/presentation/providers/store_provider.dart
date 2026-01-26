import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/settings/domain/store_model.dart';

part 'store_provider.g.dart';

/// Store мэдээлэл provider
/// Backend API ашиглан дэлгүүрийн мэдээлэл татаж, шинэчилнэ
@riverpod
class StoreNotifier extends _$StoreNotifier {
  @override
  Future<StoreModel?> build() async {
    // Store мэдээлэл татах
    return _fetchStore();
  }

  /// Store мэдээлэл татах
  Future<StoreModel?> _fetchStore() async {
    try {
      final storeId = ref.read(storeIdProvider);
      if (storeId == null) {
        return null;
      }

      // GET /stores/:id
      final response = await apiClient.get(ApiEndpoints.store(storeId));

      if (response.statusCode == 200 && response.data['success'] == true) {
        final storeData = response.data['store'];
        return StoreModel.fromJson(storeData);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Store мэдээлэл шинэчлэх
  ///
  /// Backend: PUT /stores/:id
  /// Body: { name?: string, location?: string }
  Future<bool> updateStore({String? name, String? location}) async {
    try {
      final storeId = ref.read(storeIdProvider);
      if (storeId == null) {
        return false;
      }

      // PUT request хийх
      final response = await apiClient.put(
        ApiEndpoints.store(storeId),
        data: {
          if (name != null) 'name': name,
          if (location != null) 'location': location,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // State шинэчлэх (дахин татах)
        ref.invalidateSelf();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
