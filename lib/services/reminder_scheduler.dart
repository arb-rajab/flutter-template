import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Schedules local, on-device notifications for a future time.
///
/// Call `tz.initializeTimeZones()` (package:timezone/data/latest_all.dart)
/// once at startup before scheduling anything.
class ReminderScheduler {
  ReminderScheduler(
    this._plugin, {
    this.channelId = 'reminders',
    this.channelName = 'Reminders',
    this.channelDescription = 'Reminders scheduled by the app',
  }) : _androidDetails = AndroidNotificationDetails(
         channelId,
         channelName,
         channelDescription: channelDescription,
         importance: Importance.high,
         priority: Priority.high,
       );

  final FlutterLocalNotificationsPlugin _plugin;
  final String channelId;
  final String channelName;
  final String channelDescription;
  final AndroidNotificationDetails _androidDetails;

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  /// Notification IDs are derived from the caller's own id string, so
  /// rescheduling or cancelling the same reminder is idempotent without a
  /// separate id-mapping table.
  int notificationId(String reminderId) => reminderId.hashCode & 0x7fffffff;

  /// Schedules a notification for [fireAt] and returns whether the user will
  /// actually see it: `false` only when the OS reported notifications as
  /// disabled (declined POST_NOTIFICATIONS). The notification is still
  /// scheduled in that case and Android silently suppresses its display, so
  /// callers use this to tell the user. Returns `true` when enabled, when the
  /// state is unknown (iOS), or when [fireAt] is already in the past.
  Future<bool> scheduleReminder({
    required String reminderId,
    required String title,
    required String body,
    required DateTime fireAt,
  }) async {
    if (fireAt.isBefore(DateTime.now())) {
      return true;
    }

    // Android 13+ shows no notifications until the user grants
    // POST_NOTIFICATIONS. Ask the first time there is something to show.
    // No-op on older Android, null (skipped) on iOS.
    final notificationsEnabled = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin.zonedSchedule(
      notificationId(reminderId),
      title,
      body,
      tz.TZDateTime.from(fireAt, tz.local),
      NotificationDetails(
        android: _androidDetails,
        iOS: const DarwinNotificationDetails(),
      ),
      // Inexact on purpose. Exact alarms need SCHEDULE_EXACT_ALARM, which
      // Android 14 no longer pre-grants (zonedSchedule throws
      // `exact_alarms_not_permitted` without it), or USE_EXACT_ALARM, which
      // Play reserves for alarm-clock/calendar apps. Delivery can be late by
      // up to about an hour. If you need exact timing, add the permission
      // and its prompt flow.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    return notificationsEnabled != false;
  }

  Future<void> cancelReminder(String reminderId) =>
      _plugin.cancel(notificationId(reminderId));
}
