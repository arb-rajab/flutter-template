import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:starter_app/services/reminder_scheduler.dart';

/// Tests must not call through to a real `FlutterLocalNotificationsPlugin`:
/// its platform channel is never registered in a plain `flutter_test`
/// environment, so `.cancel()` / `.zonedSchedule()` throw
/// `LateInitializationError`. Subclass the scheduler and override the methods
/// under test instead.
class FakeReminderScheduler extends ReminderScheduler {
  FakeReminderScheduler() : super(FlutterLocalNotificationsPlugin());

  final scheduledIds = <String>[];
  final cancelledIds = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> scheduleReminder({
    required String reminderId,
    required String title,
    required String body,
    required DateTime fireAt,
  }) async {
    scheduledIds.add(reminderId);
    return true;
  }

  @override
  Future<void> cancelReminder(String reminderId) async {
    cancelledIds.add(reminderId);
  }
}
