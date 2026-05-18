// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeightRecord _$WeightRecordFromJson(Map<String, dynamic> json) {
  return _WeightRecord.fromJson(json);
}

/// @nodoc
mixin _$WeightRecord {
  DateTime get date => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;

  /// Serializes this WeightRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeightRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeightRecordCopyWith<WeightRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightRecordCopyWith<$Res> {
  factory $WeightRecordCopyWith(
    WeightRecord value,
    $Res Function(WeightRecord) then,
  ) = _$WeightRecordCopyWithImpl<$Res, WeightRecord>;
  @useResult
  $Res call({DateTime date, double weight});
}

/// @nodoc
class _$WeightRecordCopyWithImpl<$Res, $Val extends WeightRecord>
    implements $WeightRecordCopyWith<$Res> {
  _$WeightRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeightRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? weight = null}) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeightRecordImplCopyWith<$Res>
    implements $WeightRecordCopyWith<$Res> {
  factory _$$WeightRecordImplCopyWith(
    _$WeightRecordImpl value,
    $Res Function(_$WeightRecordImpl) then,
  ) = __$$WeightRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, double weight});
}

/// @nodoc
class __$$WeightRecordImplCopyWithImpl<$Res>
    extends _$WeightRecordCopyWithImpl<$Res, _$WeightRecordImpl>
    implements _$$WeightRecordImplCopyWith<$Res> {
  __$$WeightRecordImplCopyWithImpl(
    _$WeightRecordImpl _value,
    $Res Function(_$WeightRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeightRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? weight = null}) {
    return _then(
      _$WeightRecordImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeightRecordImpl implements _WeightRecord {
  const _$WeightRecordImpl({required this.date, required this.weight});

  factory _$WeightRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightRecordImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double weight;

  @override
  String toString() {
    return 'WeightRecord(date: $date, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightRecordImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, weight);

  /// Create a copy of WeightRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightRecordImplCopyWith<_$WeightRecordImpl> get copyWith =>
      __$$WeightRecordImplCopyWithImpl<_$WeightRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightRecordImplToJson(this);
  }
}

abstract class _WeightRecord implements WeightRecord {
  const factory _WeightRecord({
    required final DateTime date,
    required final double weight,
  }) = _$WeightRecordImpl;

  factory _WeightRecord.fromJson(Map<String, dynamic> json) =
      _$WeightRecordImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get weight;

  /// Create a copy of WeightRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeightRecordImplCopyWith<_$WeightRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
