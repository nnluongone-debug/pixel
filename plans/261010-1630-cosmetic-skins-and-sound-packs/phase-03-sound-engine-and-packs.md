# Phase 3 — Sound engine + 3 original sound packs

**Priority:** high · **Status:** planned · **Depends on:** phase 1

## Key insights
- Today only `SystemSound.click` + haptics exist; haptics stay as they are.
- Taps need <30 ms latency → preload short WAVs into `AudioPool`s.
- Must respect the iOS silent switch and mix with the user's music
  (ambient audio session), and a global mute in Config.
- Legal: original sounds only — synthesized by a committed script.

## Events → sound slots
`tap`, `increment`, `undo`, `complete` (target reached), `brickLand`,
`rowClear`, `levelUp`, `badgeUnlock`, `focusStart/Stop`.

## Packs
- **Neon Default** — soft sine/triangle blips.
- **8-Bit Platformer** — square-wave coin/jump/power-up style arpeggios.
- **Space Arcade** — descending zaps, low "march" pulse, explosion noise burst.
- **Zen Wood** — damped wood-block / temple-block hits, gentle chime for level up.

## Architecture
- `tool/sfx/generate_sfx.py` (stdlib only: `wave`, `math`, `random`) writes
  16-bit 22 kHz mono WAVs to `assets/sounds/<pack>/<slot>.wav` (~5–40 KB each).
- `lib/services/sound/sound_service.dart`: preload pack, `play(SoundSlot)`,
  volume, mute, pack switch; failures are logged, never thrown.
- `soundServiceProvider` + hooks: `NeonActionButton` (tap), `HabitCard`
  (increment/undo/complete), `PixelMatrixGrid` (brickLand), level-up
  and badge popups.
- Package: `audioplayers` (AudioPool); iOS `AVAudioSessionCategoryAmbient`.

## Todo
- [ ] SFX generator + listen-through of all 4 packs (export a preview list)
- [ ] SoundService + provider + unit tests (slot mapping, mute, missing file)
- [ ] Wire events; throttle bursts (demo seeding drops 150 bricks → cap)
- [ ] Config: sound toggle + volume + pack preview buttons
- [ ] Device test: silent switch, background music mixing, latency

## Success criteria
Every event plays the equipped pack's sound with no audible delay; silent
switch and mute respected; asset size < 1.5 MB total.
