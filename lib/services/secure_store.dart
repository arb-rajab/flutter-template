import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores secrets (auth tokens and the like) in the platform keystore:
/// Keychain on iOS, EncryptedSharedPreferences on Android. Keep anything
/// non-sensitive in `shared_preferences` instead.
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
