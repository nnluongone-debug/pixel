export const MAX_SENDS_PER_HOUR = 5;
export const MIN_SEND_INTERVAL_MS = 60_000;
export const HOUR_MS = 3_600_000;
export const DAY_MS = 86_400_000;
export const CODE_TTL_MS = 600_000;
/** Wrong guesses allowed against a single code. */
export const MAX_ATTEMPTS = 5;
/** Wrong guesses allowed per email per 24 h, across all codes. */
export const MAX_FAILURES_PER_DAY = 10;
export const MAX_SENDS_PER_IP_PER_HOUR = 10;
/** Kept below the Resend free tier (100/day). */
export const MAX_SENDS_PER_DAY = 90;

export type SendDecision =
  | { allowed: true; sendTimes: number[] }
  | { allowed: false; retryAfterSeconds: number };

/** Timestamps (ms) still inside the window ending at [now]. */
export function recentWithin(times: readonly number[], now: number, windowMs: number): number[] {
  return times.filter((t) => t > now - windowMs && t <= now);
}

function secondsUntilOldestExpires(recent: readonly number[], now: number, windowMs: number): number {
  return Math.ceil((Math.min(...recent) + windowMs - now) / 1000);
}

/** Decides whether another code may be sent to one email, given prior send times. */
export function decideSend(previous: readonly number[], now: number): SendDecision {
  const recent = recentWithin(previous, now, HOUR_MS);
  const waits: number[] = [];
  if (recent.length) {
    const sinceLast = now - Math.max(...recent);
    if (sinceLast < MIN_SEND_INTERVAL_MS) {
      waits.push(Math.ceil((MIN_SEND_INTERVAL_MS - sinceLast) / 1000));
    }
  }
  if (recent.length >= MAX_SENDS_PER_HOUR) {
    waits.push(secondsUntilOldestExpires(recent, now, HOUR_MS));
  }
  if (waits.length) return { allowed: false, retryAfterSeconds: Math.max(...waits) };
  return { allowed: true, sendTimes: [...recent, now] };
}

/** Sliding-window cap used for the per-IP limit. */
export function decideWindow(
  previous: readonly number[],
  now: number,
  windowMs: number,
  max: number,
): SendDecision {
  const recent = recentWithin(previous, now, windowMs);
  if (recent.length >= max) {
    return { allowed: false, retryAfterSeconds: secondsUntilOldestExpires(recent, now, windowMs) };
  }
  return { allowed: true, sendTimes: [...recent, now] };
}

/** Fixed UTC-day counter for the global send cap. */
export function decideDailyCap(
  count: number,
  now: number,
  max: number,
): { allowed: boolean; retryAfterSeconds: number } {
  const nextMidnight = (Math.floor(now / DAY_MS) + 1) * DAY_MS;
  return { allowed: count < max, retryAfterSeconds: Math.ceil((nextMidnight - now) / 1000) };
}

export function utcDayKey(now: number): string {
  return new Date(now).toISOString().slice(0, 10);
}

export type LockState = { locked: false } | { locked: true; retryAfterSeconds: number };

/** Locked once an email accumulated [MAX_FAILURES_PER_DAY] wrong guesses in 24 h. */
export function failureLock(failTimes: readonly number[], now: number): LockState {
  const recent = recentWithin(failTimes, now, DAY_MS);
  if (recent.length < MAX_FAILURES_PER_DAY) return { locked: false };
  // Unlocks once enough old failures age out to drop below the cap.
  const sorted = [...recent].sort((a, b) => a - b);
  const unlockAt = sorted[recent.length - MAX_FAILURES_PER_DAY] + DAY_MS;
  return { locked: true, retryAfterSeconds: Math.ceil((unlockAt - now) / 1000) };
}
