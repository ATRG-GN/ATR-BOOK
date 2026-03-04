import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// จัดเก็บ API key แบบปลอดภัยสำหรับ Android เท่านั้น
///
/// - Android: ใช้ EncryptedSharedPreferences ผ่าน flutter_secure_storage
/// - Web: ไม่อนุญาตให้จัดเก็บ API key ฝั่ง client
class ApiKeyVault {
  ApiKeyVault({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  static const String _apiKeyName = 'atr_book_api_key';
  final FlutterSecureStorage _storage;

  Future<void> saveApiKey(String apiKey) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web ต้องไม่เก็บ API key ใน client ให้เรียกผ่าน backend proxy + JWT แทน',
      );
    }

    await _storage.write(key: _apiKeyName, value: apiKey);
  }

  Future<String?> readApiKey() async {
    if (kIsWeb) {
      return null;
    }

    return _storage.read(key: _apiKeyName);
  }

  Future<void> deleteApiKey() async {
    if (kIsWeb) {
      return;
    }

    await _storage.delete(key: _apiKeyName);
  }
}
