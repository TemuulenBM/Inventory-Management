import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';

part 'profile_provider.g.dart';

/// Profile засварлах provider
/// Backend API ашиглан хэрэглэгчийн profile шинэчилнэ
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  void build() {
    // No initial state needed
  }

  /// Profile шинэчлэх (зөвхөн нэр засах боломжтой)
  ///
  /// Backend: PUT /stores/:storeId/users/:userId
  /// Body: { name: string }
  Future<bool> updateProfile({required String name}) async {
    try {
      final storeId = ref.read(storeIdProvider);
      final userId = ref.read(currentUserIdProvider);

      if (storeId == null || userId == null) {
        return false;
      }

      // PUT request хийх
      final response = await apiClient.put(
        ApiEndpoints.user(storeId, userId),
        data: {'name': name},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Auth state шинэчлэх (хэрэглэгчийн мэдээлэл дахин татах)
        await ref.read(authNotifierProvider.notifier).refreshCurrentUser();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
