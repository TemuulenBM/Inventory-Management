import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/core/services/inventory_event_service.dart';
import 'package:retail_control_platform/features/inventory/domain/inventory_event_filter.dart';
import 'package:retail_control_platform/features/inventory/domain/inventory_event_model.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

part 'inventory_event_provider.g.dart';

/// InventoryEventService provider
@riverpod
InventoryEventService inventoryEventService(InventoryEventServiceRef ref) {
  final db = ref.watch(databaseProvider);
  return InventoryEventService(db: db);
}

/// Filter state provider
/// Event type болон огноогоор шүүх боломжтой
@riverpod
class InventoryEventFilterNotifier extends _$InventoryEventFilterNotifier {
  @override
  InventoryEventFilter build() => const InventoryEventFilter();

  /// Event type тохируулах (null = бүгд)
  void setEventType(InventoryEventType? type) {
    state = state.copyWith(eventType: type, page: 1);
  }

  /// Огнооны хүрээ тохируулах
  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end, page: 1);
  }

  /// Хуудас солих (pagination)
  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  /// Бүх filter цэвэрлэх
  void clearFilters() {
    state = const InventoryEventFilter();
  }

  /// Огнооны filter цэвэрлэх
  void clearDateFilter() {
    state = state.copyWith(startDate: null, endDate: null);
  }
}

/// Тодорхой барааны түүх авах
/// Filter state-тэй автоматаар холбогдоно
@riverpod
Future<List<InventoryEventModel>> productInventoryEvents(
  ProductInventoryEventsRef ref,
  String productId,
) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) {
    return [];
  }

  final filter = ref.watch(inventoryEventFilterNotifierProvider);
  final service = ref.watch(inventoryEventServiceProvider);

  final result = await service.getProductHistory(
    storeId,
    productId,
    filter: filter,
  );

  return result.when(
    success: (events) => events,
    error: (message, statusCode, _) {
      // Log error but return empty list
      return [];
    },
  );
}

/// Бүх барааны events (dashboard/global view)
@riverpod
Future<List<InventoryEventModel>> allInventoryEvents(
  AllInventoryEventsRef ref,
) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) {
    return [];
  }

  final filter = ref.watch(inventoryEventFilterNotifierProvider);
  final service = ref.watch(inventoryEventServiceProvider);

  final result = await service.getAllEvents(storeId, filter: filter);

  return result.when(
    success: (events) => events,
    error: (_, __, ___) => [],
  );
}

/// Тохируулга нэмэх actions
@riverpod
class AdjustmentActions extends _$AdjustmentActions {
  @override
  FutureOr<void> build() {}

  /// Шинэ тохируулга үүсгэх
  Future<bool> createAdjustment({
    required String productId,
    required int qtyChange,
    required String reason,
    String? shiftId,
  }) async {
    state = const AsyncValue.loading();

    final storeId = ref.read(storeIdProvider);
    final userId = ref.read(currentUserIdProvider);

    if (storeId == null || userId == null) {
      state = AsyncValue.error('Хэрэглэгч нэвтрээгүй байна', StackTrace.current);
      return false;
    }

    final service = ref.read(inventoryEventServiceProvider);
    final result = await service.createAdjustment(
      storeId: storeId,
      productId: productId,
      actorId: userId,
      qtyChange: qtyChange,
      reason: reason,
      shiftId: shiftId,
    );

    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        // Events list refresh хийх
        ref.invalidate(productInventoryEventsProvider(productId));
        // Product detail refresh хийх (stock өөрчлөгдсөн)
        ref.invalidate(productDetailProvider(productId));
        // Low stock products refresh
        ref.invalidate(lowStockProductsProvider);
        return true;
      },
      error: (message, _, __) {
        state = AsyncValue.error(message, StackTrace.current);
        return false;
      },
    );
  }
}
