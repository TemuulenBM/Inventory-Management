// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryEventServiceHash() =>
    r'ed2a9712889c07f31117db01e2b25dbf78b3e6ba';

/// InventoryEventService provider
///
/// Copied from [inventoryEventService].
@ProviderFor(inventoryEventService)
final inventoryEventServiceProvider =
    AutoDisposeProvider<InventoryEventService>.internal(
  inventoryEventService,
  name: r'inventoryEventServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryEventServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InventoryEventServiceRef
    = AutoDisposeProviderRef<InventoryEventService>;
String _$productInventoryEventsHash() =>
    r'52c5942d17a9d313452c558693491d7b9f87f795';

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

/// Тодорхой барааны түүх авах
/// Filter state-тэй автоматаар холбогдоно
///
/// Copied from [productInventoryEvents].
@ProviderFor(productInventoryEvents)
const productInventoryEventsProvider = ProductInventoryEventsFamily();

/// Тодорхой барааны түүх авах
/// Filter state-тэй автоматаар холбогдоно
///
/// Copied from [productInventoryEvents].
class ProductInventoryEventsFamily
    extends Family<AsyncValue<List<InventoryEventModel>>> {
  /// Тодорхой барааны түүх авах
  /// Filter state-тэй автоматаар холбогдоно
  ///
  /// Copied from [productInventoryEvents].
  const ProductInventoryEventsFamily();

  /// Тодорхой барааны түүх авах
  /// Filter state-тэй автоматаар холбогдоно
  ///
  /// Copied from [productInventoryEvents].
  ProductInventoryEventsProvider call(
    String productId,
  ) {
    return ProductInventoryEventsProvider(
      productId,
    );
  }

  @override
  ProductInventoryEventsProvider getProviderOverride(
    covariant ProductInventoryEventsProvider provider,
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
  String? get name => r'productInventoryEventsProvider';
}

/// Тодорхой барааны түүх авах
/// Filter state-тэй автоматаар холбогдоно
///
/// Copied from [productInventoryEvents].
class ProductInventoryEventsProvider
    extends AutoDisposeFutureProvider<List<InventoryEventModel>> {
  /// Тодорхой барааны түүх авах
  /// Filter state-тэй автоматаар холбогдоно
  ///
  /// Copied from [productInventoryEvents].
  ProductInventoryEventsProvider(
    String productId,
  ) : this._internal(
          (ref) => productInventoryEvents(
            ref as ProductInventoryEventsRef,
            productId,
          ),
          from: productInventoryEventsProvider,
          name: r'productInventoryEventsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productInventoryEventsHash,
          dependencies: ProductInventoryEventsFamily._dependencies,
          allTransitiveDependencies:
              ProductInventoryEventsFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductInventoryEventsProvider._internal(
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
    FutureOr<List<InventoryEventModel>> Function(
            ProductInventoryEventsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductInventoryEventsProvider._internal(
        (ref) => create(ref as ProductInventoryEventsRef),
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
  AutoDisposeFutureProviderElement<List<InventoryEventModel>> createElement() {
    return _ProductInventoryEventsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductInventoryEventsProvider &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProductInventoryEventsRef
    on AutoDisposeFutureProviderRef<List<InventoryEventModel>> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductInventoryEventsProviderElement
    extends AutoDisposeFutureProviderElement<List<InventoryEventModel>>
    with ProductInventoryEventsRef {
  _ProductInventoryEventsProviderElement(super.provider);

  @override
  String get productId => (origin as ProductInventoryEventsProvider).productId;
}

String _$allInventoryEventsHash() =>
    r'a9ae084cfcc6bc6e049381b35a07dd4522ce489e';

/// Бүх барааны events (dashboard/global view)
///
/// Copied from [allInventoryEvents].
@ProviderFor(allInventoryEvents)
final allInventoryEventsProvider =
    AutoDisposeFutureProvider<List<InventoryEventModel>>.internal(
  allInventoryEvents,
  name: r'allInventoryEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allInventoryEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllInventoryEventsRef
    = AutoDisposeFutureProviderRef<List<InventoryEventModel>>;
String _$inventoryEventFilterNotifierHash() =>
    r'99902b3e49d0b486622f63b5a501d50c3dc83da0';

/// Filter state provider
/// Event type болон огноогоор шүүх боломжтой
///
/// Copied from [InventoryEventFilterNotifier].
@ProviderFor(InventoryEventFilterNotifier)
final inventoryEventFilterNotifierProvider = AutoDisposeNotifierProvider<
    InventoryEventFilterNotifier, InventoryEventFilter>.internal(
  InventoryEventFilterNotifier.new,
  name: r'inventoryEventFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryEventFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryEventFilterNotifier
    = AutoDisposeNotifier<InventoryEventFilter>;
String _$adjustmentActionsHash() => r'301e9bc78f4f14a081921803a464fd965c667c2b';

/// Тохируулга нэмэх actions
///
/// Copied from [AdjustmentActions].
@ProviderFor(AdjustmentActions)
final adjustmentActionsProvider =
    AutoDisposeAsyncNotifierProvider<AdjustmentActions, void>.internal(
  AdjustmentActions.new,
  name: r'adjustmentActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adjustmentActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdjustmentActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
