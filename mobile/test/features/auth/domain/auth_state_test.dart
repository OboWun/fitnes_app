import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/auth/domain/auth_state.dart';

import '../../../helpers/fakes.dart';

void main() {
  group('AuthState', () {
    test('has correct defaults', () {
      const state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.accessToken, isNull);
      expect(state.errorMessage, isNull);
    });

    group('copyWith', () {
      test('updates status', () {
        const state = AuthState();
        final updated = state.copyWith(status: AuthStatus.loading);

        expect(updated.status, AuthStatus.loading);
        expect(updated.user, isNull);
      });

      test('updates user', () {
        final user = testUserModel(name: 'Иван', gender: 'male');
        const state = AuthState();
        final updated = state.copyWith(user: user);

        expect(updated.user, user);
        expect(updated.status, AuthStatus.initial);
      });

      test('can clear error message with null', () {
        const state = AuthState(
          status: AuthStatus.error,
          errorMessage: 'Some error',
        );
        final updated = state.copyWith();

        expect(updated.errorMessage, 'Some error');
      });

      test('updates accessToken', () {
        const state = AuthState();
        final updated = state.copyWith(accessToken: 'jwt-token-123');

        expect(updated.accessToken, 'jwt-token-123');
      });

      test('sets error state', () {
        const state = AuthState();
        final updated = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Network failure',
        );

        expect(updated.status, AuthStatus.error);
        expect(updated.errorMessage, 'Network failure');
      });
    });

    group('computed getters', () {
      test('isAuthenticated', () {
        const state = AuthState(status: AuthStatus.authenticated);
        expect(state.isAuthenticated, isTrue);

        const state2 = AuthState(status: AuthStatus.loading);
        expect(state2.isAuthenticated, isFalse);
      });

      test('isLoading', () {
        const state = AuthState(status: AuthStatus.loading);
        expect(state.isLoading, isTrue);

        const state2 = AuthState(status: AuthStatus.authenticated);
        expect(state2.isLoading, isFalse);
      });

      test('isError', () {
        const state = AuthState(status: AuthStatus.error);
        expect(state.isError, isTrue);

        const state2 = AuthState(status: AuthStatus.initial);
        expect(state2.isError, isFalse);
      });

      test('needsOnboarding', () {
        const state = AuthState(status: AuthStatus.onboarding);
        expect(state.needsOnboarding, isTrue);

        const state2 = AuthState(status: AuthStatus.authenticated);
        expect(state2.needsOnboarding, isFalse);
      });
    });

    group('AuthStatus enum', () {
      test('has all expected values', () {
        expect(AuthStatus.values, containsAll([
          AuthStatus.initial,
          AuthStatus.loading,
          AuthStatus.authenticated,
          AuthStatus.unauthenticated,
          AuthStatus.onboarding,
          AuthStatus.error,
        ]));
      });
    });
  });
}
