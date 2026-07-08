# Puja Bandhu — SRS Implementation Status

> Mobile app aligned with **Puja Bandhu SRS v1.0** (Flutter + mock data for v1 demo).

## Stack

| Layer | Technology |
|-------|------------|
| State | `flutter_bloc` (Cubit / BLoC) |
| Routing | `go_router` |
| Data (demo) | `assets/mock/*.json` + `SharedPreferences` |
| Maps | Offline `flutter_map`-style painter (OSM-ready) |
| Auth | Google Sign-In stub (SRS §3) |

## Module Status

| SRS Module | Status | Route / Entry |
|------------|--------|---------------|
| Google Sign-In + profile completion | ✅ Mock | `/login` → `/profile-complete` |
| Panjika (Ponjika) | ✅ Partial | `/ponjika` |
| Lagno / Muhurta | ✅ Partial | `/logno` |
| Ekadashi + reminders | ✅ Mock | `/ekadashi` |
| Biye Lagno (Guna Milan) | ✅ Mock | `/biye-lagno` |
| Mandap discovery + route | ✅ Mock | `/mondop-map` |
| Mandap reviews | ✅ Mock | Mondop detail |
| Marketplace (COD) | ✅ Mock | `/marketplace` |
| Community chat | ✅ Mock | `/community` |
| Location sharing | ✅ Partial | Settings → Privacy |
| Social feed | ✅ Mock | Home tabs |
| Color palette §19 | ✅ | `lib/core/theme/app_colors.dart` |

## Mock Data

| File | Purpose |
|------|---------|
| `assets/mock/ponjika.json` | Calendar, logno, ekadashi |
| `assets/mock/mondops.json` | Mandap pins + reviews |
| `assets/mock/marketplace_products.json` | COD products |
| `assets/mock/community_chat.json` | Chat rooms + messages |
| `assets/mock/biye_lagno_profiles.json` | Sample birth profiles |
| `assets/mock/home_dashboard.json` | Dashboard features grid |

## Architecture

Each feature follows:

```
lib/features/<name>/
  domain/entities/       # Pure Dart models
  domain/repositories/   # Abstract contracts
  data/datasources/      # Asset / local / remote
  data/repositories/     # Implementations
  presentation/cubit/    # State management
  presentation/pages/    # Screens
  presentation/widgets/  # Extracted UI (<400 lines/file)
```

## Auth Flow (SRS §3)

```
Splash → Onboarding (first launch) → Google Sign-In
  → Profile completion (if incomplete) → Home
```

Profile fields: name, district, DOB, time of birth, birthplace, gender (for Lagno).

## How to Add a Feature

1. Create `domain/entities` + `domain/repositories`.
2. Add mock JSON under `assets/mock/`.
3. Implement `data/repositories/*_impl.dart`.
4. Add `presentation/cubit` with `loadState` enum pattern.
5. Wire in `app_dependencies.dart`, `app_route_paths.dart`, `app_router_feature_routes.dart`.
6. Register asset in `pubspec.yaml` if new folder.

## Validation

Form validators live in `lib/core/utils/validators.dart`:
- Email, password, name, phone (legacy)
- District, DOB, birth time, COD checkout fields

## Out of Scope (SRS v1)

- Real NestJS backend / WebSocket chat
- Payment gateway (COD only)
- Real Google OAuth (`google_sign_in` — stubbed for demo)
- iOS release, live video, donations

## Run

```bash
flutter pub get
flutter run --dart-define=USE_MOCK_API=true
```
