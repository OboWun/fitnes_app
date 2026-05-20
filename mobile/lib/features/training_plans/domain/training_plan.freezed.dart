// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrainingPlan _$TrainingPlanFromJson(Map<String, dynamic> json) {
  return _TrainingPlan.fromJson(json);
}

/// @nodoc
mixin _$TrainingPlan {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  List<PlanScheduleItem> get schedule => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TrainingPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingPlanCopyWith<TrainingPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingPlanCopyWith<$Res> {
  factory $TrainingPlanCopyWith(
    TrainingPlan value,
    $Res Function(TrainingPlan) then,
  ) = _$TrainingPlanCopyWithImpl<$Res, TrainingPlan>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    bool isActive,
    String? source,
    List<PlanScheduleItem> schedule,
    String? createdAt,
  });
}

/// @nodoc
class _$TrainingPlanCopyWithImpl<$Res, $Val extends TrainingPlan>
    implements $TrainingPlanCopyWith<$Res> {
  _$TrainingPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? isActive = null,
    Object? source = freezed,
    Object? schedule = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            schedule: null == schedule
                ? _value.schedule
                : schedule // ignore: cast_nullable_to_non_nullable
                      as List<PlanScheduleItem>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainingPlanImplCopyWith<$Res>
    implements $TrainingPlanCopyWith<$Res> {
  factory _$$TrainingPlanImplCopyWith(
    _$TrainingPlanImpl value,
    $Res Function(_$TrainingPlanImpl) then,
  ) = __$$TrainingPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    bool isActive,
    String? source,
    List<PlanScheduleItem> schedule,
    String? createdAt,
  });
}

/// @nodoc
class __$$TrainingPlanImplCopyWithImpl<$Res>
    extends _$TrainingPlanCopyWithImpl<$Res, _$TrainingPlanImpl>
    implements _$$TrainingPlanImplCopyWith<$Res> {
  __$$TrainingPlanImplCopyWithImpl(
    _$TrainingPlanImpl _value,
    $Res Function(_$TrainingPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? isActive = null,
    Object? source = freezed,
    Object? schedule = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TrainingPlanImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        schedule: null == schedule
            ? _value._schedule
            : schedule // ignore: cast_nullable_to_non_nullable
                  as List<PlanScheduleItem>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingPlanImpl implements _TrainingPlan {
  const _$TrainingPlanImpl({
    required this.id,
    required this.userId,
    required this.name,
    this.isActive = false,
    this.source,
    final List<PlanScheduleItem> schedule = const [],
    this.createdAt,
  }) : _schedule = schedule;

  factory _$TrainingPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? source;
  final List<PlanScheduleItem> _schedule;
  @override
  @JsonKey()
  List<PlanScheduleItem> get schedule {
    if (_schedule is EqualUnmodifiableListView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedule);
  }

  @override
  final String? createdAt;

  @override
  String toString() {
    return 'TrainingPlan(id: $id, userId: $userId, name: $name, isActive: $isActive, source: $source, schedule: $schedule, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    name,
    isActive,
    source,
    const DeepCollectionEquality().hash(_schedule),
    createdAt,
  );

  /// Create a copy of TrainingPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingPlanImplCopyWith<_$TrainingPlanImpl> get copyWith =>
      __$$TrainingPlanImplCopyWithImpl<_$TrainingPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingPlanImplToJson(this);
  }
}

abstract class _TrainingPlan implements TrainingPlan {
  const factory _TrainingPlan({
    required final String id,
    required final String userId,
    required final String name,
    final bool isActive,
    final String? source,
    final List<PlanScheduleItem> schedule,
    final String? createdAt,
  }) = _$TrainingPlanImpl;

  factory _TrainingPlan.fromJson(Map<String, dynamic> json) =
      _$TrainingPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  bool get isActive;
  @override
  String? get source;
  @override
  List<PlanScheduleItem> get schedule;
  @override
  String? get createdAt;

  /// Create a copy of TrainingPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingPlanImplCopyWith<_$TrainingPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
