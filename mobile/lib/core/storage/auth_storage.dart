import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage(ref.watch(sharedPreferencesProvider));
});

class AuthStorage {
  final SharedPreferences _prefs;

  AuthStorage(this._prefs);

  String? get accessToken => _prefs.getString(AppConstants.accessTokenKey);

  Future<void> setAccessToken(String token) async {
    await _prefs.setString(AppConstants.accessTokenKey, token);
  }

  String? get deviceId => _prefs.getString(AppConstants.deviceIdKey);

  Future<void> setDeviceId(String id) async {
    await _prefs.setString(AppConstants.deviceIdKey, id);
  }

  bool get isAuthenticated => accessToken != null;

  Future<void> clear() async {
    await _prefs.remove(AppConstants.accessTokenKey);
  }
}
