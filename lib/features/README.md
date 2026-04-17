# Features (feature-first layout)

Add a new product area as a folder under `lib/features/<feature_name>/`:

- **`domain/`** — entities, repository interfaces, feature-specific exceptions (no Flutter imports).
- **`data/`** — datasources, repository implementations, mappers.
- **`presentation/`** — pages, widgets, Cubits/BLoCs for that feature only.

Cross-cutting pieces stay outside:

- **`lib/core/`** — theme, DI, networking, constants, validators.
- **`lib/presentation/`** — app shell, global router, theme/connectivity/version UI if shared.
- **`lib/shared/`** — widgets or utilities reused by multiple features.

Wire new repositories through `lib/core/di/app_dependencies.dart` and expose BlocProviders in `lib/presentation/app.dart` when needed globally.
