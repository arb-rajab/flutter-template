import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:starter_app/main.dart' as app;

/// Native startup smoke test. It uses no fakes: it goes through the real
/// platform plugins, so it only means anything on a device or emulator (see
/// `.github/workflows/android-native.yml`). Widget tests pump the app widget
/// directly and never run `main()`, so they can't catch a native plugin that
/// fails at startup.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real main() starts the app', (tester) async {
    await app.main();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
