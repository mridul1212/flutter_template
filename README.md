# Flutter Template (Clean Architecture + BLoC / Cubit)

Boilerplate app with **splash → onboarding (first launch) → auth → home**, **local session cache** (token + expiry + user JSON), and a **5-tab shell** with a profile screen. Code is organized **by feature** under `lib/features/`. State uses **`flutter_bloc`**: **`AuthBloc`** for auth flows, **`AppRouterCubit`** for high-level navigation, plus small **Cubits** per feature (onboarding pager, home tabs, dashboard demo).

---

## What this project does

| Area | Behavior |
|------|----------|
| **Splash** | Animated logo, then decides the next screen. |
| **Onboarding** | Shown once until completed or skipped; persists a flag in `SharedPreferences`. |
| **Login / Register** | Form **validation**; email login uses a **dummy** backend rule; Google / phone are **stubs** that still persist a session like a real sign-in. |
| **Session** | After success, a **token**, **expiry**, and **user** profile JSON are stored locally. On next launch, if the token is still valid, the app opens **Home**. |
| **Home** | **NavigationBar** + **`IndexedStack`**: five sections; the last is **Profile** (dummy stats + network avatar via `cached_network_image`). |

Demo credentials are defined in `lib/core/constants/app_constants.dart` (default: `demo@app.com` / `password1`).

---

## Quick start

```bash
flutter pub get
flutter run
```

To **see onboarding again**, clear app data / uninstall, or remove the keys written by `AuthLocalDataSource` (see `AppConstants` for key names).

---

## Folder structure (feature-first)

Product code lives under **`lib/features/<feature>/`** with small clean layers inside each feature:

```
lib/features/<feature>/
  domain/         # Entities, repository interfaces, feature exceptions (no Flutter)
  data/           # Datasources + repository implementations
  presentation/   # Pages, widgets, Cubits/BLoCs for that feature only
```

Cross-cutting code stays outside features:

```
lib/
  core/           # Theme, networking (Dio), DI, constants, validators
  presentation/   # App shell: MaterialApp, global router, theme/connectivity/version
  shared/         # Reused widgets (e.g. AppTextField)
  features/       # Auth, home, onboarding, splash, posts API demo, app update policy
```

Dependency construction lives in `lib/core/di/app_dependencies.dart` and is created in `main.dart`. See `lib/features/README.md` for how to add a new feature folder.

---

## Main files to know

| File | Role |
|------|------|
| `lib/main.dart` | `WidgetsFlutterBinding.ensureInitialized()`, builds `AppDependencies`, runs `AppBootstrap`. |
| `lib/presentation/app.dart` | `MultiBlocProvider` + `MaterialApp` + root `BlocBuilder` switching on `AppDestination`. |
| `lib/presentation/router/app_router_cubit.dart` | Splash resolution, onboarding completion, login/register/home routing, logout. |
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | Login/register/social stub events → repository → success/error. |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Contract your “real” auth will implement. |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | **Replace** dummy delays and rules with API calls. |
| `lib/features/auth/data/datasources/auth_local_datasource.dart` | Local persistence keys and read/write helpers. |

---

## Customization (UI & product)

### Theme and global styles

Edit `lib/core/theme/app_theme.dart`. `AppBootstrap` in `lib/presentation/app.dart` applies `AppTheme.light()`.

### Splash animation and branding

- UI: `lib/features/splash/presentation/pages/splash_page.dart` (animation, logo widget).
- Optional: add an `assets/` folder (e.g. `assets/images/`), list paths under `pubspec.yaml` → `flutter: assets:`, then use `Image.asset` in the splash widget.

### Onboarding copy and number of pages

- Slides live in `lib/features/onboarding/presentation/pages/onboarding_page.dart` (`_pages` list).
- Change length → `OnboardingCubit(pageCount: …)` must match the number of slides.

### Login / register copy and validation rules

