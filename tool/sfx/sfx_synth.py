#!/usr/bin/env python3
"""Synthesis primitives shared by the Pixel Quest sound packs (stdlib only)."""
import math
import random
import struct
import wave

SR = 22050
rng = random.Random(2610)


def midi(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def wave_at(kind, ph):
    p = ph % (2 * math.pi)
    if kind == "sine":
        return math.sin(p)
    if kind == "tri":
        return 2 / math.pi * math.asin(math.sin(p))
    if kind == "square":
        return 0.6 if p < math.pi else -0.6
    if kind == "saw":
        return p / math.pi - 1
    if kind == "pulse":  # 25% duty
        return 0.6 if p < math.pi / 2 else -0.6
    return rng.uniform(-1, 1)  # noise


def voice(kind, f0, dur, f1=None, decay=5.0, partials=((1, 1.0),), vib=0.0):
    """One note: exponential pitch glide f0->f1, exponential amplitude decay."""
    n = int(SR * dur)
    f1 = f0 if f1 is None else f1
    phase, out = 0.0, []
    for i in range(n):
        t = i / n
        f = f0 * (f1 / f0) ** t
        if vib:
            f *= 1 + vib * math.sin(2 * math.pi * 6 * i / SR)
        phase += 2 * math.pi * f / SR
        s = sum(a * wave_at(kind, phase * r) for r, a in partials)
        out.append(s * min(1.0, i / (SR * 0.002)) * math.exp(-decay * t))
    return out


def noise_burst(dur, decay=6.0, smooth=0.0):
    """Decaying noise; smooth in 0..1 low-passes it for a rumbling explosion."""
    n, last, out = int(SR * dur), 0.0, []
    for i in range(n):
        last = smooth * last + (1 - smooth) * rng.uniform(-1, 1)
        out.append(last * math.exp(-decay * i / n))
    return out


def mix(*events):
    """events: (start_seconds, samples, gain)."""
    length = max(int(SR * s) + len(x) for s, x, _ in events)
    buf = [0.0] * length
    for start, x, gain in events:
        o = int(SR * start)
        for i, v in enumerate(x):
            buf[o + i] += v * gain
    return buf


def arp(kind, notes, step, dur, decay=5.0, partials=((1, 1.0),), gain=1.0, vib=0.0):
    return mix(*[(i * step, voice(kind, midi(n), dur, decay=decay,
                                  partials=partials, vib=vib), gain)
                 for i, n in enumerate(notes)])


def seq(parts, step):
    return mix(*[(i * step, p, 1.0) for i, p in enumerate(parts)])


def fm_bell(f, dur, decay=5.0, ratio=3.5, index=3.0):
    """Glassy FM tone: the modulation index fades faster than the carrier."""
    n, out = int(SR * dur), []
    for i in range(n):
        t = i / n
        mod = index * math.exp(-8 * t) * math.sin(2 * math.pi * f * ratio * i / SR)
        out.append(math.sin(2 * math.pi * f * i / SR + mod)
                   * min(1.0, i / (SR * 0.002)) * math.exp(-decay * t))
    return out


def pad(f0, f1, dur, partials=((1, 1.0), (1.5, 0.5)), vib=0.01, shape=1.0):
    """Soft swell: sine partials under a sin(pi*t)^shape envelope."""
    n, phase, out = int(SR * dur), 0.0, []
    for i in range(n):
        t = i / n
        f = f0 * (f1 / f0) ** t * (1 + vib * math.sin(2 * math.pi * 5 * i / SR))
        phase += 2 * math.pi * f / SR
        out.append(sum(a * math.sin(phase * r) for r, a in partials)
                   * math.sin(math.pi * t) ** shape)
    return out


def whoosh(dur, smooth=0.9, shape=1.0):
    """Low-passed noise swell."""
    n, last, out = int(SR * dur), 0.0, []
    for i in range(n):
        last = smooth * last + (1 - smooth) * rng.uniform(-1, 1)
        out.append(last * math.sin(math.pi * i / n) ** shape)
    return out


def crush4(buf):
    """Quantize to 4-bit (16 levels) for the lo-fi chiptune pack."""
    top = max(abs(v) for v in buf) or 1.0
    return [round(v / top * 7.5) / 7.5 * top for v in buf]


def finish(buf, peak=0.85):
    top = max(abs(v) for v in buf) or 1.0
    g = peak / top
    n, fi, fo = len(buf), int(SR * 0.001), int(SR * 0.006)
    out = []
    for i, v in enumerate(buf):
        v *= g * min(1.0, i / fi if fi else 1.0) * min(1.0, (n - 1 - i) / fo if fo else 1.0)
        out.append(max(-32767, min(32767, int(v * 32767))))
    return out


def write(path, samples):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(struct.pack("<%dh" % len(samples), *samples))
