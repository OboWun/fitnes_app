import 'package:flutter/material.dart';

import '../network/exceptions.dart';

mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  void clearError() {
    if (_errorMessage == null) return;
    setState(() => _errorMessage = null);
  }

  void handleError(Object error) {
    final message = switch (error) {
      AppException e => e.message,
      _ => 'Произошла ошибка',
    };
    setState(() => _errorMessage = message);
    _showErrorToast(message);
  }

  void _showErrorToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> runWithErrorHandling(Future<void> Function() action) async {
    try {
      clearError();
      await action();
    } catch (e) {
      handleError(e);
    }
  }
}
