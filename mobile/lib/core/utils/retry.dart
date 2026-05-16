import 'dart:async';

Future<T> withRetry<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
}) async {
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await action();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      final delay = Duration(seconds: attempt);
      await Future<void>.delayed(delay);
    }
  }
  throw StateError('unreachable');
}
