// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncActionsHash() => r'a12dbc04a96d0e981478db992e6bf149f717a7af';

/// Sync үйлдлүүдийн action notifier
///
/// Retry, delete operations удирдах
/// Failed operations дээр user retry/delete хийх боломжтой
///
/// Copied from [SyncActions].
@ProviderFor(SyncActions)
final syncActionsProvider =
    AutoDisposeAsyncNotifierProvider<SyncActions, void>.internal(
  SyncActions.new,
  name: r'syncActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
