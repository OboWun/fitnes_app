// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_short.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExerciseShort _$ExerciseShortFromJson(Map<String, dynamic> json) {
  return _ExerciseShort.fromJson(json);
}

/// @nodoc
mixin _$ExerciseShort {
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<EquipmentRef> get equipments => throw _privateConstructorUsedError;
  String? get contraindication => throw _privateConstructorUsedError;

  /// Serializes this ExerciseShort to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseShort
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseShortCopyWith<ExerciseShort> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseShortCopyWith<$Res> {
  factory $ExerciseShortCopyWith(
    ExerciseShort value,
    $Res Function(ExerciseShort) then,
  ) = _$ExerciseShortCopyWithImpl<$Res, ExerciseShort>;
  @useResult
  $Res call({
    String slug,
    String name,
    String? imageUrl,
    String? description,
    List<EquipmentRef> equipments,
    String? contraindication,
  });
}

/// @nodoc
class _$ExerciseShortCopyWithImpl<$Res, $Val extends ExerciseShort>
    implements $ExerciseShortCopyWith<$Res> {
  _$ExerciseShortCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseShort
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? equipments = null,
    Object? contraindication = freezed,
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
            equipments: null == equipments
                ? _value.equipments
                : equipments // ignore: cast_nullable_to_non_nullable
                      as List<EquipmentRef>,
            contraindication: freezed == contraindication
                ? _value.contraindication
                : contraindication // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExerciseShortImplCopyWith<$Res>
    implements $ExerciseShortCopyWith<$Res> {
  factory _$$ExerciseShortImplCopyWith(
    _$ExerciseShortImpl value,
    $Res Function(_$ExerciseShortImpl) then,
  ) = __$$ExerciseShortImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String slug,
    String name,
    String? imageUrl,
    String? description,
    List<EquipmentRef> equipments,
    String? contraindication,
  });
}

/// @nodoc
class __$$ExerciseShortImplCopyWithImpl<$Res>
    extends _$ExerciseShortCopyWithImpl<$Res, _$ExerciseShortImpl>
    implements _$$ExerciseShortImplCopyWith<$Res> {
  __$$ExerciseShortImplCopyWithImpl(
    _$ExerciseShortImpl _value,
    $Res Function(_$ExerciseShortImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseShort
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? equipments = null,
    Object? contraindication = freezed,
  }) {
    return _then(
      _$ExerciseShortImpl(
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
        equipments: null == equipments
            ? _value._equipments
            : equipments // ignore: cast_nullable_to_non_nullable
                  as List<EquipmentRef>,
        contraindication: freezed == contraindication
            ? _value.contraindication
            : contraindication // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseShortImpl implements _ExerciseShort {
  const _$ExerciseShortImpl({
    required this.slug,
    required this.name,
    this.imageUrl,
    this.description,
    final List<EquipmentRef> equipments = const [],
    this.contraindication,
  }) : _equipments = equipments;

  factory _$ExerciseShortImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseShortImplFromJson(json);

  @override
  final String slug;
  @override
  final String name;
  @override
  final String? imageUrl;
  @override
  final String? description;
  final List<EquipmentRef> _equipments;
  @override
  @JsonKey()
  List<EquipmentRef> get equipments {
    if (_equipments is EqualUnmodifiableListView) return _equipments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipments);
  }

  @override
  final String? contraindication;

  @override
  String toString() {
    return 'ExerciseShort(slug: $slug, name: $name, imageUrl: $imageUrl, description: $description, equipments: $equipments, contraindication: $contraindication)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseShortImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._equipments,
              _equipments,
            ) &&
            (identical(other.contraindication, contraindication) ||
                other.contraindication == contraindication));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    slug,
    name,
    imageUrl,
    description,
    const DeepCollectionEquality().hash(_equipments),
    contraindication,
  );

  /// Create a copy of ExerciseShort
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseShortImplCopyWith<_$ExerciseShortImpl> get copyWith =>
      __$$ExerciseShortImplCopyWithImpl<_$ExerciseShortImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseShortImplToJson(this);
  }
}

abstract class _ExerciseShort implements ExerciseShort {
  const factory _ExerciseShort({
    required final String slug,
    required final String name,
    final String? imageUrl,
    final String? description,
    final List<EquipmentRef> equipments,
    final String? contraindication,
  }) = _$ExerciseShortImpl;

  factory _ExerciseShort.fromJson(Map<String, dynamic> json) =
      _$ExerciseShortImpl.fromJson;

  @override
  String get slug;
  @override
  String get name;
  @override
  String? get imageUrl;
  @override
  String? get description;
  @override
  List<EquipmentRef> get equipments;
  @override
  String? get contraindication;

  /// Create a copy of ExerciseShort
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseShortImplCopyWith<_$ExerciseShortImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
