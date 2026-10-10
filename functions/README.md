# Pixel Quest Cloud Functions

Passwordless email-code sign-in (region `asia-southeast1`, Node 22).

- `requestLoginCode({email, lang})` -> `{resendAfterSeconds}`: stores a salted hash in `loginCodes/{sha256(email)}` and emails a 6-digit code via Resend.
- `verifyLoginCode({email, code})` -> `{token}`: checks the code (5 attempts, 10 min expiry) and returns a Firebase custom token.

> **Warning: real users need a verified sending domain.** The default `RESEND_FROM`
> (`onboarding@resend.dev`) only delivers to the Resend account owner's own address.
> Verify a domain in Resend and set `RESEND_FROM` before releasing.

Abuse limits: 60 s / 5 per hour per email; 10 sends per hour per IP; 90 sends per day globally;
5 wrong guesses per code and 10 per email per 24 h (new codes do not reset it). Counters live in
`loginLimits` (no client access); `loginLimits.expireAt` and `loginCodes.expiresAt` have TTL policies.
Sign-in never reuses an unverified or provider-linked account: it is deleted and recreated.

Next step: enable App Check (`enforceAppCheck: true` on both callables) once the client sends App Check tokens.

Cloud Functions require the **Blaze** (pay-as-you-go) plan.

## Setup

```bash
cd functions && npm install
firebase functions:secrets:set RESEND_API_KEY      # Resend API key
```

Optional sender override (param `RESEND_FROM`, default `Pixel Quest <onboarding@resend.dev>`): set it in
`functions/.env.habitpixel-309ee` as `RESEND_FROM="Pixel Quest <login@your-domain.com>"` (domain must be verified in Resend; the default sender can only mail the Resend account owner).

## TTL for expired codes

`firestore.indexes.json` declares TTL policies on `loginCodes.expiresAt` and `loginLimits.expireAt`, applied by the Firestore deploy.
Manual alternative:

```bash
gcloud firestore fields ttls update expiresAt --collection-group=loginCodes --enable-ttl --project=habitpixel-309ee
```

## Deploy

```bash
firebase deploy --only functions,firestore
```

## Dev

```bash
npm run build   # tsc -> lib/
npm test        # vitest (pure logic)
```
