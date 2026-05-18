// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_brief.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExerciseBrief _$ExerciseBriefFromJson(Map<String, dynamic> json) {
  return _ExerciseBrief.fromJson(json);
}

/// @nodoc
mixin _$ExerciseBrief {
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get gifUrl => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;

  /// Serializes this ExerciseBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseBriefCopyWith<ExerciseBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseBriefCopyWith<$Res> {
  factory $ExerciseBriefCopyWith(
    ExerciseBrief value,
    $Res Function(ExerciseBrief) then,
  ) = _$ExerciseBriefCopyWithImpl<$Res, ExerciseBrief>;
  @useResult
  $Res call({String slug, String name, String? gifUrl, String? difficulty});
}

/// @nodoc
class _$ExerciseBriefCopyWithImpl<$Res, $Val extends ExerciseBrief>
    implements $ExerciseBriefCopyWith<$Res> {
  _$ExerciseBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? gifUrl = freezed,
    Object? difficulty = freezed,
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
            gifUrl: freezed == gifUrl
                ? _value.gifUrl
                : gifUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            difficulty: freezed == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExerciseBriefImplCopyWith<$Res>
    implements $ExerciseBriefCopyWith<$Res> {
  factory _$$ExerciseBriefImplCopyWith(
    _$ExerciseBriefImpl value,
    $Res Function(_$ExerciseBriefImpl) then,
  ) = __$$ExerciseBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String slug, String name, String? gifUrl, String? difficulty});
}

/// @nodoc
class __$$ExerciseBriefImplCopyWithImpl<$Res>
    extends _$ExerciseBriefCopyWithImpl<$Res, _$ExerciseBriefImpl>
    implements _$$ExerciseBriefImplCopyWith<$Res> {
  __$$ExerciseBriefImplCopyWithImpl(
    _$ExerciseBriefImpl _value,
    $Res Function(_$ExerciseBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? gifUrl = freezed,
    Object? difficulty = freezed,
  }) {
    return _then(
      _$ExerciseBriefImpl(
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        gifUrl: freezed == gifUrl
            ? _value.gifUrl
            : gifUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        difficulty: freezed == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseBriefImpl implements _ExerciseBrief {
  const _$ExerciseBriefImpl({
    required this.slug,
    required this.name,
    this.gifUrl,
    this.difficulty,
  });

  factory _$ExerciseBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseBriefImplFromJson(json);

  @override
  final String slug;
  @override
  final String name;
  @override
  final String? gifUrl;
  @override
  final String? difficulty;

  @override
  String toString() {
    return 'ExerciseBrief(slug: $slug, name: $name, gifUrl: $gifUrl, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseBriefImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, slug, name, gifUrl, difficulty);

  /// Create a copy of ExerciseBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseBriefImplCopyWith<_$ExerciseBriefImpl> get copyWith =>
      __$$ExerciseBriefImplCopyWithImpl<_$ExerciseBriefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseBriefImplToJson(this);
  }
}

abstract class _ExerciseBrief implements ExerciseBrief {
  const factory _ExerciseBrief({
    required final String slug,
    required final String name,
    final String? gifUrl,
    final String? difficulty,
  }) = _$ExerciseBriefImpl;

  factory _ExerciseBrief.fromJson(Map<String, dynamic> json) =
      _$ExerciseBriefImpl.fromJson;

  @override
  String get slug;
  @override
  String get name;
  @override
  String? get gifUrl;
  @override
  String? get difficulty;

  /// Create a copy of ExerciseBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseBriefImplCopyWith<_$ExerciseBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
