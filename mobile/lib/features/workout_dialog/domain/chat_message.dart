import 'package:freezed_annotation/freezed_annotation.dart';

import 'dialog_option.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum ChatRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system;
}

enum DialogInputType {
  @JsonValue('single_choice')
  singleChoice,
  @JsonValue('multi_choice')
  multiChoice,
  @JsonValue('number')
  number;
}

@Freezed(fromJson: true)
class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String id,
    required String sessionId,
    required ChatRole role,
    required String content,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}

extension ChatMessageMetadataX on ChatMessageModel {
  bool get isDialogStep =>
      metadata?['type'] == 'dialog_step';

  bool get isDialogComplete =>
      metadata?['type'] == 'dialog_complete';

  String? get dialogStep => metadata?['step'] as String?;

  DialogInputType? get dialogInputType {
    final raw = metadata?['inputType'] as String?;
    return switch (raw) {
      'single_choice' => DialogInputType.singleChoice,
      'multi_choice' => DialogInputType.multiChoice,
      'number' => DialogInputType.number,
      _ => null,
    };
  }

  List<DialogOption> get dialogOptions {
    final raw = metadata?['options'] as List<dynamic>?;
    if (raw == null) return [];
    return raw
        .map((e) => DialogOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  bool get canSkipDialog => metadata?['canSkip'] as bool? ?? false;

  String? get planType => metadata?['planType'] as String?;

  Map<String, dynamic>? get dialogParams {
    final p = metadata?['params'];
    if (p is Map<String, dynamic>) return p;
    return null;
  }
}
