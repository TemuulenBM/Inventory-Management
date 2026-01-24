import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// SyncQueueManager - Offline sync queue удирдах
/// Push: SyncQueue-аас backend руу batch хэлбэрээр илгээх
/// Pull: Backend-аас сүүлийн өөрчлөлтүүдийг татах
class SyncQueueManager {
  final AppDatabase db;
  final ApiClient api = apiClient;

  static const int maxBatchSize = 50;
  static const int maxRetries = 3;
  static const String _lastSyncTimeKey = 'last_sync_time';

  SyncQueueManager({required this.db});

  /// Sync хийх (push + pull)
  Future<SyncResult> sync(String storeId) async {
    final pushResult = await pushPendingOperations(storeId);
    final pullResult = await pullChanges(storeId);

    return SyncResult(
      syncedCount: pushResult.syncedCount + pullResult.syncedCount,
      failedCount: pushResult.failedCount + pullResult.failedCount,
      errors: [...pushResult.errors, ...pullResult.errors],
    );
  }

  // ============================================================================
  // PUSH - SyncQueue-аас backend руу
  // ============================================================================

  /// Хүлээгдэж буй үйлдлүүдийг backend руу илгээх
  Future<SyncResult> pushPendingOperations(String storeId) async {
    final pending = await db.getPendingSyncOperations(limit: maxBatchSize);

    if (pending.isEmpty) {
      return SyncResult.empty();
    }

    _log('Pushing ${pending.length} pending operations...');

    // Group operations by type for batch processing
    final operations = pending.map((op) {
      final payload = jsonDecode(op.payload) as Map<String, dynamic>;
      return {
        'operation_type': _mapOperationType(op.entityType, op.operation),
        'client_id': op.id.toString(),
        'client_timestamp': op.createdAt.toIso8601String(),
        'data': payload,
      };
    }).toList();

    try {
      final response = await api.post(
        ApiEndpoints.sync,
        data: {
          'device_id': await _getDeviceId(),
          'operations': operations,
        },
      );

      if (response.data['success'] == true) {
        final results = response.data['results'] as List? ?? [];
        int synced = 0;
        int failed = 0;
        final errors = <String>[];

        for (final result in results) {
          final syncId = int.parse(result['client_id'].toString());

          if (result['status'] == 'success') {
            await db.markSynced(syncId);
            synced++;

            // Server ID mapping (temp_id -> server_id)
            if (result['server_id'] != null) {
              _log('ID mapping: $syncId -> ${result['server_id']}');
            }
          } else {
            final errorMsg = result['error']?.toString() ?? 'Unknown error';
            await db.incrementRetryCount(syncId, errorMsg);
            failed++;
            errors.add(errorMsg);
          }
        }

        _log('Push complete: $synced synced, $failed failed');

        return SyncResult(
          syncedCount: synced,
          failedCount: failed,
          errors: errors,
        );
      } else {
        final error = response.data['message'] ?? 'Sync failed';
        return SyncResult(syncedCount: 0, failedCount: pending.length, errors: [error]);
      }
    } catch (e) {
      _log('Push error: $e');
      return SyncResult(
        syncedCount: 0,
        failedCount: pending.length,
        errors: [e.toString()],
      );
    }
  }

  // ============================================================================
  // PULL - Backend-аас сүүлийн өөрчлөлтүүд татах
  // ============================================================================

