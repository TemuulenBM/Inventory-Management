// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$employeeListHash() => r'9d4c59fae7b4e9c5805d2f9280ac9c9900a3532b';

/// Employee list provider
/// Backend API ашиглан ажилтнуудын жагсаалт татаж, CRUD хийнэ
///
/// Copied from [EmployeeList].
@ProviderFor(EmployeeList)
final employeeListProvider = AutoDisposeAsyncNotifierProvider<EmployeeList,
    List<EmployeeModel>>.internal(
  EmployeeList.new,
  name: r'employeeListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$employeeListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EmployeeList = AutoDisposeAsyncNotifier<List<EmployeeModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
