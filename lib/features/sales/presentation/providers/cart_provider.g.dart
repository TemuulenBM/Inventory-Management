// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$salesServiceHash() => r'bcffb841ce905aa0a174c81bd4488aa31ce718cb';

/// SalesService provider
///
/// Copied from [salesService].
@ProviderFor(salesService)
final salesServiceProvider = AutoDisposeProvider<SalesService>.internal(
  salesService,
  name: r'salesServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$salesServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SalesServiceRef = AutoDisposeProviderRef<SalesService>;
String _$cartTotalHash() => r'269e669015ac6baa8b61eccc7e172684b2d6d118';

/// Cart total (sum of all item subtotals)
///
/// Copied from [cartTotal].
@ProviderFor(cartTotal)
final cartTotalProvider = AutoDisposeProvider<double>.internal(
  cartTotal,
  name: r'cartTotalProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CartTotalRef = AutoDisposeProviderRef<double>;
String _$cartItemCountHash() => r'7c44326ddcfffc9929119f838e6e5195512ab77c';

/// Cart item count
///
/// Copied from [cartItemCount].
@ProviderFor(cartItemCount)
final cartItemCountProvider = AutoDisposeProvider<int>.internal(
  cartItemCount,
  name: r'cartItemCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartItemCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CartItemCountRef = AutoDisposeProviderRef<int>;
String _$salesHistoryHash() => r'7e2647c3e2899934a1d6381a43a615d59dbae783';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Sales history provider
///
/// Copied from [salesHistory].
@ProviderFor(salesHistory)
const salesHistoryProvider = SalesHistoryFamily();

/// Sales history provider
///
/// Copied from [salesHistory].
class SalesHistoryFamily extends Family<AsyncValue<List<SaleWithItems>>> {
  /// Sales history provider
  ///
  /// Copied from [salesHistory].
  const SalesHistoryFamily();

  /// Sales history provider
  ///
  /// Copied from [salesHistory].
  SalesHistoryProvider call({
    int limit = 20,
  }) {
    return SalesHistoryProvider(
      limit: limit,
    );
  }

  @override
  SalesHistoryProvider getProviderOverride(
    covariant SalesHistoryProvider provider,
  ) {
    return call(
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'salesHistoryProvider';
}

/// Sales history provider
///
/// Copied from [salesHistory].
class SalesHistoryProvider
    extends AutoDisposeFutureProvider<List<SaleWithItems>> {
  /// Sales history provider
  ///
  /// Copied from [salesHistory].
  SalesHistoryProvider({
    int limit = 20,
  }) : this._internal(
          (ref) => salesHistory(
            ref as SalesHistoryRef,
            limit: limit,
          ),
          from: salesHistoryProvider,
          name: r'salesHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$salesHistoryHash,
          dependencies: SalesHistoryFamily._dependencies,
          allTransitiveDependencies:
              SalesHistoryFamily._allTransitiveDependencies,
          limit: limit,
        );

  SalesHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<SaleWithItems>> Function(SalesHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SalesHistoryProvider._internal(
        (ref) => create(ref as SalesHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SaleWithItems>> createElement() {
    return _SalesHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SalesHistoryProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SalesHistoryRef on AutoDisposeFutureProviderRef<List<SaleWithItems>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _SalesHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<SaleWithItems>>
    with SalesHistoryRef {
  _SalesHistoryProviderElement(super.provider);

  @override
  int get limit => (origin as SalesHistoryProvider).limit;
}

String _$todaySalesTotalHash() => r'd876ee447a8b859316c3498fe078a2b572ef1836';

/// Today's sales total
///
/// Copied from [todaySalesTotal].
@ProviderFor(todaySalesTotal)
final todaySalesTotalProvider = AutoDisposeFutureProvider<double>.internal(
  todaySalesTotal,
  name: r'todaySalesTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todaySalesTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodaySalesTotalRef = AutoDisposeFutureProviderRef<double>;
String _$yesterdaySalesTotalHash() =>
    r'701f8c088b72532e659e6a208a4dad4bcfb79213';

/// Yesterday's sales total (for growth comparison)
///
/// Copied from [yesterdaySalesTotal].
@ProviderFor(yesterdaySalesTotal)
final yesterdaySalesTotalProvider = AutoDisposeFutureProvider<double>.internal(
  yesterdaySalesTotal,
  name: r'yesterdaySalesTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$yesterdaySalesTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef YesterdaySalesTotalRef = AutoDisposeFutureProviderRef<double>;
String _$topProductsHash() => r'21e95a59fb5a956859cec3b3d4182edb3e0cc57f';

/// Өнөөдрийн шилдэг борлуулалттай бүтээгдэхүүнүүд (Top 5)
///
/// Copied from [topProducts].
@ProviderFor(topProducts)
final topProductsProvider =
    AutoDisposeFutureProvider<List<TopProductItem>>.internal(
  topProducts,
  name: r'topProductsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$topProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TopProductsRef = AutoDisposeFutureProviderRef<List<TopProductItem>>;
String _$cartNotifierHash() => r'2db98b97a7fa24552e82c5956d8ad84b5c6b33d7';

/// Cart state notifier
///
/// Copied from [CartNotifier].
@ProviderFor(CartNotifier)
final cartNotifierProvider =
    AutoDisposeNotifierProvider<CartNotifier, List<CartItem>>.internal(
  CartNotifier.new,
  name: r'cartNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CartNotifier = AutoDisposeNotifier<List<CartItem>>;
String _$checkoutActionsHash() => r'd243516ba5678a160dd287cad1158af4b70b9697';

/// Checkout actions
///
/// Copied from [CheckoutActions].
@ProviderFor(CheckoutActions)
final checkoutActionsProvider =
    AutoDisposeAsyncNotifierProvider<CheckoutActions, void>.internal(
  CheckoutActions.new,
  name: r'checkoutActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkoutActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CheckoutActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
