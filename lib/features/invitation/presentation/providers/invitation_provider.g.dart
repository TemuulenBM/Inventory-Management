// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$invitationListHash() => r'8e4b58f6ecbda6edeeb656d389ba073ca89afcc5';

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

/// Урилгын жагсаалт provider
/// GET /invitations
///
/// Copied from [invitationList].
@ProviderFor(invitationList)
const invitationListProvider = InvitationListFamily();

/// Урилгын жагсаалт provider
/// GET /invitations
///
/// Copied from [invitationList].
class InvitationListFamily extends Family<AsyncValue<List<InvitationModel>>> {
  /// Урилгын жагсаалт provider
  /// GET /invitations
  ///
  /// Copied from [invitationList].
  const InvitationListFamily();

  /// Урилгын жагсаалт provider
  /// GET /invitations
  ///
  /// Copied from [invitationList].
  InvitationListProvider call({
    InvitationStatus? status,
  }) {
    return InvitationListProvider(
      status: status,
    );
  }

  @override
  InvitationListProvider getProviderOverride(
    covariant InvitationListProvider provider,
  ) {
    return call(
      status: provider.status,
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
  String? get name => r'invitationListProvider';
}

/// Урилгын жагсаалт provider
/// GET /invitations
///
/// Copied from [invitationList].
class InvitationListProvider
    extends AutoDisposeFutureProvider<List<InvitationModel>> {
  /// Урилгын жагсаалт provider
  /// GET /invitations
  ///
  /// Copied from [invitationList].
  InvitationListProvider({
    InvitationStatus? status,
  }) : this._internal(
          (ref) => invitationList(
            ref as InvitationListRef,
            status: status,
          ),
          from: invitationListProvider,
          name: r'invitationListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$invitationListHash,
          dependencies: InvitationListFamily._dependencies,
          allTransitiveDependencies:
              InvitationListFamily._allTransitiveDependencies,
          status: status,
        );

  InvitationListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final InvitationStatus? status;

  @override
  Override overrideWith(
    FutureOr<List<InvitationModel>> Function(InvitationListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InvitationListProvider._internal(
        (ref) => create(ref as InvitationListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<InvitationModel>> createElement() {
    return _InvitationListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvitationListProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InvitationListRef on AutoDisposeFutureProviderRef<List<InvitationModel>> {
  /// The parameter `status` of this provider.
  InvitationStatus? get status;
}

class _InvitationListProviderElement
    extends AutoDisposeFutureProviderElement<List<InvitationModel>>
    with InvitationListRef {
  _InvitationListProviderElement(super.provider);

  @override
  InvitationStatus? get status => (origin as InvitationListProvider).status;
}

String _$invitationNotifierHash() =>
    r'0f2d55bbe320a9ba24d9c98f11ed6c99a354895d';

/// Урилга үүсгэх/устгах notifier
///
/// Copied from [InvitationNotifier].
@ProviderFor(InvitationNotifier)
final invitationNotifierProvider =
    AutoDisposeNotifierProvider<InvitationNotifier, void>.internal(
  InvitationNotifier.new,
  name: r'invitationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$invitationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InvitationNotifier = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
