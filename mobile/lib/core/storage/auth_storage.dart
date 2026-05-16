import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_storage.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnsupportedError('Must be overridden in ProviderScope');
}

@Riverpod(keepAlive: true)
AuthStorage authStorage(AuthStorageRef ref) {
  return AuthStorage(ref.watch(sharedPreferencesProvider));
}

class AuthStorage {
  final SharedPreferences _prefs;

  AuthStorage(this._prefs);

  static const String _accessTokenKey = 'access_token';
  static const String _deviceIdKey = 'device_id';

  String? get accessToken => _prefs.getString(_accessTokenKey);

  Future<void> setAccessToken(String token) async {
    await _prefs.setString(_accessTokenKey, token);
  }

  String? get deviceId => _prefs.getString(_deviceIdKey);

  Future<void> setDeviceId(String id) async {
    await _prefs.setString(_deviceIdKey, id);
  }

  bool get isAuthenticated => accessToken != null;

  Future<void> clear() async {
    await _prefs.remove(_accessTokenKey);
  }
}