  /// Backend-аас сүүлийн өөрчлөлтүүдийг татах (delta sync)
  Future<SyncResult> pullChanges(String storeId) async {
    try {
      final lastSync = await _getLastSyncTime();
      // ISO 8601 format with timezone (Z = UTC)
      final sinceTime = lastSync ?? DateTime.now().subtract(const Duration(days: 7));
      final sinceStr = '${sinceTime.toUtc().toIso8601String().split('.').first}Z';

      _log('Pulling changes since: $sinceStr');

      final response = await api.get(
        ApiEndpoints.changes(storeId),
        queryParameters: {
          'since': sinceStr,
          'limit': 100,
        },
      );

      if (response.data['success'] == true) {
        final changes = response.data['changes'] as Map<String, dynamic>? ?? {};
        int totalChanges = 0;

        // Process products
        final products = changes['products'] as List? ?? [];
        for (final product in products) {
          await _upsertProduct(product);
          totalChanges++;
        }

        // Process inventory events
        final inventoryEvents = changes['inventory_events'] as List? ?? [];
        for (final event in inventoryEvents) {
          await _upsertInventoryEvent(event);
          totalChanges++;
        }

        // Process shifts
        final shifts = changes['shifts'] as List? ?? [];
        for (final shift in shifts) {
          await _upsertShift(shift);
          totalChanges++;
        }

        // Process alerts
        final alerts = changes['alerts'] as List? ?? [];
        for (final alert in alerts) {
          await _upsertAlert(alert);
          totalChanges++;
        }

        // Update last sync time
        final serverTimestamp = response.data['timestamp'];
        if (serverTimestamp != null) {
          await _setLastSyncTime(DateTime.parse(serverTimestamp));
        } else {
          await _setLastSyncTime(DateTime.now());
        }

        _log('Pull complete: $totalChanges changes');

        return SyncResult(syncedCount: totalChanges, failedCount: 0, errors: []);
      } else {
        return SyncResult(
          syncedCount: 0,
          failedCount: 0,
          errors: [response.data['message'] ?? 'Pull failed'],
        );
      }
    } catch (e) {
      _log('Pull error: $e');
      return SyncResult(syncedCount: 0, failedCount: 0, errors: [e.toString()]);
    }
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Operation type mapping
  String _mapOperationType(String entityType, String operation) {
    switch ('${entityType}_$operation') {
      case 'sale_create_sale':
        return 'create_sale';
      case 'sale_void_sale':
        return 'void_sale';
      case 'product_create':
        return 'create_product';
      case 'product_update':
        return 'update_product';
      case 'inventory_event_create':
        return 'create_inventory_event';
      case 'shift_open_shift':
        return 'open_shift';
      case 'shift_close_shift':
        return 'close_shift';
      case 'alert_resolve':
        return 'resolve_alert';
      default:
        return '${entityType}_$operation';
    }
  }

  /// Device ID авах (persistent)
  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  /// Last sync time авах
  Future<DateTime?> _getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastSyncTimeKey);
    if (timestamp != null) {
      return DateTime.tryParse(timestamp);
    }
    return null;
  }

  /// Last sync time хадгалах
  Future<void> _setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncTimeKey, time.toIso8601String());
  }

  /// Product upsert
  Future<void> _upsertProduct(Map<String, dynamic> data) async {
    try {
      await db.into(db.products).insertOnConflictUpdate(
            ProductsCompanion.insert(
              id: data['id'],
              storeId: data['store_id'],
              name: data['name'],
              sku: data['sku'] ?? '',
              unit: data['unit'] ?? 'piece',
              sellPrice: (data['sell_price'] as num?)?.toDouble() ?? 0,
              costPrice: Value((data['cost_price'] as num?)?.toDouble()),
              lowStockThreshold: Value(data['low_stock_threshold'] ?? 10),
            ),
          );
    } catch (e) {
      _log('_upsertProduct error: $e');
    }
  }

  /// Inventory event upsert
  Future<void> _upsertInventoryEvent(Map<String, dynamic> data) async {
    try {
      await db.into(db.inventoryEvents).insertOnConflictUpdate(
            InventoryEventsCompanion.insert(
              id: data['id'],
              storeId: data['store_id'],
              productId: data['product_id'],
              type: data['event_type'] ?? 'ADJUST',
              qtyChange: data['qty_change'] ?? 0,
              actorId: data['actor_id'],
              shiftId: Value(data['shift_id']),
              reason: Value(data['reason']),
              timestamp: Value(DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now()),
            ),
          );
    } catch (e) {
      _log('_upsertInventoryEvent error: $e');
    }
  }

  /// Shift upsert
  Future<void> _upsertShift(Map<String, dynamic> data) async {
    try {
      await db.into(db.shifts).insertOnConflictUpdate(
            ShiftsCompanion.insert(
              id: data['id'],
              storeId: data['store_id'],
              sellerId: data['seller_id'],
              openedAt: Value(DateTime.tryParse(data['opened_at'] ?? '') ?? DateTime.now()),
              closedAt: Value(DateTime.tryParse(data['closed_at'] ?? '')),
              openBalance: Value((data['open_balance'] as num?)?.toDouble()),
              closeBalance: Value((data['close_balance'] as num?)?.toDouble()),
            ),
          );
    } catch (e) {
      _log('_upsertShift error: $e');
    }
  }

  /// Alert upsert
  Future<void> _upsertAlert(Map<String, dynamic> data) async {
    try {
      await db.into(db.alerts).insertOnConflictUpdate(
            AlertsCompanion.insert(
              id: data['id'],
              storeId: data['store_id'],
              type: data['alert_type'] ?? 'system',
              productId: Value(data['product_id']),
              message: data['message'] ?? '',
              level: Value(data['level'] ?? 'info'),
              resolved: Value(data['resolved'] ?? false),
            ),
          );
    } catch (e) {
      _log('_upsertAlert error: $e');
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      print('[SyncQueueManager] $message');
    }
  }
}

/// Sync result
class SyncResult {
  final int syncedCount;
  final int failedCount;
  final List<String> errors;

  SyncResult({
    required this.syncedCount,
    required this.failedCount,
    required this.errors,
  });

  factory SyncResult.empty() => SyncResult(
        syncedCount: 0,
        failedCount: 0,
        errors: [],
      );

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => failedCount == 0 && errors.isEmpty;
}
