// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransferModel _$TransferModelFromJson(Map<String, dynamic> json) {
  return _TransferModel.fromJson(json);
}

/// @nodoc
mixin _$TransferModel {
  String get id => throw _privateConstructorUsedError;
  TransferStore get sourceStore => throw _privateConstructorUsedError;
  TransferStore get destinationStore => throw _privateConstructorUsedError;
  TransferUser get initiatedBy => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<TransferItemModel> get items => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransferModelCopyWith<TransferModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferModelCopyWith<$Res> {
  factory $TransferModelCopyWith(
          TransferModel value, $Res Function(TransferModel) then) =
      _$TransferModelCopyWithImpl<$Res, TransferModel>;
  @useResult
  $Res call(
      {String id,
      TransferStore sourceStore,
      TransferStore destinationStore,
      TransferUser initiatedBy,
      String status,
      String? notes,
      List<TransferItemModel> items,
      String createdAt,
      String? completedAt});

  $TransferStoreCopyWith<$Res> get sourceStore;
  $TransferStoreCopyWith<$Res> get destinationStore;
  $TransferUserCopyWith<$Res> get initiatedBy;
}

/// @nodoc
class _$TransferModelCopyWithImpl<$Res, $Val extends TransferModel>
    implements $TransferModelCopyWith<$Res> {
  _$TransferModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceStore = null,
    Object? destinationStore = null,
    Object? initiatedBy = null,
    Object? status = null,
    Object? notes = freezed,
    Object? items = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sourceStore: null == sourceStore
          ? _value.sourceStore
          : sourceStore // ignore: cast_nullable_to_non_nullable
              as TransferStore,
      destinationStore: null == destinationStore
          ? _value.destinationStore
          : destinationStore // ignore: cast_nullable_to_non_nullable
              as TransferStore,
      initiatedBy: null == initiatedBy
          ? _value.initiatedBy
          : initiatedBy // ignore: cast_nullable_to_non_nullable
              as TransferUser,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TransferItemModel>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TransferStoreCopyWith<$Res> get sourceStore {
    return $TransferStoreCopyWith<$Res>(_value.sourceStore, (value) {
      return _then(_value.copyWith(sourceStore: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TransferStoreCopyWith<$Res> get destinationStore {
    return $TransferStoreCopyWith<$Res>(_value.destinationStore, (value) {
      return _then(_value.copyWith(destinationStore: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TransferUserCopyWith<$Res> get initiatedBy {
    return $TransferUserCopyWith<$Res>(_value.initiatedBy, (value) {
      return _then(_value.copyWith(initiatedBy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TransferModelImplCopyWith<$Res>
    implements $TransferModelCopyWith<$Res> {
  factory _$$TransferModelImplCopyWith(
          _$TransferModelImpl value, $Res Function(_$TransferModelImpl) then) =
      __$$TransferModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TransferStore sourceStore,
      TransferStore destinationStore,
      TransferUser initiatedBy,
      String status,
      String? notes,
      List<TransferItemModel> items,
      String createdAt,
      String? completedAt});

  @override
  $TransferStoreCopyWith<$Res> get sourceStore;
  @override
  $TransferStoreCopyWith<$Res> get destinationStore;
  @override
  $TransferUserCopyWith<$Res> get initiatedBy;
}

/// @nodoc
class __$$TransferModelImplCopyWithImpl<$Res>
    extends _$TransferModelCopyWithImpl<$Res, _$TransferModelImpl>
    implements _$$TransferModelImplCopyWith<$Res> {
  __$$TransferModelImplCopyWithImpl(
      _$TransferModelImpl _value, $Res Function(_$TransferModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceStore = null,
    Object? destinationStore = null,
    Object? initiatedBy = null,
    Object? status = null,
    Object? notes = freezed,
    Object? items = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$TransferModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sourceStore: null == sourceStore
          ? _value.sourceStore
          : sourceStore // ignore: cast_nullable_to_non_nullable
              as TransferStore,
      destinationStore: null == destinationStore
          ? _value.destinationStore
          : destinationStore // ignore: cast_nullable_to_non_nullable
              as TransferStore,
      initiatedBy: null == initiatedBy
          ? _value.initiatedBy
          : initiatedBy // ignore: cast_nullable_to_non_nullable
              as TransferUser,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TransferItemModel>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferModelImpl extends _TransferModel {
  const _$TransferModelImpl(
      {required this.id,
      required this.sourceStore,
      required this.destinationStore,
      required this.initiatedBy,
      required this.status,
      this.notes,
      required final List<TransferItemModel> items,
      required this.createdAt,
      this.completedAt})
      : _items = items,
        super._();

  factory _$TransferModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferModelImplFromJson(json);

  @override
  final String id;
  @override
  final TransferStore sourceStore;
  @override
  final TransferStore destinationStore;
  @override
  final TransferUser initiatedBy;
  @override
  final String status;
  @override
  final String? notes;
  final List<TransferItemModel> _items;
  @override
  List<TransferItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String createdAt;
  @override
  final String? completedAt;

  @override
  String toString() {
    return 'TransferModel(id: $id, sourceStore: $sourceStore, destinationStore: $destinationStore, initiatedBy: $initiatedBy, status: $status, notes: $notes, items: $items, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sourceStore, sourceStore) ||
                other.sourceStore == sourceStore) &&
            (identical(other.destinationStore, destinationStore) ||
                other.destinationStore == destinationStore) &&
            (identical(other.initiatedBy, initiatedBy) ||
                other.initiatedBy == initiatedBy) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      sourceStore,
      destinationStore,
      initiatedBy,
      status,
      notes,
      const DeepCollectionEquality().hash(_items),
      createdAt,
      completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferModelImplCopyWith<_$TransferModelImpl> get copyWith =>
      __$$TransferModelImplCopyWithImpl<_$TransferModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferModelImplToJson(
      this,
    );
  }
}

abstract class _TransferModel extends TransferModel {
  const factory _TransferModel(
      {required final String id,
      required final TransferStore sourceStore,
      required final TransferStore destinationStore,
      required final TransferUser initiatedBy,
      required final String status,
      final String? notes,
      required final List<TransferItemModel> items,
      required final String createdAt,
      final String? completedAt}) = _$TransferModelImpl;
  const _TransferModel._() : super._();

  factory _TransferModel.fromJson(Map<String, dynamic> json) =
      _$TransferModelImpl.fromJson;

  @override
  String get id;
  @override
  TransferStore get sourceStore;
  @override
  TransferStore get destinationStore;
  @override
  TransferUser get initiatedBy;
  @override
  String get status;
  @override
  String? get notes;
  @override
  List<TransferItemModel> get items;
  @override
  String get createdAt;
  @override
  String? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$TransferModelImplCopyWith<_$TransferModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TransferStore _$TransferStoreFromJson(Map<String, dynamic> json) {
  return _TransferStore.fromJson(json);
}

/// @nodoc
mixin _$TransferStore {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransferStoreCopyWith<TransferStore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferStoreCopyWith<$Res> {
  factory $TransferStoreCopyWith(
          TransferStore value, $Res Function(TransferStore) then) =
      _$TransferStoreCopyWithImpl<$Res, TransferStore>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$TransferStoreCopyWithImpl<$Res, $Val extends TransferStore>
    implements $TransferStoreCopyWith<$Res> {
  _$TransferStoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransferStoreImplCopyWith<$Res>
    implements $TransferStoreCopyWith<$Res> {
  factory _$$TransferStoreImplCopyWith(
          _$TransferStoreImpl value, $Res Function(_$TransferStoreImpl) then) =
      __$$TransferStoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$TransferStoreImplCopyWithImpl<$Res>
    extends _$TransferStoreCopyWithImpl<$Res, _$TransferStoreImpl>
    implements _$$TransferStoreImplCopyWith<$Res> {
  __$$TransferStoreImplCopyWithImpl(
      _$TransferStoreImpl _value, $Res Function(_$TransferStoreImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$TransferStoreImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferStoreImpl implements _TransferStore {
  const _$TransferStoreImpl({required this.id, required this.name});

  factory _$TransferStoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferStoreImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'TransferStore(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferStoreImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferStoreImplCopyWith<_$TransferStoreImpl> get copyWith =>
      __$$TransferStoreImplCopyWithImpl<_$TransferStoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferStoreImplToJson(
      this,
    );
  }
}

abstract class _TransferStore implements TransferStore {
  const factory _TransferStore(
      {required final String id,
      required final String name}) = _$TransferStoreImpl;

  factory _TransferStore.fromJson(Map<String, dynamic> json) =
      _$TransferStoreImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$TransferStoreImplCopyWith<_$TransferStoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TransferUser _$TransferUserFromJson(Map<String, dynamic> json) {
  return _TransferUser.fromJson(json);
}

/// @nodoc
mixin _$TransferUser {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransferUserCopyWith<TransferUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferUserCopyWith<$Res> {
  factory $TransferUserCopyWith(
          TransferUser value, $Res Function(TransferUser) then) =
      _$TransferUserCopyWithImpl<$Res, TransferUser>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$TransferUserCopyWithImpl<$Res, $Val extends TransferUser>
    implements $TransferUserCopyWith<$Res> {
  _$TransferUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransferUserImplCopyWith<$Res>
    implements $TransferUserCopyWith<$Res> {
  factory _$$TransferUserImplCopyWith(
          _$TransferUserImpl value, $Res Function(_$TransferUserImpl) then) =
      __$$TransferUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$TransferUserImplCopyWithImpl<$Res>
    extends _$TransferUserCopyWithImpl<$Res, _$TransferUserImpl>
    implements _$$TransferUserImplCopyWith<$Res> {
  __$$TransferUserImplCopyWithImpl(
      _$TransferUserImpl _value, $Res Function(_$TransferUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$TransferUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferUserImpl implements _TransferUser {
  const _$TransferUserImpl({required this.id, required this.name});

  factory _$TransferUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferUserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'TransferUser(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferUserImplCopyWith<_$TransferUserImpl> get copyWith =>
      __$$TransferUserImplCopyWithImpl<_$TransferUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferUserImplToJson(
      this,
    );
  }
}

abstract class _TransferUser implements TransferUser {
  const factory _TransferUser(
      {required final String id,
      required final String name}) = _$TransferUserImpl;

  factory _TransferUser.fromJson(Map<String, dynamic> json) =
      _$TransferUserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$TransferUserImplCopyWith<_$TransferUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TransferItemModel _$TransferItemModelFromJson(Map<String, dynamic> json) {
  return _TransferItemModel.fromJson(json);
}

/// @nodoc
mixin _$TransferItemModel {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransferItemModelCopyWith<TransferItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferItemModelCopyWith<$Res> {
  factory $TransferItemModelCopyWith(
          TransferItemModel value, $Res Function(TransferItemModel) then) =
      _$TransferItemModelCopyWithImpl<$Res, TransferItemModel>;
  @useResult
  $Res call({String id, String productId, String productName, int quantity});
}

/// @nodoc
class _$TransferItemModelCopyWithImpl<$Res, $Val extends TransferItemModel>
    implements $TransferItemModelCopyWith<$Res> {
  _$TransferItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransferItemModelImplCopyWith<$Res>
    implements $TransferItemModelCopyWith<$Res> {
  factory _$$TransferItemModelImplCopyWith(_$TransferItemModelImpl value,
          $Res Function(_$TransferItemModelImpl) then) =
      __$$TransferItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String productId, String productName, int quantity});
}

/// @nodoc
class __$$TransferItemModelImplCopyWithImpl<$Res>
    extends _$TransferItemModelCopyWithImpl<$Res, _$TransferItemModelImpl>
    implements _$$TransferItemModelImplCopyWith<$Res> {
  __$$TransferItemModelImplCopyWithImpl(_$TransferItemModelImpl _value,
      $Res Function(_$TransferItemModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
  }) {
    return _then(_$TransferItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferItemModelImpl implements _TransferItemModel {
  const _$TransferItemModelImpl(
      {required this.id,
      required this.productId,
      required this.productName,
      required this.quantity});

  factory _$TransferItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferItemModelImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final int quantity;

  @override
  String toString() {
    return 'TransferItemModel(id: $id, productId: $productId, productName: $productName, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, productId, productName, quantity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferItemModelImplCopyWith<_$TransferItemModelImpl> get copyWith =>
      __$$TransferItemModelImplCopyWithImpl<_$TransferItemModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferItemModelImplToJson(
      this,
    );
  }
}

abstract class _TransferItemModel implements TransferItemModel {
  const factory _TransferItemModel(
      {required final String id,
      required final String productId,
      required final String productName,
      required final int quantity}) = _$TransferItemModelImpl;

  factory _TransferItemModel.fromJson(Map<String, dynamic> json) =
      _$TransferItemModelImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  String get productName;
  @override
  int get quantity;
  @override
  @JsonKey(ignore: true)
  _$$TransferItemModelImplCopyWith<_$TransferItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
