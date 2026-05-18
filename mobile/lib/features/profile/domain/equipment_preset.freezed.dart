// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EquipmentDetail _$EquipmentDetailFromJson(Map<String, dynamic> json) {
  return _EquipmentDetail.fromJson(json);
}

/// @nodoc
mixin _$EquipmentDetail {
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this EquipmentDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentDetailCopyWith<EquipmentDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentDetailCopyWith<$Res> {
  factory $EquipmentDetailCopyWith(
    EquipmentDetail value,
    $Res Function(EquipmentDetail) then,
  ) = _$EquipmentDetailCopyWithImpl<$Res, EquipmentDetail>;
  @useResult
  $Res call({String slug, String name});
}

/// @nodoc
class _$EquipmentDetailCopyWithImpl<$Res, $Val extends EquipmentDetail>
    implements $EquipmentDetailCopyWith<$Res> {
  _$EquipmentDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentDetail
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
abstract class _$$EquipmentDetailImplCopyWith<$Res>
    implements $EquipmentDetailCopyWith<$Res> {
  factory _$$EquipmentDetailImplCopyWith(
    _$EquipmentDetailImpl value,
    $Res Function(_$EquipmentDetailImpl) then,
  ) = __$$EquipmentDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String slug, String name});
}

/// @nodoc
class __$$EquipmentDetailImplCopyWithImpl<$Res>
    extends _$EquipmentDetailCopyWithImpl<$Res, _$EquipmentDetailImpl>
    implements _$$EquipmentDetailImplCopyWith<$Res> {
  __$$EquipmentDetailImplCopyWithImpl(
    _$EquipmentDetailImpl _value,
    $Res Function(_$EquipmentDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquipmentDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slug = null, Object? name = null}) {
    return _then(
      _$EquipmentDetailImpl(
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
class _$EquipmentDetailImpl implements _EquipmentDetail {
  const _$EquipmentDetailImpl({required this.slug, required this.name});

  factory _$EquipmentDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipmentDetailImplFromJson(json);

  @override
  final String slug;
  @override
  final String name;

  @override
  String toString() {
    return 'EquipmentDetail(slug: $slug, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentDetailImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, slug, name);

  /// Create a copy of EquipmentDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentDetailImplCopyWith<_$EquipmentDetailImpl> get copyWith =>
      __$$EquipmentDetailImplCopyWithImpl<_$EquipmentDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipmentDetailImplToJson(this);
  }
}

abstract class _EquipmentDetail implements EquipmentDetail {
  const factory _EquipmentDetail({
    required final String slug,
    required final String name,
  }) = _$EquipmentDetailImpl;

  factory _EquipmentDetail.fromJson(Map<String, dynamic> json) =
      _$EquipmentDetailImpl.fromJson;

  @override
  String get slug;
  @override
  String get name;

  /// Create a copy of EquipmentDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentDetailImplCopyWith<_$EquipmentDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EquipmentPreset _$EquipmentPresetFromJson(Map<String, dynamic> json) {
  return _EquipmentPreset.fromJson(json);
}

/// @nodoc
mixin _$EquipmentPreset {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  bool get isSystem => throw _privateConstructorUsedError;
  List<String> get equipmentSlugs => throw _privateConstructorUsedError;
  List<EquipmentDetail> get equipmentDetails =>
      throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this EquipmentPreset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentPresetCopyWith<EquipmentPreset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentPresetCopyWith<$Res> {
  factory $EquipmentPresetCopyWith(
    EquipmentPreset value,
    $Res Function(EquipmentPreset) then,
  ) = _$EquipmentPresetCopyWithImpl<$Res, EquipmentPreset>;
  @useResult
  $Res call({
    String id,
    String name,
    String slug,
    bool isSystem,
    List<String> equipmentSlugs,
    List<EquipmentDetail> equipmentDetails,
    String? createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class _$EquipmentPresetCopyWithImpl<$Res, $Val extends EquipmentPreset>
    implements $EquipmentPresetCopyWith<$Res> {
  _$EquipmentPresetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? isSystem = null,
    Object? equipmentSlugs = null,
    Object? equipmentDetails = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            isSystem: null == isSystem
                ? _value.isSystem
                : isSystem // ignore: cast_nullable_to_non_nullable
                      as bool,
            equipmentSlugs: null == equipmentSlugs
                ? _value.equipmentSlugs
                : equipmentSlugs // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            equipmentDetails: null == equipmentDetails
                ? _value.equipmentDetails
                : equipmentDetails // ignore: cast_nullable_to_non_nullable
                      as List<EquipmentDetail>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EquipmentPresetImplCopyWith<$Res>
    implements $EquipmentPresetCopyWith<$Res> {
  factory _$$EquipmentPresetImplCopyWith(
    _$EquipmentPresetImpl value,
    $Res Function(_$EquipmentPresetImpl) then,
  ) = __$$EquipmentPresetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String slug,
    bool isSystem,
    List<String> equipmentSlugs,
    List<EquipmentDetail> equipmentDetails,
    String? createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class __$$EquipmentPresetImplCopyWithImpl<$Res>
    extends _$EquipmentPresetCopyWithImpl<$Res, _$EquipmentPresetImpl>
    implements _$$EquipmentPresetImplCopyWith<$Res> {
  __$$EquipmentPresetImplCopyWithImpl(
    _$EquipmentPresetImpl _value,
    $Res Function(_$EquipmentPresetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquipmentPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? isSystem = null,
    Object? equipmentSlugs = null,
    Object? equipmentDetails = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$EquipmentPresetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        isSystem: null == isSystem
            ? _value.isSystem
            : isSystem // ignore: cast_nullable_to_non_nullable
                  as bool,
        equipmentSlugs: null == equipmentSlugs
            ? _value._equipmentSlugs
            : equipmentSlugs // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        equipmentDetails: null == equipmentDetails
            ? _value._equipmentDetails
            : equipmentDetails // ignore: cast_nullable_to_non_nullable
                  as List<EquipmentDetail>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EquipmentPresetImpl implements _EquipmentPreset {
  const _$EquipmentPresetImpl({
    required this.id,
    required this.name,
    required this.slug,
    this.isSystem = false,
    final List<String> equipmentSlugs = const [],
    final List<EquipmentDetail> equipmentDetails = const [],
    this.createdAt,
    this.updatedAt,
  }) : _equipmentSlugs = equipmentSlugs,
       _equipmentDetails = equipmentDetails;

  factory _$EquipmentPresetImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipmentPresetImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String slug;
  @override
  @JsonKey()
  final bool isSystem;
  final List<String> _equipmentSlugs;
  @override
  @JsonKey()
  List<String> get equipmentSlugs {
    if (_equipmentSlugs is EqualUnmodifiableListView) return _equipmentSlugs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipmentSlugs);
  }

  final List<EquipmentDetail> _equipmentDetails;
  @override
  @JsonKey()
  List<EquipmentDetail> get equipmentDetails {
    if (_equipmentDetails is EqualUnmodifiableListView)
      return _equipmentDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipmentDetails);
  }

  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'EquipmentPreset(id: $id, name: $name, slug: $slug, isSystem: $isSystem, equipmentSlugs: $equipmentSlugs, equipmentDetails: $equipmentDetails, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentPresetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.isSystem, isSystem) ||
                other.isSystem == isSystem) &&
            const DeepCollectionEquality().equals(
              other._equipmentSlugs,
              _equipmentSlugs,
            ) &&
            const DeepCollectionEquality().equals(
              other._equipmentDetails,
              _equipmentDetails,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    slug,
    isSystem,
    const DeepCollectionEquality().hash(_equipmentSlugs),
    const DeepCollectionEquality().hash(_equipmentDetails),
    createdAt,
    updatedAt,
  );

  /// Create a copy of EquipmentPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentPresetImplCopyWith<_$EquipmentPresetImpl> get copyWith =>
      __$$EquipmentPresetImplCopyWithImpl<_$EquipmentPresetImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipmentPresetImplToJson(this);
  }
}

abstract class _EquipmentPreset implements EquipmentPreset {
  const factory _EquipmentPreset({
    required final String id,
    required final String name,
    required final String slug,
    final bool isSystem,
    final List<String> equipmentSlugs,
    final List<EquipmentDetail> equipmentDetails,
    final String? createdAt,
    final String? updatedAt,
  }) = _$EquipmentPresetImpl;

  factory _EquipmentPreset.fromJson(Map<String, dynamic> json) =
      _$EquipmentPresetImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  bool get isSystem;
  @override
  List<String> get equipmentSlugs;
  @override
  List<EquipmentDetail> get equipmentDetails;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of EquipmentPreset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentPresetImplCopyWith<_$EquipmentPresetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
