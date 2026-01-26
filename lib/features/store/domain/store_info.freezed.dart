// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StoreInfo _$StoreInfoFromJson(Map<String, dynamic> json) {
  return _StoreInfo.fromJson(json);
}

/// @nodoc
mixin _$StoreInfo {
  /// Дэлгүүрийн ID
  String get id => throw _privateConstructorUsedError;

  /// Дэлгүүрийн нэр
  String get name => throw _privateConstructorUsedError;

  /// Байршил (nullable)
  String? get location => throw _privateConstructorUsedError;

  /// Хэрэглэгчийн энэ дэлгүүр дэх эрх (owner, manager, seller)
  String get role => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StoreInfoCopyWith<StoreInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreInfoCopyWith<$Res> {
  factory $StoreInfoCopyWith(StoreInfo value, $Res Function(StoreInfo) then) =
      _$StoreInfoCopyWithImpl<$Res, StoreInfo>;
  @useResult
  $Res call({String id, String name, String? location, String role});
}

/// @nodoc
class _$StoreInfoCopyWithImpl<$Res, $Val extends StoreInfo>
    implements $StoreInfoCopyWith<$Res> {
  _$StoreInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = freezed,
    Object? role = null,
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
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoreInfoImplCopyWith<$Res>
    implements $StoreInfoCopyWith<$Res> {
  factory _$$StoreInfoImplCopyWith(
          _$StoreInfoImpl value, $Res Function(_$StoreInfoImpl) then) =
      __$$StoreInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? location, String role});
}

/// @nodoc
class __$$StoreInfoImplCopyWithImpl<$Res>
    extends _$StoreInfoCopyWithImpl<$Res, _$StoreInfoImpl>
    implements _$$StoreInfoImplCopyWith<$Res> {
  __$$StoreInfoImplCopyWithImpl(
      _$StoreInfoImpl _value, $Res Function(_$StoreInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = freezed,
    Object? role = null,
  }) {
    return _then(_$StoreInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoreInfoImpl implements _StoreInfo {
  const _$StoreInfoImpl(
      {required this.id,
      required this.name,
      this.location,
      required this.role});

  factory _$StoreInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreInfoImplFromJson(json);

  /// Дэлгүүрийн ID
  @override
  final String id;

  /// Дэлгүүрийн нэр
  @override
  final String name;

  /// Байршил (nullable)
  @override
  final String? location;

  /// Хэрэглэгчийн энэ дэлгүүр дэх эрх (owner, manager, seller)
  @override
  final String role;

  @override
  String toString() {
    return 'StoreInfo(id: $id, name: $name, location: $location, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, location, role);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreInfoImplCopyWith<_$StoreInfoImpl> get copyWith =>
      __$$StoreInfoImplCopyWithImpl<_$StoreInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreInfoImplToJson(
      this,
    );
  }
}

abstract class _StoreInfo implements StoreInfo {
  const factory _StoreInfo(
      {required final String id,
      required final String name,
      final String? location,
      required final String role}) = _$StoreInfoImpl;

  factory _StoreInfo.fromJson(Map<String, dynamic> json) =
      _$StoreInfoImpl.fromJson;

  @override

  /// Дэлгүүрийн ID
  String get id;
  @override

  /// Дэлгүүрийн нэр
  String get name;
  @override

  /// Байршил (nullable)
  String? get location;
  @override

  /// Хэрэглэгчийн энэ дэлгүүр дэх эрх (owner, manager, seller)
  String get role;
  @override
  @JsonKey(ignore: true)
  _$$StoreInfoImplCopyWith<_$StoreInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
