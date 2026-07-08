# Durga Utsav — Theme, Mock API, Localization Guide

This project is a Flutter template reskinned into a **premium Bengali Durga Puja aesthetic** (sindoor red + maroon + gold + cream), with:

- **Theme switching**: Light / Dark / System
- **Language switching**: English / Bengali / System
- **Mock API data** (asset-backed) wired into the existing dashboard demo

The goal is to **upgrade visuals without changing your existing structure/layout**, so developers can keep adding features with the same architecture.

---

## Theme (Premium Durga Puja look)

### Files to know

- `lib/core/theme/app_colors.dart`
  - Central festive palette (sindoor/maroon/gold/cream/ivory + glow)
- `lib/core/theme/app_theme.dart`
  - Material 3 theme defaults (cards, inputs, navigation bar)

### Official color palette

| Role | Hex | Usage |
|------|-----|--------|
| Sindoor red | `#B8142D` | Primary buttons, accents, countdown |
| Deep maroon | `#8B1A2E` | Depth, gradients, dark accents |
| Golden yellow | `#D4AF37` | Borders, icons, premium highlights |
| Warm orange | `#D2691E` | Warmth, gradient end, warnings |
| Cream | `#FFFEF9` | Cards, app bar |
| Ivory | `#FDFAF6` | Scaffold background |

Defined in `lib/core/theme/app_colors.dart` as `AppColors.*`.

### What changed

- **Explicit `ColorScheme`** (not `fromSeed`) so Material does not drift off-brand.
- **Golden card borders** and warm dividers on light theme.
- **Rounded premium components**: cards + inputs use a consistent radius.
- **Warm surfaces**: ivory scaffold + cream cards.

### Extend the theme

If you want more “Puja” atmosphere later, the safest place to add it without breaking layout is:

- `ThemeData.cardTheme`
- `ThemeData.appBarTheme`
- `ThemeData.navigationBarTheme`

---

## Splash (Maa Durga Mukhomondol ambience)

### File

- `lib/features/splash/presentation/pages/splash_page.dart`

### What you get

- **Durga “eyes”** style mark (custom painter)
- **Alpana hint** (subtle line art)
- **Dhunuchi smoke overlay** (lightweight painter, no heavy blur)
- Same **routing behavior** as before (splash resolves via `AppRouterCubit.resolveAfterSplash()`).

---

## Localization (English + Bengali)

### Added dependencies

- `flutter_localizations` (SDK)
- `intl`

### Files

- `l10n.yaml`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_bn.arb`
- Generated output: `lib/l10n/app_localizations.dart` (auto-generated)

### Runtime switching

- `lib/presentation/locale/locale_cubit.dart`
  - Persists language selection in `SharedPreferences`
- Key used: `AppConstants.localeKey` in `lib/core/constants/app_constants.dart`

### Where it’s wired

- `lib/presentation/app.dart`
  - `supportedLocales`, `localizationsDelegates`, and `locale` set from `LocaleCubit`

### Generate localizations

Run:

```bash
flutter gen-l10n
```

Note:
- Avoid ARB keys that are Dart keywords (example: use `continueAction`, not `continue`).

---

## Mock API (asset-backed “mock server”)

This template already had a network demo using JSONPlaceholder via Dio. Now it can run fully offline using fixtures.

### Mock data

- `assets/mock/post_1.json`

### Mock repository

- `lib/features/posts/data/repositories/posts_repository_mock.dart`

### Dependency injection switch

In `lib/core/di/app_dependencies.dart`:

- `useMockApi` defaults to:

```dart
bool.fromEnvironment('USE_MOCK_API', defaultValue: true)
```

So by default, the app uses the **mock posts repository**.

To force real HTTP:

```bash
flutter run --dart-define=USE_MOCK_API=false
```

---

## What to do next (recommended)

If you want this template to match the “Durga Utsav” super-app concept (Maps + Groups + Shopping + Ponjika) while keeping structure:

- Add new features under `lib/features/<feature>/`
- Keep the same pattern:
  - `domain/` (entities + repository contracts)
  - `data/` (datasources + implementations)
  - `presentation/` (pages + blocs/cubits)

Good first features to add next:

- `features/mondop/` (discovery + details, mock JSON fixtures first)
- `features/ponjika/` (daily tithi + timings, local fixtures)
- `features/community/` (groups + chanda tracker, local-only first)

