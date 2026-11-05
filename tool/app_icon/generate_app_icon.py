"""Renders the Pixel Quest launcher icon (pure Python, no deps).

A 5x5 brick matrix whose columns rise left to right like a habit streak,
neon bricks with a pixel bevel and soft glow on the app's dark surface.

Usage: python3 tool/app_icon/generate_app_icon.py assets/app_icon
Writes app_icon.png (full, opaque) and app_icon_foreground.png
(transparent, for the Android adaptive icon).
"""
import math
import os
import struct
import sys
import zlib

SIZE = 1024
BG_TOP = (0x16, 0x18, 0x22)
BG_BOTTOM = (0x0B, 0x0C, 0x10)
SLOT = (0x25, 0x29, 0x36)
# Column colors from the habit palette: rose, amber, mint, cyan, lavender.
COLUMNS = [(0xFF, 0x76, 0x75), (0xF9, 0xCA, 0x24), (0x2D, 0xE3, 0x8E),
           (0x00, 0xD2, 0xFF), (0xA2, 0x9B, 0xFE)]
HEIGHTS = [1, 2, 3, 4, 5]
GRID = 5


def mix(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def render(scale, opaque):
    cell = 120 * scale
    gap = 24 * scale
    span = GRID * cell + (GRID - 1) * gap
    origin = (SIZE - span) / 2
    bricks = []  # (x0, y0, x1, y1, color)
    slots = []
    for c in range(GRID):
        for r in range(GRID):  # r = 0 is the bottom row
            x0 = origin + c * (cell + gap)
            y0 = origin + (GRID - 1 - r) * (cell + gap)
            rect = (x0, y0, x0 + cell, y0 + cell)
            if r < HEIGHTS[c]:
                bricks.append(rect + (COLUMNS[c],))
            else:
                slots.append(rect)
    bevel = max(1.0, 14 * scale)
    sigma = 46 * scale
    rows = []
    for y in range(SIZE):
        row = bytearray()
        bg = mix(BG_TOP, BG_BOTTOM, y / (SIZE - 1))
        for x in range(SIZE):
            px, py = x + 0.5, y + 0.5
            color, alpha = (bg, 1.0) if opaque else ((0, 0, 0), 0.0)
            # Glow: nearest-edge distance to each brick.
            glow = [0.0, 0.0, 0.0]
            for (x0, y0, x1, y1, col) in bricks:
                dx = max(x0 - px, 0, px - x1)
                dy = max(y0 - py, 0, py - y1)
                if dx or dy:
                    g = 0.55 * math.exp(-(dx * dx + dy * dy) / (sigma * sigma))
                    for i in range(3):
                        glow[i] += col[i] * g
            g_alpha = min(1.0, max(glow) / 255)
            if g_alpha > 0:
                glow_col = tuple(min(255, v / g_alpha) for v in glow) if g_alpha else (0, 0, 0)
                if opaque:
                    color = tuple(min(255, color[i] + glow[i]) for i in range(3))
                else:
                    color, alpha = glow_col, g_alpha
            for (x0, y0, x1, y1) in slots:
                if x0 <= px < x1 and y0 <= py < y1:
                    edge = min(px - x0, x1 - px, py - y0, y1 - py) < 4 * scale
                    slot = mix(SLOT, (0x3C, 0x4A, 0x3F), 0.6) if edge else SLOT
                    color = mix(color, slot, 0.85) if opaque else slot
                    alpha = 1.0 if opaque else max(alpha, 0.9)
            for (x0, y0, x1, y1, col) in bricks:
                if x0 <= px < x1 and y0 <= py < y1:
                    if px - x0 < bevel or py - y0 < bevel:
                        color = mix(col, (255, 255, 255), 0.45)  # lit edge
                    elif x1 - px < bevel or y1 - py < bevel:
                        color = mix(col, (0, 0, 0), 0.35)  # shadow edge
                    else:
                        color = col
                    alpha = 1.0
            r, g, b = (int(round(v)) for v in color)
            row += bytes((r, g, b, int(round(alpha * 255))))
        rows.append(bytes(row))
    return rows


def write_png(path, rows):
    raw = b''.join(b'\x00' + r for r in rows)
    def chunk(tag, data):
        return (struct.pack('>I', len(data)) + tag + data +
                struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF))
    png = (b'\x89PNG\r\n\x1a\n' +
           chunk(b'IHDR', struct.pack('>IIBBBBB', SIZE, SIZE, 8, 6, 0, 0, 0)) +
           chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))
    with open(path, 'wb') as f:
        f.write(png)


if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else 'assets/app_icon'
    os.makedirs(out, exist_ok=True)
    write_png(os.path.join(out, 'app_icon.png'), render(1.0, True))
    # flutter_launcher_icons insets the adaptive foreground by 16%, which
    # already lands the matrix inside the launcher's safe zone.
    write_png(os.path.join(out, 'app_icon_foreground.png'), render(1.0, False))
    print('wrote', out)
