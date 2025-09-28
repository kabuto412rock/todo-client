class Env {
  /// Base API URL injected at compile-time via `--dart-define=BASE_URL=...`.
  ///
  /// Example:
  ///   flutter run --dart-define=BASE_URL=http://192.168.1.188:8081
  ///
  /// If not provided, falls back to the value below. Keep this default
  /// development-only and safe to commit.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://127.0.0.1:8081',
  );
}
