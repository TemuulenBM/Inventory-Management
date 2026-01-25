// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventActor _$EventActorFromJson(Map<String, dynamic> json) {
  return _EventActor.fromJson(json);
}

/// @nodoc
mixin _$EventActor {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventActorCopyWith<EventActor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventActorCopyWith<$Res> {
  factory $EventActorCopyWith(
          EventActor value, $Res Function(EventActor) then) =
      _$EventActorCopyWithImpl<$Res, EventActor>;
  @useResult
  $Res call({String id, String name, String? avatarUrl});
}

/// @nodoc
class _$EventActorCopyWithImpl<$Res, $Val extends EventActor>
    implements $EventActorCopyWith<$Res> {
  _$EventActorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
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
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventActorImplCopyWith<$Res>
    implements $EventActorCopyWith<$Res> {
  factory _$$EventActorImplCopyWith(
          _$EventActorImpl value, $Res Function(_$EventActorImpl) then) =
      __$$EventActorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? avatarUrl});
}

/// @nodoc
class __$$EventActorImplCopyWithImpl<$Res>
    extends _$EventActorCopyWithImpl<$Res, _$EventActorImpl>
    implements _$$EventActorImplCopyWith<$Res> {
  __$$EventActorImplCopyWithImpl(
      _$EventActorImpl _value, $Res Function(_$EventActorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$EventActorImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventActorImpl implements _EventActor {
  const _$EventActorImpl(
      {required this.id, required this.name, this.avatarUrl});

  factory _$EventActorImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventActorImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'EventActor(id: $id, name: $name, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventActorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, avatarUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventActorImplCopyWith<_$EventActorImpl> get copyWith =>
      __$$EventActorImplCopyWithImpl<_$EventActorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventActorImplToJson(
      this,
    );
  }
}

abstract class _EventActor implements EventActor {
  const factory _EventActor(
      {required final String id,
      required final String name,
      final String? avatarUrl}) = _$EventActorImpl;

  factory _EventActor.fromJson(Map<String, dynamic> json) =
      _$EventActorImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get avatarUrl;
  @override
  @JsonKey(ignore: true)
  _$$EventActorImplCopyWith<_$EventActorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InventoryEventModel _$InventoryEventModelFromJson(Map<String, dynamic> json) {
  return _InventoryEventModel.fromJson(json);
}

/// @nodoc
mixin _$InventoryEventModel {
  String get id => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  InventoryEventType get type => throw _privateConstructorUsedError;
  int get qtyChange => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  EventActor get actor => throw _privateConstructorUsedError;
  String? get productName => throw _privateConstructorUsedError;
  String? get shiftId => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InventoryEventModelCopyWith<InventoryEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryEventModelCopyWith<$Res> {
  factory $InventoryEventModelCopyWith(
          InventoryEventModel value, $Res Function(InventoryEventModel) then) =
      _$InventoryEventModelCopyWithImpl<$Res, InventoryEventModel>;
  @useResult
  $Res call(
      {String id,
      String storeId,
      String productId,
      InventoryEventType type,
      int qtyChange,
      DateTime timestamp,
      EventActor actor,
      String? productName,
      String? shiftId,
      String? reason});

  $EventActorCopyWith<$Res> get actor;
}

/// @nodoc
class _$InventoryEventModelCopyWithImpl<$Res, $Val extends InventoryEventModel>
    implements $InventoryEventModelCopyWith<$Res> {
  _$InventoryEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? productId = null,
    Object? type = null,
    Object? qtyChange = null,
    Object? timestamp = null,
    Object? actor = null,
    Object? productName = freezed,
    Object? shiftId = freezed,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InventoryEventType,
      qtyChange: null == qtyChange
          ? _value.qtyChange
          : qtyChange // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actor: null == actor
          ? _value.actor
          : actor // ignore: cast_nullable_to_non_nullable
              as EventActor,
      productName: freezed == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String?,
      shiftId: freezed == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $EventActorCopyWith<$Res> get actor {
    return $EventActorCopyWith<$Res>(_value.actor, (value) {
      return _then(_value.copyWith(actor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InventoryEventModelImplCopyWith<$Res>
    implements $InventoryEventModelCopyWith<$Res> {
  factory _$$InventoryEventModelImplCopyWith(_$InventoryEventModelImpl value,
          $Res Function(_$InventoryEventModelImpl) then) =
      __$$InventoryEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String storeId,
      String productId,
      InventoryEventType type,
      int qtyChange,
      DateTime timestamp,
      EventActor actor,
      String? productName,
      String? shiftId,
      String? reason});

  @override
  $EventActorCopyWith<$Res> get actor;
}

/// @nodoc
class __$$InventoryEventModelImplCopyWithImpl<$Res>
    extends _$InventoryEventModelCopyWithImpl<$Res, _$InventoryEventModelImpl>
    implements _$$InventoryEventModelImplCopyWith<$Res> {
  __$$InventoryEventModelImplCopyWithImpl(_$InventoryEventModelImpl _value,
      $Res Function(_$InventoryEventModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? productId = null,
    Object? type = null,
    Object? qtyChange = null,
    Object? timestamp = null,
    Object? actor = null,
    Object? productName = freezed,
    Object? shiftId = freezed,
    Object? reason = freezed,
  }) {
    return _then(_$InventoryEventModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InventoryEventType,
      qtyChange: null == qtyChange
          ? _value.qtyChange
          : qtyChange // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actor: null == actor
          ? _value.actor
          : actor // ignore: cast_nullable_to_non_nullable
              as EventActor,
      productName: freezed == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String?,
      shiftId: freezed == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryEventModelImpl extends _InventoryEventModel {
  const _$InventoryEventModelImpl(
      {required this.id,
      required this.storeId,
      required this.productId,
      required this.type,
      required this.qtyChange,
      required this.timestamp,
      required this.actor,
      this.productName,
      this.shiftId,
      this.reason})
      : super._();

  factory _$InventoryEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryEventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String storeId;
  @override
  final String productId;
  @override
  final InventoryEventType type;
  @override
  final int qtyChange;
  @override
  final DateTime timestamp;
  @override
  final EventActor actor;
  @override
  final String? productName;
  @override
  final String? shiftId;
  @override
  final String? reason;

  @override
  String toString() {
    return 'InventoryEventModel(id: $id, storeId: $storeId, productId: $productId, type: $type, qtyChange: $qtyChange, timestamp: $timestamp, actor: $actor, productName: $productName, shiftId: $shiftId, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.qtyChange, qtyChange) ||
                other.qtyChange == qtyChange) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.actor, actor) || other.actor == actor) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.shiftId, shiftId) || other.shiftId == shiftId) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, storeId, productId, type,
      qtyChange, timestamp, actor, productName, shiftId, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryEventModelImplCopyWith<_$InventoryEventModelImpl> get copyWith =>
      __$$InventoryEventModelImplCopyWithImpl<_$InventoryEventModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryEventModelImplToJson(
      this,
    );
  }
}

abstract class _InventoryEventModel extends InventoryEventModel {
  const factory _InventoryEventModel(
      {required final String id,
      required final String storeId,
      required final String productId,
      required final InventoryEventType type,
      required final int qtyChange,
      required final DateTime timestamp,
      required final EventActor actor,
      final String? productName,
      final String? shiftId,
      final String? reason}) = _$InventoryEventModelImpl;
  const _InventoryEventModel._() : super._();

  factory _InventoryEventModel.fromJson(Map<String, dynamic> json) =
      _$InventoryEventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get storeId;
  @override
  String get productId;
  @override
  InventoryEventType get type;
  @override
  int get qtyChange;
  @override
  DateTime get timestamp;
  @override
  EventActor get actor;
  @override
  String? get productName;
  @override
  String? get shiftId;
  @override
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$InventoryEventModelImplCopyWith<_$InventoryEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
