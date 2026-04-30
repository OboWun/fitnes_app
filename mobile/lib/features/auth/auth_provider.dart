import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/auth_storage.dart';
import 'data/auth_api.dart';
import 'data/auth_repository.dart';
import 'domain/auth_state.dart';
import 'domain/user_model.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authApiProvider),
    ref.watch(authStorageProvider),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  /// Инициализация при старте приложения
  Future<void> initialize() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _repository.authenticate();
      final user = result.user;

      if (user.isProfileComplete) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          accessToken: result.accessToken,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.onboarding,
          user: user,
          accessToken: result.accessToken,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Обновление профиля (из онбординга)
  Future<void> updateProfile({
    String? name,
    String? gender,
    int? age,
    int? weight,
    int? height,
    List<String>? contraindications,
  }) async {
    try {
      final updatedUser = await _repository.updateProfile(
        name: name,
        gender: gender,
        age: age,
        weight: weight,
        height: height,
        contraindications: contraindications,
      );

      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Заве��шение онбординга
  void completeOnboarding() {
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  /// Обновляет user локально (без отправки на сервер)
  void updateUserLocally(UserModel user) {
    state = state.copyWith(user: user);
  }
}
