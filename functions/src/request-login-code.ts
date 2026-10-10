import { Timestamp, getFirestore } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { emailDocId, generateCode, generateSalt, hashCode, sha256Hex } from './crypto';
import { buildLoginEmail } from './email-template';
import { sendEmail, EmailSendError } from './email-sender';
import {
  CODE_TTL_MS,
  DAY_MS,
  HOUR_MS,
  MAX_SENDS_PER_DAY,
  MAX_SENDS_PER_IP_PER_HOUR,
  MIN_SEND_INTERVAL_MS,
  decideDailyCap,
  decideSend,
  decideWindow,
  utcDayKey,
} from './rate-limit';
import { maskEmail, normalizeEmail, normalizeLang } from './validation';

export interface RequestInput {
  email: unknown;
  lang: unknown;
  ip: string;
  apiKey: string;
  from: string;
}

function rateLimited(retryAfterSeconds: number): HttpsError {
  return new HttpsError('resource-exhausted', 'Too many code requests.', {
    reason: 'rate',
    retryAfterSeconds,
  });
}

/** Stores a fresh hashed code (rate limited) and emails it. */
export async function requestLoginCode(input: RequestInput): Promise<{ resendAfterSeconds: number }> {
  const email = normalizeEmail(input.email);
  if (!email) throw new HttpsError('invalid-argument', 'Invalid email.', { field: 'email' });
  const lang = normalizeLang(input.lang);

  const db = getFirestore();
  const codeRef = db.collection('loginCodes').doc(emailDocId(email));
  const limits = db.collection('loginLimits');
  const emailLimitRef = limits.doc(`email_${emailDocId(email)}`);
  const ipLimitRef = limits.doc(`ip_${sha256Hex(`ip:${input.ip}`)}`);
  const dayRef = limits.doc(`day_${utcDayKey(Date.now())}`);
  const code = generateCode();
  const salt = generateSalt();

  await db.runTransaction(async (tx) => {
    const [emailSnap, ipSnap, daySnap] = await Promise.all([
      tx.get(emailLimitRef),
      tx.get(ipLimitRef),
      tx.get(dayRef),
    ]);
    const now = Date.now();

    const emailDecision = decideSend((emailSnap.data()?.sendTimes as number[] | undefined) ?? [], now);
    if (!emailDecision.allowed) throw rateLimited(emailDecision.retryAfterSeconds);
    const ipDecision = decideWindow(
      (ipSnap.data()?.sendTimes as number[] | undefined) ?? [],
      now,
      HOUR_MS,
      MAX_SENDS_PER_IP_PER_HOUR,
    );
    if (!ipDecision.allowed) throw rateLimited(ipDecision.retryAfterSeconds);
    const count = (daySnap.data()?.count as number | undefined) ?? 0;
    const dayDecision = decideDailyCap(count, now, MAX_SENDS_PER_DAY);
    if (!dayDecision.allowed) throw rateLimited(dayDecision.retryAfterSeconds);

    tx.set(emailLimitRef, { sendTimes: emailDecision.sendTimes }, { merge: true });
    tx.set(ipLimitRef, { sendTimes: ipDecision.sendTimes, expireAt: Timestamp.fromMillis(now + 2 * HOUR_MS) });
    tx.set(dayRef, { count: count + 1, expireAt: Timestamp.fromMillis(now + 2 * DAY_MS) });
    tx.set(codeRef, {
      codeHash: hashCode(code, salt),
      salt,
      attempts: 0,
      lastSentAt: Timestamp.fromMillis(now),
      expiresAt: Timestamp.fromMillis(now + CODE_TTL_MS),
    });
  });

  try {
    await sendEmail(input.apiKey, input.from, email, buildLoginEmail(code, lang));
  } catch (e) {
    // Leave no usable code behind; the send still counted toward the limits.
    await codeRef.delete().catch(() => undefined);
    logger.error('Login email failed', {
      to: maskEmail(email),
      reason: e instanceof EmailSendError ? e.message : 'unexpected',
    });
    throw new HttpsError('internal', 'Could not send the email.');
  }
  logger.info('Login code sent', { to: maskEmail(email) });
  return { resendAfterSeconds: MIN_SEND_INTERVAL_MS / 1000 };
}
