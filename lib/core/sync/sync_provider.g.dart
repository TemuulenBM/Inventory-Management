// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityProviderHash() =>
    r'6cfc331587465939bf19d8599f1c096e4c8702de';

/// Connectivity stream provider
///
/// Copied from [connectivityProvider].
@ProviderFor(connectivityProvider)
final connectivityProviderProvider =
    AutoDisposeStreamProvider<ConnectivityResult>.internal(
  connectivityProvider,
  name: r'connectivityProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ConnectivityProviderRef
    = AutoDisposeStreamProviderRef<ConnectivityResult>;
String _$isOnlineHash() => r'5def1d73cb7152cce8fed7ecf2dfb5d9c3ef3601';

/// Is online (convenience provider)
///
/// Copied from [isOnline].
@ProviderFor(isOnline)
final isOnlineProvider = AutoDisposeProvider<bool>.internal(
  isOnline,
  name: r'isOnlineProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isOnlineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsOnlineRef = AutoDisposeProviderRef<bool>;
String _$syncNotifierHash() => r'33ac5a8849588b266e7d1a52c4a422d0a59dc0a4';

/// Sync state notifier
///
/// Copied from [SyncNotifier].
@ProviderFor(SyncNotifier)
final syncNotifierProvider =
    AutoDisposeNotifierProvider<SyncNotifier, SyncState>.internal(
  SyncNotifier.new,
  name: r'syncNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncNotifier = AutoDisposeNotifier<SyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
