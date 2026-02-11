import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/store/presentation/providers/user_stores_provider.dart';
import 'package:retail_control_platform/features/transfer/domain/models/transfer_model.dart';

part 'transfer_provider.g.dart';

/// Шилжүүлгийн жагсаалт авах (backend API-аас)
@riverpod
Future<List<TransferModel>> transferList(TransferListRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return [];

  try {
    final response = await apiClient.get(
      '/stores/$storeId/transfers',
      queryParameters: {'direction': 'all', 'limit': 50},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) return [];

    final transfersJson = data['transfers'] as List<dynamic>;
    return transfersJson
        .map((json) => TransferModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Error-г дамжуулж, UI дээр error state харуулах
    rethrow;
  }
}

/// Очих боломжтой салбаруудын жагсаалт (шилжүүлэг хийхэд)
/// userStoresProvider-аас одоогийн салбарыг хасна
@riverpod
Future<List<Map<String, String>>> availableDestinationStores(
  AvailableDestinationStoresRef ref,
) async {
  final currentStoreId = ref.watch(storeIdProvider);
  if (currentStoreId == null) return [];

  // userStoresProvider ашиглан салбаруудыг авах
  // (Дэлгүүр сонгох дэлгэцтэй ижил endpoint: /users/:userId/stores)
  final stores = await ref.watch(userStoresProvider.future);

  return stores
      .where((s) => s.id != currentStoreId)
      .map((s) => {'id': s.id, 'name': s.name})
      .toList();
}

/// Шилжүүлэг үүсгэх action
@riverpod
class CreateTransferAction extends _$CreateTransferAction {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Шилжүүлэг илгээх
  Future<bool> submit({
    required String destinationStoreId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final storeId = ref.read(storeIdProvider);
    if (storeId == null) return false;

    state = const AsyncLoading();

    try {
      final response = await apiClient.post(
        '/stores/$storeId/transfers',
        data: {
          'destination_store_id': destinationStoreId,
          'items': items.map((item) => {
            'product_id': item['product_id'],
            'quantity': item['quantity'],
          }).toList(),
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = const AsyncData(null);
        // Шилжүүлгийн жагсаалтыг шинэчлэх
        ref.invalidate(transferListProvider);
        return true;
      } else {
        final errorMsg = data['message'] as String? ?? 'Алдаа гарлаа';
        state = AsyncError(errorMsg, StackTrace.current);
        return false;
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}
