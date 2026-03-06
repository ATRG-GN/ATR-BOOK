import 'package:atr_book/security/api_key_vault.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiKeyVault', () {
    test('non-Android: saveApiKey throws UnsupportedError', () async {
      final vault = ApiKeyVault(platformOverride: TargetPlatform.iOS);

      expect(
        () => vault.saveApiKey('secret'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('non-Android: read/delete are no-op safe', () async {
      final vault = ApiKeyVault(platformOverride: TargetPlatform.macOS);

      expect(await vault.readApiKey(), isNull);
      await vault.deleteApiKey();
    });
  });
}
