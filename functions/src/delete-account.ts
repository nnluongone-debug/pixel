import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { emailDocId } from './crypto';

/**
 * Permanently deletes the caller's account: the `users/{uid}` tree (profile,
 * habits, check-ins), any pending login code, then the Auth user. Data goes
 * first so a failure never leaves orphaned data behind a deleted login.
 */
export async function deleteAccount(uid: string | undefined): Promise<{ deleted: true }> {
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');
  const db = getFirestore();
  const auth = getAuth();
  let email: string | undefined;
  try {
    email = (await auth.getUser(uid)).email;
  } catch (e) {
    if ((e as { code?: string }).code !== 'auth/user-not-found') throw e;
  }
  await db.recursiveDelete(db.collection('users').doc(uid));
  if (email) await db.collection('loginCodes').doc(emailDocId(email)).delete();
  try {
    await auth.deleteUser(uid);
  } catch (e) {
    if ((e as { code?: string }).code !== 'auth/user-not-found') throw e;
  }
  return { deleted: true };
}
