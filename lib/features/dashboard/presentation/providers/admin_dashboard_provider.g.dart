// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminAllStoresDashboardHash() =>
    r'f1ddc7633a99f640b9d967ba78a250b98a21b99f';

/// Super-admin бүх дэлгүүрийн dashboard (API-аас)
/// StoreDashboardSummary model-ийг дахин ашиглана (шинэ model хэрэггүй)
///
/// Copied from [adminAllStoresDashboard].
@ProviderFor(adminAllStoresDashboard)
final adminAllStoresDashboardProvider =
    AutoDisposeFutureProvider<List<StoreDashboardSummary>>.internal(
  adminAllStoresDashboard,
  name: r'adminAllStoresDashboardProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminAllStoresDashboardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AdminAllStoresDashboardRef
    = AutoDisposeFutureProviderRef<List<StoreDashboardSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
