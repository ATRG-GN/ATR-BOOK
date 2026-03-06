import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// จัดเก็บ API key แบบปลอดภัยสำหรับ Android เท่านั้น
///
/// - Android: ใช้ EncryptedSharedPreferences ผ่าน flutter_secure_storage
/// - Web: ไม่อนุญาตให้จัดเก็บ API key ฝั่ง client
class ApiKeyVault {
  ApiKeyVault({FlutterSecureStorage? storage, TargetPlatform? platformOverride})
    : _storage = storage,
      _platformOverride = platformOverride;

  static const String _apiKeyName = 'atr_book_api_key';
  FlutterSecureStorage? _storage;
  final TargetPlatform? _platformOverride;

  bool get _canUseSecureStorage {
    if (kIsWeb) {
      return false;
    }

    return (_platformOverride ?? defaultTargetPlatform) == TargetPlatform.android;
  }

  FlutterSecureStorage get _secureStorage =>
      _storage ??= const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  Future<void> saveApiKey(String apiKey) async {
    if (!_canUseSecureStorage) {
      throw UnsupportedError(
        'รองรับการเก็บ API key เฉพาะ Android; แพลตฟอร์มอื่นให้เรียกผ่าน backend proxy + JWT แทน',
      );
    }

    await _secureStorage.write(key: _apiKeyName, value: apiKey);
  }

  Future<String?> readApiKey() async {
    if (!_canUseSecureStorage) {
      return null;
    }

    return _secureStorage.read(key: _apiKeyName);
  }

  Future<void> deleteApiKey() async {
    if (!_canUseSecureStorage) {
      return;
    }

    await _secureStorage.delete(key: _apiKeyName);
  }
}
