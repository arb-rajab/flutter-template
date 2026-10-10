import 'package:flutter/material.dart';
import 'package:starter_app/app_services.dart';
import 'package:timezone/data/latest_all.dart' as tz;

/// App entry point for `.github/scripts/reboot-reminder-check.sh`: does a
/// scheduled reminder survive a device reboot?
///
/// This is not a `flutter test` file (no `_test.dart` suffix, so
/// `flutter test integration_test` skips it). A Dart test can't span a
/// reboot, and `flutter test` force-stops the app when it finishes, which
/// cancels the app's alarms and blocks BOOT_COMPLETED until the next launch.
/// Instead, CI builds this file as its own debug APK
/// (`flutter build apk --debug -t integration_test/reboot_probe_main.dart`),
/// launches it once with adb and reboots, then checks AlarmManager and the
/// notification shade from the shell without reopening the app.
const _dueIn = Duration(minutes: 5);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('reboot probe'))),
    ),
  );

  try {
    final services = await AppServices.bootstrap();
    final fireAt = DateTime.now().add(_dueIn);
    // Waits for the POST_NOTIFICATIONS prompt, which the script's
    // allow-permission-dialogs.sh answers.
    await services.reminders.scheduleReminder(
      reminderId: 'reminder-reboot-e2e',
      title: 'Reboot probe reminder',
      body: 'Scheduled before a reboot',
      fireAt: fireAt,
    );
    // The script greps logcat for this exact line.
    debugPrint(
      'REBOOT_PROBE scheduled fireAtMs=${fireAt.millisecondsSinceEpoch}',
    );
  } catch (e) {
    debugPrint('REBOOT_PROBE error: $e');
  }
}
