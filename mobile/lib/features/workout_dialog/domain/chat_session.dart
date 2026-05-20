import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_session.freezed.dart';
part 'chat_session.g.dart';

enum ChatMode {
  @JsonValue('chat')
  chat,
  @JsonValue('workout')
  workout;

  String get label => switch (this) {
        ChatMode.chat => 'Чат',
        ChatMode.workout => 'Тренировка',
      };
}

@Freezed(fromJson: true, toJson: true)
class ChatSession with _$ChatSession {
  const factory ChatSession({
    required String id,
    @Default(ChatMode.chat) ChatMode mode,
    String? dialogId,
    String? title,
    DateTime? createdAt,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);
}
