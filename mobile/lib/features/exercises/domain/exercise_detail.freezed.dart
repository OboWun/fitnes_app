// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MuscleRef _$MuscleRefFromJson(Map<String, dynamic> json) {
  return _MuscleRef.fromJson(json);
}

/// @nodoc
mixin _$MuscleRef {
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this MuscleRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MuscleRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MuscleRefCopyWith<MuscleRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MuscleRefCopyWith<$Res> {
  factory $MuscleRefCopyWith(MuscleRef value, $Res Function(MuscleRef) then) =
      _$MuscleRefCopyWithImpl<$Res, MuscleRef>;
  @useResult
  $Res call({String slug, String name});
}

/// @nodoc
class _$MuscleRefCopyWithImpl<$Res, $Val extends MuscleRef>
    implements $MuscleRefCopyWith<$Res> {
  _$MuscleRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MuscleRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slug = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MuscleRefImplCopyWith<$Res>
    implements $MuscleRefCopyWith<$Res> {
  factory _$$MuscleRefImplCopyWith(
    _$MuscleRefImpl value,
    $Res Function(_$MuscleRefImpl) then,
  ) = __$$MuscleRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String slug, String name});
}

/// @nodoc
class __$$MuscleRefImplCopyWithImpl<$Res>
    extends _$MuscleRefCopyWithImpl<$Res, _$MuscleRefImpl>
    implements _$$MuscleRefImplCopyWith<$Res> {
  __$$MuscleRefImplCopyWithImpl(
    _$MuscleRefImpl _value,
    $Res Function(_$MuscleRefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MuscleRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slug = null, Object? name = null}) {
    return _then(
      _$MuscleRefImpl(
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MuscleRefImpl implements _MuscleRef {
  const _$MuscleRefImpl({required this.slug, required this.name});

  factory _$MuscleRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$MuscleRefImplFromJson(json);

  @override
  final String slug;
  @override
  final String name;

  @override
  String toString() {
    return 'MuscleRef(slug: $slug, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MuscleRefImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, slug, name);

  /// Create a copy of MuscleRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MuscleRefImplCopyWith<_$MuscleRefImpl> get copyWith =>
      __$$MuscleRefImplCopyWithImpl<_$MuscleRefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MuscleRefImplToJson(this);
  }
}

abstract class _MuscleRef implements MuscleRef {
  const factory _MuscleRef({
    required final String slug,
    required final String name,
  }) = _$MuscleRefImpl;

  factory _MuscleRef.fromJson(Map<String, dynamic> json) =
      _$MuscleRefImpl.fromJson;

  @override
  String get slug;
  @override
  String get name;

  /// Create a copy of MuscleRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MuscleRefImplCopyWith<_$MuscleRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BodyPartRef _$BodyPartRefFromJson(Map<String, dynamic> json) {
  return _BodyPartRef.fromJson(json);
}

/// @nodoc
mixin _$BodyPartRef {
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this BodyPartRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BodyPartRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BodyPartRefCopyWith<BodyPartRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyPartRefCopyWith<$Res> {
  factory $BodyPartRefCopyWith(
    BodyPartRef value,
    $Res Function(BodyPartRef) then,
  ) = _$BodyPartRefCopyWithImpl<$Res, BodyPartRef>;
  @useResult
  $Res call({String slug, String name});
}

/// @nodoc
class _$BodyPartRefCopyWithImpl<$Res, $Val extends BodyPartRef>
    implements $BodyPartRefCopyWith<$Res> {
  _$BodyPartRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BodyPartRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slug = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BodyPartRefImplCopyWith<$Res>
    implements $BodyPartRefCopyWith<$Res> {
  factory _$$BodyPartRefImplCopyWith(
    _$BodyPartRefImpl value,
    $Res Function(_$BodyPartRefImpl) then,
  ) = __$$BodyPartRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String slug, String name});
}

/// @nodoc
class __$$BodyPartRefImplCopyWithImpl<$Res>
    extends _$BodyPartRefCopyWithImpl<$Res, _$BodyPartRefImpl>
    implements _$$BodyPartRefImplCopyWith<$Res> {
  __$$BodyPartRefImplCopyWithImpl(
    _$BodyPartRefImpl _value,
    $Res Function(_$BodyPartRefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BodyPartRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slug = null, Object? name = null}) {
    return _then(
      _$BodyPartRefImpl(
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BodyPartRefImpl implements _BodyPartRef {
  const _$BodyPartRefImpl({required this.slug, required this.name});

  factory _$BodyPartRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodyPartRefImplFromJson(json);

  @override
  final String slug;
  @override
  final String name;

  @override
  String toString() {
    return 'BodyPartRef(slug: $slug, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyPartRefImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, slug, name);

  /// Create a copy of BodyPartRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyPartRefImplCopyWith<_$BodyPartRefImpl> get copyWith =>
      __$$BodyPartRefImplCopyWithImpl<_$BodyPartRefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BodyPartRefImplToJson(this);
  }
}

abstract class _BodyPartRef implements BodyPartRef {
  const factory _BodyPartRef({
    required final String slug,
    required final String name,
  }) = _$BodyPartRefImpl;

  factory _BodyPartRef.fromJson(Map<String, dynamic> json) =
      _$BodyPartRefImpl.fromJson;

  @override
  String get slug;
  @override
  String get name;

  /// Create a copy of BodyPartRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BodyPartRefImplCopyWith<_$BodyPartRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ContraindicationEntry _$ContraindicationEntryFromJson(
  Map<String, dynamic> json,
) {
  return _ContraindicationEntry.fromJson(json);
}

/// @nodoc
mixin _$ContraindicationEntry {
  String get slug => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;

  /// Serializes this ContraindicationEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContraindicationEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContraindicationEntryCopyWith<ContraindicationEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContraindicationEntryCopyWith<$Res> {
  factory $ContraindicationEntryCopyWith(
    ContraindicationEntry value,
    $Res Function(ContraindicationEntry) then,
  ) = _$ContraindicationEntryCopyWithImpl<$Res, ContraindicationEntry>;
  @useResult
  $Res call({String slug, String? name, String severity});
}

/// @nodoc
class _$ContraindicationEntryCopyWithImpl<
  $Res,
  $Val extends ContraindicationEntry
>
    implements $ContraindicationEntryCopyWith<$Res> {
  _$ContraindicationEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContraindicationEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = freezed,
    Object? severity = null,
  }) {
    return _then(
      _value.copyWith(
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContraindicationEntryImplCopyWith<$Res>
    implements $ContraindicationEntryCopyWith<$Res> {
  factory _$$ContraindicationEntryImplCopyWith(
    _$ContraindicationEntryImpl value,
    $Res Function(_$ContraindicationEntryImpl) then,
  ) = __$$ContraindicationEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String slug, String? name, String severity});
}

/// @nodoc
class __$$ContraindicationEntryImplCopyWithImpl<$Res>
    extends
        _$ContraindicationEntryCopyWithImpl<$Res, _$ContraindicationEntryImpl>
    implements _$$ContraindicationEntryImplCopyWith<$Res> {
  __$$ContraindicationEntryImplCopyWithImpl(
    _$ContraindicationEntryImpl _value,
    $Res Function(_$ContraindicationEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContraindicationEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = freezed,
    Object? severity = null,
  }) {
    return _then(
      _$ContraindicationEntryImpl(
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContraindicationEntryImpl implements _ContraindicationEntry {
  const _$ContraindicationEntryImpl({
    required this.slug,
    this.name,
    required this.severity,
  });

  factory _$ContraindicationEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContraindicationEntryImplFromJson(json);

  @override
  final String slug;
  @override
  final String? name;
  @override
  final String severity;

  @override
  String toString() {
    return 'ContraindicationEntry(slug: $slug, name: $name, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContraindicationEntryImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.severity, severity) ||
                other.severity == severity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, slug, name, severity);

  /// Create a copy of ContraindicationEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContraindicationEntryImplCopyWith<_$ContraindicationEntryImpl>
  get copyWith =>
      __$$ContraindicationEntryImplCopyWithImpl<_$ContraindicationEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContraindicationEntryImplToJson(this);
  }
}

abstract class _ContraindicationEntry implements ContraindicationEntry {
  const factory _ContraindicationEntry({
    required final String slug,
    final String? name,
    required final String severity,
  }) = _$ContraindicationEntryImpl;

  factory _ContraindicationEntry.fromJson(Map<String, dynamic> json) =
      _$ContraindicationEntryImpl.fromJson;

  @override
  String get slug;
  @override
  String? get name;
  @override
  String get severity;

  /// Create a copy of ContraindicationEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContraindicationEntryImplCopyWith<_$ContraindicationEntryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExerciseDetail _$ExerciseDetailFromJson(Map<String, dynamic> json) {
  return _ExerciseDetail.fromJson(json);
}

/// @nodoc
mixin _$ExerciseDetail {
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get exerciseType => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  String? get movementPattern => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;
  List<String> get instructions => throw _privateConstructorUsedError;
  List<MuscleRef> get targetMuscles => throw _privateConstructorUsedError;
  List<MuscleRef> get secondaryMuscles => throw _privateConstructorUsedError;
  List<BodyPartRef> get bodyParts => throw _privateConstructorUsedError;
  List<EquipmentRef> get equipments => throw _privateConstructorUsedError;
  List<String> get variations => throw _privateConstructorUsedError;
  List<String> get alias => throw _privateConstructorUsedError;
  List<ContraindicationEntry> get userContraindications =>
      throw _privateConstructorUsedError;
  List<ExerciseShort> get similarExercises =>
      throw _privateConstructorUsedError;

  /// Serializes this ExerciseDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseDetailCopyWith<ExerciseDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseDetailCopyWith<$Res> {
  factory $ExerciseDetailCopyWith(
    ExerciseDetail value,
    $Res Function(ExerciseDetail) then,
  ) = _$ExerciseDetailCopyWithImpl<$Res, ExerciseDetail>;
  @useResult
  $Res call({
    String slug,
    String name,
    String? imageUrl,
    String? description,
    String? exerciseType,
    String? difficulty,
    String? movementPattern,
    double? confidence,
    List<String> instructions,
    List<MuscleRef> targetMuscles,
    List<MuscleRef> secondaryMuscles,
    List<BodyPartRef> bodyParts,
    List<EquipmentRef> equipments,
    List<String> variations,
    List<String> alias,
    List<ContraindicationEntry> userContraindications,
    List<ExerciseShort> similarExercises,
  });
}

/// @nodoc
class _$ExerciseDetailCopyWithImpl<$Res, $Val extends ExerciseDetail>
    implements $ExerciseDetailCopyWith<$Res> {
  _$ExerciseDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? exerciseType = freezed,
    Object? difficulty = freezed,
    Object? movementPattern = freezed,
    Object? confidence = freezed,
    Object? instructions = null,
    Object? targetMuscles = null,
    Object? secondaryMuscles = null,
    Object? bodyParts = null,
    Object? equipments = null,
    Object? variations = null,
    Object? alias = null,
    Object? userContraindications = null,
    Object? similarExercises = null,
  }) {
    return _then(
      _value.copyWith(
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            exerciseType: freezed == exerciseType
                ? _value.exerciseType
                : exerciseType // ignore: cast_nullable_to_non_nullable
                      as String?,
            difficulty: freezed == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String?,
            movementPattern: freezed == movementPattern
                ? _value.movementPattern
                : movementPattern // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidence: freezed == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double?,
            instructions: null == instructions
                ? _value.instructions
                : instructions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            targetMuscles: null == targetMuscles
                ? _value.targetMuscles
                : targetMuscles // ignore: cast_nullable_to_non_nullable
                      as List<MuscleRef>,
            secondaryMuscles: null == secondaryMuscles
                ? _value.secondaryMuscles
                : secondaryMuscles // ignore: cast_nullable_to_non_nullable
                      as List<MuscleRef>,
            bodyParts: null == bodyParts
                ? _value.bodyParts
                : bodyParts // ignore: cast_nullable_to_non_nullable
                      as List<BodyPartRef>,
            equipments: null == equipments
                ? _value.equipments
                : equipments // ignore: cast_nullable_to_non_nullable
                      as List<EquipmentRef>,
            variations: null == variations
                ? _value.variations
                : variations // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            alias: null == alias
                ? _value.alias
                : alias // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            userContraindications: null == userContraindications
                ? _value.userContraindications
                : userContraindications // ignore: cast_nullable_to_non_nullable
                      as List<ContraindicationEntry>,
            similarExercises: null == similarExercises
                ? _value.similarExercises
                : similarExercises // ignore: cast_nullable_to_non_nullable
                      as List<ExerciseShort>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExerciseDetailImplCopyWith<$Res>
    implements $ExerciseDetailCopyWith<$Res> {
  factory _$$ExerciseDetailImplCopyWith(
    _$ExerciseDetailImpl value,
    $Res Function(_$ExerciseDetailImpl) then,
  ) = __$$ExerciseDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String slug,
    String name,
    String? imageUrl,
    String? description,
    String? exerciseType,
    String? difficulty,
    String? movementPattern,
    double? confidence,
    List<String> instructions,
    List<MuscleRef> targetMuscles,
    List<MuscleRef> secondaryMuscles,
    List<BodyPartRef> bodyParts,
    List<EquipmentRef> equipments,
    List<String> variations,
    List<String> alias,
    List<ContraindicationEntry> userContraindications,
    List<ExerciseShort> similarExercises,
  });
}

/// @nodoc
class __$$ExerciseDetailImplCopyWithImpl<$Res>
    extends _$ExerciseDetailCopyWithImpl<$Res, _$ExerciseDetailImpl>
    implements _$$ExerciseDetailImplCopyWith<$Res> {
  __$$ExerciseDetailImplCopyWithImpl(
    _$ExerciseDetailImpl _value,
    $Res Function(_$ExerciseDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? exerciseType = freezed,
    Object? difficulty = freezed,
    Object? movementPattern = freezed,
    Object? confidence = freezed,
    Object? instructions = null,
    Object? targetMuscles = null,
    Object? secondaryMuscles = null,
    Object? bodyParts = null,
    Object? equipments = null,
    Object? variations = null,
    Object? alias = null,
    Object? userContraindications = null,
    Object? similarExercises = null,
  }) {
    return _then(
      _$ExerciseDetailImpl(
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        exerciseType: freezed == exerciseType
            ? _value.exerciseType
            : exerciseType // ignore: cast_nullable_to_non_nullable
                  as String?,
        difficulty: freezed == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String?,
        movementPattern: freezed == movementPattern
            ? _value.movementPattern
            : movementPattern // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidence: freezed == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double?,
        instructions: null == instructions
            ? _value._instructions
            : instructions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        targetMuscles: null == targetMuscles
            ? _value._targetMuscles
            : targetMuscles // ignore: cast_nullable_to_non_nullable
                  as List<MuscleRef>,
        secondaryMuscles: null == secondaryMuscles
            ? _value._secondaryMuscles
            : secondaryMuscles // ignore: cast_nullable_to_non_nullable
                  as List<MuscleRef>,
        bodyParts: null == bodyParts
            ? _value._bodyParts
            : bodyParts // ignore: cast_nullable_to_non_nullable
                  as List<BodyPartRef>,
        equipments: null == equipments
            ? _value._equipments
            : equipments // ignore: cast_nullable_to_non_nullable
                  as List<EquipmentRef>,
        variations: null == variations
            ? _value._variations
            : variations // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        alias: null == alias
            ? _value._alias
            : alias // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        userContraindications: null == userContraindications
            ? _value._userContraindications
            : userContraindications // ignore: cast_nullable_to_non_nullable
                  as List<ContraindicationEntry>,
        similarExercises: null == similarExercises
            ? _value._similarExercises
            : similarExercises // ignore: cast_nullable_to_non_nullable
                  as List<ExerciseShort>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseDetailImpl implements _ExerciseDetail {
  const _$ExerciseDetailImpl({
    required this.slug,
    required this.name,
    this.imageUrl,
    this.description,
    this.exerciseType,
    this.difficulty,
    this.movementPattern,
    this.confidence,
    final List<String> instructions = const [],
    final List<MuscleRef> targetMuscles = const [],
    final List<MuscleRef> secondaryMuscles = const [],
    final List<BodyPartRef> bodyParts = const [],
    final List<EquipmentRef> equipments = const [],
    final List<String> variations = const [],
    final List<String> alias = const [],
    final List<ContraindicationEntry> userContraindications = const [],
    final List<ExerciseShort> similarExercises = const [],
  }) : _instructions = instructions,
       _targetMuscles = targetMuscles,
       _secondaryMuscles = secondaryMuscles,
       _bodyParts = bodyParts,
       _equipments = equipments,
       _variations = variations,
       _alias = alias,
       _userContraindications = userContraindications,
       _similarExercises = similarExercises;

  factory _$ExerciseDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseDetailImplFromJson(json);

  @override
  final String slug;
  @override
  final String name;
  @override
  final String? imageUrl;
  @override
  final String? description;
  @override
  final String? exerciseType;
  @override
  final String? difficulty;
  @override
  final String? movementPattern;
  @override
  final double? confidence;
  final List<String> _instructions;
  @override
  @JsonKey()
  List<String> get instructions {
    if (_instructions is EqualUnmodifiableListView) return _instructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_instructions);
  }

  final List<MuscleRef> _targetMuscles;
  @override
  @JsonKey()
  List<MuscleRef> get targetMuscles {
    if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetMuscles);
  }

  final List<MuscleRef> _secondaryMuscles;
  @override
  @JsonKey()
  List<MuscleRef> get secondaryMuscles {
    if (_secondaryMuscles is EqualUnmodifiableListView)
      return _secondaryMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_secondaryMuscles);
  }

  final List<BodyPartRef> _bodyParts;
  @override
  @JsonKey()
  List<BodyPartRef> get bodyParts {
    if (_bodyParts is EqualUnmodifiableListView) return _bodyParts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bodyParts);
  }

  final List<EquipmentRef> _equipments;
  @override
  @JsonKey()
  List<EquipmentRef> get equipments {
    if (_equipments is EqualUnmodifiableListView) return _equipments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipments);
  }

  final List<String> _variations;
  @override
  @JsonKey()
  List<String> get variations {
    if (_variations is EqualUnmodifiableListView) return _variations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variations);
  }

  final List<String> _alias;
  @override
  @JsonKey()
  List<String> get alias {
    if (_alias is EqualUnmodifiableListView) return _alias;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alias);
  }

  final List<ContraindicationEntry> _userContraindications;
  @override
  @JsonKey()
  List<ContraindicationEntry> get userContraindications {
    if (_userContraindications is EqualUnmodifiableListView)
      return _userContraindications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userContraindications);
  }

  final List<ExerciseShort> _similarExercises;
  @override
  @JsonKey()
  List<ExerciseShort> get similarExercises {
    if (_similarExercises is EqualUnmodifiableListView)
      return _similarExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_similarExercises);
  }

  @override
  String toString() {
    return 'ExerciseDetail(slug: $slug, name: $name, imageUrl: $imageUrl, description: $description, exerciseType: $exerciseType, difficulty: $difficulty, movementPattern: $movementPattern, confidence: $confidence, instructions: $instructions, targetMuscles: $targetMuscles, secondaryMuscles: $secondaryMuscles, bodyParts: $bodyParts, equipments: $equipments, variations: $variations, alias: $alias, userContraindications: $userContraindications, similarExercises: $similarExercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseDetailImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.exerciseType, exerciseType) ||
                other.exerciseType == exerciseType) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.movementPattern, movementPattern) ||
                other.movementPattern == movementPattern) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality().equals(
              other._instructions,
              _instructions,
            ) &&
            const DeepCollectionEquality().equals(
              other._targetMuscles,
              _targetMuscles,
            ) &&
            const DeepCollectionEquality().equals(
              other._secondaryMuscles,
              _secondaryMuscles,
            ) &&
            const DeepCollectionEquality().equals(
              other._bodyParts,
              _bodyParts,
            ) &&
            const DeepCollectionEquality().equals(
              other._equipments,
              _equipments,
            ) &&
            const DeepCollectionEquality().equals(
              other._variations,
              _variations,
            ) &&
            const DeepCollectionEquality().equals(other._alias, _alias) &&
            const DeepCollectionEquality().equals(
              other._userContraindications,
              _userContraindications,
            ) &&
            const DeepCollectionEquality().equals(
              other._similarExercises,
              _similarExercises,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    slug,
    name,
    imageUrl,
    description,
    exerciseType,
    difficulty,
    movementPattern,
    confidence,
    const DeepCollectionEquality().hash(_instructions),
    const DeepCollectionEquality().hash(_targetMuscles),
    const DeepCollectionEquality().hash(_secondaryMuscles),
    const DeepCollectionEquality().hash(_bodyParts),
    const DeepCollectionEquality().hash(_equipments),
    const DeepCollectionEquality().hash(_variations),
    const DeepCollectionEquality().hash(_alias),
    const DeepCollectionEquality().hash(_userContraindications),
    const DeepCollectionEquality().hash(_similarExercises),
  );

  /// Create a copy of ExerciseDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseDetailImplCopyWith<_$ExerciseDetailImpl> get copyWith =>
      __$$ExerciseDetailImplCopyWithImpl<_$ExerciseDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseDetailImplToJson(this);
  }
}

abstract class _ExerciseDetail implements ExerciseDetail {
  const factory _ExerciseDetail({
    required final String slug,
    required final String name,
    final String? imageUrl,
    final String? description,
    final String? exerciseType,
    final String? difficulty,
    final String? movementPattern,
    final double? confidence,
    final List<String> instructions,
    final List<MuscleRef> targetMuscles,
    final List<MuscleRef> secondaryMuscles,
    final List<BodyPartRef> bodyParts,
    final List<EquipmentRef> equipments,
    final List<String> variations,
    final List<String> alias,
    final List<ContraindicationEntry> userContraindications,
    final List<ExerciseShort> similarExercises,
  }) = _$ExerciseDetailImpl;

  factory _ExerciseDetail.fromJson(Map<String, dynamic> json) =
      _$ExerciseDetailImpl.fromJson;

  @override
  String get slug;
  @override
  String get name;
  @override
  String? get imageUrl;
  @override
  String? get description;
  @override
  String? get exerciseType;
  @override
  String? get difficulty;
  @override
  String? get movementPattern;
  @override
  double? get confidence;
  @override
  List<String> get instructions;
  @override
  List<MuscleRef> get targetMuscles;
  @override
  List<MuscleRef> get secondaryMuscles;
  @override
  List<BodyPartRef> get bodyParts;
  @override
  List<EquipmentRef> get equipments;
  @override
  List<String> get variations;
  @override
  List<String> get alias;
  @override
  List<ContraindicationEntry> get userContraindications;
  @override
  List<ExerciseShort> get similarExercises;

  /// Create a copy of ExerciseDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseDetailImplCopyWith<_$ExerciseDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
