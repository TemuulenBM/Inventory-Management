// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_browse_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$effectiveStoreIdHash() => r'af380bb7c77f2fa4c1459bf0b8f2a0ef5b476381';

/// Effective store ID — super-admin browse mode эсвэл ердийн storeId
///
/// Super-admin browse mode: adminBrowseStoreProvider-аас авна
/// Ердийн хэрэглэгч: storeIdProvider-аас авна (user.storeId)
///
/// Store-scoped provider-ууд энэ provider-ийг ашиглана:
/// productListProvider, topSellingProductIdsProvider гэх мэт
///
/// Copied from [effectiveStoreId].
@ProviderFor(effectiveStoreId)
final effectiveStoreIdProvider = AutoDisposeProvider<String?>.internal(
  effectiveStoreId,
  name: r'effectiveStoreIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$effectiveStoreIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EffectiveStoreIdRef = AutoDisposeProviderRef<String?>;
String _$isReadOnlyModeHash() => r'4b4353a33a9d83334302bcdd9577f0896dec2d1f';

/// Read-only mode эсэхийг шалгах
/// Super-admin хэрэглэгч ямагт read-only (бичих үйлдэл хийж чадахгүй)
///
/// Copied from [isReadOnlyMode].
@ProviderFor(isReadOnlyMode)
final isReadOnlyModeProvider = AutoDisposeProvider<bool>.internal(
  isReadOnlyMode,
  name: r'isReadOnlyModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isReadOnlyModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsReadOnlyModeRef = AutoDisposeProviderRef<bool>;
String _$adminBrowseStoreHash() => r'fd0763bc28308541aedacc436c4fd3a1f8a4b4d1';

/// Super-admin аль дэлгүүрийг browse хийж байгааг хадгалах
/// Browse mode: super-admin тодорхой дэлгүүрийн бараа, бүртгэлийг read-only харах
///
/// Copied from [AdminBrowseStore].
@ProviderFor(AdminBrowseStore)
final adminBrowseStoreProvider =
    AutoDisposeNotifierProvider<AdminBrowseStore, String?>.internal(
  AdminBrowseStore.new,
  name: r'adminBrowseStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminBrowseStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminBrowseStore = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
