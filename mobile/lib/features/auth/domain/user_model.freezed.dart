// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get weight => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  List<String>? get contraindications => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  UserMetadata? get metadata => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String id,
    String deviceId,
    String? name,
    int? weight,
    int? height,
    int? age,
    String? gender,
    List<String>? contraindications,
    String createdAt,
    UserMetadata? metadata,
  });

  $UserMetadataCopyWith<$Res>? get metadata;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? name = freezed,
    Object? weight = freezed,
    Object? height = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? contraindications = freezed,
    Object? createdAt = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceId: null == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as int?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int?,
            age: freezed == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            contraindications: freezed == contraindications
                ? _value.contraindications
                : contraindications // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as UserMetadata?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserMetadataCopyWith<$Res>? get metadata {
    if (_value.metadata == null) {
      return null;
    }

    return $UserMetadataCopyWith<$Res>(_value.metadata!, (value) {
      return _then(_value.copyWith(metadata: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String deviceId,
    String? name,
    int? weight,
    int? height,
    int? age,
    String? gender,
    List<String>? contraindications,
    String createdAt,
    UserMetadata? metadata,
  });

  @override
  $UserMetadataCopyWith<$Res>? get metadata;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? name = freezed,
    Object? weight = freezed,
    Object? height = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? contraindications = freezed,
    Object? createdAt = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceId: null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        age: freezed == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        contraindications: freezed == contraindications
            ? _value._contraindications
            : contraindications // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: freezed == metadata
            ? _value.metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as UserMetadata?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
    required this.id,
    required this.deviceId,
    this.name,
    this.weight,
    this.height,
    this.age,
    this.gender,
    final List<String>? contraindications,
    required this.createdAt,
    this.metadata,
  }) : _contraindications = contraindications,
       super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String deviceId;
  @override
  final String? name;
  @override
  final int? weight;
  @override
  final int? height;
  @override
  final int? age;
  @override
  final String? gender;
  final List<String>? _contraindications;
  @override
  List<String>? get contraindications {
    final value = _contraindications;
    if (value == null) return null;
    if (_contraindications is EqualUnmodifiableListView)
      return _contraindications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String createdAt;
  @override
  final UserMetadata? metadata;

  @override
  String toString() {
    return 'UserModel(id: $id, deviceId: $deviceId, name: $name, weight: $weight, height: $height, age: $age, gender: $gender, contraindications: $contraindications, createdAt: $createdAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            const DeepCollectionEquality().equals(
              other._contraindications,
              _contraindications,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    deviceId,
    name,
    weight,
    height,
    age,
    gender,
    const DeepCollectionEquality().hash(_contraindications),
    createdAt,
    metadata,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel({
    required final String id,
    required final String deviceId,
    final String? name,
    final int? weight,
    final int? height,
    final int? age,
    final String? gender,
    final List<String>? contraindications,
    required final String createdAt,
    final UserMetadata? metadata,
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get deviceId;
  @override
  String? get name;
  @override
  int? get weight;
  @override
  int? get height;
  @override
  int? get age;
  @override
  String? get gender;
  @override
  List<String>? get contraindications;
  @override
  String get createdAt;
  @override
  UserMetadata? get metadata;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserMetadata _$UserMetadataFromJson(Map<String, dynamic> json) {
  return _UserMetadata.fromJson(json);
}

/// @nodoc
mixin _$UserMetadata {
  String? get goal => throw _privateConstructorUsedError;
  int? get trainingAgeMonths => throw _privateConstructorUsedError;
  String? get experienceLevel => throw _privateConstructorUsedError;
  int? get recoveryCapacity => throw _privateConstructorUsedError;
  List<String>? get availableEquipment => throw _privateConstructorUsedError;
  List<String>? get injuryHistory => throw _privateConstructorUsedError;
  List<String>? get currentLimitations => throw _privateConstructorUsedError;
  List<String>? get preferredExercises => throw _privateConstructorUsedError;
  List<String>? get dislikedExercises => throw _privateConstructorUsedError;
  List<String>? get preferredMovementPatterns =>
      throw _privateConstructorUsedError;
  String? get defaultEquipmentPresetId => throw _privateConstructorUsedError;

  /// Serializes this UserMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserMetadataCopyWith<UserMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserMetadataCopyWith<$Res> {
  factory $UserMetadataCopyWith(
    UserMetadata value,
    $Res Function(UserMetadata) then,
  ) = _$UserMetadataCopyWithImpl<$Res, UserMetadata>;
  @useResult
  $Res call({
    String? goal,
    int? trainingAgeMonths,
    String? experienceLevel,
    int? recoveryCapacity,
    List<String>? availableEquipment,
    List<String>? injuryHistory,
    List<String>? currentLimitations,
    List<String>? preferredExercises,
    List<String>? dislikedExercises,
    List<String>? preferredMovementPatterns,
    String? defaultEquipmentPresetId,
  });
}

/// @nodoc
class _$UserMetadataCopyWithImpl<$Res, $Val extends UserMetadata>
    implements $UserMetadataCopyWith<$Res> {
  _$UserMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = freezed,
    Object? trainingAgeMonths = freezed,
    Object? experienceLevel = freezed,
    Object? recoveryCapacity = freezed,
    Object? availableEquipment = freezed,
    Object? injuryHistory = freezed,
    Object? currentLimitations = freezed,
    Object? preferredExercises = freezed,
    Object? dislikedExercises = freezed,
    Object? preferredMovementPatterns = freezed,
    Object? defaultEquipmentPresetId = freezed,
  }) {
    return _then(
      _value.copyWith(
            goal: freezed == goal
                ? _value.goal
                : goal // ignore: cast_nullable_to_non_nullable
                      as String?,
            trainingAgeMonths: freezed == trainingAgeMonths
                ? _value.trainingAgeMonths
                : trainingAgeMonths // ignore: cast_nullable_to_non_nullable
                      as int?,
            experienceLevel: freezed == experienceLevel
                ? _value.experienceLevel
                : experienceLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
            recoveryCapacity: freezed == recoveryCapacity
                ? _value.recoveryCapacity
                : recoveryCapacity // ignore: cast_nullable_to_non_nullable
                      as int?,
            availableEquipment: freezed == availableEquipment
                ? _value.availableEquipment
                : availableEquipment // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            injuryHistory: freezed == injuryHistory
                ? _value.injuryHistory
                : injuryHistory // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            currentLimitations: freezed == currentLimitations
                ? _value.currentLimitations
                : currentLimitations // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            preferredExercises: freezed == preferredExercises
                ? _value.preferredExercises
                : preferredExercises // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            dislikedExercises: freezed == dislikedExercises
                ? _value.dislikedExercises
                : dislikedExercises // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            preferredMovementPatterns: freezed == preferredMovementPatterns
                ? _value.preferredMovementPatterns
                : preferredMovementPatterns // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            defaultEquipmentPresetId: freezed == defaultEquipmentPresetId
                ? _value.defaultEquipmentPresetId
                : defaultEquipmentPresetId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserMetadataImplCopyWith<$Res>
    implements $UserMetadataCopyWith<$Res> {
  factory _$$UserMetadataImplCopyWith(
    _$UserMetadataImpl value,
    $Res Function(_$UserMetadataImpl) then,
  ) = __$$UserMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? goal,
    int? trainingAgeMonths,
    String? experienceLevel,
    int? recoveryCapacity,
    List<String>? availableEquipment,
    List<String>? injuryHistory,
    List<String>? currentLimitations,
    List<String>? preferredExercises,
    List<String>? dislikedExercises,
    List<String>? preferredMovementPatterns,
    String? defaultEquipmentPresetId,
  });
}

/// @nodoc
class __$$UserMetadataImplCopyWithImpl<$Res>
    extends _$UserMetadataCopyWithImpl<$Res, _$UserMetadataImpl>
    implements _$$UserMetadataImplCopyWith<$Res> {
  __$$UserMetadataImplCopyWithImpl(
    _$UserMetadataImpl _value,
    $Res Function(_$UserMetadataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = freezed,
    Object? trainingAgeMonths = freezed,
    Object? experienceLevel = freezed,
    Object? recoveryCapacity = freezed,
    Object? availableEquipment = freezed,
    Object? injuryHistory = freezed,
    Object? currentLimitations = freezed,
    Object? preferredExercises = freezed,
    Object? dislikedExercises = freezed,
    Object? preferredMovementPatterns = freezed,
    Object? defaultEquipmentPresetId = freezed,
  }) {
    return _then(
      _$UserMetadataImpl(
        goal: freezed == goal
            ? _value.goal
            : goal // ignore: cast_nullable_to_non_nullable
                  as String?,
        trainingAgeMonths: freezed == trainingAgeMonths
            ? _value.trainingAgeMonths
            : trainingAgeMonths // ignore: cast_nullable_to_non_nullable
                  as int?,
        experienceLevel: freezed == experienceLevel
            ? _value.experienceLevel
            : experienceLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
        recoveryCapacity: freezed == recoveryCapacity
            ? _value.recoveryCapacity
            : recoveryCapacity // ignore: cast_nullable_to_non_nullable
                  as int?,
        availableEquipment: freezed == availableEquipment
            ? _value._availableEquipment
            : availableEquipment // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        injuryHistory: freezed == injuryHistory
            ? _value._injuryHistory
            : injuryHistory // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        currentLimitations: freezed == currentLimitations
            ? _value._currentLimitations
            : currentLimitations // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        preferredExercises: freezed == preferredExercises
            ? _value._preferredExercises
            : preferredExercises // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        dislikedExercises: freezed == dislikedExercises
            ? _value._dislikedExercises
            : dislikedExercises // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        preferredMovementPatterns: freezed == preferredMovementPatterns
            ? _value._preferredMovementPatterns
            : preferredMovementPatterns // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        defaultEquipmentPresetId: freezed == defaultEquipmentPresetId
            ? _value.defaultEquipmentPresetId
            : defaultEquipmentPresetId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserMetadataImpl implements _UserMetadata {
  const _$UserMetadataImpl({
    this.goal,
    this.trainingAgeMonths,
    this.experienceLevel,
    this.recoveryCapacity,
    final List<String>? availableEquipment,
    final List<String>? injuryHistory,
    final List<String>? currentLimitations,
    final List<String>? preferredExercises,
    final List<String>? dislikedExercises,
    final List<String>? preferredMovementPatterns,
    this.defaultEquipmentPresetId,
  }) : _availableEquipment = availableEquipment,
       _injuryHistory = injuryHistory,
       _currentLimitations = currentLimitations,
       _preferredExercises = preferredExercises,
       _dislikedExercises = dislikedExercises,
       _preferredMovementPatterns = preferredMovementPatterns;

  factory _$UserMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserMetadataImplFromJson(json);

  @override
  final String? goal;
  @override
  final int? trainingAgeMonths;
  @override
  final String? experienceLevel;
  @override
  final int? recoveryCapacity;
  final List<String>? _availableEquipment;
  @override
  List<String>? get availableEquipment {
    final value = _availableEquipment;
    if (value == null) return null;
    if (_availableEquipment is EqualUnmodifiableListView)
      return _availableEquipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _injuryHistory;
  @override
  List<String>? get injuryHistory {
    final value = _injuryHistory;
    if (value == null) return null;
    if (_injuryHistory is EqualUnmodifiableListView) return _injuryHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _currentLimitations;
  @override
  List<String>? get currentLimitations {
    final value = _currentLimitations;
    if (value == null) return null;
    if (_currentLimitations is EqualUnmodifiableListView)
      return _currentLimitations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _preferredExercises;
  @override
  List<String>? get preferredExercises {
    final value = _preferredExercises;
    if (value == null) return null;
    if (_preferredExercises is EqualUnmodifiableListView)
      return _preferredExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _dislikedExercises;
  @override
  List<String>? get dislikedExercises {
    final value = _dislikedExercises;
    if (value == null) return null;
    if (_dislikedExercises is EqualUnmodifiableListView)
      return _dislikedExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _preferredMovementPatterns;
  @override
  List<String>? get preferredMovementPatterns {
    final value = _preferredMovementPatterns;
    if (value == null) return null;
    if (_preferredMovementPatterns is EqualUnmodifiableListView)
      return _preferredMovementPatterns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? defaultEquipmentPresetId;

  @override
  String toString() {
    return 'UserMetadata(goal: $goal, trainingAgeMonths: $trainingAgeMonths, experienceLevel: $experienceLevel, recoveryCapacity: $recoveryCapacity, availableEquipment: $availableEquipment, injuryHistory: $injuryHistory, currentLimitations: $currentLimitations, preferredExercises: $preferredExercises, dislikedExercises: $dislikedExercises, preferredMovementPatterns: $preferredMovementPatterns, defaultEquipmentPresetId: $defaultEquipmentPresetId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserMetadataImpl &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.trainingAgeMonths, trainingAgeMonths) ||
                other.trainingAgeMonths == trainingAgeMonths) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            (identical(other.recoveryCapacity, recoveryCapacity) ||
                other.recoveryCapacity == recoveryCapacity) &&
            const DeepCollectionEquality().equals(
              other._availableEquipment,
              _availableEquipment,
            ) &&
            const DeepCollectionEquality().equals(
              other._injuryHistory,
              _injuryHistory,
            ) &&
            const DeepCollectionEquality().equals(
              other._currentLimitations,
              _currentLimitations,
            ) &&
            const DeepCollectionEquality().equals(
              other._preferredExercises,
              _preferredExercises,
            ) &&
            const DeepCollectionEquality().equals(
              other._dislikedExercises,
              _dislikedExercises,
            ) &&
            const DeepCollectionEquality().equals(
              other._preferredMovementPatterns,
              _preferredMovementPatterns,
            ) &&
            (identical(
                  other.defaultEquipmentPresetId,
                  defaultEquipmentPresetId,
                ) ||
                other.defaultEquipmentPresetId == defaultEquipmentPresetId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    goal,
    trainingAgeMonths,
    experienceLevel,
    recoveryCapacity,
    const DeepCollectionEquality().hash(_availableEquipment),
    const DeepCollectionEquality().hash(_injuryHistory),
    const DeepCollectionEquality().hash(_currentLimitations),
    const DeepCollectionEquality().hash(_preferredExercises),
    const DeepCollectionEquality().hash(_dislikedExercises),
    const DeepCollectionEquality().hash(_preferredMovementPatterns),
    defaultEquipmentPresetId,
  );

  /// Create a copy of UserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserMetadataImplCopyWith<_$UserMetadataImpl> get copyWith =>
      __$$UserMetadataImplCopyWithImpl<_$UserMetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserMetadataImplToJson(this);
  }
}

abstract class _UserMetadata implements UserMetadata {
  const factory _UserMetadata({
    final String? goal,
    final int? trainingAgeMonths,
    final String? experienceLevel,
    final int? recoveryCapacity,
    final List<String>? availableEquipment,
    final List<String>? injuryHistory,
    final List<String>? currentLimitations,
    final List<String>? preferredExercises,
    final List<String>? dislikedExercises,
    final List<String>? preferredMovementPatterns,
    final String? defaultEquipmentPresetId,
  }) = _$UserMetadataImpl;

  factory _UserMetadata.fromJson(Map<String, dynamic> json) =
      _$UserMetadataImpl.fromJson;

  @override
  String? get goal;
  @override
  int? get trainingAgeMonths;
  @override
  String? get experienceLevel;
  @override
  int? get recoveryCapacity;
  @override
  List<String>? get availableEquipment;
  @override
  List<String>? get injuryHistory;
  @override
  List<String>? get currentLimitations;
  @override
  List<String>? get preferredExercises;
  @override
  List<String>? get dislikedExercises;
  @override
  List<String>? get preferredMovementPatterns;
  @override
  String? get defaultEquipmentPresetId;

  /// Create a copy of UserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserMetadataImplCopyWith<_$UserMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
