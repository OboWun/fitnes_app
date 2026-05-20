// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_schedule_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlanScheduleItem _$PlanScheduleItemFromJson(Map<String, dynamic> json) {
  return _PlanScheduleItem.fromJson(json);
}

/// @nodoc
mixin _$PlanScheduleItem {
  String get dayOfWeek => throw _privateConstructorUsedError;
  String get workoutTemplateId => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this PlanScheduleItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanScheduleItemCopyWith<PlanScheduleItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanScheduleItemCopyWith<$Res> {
  factory $PlanScheduleItemCopyWith(
    PlanScheduleItem value,
    $Res Function(PlanScheduleItem) then,
  ) = _$PlanScheduleItemCopyWithImpl<$Res, PlanScheduleItem>;
  @useResult
  $Res call({
    String dayOfWeek,
    String workoutTemplateId,
    String? time,
    String? name,
    int sortOrder,
  });
}

/// @nodoc
class _$PlanScheduleItemCopyWithImpl<$Res, $Val extends PlanScheduleItem>
    implements $PlanScheduleItemCopyWith<$Res> {
  _$PlanScheduleItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? workoutTemplateId = null,
    Object? time = freezed,
    Object? name = freezed,
    Object? sortOrder = null,
  }) {
    return _then(
      _value.copyWith(
            dayOfWeek: null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                      as String,
            workoutTemplateId: null == workoutTemplateId
                ? _value.workoutTemplateId
                : workoutTemplateId // ignore: cast_nullable_to_non_nullable
                      as String,
            time: freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanScheduleItemImplCopyWith<$Res>
    implements $PlanScheduleItemCopyWith<$Res> {
  factory _$$PlanScheduleItemImplCopyWith(
    _$PlanScheduleItemImpl value,
    $Res Function(_$PlanScheduleItemImpl) then,
  ) = __$$PlanScheduleItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String dayOfWeek,
    String workoutTemplateId,
    String? time,
    String? name,
    int sortOrder,
  });
}

/// @nodoc
class __$$PlanScheduleItemImplCopyWithImpl<$Res>
    extends _$PlanScheduleItemCopyWithImpl<$Res, _$PlanScheduleItemImpl>
    implements _$$PlanScheduleItemImplCopyWith<$Res> {
  __$$PlanScheduleItemImplCopyWithImpl(
    _$PlanScheduleItemImpl _value,
    $Res Function(_$PlanScheduleItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? workoutTemplateId = null,
    Object? time = freezed,
    Object? name = freezed,
    Object? sortOrder = null,
  }) {
    return _then(
      _$PlanScheduleItemImpl(
        dayOfWeek: null == dayOfWeek
            ? _value.dayOfWeek
            : dayOfWeek // ignore: cast_nullable_to_non_nullable
                  as String,
        workoutTemplateId: null == workoutTemplateId
            ? _value.workoutTemplateId
            : workoutTemplateId // ignore: cast_nullable_to_non_nullable
                  as String,
        time: freezed == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanScheduleItemImpl implements _PlanScheduleItem {
  const _$PlanScheduleItemImpl({
    required this.dayOfWeek,
    required this.workoutTemplateId,
    this.time,
    this.name,
    this.sortOrder = 0,
  });

  factory _$PlanScheduleItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanScheduleItemImplFromJson(json);

  @override
  final String dayOfWeek;
  @override
  final String workoutTemplateId;
  @override
  final String? time;
  @override
  final String? name;
  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'PlanScheduleItem(dayOfWeek: $dayOfWeek, workoutTemplateId: $workoutTemplateId, time: $time, name: $name, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanScheduleItemImpl &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.workoutTemplateId, workoutTemplateId) ||
                other.workoutTemplateId == workoutTemplateId) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dayOfWeek,
    workoutTemplateId,
    time,
    name,
    sortOrder,
  );

  /// Create a copy of PlanScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanScheduleItemImplCopyWith<_$PlanScheduleItemImpl> get copyWith =>
      __$$PlanScheduleItemImplCopyWithImpl<_$PlanScheduleItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanScheduleItemImplToJson(this);
  }
}

abstract class _PlanScheduleItem implements PlanScheduleItem {
  const factory _PlanScheduleItem({
    required final String dayOfWeek,
    required final String workoutTemplateId,
    final String? time,
    final String? name,
    final int sortOrder,
  }) = _$PlanScheduleItemImpl;

  factory _PlanScheduleItem.fromJson(Map<String, dynamic> json) =
      _$PlanScheduleItemImpl.fromJson;

  @override
  String get dayOfWeek;
  @override
  String get workoutTemplateId;
  @override
  String? get time;
  @override
  String? get name;
  @override
  int get sortOrder;

  /// Create a copy of PlanScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanScheduleItemImplCopyWith<_$PlanScheduleItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
