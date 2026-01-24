import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/core/sync/sync_state.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

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

  Future<void> _checkConnectivity() async {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    if (results.isNotEmpty) {
      _updateOnlineStatus(results.first);
    } else {
      _updateOnlineStatus(ConnectivityResult.none);
    }
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

    state = state.copyWith(status: SyncStatus.syncing);

    try {
      final db = ref.read(databaseProvider);

      // TODO: Implement actual sync logic
      // 1. Get pending items from sync_queue
      // final pendingItems = await db.select(db.syncQueue).get();
      //
      // 2. Send to backend API
      // for (final item in pendingItems) {
      //   await _sendToBackend(item);
      //   await db.delete(db.syncQueue).delete(item);
      // }
      //
      // 3. Fetch latest data from backend
      // await _fetchFromBackend();

      // Mock: Simulate sync delay
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        status: SyncStatus.synced,
        pendingCount: 0,
        lastSyncTime: DateTime.now(),
        errorMessage: null,
      );
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

}

/// Connectivity stream provider
@riverpod
Stream<ConnectivityResult> connectivityStream(ConnectivityStreamRef ref) {
  return Connectivity().onConnectivityChanged.map((List<ConnectivityResult> results) {
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  });
}

/// Is online (convenience provider)
@riverpod
bool isOnline(IsOnlineRef ref) {
  final syncState = ref.watch(syncNotifierProvider);
  return syncState.isOnline;
}
