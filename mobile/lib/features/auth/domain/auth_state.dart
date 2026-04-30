import 'user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, onboarding, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? accessToken;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? accessToken,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
