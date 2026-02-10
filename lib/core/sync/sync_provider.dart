import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/core/sync/sync_queue_manager.dart';
import 'package:retail_control_platform/core/sync/sync_state.dart';
import 'package:retail_control_platform/features/alerts/presentation/providers/alert_provider.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';
import 'package:retail_control_platform/features/shifts/presentation/providers/shift_provider.dart';

part 'sync_provider.g.dart';

/// Sync state notifier
@riverpod
class SyncNotifier extends _$SyncNotifier {
  Timer? _syncTimer;

  @override
  SyncState build() {
    // Check initial connectivity
    _checkConnectivity();

    // Auto-sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (state.isOnline) {
        sync();
      }
    });

    // Clean up timer on dispose
    ref.onDispose(() {
      _syncTimer?.cancel();
    });

    // Listen to connectivity changes
    ref.listen(connectivityStreamProvider, (previous, next) {
      next.whenData((result) {
        _updateOnlineStatus(result);
      });
    });

    // Initial sync - app эхлэхэд автомат sync хийх
    Future.microtask(() {
      _performInitialSync();
    });

    return const SyncState(
      status: SyncStatus.synced,
      isOnline: true,
      pendingCount: 0,
    );
  }

  /// App эхлэхэд нэг удаа sync хийх
  Future<void> _performInitialSync() async {
    // Database migration дуусах хүртэл хүлээх
    // 500ms → 2s (migration time + connectivity check)
    await Future.delayed(const Duration(seconds: 2));

    // Database ready эсэхийг шалгах
    try {
      final db = ref.read(databaseProvider);
      // Simple query - Migration дууссан эсэхийг баталгаажуулах
      await db.select(db.stores).get();
    } catch (e) {
      if (kDebugMode) print('[SyncNotifier] Database not ready, skipping initial sync: $e');
      return;
    }

    if (kDebugMode) print('[SyncNotifier] Database ready, checking sync status...');

    // Online бөгөөд хэзээ ч sync хийгээгүй бол эхлэн sync хийх
    if (state.isOnline && state.lastSyncTime == null) {
      if (kDebugMode) print('[SyncNotifier] Starting initial sync...');
      sync();
    } else {
      if (kDebugMode) print('[SyncNotifier] Initial sync skipped - isOnline: ${state.isOnline}, lastSync: ${state.lastSyncTime}');
    }
  }

  Future<void> _checkConnectivity() async {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();

    // iOS simulator дээр connectivity_plus unreliable байдаг
    // Backend health check fallback хийх
    if (results.isEmpty || results.first == ConnectivityResult.none) {
      if (kDebugMode) print('[SyncNotifier] Connectivity check: none - Trying backend fallback...');
      final backendOnline = await _checkBackendConnectivity();
      if (backendOnline) {
        if (kDebugMode) print('[SyncNotifier] Backend online - Forcing online status');
        _updateOnlineStatus(ConnectivityResult.wifi); // Force online
        return;
      }
    }

    // Connectivity check амжилттай
    if (results.isNotEmpty) {
      _updateOnlineStatus(results.first);
    } else {
      _updateOnlineStatus(ConnectivityResult.none);
    }
  }

  /// Backend холбогдож байгаа эсэхийг шалгах
  ///
  /// iOS simulator дээр connectivity_plus unreliable байдаг тул fallback
  /// Store provider-аас storeId байгаа эсэхийг шалгах
  Future<bool> _checkBackendConnectivity() async {
    try {
      final storeId = ref.read(storeIdProvider);

      // Store ID байгаа эсэхийг шалгах
      // Хэрэв backend холбогдсон бол user login хийж, store олсон байна
      // Super-admin эсвэл store-гүй owner бол false
      return storeId != null && storeId.isNotEmpty;
    } catch (e) {
      // Provider read алдаа
      return false;
    }
  }

  void _updateOnlineStatus(ConnectivityResult result) {
    final isOnline = result != ConnectivityResult.none;
    final wasOnline = state.isOnline;

    // Debug logging - State transition track хийх
    if (isOnline != wasOnline) {
      if (kDebugMode) print('[SyncNotifier] Connectivity changed: $wasOnline → $isOnline ($result)');
    }

    state = state.copyWith(
      isOnline: isOnline,
      status: isOnline
          ? (state.pendingCount > 0
              ? SyncStatus.pendingChanges
              : SyncStatus.synced)
          : SyncStatus.offline,
    );

    // Trigger auto-sync when coming back online
    if (isOnline && state.pendingCount > 0) {
      sync();
    }
  }

  /// Manual sync trigger
  Future<void> sync() async {
    if (!state.isOnline) {
      if (kDebugMode) print('[SyncNotifier] Sync skipped - offline');
      return;
    }

    final storeId = ref.read(storeIdProvider);

    // Super-admin бол skip (silent)
    if (storeId == null) {
      final user = ref.read(currentUserProvider);

      if (user?.role == 'super_admin') {
        state = state.copyWith(
          status: SyncStatus.synced, // ERROR биш SYNCED
          errorMessage: null,
        );
        return;
      }

      // Owner (storeId null) - error
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: 'Store ID байхгүй байна',
      );
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing);

    try {
      final db = ref.read(databaseProvider);
      final syncManager = SyncQueueManager(db: db);

      // Sync хийх (push + pull)
      final result = await syncManager.sync(storeId);

      // Pending count шинэчлэх
      final remaining = await db.getPendingSyncOperations(limit: 100);

      if (result.isSuccess) {
        state = state.copyWith(
          status: remaining.isEmpty ? SyncStatus.synced : SyncStatus.pendingChanges,
          pendingCount: remaining.length,
          lastSyncTime: DateTime.now(),
          errorMessage: null,
        );

        // Provider-уудыг invalidate хийх (data refresh)
        ref.invalidate(productListProvider);
        ref.invalidate(alertListProvider);
        if (storeId.isNotEmpty) {
          ref.invalidate(shiftHistoryProvider(storeId));
        }
      } else {
        state = state.copyWith(
          status: SyncStatus.error,
          pendingCount: remaining.length,
          errorMessage: result.errors.isNotEmpty ? result.errors.first : 'Sync алдаа',
        );
      }
    } catch (e, stack) {
      if (kDebugMode) print('[SyncNotifier] Sync error: $e');
      if (kDebugMode) print('[SyncNotifier] Stack trace: $stack');
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update pending count (called when offline changes are made)
  void updatePendingCount(int count) {
    state = state.copyWith(
      pendingCount: count,
      status: count > 0 ? SyncStatus.pendingChanges : SyncStatus.synced,
    );
  }

  /// Check and update pending count from database
  Future<void> refreshPendingCount() async {
    try {
      final db = ref.read(databaseProvider);
      final pending = await db.getPendingSyncOperations(limit: 100);
      updatePendingCount(pending.length);
    } catch (e) {
      // Ignore
    }
  }
}

/// Connectivity stream provider
@riverpod
Stream<ConnectivityResult> connectivityStream(ConnectivityStreamRef ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  });
}

/// Is online (convenience provider)
@riverpod
bool isOnline(IsOnlineRef ref) {
  final syncState = ref.watch(syncNotifierProvider);
  return syncState.isOnline;
}

/// Pending sync count (convenience provider)
@riverpod
int pendingSyncCount(PendingSyncCountRef ref) {
  final syncState = ref.watch(syncNotifierProvider);
  return syncState.pendingCount;
}
