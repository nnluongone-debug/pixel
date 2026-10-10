# Phase 6 — Pro purchase gating

**Priority:** later · **Status:** blocked

## Blockers (owner actions)
- Apple Developer Program membership ($99/yr) — the current free personal
  team cannot sell in-app purchases or ship to the App Store.
- Google Play Console account ($25 one-time) + app listing.
- Store products: one non-consumable "Pixel Quest Pro" (or subscription).

## Plan once unblocked
- `in_app_purchase` client; purchase + restore in the Locker.
- Cloud Function `validatePurchase` (App Store Server API / Play Developer
  API) writes `users/{uid}.entitlements.pro = true` (server-only field in rules).
- `hasProProvider` from Firestore; Pro unlocks Pure Gold immediately (and any
  future Pro-only items); guests must sign in to purchase.
- Tests with sandbox accounts; refund/revoke handling.
