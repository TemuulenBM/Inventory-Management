import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/core/sync/sync_queue_manager.dart';
import 'package:retail_control_platform/core/sync/sync_state.dart';
import 'package:retail_control_platform/features/alerts/presentation/providers/alert_provider.dart';
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

    return const SyncState(
      status: SyncStatus.synced,
      isOnline: true,
      pendingCount: 0,
    );
  }

  /// Интернэт холболтыг шалгах
  Future<void> _checkConnectivity() async {
    // connectivity_plus 5.x дээр checkConnectivity() нь дан ConnectivityResult буцаана
    final result = await Connectivity().checkConnectivity();
    _updateOnlineStatus(result);
  }

  void _updateOnlineStatus(ConnectivityResult result) {
    final isOnline = result != ConnectivityResult.none;
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
      return;
    }

    final storeId = ref.read(storeIdProvider);
    if (storeId == null) {
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
    } catch (e) {
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

/// Интернэт холболтын өөрчлөлтийг сонсох stream provider
@riverpod
Stream<ConnectivityResult> connectivityStream(ConnectivityStreamRef ref) {
  // connectivity_plus 5.x дээр onConnectivityChanged нь Stream<ConnectivityResult> буцаана
  return Connectivity().onConnectivityChanged;
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
