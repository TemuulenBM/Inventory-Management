import 'package:drift/drift.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/api/api_result.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/core/services/base_service.dart';
import 'package:retail_control_platform/features/shifts/domain/shift_model.dart';
import 'package:uuid/uuid.dart';

/// ShiftService - Ээлжтэй холбоотой бүх үйлдлүүд
/// API + Local Database integration with offline-first pattern
class ShiftService extends BaseService {
  ShiftService({required super.db});

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Идэвхтэй ээлж авах
  Future<ApiResult<ShiftModel?>> getActiveShift(
    String storeId,
    String sellerId,
  ) async {
    try {
      // 1. Local DB-аас унших
      final localShift = await _getLocalActiveShift(storeId, sellerId);

      // 2. Online бол API-аас refresh
      if (await isOnline) {
        _refreshActiveShiftFromApi(storeId);
      }

      return ApiResult.success(localShift);
    } catch (e) {
      log('getActiveShift error: $e');
      return ApiResult.error('Идэвхтэй ээлж унших үед алдаа гарлаа');
    }
  }

  /// Ээлжийн түүх
  Future<ApiResult<List<ShiftModel>>> getShiftHistory(
    String storeId, {
    String? sellerId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // 1. Local DB-аас унших
      final localShifts = await _getLocalShiftHistory(storeId, sellerId, limit);

      // 2. Online бол API-аас refresh
      if (await isOnline) {
        _refreshShiftHistoryFromApi(storeId, sellerId);
      }

      return ApiResult.success(localShifts);
    } catch (e) {
      log('getShiftHistory error: $e');
      return ApiResult.error('Ээлжийн түүх унших үед алдаа гарлаа');
    }
  }

