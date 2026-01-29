// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_operations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingSyncOperationsHash() =>
    r'6b5bda6877f7bc1a0a158d30099422844c4590ac';

/// Хүлээгдэж буй sync үйлдлүүдийг авах
///
/// Database-аас шууд pending operations унших (synced = false)
/// Limit 100 - UI дээр харуулах maximum тоо
///
/// Copied from [pendingSyncOperations].
@ProviderFor(pendingSyncOperations)
final pendingSyncOperationsProvider =
    AutoDisposeFutureProvider<List<SyncQueueData>>.internal(
  pendingSyncOperations,
  name: r'pendingSyncOperationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingSyncOperationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingSyncOperationsRef
    = AutoDisposeFutureProviderRef<List<SyncQueueData>>;
String _$failedSyncOperationsHash() =>
    r'0be89c6a86a6a7513c7df308586400ba61cfdb00';

/// Failed operations (retry_count > 0)
///
/// Sync failed болсон үйлдлүүд - retry count нэмэгдсэн
/// Эдгээр үйлдлүүдэд retry/delete action button харуулна
///
/// Copied from [failedSyncOperations].
@ProviderFor(failedSyncOperations)
final failedSyncOperationsProvider =
    AutoDisposeFutureProvider<List<SyncQueueData>>.internal(
  failedSyncOperations,
  name: r'failedSyncOperationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$failedSyncOperationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FailedSyncOperationsRef
    = AutoDisposeFutureProviderRef<List<SyncQueueData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
