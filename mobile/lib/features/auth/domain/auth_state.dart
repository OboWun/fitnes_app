import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    UserModel? user,
    String? accessToken,
    String? errorMessage,
  }) = _AuthState;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isError => status == AuthStatus.error;
  bool get needsOnboarding => status == AuthStatus.onboarding;
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  onboarding,
  error,
}
