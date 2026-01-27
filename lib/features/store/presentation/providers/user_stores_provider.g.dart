// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stores_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userStoresHash() => r'e96ca3734ef3520de63fbf807a8c65bdb102b10b';

/// Хэрэглэгчийн дэлгүүрүүдийн жагсаалт
///
/// Owner олон дэлгүүртэй байж болох тул
/// store_members-аар бүх дэлгүүрүүдийг авна
///
/// Copied from [UserStores].
@ProviderFor(UserStores)
final userStoresProvider =
    AutoDisposeAsyncNotifierProvider<UserStores, List<StoreInfo>>.internal(
  UserStores.new,
  name: r'userStoresProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userStoresHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserStores = AutoDisposeAsyncNotifier<List<StoreInfo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
