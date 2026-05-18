import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_record.freezed.dart';
part 'weight_record.g.dart';

@Freezed(fromJson: true, toJson: true)
class WeightRecord with _$WeightRecord {
  const factory WeightRecord({
    required DateTime date,
    required double weight,
  }) = _WeightRecord;

  factory WeightRecord.fromJson(Map<String, dynamic> json) =>
      _$WeightRecordFromJson(json);
}

enum WeightPeriod {
  week,
  month,
  all,
}
