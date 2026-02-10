// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShiftModel _$ShiftModelFromJson(Map<String, dynamic> json) {
  return _ShiftModel.fromJson(json);
}

/// @nodoc
mixin _$ShiftModel {
  String get id => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  String get sellerName => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  double get totalSales => throw _privateConstructorUsedError;
  int get transactionCount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Ээлж эхлэх мөнгө
  int? get openBalance => throw _privateConstructorUsedError;

  /// Ээлж хаах мөнгө (бодит тоолсон)
  int? get closeBalance => throw _privateConstructorUsedError;

  /// Хүлээгдэж буй мөнгө (open_balance + cash борлуулалт)
  int? get expectedBalance => throw _privateConstructorUsedError;

  /// Мөнгөн зөрүү (close_balance - expected_balance)
  int? get discrepancy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShiftModelCopyWith<ShiftModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShiftModelCopyWith<$Res> {
  factory $ShiftModelCopyWith(
          ShiftModel value, $Res Function(ShiftModel) then) =
      _$ShiftModelCopyWithImpl<$Res, ShiftModel>;
  @useResult
  $Res call(
      {String id,
      String sellerId,
      String sellerName,
      String storeId,
      DateTime startTime,
      DateTime? endTime,
      double totalSales,
      int transactionCount,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt,
      int? openBalance,
      int? closeBalance,
      int? expectedBalance,
      int? discrepancy});
}

/// @nodoc
class _$ShiftModelCopyWithImpl<$Res, $Val extends ShiftModel>
    implements $ShiftModelCopyWith<$Res> {
  _$ShiftModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerId = null,
    Object? sellerName = null,
    Object? storeId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? totalSales = null,
    Object? transactionCount = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? openBalance = freezed,
    Object? closeBalance = freezed,
    Object? expectedBalance = freezed,
    Object? discrepancy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      sellerName: null == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalSales: null == totalSales
          ? _value.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as double,
      transactionCount: null == transactionCount
          ? _value.transactionCount
          : transactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      openBalance: freezed == openBalance
          ? _value.openBalance
          : openBalance // ignore: cast_nullable_to_non_nullable
              as int?,
      closeBalance: freezed == closeBalance
          ? _value.closeBalance
          : closeBalance // ignore: cast_nullable_to_non_nullable
              as int?,
      expectedBalance: freezed == expectedBalance
          ? _value.expectedBalance
          : expectedBalance // ignore: cast_nullable_to_non_nullable
              as int?,
      discrepancy: freezed == discrepancy
          ? _value.discrepancy
          : discrepancy // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShiftModelImplCopyWith<$Res>
    implements $ShiftModelCopyWith<$Res> {
  factory _$$ShiftModelImplCopyWith(
          _$ShiftModelImpl value, $Res Function(_$ShiftModelImpl) then) =
      __$$ShiftModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String sellerId,
      String sellerName,
      String storeId,
      DateTime startTime,
      DateTime? endTime,
      double totalSales,
      int transactionCount,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt,
      int? openBalance,
      int? closeBalance,
      int? expectedBalance,
      int? discrepancy});
}

