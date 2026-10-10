const MAX_EMAIL_LENGTH = 254;
const EMAIL_PATTERN = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
const CODE_PATTERN = /^\d{6}$/;

export type Lang = 'vi' | 'en';

export function normalizeEmail(input: unknown): string | null {
  if (typeof input !== 'string') return null;
  const email = input.trim().toLowerCase();
  if (email.length < 5 || email.length > MAX_EMAIL_LENGTH) return null;
  return EMAIL_PATTERN.test(email) ? email : null;
}

export function normalizeCode(input: unknown): string | null {
  if (typeof input !== 'string') return null;
  const code = input.trim();
  return CODE_PATTERN.test(code) ? code : null;
}

export function normalizeLang(input: unknown): Lang {
  return typeof input === 'string' && input.toLowerCase().startsWith('vi')
    ? 'vi'
    : 'en';
}

/** Keeps the first character and the domain only, e.g. `a***@example.com`. */
export function maskEmail(email: string): string {
  const at = email.lastIndexOf('@');
  if (at < 1) return '***';
  return `${email[0]}***${email.slice(at)}`;
}
