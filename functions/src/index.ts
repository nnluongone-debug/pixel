import { initializeApp } from 'firebase-admin/app';
import { onCall } from 'firebase-functions/v2/https';
import { defineSecret, defineString } from 'firebase-functions/params';
import { requestLoginCode as handleRequest } from './request-login-code';
import { verifyLoginCode as handleVerify } from './verify-login-code';
import { deleteAccount as handleDelete } from './delete-account';

initializeApp();

const RESEND_API_KEY = defineSecret('RESEND_API_KEY');
const RESEND_FROM = defineString('RESEND_FROM', {
  default: 'Habit Tracker - Pixel <onboarding@resend.dev>',
});

const REGION = 'asia-southeast1';

export const requestLoginCode = onCall(
  { region: REGION, secrets: [RESEND_API_KEY], maxInstances: 10 },
  (req) =>
    handleRequest({
      email: req.data?.email,
      lang: req.data?.lang,
      ip: req.rawRequest.ip ?? 'unknown',
      apiKey: RESEND_API_KEY.value(),
      from: RESEND_FROM.value(),
    }),
);

export const verifyLoginCode = onCall(
  { region: REGION, maxInstances: 10 },
  (req) => handleVerify(req.data?.email, req.data?.code),
);

export const deleteAccount = onCall(
  { region: REGION, maxInstances: 10 },
  (req) => handleDelete(req.auth?.uid),
);
