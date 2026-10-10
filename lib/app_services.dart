import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api/api_client.dart';
import 'config/env.dart';
import 'services/reminder_scheduler.dart';
import 'services/secure_store.dart';

/// Bundles the app's service-layer singletons so they are built once in
/// `main()` and handed down via `Provider`. Add new services here.
class AppServices {
  AppServices({
    required this.api,
    required this.secureStore,
    required this.reminders,
  });

  static Future<AppServices> bootstrap() async {
    final reminders = ReminderScheduler(FlutterLocalNotificationsPlugin());
    await reminders.initialize();

    final secureStore = SecureStore();
    final api = ApiClient(baseUrl: Env.apiBaseUrl);
    api.bearerToken = await secureStore.readToken();

    return AppServices(
      api: api,
      secureStore: secureStore,
      reminders: reminders,
    );
  }

  final ApiClient api;
  final SecureStore secureStore;
  final ReminderScheduler reminders;
}
