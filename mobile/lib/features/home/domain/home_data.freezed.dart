// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActiveBlock _$ActiveBlockFromJson(Map<String, dynamic> json) {
  return _ActiveBlock.fromJson(json);
}

/// @nodoc
mixin _$ActiveBlock {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  int? get durationWeeks => throw _privateConstructorUsedError;
  String? get goal => throw _privateConstructorUsedError;
  String? get splitName => throw _privateConstructorUsedError;
  int? get currentWeek => throw _privateConstructorUsedError;

  /// Serializes this ActiveBlock to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActiveBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActiveBlockCopyWith<ActiveBlock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveBlockCopyWith<$Res> {
  factory $ActiveBlockCopyWith(
    ActiveBlock value,
    $Res Function(ActiveBlock) then,
  ) = _$ActiveBlockCopyWithImpl<$Res, ActiveBlock>;
  @useResult
  $Res call({
    String id,
    String name,
    String? type,
    int? durationWeeks,
    String? goal,
    String? splitName,
    int? currentWeek,
  });
}

/// @nodoc
class _$ActiveBlockCopyWithImpl<$Res, $Val extends ActiveBlock>
    implements $ActiveBlockCopyWith<$Res> {
  _$ActiveBlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActiveBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = freezed,
    Object? durationWeeks = freezed,
    Object? goal = freezed,
    Object? splitName = freezed,
    Object? currentWeek = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            durationWeeks: freezed == durationWeeks
                ? _value.durationWeeks
                : durationWeeks // ignore: cast_nullable_to_non_nullable
                      as int?,
            goal: freezed == goal
                ? _value.goal
                : goal // ignore: cast_nullable_to_non_nullable
                      as String?,
            splitName: freezed == splitName
                ? _value.splitName
                : splitName // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentWeek: freezed == currentWeek
                ? _value.currentWeek
                : currentWeek // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActiveBlockImplCopyWith<$Res>
    implements $ActiveBlockCopyWith<$Res> {
  factory _$$ActiveBlockImplCopyWith(
    _$ActiveBlockImpl value,
    $Res Function(_$ActiveBlockImpl) then,
  ) = __$$ActiveBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? type,
    int? durationWeeks,
    String? goal,
    String? splitName,
    int? currentWeek,
  });
}

/// @nodoc
class __$$ActiveBlockImplCopyWithImpl<$Res>
    extends _$ActiveBlockCopyWithImpl<$Res, _$ActiveBlockImpl>
    implements _$$ActiveBlockImplCopyWith<$Res> {
  __$$ActiveBlockImplCopyWithImpl(
    _$ActiveBlockImpl _value,
    $Res Function(_$ActiveBlockImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActiveBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = freezed,
    Object? durationWeeks = freezed,
    Object? goal = freezed,
    Object? splitName = freezed,
    Object? currentWeek = freezed,
  }) {
    return _then(
      _$ActiveBlockImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        durationWeeks: freezed == durationWeeks
            ? _value.durationWeeks
            : durationWeeks // ignore: cast_nullable_to_non_nullable
                  as int?,
        goal: freezed == goal
            ? _value.goal
            : goal // ignore: cast_nullable_to_non_nullable
                  as String?,
        splitName: freezed == splitName
            ? _value.splitName
            : splitName // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentWeek: freezed == currentWeek
            ? _value.currentWeek
            : currentWeek // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActiveBlockImpl implements _ActiveBlock {
  const _$ActiveBlockImpl({
    required this.id,
    required this.name,
    this.type,
    this.durationWeeks,
    this.goal,
    this.splitName,
    this.currentWeek,
  });

  factory _$ActiveBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActiveBlockImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? type;
  @override
  final int? durationWeeks;
  @override
  final String? goal;
  @override
  final String? splitName;
  @override
  final int? currentWeek;

  @override
  String toString() {
    return 'ActiveBlock(id: $id, name: $name, type: $type, durationWeeks: $durationWeeks, goal: $goal, splitName: $splitName, currentWeek: $currentWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.durationWeeks, durationWeeks) ||
                other.durationWeeks == durationWeeks) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.splitName, splitName) ||
                other.splitName == splitName) &&
            (identical(other.currentWeek, currentWeek) ||
                other.currentWeek == currentWeek));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    durationWeeks,
    goal,
    splitName,
    currentWeek,
  );

  /// Create a copy of ActiveBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActiveBlockImplCopyWith<_$ActiveBlockImpl> get copyWith =>
      __$$ActiveBlockImplCopyWithImpl<_$ActiveBlockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActiveBlockImplToJson(this);
  }
}

