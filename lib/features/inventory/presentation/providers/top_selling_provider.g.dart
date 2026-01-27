// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_selling_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$topSellingProductIdsHash() =>
    r'db0a351fe97f4f6527621a398c76b8e3fb06ff28';

/// Top-selling product IDs (all-time sales)
///
/// Returns: Product IDs-ийн жагсаалт, борлуулалтын дарааллаар (desc)
/// Empty list: Sales data байхгүй бол
///
/// Copied from [topSellingProductIds].
@ProviderFor(topSellingProductIds)
final topSellingProductIdsProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  topSellingProductIds,
  name: r'topSellingProductIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topSellingProductIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TopSellingProductIdsRef = AutoDisposeFutureProviderRef<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