- Validators: `lib/core/utils/validators.dart`.
- Forms: `lib/features/auth/presentation/pages/login_page.dart`, `register_page.dart`.
- Reusable field: `lib/shared/widgets/app_text_field.dart`.

### Home tabs and profile

- Tabs and placeholders: `lib/features/home/presentation/pages/home_shell.dart`.
- Tab index state: `lib/features/home/presentation/cubit/home_nav_cubit.dart`.
- Replace `_PlaceholderTab` children with your real screens; keep **`IndexedStack`** if you want to preserve each tab’s state without rebuilding everything.

### Demo credentials hint on screen

Change `AppConstants` in `lib/core/constants/app_constants.dart` and the hint text in `login_page.dart` if you still show dev-only copy (remove before production).

---

## Adding live data (recommended path)

Keep **the same `AuthRepository` interface** in `features/auth/domain/` so UI and `AuthBloc` stay stable. Swap **implementation** in `features/auth/data/` to call your backend.

### 1. Add networking (example: `dio` or `http`)

In `pubspec.yaml`, add your HTTP client package and any JSON tooling (`json_serializable`, etc.) if you use code generation.

### 2. Create a remote data source

Example (new file pattern):

- `lib/features/auth/data/datasources/auth_remote_datasource.dart`  
  - Methods: `Future<AuthResponseDto> login(String email, String password)`, etc.  
  - Maps HTTP status codes to **`AuthException`** messages the UI can show.

Keep **DTOs** (API shape) in `data/`; map them to **`UserEntity`** in the repository or a small mapper.

### 3. Extend or replace `AuthRepositoryImpl`

Current file: `lib/features/auth/data/repositories/auth_repository_impl.dart`.

- Inject **`AuthRemoteDataSource`** (and keep **`AuthLocalDataSource`** for caching).
- On successful login/register from API:
  - Save the **real** access/refresh tokens (prefer **`flutter_secure_storage`** for secrets instead of plain `SharedPreferences` in production).
  - Persist **expiry** if the API returns `expires_in`, or decode JWT `exp` if you use JWTs.
  - Map response to `UserEntity` and call `persistSession` (or rename methods to match your model).

### 4. Point dependency injection at the new implementation

In `lib/core/di/app_dependencies.dart`, construct your new repository implementation and pass it into `BlocProvider` creators in `app.dart` the same way as today (only the constructor arguments change).

### 5. Align `AuthBloc` events with real flows (optional)

`AuthBloc` already emits **loading / success / error**. For refresh tokens, biometric login, or OTP steps, add new **`AuthEvent`** types and handle them in `auth_bloc.dart` without changing the UI contract more than necessary.

### 6. Secure and production-ready checklist

- [ ] Move secrets off `SharedPreferences` to **secure storage**.
- [ ] Remove demo password hints from the UI.
- [ ] Add **certificate pinning** / TLS policies if required by your org.
- [ ] Centralize **base URL** via `--dart-define` or `flutter_dotenv`, not hard-coded strings.
- [ ] Map **401** from API to logout + route to login (`AppRouterCubit` + clear cache).

---

## Session and cache behavior (today)

- **Onboarding flag**: `AuthLocalDataSource` / keys in `AppConstants.onboardingKey`.
- **Session**: token string + expiry milliseconds + user JSON (`AppConstants.tokenKey`, etc.).
- **Validity**: `AuthLocalDataSource.isTokenValid()` compares expiry to `DateTime.now()`.
- **Logout**: `AppRouterCubit.logout()` → repository clears persisted session.

When you add a real backend, you may still use the same keys or rename them in **one place** (`AppConstants`) and run a one-time migration if users already have the app installed.

---

## Tests

```bash
flutter test
```

Widget tests that need `SharedPreferences` should call `SharedPreferences.setMockInitialValues({})` before `AppDependencies.create()` (see `test/widget_test.dart`).

---

## Further reading

- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [cached_network_image](https://pub.dev/packages/cached_network_image)

If you want this doc split into `docs/architecture.md` and a shorter root README, say so and it can be reorganized.
# flutter_template
