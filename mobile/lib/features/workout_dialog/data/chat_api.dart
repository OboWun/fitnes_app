import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'chat_api.g.dart';

@riverpod
ChatApi chatApi(ChatApiRef ref) {
  return ChatApi(ref.watch(dioProvider));
}

class ChatApi {
  final Dio _dio;

  ChatApi(this._dio);

  Future<Map<String, dynamic>> createSession({
    String mode = 'chat',
    String? title,
  }) async {
    final response = await _dio.post('/chat/sessions', data: {
      'mode': mode,
      if (title != null) 'title': title,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final response = await _dio.get('/chat/sessions');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getSession(String id) async {
    final response = await _dio.get('/chat/sessions/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteSession(String id) async {
    await _dio.delete('/chat/sessions/$id');
  }

  Future<Map<String, dynamic>> sendMessage(String sessionId, String content) async {
    final response = await _dio.post(
      '/chat/sessions/$sessionId/messages',
      data: {'content': content},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> switchMode(String sessionId, String mode) async {
    final response = await _dio.patch(
      '/chat/sessions/$sessionId/mode',
      data: {'mode': mode},
    );
    return response.data as Map<String, dynamic>;
  }
}
