// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentShiftHash() => r'c7dc9a1fb8aac6f1439d11bd37d2cf24d2ac3ad4';

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
///
/// Copied from [currentShift].
@ProviderFor(currentShift)
const currentShiftProvider = CurrentShiftFamily();

/// Current active shift
///
/// Copied from [currentShift].
class CurrentShiftFamily extends Family<AsyncValue<ShiftModel?>> {
  /// Current active shift
  ///
  /// Copied from [currentShift].
  const CurrentShiftFamily();

  /// Current active shift
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
///
/// Copied from [currentShift].
class CurrentShiftProvider extends AutoDisposeFutureProvider<ShiftModel?> {
  /// Current active shift
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

String _$shiftHistoryHash() => r'cde81f57a4a7b81f2eadc1ccfd18eb34e1ff7b55';

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

String _$shiftActionsHash() => r'04652818db525baf908d33fc26434472038875c2';

/// Start new shift
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
