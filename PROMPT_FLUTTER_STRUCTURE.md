## Purpose

Use this prompt file in **any Flutter project** to generate a consistent, maintainable **feature-first Clean Architecture** structure (Domain/Data/Presentation), with sensible defaults for DI, routing, state management, networking, and environment/config.

Copy everything below into your AI tool (Cursor/ChatGPT/etc.) and replace the placeholders.

---

## Prompt (copy/paste)

You are a senior Flutter engineer. I want you to **create or refactor** this Flutter app into a **feature-first Clean Architecture** structure.

### Constraints
- Use **Flutter stable** and **Dart stable**.
- Prefer **feature-first** folders under `lib/features/`.
- Each feature must have three layers:
  - `domain/`: entities, repository interfaces, domain exceptions (no Flutter imports)
  - `data/`: datasources (remote/local), DTOs/mappers (if needed), repository implementations
  - `presentation/`: pages/widgets + Cubit/BLoC used only by that feature
- Put cross-cutting code in:
  - `lib/core/` (networking, DI, theme, constants, navigation helpers, utils)
  - `lib/presentation/` (app shell, router, app-wide cubits)
  - `lib/shared/` (reusable widgets)
- Keep code **null-safe**, formatted, and lint-clean.
- Do not introduce placeholder comments that restate the code.

### What to build
- App flow: **Splash → Onboarding (first launch only) → Auth (login/register) → Home shell (bottom nav)**.
- Persist a local session (token + expiry + user JSON).
- Include:
  - Deep link handling (optional but preferred)
  - Connectivity guard (optional but preferred)
  - Version/update policy loaded from an asset JSON (example file: `assets/config/version_policy.json`)

### Required folder structure

Create this structure (add missing folders/files, refactor existing ones to match):

```text
lib/
  main.dart
  core/
    constants/
    di/
    navigation/
    network/
    telemetry/        # optional
    theme/
    utils/
  presentation/
    app.dart
    router/
    theme/
    connectivity/
    version/
  shared/
    widgets/
  features/
    <feature_name>/
      data/
        datasources/
        repositories/
        dtos/          # optional
        mappers/       # optional
      domain/
        entities/
        exceptions/    # optional
        repositories/
        usecases/      # optional
      presentation/
        pages/
        widgets/       # optional
        cubit/         # or bloc/
```

### File size (mandatory)
- Hand-written Dart files: **target ~300 lines**, **hard max 400 lines**.
- Split large pages into `presentation/widgets/<feature>_<part>.dart`.
- Split large routers into `app_router_<group>_routes.dart` + `go_app_redirect.dart`.
- Generated files (`app_localizations*.dart`, `*.g.dart`) are exempt.
- Full rules: **`PROJECT_FILE_SIZE_RULES.md`**.

### Naming + conventions
- Feature name is **snake_case** folder: `auth`, `home`, `onboarding`, `splash`, `notifications`, `update`.
- Files: `lower_snake_case.dart`
- Cubits/Blocs: `<Thing>Cubit`, `<Thing>State`, `<Thing>Event` (if BLoC)
- Repository interfaces go in `domain/repositories/`.
- Repository implementations go in `data/repositories/` and end with `_impl.dart`.
- Datasources in `data/datasources/` (split into `*_remote_datasource.dart` and `*_local_datasource.dart`).

### Dependencies (default set)
Use:
- `flutter_bloc` for state
- `dio` for networking
- `shared_preferences` for non-secret local storage
- `go_router` for routing (with a shell for bottom navigation)
- `cached_network_image` for remote avatar/image

### Android/iOS/web safety
- Keep platform-specific code inside plugins only; app code should remain platform-agnostic.
- Avoid breaking changes; if Flutter introduces a deprecation (example: `cacheExtent`), migrate to the recommended API (`scrollCacheExtent` with `ScrollCacheExtent.pixels(...)`).

### What you must deliver
1. Create/refactor the code to match the structure above.
2. Ensure `flutter analyze` returns **No issues found**.
3. Ensure `flutter pub get` succeeds.
4. Provide a short “how to add a new feature” guide in `lib/features/README.md`.

### Project-specific placeholders (fill these before coding)
- Application name: <APP_NAME>
- Android applicationId: <ANDROID_APP_ID>
- iOS bundle id: <IOS_BUNDLE_ID>
- Base API URL (if any): <BASE_URL>
- Demo credentials (optional): <DEMO_EMAIL> / <DEMO_PASSWORD>

### Extra: generate a feature template
Also create a minimal “feature template” example called `sample_feature` showing:
- one `Entity`
- one `Repository` interface in domain
- one repository implementation in data
- one cubit + page in presentation

Now implement it.

