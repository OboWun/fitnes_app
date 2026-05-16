import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/auth_storage.dart';
import 'auth_api.dart';
import '../domain/user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(
    ref.watch(authApiProvider),
    ref.watch(authStorageProvider),
  );
}

class AuthRepository {
  final AuthApi _api;
  final AuthStorage _storage;

  AuthRepository(this._api, this._storage);

  Future<String> getDeviceId() async {
    final storedId = _storage.deviceId;
    if (storedId != null) return storedId;

    final deviceInfo = DeviceInfoPlugin();
    String deviceId;

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      deviceId = android.id;
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      deviceId = ios.identifierForVendor ??
          DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await _storage.setDeviceId(deviceId);
    return deviceId;
  }

  Future<({UserModel user, String accessToken})> authenticate() async {
    final deviceId = await getDeviceId();
    final response = await _api.authenticateDevice(deviceId);

    final accessToken = response['accessToken'] as String;
    final userJson = response['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    await _storage.setAccessToken(accessToken);

    return (user: user, accessToken: accessToken);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? gender,
    int? age,
    int? weight,
    int? height,
    List<String>? contraindications,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (gender != null) data['gender'] = gender;
    if (age != null) data['age'] = age;
    if (weight != null) data['weight'] = weight;
    if (height != null) data['height'] = height;
    if (contraindications != null) data['contraindications'] = contraindications;

    final response = await _api.updateProfile(data);
    return UserModel.fromJson(response);
  }

  Future<List<Map<String, dynamic>>> getContraindications() async {
    return _api.getContraindications();
  }

  bool get isAuthenticated => _storage.isAuthenticated;

  Future<void> clearAuth() async {
    await _storage.clear();
  }
}
