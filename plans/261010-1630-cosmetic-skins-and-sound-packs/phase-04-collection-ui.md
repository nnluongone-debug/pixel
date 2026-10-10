# Phase 4 — Collection screen ("ARCADE LOCKER") + unlock popups

**Priority:** high · **Status:** planned · **Depends on:** phases 2, 3

## Requirements
- Entry points: Profile ("ARCADE LOCKER" card) and Config.
- Tabs **SKINS** / **SOUNDS**; each item card shows:
  - live preview (mini 5×4 tower rendered with that skin; sound card plays a
    short preview sequence on tap),
  - rarity frame matching the badge tiers,
  - state: EQUIPPED / EQUIP / locked with requirement ("LV 6 — 320 XP to go")
    and progress bar.
- Equipping: haptic + sound of the new pack + brief re-skin animation.
- "NEW SKIN!/NEW SOUND PACK!" popup when a level-up unlocks an item (reuse the
  badge celebration dialog; one popup per item, celebrated once).
- Bilingual strings (EN/VI), 360 dp fit, reduce-motion support.

## Files
- Create: `lib/features/locker/**` (screen, item cards, previews, unlock
  listener), tests `test/features/locker/**`.
- Modify: `lib/features/account/profile_screen.dart`,
  `lib/features/config/config_screen.dart`, ARB files.

## Todo
- [ ] Locker screen + cards + previews
- [ ] Equip flow + persistence wiring
- [ ] Unlock celebration (first-run silent, like badges)
- [ ] Widget tests (locked/unlocked/equip, VI rendering)

## Success criteria
A level-6 player sees 3 skins unlocked, equips Cyberpunk, and the home matrix
restyles immediately; reaching level 10 pops "NEW SKIN!" once.
