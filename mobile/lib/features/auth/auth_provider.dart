import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/storage/auth_storage.dart';
import 'data/auth_repository.dart';
import 'domain/auth_state.dart';
import 'domain/user_model.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> initialize() async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.authenticate();
      final user = result.user;

      if (user.isProfileComplete) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          accessToken: result.accessToken,
        );
      } else {
        state = AuthState(
          status: AuthStatus.onboarding,
          user: user,
          accessToken: result.accessToken,
        );
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    String? name,
    String? gender,
    int? age,
    int? weight,
    int? height,
    List<String>? contraindications,
  }) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final updatedUser = await repository.updateProfile(
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

  void completeOnboarding() {
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  void updateUserLocally(UserModel user) {
    state = state.copyWith(user: user);
  }

  Future<void> logout() async {
    final storage = ref.read(authStorageProvider);
    await storage.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

@riverpod
Future<List<Map<String, dynamic>>> contraindications(
    ContraindicationsRef ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getContraindications();
}
