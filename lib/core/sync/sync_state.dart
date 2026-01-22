import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

/// Sync status
enum SyncStatus {
  synced,
  syncing,
  pendingChanges,
  offline,
  error,
}

/// Sync state (Freezed union)
@freezed
class SyncState with _$SyncState {
  const factory SyncState({
    required SyncStatus status,
    required bool isOnline,
    required int pendingCount,
    DateTime? lastSyncTime,
    String? errorMessage,
  }) = _SyncState;
}
