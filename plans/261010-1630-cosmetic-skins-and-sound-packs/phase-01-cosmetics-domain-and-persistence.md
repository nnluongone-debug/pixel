# Phase 1 — Cosmetics domain, unlocks & persistence

**Priority:** high (blocks 2–4) · **Status:** planned

## Key insights
- Unlocks derive from lifetime XP/level (`XpRules`, `userStatsProvider`), so
  "owned" never needs storing for level items — undo/re-earn stays consistent.
- Only the *equipped* choice and "already celebrated" ids need persistence.
- Signed-in users should get their equipped look on every device.

## Requirements
- `CosmeticKind { skin, sound }`, `CosmeticId` enum, `CosmeticUnlock`
  (`default`, `level(n)`, `pro`), catalog with tier/rarity for display.
- `isUnlocked(item, level, hasPro)`; next-unlock helper for "LV 6 →" hints.
- Equipped skin/sound persisted in SharedPreferences; when signed in, mirrored
  to `users/{uid}.cosmetics {skin, sound, updatedAt}` (last-write-wins).
- Equipped item that becomes locked (XP removed by undo/delete) falls back to
  the default without deleting the preference.
- Sound settings: enabled flag + volume (0–1).

## Architecture
- `lib/domain/cosmetics/cosmetic_catalog.dart`, `unlock_rules.dart` (pure).
- `lib/providers/cosmetics_providers.dart`: `unlockedCosmeticsProvider`,
  `equippedSkinProvider`, `equippedSoundProvider`, `soundSettingsProvider`.
- `lib/data/repositories/cosmetics_repository.dart`: prefs + Firestore mirror.
- `firestore.rules`: allow optional `cosmetics` map (known ids only).

## Files
- Create: the four above + tests in `test/domain/cosmetics/**`, `test/providers/**`.
- Modify: `firestore.rules`, `lib/data/models/user_profile.dart` (ignore
  unknown keys), `lib/providers/sync_providers.dart` (pull cosmetics on sign-in).

## Todo
- [ ] Catalog + unlock rules + tests (thresholds, fallback, Pro flag)
- [ ] Providers + prefs persistence + tests
- [ ] Firestore mirror + rules + deploy rules
- [ ] "newly unlocked" detection (reuse `BadgeUnlockListener` pattern)

## Success criteria
Levels 1/3/6/10/15 unlock exactly the expected items; equipping survives
restart and sign-in on a second device; locked equipped item falls back.

## Risks
Rules change breaks profile saves → ship rules + client together; test with
the existing profile save test.
