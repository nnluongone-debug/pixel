import { decideAccountAction } from '../src/account-policy';
import { decideDailyCap, decideWindow, failureLock } from '../src/rate-limit';
import { describe, expect, it } from 'vitest';
import { codeMatches, generateCode, generateSalt, hashCode } from '../src/crypto';
import { buildLoginEmail } from '../src/email-template';
import { decideSend } from '../src/rate-limit';
import { maskEmail, normalizeCode, normalizeEmail, normalizeLang } from '../src/validation';

describe('validation', () => {
  it('normalizes emails', () => {
    expect(normalizeEmail('  Foo@Bar.COM ')).toBe('foo@bar.com');
  });
  it('rejects bad emails', () => {
    for (const bad of ['', 'a@b', 'no-at.com', 'a b@c.com', 42, null, `${'a'.repeat(250)}@b.co`]) {
      expect(normalizeEmail(bad)).toBeNull();
    }
  });
  it('validates codes', () => {
    expect(normalizeCode(' 012345 ')).toBe('012345');
    for (const bad of ['12345', '1234567', 'abcdef', 123456, undefined]) {
      expect(normalizeCode(bad)).toBeNull();
    }
  });
  it('picks language and masks email', () => {
    expect(normalizeLang('vi')).toBe('vi');
    expect(normalizeLang('fr')).toBe('en');
    expect(maskEmail('foo@bar.com')).toBe('f***@bar.com');
  });
});

describe('crypto', () => {
  it('generates 6-digit codes', () => {
    for (let i = 0; i < 200; i++) expect(generateCode()).toMatch(/^\d{6}$/);
  });
  it('matches only the right code and salt', () => {
    const salt = generateSalt();
    const hash = hashCode('123456', salt);
    expect(codeMatches('123456', salt, hash)).toBe(true);
    expect(codeMatches('123457', salt, hash)).toBe(false);
    expect(codeMatches('123456', generateSalt(), hash)).toBe(false);
    expect(codeMatches('123456', salt, 'zz')).toBe(false);
  });
});

describe('decideSend', () => {
  const now = 10_000_000;
  it('allows the first send', () => {
    expect(decideSend([], now)).toEqual({ allowed: true, sendTimes: [now] });
  });
  it('enforces the 60 s gap', () => {
    expect(decideSend([now - 20_000], now)).toEqual({ allowed: false, retryAfterSeconds: 40 });
  });
  it('allows after the gap', () => {
    expect(decideSend([now - 61_000], now).allowed).toBe(true);
  });
  it('caps at 5 per hour and reports time until the oldest expires', () => {
    const sends = [0, 1, 2, 3, 4].map((i) => now - 3_000_000 + i * 70_000);
    expect(decideSend(sends, now)).toEqual({ allowed: false, retryAfterSeconds: 600 });
  });
  it('drops sends older than the window', () => {
    const old = [1, 2, 3, 4, 5].map((i) => now - 4_000_000 - i);
    expect(decideSend(old, now).allowed).toBe(true);
  });
});

describe('email template', () => {
  it('renders both languages with the code', () => {
    const vi = buildLoginEmail('123456', 'vi');
    const en = buildLoginEmail('123456', 'en');
    expect(vi.subject).toContain('mã đăng nhập');
    expect(vi.text).toContain('10 phút');
    expect(en.html).toContain('123456');
    expect(en.text).toContain('10 minutes');
    expect(en.text).toContain('ignore');
  });
});

describe('account policy', () => {
  it('creates, reuses or recreates', () => {
    expect(decideAccountAction(null)).toBe('create');
    expect(decideAccountAction({ emailVerified: true, providerIds: [] })).toBe('reuse');
    expect(decideAccountAction({ emailVerified: true, providerIds: ['custom'] })).toBe('reuse');
    expect(decideAccountAction({ emailVerified: false, providerIds: [] })).toBe('recreate');
    expect(decideAccountAction({ emailVerified: true, providerIds: ['password'] })).toBe('recreate');
    expect(decideAccountAction({ emailVerified: false, providerIds: ['password'] })).toBe('recreate');
  });
});

describe('limits', () => {
  const now = 100_000_000;
  it('locks after 10 failures in 24h and reports unlock time', () => {
    const fails = Array.from({ length: 10 }, (_, i) => now - 3_600_000 + i * 1000);
    expect(failureLock(fails.slice(1), now)).toEqual({ locked: false });
    expect(failureLock(fails, now)).toEqual({ locked: true, retryAfterSeconds: 82800 });
  });
  it('forgets failures older than 24h', () => {
    expect(failureLock(Array.from({ length: 10 }, () => now - 90_000_000), now).locked).toBe(false);
  });
  it('caps per IP', () => {
    const sends = Array.from({ length: 10 }, (_, i) => now - 1_800_000 + i);
    expect(decideWindow(sends, now, 3_600_000, 10)).toEqual({ allowed: false, retryAfterSeconds: 1800 });
    expect(decideWindow(sends.slice(1), now, 3_600_000, 10).allowed).toBe(true);
  });
  it('caps per day', () => {
    expect(decideDailyCap(89, now, 90).allowed).toBe(true);
    expect(decideDailyCap(90, now, 90).allowed).toBe(false);
  });
});
