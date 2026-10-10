import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/services/reminder_scheduler.dart';

import '../support/fake_reminder_scheduler.dart';

void main() {
  test('notification ids are stable and non-negative', () {
    final scheduler = FakeReminderScheduler();
    expect(scheduler.notificationId('a'), scheduler.notificationId('a'));
    expect(scheduler.notificationId('a'), isNonNegative);
    expect(scheduler.notificationId('a'), isNot(scheduler.notificationId('b')));
  });

  test('a reminder in the past is a no-op that reports success', () async {
    // Uses the real scheduler on purpose: the past-time early return happens
    // before any platform channel is touched.
    final scheduler = ReminderScheduler(FlutterLocalNotificationsPlugin());
    final ok = await scheduler.scheduleReminder(
      reminderId: 'r1',
      title: 't',
      body: 'b',
      fireAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    expect(ok, isTrue);
  });
}
