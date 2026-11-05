"""The six Pixel Quest sound packs. Each builder returns {slot: samples}."""
from sfx_synth import (arp, crush4, fm_bell, midi, mix, noise_burst, pad, seq,
                       voice, whoosh)


def synth_pop():
    """8-Bit Synth Pop & Coin SFX: square-wave coin/jump/power-up arpeggios."""
    return {
        "tap": voice("square", 1200, 0.04, decay=5),
        "increment": arp("square", [83, 88], 0.035, 0.04, decay=3),
        "undo": voice("square", 600, 0.07, 300, decay=3),
        "complete": arp("square", [72, 76, 79, 84, 88], 0.065, 0.075, decay=2),
        "brickLand": mix((0, voice("square", 200, 0.08, 70, decay=5), 0.8),
                         (0, noise_burst(0.04, 6), 0.3)),
        "rowClear": arp("square", [60, 64, 67, 72, 76, 79, 84, 88], 0.035, 0.06, decay=2),
        "levelUp": arp("square", [60, 64, 67, 72, 67, 72, 76, 79, 84, 79, 84, 88, 91],
                       0.08, 0.12, decay=2.5),
        "badgeUnlock": arp("square", [67, 71, 74, 79, 78, 74, 79, 83, 86], 0.1, 0.15, decay=2.5),
        "focusStart": voice("square", 300, 0.15, 900, decay=2),
        "focusStop": voice("square", 900, 0.15, 300, decay=2),
    }


def laser_drop():
    """Laser Drop SFX: descending zaps, low pulse, noise-burst explosion."""
    return {
        "tap": voice("square", 1800, 0.06, 600, decay=4),
        "increment": voice("saw", 1400, 0.07, 500, decay=3.5),
        "undo": voice("saw", 500, 0.07, 200, decay=3),
        "complete": mix((0, voice("saw", 1600, 0.12, 400, decay=3), 1.0),
                        (0.1, voice("saw", 1900, 0.12, 500, decay=3), 0.9),
                        (0.2, voice("saw", 2200, 0.12, 600, decay=3), 0.8),
                        (0.3, voice("sine", 2400, 0.1, decay=5), 0.6)),
        "brickLand": mix((0, voice("square", 90, 0.08, 60, decay=4), 1.0),
                         (0, noise_burst(0.03, 6, 0.6), 0.4)),
        "rowClear": mix((0, noise_burst(0.45, 5, 0.85), 1.6),
                        (0, voice("saw", 120, 0.4, 40, decay=4), 0.7)),
        "levelUp": mix((0, voice("saw", 200, 0.6, 1600, decay=1.5), 0.7),
                       (0.5, arp("square", [72, 79, 84, 91], 0.12, 0.2, decay=3), 0.8)),
        "badgeUnlock": arp("sine", [76, 83, 88, 95, 100], 0.15, 0.4, decay=3,
                           partials=((1, 1.0), (2, 0.3)), vib=0.02),
        "focusStart": seq([voice("square", 70, 0.1, decay=3)] * 2, 0.14),
        "focusStop": voice("saw", 500, 0.25, 70, decay=3),
    }


def chiptune():
    """4-Bit Chiptune Bleep: quantized 25%-pulse bleeps, Game Boy-ish."""
    def p(f, dur, f1=None):
        return voice("pulse", f, dur, f1, decay=2.5)

    sounds = {
        "tap": p(1000, 0.04),
        "increment": seq([p(784, 0.035), p(1175, 0.035)], 0.037),
        "undo": p(700, 0.07, 350),
        "complete": arp("pulse", [67, 71, 74, 79], 0.07, 0.1, decay=2),
        "brickLand": mix((0, p(150, 0.08, 60), 0.9), (0, noise_burst(0.03, 6), 0.3)),
        "rowClear": arp("pulse", [60, 64, 67, 72, 76, 79, 84, 88], 0.04, 0.07, decay=2),
        "levelUp": arp("pulse", [60, 64, 67, 72, 71, 74, 79, 83, 86, 91],
                       0.1, 0.14, decay=2.5),
        "badgeUnlock": arp("pulse", [72, 72, 79, 76, 79, 84, 88, 91], 0.12, 0.18, decay=2.5),
        "focusStart": arp("pulse", [64, 71], 0.08, 0.12, decay=2),
        "focusStop": arp("pulse", [71, 64], 0.08, 0.12, decay=2),
    }
    return {k: crush4(v) for k, v in sounds.items()}


