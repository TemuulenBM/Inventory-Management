import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/features/shifts/domain/shift_model.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

part 'shift_provider.g.dart';

/// Current active shift
@riverpod
Future<ShiftModel?> currentShift(
  CurrentShiftRef ref,
  String storeId,
) async {
  final db = ref.watch(databaseProvider);

  // TODO: Implement actual query
  // final shift = await db.select(db.shifts)
  //   .where((s) => s.storeId.equals(storeId) & s.endTime.isNull())
  //   .getSingleOrNull();

  // Mock data for Phase 3
  return _getMockCurrentShift();
}

/// Shift history (past shifts)
@riverpod
Future<List<ShiftModel>> shiftHistory(
  ShiftHistoryRef ref,
  String storeId, {
  int limit = 20,
}) async {
  final db = ref.watch(databaseProvider);

  // TODO: Implement actual query
  // final shifts = await db.select(db.shifts)
  //   .where((s) => s.storeId.equals(storeId) & s.endTime.isNotNull())
  //   .orderBy([(s) => OrderingTerm.desc(s.startTime)])
  //   .limit(limit)
  //   .get();

  // Mock data for Phase 3
  return _getMockShiftHistory();
}

/// Start new shift
@riverpod
class ShiftActions extends _$ShiftActions {
  @override
  FutureOr<void> build() {}

  Future<void> startShift({
    required String sellerId,
    required String sellerName,
    required String storeId,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);

      // TODO: Implement actual insert
      // await db.into(db.shifts).insert(
      //   ShiftsCompanion.insert(
      //     sellerId: sellerId,
      //     sellerName: sellerName,
      //     storeId: storeId,
      //     startTime: DateTime.now(),
      //     notes: Value(notes),
      //   ),
      // );

      // Invalidate current shift to refresh
      ref.invalidate(currentShiftProvider);
    });
  }

  Future<void> endShift({
    required String shiftId,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);

      // TODO: Implement actual update
      // await (db.update(db.shifts)..where((s) => s.id.equals(shiftId)))
      //   .write(
      //     ShiftsCompanion(
      //       endTime: Value(DateTime.now()),
      //       notes: Value(notes),
      //     ),
      //   );

      // Invalidate to refresh
      ref.invalidate(currentShiftProvider);
      ref.invalidate(shiftHistoryProvider);
    });
  }
}

/// Mock data for Phase 3
ShiftModel? _getMockCurrentShift() {
  return ShiftModel(
    id: 'shift-1',
    sellerId: 'seller-1',
    sellerName: 'Болд',
    storeId: 'store-1',
    startTime: DateTime.now().subtract(const Duration(hours: 3)),
    totalSales: 125000,
    transactionCount: 18,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  );
}

List<ShiftModel> _getMockShiftHistory() {
  return [
    ShiftModel(
      id: 'shift-2',
      sellerId: 'seller-1',
      sellerName: 'Болд',
      storeId: 'store-1',
      startTime: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      endTime: DateTime.now().subtract(const Duration(days: 1)),
      totalSales: 210000,
      transactionCount: 32,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    ShiftModel(
      id: 'shift-3',
      sellerId: 'seller-2',
      sellerName: 'Сарнай',
      storeId: 'store-1',
      startTime: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      endTime: DateTime.now().subtract(const Duration(days: 2)),
      totalSales: 185000,
      transactionCount: 27,
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    ),
  ];
}
