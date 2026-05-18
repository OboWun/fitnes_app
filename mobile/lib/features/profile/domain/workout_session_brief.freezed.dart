// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session_brief.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkoutSessionBrief _$WorkoutSessionBriefFromJson(Map<String, dynamic> json) {
  return _WorkoutSessionBrief.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSessionBrief {
  String get id => throw _privateConstructorUsedError;
  String? get sessionType => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;
  int get exerciseCount => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this WorkoutSessionBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutSessionBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutSessionBriefCopyWith<WorkoutSessionBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSessionBriefCopyWith<$Res> {
  factory $WorkoutSessionBriefCopyWith(
    WorkoutSessionBrief value,
    $Res Function(WorkoutSessionBrief) then,
  ) = _$WorkoutSessionBriefCopyWithImpl<$Res, WorkoutSessionBrief>;
  @useResult
  $Res call({
    String id,
    String? sessionType,
    String? date,
    int exerciseCount,
    String? status,
  });
}

/// @nodoc
class _$WorkoutSessionBriefCopyWithImpl<$Res, $Val extends WorkoutSessionBrief>
    implements $WorkoutSessionBriefCopyWith<$Res> {
  _$WorkoutSessionBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutSessionBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionType = freezed,
    Object? date = freezed,
    Object? exerciseCount = null,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionType: freezed == sessionType
                ? _value.sessionType
                : sessionType // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String?,
            exerciseCount: null == exerciseCount
                ? _value.exerciseCount
                : exerciseCount // ignore: cast_nullable_to_non_nullable
                      as int,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkoutSessionBriefImplCopyWith<$Res>
    implements $WorkoutSessionBriefCopyWith<$Res> {
  factory _$$WorkoutSessionBriefImplCopyWith(
    _$WorkoutSessionBriefImpl value,
    $Res Function(_$WorkoutSessionBriefImpl) then,
  ) = __$$WorkoutSessionBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? sessionType,
    String? date,
    int exerciseCount,
    String? status,
  });
}

/// @nodoc
class __$$WorkoutSessionBriefImplCopyWithImpl<$Res>
    extends _$WorkoutSessionBriefCopyWithImpl<$Res, _$WorkoutSessionBriefImpl>
    implements _$$WorkoutSessionBriefImplCopyWith<$Res> {
  __$$WorkoutSessionBriefImplCopyWithImpl(
    _$WorkoutSessionBriefImpl _value,
    $Res Function(_$WorkoutSessionBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutSessionBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionType = freezed,
    Object? date = freezed,
    Object? exerciseCount = null,
    Object? status = freezed,
  }) {
    return _then(
      _$WorkoutSessionBriefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionType: freezed == sessionType
            ? _value.sessionType
            : sessionType // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String?,
        exerciseCount: null == exerciseCount
            ? _value.exerciseCount
            : exerciseCount // ignore: cast_nullable_to_non_nullable
                  as int,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSessionBriefImpl implements _WorkoutSessionBrief {
  const _$WorkoutSessionBriefImpl({
    required this.id,
    this.sessionType,
    this.date,
    this.exerciseCount = 0,
    this.status,
  });

  factory _$WorkoutSessionBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSessionBriefImplFromJson(json);

  @override
  final String id;
  @override
  final String? sessionType;
  @override
  final String? date;
  @override
  @JsonKey()
  final int exerciseCount;
  @override
  final String? status;

  @override
  String toString() {
    return 'WorkoutSessionBrief(id: $id, sessionType: $sessionType, date: $date, exerciseCount: $exerciseCount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSessionBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.exerciseCount, exerciseCount) ||
                other.exerciseCount == exerciseCount) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, sessionType, date, exerciseCount, status);

  /// Create a copy of WorkoutSessionBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSessionBriefImplCopyWith<_$WorkoutSessionBriefImpl> get copyWith =>
      __$$WorkoutSessionBriefImplCopyWithImpl<_$WorkoutSessionBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSessionBriefImplToJson(this);
  }
}

abstract class _WorkoutSessionBrief implements WorkoutSessionBrief {
  const factory _WorkoutSessionBrief({
    required final String id,
    final String? sessionType,
    final String? date,
    final int exerciseCount,
    final String? status,
  }) = _$WorkoutSessionBriefImpl;

  factory _WorkoutSessionBrief.fromJson(Map<String, dynamic> json) =
      _$WorkoutSessionBriefImpl.fromJson;

  @override
  String get id;
  @override
  String? get sessionType;
  @override
  String? get date;
  @override
  int get exerciseCount;
  @override
  String? get status;

  /// Create a copy of WorkoutSessionBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutSessionBriefImplCopyWith<_$WorkoutSessionBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