def crystal_chime():
    """Crystal Bell Chime: glassy FM bells."""
    return {
        "tap": fm_bell(1568, 0.04, decay=4),
        "increment": seq([fm_bell(1319, 0.035, 3), fm_bell(1760, 0.035, 3)], 0.037),
        "undo": fm_bell(880, 0.07, decay=4),
        "complete": mix(*[(i * 0.08, fm_bell(midi(n), 0.15, 3), 1.0)
                          for i, n in enumerate([88, 91, 95, 100])]),
        "brickLand": fm_bell(520, 0.09, decay=6, ratio=2.2),
        "rowClear": mix(*[(i * 0.045, fm_bell(midi(n), 0.15, 3), 1.0)
                          for i, n in enumerate([100, 98, 95, 91, 88, 86, 83])]),
        "levelUp": mix(*[(i * 0.14, fm_bell(midi(n), 0.6, 3.5), 1.0)
                         for i, n in enumerate([79, 83, 86, 91, 95])]),
        "badgeUnlock": mix(*[(i * 0.06, fm_bell(midi(n), 1.0, 3.5), 0.9)
                             for i, n in enumerate([84, 88, 91])]),
        "focusStart": fm_bell(1046, 0.4, decay=4),
        "focusStop": fm_bell(784, 0.4, decay=4),
    }


def coin_cascade():
    """Coin Cascade SFX: shimmering coin arpeggios that fall in pitch."""
    shimmer = ((1, 1.0), (2, 0.4))

    def coins(notes, step, dur):
        return arp("square", notes, step, dur, decay=4, partials=shimmer, gain=0.8)

    falling = list(range(96, 80, -1))
    return {
        "tap": voice("square", 1568, 0.04, decay=5),
        "increment": arp("square", [83, 88], 0.035, 0.04, decay=3),
        "undo": voice("square", 1000, 0.07, 500, decay=3),
        "complete": coins([96, 93, 91, 88, 84, 81, 79, 76], 0.045, 0.07),
        "brickLand": mix((0, voice("tri", 1200, 0.08, 500, decay=5), 1.0),
                         (0, noise_burst(0.02, 8), 0.2)),
        "rowClear": coins(list(range(100, 86, -1)), 0.03, 0.08),
        "levelUp": coins(falling, 0.06, 0.15),
        "badgeUnlock": coins([76, 79, 84, 88] + list(range(98, 84, -1)), 0.06, 0.14),
        "focusStart": coins([84, 88, 91], 0.07, 0.1),
        "focusStop": coins([91, 88, 84], 0.07, 0.1),
    }


def cosmic_warp():
    """Cosmic Warp Ambient: soft pad swells and whooshes, kept short."""
    return {
        "tap": pad(600, 900, 0.06, vib=0),
        "increment": pad(500, 800, 0.075, vib=0),
        "undo": pad(800, 500, 0.075, vib=0),
        "complete": mix((0, pad(330, 440, 0.38, ((1, 1.0), (1.5, 0.6), (2, 0.3))), 1.0),
                        (0, whoosh(0.3, 0.8), 0.15)),
        "brickLand": mix((0, pad(100, 70, 0.085, vib=0), 1.0),
                         (0, noise_burst(0.05, 5, 0.9), 0.6)),
        "rowClear": mix((0, whoosh(0.45, 0.92), 1.4), (0, pad(200, 600, 0.45), 0.6)),
        "levelUp": mix((0, pad(220, 440, 1.1, ((1, 1.0), (1.5, 0.6), (2, 0.4)), shape=0.7), 1.0),
                       (0, pad(330, 660, 1.1, shape=0.7), 0.6),
                       (0, whoosh(1.0, 0.93), 0.8)),
        "badgeUnlock": mix((0, pad(262, 262, 1.15, ((1, 1.0), (1.25, 0.6), (1.5, 0.6), (2, 0.3)),
                                   shape=0.6), 1.0),
                           (0.1, pad(523, 523, 1.0, shape=0.6), 0.5)),
        "focusStart": mix((0, pad(200, 400, 0.4), 1.0), (0, whoosh(0.4, 0.9), 0.5)),
        "focusStop": mix((0, pad(400, 200, 0.4), 1.0), (0, whoosh(0.4, 0.9), 0.5)),
    }


PACKS = {
    "chiptune": chiptune,
    "synthPop": synth_pop,
    "laserDrop": laser_drop,
    "crystalChime": crystal_chime,
    "coinCascade": coin_cascade,
    "cosmicWarp": cosmic_warp,
}
