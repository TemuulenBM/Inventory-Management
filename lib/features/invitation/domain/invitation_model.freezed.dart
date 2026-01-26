// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InvitationModel _$InvitationModelFromJson(Map<String, dynamic> json) {
  return _InvitationModel.fromJson(json);
}

/// @nodoc
mixin _$InvitationModel {
  String get id => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  InvitationStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'invited_by')
  String? get invitedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'invited_at')
  DateTime get invitedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_at')
  DateTime? get usedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_by')
  String? get usedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvitationModelCopyWith<InvitationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvitationModelCopyWith<$Res> {
  factory $InvitationModelCopyWith(
          InvitationModel value, $Res Function(InvitationModel) then) =
      _$InvitationModelCopyWithImpl<$Res, InvitationModel>;
  @useResult
  $Res call(
      {String id,
      String phone,
      String role,
      InvitationStatus status,
      @JsonKey(name: 'invited_by') String? invitedBy,
      @JsonKey(name: 'invited_at') DateTime invitedAt,
      @JsonKey(name: 'expires_at') DateTime expiresAt,
      @JsonKey(name: 'used_at') DateTime? usedAt,
      @JsonKey(name: 'used_by') String? usedBy});
}

/// @nodoc
class _$InvitationModelCopyWithImpl<$Res, $Val extends InvitationModel>
    implements $InvitationModelCopyWith<$Res> {
  _$InvitationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? role = null,
    Object? status = null,
    Object? invitedBy = freezed,
    Object? invitedAt = null,
    Object? expiresAt = null,
    Object? usedAt = freezed,
    Object? usedBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as InvitationStatus,
      invitedBy: freezed == invitedBy
          ? _value.invitedBy
          : invitedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      invitedAt: null == invitedAt
          ? _value.invitedAt
          : invitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      usedAt: freezed == usedAt
          ? _value.usedAt
          : usedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      usedBy: freezed == usedBy
          ? _value.usedBy
          : usedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvitationModelImplCopyWith<$Res>
    implements $InvitationModelCopyWith<$Res> {
  factory _$$InvitationModelImplCopyWith(_$InvitationModelImpl value,
          $Res Function(_$InvitationModelImpl) then) =
      __$$InvitationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String phone,
      String role,
      InvitationStatus status,
      @JsonKey(name: 'invited_by') String? invitedBy,
      @JsonKey(name: 'invited_at') DateTime invitedAt,
      @JsonKey(name: 'expires_at') DateTime expiresAt,
      @JsonKey(name: 'used_at') DateTime? usedAt,
      @JsonKey(name: 'used_by') String? usedBy});
}

