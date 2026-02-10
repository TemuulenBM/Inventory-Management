/**
 * User Stores Provider
 *
 * Multi-store дэмжлэг:
 * - Хэрэглэгчийн бүх дэлгүүрүүдийг авах (GET /users/:userId/stores)
 * - Дэлгүүр сонгох (POST /users/:userId/stores/:storeId/select)
 * - Owner олон дэлгүүртэй байх боломжтой
 */

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/store/domain/store_info.dart';

part 'user_stores_provider.g.dart';

/// Хэрэглэгчийн дэлгүүрүүдийн жагсаалт
///
/// Owner олон дэлгүүртэй байж болох тул
/// store_members-аар бүх дэлгүүрүүдийг авна
@riverpod
class UserStores extends _$UserStores {
  @override
  Future<List<StoreInfo>> build() async {
    // Current user шалгах
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    try {
      final response = await apiClient.get(
        ApiEndpoints.userStores(user.id),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final storesData = response.data['stores'] as List?;
        if (storesData == null) return [];

        return storesData
            .map((json) => StoreInfo.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      // Алдаа гарвал хоосон жагсаалт буцаана
      return [];
    }
  }

  /// Дэлгүүр сонгох (primary store шинэчлэх)
  ///
  /// Backend POST /users/:userId/stores/:storeId/select дуудаж,
  /// users.store_id шинэчилнэ. Амжилттай бол user state-ийг refresh хийнэ.
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> selectStore(String storeId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      final response = await apiClient.post(
        ApiEndpoints.selectStore(user.id, storeId),
        data: {}, // Fastify JSON parser-д body хоосон байх ёсгүй
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        // User state шинэчлэх (storeId өөрчлөгдсөн тул)
        await ref.read(authNotifierProvider.notifier).refreshCurrentUser();

        // Дэлгүүрүүдийн жагсаалт шинэчлэх
        ref.invalidateSelf();

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
