# Notes for Claude Code sessions on this repo

## Flutter SDK
The SDK may not be preinstalled in a fresh container. Check `which flutter` first; if missing:
`git clone --depth 1 -b stable https://github.com/flutter/flutter.git /opt/flutter` and add `/opt/flutter/bin`
to `PATH`. The first `flutter pub get` downloads the Dart SDK (a few minutes). Do not reclone if it exists.

## `flutter analyze` must report "No issues found!"
Its exit code is nonzero for info-level lints too, and CI fails on that. Do not leave any lint unresolved. For a
lint that genuinely does not apply, use a `// ignore: lint_name` comment on the line immediately above the flagged
line (a multi-line comment before it does not suppress it). Example: `use_null_aware_elements` fires on a
conditionally included map entry (`if (x != null) 'k': x`), and its suggested `?'k': x` rewrite is wrong there
(it produces a type error), so `lib/api/api_client.dart` ignores it.

## Output is verbose: tail it
`flutter pub get`, `flutter test` and `flutter analyze` print a root-user banner and tool chatter first. Pipe
through `tail -N`; the useful signal is at the end.

## `dart format`
Run `dart format lib test integration_test` once near the end of a batch of edits (CI runs it with
`--set-exit-if-changed`). It is fast and idempotent.

## Tests that touch `ReminderScheduler`
A real `FlutterLocalNotificationsPlugin` throws `LateInitializationError` in plain `flutter_test` (its platform
channel is never registered). Use `test/support/fake_reminder_scheduler.dart`. Same for secure storage: install
`FakeSecureStoragePlatform` (see `test/support/`).

## Android native work cannot always run in a sandbox
`flutter build apk` and the emulator need `dl.google.com` and `/dev/kvm`. A quick check:
`curl -sS -o /dev/null -w '%{http_code}\n' https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/maven-metadata.xml; ls /dev/kvm`.
If it is blocked (proxy 403, no KVM), do not retry; get native evidence from `.github/workflows/android-native.yml`
(push, then read the job logs once the job has ended; logs 404 while it is running). A push alone does not trigger
it: it runs on `pull_request` paths or `workflow_dispatch`. The Gradle build takes about 4 minutes and the emulator
run about 10.

## Checks that must outlive the app process
`flutter test` force-stops the app when it finishes, which cancels its alarms and blocks BOOT_COMPLETED. A
reboot/process-death check therefore cannot be a `flutter test`: use the pattern in
`.github/scripts/reboot-reminder-check.sh` (separate probe APK from `integration_test/reboot_probe_main.dart`,
launched with adb, asserted from the shell via `dumpsys alarm` / `dumpsys notification`). Give probe entry points
no `_test.dart` suffix so `flutter test integration_test` skips them.

## Permission prompts in emulator tests
Tests that make the app request a runtime permission rely on `.github/scripts/allow-permission-dialogs.sh` tapping
"Allow". Its `tapped Allow at x,y` log line shows the prompt appeared.

## Project memory
Durable context goes in `docs/project-memory/`.
