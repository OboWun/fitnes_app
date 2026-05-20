// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dialog_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DialogOption _$DialogOptionFromJson(Map<String, dynamic> json) {
  return _DialogOption.fromJson(json);
}

/// @nodoc
mixin _$DialogOption {
  String get value => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Serializes this DialogOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DialogOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DialogOptionCopyWith<DialogOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DialogOptionCopyWith<$Res> {
  factory $DialogOptionCopyWith(
    DialogOption value,
    $Res Function(DialogOption) then,
  ) = _$DialogOptionCopyWithImpl<$Res, DialogOption>;
  @useResult
  $Res call({String value, String label});
}

/// @nodoc
class _$DialogOptionCopyWithImpl<$Res, $Val extends DialogOption>
    implements $DialogOptionCopyWith<$Res> {
  _$DialogOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DialogOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null, Object? label = null}) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DialogOptionImplCopyWith<$Res>
    implements $DialogOptionCopyWith<$Res> {
  factory _$$DialogOptionImplCopyWith(
    _$DialogOptionImpl value,
    $Res Function(_$DialogOptionImpl) then,
  ) = __$$DialogOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, String label});
}

/// @nodoc
class __$$DialogOptionImplCopyWithImpl<$Res>
    extends _$DialogOptionCopyWithImpl<$Res, _$DialogOptionImpl>
    implements _$$DialogOptionImplCopyWith<$Res> {
  __$$DialogOptionImplCopyWithImpl(
    _$DialogOptionImpl _value,
    $Res Function(_$DialogOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DialogOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null, Object? label = null}) {
    return _then(
      _$DialogOptionImpl(
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DialogOptionImpl implements _DialogOption {
  const _$DialogOptionImpl({required this.value, required this.label});

  factory _$DialogOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DialogOptionImplFromJson(json);

  @override
  final String value;
  @override
  final String label;

  @override
  String toString() {
    return 'DialogOption(value: $value, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DialogOptionImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, label);

  /// Create a copy of DialogOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DialogOptionImplCopyWith<_$DialogOptionImpl> get copyWith =>
      __$$DialogOptionImplCopyWithImpl<_$DialogOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DialogOptionImplToJson(this);
  }
}

abstract class _DialogOption implements DialogOption {
  const factory _DialogOption({
    required final String value,
    required final String label,
  }) = _$DialogOptionImpl;

  factory _DialogOption.fromJson(Map<String, dynamic> json) =
      _$DialogOptionImpl.fromJson;

  @override
  String get value;
  @override
  String get label;

  /// Create a copy of DialogOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DialogOptionImplCopyWith<_$DialogOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
