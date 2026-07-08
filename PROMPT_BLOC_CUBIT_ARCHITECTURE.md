## Purpose

Use this prompt file when you are creating a **new feature** and want the AI to generate the **BLoC or Cubit** scaffolding correctly, following **feature-first clean architecture**.

It is designed to be used together with `PROMPT_FLUTTER_STRUCTURE.md`.

---

## Prompt (copy/paste)

You are a senior Flutter engineer using **flutter_bloc**. I already use a **feature-first clean architecture**:

- `lib/features/<feature>/domain` (no Flutter imports)
- `lib/features/<feature>/data`
- `lib/features/<feature>/presentation`

I want you to create a new feature named:
- Feature folder: `<FEATURE_NAME>` (snake_case)
- Feature goal: `<FEATURE_GOAL>`

### Decide Cubit vs BLoC (must follow these rules)

Use **Cubit** when:
- The UI has simple state transitions (loading/success/failure)
- No complex event fan-out
- No need for event replay, analytics per event, or cancellation per event

Use **BLoC** when:
- Many UI actions trigger different flows (submit, retry, refresh, paginate, filter, logout, etc.)
- You need explicit events for analytics / logging
- You need more predictable state transitions with event separation

If unsure, default to **Cubit**.

### State model (standard)

Use a single state object with:
- `loadState`: `initial | loading | success | failure`
- `error`: `String?`
- feature-specific data fields (nullable until success)

Prefer an enum like:
- `enum <Thing>Load { initial, loading, success, failure }`

### Required deliverables

Create the full vertical slice:
1. **Domain**
   - `Entity` (pure Dart)
   - `Repository` interface in `domain/repositories/`
   - optional domain exceptions in `domain/exceptions/`
2. **Data**
   - `RemoteDataSource` (Dio / ApiClient)
   - optional `LocalDataSource` (SharedPreferences)
   - `RepositoryImpl` that maps data → domain entity
3. **Presentation**
   - **Cubit or BLoC** (as per rules above)
   - `Page` that renders loading/success/error and triggers actions

Also:
- Add DI wiring in `lib/core/di/app_dependencies.dart`
- Add a route in `lib/presentation/router/` (prefer `go_router`)
- Ensure `flutter analyze` is clean

---

## Templates you must follow

### 1) Domain repository interface

Create:
- `lib/features/<feature>/domain/repositories/<feature>_repository.dart`

It must look like:

```dart
abstract interface class <Feature>Repository {
  Future<<Entity>> fetch();
}
```

### 2) Data source (remote)

Create:
- `lib/features/<feature>/data/datasources/<feature>_remote_datasource.dart`

Rules:
- Keep HTTP + DTO parsing here
- Throw a typed exception (or `Exception`) with a user-safe message

### 3) Repository implementation

Create:
- `lib/features/<feature>/data/repositories/<feature>_repository_impl.dart`

Rules:
- Depends on data sources
- Maps DTO → `Entity`
- No Flutter imports

---

## Cubit blueprint (preferred default)

Create:
- `lib/features/<feature>/presentation/cubit/<feature>_cubit.dart`
- `lib/features/<feature>/presentation/cubit/<feature>_state.dart`

Required API:
- `Future<void> load()` (initial fetch)
- `Future<void> refresh()` (optional, can call `load`)

State must include:
- `loadState`
- `error`
- `data` (entity or list)

UI page:
- `lib/features/<feature>/presentation/pages/<feature>_page.dart`
- Use `BlocProvider` + `BlocBuilder`
- On first build call `context.read<<Feature>Cubit>().load()` (use `initState` in a StatefulWidget, or a post-frame callback)

---

## BLoC blueprint (use when needed)

Create:
- `lib/features/<feature>/presentation/bloc/<feature>_bloc.dart`
- `lib/features/<feature>/presentation/bloc/<feature>_event.dart`
- `lib/features/<feature>/presentation/bloc/<feature>_state.dart`

Events (minimum):
- `<Feature>Started`
- `<Feature>Refreshed`
- `<Feature>Retried`

State must include:
- `loadState`
- `error`
- `data`

---

## “Create a new feature” example prompt (you fill placeholders)

Feature folder: `posts`
Feature goal: “Fetch a post list from `/posts` and display it”
Decision: Cubit

Now implement the feature and wire it into the router + DI.

