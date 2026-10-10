import { createHash, randomBytes, randomInt, timingSafeEqual } from 'node:crypto';

export function sha256Hex(value: string): string {
  return createHash('sha256').update(value).digest('hex');
}

/** Firestore doc id for an (already normalized) email. */
export function emailDocId(email: string): string {
  return sha256Hex(email);
}

export function generateCode(): string {
  return randomInt(0, 1_000_000).toString().padStart(6, '0');
}

export function generateSalt(): string {
  return randomBytes(16).toString('hex');
}

export function hashCode(code: string, salt: string): string {
  return sha256Hex(`${salt}:${code}`);
}

export function codeMatches(code: string, salt: string, expectedHash: string): boolean {
  const actual = Buffer.from(hashCode(code, salt), 'hex');
  const expected = Buffer.from(expectedHash, 'hex');
  return actual.length === expected.length && timingSafeEqual(actual, expected);
}
