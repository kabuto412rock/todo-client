## AI Coding Assistant Guide for `todo_client`

Concise, project-specific conventions so an AI agent can contribute productively. Keep responses action‑oriented and align with these patterns.

### 1. Purpose & Scope

Flutter cross‑platform (mobile/web/desktop) TODO client with simple auth (token) and future todo CRUD. Current focus: authentication flow + scaffold for todos. State handled with Provider (`ChangeNotifier`). Networking via a singleton `ApiClient` wrapping `dio`.

### 2. High-Level Architecture

- `lib/main.dart`: App entry; provides a single global `AuthState` via `ChangeNotifierProvider`.
- `lib/app.dart`: Bootstraps by asynchronously loading stored auth token before showing main routes. Chooses initial route (`/login` or `/todos`) based on `AuthState.isAuthed`.
- `lib/core/`: Cross‑cutting utilities.
  - `api_client.dart`: Singleton `ApiClient` exposing configured `Dio` instance (JSON headers, base URL from `Env.baseUrl`, 10s timeouts). Always reuse this (do NOT create new `Dio`).
  - `env.dart`: Hardcoded `baseUrl` (currently `https://localhost:8081`). If adding environments, centralize here.
- `lib/features/auth/`: Auth UI + state.
  - `auth_state.dart`: Holds token, loading, error. Persists token with `SharedPreferences` under key `auth_token`. Exposes `login`, `logout`, `loadToken`.
  - `login_page.dart`: Simple form; on success navigate to `/todos` using `pushReplacementNamed`.
- `lib/features/todos/`: Placeholder for todo domain (`todo_model.dart`, `todo_page.dart`). Future expansion: list, CRUD, optimistic updates.

### 3. State & Reactivity Conventions

- Use `ChangeNotifier` + `Provider` for now. Name pattern: `<Domain>State` inside `features/<domain>/`.
- After mutating internal state, always `notifyListeners()`. Keep network+mutation logic on the state class (not in widgets).
- Expose derived booleans like `isAuthed`, `loading` instead of querying raw fields in widgets.

### 4. Networking Pattern

- Obtain client via `ApiClient().dio` (singleton). Add per‑request headers (e.g., auth) via interceptors or manual copy—prefer adding an interceptor helper if token usage becomes common.
- All endpoints currently relative to `Env.baseUrl`.
- Decode response: some endpoints may return raw JSON string; pattern: `final data = resp.data is Map ? resp.data : jsonDecode(resp.data);` (see `login`). Reuse this when unsure of dio's transformer output for consistency.

### 5. Auth Handling

- Token persisted with key `auth_token` (string). Treat empty string as unauthenticated.
- On app start: `AuthState.loadToken()` invoked post first frame in `MyApp.initState` to avoid blocking first build.
- Logout: remove key then navigate to `/login` replacing current stack.
- When adding authenticated API calls, read token from `AuthState.token`; if null, redirect to login (UI) rather than throwing deep errors.

### 6. Routing

- Centralized in `MaterialApp.routes` inside `app.dart`. Keep route names short and leading slash (e.g., `/todos`). When adding new feature pages, register here; avoid inline `MaterialPageRoute` unless passing complex arguments.

### 7. Feature Module Structure (Follow This)

For each new domain feature directory (e.g., `features/todos/`):

- `<entity>_model.dart` for pure data objects (add `toJson`, `copyWith` when needed).
- `<entity>_state.dart` for state + async operations.
- `<entity>_page.dart` (or more granular widgets) for UI screens.
- Optionally `widgets/` subfolder for reusable components within that feature.

### 8. Data Models

- Current models are simple immutable classes with final fields + `fromJson` factory. When expanding, prefer adding:
  - `toJson()` returning `Map<String,dynamic>`
  - `copyWith({ ... })` for selective mutation
  - Null safety: keep required non-null fields as `required` named params.

### 9. Error & Loading UX

- Use boolean flags on state classes (`loading`, `error`) consumed by UI to toggle progress indicators and error text (pattern in `login_page.dart`).
- Do not throw from UI event handlers; surface user‑facing message via state `error` string.

### 10. Local Persistence

- Only `SharedPreferences` currently. Wrap new persisted values behind state class methods instead of calling `SharedPreferences` in widgets.

### 11. Testing Expectations

- Placeholder `test/widget_test.dart` exists (Flutter default). When adding logic to state classes, create unit tests under `test/` mirroring feature path, e.g. `test/features/auth/auth_state_test.dart` verifying: login success path (mock dio), failure sets `error`, logout clears token.

### 12. Build & Run Workflows (Typical)

Common commands (run from project root):

- `flutter pub get` (fetch deps)
- `flutter run -d chrome` or `flutter run -d windows` / `-d ios`.
- `flutter test` (execute tests)
  Keep instructions concise; do not introduce custom scripts unless they exist.

### 13. Adding Todo CRUD (Guidance)

- Create `todo_state.dart` with list management: fields `List<Todo> items`, `bool loading`, `String? error`.
- Fetch with `ApiClient().dio.get('/todos', options: Options(headers: {'Authorization': 'Bearer <token>'}))` once token present.
- Provide mutation helpers: `addTodo`, `toggleTodo`, `removeTodo` with optimistic UI then server sync.

### 14. Code Style & Practices

- Favor const constructors & widgets where possible.
- Keep widget build methods lean; extract sub-widgets when exceeding ~60 lines.
- Avoid global singletons except `ApiClient` & top-level `ChangeNotifierProviders` in `main.dart`.

### 15. Safe Assumptions for AI

- If an API call requires auth and token absent, early return + set `error = 'Not authenticated'` then notify.
- When adding interceptors or new cross-cutting code, place in `core/` (e.g., `core/dio_interceptors.dart`).
- Keep new feature directories under `features/` (never at root of `lib/`).

### 16. What NOT to Do

- Do not instantiate `Dio` directly in features.
- Do not access `SharedPreferences` from widgets.
- Do not hardcode additional base URLs inside feature code.
- Do not navigate with raw `Navigator.push` for primary routes if a named route exists.

### 17. Incremental Improvements (Encouraged)

- Add `copyWith` & `toJson` to `Todo` when extending.
- Introduce lightweight caching for todos (in‑memory) before adding persistence.
- Consider extracting an `AuthInterceptor` once multiple authenticated endpoints exist.

---

If something seems ambiguous (e.g., how to shape future todo endpoints), propose a minimal approach consistent with existing patterns, then proceed unless explicitly redirected.
