// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EquipmentRef _$EquipmentRefFromJson(Map<String, dynamic> json) {
  return _EquipmentRef.fromJson(json);
}

/// @nodoc
mixin _$EquipmentRef {
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this EquipmentRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentRefCopyWith<EquipmentRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentRefCopyWith<$Res> {
  factory $EquipmentRefCopyWith(
    EquipmentRef value,
    $Res Function(EquipmentRef) then,
  ) = _$EquipmentRefCopyWithImpl<$Res, EquipmentRef>;
  @useResult
  $Res call({String slug, String name, String? description, String? imageUrl});
}

/// @nodoc
class _$EquipmentRefCopyWithImpl<$Res, $Val extends EquipmentRef>
    implements $EquipmentRefCopyWith<$Res> {
  _$EquipmentRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EquipmentRefImplCopyWith<$Res>
    implements $EquipmentRefCopyWith<$Res> {
  factory _$$EquipmentRefImplCopyWith(
    _$EquipmentRefImpl value,
    $Res Function(_$EquipmentRefImpl) then,
  ) = __$$EquipmentRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String slug, String name, String? description, String? imageUrl});
}

/// @nodoc
class __$$EquipmentRefImplCopyWithImpl<$Res>
    extends _$EquipmentRefCopyWithImpl<$Res, _$EquipmentRefImpl>
    implements _$$EquipmentRefImplCopyWith<$Res> {
  __$$EquipmentRefImplCopyWithImpl(
    _$EquipmentRefImpl _value,
    $Res Function(_$EquipmentRefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquipmentRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$EquipmentRefImpl(
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EquipmentRefImpl implements _EquipmentRef {
  const _$EquipmentRefImpl({
    required this.slug,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory _$EquipmentRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipmentRefImplFromJson(json);

  @override
  final String slug;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'EquipmentRef(slug: $slug, name: $name, description: $description, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentRefImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, slug, name, description, imageUrl);

  /// Create a copy of EquipmentRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentRefImplCopyWith<_$EquipmentRefImpl> get copyWith =>
      __$$EquipmentRefImplCopyWithImpl<_$EquipmentRefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipmentRefImplToJson(this);
  }
}

abstract class _EquipmentRef implements EquipmentRef {
  const factory _EquipmentRef({
    required final String slug,
    required final String name,
    final String? description,
    final String? imageUrl,
  }) = _$EquipmentRefImpl;

  factory _EquipmentRef.fromJson(Map<String, dynamic> json) =
      _$EquipmentRefImpl.fromJson;

  @override
  String get slug;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get imageUrl;

  /// Create a copy of EquipmentRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentRefImplCopyWith<_$EquipmentRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