abstract class _ActiveBlock implements ActiveBlock {
  const factory _ActiveBlock({
    required final String id,
    required final String name,
    final String? type,
    final int? durationWeeks,
    final String? goal,
    final String? splitName,
    final int? currentWeek,
  }) = _$ActiveBlockImpl;

  factory _ActiveBlock.fromJson(Map<String, dynamic> json) =
      _$ActiveBlockImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get type;
  @override
  int? get durationWeeks;
  @override
  String? get goal;
  @override
  String? get splitName;
  @override
  int? get currentWeek;

  /// Create a copy of ActiveBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActiveBlockImplCopyWith<_$ActiveBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TodaySession _$TodaySessionFromJson(Map<String, dynamic> json) {
  return _TodaySession.fromJson(json);
}

/// @nodoc
mixin _$TodaySession {
  String get id => throw _privateConstructorUsedError;
  String? get sessionType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;
  int get exerciseCount => throw _privateConstructorUsedError;

  /// Serializes this TodaySession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodaySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodaySessionCopyWith<TodaySession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodaySessionCopyWith<$Res> {
  factory $TodaySessionCopyWith(
    TodaySession value,
    $Res Function(TodaySession) then,
  ) = _$TodaySessionCopyWithImpl<$Res, TodaySession>;
  @useResult
  $Res call({
    String id,
    String? sessionType,
    String? description,
    String? time,
    int exerciseCount,
  });
}

/// @nodoc
class _$TodaySessionCopyWithImpl<$Res, $Val extends TodaySession>
    implements $TodaySessionCopyWith<$Res> {
  _$TodaySessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodaySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionType = freezed,
    Object? description = freezed,
    Object? time = freezed,
    Object? exerciseCount = null,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            time: freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String?,
            exerciseCount: null == exerciseCount
                ? _value.exerciseCount
                : exerciseCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodaySessionImplCopyWith<$Res>
    implements $TodaySessionCopyWith<$Res> {
  factory _$$TodaySessionImplCopyWith(
    _$TodaySessionImpl value,
    $Res Function(_$TodaySessionImpl) then,
  ) = __$$TodaySessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? sessionType,
    String? description,
    String? time,
    int exerciseCount,
  });
}