  /// Нэг ээлжийн дэлгэрэнгүй
  Future<ApiResult<ShiftModel?>> getShiftDetail(
    String storeId,
    String shiftId,
  ) async {
    try {
      final shift = await _getLocalShift(shiftId);
      return ApiResult.success(shift);
    } catch (e) {
      log('getShiftDetail error: $e');
      return ApiResult.error('Ээлж унших үед алдаа гарлаа');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Ээлж нээх
  Future<ApiResult<ShiftModel>> openShift(
    String storeId,
    String sellerId,
    String sellerName, {
    int? openBalance,
  }) async {
    final shiftId = const Uuid().v4();
    final now = DateTime.now();

    try {
      // 1. Local DB-д хадгалах
      final shiftCompanion = ShiftsCompanion.insert(
        id: shiftId,
        storeId: storeId,
        sellerId: sellerId,
        openedAt: Value(now),
        openBalance: Value(openBalance),
      );

      await db.into(db.shifts).insert(shiftCompanion);

      // 2. Online бол API руу илгээх
      if (await isOnline) {
        try {
          final response = await api.post(
            ApiEndpoints.openShift(storeId),
            data: {'open_balance': openBalance},
          );

          if (response.data['success'] == true) {
            // Server ID авч local-д update хийх
            final serverId = response.data['shift']['id'];
            if (serverId != null && serverId != shiftId) {
              await _updateLocalShiftId(shiftId, serverId);
            }
          }
        } catch (e) {
          log('API openShift error: $e');
          // Queue for later sync
          await enqueueOperation(
            entityType: 'shift',
            operation: 'open_shift',
            payload: {
              'temp_id': shiftId,
              'store_id': storeId,
              'open_balance': openBalance,
            },
          );
        }
      } else {
        // Offline - queue
        await enqueueOperation(
          entityType: 'shift',
          operation: 'open_shift',
          payload: {
            'temp_id': shiftId,
            'store_id': storeId,
            'open_balance': openBalance,
          },
        );
      }

      // 3. ShiftModel буцаах
      final shift = ShiftModel(
        id: shiftId,
        sellerId: sellerId,
        sellerName: sellerName,
        storeId: storeId,
        startTime: now,
        totalSales: 0,
        transactionCount: 0,
        createdAt: now,
      );

      return ApiResult.success(shift);
    } catch (e) {
      log('openShift error: $e');
      return ApiResult.error('Ээлж нээх үед алдаа гарлаа: $e');
    }
  }

  /// Ээлж хаах
  Future<ApiResult<ShiftModel>> closeShift(
    String storeId,
    String shiftId, {
    int? closeBalance,
  }) async {
    final now = DateTime.now();

    try {
      // 1. Ээлжийн борлуулалт тооцоолох
      final salesData = await _calculateShiftSales(shiftId);

      // 2. Мөнгөн тулгалт (cash reconciliation) тооцоолох
      final currentShift = await (db.select(db.shifts)
            ..where((s) => s.id.equals(shiftId)))
          .getSingleOrNull();
      final openBal = currentShift?.openBalance ?? 0;
      // Бэлэн мөнгөний борлуулалт (зөвхөн cash payment method)
      final cashSalesTotal = await _calculateCashSales(shiftId);
      final expectedBal = openBal + cashSalesTotal;
      // Зөрүү: бодит тоолсон мөнгө - хүлээгдэж буй мөнгө
      final disc = closeBalance != null ? closeBalance - expectedBal : null;

      // 3. Local DB-д update хийх (тулгалтын тоогоор хамт)
      await (db.update(db.shifts)..where((s) => s.id.equals(shiftId))).write(
        ShiftsCompanion(
          closedAt: Value(now),
          closeBalance: Value(closeBalance),
          expectedBalance: Value(expectedBal),
          discrepancy: Value(disc),
        ),
      );

      // 5. Online бол API руу илгээх (reconciliation мэдээлэлтэй)
      final shiftPayload = {
        'shift_id': shiftId,
        'store_id': storeId,
        'close_balance': closeBalance,
        'expected_balance': expectedBal,
        'discrepancy': disc,
      };

      if (await isOnline) {
        try {
          await api.post(
            ApiEndpoints.closeShift(storeId),
            data: shiftPayload,
          );
        } catch (e) {
          log('API closeShift error: $e');
          await enqueueOperation(
            entityType: 'shift',
            operation: 'close_shift',
            payload: shiftPayload,
          );
        }
      } else {
        await enqueueOperation(
          entityType: 'shift',
          operation: 'close_shift',
          payload: shiftPayload,
        );
      }

      // 6. Updated shift буцаах
      final shift = await _getLocalShift(shiftId);
      if (shift == null) {
        return const ApiResult.error('Ээлж олдсонгүй');
      }

      return ApiResult.success(shift.copyWith(
        endTime: now,
        totalSales: salesData['totalSales']!,
        transactionCount: salesData['transactionCount']!.toInt(),
      ));
    } catch (e) {
      log('closeShift error: $e');
      return ApiResult.error('Ээлж хаах үед алдаа гарлаа: $e');
    }
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Local DB-аас идэвхтэй ээлж авах
  /// Хэрэв олон идэвхтэй ээлж байвал auto-cleanup хийнэ (self-healing)
  Future<ShiftModel?> _getLocalActiveShift(String storeId, String sellerId) async {
    // Бүх идэвхтэй ээлж авах
    final allActiveShifts = await (db.select(db.shifts)
          ..where((s) =>
              s.storeId.equals(storeId) &
              s.sellerId.equals(sellerId) &
              s.closedAt.isNull()))
        .get();

    // Хоосон бол null буцаах
    if (allActiveShifts.isEmpty) return null;

    // Хэрэв олон идэвхтэй ээлж байвал auto-cleanup хийх
    if (allActiveShifts.length > 1) {
      log('⚠️ WARNING: ${allActiveShifts.length} active shifts found. Auto-closing old shifts.');

      // Хамгийн сүүлд нээсэн ээлжийг олох
      final latestShift = allActiveShifts.reduce((a, b) =>
          a.openedAt.isAfter(b.openedAt) ? a : b);

      // Бусад хуучин ээлжүүдийг хаах
      for (final oldShift in allActiveShifts) {
        if (oldShift.id != latestShift.id) {
          // Local DB-д ээлж хаах
          await (db.update(db.shifts)..where((s) => s.id.equals(oldShift.id)))
              .write(ShiftsCompanion(
            closedAt: Value(DateTime.now()),
            closeBalance: const Value(null),
          ));

          // Sync queue-д нэмэх (backend-руу sync хийгдэх)
          await enqueueOperation(
            entityType: 'shift',
            operation: 'close_shift',
            payload: {
              'shift_id': oldShift.id,
              'close_balance': null,
              'reason': 'Duplicate active shift cleanup',
            },
          );

          log('Closed duplicate shift: ${oldShift.id}');
        }
      }
    }

    // Хамгийн сүүлд нээсэн ээлжийг буцаах
    final shift = allActiveShifts.reduce((a, b) =>
        a.openedAt.isAfter(b.openedAt) ? a : b);

    // User name авах
    final user = await (db.select(db.users)..where((u) => u.id.equals(shift.sellerId)))
        .getSingleOrNull();

    // Ээлжийн борлуулалт тооцоолох
    final salesData = await _calculateShiftSales(shift.id);

    return ShiftModel(
      id: shift.id,
      sellerId: shift.sellerId,
      sellerName: user?.name ?? 'Unknown',
      storeId: shift.storeId,
      startTime: shift.openedAt,
      endTime: shift.closedAt,
      totalSales: salesData['totalSales']!,
      transactionCount: salesData['transactionCount']!.toInt(),
      createdAt: shift.openedAt,
      openBalance: shift.openBalance,
      closeBalance: shift.closeBalance,
      expectedBalance: shift.expectedBalance,
      discrepancy: shift.discrepancy,
    );
  }

  /// Local DB-аас нэг ээлж авах
  Future<ShiftModel?> _getLocalShift(String shiftId) async {
    final shift = await (db.select(db.shifts)..where((s) => s.id.equals(shiftId)))
        .getSingleOrNull();

    if (shift == null) return null;

    final user = await (db.select(db.users)..where((u) => u.id.equals(shift.sellerId)))
        .getSingleOrNull();

    final salesData = await _calculateShiftSales(shiftId);

    return ShiftModel(
      id: shift.id,
      sellerId: shift.sellerId,
      sellerName: user?.name ?? 'Unknown',
      storeId: shift.storeId,
      startTime: shift.openedAt,
      endTime: shift.closedAt,
      totalSales: salesData['totalSales']!,
      transactionCount: salesData['transactionCount']!.toInt(),
      createdAt: shift.openedAt,
      openBalance: shift.openBalance,
      closeBalance: shift.closeBalance,
      expectedBalance: shift.expectedBalance,
      discrepancy: shift.discrepancy,
    );
  }

  /// Local DB-аас ээлжийн түүх
  Future<List<ShiftModel>> _getLocalShiftHistory(
    String storeId,
    String? sellerId,
    int limit,
  ) async {
    var query = db.select(db.shifts)
      ..where((s) => s.storeId.equals(storeId) & s.closedAt.isNotNull())
      ..orderBy([(s) => OrderingTerm.desc(s.openedAt)])
      ..limit(limit);

    if (sellerId != null) {
      query = query..where((s) => s.sellerId.equals(sellerId));
    }

    final shifts = await query.get();
    if (shifts.isEmpty) return [];

    // Batch query: бүх seller-үүдийг нэг query-ээр авах (N+1 засвар)
    final sellerIds = shifts.map((s) => s.sellerId).toSet().toList();
    final sellers = await (db.select(db.users)
          ..where((u) => u.id.isIn(sellerIds)))
        .get();
    final sellerMap = {for (final s in sellers) s.id: s.name};

    // Batch query: бүх shift-ийн sales-ийг нэг GROUP BY query-ээр авах (N+1 засвар)
    final shiftIds = shifts.map((s) => s.id).toList();
    final allShiftSales = await (db.select(db.sales)
          ..where((s) => s.shiftId.isIn(shiftIds)))
        .get();

    // Shift ID-аар group хийж sales тооцоолох
    final salesByShiftId = <String, List<Sale>>{};
    for (final sale in allShiftSales) {
      if (sale.shiftId != null) {
        salesByShiftId.putIfAbsent(sale.shiftId!, () => []).add(sale);
      }
    }

    return shifts.map((shift) {
      final shiftSales = salesByShiftId[shift.id] ?? [];
      final totalSales = shiftSales.fold<double>(0, (sum, s) => sum + s.totalAmount);
      final transactionCount = shiftSales.length;

      return ShiftModel(
        id: shift.id,
        sellerId: shift.sellerId,
        sellerName: sellerMap[shift.sellerId] ?? 'Unknown',
        storeId: shift.storeId,
        startTime: shift.openedAt,
        endTime: shift.closedAt,
        totalSales: totalSales,
        transactionCount: transactionCount,
        createdAt: shift.openedAt,
        openBalance: shift.openBalance,
        closeBalance: shift.closeBalance,
        expectedBalance: shift.expectedBalance,
        discrepancy: shift.discrepancy,
      );
    }).toList();
  }

  /// Ээлжийн борлуулалт тооцоолох
  Future<Map<String, double>> _calculateShiftSales(String shiftId) async {
    final sales = await (db.select(db.sales)..where((s) => s.shiftId.equals(shiftId))).get();

    final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final transactionCount = sales.length.toDouble();

    return {
      'totalSales': totalSales,
      'transactionCount': transactionCount,
    };
  }

  /// Бэлэн мөнгөний борлуулалт тооцоолох (зөвхөн cash payment method)
  /// Cash reconciliation-д ашиглана: expected = open_balance + cash_sales
  Future<int> _calculateCashSales(String shiftId) async {
    final cashSales = await (db.select(db.sales)
          ..where((s) =>
              s.shiftId.equals(shiftId) &
              s.paymentMethod.equals('cash')))
        .get();

    return cashSales.fold<int>(0, (sum, sale) => sum + sale.totalAmount);
  }

  /// API-аас идэвхтэй ээлж refresh
  Future<void> _refreshActiveShiftFromApi(String storeId) async {
    try {
      final response = await api.get(ApiEndpoints.activeShift(storeId));

      if (response.data['success'] == true && response.data['shift'] != null) {
        final data = response.data['shift'];
        final companion = ShiftsCompanion(
          id: Value(data['id']),
          storeId: Value(storeId),
          sellerId: Value(data['seller_id']),
          openedAt: Value(DateTime.parse(data['opened_at'])),
          openBalance: Value((data['open_balance'] as num?)?.toInt()),
        );

        await db.into(db.shifts).insertOnConflictUpdate(companion);
      }
    } catch (e) {
      log('_refreshActiveShiftFromApi error: $e');
    }
  }

  /// API-аас ээлжийн түүх refresh
  Future<void> _refreshShiftHistoryFromApi(String storeId, String? sellerId) async {
    try {
      final response = await api.get(
        ApiEndpoints.shifts(storeId),
        queryParameters: {
          if (sellerId != null) 'seller_id': sellerId,
          'limit': 20,
        },
      );

      if (response.data['success'] == true) {
        final shiftsData = response.data['shifts'] as List? ?? [];

        for (final data in shiftsData) {
          final companion = ShiftsCompanion(
            id: Value(data['id']),
            storeId: Value(storeId),
            sellerId: Value(data['seller_id']),
            openedAt: Value(DateTime.parse(data['opened_at'])),
            closedAt: data['closed_at'] != null
                ? Value(DateTime.parse(data['closed_at']))
                : const Value.absent(),
            openBalance: Value((data['open_balance'] as num?)?.toInt()),
            closeBalance: Value((data['close_balance'] as num?)?.toInt()),
            expectedBalance: Value((data['expected_balance'] as num?)?.toInt()),
            discrepancy: Value((data['discrepancy'] as num?)?.toInt()),
          );

          await db.into(db.shifts).insertOnConflictUpdate(companion);
        }

        log('Refreshed ${shiftsData.length} shifts from API');
      }
    } catch (e) {
      log('_refreshShiftHistoryFromApi error: $e');
    }
  }

  /// Local shift ID update хийх (server ID-тай солих)
  Future<void> _updateLocalShiftId(String oldId, String newId) async {
    try {
      // TRANSACTION - бүх 3 table атомар байдлаар update хийх
      // Offline ээлж үүсгэхдээ temp UUID генерирүүлдэг, sync дараа server ID-тай солих шаардлагатай
      // Учир нь sales болон inventory_events-д shift_id FK байна
      await db.transaction(() async {
        // 1. Shifts table - Primary key өөрчлөх
        await (db.update(db.shifts)..where((s) => s.id.equals(oldId)))
            .write(ShiftsCompanion(id: Value(newId)));

        // 2. Sales table - shift_id foreign key update хийх
        await (db.update(db.sales)..where((s) => s.shiftId.equals(oldId)))
            .write(SalesCompanion(shiftId: Value(newId)));

        // 3. Inventory events - shift_id foreign key update хийх
        await (db.update(db.inventoryEvents)
              ..where((ie) => ie.shiftId.equals(oldId)))
            .write(InventoryEventsCompanion(shiftId: Value(newId)));
      });

      log('Shift ID mapping complete: $oldId -> $newId');
    } catch (e) {
      log('ERROR: _updateLocalShiftId failed: $e');
      // Transaction failure үед бүх өөрчлөлт rollback хийгдэнэ (Drift автоматаар)
      // Sync operation failed гэж тэмдэглэхийн тулд exception propagate хийх
      rethrow;
    }
  }
}
