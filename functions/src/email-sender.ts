import type { LoginEmail } from './email-template';

const RESEND_URL = 'https://api.resend.com/emails';
const TIMEOUT_MS = 10_000;

export class EmailSendError extends Error {}

/** Sends via the Resend REST API. Throws [EmailSendError] on any failure. */
export async function sendEmail(
  apiKey: string,
  from: string,
  to: string,
  email: LoginEmail,
): Promise<void> {
  let response: Response;
  try {
    response = await fetch(RESEND_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from,
        to: [to],
        subject: email.subject,
        html: email.html,
        text: email.text,
      }),
      signal: AbortSignal.timeout(TIMEOUT_MS),
    });
  } catch (e) {
    throw new EmailSendError(`Resend request failed: ${(e as Error).name}`);
  }
  if (!response.ok) {
    throw new EmailSendError(`Resend responded with ${response.status}`);
  }
}
