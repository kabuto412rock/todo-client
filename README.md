# todo_client

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment configuration (no IPs in VCS)

This project reads environment values at compile time via Dart defines to avoid committing sensitive or host-specific values.

- Code: see `lib/core/env.dart` which uses `String.fromEnvironment('BASE_URL')`.
- Quick run:
	- Inline define:
		- `flutter run --dart-define=BASE_URL=http://127.0.0.1:8081`
	- From file (Flutter 3.7+):
		- Create `env_dev.json` next to `pubspec.yaml` with:
			```json
			{ "BASE_URL": "http://127.0.0.1:8081" }
			```
		- Run: `flutter run --dart-define-from-file=env_dev.json`

VS Code: see `.vscode/launch.json` for ready-made launch configs.

Tips:
- Do not commit real env files. `env*.json` are ignored by `.gitignore`. Use the provided `env.sample.json` as a template.
- For release builds, pass your production URL via `--dart-define`.

### Platform host tips
- Android emulator: host machine is `http://10.0.2.2:<port>`
- iOS simulator: host machine can be `http://127.0.0.1:<port>`
- Web/Windows/macOS/Linux desktop: typically `http://127.0.0.1:<port>` if backend runs locally

Note: `flutter_dotenv` is not required here because we load config at compile time using `--dart-define` (12-Factor friendly) instead of bundling a `.env` file into the app.

