// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'week_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeekSession _$WeekSessionFromJson(Map<String, dynamic> json) {
  return _WeekSession.fromJson(json);
}

/// @nodoc
mixin _$WeekSession {
  String get id => throw _privateConstructorUsedError;
  DayOfWeek get dayOfWeek => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get sessionType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get exerciseCount => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;

  /// Serializes this WeekSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeekSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeekSessionCopyWith<WeekSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeekSessionCopyWith<$Res> {
  factory $WeekSessionCopyWith(
    WeekSession value,
    $Res Function(WeekSession) then,
  ) = _$WeekSessionCopyWithImpl<$Res, WeekSession>;
  @useResult
  $Res call({
    String id,
    DayOfWeek dayOfWeek,
    String? date,
    String status,
    String? sessionType,
    String? description,
    int exerciseCount,
    String? time,
  });
}

/// @nodoc
class _$WeekSessionCopyWithImpl<$Res, $Val extends WeekSession>
    implements $WeekSessionCopyWith<$Res> {
  _$WeekSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeekSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayOfWeek = null,
    Object? date = freezed,
    Object? status = null,
    Object? sessionType = freezed,
    Object? description = freezed,
    Object? exerciseCount = null,
    Object? time = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            dayOfWeek: null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                      as DayOfWeek,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionType: freezed == sessionType
                ? _value.sessionType
                : sessionType // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            exerciseCount: null == exerciseCount
                ? _value.exerciseCount
                : exerciseCount // ignore: cast_nullable_to_non_nullable
                      as int,
            time: freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeekSessionImplCopyWith<$Res>
    implements $WeekSessionCopyWith<$Res> {
  factory _$$WeekSessionImplCopyWith(
    _$WeekSessionImpl value,
    $Res Function(_$WeekSessionImpl) then,
  ) = __$$WeekSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DayOfWeek dayOfWeek,
    String? date,
    String status,
    String? sessionType,
    String? description,
    int exerciseCount,
    String? time,
  });
}

/// @nodoc
class __$$WeekSessionImplCopyWithImpl<$Res>
    extends _$WeekSessionCopyWithImpl<$Res, _$WeekSessionImpl>
    implements _$$WeekSessionImplCopyWith<$Res> {
  __$$WeekSessionImplCopyWithImpl(
    _$WeekSessionImpl _value,
    $Res Function(_$WeekSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeekSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayOfWeek = null,
    Object? date = freezed,
    Object? status = null,
    Object? sessionType = freezed,
    Object? description = freezed,
    Object? exerciseCount = null,
    Object? time = freezed,
  }) {
    return _then(
      _$WeekSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        dayOfWeek: null == dayOfWeek
            ? _value.dayOfWeek
            : dayOfWeek // ignore: cast_nullable_to_non_nullable
                  as DayOfWeek,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionType: freezed == sessionType
            ? _value.sessionType
            : sessionType // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        exerciseCount: null == exerciseCount
            ? _value.exerciseCount
            : exerciseCount // ignore: cast_nullable_to_non_nullable
                  as int,
        time: freezed == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeekSessionImpl implements _WeekSession {
  const _$WeekSessionImpl({
    required this.id,
    required this.dayOfWeek,
    this.date,
    this.status = 'planned',
    this.sessionType,
    this.description,
    this.exerciseCount = 0,
    this.time,
  });

  factory _$WeekSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeekSessionImplFromJson(json);

  @override
  final String id;
  @override
  final DayOfWeek dayOfWeek;
  @override
  final String? date;
  @override
  @JsonKey()
  final String status;
  @override
  final String? sessionType;
  @override
  final String? description;
  @override
  @JsonKey()
  final int exerciseCount;
  @override
  final String? time;

  @override
  String toString() {
    return 'WeekSession(id: $id, dayOfWeek: $dayOfWeek, date: $date, status: $status, sessionType: $sessionType, description: $description, exerciseCount: $exerciseCount, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.exerciseCount, exerciseCount) ||
                other.exerciseCount == exerciseCount) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    dayOfWeek,
    date,
    status,
    sessionType,
    description,
    exerciseCount,
    time,
  );

  /// Create a copy of WeekSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeekSessionImplCopyWith<_$WeekSessionImpl> get copyWith =>
      __$$WeekSessionImplCopyWithImpl<_$WeekSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeekSessionImplToJson(this);
  }
}

abstract class _WeekSession implements WeekSession {
  const factory _WeekSession({
    required final String id,
    required final DayOfWeek dayOfWeek,
    final String? date,
    final String status,
    final String? sessionType,
    final String? description,
    final int exerciseCount,
    final String? time,
  }) = _$WeekSessionImpl;

  factory _WeekSession.fromJson(Map<String, dynamic> json) =
      _$WeekSessionImpl.fromJson;

  @override
  String get id;
  @override
  DayOfWeek get dayOfWeek;
  @override
  String? get date;
  @override
  String get status;
  @override
  String? get sessionType;
  @override
  String? get description;
  @override
  int get exerciseCount;
  @override
  String? get time;

  /// Create a copy of WeekSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeekSessionImplCopyWith<_$WeekSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
