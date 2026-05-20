import 'package:freezed_annotation/freezed_annotation.dart';

part 'dialog_option.freezed.dart';
part 'dialog_option.g.dart';

@Freezed(fromJson: true, toJson: true)
class DialogOption with _$DialogOption {
  const factory DialogOption({
    required String value,
    required String label,
  }) = _DialogOption;

  factory DialogOption.fromJson(Map<String, dynamic> json) =>
      _$DialogOptionFromJson(json);
}
