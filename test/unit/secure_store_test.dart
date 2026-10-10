import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/services/secure_store.dart';

import '../support/fake_secure_storage_platform.dart';

void main() {
  late FakeSecureStoragePlatform platform;
  late SecureStore store;

  setUp(() {
    platform = FakeSecureStoragePlatform();
    FlutterSecureStoragePlatform.instance = platform;
    store = SecureStore(const FlutterSecureStorage());
  });

  test('round-trips a token', () async {
    expect(await store.readToken(), isNull);
    await store.writeToken('abc');
    expect(await store.readToken(), 'abc');
  });

  test('clearToken removes it', () async {
    await store.writeToken('abc');
    await store.clearToken();
    expect(await store.readToken(), isNull);
  });
}
