// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkoutExercise _$WorkoutExerciseFromJson(Map<String, dynamic> json) {
  return _WorkoutExercise.fromJson(json);
}

/// @nodoc
mixin _$WorkoutExercise {
  String get exerciseSlug => throw _privateConstructorUsedError;
  int get sets => throw _privateConstructorUsedError;
  int? get reps => throw _privateConstructorUsedError;
  int? get restBetweenSets => throw _privateConstructorUsedError;
  int? get restAfterExercise => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this WorkoutExercise to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutExerciseCopyWith<WorkoutExercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutExerciseCopyWith<$Res> {
  factory $WorkoutExerciseCopyWith(
    WorkoutExercise value,
    $Res Function(WorkoutExercise) then,
  ) = _$WorkoutExerciseCopyWithImpl<$Res, WorkoutExercise>;
  @useResult
  $Res call({
    String exerciseSlug,
    int sets,
    int? reps,
    int? restBetweenSets,
    int? restAfterExercise,
    int order,
  });
}

/// @nodoc
class _$WorkoutExerciseCopyWithImpl<$Res, $Val extends WorkoutExercise>
    implements $WorkoutExerciseCopyWith<$Res> {
  _$WorkoutExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseSlug = null,
    Object? sets = null,
    Object? reps = freezed,
    Object? restBetweenSets = freezed,
    Object? restAfterExercise = freezed,
    Object? order = null,
  }) {
    return _then(
      _value.copyWith(
            exerciseSlug: null == exerciseSlug
                ? _value.exerciseSlug
                : exerciseSlug // ignore: cast_nullable_to_non_nullable
                      as String,
            sets: null == sets
                ? _value.sets
                : sets // ignore: cast_nullable_to_non_nullable
                      as int,
            reps: freezed == reps
                ? _value.reps
                : reps // ignore: cast_nullable_to_non_nullable
                      as int?,
            restBetweenSets: freezed == restBetweenSets
                ? _value.restBetweenSets
                : restBetweenSets // ignore: cast_nullable_to_non_nullable
                      as int?,
            restAfterExercise: freezed == restAfterExercise
                ? _value.restAfterExercise
                : restAfterExercise // ignore: cast_nullable_to_non_nullable
                      as int?,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkoutExerciseImplCopyWith<$Res>
    implements $WorkoutExerciseCopyWith<$Res> {
  factory _$$WorkoutExerciseImplCopyWith(
    _$WorkoutExerciseImpl value,
    $Res Function(_$WorkoutExerciseImpl) then,
  ) = __$$WorkoutExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String exerciseSlug,
    int sets,
    int? reps,
    int? restBetweenSets,
    int? restAfterExercise,
    int order,
  });
}

/// @nodoc
class __$$WorkoutExerciseImplCopyWithImpl<$Res>
    extends _$WorkoutExerciseCopyWithImpl<$Res, _$WorkoutExerciseImpl>
    implements _$$WorkoutExerciseImplCopyWith<$Res> {
  __$$WorkoutExerciseImplCopyWithImpl(
    _$WorkoutExerciseImpl _value,
    $Res Function(_$WorkoutExerciseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseSlug = null,
    Object? sets = null,
    Object? reps = freezed,
    Object? restBetweenSets = freezed,
    Object? restAfterExercise = freezed,
    Object? order = null,
  }) {
    return _then(
      _$WorkoutExerciseImpl(
        exerciseSlug: null == exerciseSlug
            ? _value.exerciseSlug
            : exerciseSlug // ignore: cast_nullable_to_non_nullable
                  as String,
        sets: null == sets
            ? _value.sets
            : sets // ignore: cast_nullable_to_non_nullable
                  as int,
        reps: freezed == reps
            ? _value.reps
            : reps // ignore: cast_nullable_to_non_nullable
                  as int?,
        restBetweenSets: freezed == restBetweenSets
            ? _value.restBetweenSets
            : restBetweenSets // ignore: cast_nullable_to_non_nullable
                  as int?,
        restAfterExercise: freezed == restAfterExercise
            ? _value.restAfterExercise
            : restAfterExercise // ignore: cast_nullable_to_non_nullable
                  as int?,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutExerciseImpl implements _WorkoutExercise {
  const _$WorkoutExerciseImpl({
    required this.exerciseSlug,
    required this.sets,
    this.reps,
    this.restBetweenSets,
    this.restAfterExercise,
    required this.order,
  });

  factory _$WorkoutExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutExerciseImplFromJson(json);

  @override
  final String exerciseSlug;
  @override
  final int sets;
  @override
  final int? reps;
  @override
  final int? restBetweenSets;
  @override
  final int? restAfterExercise;
  @override
  final int order;

  @override
  String toString() {
    return 'WorkoutExercise(exerciseSlug: $exerciseSlug, sets: $sets, reps: $reps, restBetweenSets: $restBetweenSets, restAfterExercise: $restAfterExercise, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutExerciseImpl &&
            (identical(other.exerciseSlug, exerciseSlug) ||
                other.exerciseSlug == exerciseSlug) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.restBetweenSets, restBetweenSets) ||
                other.restBetweenSets == restBetweenSets) &&
            (identical(other.restAfterExercise, restAfterExercise) ||
                other.restAfterExercise == restAfterExercise) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    exerciseSlug,
    sets,
    reps,
    restBetweenSets,
    restAfterExercise,
    order,
  );

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutExerciseImplCopyWith<_$WorkoutExerciseImpl> get copyWith =>
      __$$WorkoutExerciseImplCopyWithImpl<_$WorkoutExerciseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutExerciseImplToJson(this);
  }
}

abstract class _WorkoutExercise implements WorkoutExercise {
  const factory _WorkoutExercise({
    required final String exerciseSlug,
    required final int sets,
    final int? reps,
    final int? restBetweenSets,
    final int? restAfterExercise,
    required final int order,
  }) = _$WorkoutExerciseImpl;

  factory _WorkoutExercise.fromJson(Map<String, dynamic> json) =
      _$WorkoutExerciseImpl.fromJson;

  @override
  String get exerciseSlug;
  @override
  int get sets;
  @override
  int? get reps;
  @override
  int? get restBetweenSets;
  @override
  int? get restAfterExercise;
  @override
  int get order;

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutExerciseImplCopyWith<_$WorkoutExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
