# Phase 5 — Home-screen widget skins (iOS, optional)

**Priority:** medium · **Status:** planned (in scope) · **Depends on:** phases 1–2

- Add `skin` id to the widget snapshot (`lib/services/home_widget_snapshot.dart`).
- Swift: `WidgetSkin` palette per id (Neon / Game Boy greens / Cyberpunk
  magenta-cyan edges / Gem facet / Gold), static only (WidgetKit has no
  continuous animation).
- Files: `ios/PixelQuestWidget/WidgetTheme.swift`, `BlockGrid.swift`, a new
  `WidgetSkin.swift` (added to the target via the xcodeproj gem).
- Success: changing skin in the app updates widgets on next sync.
