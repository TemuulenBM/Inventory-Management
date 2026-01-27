// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'64e68ef891caef3da1e4e2621a495f73a5ce2a50';

/// Database provider (singleton)
///
/// Copied from [database].
@ProviderFor(database)
final databaseProvider = AutoDisposeProvider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DatabaseRef = AutoDisposeProviderRef<AppDatabase>;
String _$productServiceHash() => r'7faf47ff41a55bb68fab695ccf6208dec6cbba84';

/// ProductService provider
///
/// Copied from [productService].
@ProviderFor(productService)
final productServiceProvider = AutoDisposeProvider<ProductService>.internal(
  productService,
  name: r'productServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProductServiceRef = AutoDisposeProviderRef<ProductService>;
String _$productListHash() => r'702b2013d2d146ecda93d6644680f5dd0643b0f4';

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

/// Product list with optional filters
/// Offline-first: Local DB эхлээд, background-д API refresh
///
/// Copied from [productList].
@ProviderFor(productList)
const productListProvider = ProductListFamily();

/// Product list with optional filters
/// Offline-first: Local DB эхлээд, background-д API refresh
///
/// Copied from [productList].
class ProductListFamily extends Family<AsyncValue<List<ProductWithStock>>> {
  /// Product list with optional filters
  /// Offline-first: Local DB эхлээд, background-д API refresh
  ///
  /// Copied from [productList].
  const ProductListFamily();

  /// Product list with optional filters
  /// Offline-first: Local DB эхлээд, background-д API refresh
  ///
  /// Copied from [productList].
  ProductListProvider call({
    String? searchQuery,
    String? category,
  }) {
    return ProductListProvider(
      searchQuery: searchQuery,
      category: category,
    );
  }

  @override
  ProductListProvider getProviderOverride(
    covariant ProductListProvider provider,
  ) {
    return call(
      searchQuery: provider.searchQuery,
      category: provider.category,
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
  String? get name => r'productListProvider';
}

/// Product list with optional filters
/// Offline-first: Local DB эхлээд, background-д API refresh
///
/// Copied from [productList].
class ProductListProvider
    extends AutoDisposeFutureProvider<List<ProductWithStock>> {
  /// Product list with optional filters
  /// Offline-first: Local DB эхлээд, background-д API refresh
  ///
  /// Copied from [productList].
  ProductListProvider({
    String? searchQuery,
    String? category,
  }) : this._internal(
          (ref) => productList(
            ref as ProductListRef,
            searchQuery: searchQuery,
            category: category,
          ),
          from: productListProvider,
          name: r'productListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productListHash,
          dependencies: ProductListFamily._dependencies,
          allTransitiveDependencies:
              ProductListFamily._allTransitiveDependencies,
          searchQuery: searchQuery,
          category: category,
        );

  ProductListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
    required this.category,
  }) : super.internal();

  final String? searchQuery;
  final String? category;

  @override
  Override overrideWith(
    FutureOr<List<ProductWithStock>> Function(ProductListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductListProvider._internal(
        (ref) => create(ref as ProductListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProductWithStock>> createElement() {
    return _ProductListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductListProvider &&
        other.searchQuery == searchQuery &&
        other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProductListRef on AutoDisposeFutureProviderRef<List<ProductWithStock>> {
  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;

  /// The parameter `category` of this provider.
  String? get category;
}

class _ProductListProviderElement
    extends AutoDisposeFutureProviderElement<List<ProductWithStock>>
    with ProductListRef {
  _ProductListProviderElement(super.provider);

  @override
  String? get searchQuery => (origin as ProductListProvider).searchQuery;
  @override
  String? get category => (origin as ProductListProvider).category;
}

String _$productDetailHash() => r'54c2c3959d4879d9c50c52b066127070b72c2026';

/// Single product detail
///
/// Copied from [productDetail].
@ProviderFor(productDetail)
const productDetailProvider = ProductDetailFamily();

/// Single product detail
///
/// Copied from [productDetail].
class ProductDetailFamily extends Family<AsyncValue<ProductWithStock?>> {
  /// Single product detail
  ///
  /// Copied from [productDetail].
  const ProductDetailFamily();

  /// Single product detail
  ///
  /// Copied from [productDetail].
  ProductDetailProvider call(
    String productId,
  ) {
    return ProductDetailProvider(
      productId,
    );
  }

  @override
  ProductDetailProvider getProviderOverride(
    covariant ProductDetailProvider provider,
  ) {
    return call(
      provider.productId,
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
  String? get name => r'productDetailProvider';
}

/// Single product detail
///
/// Copied from [productDetail].
class ProductDetailProvider
    extends AutoDisposeFutureProvider<ProductWithStock?> {
  /// Single product detail
  ///
  /// Copied from [productDetail].
  ProductDetailProvider(
    String productId,
  ) : this._internal(
          (ref) => productDetail(
            ref as ProductDetailRef,
            productId,
          ),
          from: productDetailProvider,
          name: r'productDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productDetailHash,
          dependencies: ProductDetailFamily._dependencies,
          allTransitiveDependencies:
              ProductDetailFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    FutureOr<ProductWithStock?> Function(ProductDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailProvider._internal(
        (ref) => create(ref as ProductDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ProductWithStock?> createElement() {
    return _ProductDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProductDetailRef on AutoDisposeFutureProviderRef<ProductWithStock?> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductDetailProviderElement
    extends AutoDisposeFutureProviderElement<ProductWithStock?>
    with ProductDetailRef {
  _ProductDetailProviderElement(super.provider);

  @override
  String get productId => (origin as ProductDetailProvider).productId;
}

String _$lowStockProductsHash() => r'a5e6ac1a7d2bddb3d43b60376eab98439283890d';

/// Low stock products (for alerts)
///
/// Copied from [lowStockProducts].
@ProviderFor(lowStockProducts)
const lowStockProductsProvider = LowStockProductsFamily();

/// Low stock products (for alerts)
///
/// Copied from [lowStockProducts].
class LowStockProductsFamily
    extends Family<AsyncValue<List<ProductWithStock>>> {
  /// Low stock products (for alerts)
  ///
  /// Copied from [lowStockProducts].
  const LowStockProductsFamily();

  /// Low stock products (for alerts)
  ///
  /// Copied from [lowStockProducts].
  LowStockProductsProvider call(
    String storeId,
  ) {
    return LowStockProductsProvider(
      storeId,
    );
  }

  @override
  LowStockProductsProvider getProviderOverride(
    covariant LowStockProductsProvider provider,
  ) {
    return call(
      provider.storeId,
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
  String? get name => r'lowStockProductsProvider';
}

/// Low stock products (for alerts)
///
/// Copied from [lowStockProducts].
class LowStockProductsProvider
    extends AutoDisposeFutureProvider<List<ProductWithStock>> {
  /// Low stock products (for alerts)
  ///
  /// Copied from [lowStockProducts].
  LowStockProductsProvider(
    String storeId,
  ) : this._internal(
          (ref) => lowStockProducts(
            ref as LowStockProductsRef,
            storeId,
          ),
          from: lowStockProductsProvider,
          name: r'lowStockProductsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lowStockProductsHash,
          dependencies: LowStockProductsFamily._dependencies,
          allTransitiveDependencies:
              LowStockProductsFamily._allTransitiveDependencies,
          storeId: storeId,
        );

  LowStockProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storeId,
  }) : super.internal();

  final String storeId;

  @override
  Override overrideWith(
    FutureOr<List<ProductWithStock>> Function(LowStockProductsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LowStockProductsProvider._internal(
        (ref) => create(ref as LowStockProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storeId: storeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProductWithStock>> createElement() {
    return _LowStockProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LowStockProductsProvider && other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LowStockProductsRef
    on AutoDisposeFutureProviderRef<List<ProductWithStock>> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _LowStockProductsProviderElement
    extends AutoDisposeFutureProviderElement<List<ProductWithStock>>
    with LowStockProductsRef {
  _LowStockProductsProviderElement(super.provider);

  @override
  String get storeId => (origin as LowStockProductsProvider).storeId;
}

String _$searchProductsHash() => r'13acfa18b8cb4484f79576d40d8f788950aa03a2';

/// Search products (debounced)
///
/// Copied from [searchProducts].
@ProviderFor(searchProducts)
const searchProductsProvider = SearchProductsFamily();

/// Search products (debounced)
///
/// Copied from [searchProducts].
class SearchProductsFamily extends Family<AsyncValue<List<ProductWithStock>>> {
  /// Search products (debounced)
  ///
  /// Copied from [searchProducts].
  const SearchProductsFamily();

  /// Search products (debounced)
  ///
  /// Copied from [searchProducts].
  SearchProductsProvider call(
    String query,
  ) {
    return SearchProductsProvider(
      query,
    );
  }

  @override
  SearchProductsProvider getProviderOverride(
    covariant SearchProductsProvider provider,
  ) {
    return call(
      provider.query,
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
  String? get name => r'searchProductsProvider';
}

/// Search products (debounced)
///
/// Copied from [searchProducts].
class SearchProductsProvider
    extends AutoDisposeFutureProvider<List<ProductWithStock>> {
  /// Search products (debounced)
  ///
  /// Copied from [searchProducts].
  SearchProductsProvider(
    String query,
  ) : this._internal(
          (ref) => searchProducts(
            ref as SearchProductsRef,
            query,
          ),
          from: searchProductsProvider,
          name: r'searchProductsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchProductsHash,
          dependencies: SearchProductsFamily._dependencies,
          allTransitiveDependencies:
              SearchProductsFamily._allTransitiveDependencies,
          query: query,
        );

  SearchProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<ProductWithStock>> Function(SearchProductsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchProductsProvider._internal(
        (ref) => create(ref as SearchProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProductWithStock>> createElement() {
    return _SearchProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchProductsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SearchProductsRef
    on AutoDisposeFutureProviderRef<List<ProductWithStock>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchProductsProviderElement
    extends AutoDisposeFutureProviderElement<List<ProductWithStock>>
    with SearchProductsRef {
  _SearchProductsProviderElement(super.provider);

  @override
  String get query => (origin as SearchProductsProvider).query;
}

String _$productActionsHash() => r'97f829fed766107959a97318fd1926208d5cb021';

/// Product actions (create, update, delete)
///
/// Copied from [ProductActions].
@ProviderFor(ProductActions)
final productActionsProvider =
    AutoDisposeAsyncNotifierProvider<ProductActions, void>.internal(
  ProductActions.new,
  name: r'productActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
