#!/usr/bin/env python3
"""Synthesizes the original Pixel Quest sound packs (stdlib only, deterministic).

Writes 16-bit 22.05 kHz mono WAVs to assets/sounds/<packId>/<slot>.wav and
prints a duration/size table. Run from anywhere: python3 tool/sfx/generate_sfx.py
"""
import os

from sfx_packs import PACKS
from sfx_synth import SR, finish, write

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "sounds")
SLOTS = ["tap", "increment", "undo", "complete", "brickLand", "rowClear",
         "levelUp", "badgeUnlock", "focusStart", "focusStop"]


def main():
    total = 0
    print("%-14s %-12s %8s %8s" % ("pack", "slot", "ms", "bytes"))
    for pack, build in PACKS.items():
        folder = os.path.join(OUT, pack)
        os.makedirs(folder, exist_ok=True)
        sounds = build()
        assert set(sounds) == set(SLOTS), pack
        for slot in SLOTS:
            samples = finish(sounds[slot])
            path = os.path.join(folder, slot + ".wav")
            write(path, samples)
            size = os.path.getsize(path)
            total += size
            print("%-14s %-12s %8d %8d" % (pack, slot, len(samples) * 1000 // SR, size))
    print("total: %.1f KB" % (total / 1024))


if __name__ == "__main__":
    main()
