import 'package:drift/drift.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/api/api_result.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/core/services/base_service.dart';
import 'package:retail_control_platform/features/inventory/domain/inventory_event_filter.dart';
import 'package:retail_control_platform/features/inventory/domain/inventory_event_model.dart';
import 'package:uuid/uuid.dart';

/// InventoryEventService - Барааны хөдөлгөөний бүх үйлдлүүд
/// Offline-first pattern: Local DB эхлээд, дараа нь API sync
class InventoryEventService extends BaseService {
  InventoryEventService({required super.db});

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Тодорхой барааны түүх авах
  /// Offline-first: Local DB-аас эхлээд унших, background-д API-аас refresh
  Future<ApiResult<List<InventoryEventModel>>> getProductHistory(
    String storeId,
    String productId, {
    InventoryEventFilter? filter,
  }) async {
    try {
      // 1. Local DB-аас унших
      final events = await _getLocalProductEvents(productId, filter);

      // 2. Online бол background-д refresh
      if (await isOnline) {
        _refreshFromApi(storeId, productId);
      }

      return ApiResult.success(events);
    } catch (e) {
      log('getProductHistory error: $e');
      return ApiResult.error('Түүх унших үед алдаа гарлаа: $e');
    }
  }

  /// Бүх барааны events авах (Dashboard эсвэл global view)
  Future<ApiResult<List<InventoryEventModel>>> getAllEvents(
    String storeId, {
    InventoryEventFilter? filter,
  }) async {
    try {
      final events = await _getLocalAllEvents(storeId, filter);

      if (await isOnline) {
        _refreshAllEventsFromApi(storeId);
      }

      return ApiResult.success(events);
    } catch (e) {
      log('getAllEvents error: $e');
      return ApiResult.error('Events унших үед алдаа гарлаа: $e');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Гар тохируулга нэмэх (Manual Adjustment)
  Future<ApiResult<InventoryEventModel>> createAdjustment({
    required String storeId,
    required String productId,
    required String actorId,
    required int qtyChange,
    required String reason,
    String? shiftId,
  }) async {
    final eventId = const Uuid().v4();
    final now = DateTime.now();

    try {
      // 1. Local DB-д хадгалах
      final companion = InventoryEventsCompanion.insert(
        id: eventId,
        storeId: storeId,
        productId: productId,
        type: 'ADJUST',
        qtyChange: qtyChange,
        actorId: actorId,
        shiftId: Value(shiftId),
        reason: Value(reason),
        timestamp: Value(now),
      );
      await db.into(db.inventoryEvents).insert(companion);

      // 2. Actor мэдээлэл авах
      final actor = await (db.select(db.users)
            ..where((u) => u.id.equals(actorId)))
          .getSingleOrNull();

      // 3. Product нэр авах
      final product = await (db.select(db.products)
            ..where((p) => p.id.equals(productId)))
          .getSingleOrNull();

      log('📦 Adjustment created: ${qtyChange > 0 ? '+' : ''}$qtyChange for ${product?.name ?? productId}');

      // 4. Online бол API руу илгээх, offline бол queue-д
      if (await isOnline) {
        _syncEventToApi(storeId, {
          'productId': productId,
          'eventType': 'ADJUST',
          'qtyChange': qtyChange,
          'reason': reason,
          'shiftId': shiftId,
        });
      } else {
        await enqueueOperation(
          entityType: 'inventory_event',
          operation: 'create',
          payload: {
            'temp_id': eventId,
            'store_id': storeId,
            'product_id': productId,
            'event_type': 'ADJUST',
            'qty_change': qtyChange,
            'reason': reason,
            'shift_id': shiftId,
          },
        );
      }

      return ApiResult.success(InventoryEventModel(
        id: eventId,
        storeId: storeId,
        productId: productId,
        type: InventoryEventType.adjust,
        qtyChange: qtyChange,
        timestamp: now,
        actor: EventActor(
          id: actorId,
          name: actor?.name ?? 'Хэрэглэгч',
        ),
        productName: product?.name,
        reason: reason,
        shiftId: shiftId,
      ));
    } catch (e) {
      log('createAdjustment error: $e');
      return ApiResult.error('Тохируулга нэмэх үед алдаа гарлаа: $e');
    }
  }

  // ============================================================================
  // PRIVATE HELPERS - LOCAL DB
  // ============================================================================

  /// Local DB-аас тодорхой барааны events унших
  Future<List<InventoryEventModel>> _getLocalProductEvents(
    String productId,
    InventoryEventFilter? filter,
  ) async {
    // Query builder
    var query = db.select(db.inventoryEvents).join([
      leftOuterJoin(db.users, db.users.id.equalsExp(db.inventoryEvents.actorId)),
      leftOuterJoin(db.products, db.products.id.equalsExp(db.inventoryEvents.productId)),
    ])
      ..where(db.inventoryEvents.productId.equals(productId))
      ..orderBy([OrderingTerm.desc(db.inventoryEvents.timestamp)]);

    // Event type filter
    if (filter?.eventType != null) {
      query.where(db.inventoryEvents.type.equals(filter!.eventType!.value));
    }

    // Date range filter
    if (filter?.startDate != null) {
      query.where(db.inventoryEvents.timestamp.isBiggerOrEqualValue(filter!.startDate!));
    }
    if (filter?.endDate != null) {
      // endDate-ийн өдрийн төгсгөл хүртэл
      final endOfDay = DateTime(
        filter!.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23, 59, 59,
      );
      query.where(db.inventoryEvents.timestamp.isSmallerOrEqualValue(endOfDay));
    }

    // Pagination
    final limit = filter?.limit ?? 20;
    final offset = ((filter?.page ?? 1) - 1) * limit;
    query.limit(limit, offset: offset);

    final results = await query.get();
    return results.map((row) => _mapToModel(row)).toList();
  }

  /// Local DB-аас бүх events унших
  Future<List<InventoryEventModel>> _getLocalAllEvents(
    String storeId,
    InventoryEventFilter? filter,
  ) async {
    var query = db.select(db.inventoryEvents).join([
      leftOuterJoin(db.users, db.users.id.equalsExp(db.inventoryEvents.actorId)),
      leftOuterJoin(db.products, db.products.id.equalsExp(db.inventoryEvents.productId)),
    ])
      ..where(db.inventoryEvents.storeId.equals(storeId))
      ..orderBy([OrderingTerm.desc(db.inventoryEvents.timestamp)]);

    // Event type filter
    if (filter?.eventType != null) {
      query.where(db.inventoryEvents.type.equals(filter!.eventType!.value));
    }

    // Date range filter
    if (filter?.startDate != null) {
      query.where(db.inventoryEvents.timestamp.isBiggerOrEqualValue(filter!.startDate!));
    }
    if (filter?.endDate != null) {
      final endOfDay = DateTime(
        filter!.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23, 59, 59,
      );
      query.where(db.inventoryEvents.timestamp.isSmallerOrEqualValue(endOfDay));
    }

    // Pagination
    final limit = filter?.limit ?? 20;
    final offset = ((filter?.page ?? 1) - 1) * limit;
    query.limit(limit, offset: offset);

    final results = await query.get();
    return results.map((row) => _mapToModel(row)).toList();
  }

  /// DB row-г Model руу хөрвүүлэх
  InventoryEventModel _mapToModel(TypedResult row) {
    final event = row.readTable(db.inventoryEvents);
    final user = row.readTableOrNull(db.users);
    final product = row.readTableOrNull(db.products);

    return InventoryEventModel(
      id: event.id,
      storeId: event.storeId,
      productId: event.productId,
      type: InventoryEventType.fromString(event.type),
      qtyChange: event.qtyChange,
      timestamp: event.timestamp,
      actor: EventActor(
        id: event.actorId,
        name: user?.name ?? 'Хэрэглэгч',
        avatarUrl: null,
      ),
      productName: product?.name,
      shiftId: event.shiftId,
      reason: event.reason,
    );
  }

  // ============================================================================
  // PRIVATE HELPERS - API SYNC
  // ============================================================================

  /// API-аас тодорхой барааны түүх refresh хийх (background)
  Future<void> _refreshFromApi(String storeId, String productId) async {
    try {
      final response = await api.get(
        ApiEndpoints.stockHistory(storeId, productId),
      );

      if (response.data['success'] == true) {
        final events = response.data['events'] as List<dynamic>?;
        if (events != null) {
          for (final eventJson in events) {
            await _upsertEventFromApi(eventJson as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      log('_refreshFromApi error: $e');
    }
  }

  /// API-аас бүх events refresh хийх (background)
  Future<void> _refreshAllEventsFromApi(String storeId) async {
    try {
      final response = await api.get(
        ApiEndpoints.inventoryEvents(storeId),
        queryParameters: {'limit': 100},
      );

      if (response.data['success'] == true) {
        final events = response.data['events'] as List<dynamic>?;
        if (events != null) {
          for (final eventJson in events) {
            await _upsertEventFromApi(eventJson as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      log('_refreshAllEventsFromApi error: $e');
    }
  }

  /// API-аас ирсэн event-ийг local DB-д upsert хийх
  Future<void> _upsertEventFromApi(Map<String, dynamic> json) async {
    try {
      final eventId = json['id'] as String;
      final actorId = json['actorId'] as String;
      final actorName = json['actorName'] as String?;
      final storeId = json['storeId'] as String;

      // 1. Actor (user)-ийг local DB-д upsert хийх
      if (actorName != null && actorName.isNotEmpty) {
        final existingUser = await (db.select(db.users)
              ..where((u) => u.id.equals(actorId)))
            .getSingleOrNull();

        if (existingUser == null) {
          // User байхгүй бол шинээр нэмэх
          await db.into(db.users).insert(UsersCompanion.insert(
                id: actorId,
                storeId: Value(storeId),
                name: actorName,
                role: 'seller', // Default role
              ));
        } else if (existingUser.name != actorName) {
          // Name өөрчлөгдсөн бол update хийх
          await (db.update(db.users)..where((u) => u.id.equals(actorId)))
              .write(UsersCompanion(name: Value(actorName)));
        }
      }

      // 2. Event байгаа эсэхийг шалгах
      final existing = await (db.select(db.inventoryEvents)
            ..where((e) => e.id.equals(eventId)))
          .getSingleOrNull();

      if (existing == null) {
        // Шинээр нэмэх
        final companion = InventoryEventsCompanion.insert(
          id: eventId,
          storeId: storeId,
          productId: json['productId'] as String,
          type: json['eventType'] as String,
          qtyChange: json['qtyChange'] as int,
          actorId: actorId,
          shiftId: Value(json['shiftId'] as String?),
          reason: Value(json['reason'] as String?),
          timestamp: Value(DateTime.parse(json['timestamp'] as String)),
        );
        await db.into(db.inventoryEvents).insert(companion);
      }
    } catch (e) {
      log('_upsertEventFromApi error: $e');
    }
  }

  /// API руу event илгээх (background)
  Future<void> _syncEventToApi(String storeId, Map<String, dynamic> data) async {
    try {
      await api.post(ApiEndpoints.inventoryEvents(storeId), data: data);
    } catch (e) {
      log('_syncEventToApi error: $e');
      // Алдаа гарвал queue-д нэмэх
      await enqueueOperation(
        entityType: 'inventory_event',
        operation: 'create',
        payload: {'store_id': storeId, ...data},
      );
    }
  }
}
