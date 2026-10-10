import { getAuth } from 'firebase-admin/auth';
import { decideAccountAction } from './account-policy';

/** Returns the uid of a verified, trustworthy account for [email]. */
export async function ensureVerifiedUid(email: string): Promise<string> {
  const auth = getAuth();
  let user = null;
  try {
    user = await auth.getUserByEmail(email);
  } catch (e) {
    if ((e as { code?: string }).code !== 'auth/user-not-found') throw e;
  }
  const action = decideAccountAction(
    user && { emailVerified: user.emailVerified, providerIds: user.providerData.map((p) => p.providerId) },
  );
  if (action === 'reuse' && user) return user.uid;
  if (action === 'recreate' && user) await auth.deleteUser(user.uid);
  return (await auth.createUser({ email, emailVerified: true })).uid;
}
