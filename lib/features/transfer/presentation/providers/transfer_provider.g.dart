// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transferListHash() => r'fda659139cb4963a9868b6c125d4b98187613d3c';

/// Шилжүүлгийн жагсаалт авах (backend API-аас)
///
/// Copied from [transferList].
@ProviderFor(transferList)
final transferListProvider =
    AutoDisposeFutureProvider<List<TransferModel>>.internal(
  transferList,
  name: r'transferListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$transferListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransferListRef = AutoDisposeFutureProviderRef<List<TransferModel>>;
String _$availableDestinationStoresHash() =>
    r'e590b6d67fdc560d01dd823849ca5bbe24601b37';

/// Очих боломжтой салбаруудын жагсаалт (шилжүүлэг хийхэд)
/// Owner-ийн бүх салбаруудаас одоогийн салбарыг хасна
///
/// Copied from [availableDestinationStores].
@ProviderFor(availableDestinationStores)
final availableDestinationStoresProvider =
    AutoDisposeFutureProvider<List<Map<String, String>>>.internal(
  availableDestinationStores,
  name: r'availableDestinationStoresProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableDestinationStoresHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AvailableDestinationStoresRef
    = AutoDisposeFutureProviderRef<List<Map<String, String>>>;
String _$createTransferActionHash() =>
    r'3e7f34d82f4061ac188d208249b87aac3415b233';

/// Шилжүүлэг үүсгэх action
///
/// Copied from [CreateTransferAction].
@ProviderFor(CreateTransferAction)
final createTransferActionProvider = AutoDisposeNotifierProvider<
    CreateTransferAction, AsyncValue<void>>.internal(
  CreateTransferAction.new,
  name: r'createTransferActionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createTransferActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreateTransferAction = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
