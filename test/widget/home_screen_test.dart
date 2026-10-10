import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/api/api_client.dart';
import 'package:starter_app/app_services.dart';
import 'package:starter_app/screens/home_screen.dart';
import 'package:starter_app/services/secure_store.dart';

import '../support/fake_reminder_scheduler.dart';

void main() {
  testWidgets('home screen shows the configured API base URL', (tester) async {
    final services = AppServices(
      api: ApiClient(baseUrl: 'https://api.test'),
      secureStore: SecureStore(),
      reminders: FakeReminderScheduler(),
    );

    await tester.pumpWidget(
      Provider<AppServices>.value(
        value: services,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('API: https://api.test'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });
}