/// @nodoc
class __$$InvitationModelImplCopyWithImpl<$Res>
    extends _$InvitationModelCopyWithImpl<$Res, _$InvitationModelImpl>
    implements _$$InvitationModelImplCopyWith<$Res> {
  __$$InvitationModelImplCopyWithImpl(
      _$InvitationModelImpl _value, $Res Function(_$InvitationModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? role = null,
    Object? status = null,
    Object? invitedBy = freezed,
    Object? invitedAt = null,
    Object? expiresAt = null,
    Object? usedAt = freezed,
    Object? usedBy = freezed,
  }) {
    return _then(_$InvitationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as InvitationStatus,
      invitedBy: freezed == invitedBy
          ? _value.invitedBy
          : invitedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      invitedAt: null == invitedAt
          ? _value.invitedAt
          : invitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      usedAt: freezed == usedAt
          ? _value.usedAt
          : usedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      usedBy: freezed == usedBy
          ? _value.usedBy
          : usedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvitationModelImpl implements _InvitationModel {
  const _$InvitationModelImpl(
      {required this.id,
      required this.phone,
      required this.role,
      required this.status,
      @JsonKey(name: 'invited_by') this.invitedBy,
      @JsonKey(name: 'invited_at') required this.invitedAt,
      @JsonKey(name: 'expires_at') required this.expiresAt,
      @JsonKey(name: 'used_at') this.usedAt,
      @JsonKey(name: 'used_by') this.usedBy});

  factory _$InvitationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvitationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String phone;
  @override
  final String role;
  @override
  final InvitationStatus status;
  @override
  @JsonKey(name: 'invited_by')
  final String? invitedBy;
  @override
  @JsonKey(name: 'invited_at')
  final DateTime invitedAt;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @override
  @JsonKey(name: 'used_at')
  final DateTime? usedAt;
  @override
  @JsonKey(name: 'used_by')
  final String? usedBy;

  @override
  String toString() {
    return 'InvitationModel(id: $id, phone: $phone, role: $role, status: $status, invitedBy: $invitedBy, invitedAt: $invitedAt, expiresAt: $expiresAt, usedAt: $usedAt, usedBy: $usedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvitationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.invitedBy, invitedBy) ||
                other.invitedBy == invitedBy) &&
            (identical(other.invitedAt, invitedAt) ||
                other.invitedAt == invitedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.usedAt, usedAt) || other.usedAt == usedAt) &&
            (identical(other.usedBy, usedBy) || other.usedBy == usedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, phone, role, status,
      invitedBy, invitedAt, expiresAt, usedAt, usedBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InvitationModelImplCopyWith<_$InvitationModelImpl> get copyWith =>
      __$$InvitationModelImplCopyWithImpl<_$InvitationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvitationModelImplToJson(
      this,
    );
  }
}

abstract class _InvitationModel implements InvitationModel {
  const factory _InvitationModel(
      {required final String id,
      required final String phone,
      required final String role,
      required final InvitationStatus status,
      @JsonKey(name: 'invited_by') final String? invitedBy,
      @JsonKey(name: 'invited_at') required final DateTime invitedAt,
      @JsonKey(name: 'expires_at') required final DateTime expiresAt,
      @JsonKey(name: 'used_at') final DateTime? usedAt,
      @JsonKey(name: 'used_by') final String? usedBy}) = _$InvitationModelImpl;

  factory _InvitationModel.fromJson(Map<String, dynamic> json) =
      _$InvitationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get phone;
  @override
  String get role;
  @override
  InvitationStatus get status;
  @override
  @JsonKey(name: 'invited_by')
  String? get invitedBy;
  @override
  @JsonKey(name: 'invited_at')
  DateTime get invitedAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt;
  @override
  @JsonKey(name: 'used_at')
  DateTime? get usedAt;
  @override
  @JsonKey(name: 'used_by')
  String? get usedBy;
  @override
  @JsonKey(ignore: true)
  _$$InvitationModelImplCopyWith<_$InvitationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateInvitationRequest _$CreateInvitationRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateInvitationRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateInvitationRequest {
  String get phone => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  int get expiresInDays => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateInvitationRequestCopyWith<CreateInvitationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateInvitationRequestCopyWith<$Res> {
  factory $CreateInvitationRequestCopyWith(CreateInvitationRequest value,
          $Res Function(CreateInvitationRequest) then) =
      _$CreateInvitationRequestCopyWithImpl<$Res, CreateInvitationRequest>;
  @useResult
  $Res call({String phone, String role, int expiresInDays});
}

/// @nodoc
class _$CreateInvitationRequestCopyWithImpl<$Res,
        $Val extends CreateInvitationRequest>
    implements $CreateInvitationRequestCopyWith<$Res> {
  _$CreateInvitationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = null,
    Object? role = null,
    Object? expiresInDays = null,
  }) {
    return _then(_value.copyWith(
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      expiresInDays: null == expiresInDays
          ? _value.expiresInDays
          : expiresInDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateInvitationRequestImplCopyWith<$Res>
    implements $CreateInvitationRequestCopyWith<$Res> {
  factory _$$CreateInvitationRequestImplCopyWith(
          _$CreateInvitationRequestImpl value,
          $Res Function(_$CreateInvitationRequestImpl) then) =
      __$$CreateInvitationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String phone, String role, int expiresInDays});
}

/// @nodoc
class __$$CreateInvitationRequestImplCopyWithImpl<$Res>
    extends _$CreateInvitationRequestCopyWithImpl<$Res,
        _$CreateInvitationRequestImpl>
    implements _$$CreateInvitationRequestImplCopyWith<$Res> {
  __$$CreateInvitationRequestImplCopyWithImpl(
      _$CreateInvitationRequestImpl _value,
      $Res Function(_$CreateInvitationRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = null,
    Object? role = null,
    Object? expiresInDays = null,
  }) {
    return _then(_$CreateInvitationRequestImpl(
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      expiresInDays: null == expiresInDays
          ? _value.expiresInDays
          : expiresInDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateInvitationRequestImpl implements _CreateInvitationRequest {
  const _$CreateInvitationRequestImpl(
      {required this.phone, this.role = 'owner', this.expiresInDays = 7});

  factory _$CreateInvitationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateInvitationRequestImplFromJson(json);

  @override
  final String phone;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey()
  final int expiresInDays;

  @override
  String toString() {
    return 'CreateInvitationRequest(phone: $phone, role: $role, expiresInDays: $expiresInDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateInvitationRequestImpl &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.expiresInDays, expiresInDays) ||
                other.expiresInDays == expiresInDays));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, phone, role, expiresInDays);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateInvitationRequestImplCopyWith<_$CreateInvitationRequestImpl>
      get copyWith => __$$CreateInvitationRequestImplCopyWithImpl<
          _$CreateInvitationRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateInvitationRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateInvitationRequest implements CreateInvitationRequest {
  const factory _CreateInvitationRequest(
      {required final String phone,
      final String role,
      final int expiresInDays}) = _$CreateInvitationRequestImpl;

  factory _CreateInvitationRequest.fromJson(Map<String, dynamic> json) =
      _$CreateInvitationRequestImpl.fromJson;

  @override
  String get phone;
  @override
  String get role;
  @override
  int get expiresInDays;
  @override
  @JsonKey(ignore: true)
  _$$CreateInvitationRequestImplCopyWith<_$CreateInvitationRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
