// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeIdHash() => r'1d21f69e88fa9b53218ecaaaf3cbdc159abf54cb';

/// StoreId provider - Одоогийн хэрэглэгчийн store ID-г авах
/// Auth state-аас автоматаар авна
///
/// Copied from [storeId].
@ProviderFor(storeId)
final storeIdProvider = AutoDisposeProvider<String?>.internal(
  storeId,
  name: r'storeIdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$storeIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StoreIdRef = AutoDisposeProviderRef<String?>;
String _$requireStoreIdHash() => r'1bb188e8196be5cab196dc55781ecf26f6503c52';

/// Required StoreId provider - StoreId байхгүй бол exception throw хийнэ
/// Store-тэй холбоотой бүх provider-уудад ашиглана
///
/// Copied from [requireStoreId].
@ProviderFor(requireStoreId)
final requireStoreIdProvider = AutoDisposeProvider<String>.internal(
  requireStoreId,
  name: r'requireStoreIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$requireStoreIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RequireStoreIdRef = AutoDisposeProviderRef<String>;
String _$currentUserIdHash() => r'2d816fedd0920c1210519281d961d21598c16f19';

/// Current user ID provider
///
/// Copied from [currentUserId].
@ProviderFor(currentUserId)
final currentUserIdProvider = AutoDisposeProvider<String?>.internal(
  currentUserId,
  name: r'currentUserIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserIdRef = AutoDisposeProviderRef<String?>;
String _$requireUserIdHash() => r'728a8df8358247d288f62d52815c9481340a35b3';

/// Required user ID provider
///
/// Copied from [requireUserId].
@ProviderFor(requireUserId)
final requireUserIdProvider = AutoDisposeProvider<String>.internal(
  requireUserId,
  name: r'requireUserIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$requireUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RequireUserIdRef = AutoDisposeProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
