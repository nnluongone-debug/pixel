import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { codeMatches, emailDocId } from './crypto';
import { ensureVerifiedUid } from './login-account';
import { DAY_MS, MAX_ATTEMPTS, failureLock, recentWithin } from './rate-limit';
import { maskEmail, normalizeCode, normalizeEmail } from './validation';

type Outcome =
  | { kind: 'ok' }
  | { kind: 'missing' }
  | { kind: 'wrong'; attemptsLeft: number }
  | { kind: 'locked'; retryAfterSeconds?: number };

/** Checks the code, counts failures, and returns a custom token on success. */
export async function verifyLoginCode(rawEmail: unknown, rawCode: unknown): Promise<{ token: string }> {
  const email = normalizeEmail(rawEmail);
  if (!email) throw new HttpsError('invalid-argument', 'Invalid email.', { field: 'email' });
  const code = normalizeCode(rawCode);
  if (!code) throw new HttpsError('invalid-argument', 'Invalid code.', { field: 'code' });

  const db = getFirestore();
  const codeRef = db.collection('loginCodes').doc(emailDocId(email));
  const limitRef = db.collection('loginLimits').doc(`email_${emailDocId(email)}`);

  const outcome = await db.runTransaction<Outcome>(async (tx) => {
    const [limitSnap, codeSnap] = await Promise.all([tx.get(limitRef), tx.get(codeRef)]);
    const now = Date.now();
    const failTimes = recentWithin((limitSnap.data()?.failTimes as number[] | undefined) ?? [], now, DAY_MS);

    // Lockout first: a locked email must not learn whether a code exists.
    const lock = failureLock(failTimes, now);
    if (lock.locked) return { kind: 'locked', retryAfterSeconds: lock.retryAfterSeconds };

    const data = codeSnap.data();
    if (!data || typeof data.codeHash !== 'string' || typeof data.salt !== 'string') {
      return { kind: 'missing' };
    }
    if (data.expiresAt.toMillis() <= now) return { kind: 'missing' };

    if (codeMatches(code, data.salt, data.codeHash)) {
      tx.delete(codeRef);
      return { kind: 'ok' };
    }

    const nextFails = [...failTimes, now];
    tx.set(limitRef, { failTimes: nextFails }, { merge: true });
    const attempts = ((data.attempts as number | undefined) ?? 0) + 1;
    const nowLock = failureLock(nextFails, now);
    if (attempts >= MAX_ATTEMPTS || nowLock.locked) {
      tx.delete(codeRef);
      return {
        kind: 'locked',
        retryAfterSeconds: nowLock.locked ? nowLock.retryAfterSeconds : undefined,
      };
    }
    tx.update(codeRef, { attempts });
    return { kind: 'wrong', attemptsLeft: MAX_ATTEMPTS - attempts };
  });

  switch (outcome.kind) {
    case 'missing':
      throw new HttpsError('not-found', 'No active code.', { reason: 'expired' });
    case 'locked':
      throw new HttpsError('resource-exhausted', 'Too many wrong attempts.', {
        reason: 'attempts',
        ...(outcome.retryAfterSeconds === undefined ? {} : { retryAfterSeconds: outcome.retryAfterSeconds }),
      });
    case 'wrong':
      throw new HttpsError('permission-denied', 'Wrong code.', { attemptsLeft: outcome.attemptsLeft });
  }

  try {
    return { token: await getAuth().createCustomToken(await ensureVerifiedUid(email)) };
  } catch (e) {
    logger.error('Sign-in token failed', { to: maskEmail(email), error: (e as Error).message });
    throw new HttpsError('internal', 'Could not sign in.');
  }
}
