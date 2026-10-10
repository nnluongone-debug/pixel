# Phase 2 — Brick skin rendering engine + 4 skins

**Priority:** high · **Status:** planned · **Depends on:** phase 1

## Key insights
- All bricks go through `BrickPainter.paintBrick/paintSlot` (matrix static
  layer, drop effects) — one seam to swap. Mini pixel bars (habit cards),
  editor T-block preview and badge art draw their own; skins apply to the
  matrix + mini bars + editor preview, not to badges (badges keep tier art).
- The static matrix layer repaints only on data change; animated skins
  (glitch, sparkle) must not force 60 fps repaints of 150 blurred bricks.

## Architecture
- `abstract class BrickSkin { paintSlot; paintBrick(canvas, rect, color, {opacity, glow}); bool get animated; void paintOverlay(canvas, size, bricks, t) }`.
- `NeonGlowSkin` = current `BrickPainter` (refactor, pixel-identical).
- `GameBoySkin`: map habit color → luminance → 4 fixed greens
  (#0F380F #306230 #8BAC0F #9BBC0F), 1 px dark outline, no blur, LCD
  background tint on the matrix panel.
- `CyberpunkGlitchSkin`: magenta/cyan channel-offset edges, scanline overlay;
  overlay layer jitters 1–3 random bricks for ~120 ms every few seconds.
- `GemstoneSkin`: faceted brick (light/dark triangles), white specular corner;
  overlay twinkles a few star pixels on random bricks.
- `PureGoldSkin`: gold gradient bevel + embossed edge; habit color as a small
  square inlay so habits stay distinguishable.
- Animated skins draw in a third, cheap overlay painter driven by one ticker
  at ~20–30 fps, only while the matrix is visible (TickerMode).
- `brickSkinProvider` → `PixelMatrixGrid` / `MiniPixelBar` / editor preview.

## Files
- Create: `lib/features/matrix/skins/{brick_skin,neon_glow_skin,game_boy_skin,cyberpunk_glitch_skin,gemstone_skin,pure_gold_skin}.dart`, `matrix_overlay_painter.dart`.
- Modify: `matrix_grid_painter.dart`, `matrix_effects_painter.dart`,
  `pixel_matrix_grid.dart`, `habit_card_parts.dart` (MiniPixelBar),
  `habit_editor/metaphor_section.dart`.

## Todo
- [ ] Extract `BrickSkin`, keep Neon pixel-identical (golden PNG test)
- [ ] Implement 4 skins + render-to-PNG review sheet (all skins side by side)
- [ ] Overlay painter for animated skins; reduce-motion → static
- [ ] Skin switch animates (cross-fade) without remounting the grid
- [ ] Perf check on device: 150 bricks, no jank in profile mode

## Success criteria
Switching skin restyles matrix, cards and editor preview instantly; all skins
readable for every habit color; no frame drops on iPhone 11 in profile mode.

## Risks
Glow/blur cost with 150 bricks → skins without blur (Game Boy, Gold) are
cheaper; keep blur only in Neon/Gem and cached in the static layer.
