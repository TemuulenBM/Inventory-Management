// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shiftServiceHash() => r'a9679758c63a2f06e4a60b1d81b5c0d18104f196';

/// ShiftService provider
///
/// Copied from [shiftService].
@ProviderFor(shiftService)
final shiftServiceProvider = AutoDisposeProvider<ShiftService>.internal(
  shiftService,
  name: r'shiftServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$shiftServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ShiftServiceRef = AutoDisposeProviderRef<ShiftService>;
String _$currentShiftHash() => r'63632f84450404bec7fd5ce460a9fbaaae923a56';

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

/// Current active shift
/// Offline-first: Local DB эхлээд, background-д API refresh
///
/// Copied from [currentShift].
@ProviderFor(currentShift)
const currentShiftProvider = CurrentShiftFamily();

/// Current active shift
/// Offline-first: Local DB эхлээд, background-д API refresh
///
/// Copied from [currentShift].
class CurrentShiftFamily extends Family<AsyncValue<ShiftModel?>> {
  /// Current active shift
  /// Offline-first: Local DB эхлээд, background-д API refresh
  ///
  /// Copied from [currentShift].
  const CurrentShiftFamily();

  /// Current active shift
  /// Offline-first: Local DB эхлээд, background-д API refresh
  ///
  /// Copied from [currentShift].
  CurrentShiftProvider call(
    String storeId,
  ) {
    return CurrentShiftProvider(
      storeId,
    );
  }

  @override
  CurrentShiftProvider getProviderOverride(
    covariant CurrentShiftProvider provider,
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
  String? get name => r'currentShiftProvider';
}

/// Current active shift
/// Offline-first: Local DB эхлээд, background-д API refresh
///
/// Copied from [currentShift].
class CurrentShiftProvider extends AutoDisposeFutureProvider<ShiftModel?> {
  /// Current active shift
  /// Offline-first: Local DB эхлээд, background-д API refresh
  ///
  /// Copied from [currentShift].
  CurrentShiftProvider(
    String storeId,
  ) : this._internal(
          (ref) => currentShift(
            ref as CurrentShiftRef,
            storeId,
          ),
          from: currentShiftProvider,
          name: r'currentShiftProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentShiftHash,
          dependencies: CurrentShiftFamily._dependencies,
          allTransitiveDependencies:
              CurrentShiftFamily._allTransitiveDependencies,
          storeId: storeId,
        );

  CurrentShiftProvider._internal(
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
    FutureOr<ShiftModel?> Function(CurrentShiftRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentShiftProvider._internal(
        (ref) => create(ref as CurrentShiftRef),
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
  AutoDisposeFutureProviderElement<ShiftModel?> createElement() {
    return _CurrentShiftProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentShiftProvider && other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CurrentShiftRef on AutoDisposeFutureProviderRef<ShiftModel?> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _CurrentShiftProviderElement
    extends AutoDisposeFutureProviderElement<ShiftModel?> with CurrentShiftRef {
  _CurrentShiftProviderElement(super.provider);

  @override
  String get storeId => (origin as CurrentShiftProvider).storeId;
}

String _$shiftHistoryHash() => r'127aab050b542a62085426bcc345abbfd87c4fb3';

/// Shift history (past shifts)
///
/// Copied from [shiftHistory].
@ProviderFor(shiftHistory)
const shiftHistoryProvider = ShiftHistoryFamily();

/// Shift history (past shifts)
///
/// Copied from [shiftHistory].
class ShiftHistoryFamily extends Family<AsyncValue<List<ShiftModel>>> {
  /// Shift history (past shifts)
  ///
  /// Copied from [shiftHistory].
  const ShiftHistoryFamily();

  /// Shift history (past shifts)
  ///
  /// Copied from [shiftHistory].
  ShiftHistoryProvider call(
    String storeId, {
    int limit = 20,
  }) {
    return ShiftHistoryProvider(
      storeId,
      limit: limit,
    );
  }

  @override
  ShiftHistoryProvider getProviderOverride(
    covariant ShiftHistoryProvider provider,
  ) {
    return call(
      provider.storeId,
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
  String? get name => r'shiftHistoryProvider';
}

/// Shift history (past shifts)
///
/// Copied from [shiftHistory].
class ShiftHistoryProvider extends AutoDisposeFutureProvider<List<ShiftModel>> {
  /// Shift history (past shifts)
  ///
  /// Copied from [shiftHistory].
  ShiftHistoryProvider(
    String storeId, {
    int limit = 20,
  }) : this._internal(
          (ref) => shiftHistory(
            ref as ShiftHistoryRef,
            storeId,
            limit: limit,
          ),
          from: shiftHistoryProvider,
          name: r'shiftHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shiftHistoryHash,
          dependencies: ShiftHistoryFamily._dependencies,
          allTransitiveDependencies:
              ShiftHistoryFamily._allTransitiveDependencies,
          storeId: storeId,
          limit: limit,
        );

  ShiftHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storeId,
    required this.limit,
  }) : super.internal();

  final String storeId;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<ShiftModel>> Function(ShiftHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShiftHistoryProvider._internal(
        (ref) => create(ref as ShiftHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storeId: storeId,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ShiftModel>> createElement() {
    return _ShiftHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShiftHistoryProvider &&
        other.storeId == storeId &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ShiftHistoryRef on AutoDisposeFutureProviderRef<List<ShiftModel>> {
  /// The parameter `storeId` of this provider.
  String get storeId;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _ShiftHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<ShiftModel>>
    with ShiftHistoryRef {
  _ShiftHistoryProviderElement(super.provider);

  @override
  String get storeId => (origin as ShiftHistoryProvider).storeId;
  @override
  int get limit => (origin as ShiftHistoryProvider).limit;
}

String _$shiftDetailHash() => r'307c10d67a9b6f3908e7730b503fa8707d761ff6';

/// Shift detail
///
/// Copied from [shiftDetail].
@ProviderFor(shiftDetail)
const shiftDetailProvider = ShiftDetailFamily();

/// Shift detail
///
/// Copied from [shiftDetail].
class ShiftDetailFamily extends Family<AsyncValue<ShiftModel?>> {
  /// Shift detail
  ///
  /// Copied from [shiftDetail].
  const ShiftDetailFamily();

  /// Shift detail
  ///
  /// Copied from [shiftDetail].
  ShiftDetailProvider call(
    String storeId,
    String shiftId,
  ) {
    return ShiftDetailProvider(
      storeId,
      shiftId,
    );
  }

  @override
  ShiftDetailProvider getProviderOverride(
    covariant ShiftDetailProvider provider,
  ) {
    return call(
      provider.storeId,
      provider.shiftId,
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
  String? get name => r'shiftDetailProvider';
}

/// Shift detail
///
/// Copied from [shiftDetail].
class ShiftDetailProvider extends AutoDisposeFutureProvider<ShiftModel?> {
  /// Shift detail
  ///
  /// Copied from [shiftDetail].
  ShiftDetailProvider(
    String storeId,
    String shiftId,
  ) : this._internal(
          (ref) => shiftDetail(
            ref as ShiftDetailRef,
            storeId,
            shiftId,
          ),
          from: shiftDetailProvider,
          name: r'shiftDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shiftDetailHash,
          dependencies: ShiftDetailFamily._dependencies,
          allTransitiveDependencies:
              ShiftDetailFamily._allTransitiveDependencies,
          storeId: storeId,
          shiftId: shiftId,
        );

  ShiftDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storeId,
    required this.shiftId,
  }) : super.internal();

  final String storeId;
  final String shiftId;

  @override
  Override overrideWith(
    FutureOr<ShiftModel?> Function(ShiftDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShiftDetailProvider._internal(
        (ref) => create(ref as ShiftDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storeId: storeId,
        shiftId: shiftId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ShiftModel?> createElement() {
    return _ShiftDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShiftDetailProvider &&
        other.storeId == storeId &&
        other.shiftId == shiftId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);
    hash = _SystemHash.combine(hash, shiftId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ShiftDetailRef on AutoDisposeFutureProviderRef<ShiftModel?> {
  /// The parameter `storeId` of this provider.
  String get storeId;

  /// The parameter `shiftId` of this provider.
  String get shiftId;
}

class _ShiftDetailProviderElement
    extends AutoDisposeFutureProviderElement<ShiftModel?> with ShiftDetailRef {
  _ShiftDetailProviderElement(super.provider);

  @override
  String get storeId => (origin as ShiftDetailProvider).storeId;
  @override
  String get shiftId => (origin as ShiftDetailProvider).shiftId;
}

String _$shiftActionsHash() => r'595e9992a0f90b7035495b94cc7c9798058074ef';

/// Shift actions (open, close)
///
/// Copied from [ShiftActions].
@ProviderFor(ShiftActions)
final shiftActionsProvider =
    AutoDisposeAsyncNotifierProvider<ShiftActions, void>.internal(
  ShiftActions.new,
  name: r'shiftActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$shiftActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShiftActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
