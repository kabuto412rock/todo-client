# Todo Client (Flutter)

This is a Flutter frontend app designed to work with the backend API from the repository:
https://github.com/kabuto412rock/todo-api

The app provides a simple authentication flow and a Todo list screen that reads data from the API. It uses a single API client (Dio) and Provider for state management.

## Features
- Login with username and password against the backend API (POST /auth/login)
- Persist JWT/token locally and keep the session across launches
- Fetch Todo list from the API (GET /todos)
- Simple UI with loading/error states and pull-to-refresh

Code highlights:
- Env and configuration: `lib/core/env.dart`
- API client: `lib/core/api_client.dart`
- Auth state and UI: `lib/features/auth/*`
- Todos model and UI: `lib/features/todos/*`
- App composition and routes: `lib/app.dart`, `lib/main.dart`

## Prerequisites
- Flutter SDK installed
- A running instance of the backend API (see the linked repo for setup)

## Environment configuration
This app reads its base API URL at compile time using Dart defines. No sensitive or host-specific values are committed to VCS.

- Where it is used: `Env.baseUrl` in `lib/core/env.dart`
- Options to provide the base URL:
	1) Inline define
		 - `flutter run --dart-define=BASE_URL=http://127.0.0.1:8081`
	2) From a file (Flutter 3.7+)
		 - Create `env_dev.json` next to `pubspec.yaml` with:
			 ```json
			 { "BASE_URL": "http://127.0.0.1:8081" }
			 ```
		 - Run: `flutter run --dart-define-from-file=env_dev.json`

VS Code users: see `.vscode/launch.json` for ready-made launch configurations that already pass `--dart-define-from-file=env_dev.json`.

Tips
- Do not commit real env files. Use `env.sample.json` as a template and keep `env*.json` out of VCS.
- For release builds, pass your production URL via `--dart-define` or a prod json file.

### Platform host tips
- Android emulator: the host machine is `http://10.0.2.2:<port>`
- iOS simulator: the host machine can be `http://127.0.0.1:<port>`
- Web/Windows/macOS/Linux desktop: typically `http://127.0.0.1:<port>` if the backend runs locally

Note: We purposely avoid bundling `.env` files; instead we compile in values via `--dart-define` (12-Factor friendly).

## How it connects to the backend
The app is built to match the endpoints from the linked backend repo.

- POST `/auth/login`
	- Body: `{ "username": string, "password": string }`
	- Response: `{ "token": string }`
	- Used by: `ApiClient.login(...)` and `AuthState.login(...)`

- GET `/todos`
	- Headers: `Authorization: Bearer <token>`
	- Response: either a list of todos or an object containing a `todos` array
	- Used by: `ApiClient.getTodoList(...)` and `TodoPage._fetchTodos(...)`

Todo model expected shape:
```json
{ "id": "string", "title": "string", "done": true|false }
```

## Run
Ensure the backend is running and reachable from your device/emulator, then run one of the following:

```bash
# Using inline define
flutter pub get
flutter run --dart-define=BASE_URL=http://127.0.0.1:8081

# Or using a local env file
flutter pub get
flutter run --dart-define-from-file=env_dev.json
```

On Windows you can also target the Windows desktop:

```bash
flutter run -d windows --dart-define-from-file=env_dev.json
```

## App flow
- On launch, the app loads any saved token and decides whether to show Login or Todos (`lib/app.dart`).
- Login screen lets you enter credentials; on success, token is saved and the app navigates to Todos.
- Todos screen fetches the list, shows loading/error states, supports pull-to-refresh, and allows basic local edits (UI-only for now).

## Troubleshooting
- 401/403 when fetching todos: ensure the token is present and valid; try logging in again.
- Cannot reach API from Android emulator: use `http://10.0.2.2:<port>` instead of `http://127.0.0.1:<port>`.
- Mixed content on Web (http vs https): if hosting the app over https, make sure the API is also https or configure proper CORS and security settings.
- Timeouts: verify the backend is running and the `BASE_URL` is correct.

## License
This project is for demonstration and integration with the referenced backend. See the backend repository for its own license and terms.

