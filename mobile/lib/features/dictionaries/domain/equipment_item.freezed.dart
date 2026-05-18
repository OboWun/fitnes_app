// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EquipmentItem _$EquipmentItemFromJson(Map<String, dynamic> json) {
  return _EquipmentItem.fromJson(json);
}

/// @nodoc
mixin _$EquipmentItem {
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this EquipmentItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentItemCopyWith<EquipmentItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentItemCopyWith<$Res> {
  factory $EquipmentItemCopyWith(
    EquipmentItem value,
    $Res Function(EquipmentItem) then,
  ) = _$EquipmentItemCopyWithImpl<$Res, EquipmentItem>;
  @useResult
  $Res call({String slug, String name, String? description, String? imageUrl});
}

/// @nodoc
class _$EquipmentItemCopyWithImpl<$Res, $Val extends EquipmentItem>
    implements $EquipmentItemCopyWith<$Res> {
  _$EquipmentItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentItem
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
abstract class _$$EquipmentItemImplCopyWith<$Res>
    implements $EquipmentItemCopyWith<$Res> {
  factory _$$EquipmentItemImplCopyWith(
    _$EquipmentItemImpl value,
    $Res Function(_$EquipmentItemImpl) then,
  ) = __$$EquipmentItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String slug, String name, String? description, String? imageUrl});
}

/// @nodoc
class __$$EquipmentItemImplCopyWithImpl<$Res>
    extends _$EquipmentItemCopyWithImpl<$Res, _$EquipmentItemImpl>
    implements _$$EquipmentItemImplCopyWith<$Res> {
  __$$EquipmentItemImplCopyWithImpl(
    _$EquipmentItemImpl _value,
    $Res Function(_$EquipmentItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquipmentItem
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
      _$EquipmentItemImpl(
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
class _$EquipmentItemImpl implements _EquipmentItem {
  const _$EquipmentItemImpl({
    required this.slug,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory _$EquipmentItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipmentItemImplFromJson(json);

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
    return 'EquipmentItem(slug: $slug, name: $name, description: $description, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentItemImpl &&
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

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentItemImplCopyWith<_$EquipmentItemImpl> get copyWith =>
      __$$EquipmentItemImplCopyWithImpl<_$EquipmentItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipmentItemImplToJson(this);
  }
}

abstract class _EquipmentItem implements EquipmentItem {
  const factory _EquipmentItem({
    required final String slug,
    required final String name,
    final String? description,
    final String? imageUrl,
  }) = _$EquipmentItemImpl;

  factory _EquipmentItem.fromJson(Map<String, dynamic> json) =
      _$EquipmentItemImpl.fromJson;

  @override
  String get slug;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get imageUrl;

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentItemImplCopyWith<_$EquipmentItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