/// @nodoc
class __$$ShiftModelImplCopyWithImpl<$Res>
    extends _$ShiftModelCopyWithImpl<$Res, _$ShiftModelImpl>
    implements _$$ShiftModelImplCopyWith<$Res> {
  __$$ShiftModelImplCopyWithImpl(
      _$ShiftModelImpl _value, $Res Function(_$ShiftModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerId = null,
    Object? sellerName = null,
    Object? storeId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? totalSales = null,
    Object? transactionCount = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? openBalance = freezed,
    Object? closeBalance = freezed,
    Object? expectedBalance = freezed,
    Object? discrepancy = freezed,
  }) {
    return _then(_$ShiftModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      sellerName: null == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalSales: null == totalSales
          ? _value.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as double,
      transactionCount: null == transactionCount
          ? _value.transactionCount
          : transactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      openBalance: freezed == openBalance
          ? _value.openBalance
          : openBalance // ignore: cast_nullable_to_non_nullable
              as int?,
      closeBalance: freezed == closeBalance
          ? _value.closeBalance
          : closeBalance // ignore: cast_nullable_to_non_nullable
              as int?,
      expectedBalance: freezed == expectedBalance
          ? _value.expectedBalance
          : expectedBalance // ignore: cast_nullable_to_non_nullable
              as int?,
      discrepancy: freezed == discrepancy
          ? _value.discrepancy
          : discrepancy // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShiftModelImpl extends _ShiftModel {
  const _$ShiftModelImpl(
      {required this.id,
      required this.sellerId,
      required this.sellerName,
      required this.storeId,
      required this.startTime,
      this.endTime,
      required this.totalSales,
      required this.transactionCount,
      this.notes,
      this.createdAt,
      this.updatedAt,
      this.openBalance,
      this.closeBalance,
      this.expectedBalance,
      this.discrepancy})
      : super._();

  factory _$ShiftModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShiftModelImplFromJson(json);

  @override
  final String id;
  @override
  final String sellerId;
  @override
  final String sellerName;
  @override
  final String storeId;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final double totalSales;
  @override
  final int transactionCount;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Ээлж эхлэх мөнгө
  @override
  final int? openBalance;

  /// Ээлж хаах мөнгө (бодит тоолсон)
  @override
  final int? closeBalance;

  /// Хүлээгдэж буй мөнгө (open_balance + cash борлуулалт)
  @override
  final int? expectedBalance;

  /// Мөнгөн зөрүү (close_balance - expected_balance)
  @override
  final int? discrepancy;

  @override
  String toString() {
    return 'ShiftModel(id: $id, sellerId: $sellerId, sellerName: $sellerName, storeId: $storeId, startTime: $startTime, endTime: $endTime, totalSales: $totalSales, transactionCount: $transactionCount, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, openBalance: $openBalance, closeBalance: $closeBalance, expectedBalance: $expectedBalance, discrepancy: $discrepancy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShiftModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.transactionCount, transactionCount) ||
                other.transactionCount == transactionCount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.openBalance, openBalance) ||
                other.openBalance == openBalance) &&
            (identical(other.closeBalance, closeBalance) ||
                other.closeBalance == closeBalance) &&
            (identical(other.expectedBalance, expectedBalance) ||
                other.expectedBalance == expectedBalance) &&
            (identical(other.discrepancy, discrepancy) ||
                other.discrepancy == discrepancy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      sellerId,
      sellerName,
      storeId,
      startTime,
      endTime,
      totalSales,
      transactionCount,
      notes,
      createdAt,
      updatedAt,
      openBalance,
      closeBalance,
      expectedBalance,
      discrepancy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShiftModelImplCopyWith<_$ShiftModelImpl> get copyWith =>
      __$$ShiftModelImplCopyWithImpl<_$ShiftModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShiftModelImplToJson(
      this,
    );
  }
}

abstract class _ShiftModel extends ShiftModel {
  const factory _ShiftModel(
      {required final String id,
      required final String sellerId,
      required final String sellerName,
      required final String storeId,
      required final DateTime startTime,
      final DateTime? endTime,
      required final double totalSales,
      required final int transactionCount,
      final String? notes,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final int? openBalance,
      final int? closeBalance,
      final int? expectedBalance,
      final int? discrepancy}) = _$ShiftModelImpl;
  const _ShiftModel._() : super._();

  factory _ShiftModel.fromJson(Map<String, dynamic> json) =
      _$ShiftModelImpl.fromJson;

  @override
  String get id;
  @override
  String get sellerId;
  @override
  String get sellerName;
  @override
  String get storeId;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  double get totalSales;
  @override
  int get transactionCount;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override

  /// Ээлж эхлэх мөнгө
  int? get openBalance;
  @override

  /// Ээлж хаах мөнгө (бодит тоолсон)
  int? get closeBalance;
  @override

  /// Хүлээгдэж буй мөнгө (open_balance + cash борлуулалт)
  int? get expectedBalance;
  @override

  /// Мөнгөн зөрүү (close_balance - expected_balance)
  int? get discrepancy;
  @override
  @JsonKey(ignore: true)
  _$$ShiftModelImplCopyWith<_$ShiftModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
