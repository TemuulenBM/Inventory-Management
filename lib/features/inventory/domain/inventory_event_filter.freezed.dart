// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_event_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$InventoryEventFilter {
  /// Event төрлөөр шүүх (null = бүгд)
  InventoryEventType? get eventType => throw _privateConstructorUsedError;

  /// Эхлэх огноо
  DateTime? get startDate => throw _privateConstructorUsedError;

  /// Дуусах огноо
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Хуудас (pagination)
  int get page => throw _privateConstructorUsedError;

  /// Хуудас бүрт хэдэн бичлэг
  int get limit => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InventoryEventFilterCopyWith<InventoryEventFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryEventFilterCopyWith<$Res> {
  factory $InventoryEventFilterCopyWith(InventoryEventFilter value,
          $Res Function(InventoryEventFilter) then) =
      _$InventoryEventFilterCopyWithImpl<$Res, InventoryEventFilter>;
  @useResult
  $Res call(
      {InventoryEventType? eventType,
      DateTime? startDate,
      DateTime? endDate,
      int page,
      int limit});
}

/// @nodoc
class _$InventoryEventFilterCopyWithImpl<$Res,
        $Val extends InventoryEventFilter>
    implements $InventoryEventFilterCopyWith<$Res> {
  _$InventoryEventFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventType = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_value.copyWith(
      eventType: freezed == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as InventoryEventType?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InventoryEventFilterImplCopyWith<$Res>
    implements $InventoryEventFilterCopyWith<$Res> {
  factory _$$InventoryEventFilterImplCopyWith(_$InventoryEventFilterImpl value,
          $Res Function(_$InventoryEventFilterImpl) then) =
      __$$InventoryEventFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {InventoryEventType? eventType,
      DateTime? startDate,
      DateTime? endDate,
      int page,
      int limit});
}

/// @nodoc
class __$$InventoryEventFilterImplCopyWithImpl<$Res>
    extends _$InventoryEventFilterCopyWithImpl<$Res, _$InventoryEventFilterImpl>
    implements _$$InventoryEventFilterImplCopyWith<$Res> {
  __$$InventoryEventFilterImplCopyWithImpl(_$InventoryEventFilterImpl _value,
      $Res Function(_$InventoryEventFilterImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventType = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_$InventoryEventFilterImpl(
      eventType: freezed == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as InventoryEventType?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$InventoryEventFilterImpl extends _InventoryEventFilter {
  const _$InventoryEventFilterImpl(
      {this.eventType,
      this.startDate,
      this.endDate,
      this.page = 1,
      this.limit = 20})
      : super._();

  /// Event төрлөөр шүүх (null = бүгд)
  @override
  final InventoryEventType? eventType;

  /// Эхлэх огноо
  @override
  final DateTime? startDate;

  /// Дуусах огноо
  @override
  final DateTime? endDate;

  /// Хуудас (pagination)
  @override
  @JsonKey()
  final int page;

  /// Хуудас бүрт хэдэн бичлэг
  @override
  @JsonKey()
  final int limit;

  @override
  String toString() {
    return 'InventoryEventFilter(eventType: $eventType, startDate: $startDate, endDate: $endDate, page: $page, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryEventFilterImpl &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, eventType, startDate, endDate, page, limit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryEventFilterImplCopyWith<_$InventoryEventFilterImpl>
      get copyWith =>
          __$$InventoryEventFilterImplCopyWithImpl<_$InventoryEventFilterImpl>(
              this, _$identity);
}

abstract class _InventoryEventFilter extends InventoryEventFilter {
  const factory _InventoryEventFilter(
      {final InventoryEventType? eventType,
      final DateTime? startDate,
      final DateTime? endDate,
      final int page,
      final int limit}) = _$InventoryEventFilterImpl;
  const _InventoryEventFilter._() : super._();

  @override

  /// Event төрлөөр шүүх (null = бүгд)
  InventoryEventType? get eventType;
  @override

  /// Эхлэх огноо
  DateTime? get startDate;
  @override

  /// Дуусах огноо
  DateTime? get endDate;
  @override

  /// Хуудас (pagination)
  int get page;
  @override

  /// Хуудас бүрт хэдэн бичлэг
  int get limit;
  @override
  @JsonKey(ignore: true)
  _$$InventoryEventFilterImplCopyWith<_$InventoryEventFilterImpl>
      get copyWith => throw _privateConstructorUsedError;
}
