import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/core/services/shift_service.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';
import 'package:retail_control_platform/features/shifts/domain/shift_model.dart';

part 'shift_provider.g.dart';

/// ShiftService provider
@riverpod
ShiftService shiftService(ShiftServiceRef ref) {
  final db = ref.watch(databaseProvider);
  return ShiftService(db: db);
}

/// Current active shift
/// Offline-first: Local DB эхлээд, background-д API refresh
@riverpod
Future<ShiftModel?> currentShift(
  CurrentShiftRef ref,
  String storeId,
) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final service = ref.watch(shiftServiceProvider);
  final result = await service.getActiveShift(storeId, userId);

  return result.when(
    success: (shift) => shift,
    error: (_, __, ___) => null,
  );
}

/// Shift history (past shifts)
@riverpod
Future<List<ShiftModel>> shiftHistory(
  ShiftHistoryRef ref,
  String storeId, {
  int limit = 20,
}) async {
  final service = ref.watch(shiftServiceProvider);
  final result = await service.getShiftHistory(storeId, limit: limit);

  return result.when(
    success: (shifts) => shifts,
    error: (_, __, ___) => [],
  );
}

/// Shift detail
@riverpod
Future<ShiftModel?> shiftDetail(
  ShiftDetailRef ref,
  String storeId,
  String shiftId,
) async {
  final service = ref.watch(shiftServiceProvider);
  final result = await service.getShiftDetail(storeId, shiftId);

  return result.when(
    success: (shift) => shift,
    error: (_, __, ___) => null,
  );
}

/// Shift actions (open, close)
@riverpod
class ShiftActions extends _$ShiftActions {
  @override
  FutureOr<void> build() {}

  /// Ээлж нээх
  Future<bool> openShift({
    int? openBalance,
  }) async {
    state = const AsyncValue.loading();

    final storeId = ref.read(storeIdProvider);
    final user = ref.read(currentUserProvider);

    if (storeId == null || user == null) {
      state = AsyncValue.error('Хэрэглэгч нэвтрээгүй байна', StackTrace.current);
      return false;
    }

    final service = ref.read(shiftServiceProvider);
    final result = await service.openShift(
      storeId,
      user.id,
      user.name ?? 'Unknown',
      openBalance: openBalance,
    );

    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        // Invalidate to refresh
        ref.invalidate(currentShiftProvider(storeId));
        return true;
      },
      error: (message, _, __) {
        state = AsyncValue.error(message, StackTrace.current);
        return false;
      },
    );
  }

  /// Ээлж хаах (мөнгөн тулгалт + бараа тулгалт)
  Future<bool> closeShift({
    required String shiftId,
    int? closeBalance,
    List<Map<String, dynamic>>? inventoryCounts,
  }) async {
    state = const AsyncValue.loading();

    final storeId = ref.read(storeIdProvider);
    if (storeId == null) {
      state = AsyncValue.error('Хэрэглэгч нэвтрээгүй байна', StackTrace.current);
      return false;
    }

    final service = ref.read(shiftServiceProvider);
    final result = await service.closeShift(
      storeId,
      shiftId,
      closeBalance: closeBalance,
      inventoryCounts: inventoryCounts,
    );

    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        // Invalidate to refresh
        ref.invalidate(currentShiftProvider(storeId));
        ref.invalidate(shiftHistoryProvider(storeId));
        return true;
      },
      error: (message, _, __) {
        state = AsyncValue.error(message, StackTrace.current);
        return false;
      },
    );
  }
}
