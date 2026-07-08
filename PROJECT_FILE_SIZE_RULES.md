# File size & structure rules

## Limits

| Type | Target | Hard max |
|------|--------|----------|
| Dart source (hand-written) | **~300 lines** | **400 lines** |
| Generated code (`*.g.dart`, `app_localizations*.dart`) | Exempt | Exempt |

If a file approaches 300 lines, **split before adding more code**.

## Where to put extracted code

| Extract | Folder / naming |
|---------|------------------|
| Feature UI parts | `lib/features/<feature>/presentation/widgets/<feature>_<part>.dart` |
| Feature painters / visuals | `.../presentation/widgets/` or `.../presentation/painters/` |
| Auth tabs / forms | `lib/features/auth/presentation/widgets/register_<tab>_tab.dart` |
| Router groups | `lib/presentation/router/app_router_<group>_routes.dart` |
| Redirect logic | `lib/presentation/router/go_app_redirect.dart` |
| Data models (large) | `lib/features/<feature>/data/models/<name>_<slice>.dart` + barrel export |
| Shared helpers | `lib/core/<area>/<descriptive>_helper.dart` |

## Naming

- Use **descriptive snake_case** file names: `dashboard_countdown_card.dart`, not `widget1.dart`.
- One primary public widget/class per file when possible.
- Barrel exports only when they improve imports (e.g. `ponjika_models.dart` re-exports slices).

## Page file responsibility

A `*_page.dart` file should only:

1. Scaffold / route-level layout
2. Wire `BlocProvider` / `BlocBuilder` / listeners
3. Compose child widgets from `widgets/`

Move cards, grids, painters, and tabs into sibling widget files.

## Checklist (PR / AI)

- [ ] No hand-written file over 400 lines
- [ ] New UI blocks live in `widgets/` (or `painters/`), not bloated pages
- [ ] Router changes use `app_router_*_routes.dart` helpers
- [ ] Models split by domain slice when > ~200 lines

See also: `FETCHING_AND_UI_RULES.md`, `PROMPT_FLUTTER_STRUCTURE.md`.
