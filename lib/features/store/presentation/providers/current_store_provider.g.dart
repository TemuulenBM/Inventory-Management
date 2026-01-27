// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentStoreHash() => r'da2aa57350a6d2b97fbb1da66715f677cdbdfd1b';

/// Одоогийн сонгогдсон дэлгүүрийн мэдээлэл
///
/// userStoresProvider-аас одоогийн storeId-тай тохирох store-ийг олно.
/// API call давхардуулахгүй - аль хэдийн татаж авсан жагсаалтаас хайна.
///
/// Returns: StoreInfo | null
/// - null: storeId байхгүй эсвэл store олдохгүй
/// - StoreInfo: Одоогийн сонгогдсон дэлгүүрийн мэдээлэл (нэр, байршил, role)
///
/// Copied from [currentStore].
@ProviderFor(currentStore)
final currentStoreProvider = AutoDisposeFutureProvider<StoreInfo?>.internal(
  currentStore,
  name: r'currentStoreProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentStoreRef = AutoDisposeFutureProviderRef<StoreInfo?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
