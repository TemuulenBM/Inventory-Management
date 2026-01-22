// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertListHash() => r'94b9300e16f6be241edf5ecb964007403fb80dc3';

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

/// Alert list with optional filters
///
/// Copied from [alertList].
@ProviderFor(alertList)
const alertListProvider = AlertListFamily();

/// Alert list with optional filters
///
/// Copied from [alertList].
class AlertListFamily extends Family<AsyncValue<List<AlertModel>>> {
  /// Alert list with optional filters
  ///
  /// Copied from [alertList].
  const AlertListFamily();

  /// Alert list with optional filters
  ///
  /// Copied from [alertList].
  AlertListProvider call({
    AlertSeverity? severityFilter,
    AlertType? typeFilter,
    bool? unresolvedOnly,
  }) {
    return AlertListProvider(
      severityFilter: severityFilter,
      typeFilter: typeFilter,
      unresolvedOnly: unresolvedOnly,
    );
  }

  @override
  AlertListProvider getProviderOverride(
    covariant AlertListProvider provider,
  ) {
    return call(
      severityFilter: provider.severityFilter,
      typeFilter: provider.typeFilter,
      unresolvedOnly: provider.unresolvedOnly,
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
  String? get name => r'alertListProvider';
}

/// Alert list with optional filters
///
/// Copied from [alertList].
class AlertListProvider extends AutoDisposeFutureProvider<List<AlertModel>> {
  /// Alert list with optional filters
  ///
  /// Copied from [alertList].
  AlertListProvider({
    AlertSeverity? severityFilter,
    AlertType? typeFilter,
    bool? unresolvedOnly,
  }) : this._internal(
          (ref) => alertList(
            ref as AlertListRef,
            severityFilter: severityFilter,
            typeFilter: typeFilter,
            unresolvedOnly: unresolvedOnly,
          ),
          from: alertListProvider,
          name: r'alertListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$alertListHash,
          dependencies: AlertListFamily._dependencies,
          allTransitiveDependencies: AlertListFamily._allTransitiveDependencies,
          severityFilter: severityFilter,
          typeFilter: typeFilter,
          unresolvedOnly: unresolvedOnly,
        );

  AlertListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.severityFilter,
    required this.typeFilter,
    required this.unresolvedOnly,
  }) : super.internal();

  final AlertSeverity? severityFilter;
  final AlertType? typeFilter;
  final bool? unresolvedOnly;

  @override
  Override overrideWith(
    FutureOr<List<AlertModel>> Function(AlertListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AlertListProvider._internal(
        (ref) => create(ref as AlertListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        severityFilter: severityFilter,
        typeFilter: typeFilter,
        unresolvedOnly: unresolvedOnly,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AlertModel>> createElement() {
    return _AlertListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AlertListProvider &&
        other.severityFilter == severityFilter &&
        other.typeFilter == typeFilter &&
        other.unresolvedOnly == unresolvedOnly;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, severityFilter.hashCode);
    hash = _SystemHash.combine(hash, typeFilter.hashCode);
    hash = _SystemHash.combine(hash, unresolvedOnly.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AlertListRef on AutoDisposeFutureProviderRef<List<AlertModel>> {
  /// The parameter `severityFilter` of this provider.
  AlertSeverity? get severityFilter;

  /// The parameter `typeFilter` of this provider.
  AlertType? get typeFilter;

  /// The parameter `unresolvedOnly` of this provider.
  bool? get unresolvedOnly;
}

class _AlertListProviderElement
    extends AutoDisposeFutureProviderElement<List<AlertModel>>
    with AlertListRef {
  _AlertListProviderElement(super.provider);

  @override
  AlertSeverity? get severityFilter =>
      (origin as AlertListProvider).severityFilter;
  @override
  AlertType? get typeFilter => (origin as AlertListProvider).typeFilter;
  @override
  bool? get unresolvedOnly => (origin as AlertListProvider).unresolvedOnly;
}

String _$unreadAlertCountHash() => r'15754f303e46d428df4e2fe934794611feb60084';

/// Unread alert count (for badge)
///
/// Copied from [unreadAlertCount].
@ProviderFor(unreadAlertCount)
const unreadAlertCountProvider = UnreadAlertCountFamily();

/// Unread alert count (for badge)
///
/// Copied from [unreadAlertCount].
class UnreadAlertCountFamily extends Family<AsyncValue<int>> {
  /// Unread alert count (for badge)
  ///
  /// Copied from [unreadAlertCount].
  const UnreadAlertCountFamily();

  /// Unread alert count (for badge)
  ///
  /// Copied from [unreadAlertCount].
  UnreadAlertCountProvider call(
    String storeId,
  ) {
    return UnreadAlertCountProvider(
      storeId,
    );
  }

  @override
  UnreadAlertCountProvider getProviderOverride(
    covariant UnreadAlertCountProvider provider,
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
  String? get name => r'unreadAlertCountProvider';
}

/// Unread alert count (for badge)
///
/// Copied from [unreadAlertCount].
class UnreadAlertCountProvider extends AutoDisposeFutureProvider<int> {
  /// Unread alert count (for badge)
  ///
  /// Copied from [unreadAlertCount].
  UnreadAlertCountProvider(
    String storeId,
  ) : this._internal(
          (ref) => unreadAlertCount(
            ref as UnreadAlertCountRef,
            storeId,
          ),
          from: unreadAlertCountProvider,
          name: r'unreadAlertCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unreadAlertCountHash,
          dependencies: UnreadAlertCountFamily._dependencies,
          allTransitiveDependencies:
              UnreadAlertCountFamily._allTransitiveDependencies,
          storeId: storeId,
        );

  UnreadAlertCountProvider._internal(
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
    FutureOr<int> Function(UnreadAlertCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnreadAlertCountProvider._internal(
        (ref) => create(ref as UnreadAlertCountRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _UnreadAlertCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadAlertCountProvider && other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UnreadAlertCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _UnreadAlertCountProviderElement
    extends AutoDisposeFutureProviderElement<int> with UnreadAlertCountRef {
  _UnreadAlertCountProviderElement(super.provider);

  @override
  String get storeId => (origin as UnreadAlertCountProvider).storeId;
}

String _$alertActionsHash() => r'01c559ec61004dbcbed42279a40fef3d7b54da96';

/// Alert actions
///
/// Copied from [AlertActions].
@ProviderFor(AlertActions)
final alertActionsProvider =
    AutoDisposeAsyncNotifierProvider<AlertActions, void>.internal(
  AlertActions.new,
  name: r'alertActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$alertActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
