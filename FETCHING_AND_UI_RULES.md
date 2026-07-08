# Fetching & UI Rules (No duplicate calls / No multi-tap spam)

This document defines the **standard rule/structure** for:

- Preventing **duplicate API calls** when users quickly switch screens/tabs
- Handling **multiple API calls** safely (dedupe + cache)
- Avoiding **multiple button taps** triggering repeated actions
- Rendering **long lists** efficiently without UI jank

The goal: **fast navigation should never cause repeated slow fetches** or flickery loading states.

---

## 1) Core rules

### Rule A — Idempotent `load()`

Every Cubit fetch should follow:

- **If data already loaded** and not forced → don’t fetch again.
- **If a request is in-flight** → return the existing future (dedupe).
- **If refreshing while data exists** → keep existing UI (no full-screen spinner).

Implemented example:

- `lib/features/home/presentation/cubit/home_feed_cubit.dart`
  - `ExploreCubit.load({bool force = false})`
  - `ActivityCubit.load({bool force = false})`
  - `SavedCubit.load({bool force = false})`

### Rule B — Disable actions while busy

Buttons that trigger async work must be guarded:

- `onPressed: busy ? null : () => action()`

This prevents “multi-click spam” and duplicated requests.

In this project:
- Retry buttons are disabled while `FeedLoad.loading`.
- Notification buttons are already disabled via `NotificationState.busy`.

### Rule C — Use `AutomaticKeepAliveClientMixin` for tabs

For `IndexedStack` / shell navigation tabs:

- Mix in `AutomaticKeepAliveClientMixin`
- Return `true` from `wantKeepAlive`

So a quick back/forth does **not** recreate the widget tree and re-trigger init fetches.

Implemented in:
- `ExploreTab`, `ActivityTab`, `SavedTab`

---

## 2) Long list rendering (performance)

### Rule D — Always use builder lists for unbounded data

Don’t do:

- `children: items.map(...).toList()`

Do:

- `ListView.builder`
- `ListView.separated`
- or `CustomScrollView` with `SliverList`

Implemented:
- `ExploreTab`: flattens headers + items into rows and renders with `ListView.builder`
- `ActivityTab` / `SavedTab`: `ListView.separated`

---

## 3) Multiple API calls (batching + caching strategy)

### Rule E — Avoid “N calls for 1 screen”

If a screen requires multiple datasets:

- Prefer **one repository method** returning a combined DTO/model
- Or run requests concurrently but **dedupe each endpoint** (same in-flight future)

Simple safe pattern:

- Keep one `_inFlight` future per Cubit method.
- Cache the latest success in state.

If needed later:

- Add a repository-level cache (memory) with TTL, keyed by params.

---

## 4) When to force refresh

Use:

- Pull-to-refresh → `load(force: true)`
- Retry after failure → `load(force: true)`

Avoid:

- calling `load()` on every build
- calling `load()` every time user revisits a tab when data is already present

---

## 5) Quick checklist for new screens

- [ ] Screen uses **Cubit** with `initial/loading/success/failure`.
- [ ] Cubit has **in-flight dedupe** (`_inFlight` future).
- [ ] Cubit uses **cache**: if data exists and not forced, skip fetch.
- [ ] UI uses **builder list** for long data.
- [ ] Buttons are **disabled while busy**.
- [ ] Tab screens use **keep-alive mixin** if they live in a shell/IndexedStack.

---

## 6) Local storage (year-keyed calendar data)

**Ponjika, Logno, and Ekadashi share one JSON payload per calendar year.**  
Do not add separate API endpoints or caches per screen.

### Rule F — Three-layer cache (memory → disk → network)

1. **Memory** (per year, in repository): instant when user switches between Ponjika / Logno / Ekadashi.
2. **Disk** (`ApplicationDocumentsDirectory/ponjika_cache/ponjika_{year}.json` + `SharedPreferences` metadata): survives app restarts; avoids network on cold start.
3. **Network** (only when disk missing or TTL expired, or `forceRefresh`): single fetch per year; result is written to disk.

Implemented in:

- `lib/features/ponjika/data/datasources/ponjika_local_store.dart`
- `lib/features/ponjika/data/repositories/ponjika_repository.dart`
- `lib/core/cache/year_cache_policy.dart`

### Rule G — TTL by year

| Year | TTL | Why |
|------|-----|-----|
| Current calendar year | 24 hours (`AppConstants.ponjikaCacheTtlCurrentYearHours`) | Today’s tithi / logno can change |
| Past years | 30 days | Mostly static |

If network fails, serve **stale disk** (`PonjikaCacheSource.staleDisk`) instead of error when possible.

### Rule H — Storage limits

- Keep at most **4 years** on disk (`AppConstants.ponjikaMaxCachedYears`); prune oldest when saving a new year.
- Store **raw JSON** on disk (not re-serialized models) to match API shape.

### Rule I — API configuration

```text
--dart-define=PONJIKA_API_URL=https://your.api/ponjika/{year}.json
```

Legacy single URL: `PONJIKA_REMOTE_JSON` (adds `?year=` query).

Without remote URL: bundled `assets/mock/ponjika.json` is used once, normalized to the requested year, then cached to disk.

### Rule J — Cubit usage (all three screens)

- One `PonjikaCubit` per route (same repository singleton from DI).
- `load()` is idempotent; `setYear(y)` reads disk/memory first — **no API** if that year is cached and fresh.
- Pull-to-refresh → `load(force: true)` (bypasses TTL, refetches network, updates disk).

### Checklist for year-based features

- [ ] Single repository method returns combined DTO (not 3 APIs).
- [ ] Disk path keyed by **year**, not screen name.
- [ ] In-flight dedupe keyed by **year** (`Map<int, Future<...>>`).
- [ ] Prune old years after write.
- [ ] Document TTL in `AppConstants`.

