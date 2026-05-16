import 'package:mobile/features/auth/domain/user_model.dart';

final testUserModelJson = <String, dynamic>{
  'id': 'test-id-123',
  'deviceId': 'device-abc',
  'name': 'Иван',
  'gender': 'male',
  'weight': 75,
  'height': 180,
  'age': 30,
  'contraindications': ['knee_injury'],
  'createdAt': '2026-01-01T00:00:00.000Z',
  'metadata': {
    'goal': 'hypertrophy',
    'experienceLevel': 'intermediate',
    'availableEquipment': ['barbell', 'dumbbell'],
    'defaultEquipmentPresetId': 'preset-gym-full',
  },
};

final testUserModelMinimalJson = <String, dynamic>{
  'id': 'test-id-456',
  'deviceId': 'device-def',
  'createdAt': '2026-01-01T00:00:00.000Z',
};

final testUserMetadataJson = <String, dynamic>{
  'goal': 'strength',
  'experienceLevel': 'advanced',
  'availableEquipment': ['barbell'],
};

UserModel testUserModel({
  String? name,
  String? gender,
  int? age,
  int? weight,
  int? height,
  List<String>? contraindications,
  UserMetadata? metadata,
}) {
  return UserModel(
    id: 'test-id',
    deviceId: 'test-device',
    name: name,
    gender: gender,
    age: age,
    weight: weight,
    height: height,
    contraindications: contraindications,
    createdAt: '2026-01-01T00:00:00.000Z',
    metadata: metadata,
  );
}
