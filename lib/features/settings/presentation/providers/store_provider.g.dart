// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeNotifierHash() => r'876e09fd122781d7479601816eb448fee9fdd82b';

/// Store мэдээлэл provider
/// Backend API ашиглан дэлгүүрийн мэдээлэл татаж, шинэчилнэ
///
/// Copied from [StoreNotifier].
@ProviderFor(StoreNotifier)
final storeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<StoreNotifier, StoreModel?>.internal(
  StoreNotifier.new,
  name: r'storeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StoreNotifier = AutoDisposeAsyncNotifier<StoreModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
