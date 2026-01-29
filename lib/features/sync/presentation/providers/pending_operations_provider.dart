import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/core/providers/database_provider.dart';

part 'pending_operations_provider.g.dart';

/// Хүлээгдэж буй sync үйлдлүүдийг авах
///
/// Database-аас шууд pending operations унших (synced = false)
/// Limit 100 - UI дээр харуулах maximum тоо
@riverpod
Future<List<SyncQueueData>> pendingSyncOperations(
  PendingSyncOperationsRef ref,
) async {
  final db = ref.watch(databaseProvider);

  // Limit 100 - бүх pending үйлдлүүдийг харуулах
  return await db.getPendingSyncOperations(limit: 100);
}

/// Failed operations (retry_count > 0)
///
/// Sync failed болсон үйлдлүүд - retry count нэмэгдсэн
/// Эдгээр үйлдлүүдэд retry/delete action button харуулна
@riverpod
Future<List<SyncQueueData>> failedSyncOperations(
  FailedSyncOperationsRef ref,
) async {
  final db = ref.watch(databaseProvider);
  final allPending = await db.getPendingSyncOperations(limit: 100);

  // Filter: retry_count > 0 болон error_message байгаа
  return allPending.where((op) => op.retryCount > 0).toList();
}
