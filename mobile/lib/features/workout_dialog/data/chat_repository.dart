import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/retry.dart';
import '../domain/chat_message.dart';
import '../domain/chat_session.dart';
import 'chat_api.dart';

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  return ChatRepository(ref.watch(chatApiProvider));
}

class ChatRepository {
  final ChatApi _api;

  ChatRepository(this._api);

  Future<ChatSession> createSession({
    ChatMode mode = ChatMode.workout,
    String? title,
  }) async {
    final data = await withRetry(() => _api.createSession(
          mode: mode.name,
          title: title,
        ));
    return ChatSession.fromJson(data);
  }

  Future<List<ChatSession>> getSessions() async {
    final data = await withRetry(() => _api.getSessions());
    return data.map((e) => ChatSession.fromJson(e)).toList();
  }

  Future<ChatSessionWithMessages> getSession(String id) async {
    final data = await withRetry(() => _api.getSession(id));
    final session = ChatSession.fromJson(data);
    final messages = (data['messages'] as List<dynamic>)
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ChatSessionWithMessages(session: session, messages: messages);
  }

  Future<void> deleteSession(String id) async {
    await withRetry(() => _api.deleteSession(id));
  }

  Future<SendMessageResult> sendMessage(String sessionId, String content) async {
    final data =
        await withRetry(() => _api.sendMessage(sessionId, content));
    return SendMessageResult(
      userMessageId: data['userMessageId'] as String,
      assistantMessageId: data['assistantMessageId'] as String,
      content: data['content'] as String,
      mode: data['mode'] as String? ?? 'chat',
      dialogCompleted: data['dialogCompleted'] as bool? ?? false,
      workoutResult: data['workoutResult'] as Map<String, dynamic>?,
    );
  }

  Future<ChatSession> switchMode(String sessionId, ChatMode mode) async {
    final data =
        await withRetry(() => _api.switchMode(sessionId, mode.name));
    return ChatSession.fromJson(data);
  }
}

class ChatSessionWithMessages {
  final ChatSession session;
  final List<ChatMessageModel> messages;

  const ChatSessionWithMessages({required this.session, required this.messages});
}

class SendMessageResult {
  final String userMessageId;
  final String assistantMessageId;
  final String content;
  final String mode;
  final bool dialogCompleted;
  final Map<String, dynamic>? workoutResult;

  const SendMessageResult({
    required this.userMessageId,
    required this.assistantMessageId,
    required this.content,
    required this.mode,
    required this.dialogCompleted,
    this.workoutResult,
  });
}
