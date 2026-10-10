/// Build-time configuration, read from `--dart-define` values.
///
/// Override for local development, e.g. against an Android emulator:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
///
/// Only put public, non-secret values here: anything compiled into the app
/// can be extracted from it.
class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
}
