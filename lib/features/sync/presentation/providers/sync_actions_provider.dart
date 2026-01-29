import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/core/providers/database_provider.dart';
import 'package:retail_control_platform/core/sync/sync_provider.dart';
import 'package:retail_control_platform/features/sync/presentation/providers/pending_operations_provider.dart';

part 'sync_actions_provider.g.dart';

/// Sync үйлдлүүдийн action notifier
///
/// Retry, delete operations удирдах
/// Failed operations дээр user retry/delete хийх боломжтой
@riverpod
class SyncActions extends _$SyncActions {
  @override
  FutureOr<void> build() {}

  /// Нэг үйлдлийг дахин оролдох (manual retry)
  ///
  /// SyncNotifier.sync() дуудаж, бүх pending operations sync хийнэ
  /// Sync амжилттай болвол pending operations list-с алга болно
  Future<bool> retryOperation(int syncId) async {
    state = const AsyncValue.loading();

    try {
      // Full sync trigger хийх - бүх pending operations багтаж sync хийгдэнэ
      await ref.read(syncNotifierProvider.notifier).sync();

      state = const AsyncValue.data(null);

      // Invalidate providers to refresh UI
      ref.invalidate(pendingSyncOperationsProvider);
      ref.invalidate(failedSyncOperationsProvider);

      return true;
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }

  /// Үйлдлийг queue-аас устгах (user manually dismiss)
  ///
  /// User алдаатай үйлдлийг sync хийлгүйгээр устгах
  /// Анхаар: Өгөгдөл алдагдаж болно (user баталгаажуулсан үед л ашиглах)
  Future<bool> deleteOperation(int syncId) async {
    state = const AsyncValue.loading();

    try {
      final db = ref.read(databaseProvider);

      // Delete from sync_queue table
      await (db.delete(db.syncQueue)..where((sq) => sq.id.equals(syncId))).go();

      state = const AsyncValue.data(null);

      // Invalidate providers
      ref.invalidate(pendingSyncOperationsProvider);
      ref.invalidate(failedSyncOperationsProvider);

      // Pending count шинэчлэх
      await ref.read(syncNotifierProvider.notifier).refreshPendingCount();

      return true;
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }
}