/// @nodoc
class __$$TodaySessionImplCopyWithImpl<$Res>
    extends _$TodaySessionCopyWithImpl<$Res, _$TodaySessionImpl>
    implements _$$TodaySessionImplCopyWith<$Res> {
  __$$TodaySessionImplCopyWithImpl(
    _$TodaySessionImpl _value,
    $Res Function(_$TodaySessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodaySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionType = freezed,
    Object? description = freezed,
    Object? time = freezed,
    Object? exerciseCount = null,
  }) {
    return _then(
      _$TodaySessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionType: freezed == sessionType
            ? _value.sessionType
            : sessionType // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        time: freezed == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String?,
        exerciseCount: null == exerciseCount
            ? _value.exerciseCount
            : exerciseCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TodaySessionImpl implements _TodaySession {
  const _$TodaySessionImpl({
    required this.id,
    this.sessionType,
    this.description,
    this.time,
    this.exerciseCount = 0,
  });

  factory _$TodaySessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodaySessionImplFromJson(json);

  @override
  final String id;
  @override
  final String? sessionType;
  @override
  final String? description;
  @override
  final String? time;
  @override
  @JsonKey()
  final int exerciseCount;

  @override
  String toString() {
    return 'TodaySession(id: $id, sessionType: $sessionType, description: $description, time: $time, exerciseCount: $exerciseCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodaySessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.exerciseCount, exerciseCount) ||
                other.exerciseCount == exerciseCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionType,
    description,
    time,
    exerciseCount,
  );

  /// Create a copy of TodaySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodaySessionImplCopyWith<_$TodaySessionImpl> get copyWith =>
      __$$TodaySessionImplCopyWithImpl<_$TodaySessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TodaySessionImplToJson(this);
  }
}

abstract class _TodaySession implements TodaySession {
  const factory _TodaySession({
    required final String id,
    final String? sessionType,
    final String? description,
    final String? time,
    final int exerciseCount,
  }) = _$TodaySessionImpl;

  factory _TodaySession.fromJson(Map<String, dynamic> json) =
      _$TodaySessionImpl.fromJson;

  @override
  String get id;
  @override
  String? get sessionType;
  @override
  String? get description;
  @override
  String? get time;
  @override
  int get exerciseCount;

  /// Create a copy of TodaySession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodaySessionImplCopyWith<_$TodaySessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomeData _$HomeDataFromJson(Map<String, dynamic> json) {
  return _HomeData.fromJson(json);
}

/// @nodoc
mixin _$HomeData {
  ActiveBlock? get activeBlock => throw _privateConstructorUsedError;
  List<WeekSession> get weekSessions => throw _privateConstructorUsedError;
  String? get weekStart => throw _privateConstructorUsedError;
  String? get weekEnd => throw _privateConstructorUsedError;
  TodaySession? get todaySession => throw _privateConstructorUsedError;

  /// Serializes this HomeData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeDataCopyWith<HomeData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeDataCopyWith<$Res> {
  factory $HomeDataCopyWith(HomeData value, $Res Function(HomeData) then) =
      _$HomeDataCopyWithImpl<$Res, HomeData>;
  @useResult
  $Res call({
    ActiveBlock? activeBlock,
    List<WeekSession> weekSessions,
    String? weekStart,
    String? weekEnd,
    TodaySession? todaySession,
  });

  $ActiveBlockCopyWith<$Res>? get activeBlock;
  $TodaySessionCopyWith<$Res>? get todaySession;
}

/// @nodoc
class _$HomeDataCopyWithImpl<$Res, $Val extends HomeData>
    implements $HomeDataCopyWith<$Res> {
  _$HomeDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeBlock = freezed,
    Object? weekSessions = null,
    Object? weekStart = freezed,
    Object? weekEnd = freezed,
    Object? todaySession = freezed,
  }) {
    return _then(
      _value.copyWith(
            activeBlock: freezed == activeBlock
                ? _value.activeBlock
                : activeBlock // ignore: cast_nullable_to_non_nullable
                      as ActiveBlock?,
            weekSessions: null == weekSessions
                ? _value.weekSessions
                : weekSessions // ignore: cast_nullable_to_non_nullable
                      as List<WeekSession>,
            weekStart: freezed == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as String?,
            weekEnd: freezed == weekEnd
                ? _value.weekEnd
                : weekEnd // ignore: cast_nullable_to_non_nullable
                      as String?,
            todaySession: freezed == todaySession
                ? _value.todaySession
                : todaySession // ignore: cast_nullable_to_non_nullable
                      as TodaySession?,
          )
          as $Val,
    );
  }

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActiveBlockCopyWith<$Res>? get activeBlock {
    if (_value.activeBlock == null) {
      return null;
    }

    return $ActiveBlockCopyWith<$Res>(_value.activeBlock!, (value) {
      return _then(_value.copyWith(activeBlock: value) as $Val);
    });
  }

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodaySessionCopyWith<$Res>? get todaySession {
    if (_value.todaySession == null) {
      return null;
    }

    return $TodaySessionCopyWith<$Res>(_value.todaySession!, (value) {
      return _then(_value.copyWith(todaySession: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeDataImplCopyWith<$Res>
    implements $HomeDataCopyWith<$Res> {
  factory _$$HomeDataImplCopyWith(
    _$HomeDataImpl value,
    $Res Function(_$HomeDataImpl) then,
  ) = __$$HomeDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ActiveBlock? activeBlock,
    List<WeekSession> weekSessions,
    String? weekStart,
    String? weekEnd,
    TodaySession? todaySession,
  });

  @override
  $ActiveBlockCopyWith<$Res>? get activeBlock;
  @override
  $TodaySessionCopyWith<$Res>? get todaySession;
}

/// @nodoc
class __$$HomeDataImplCopyWithImpl<$Res>
    extends _$HomeDataCopyWithImpl<$Res, _$HomeDataImpl>
    implements _$$HomeDataImplCopyWith<$Res> {
  __$$HomeDataImplCopyWithImpl(
    _$HomeDataImpl _value,
    $Res Function(_$HomeDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeBlock = freezed,
    Object? weekSessions = null,
    Object? weekStart = freezed,
    Object? weekEnd = freezed,
    Object? todaySession = freezed,
  }) {
    return _then(
      _$HomeDataImpl(
        activeBlock: freezed == activeBlock
            ? _value.activeBlock
            : activeBlock // ignore: cast_nullable_to_non_nullable
                  as ActiveBlock?,
        weekSessions: null == weekSessions
            ? _value._weekSessions
            : weekSessions // ignore: cast_nullable_to_non_nullable
                  as List<WeekSession>,
        weekStart: freezed == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as String?,
        weekEnd: freezed == weekEnd
            ? _value.weekEnd
            : weekEnd // ignore: cast_nullable_to_non_nullable
                  as String?,
        todaySession: freezed == todaySession
            ? _value.todaySession
            : todaySession // ignore: cast_nullable_to_non_nullable
                  as TodaySession?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeDataImpl implements _HomeData {
  const _$HomeDataImpl({
    this.activeBlock,
    final List<WeekSession> weekSessions = const [],
    this.weekStart,
    this.weekEnd,
    this.todaySession,
  }) : _weekSessions = weekSessions;

  factory _$HomeDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeDataImplFromJson(json);

  @override
  final ActiveBlock? activeBlock;
  final List<WeekSession> _weekSessions;
  @override
  @JsonKey()
  List<WeekSession> get weekSessions {
    if (_weekSessions is EqualUnmodifiableListView) return _weekSessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekSessions);
  }

  @override
  final String? weekStart;
  @override
  final String? weekEnd;
  @override
  final TodaySession? todaySession;

  @override
  String toString() {
    return 'HomeData(activeBlock: $activeBlock, weekSessions: $weekSessions, weekStart: $weekStart, weekEnd: $weekEnd, todaySession: $todaySession)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeDataImpl &&
            (identical(other.activeBlock, activeBlock) ||
                other.activeBlock == activeBlock) &&
            const DeepCollectionEquality().equals(
              other._weekSessions,
              _weekSessions,
            ) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd) &&
            (identical(other.todaySession, todaySession) ||
                other.todaySession == todaySession));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    activeBlock,
    const DeepCollectionEquality().hash(_weekSessions),
    weekStart,
    weekEnd,
    todaySession,
  );

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeDataImplCopyWith<_$HomeDataImpl> get copyWith =>
      __$$HomeDataImplCopyWithImpl<_$HomeDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeDataImplToJson(this);
  }
}

abstract class _HomeData implements HomeData {
  const factory _HomeData({
    final ActiveBlock? activeBlock,
    final List<WeekSession> weekSessions,
    final String? weekStart,
    final String? weekEnd,
    final TodaySession? todaySession,
  }) = _$HomeDataImpl;

  factory _HomeData.fromJson(Map<String, dynamic> json) =
      _$HomeDataImpl.fromJson;

  @override
  ActiveBlock? get activeBlock;
  @override
  List<WeekSession> get weekSessions;
  @override
  String? get weekStart;
  @override
  String? get weekEnd;
  @override
  TodaySession? get todaySession;

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeDataImplCopyWith<_$HomeDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
