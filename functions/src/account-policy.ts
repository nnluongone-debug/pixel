export interface ExistingUser {
  emailVerified: boolean;
  providerIds: readonly string[];
}

export type AccountAction = 'create' | 'reuse' | 'recreate';

/**
 * A pre-existing account is only reused when it is verified and has no
 * sign-in providers (i.e. it was created by this flow). Anything else could
 * have been pre-registered by someone who does not own the mailbox, so it is
 * replaced.
 */
export function decideAccountAction(user: ExistingUser | null): AccountAction {
  if (!user) return 'create';
  const clean = user.emailVerified && user.providerIds.every((id) => id === 'custom');
  return clean ? 'reuse' : 'recreate';
}
