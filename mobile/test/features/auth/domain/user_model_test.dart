import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/auth/domain/user_model.dart';

import '../../../helpers/fakes.dart';

void main() {
  group('UserModel', () {
    group('fromJson', () {
      test('parses full JSON correctly', () {
        final user = UserModel.fromJson(testUserModelJson);

        expect(user.id, 'test-id-123');
        expect(user.deviceId, 'device-abc');
        expect(user.name, 'Иван');
        expect(user.gender, 'male');
        expect(user.weight, 75);
        expect(user.height, 180);
        expect(user.age, 30);
        expect(user.contraindications, ['knee_injury']);
        expect(user.createdAt, '2026-01-01T00:00:00.000Z');
      });

      test('parses minimal JSON with null optional fields', () {
        final user = UserModel.fromJson(testUserModelMinimalJson);

        expect(user.id, 'test-id-456');
        expect(user.deviceId, 'device-def');
        expect(user.name, isNull);
        expect(user.gender, isNull);
        expect(user.weight, isNull);
        expect(user.height, isNull);
        expect(user.age, isNull);
        expect(user.contraindications, isNull);
        expect(user.metadata, isNull);
      });

      test('parses metadata from JSON', () {
        final user = UserModel.fromJson(testUserModelJson);

        expect(user.metadata, isNotNull);
        expect(user.metadata!.goal, 'hypertrophy');
        expect(user.metadata!.experienceLevel, 'intermediate');
        expect(user.metadata!.availableEquipment, ['barbell', 'dumbbell']);
        expect(user.metadata!.defaultEquipmentPresetId, 'preset-gym-full');
      });
    });

    group('toJson', () {
      test('round-trips correctly', () {
        final user = UserModel.fromJson(testUserModelJson);
        final json = user.toJson();

        expect(json['id'], 'test-id-123');
        expect(json['deviceId'], 'device-abc');
        expect(json['name'], 'Иван');
        expect(json['gender'], 'male');
        expect(json['weight'], 75);
        expect(json['metadata'], isA<Map>());
      });

      test('serializes null fields', () {
        final user = UserModel.fromJson(testUserModelMinimalJson);
        final json = user.toJson();

        expect(json['name'], isNull);
        expect(json['gender'], isNull);
        expect(json['metadata'], isNull);
      });
    });

    group('isProfileComplete', () {
      test('returns true when name and gender are set', () {
        final user = testUserModel(name: 'Иван', gender: 'male');
        expect(user.isProfileComplete, isTrue);
      });

      test('returns false when only name is set', () {
        final user = testUserModel(name: 'Иван');
        expect(user.isProfileComplete, isFalse);
      });

      test('returns false when only gender is set', () {
        final user = testUserModel(gender: 'female');
        expect(user.isProfileComplete, isFalse);
      });

      test('returns false when both are null', () {
        final user = testUserModel();
        expect(user.isProfileComplete, isFalse);
      });

      test('returns false when name is empty string', () {
        final user = testUserModel(name: '', gender: 'male');
        expect(user.isProfileComplete, isFalse);
      });
    });

    group('copyWith', () {
      test('updates single field', () {
        final user = testUserModel(name: 'Иван');
        final updated = user.copyWith(name: 'Пётр');

        expect(updated.name, 'Пётр');
        expect(updated.id, user.id);
      });

      test('preserves unchanged fields', () {
        final user = testUserModel(
          name: 'Иван',
          gender: 'male',
          age: 30,
        );
        final updated = user.copyWith(age: 31);

        expect(updated.name, 'Иван');
        expect(updated.gender, 'male');
        expect(updated.age, 31);
      });
    });
  });

  group('UserMetadata', () {
    test('parses full JSON', () {
      final meta = UserMetadata.fromJson(testUserMetadataJson);

      expect(meta.goal, 'strength');
      expect(meta.experienceLevel, 'advanced');
      expect(meta.availableEquipment, ['barbell']);
    });

    test('parses empty JSON with null fields', () {
      final meta = UserMetadata.fromJson({});

      expect(meta.goal, isNull);
      expect(meta.experienceLevel, isNull);
      expect(meta.availableEquipment, isNull);
      expect(meta.defaultEquipmentPresetId, isNull);
    });

    test('round-trips through JSON', () {
      final original = UserMetadata.fromJson(testUserMetadataJson);
      final json = original.toJson();
      final restored = UserMetadata.fromJson(json);

      expect(restored.goal, original.goal);
      expect(restored.experienceLevel, original.experienceLevel);
      expect(restored.availableEquipment, original.availableEquipment);
    });
  });
}
