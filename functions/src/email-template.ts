import { CODE_TTL_MS } from './rate-limit';
import type { Lang } from './validation';

export interface LoginEmail {
  subject: string;
  html: string;
  text: string;
}

const MINUTES = CODE_TTL_MS / 60_000;

const COPY = {
  en: {
    subject: (code: string) => `${code} is your Habit Tracker - Pixel code`,
    intro: 'Your sign-in code',
    expires: `This code expires in ${MINUTES} minutes.`,
    ignore: "If you didn't request this, you can safely ignore this email.",
  },
  vi: {
    subject: (code: string) => `${code} là mã đăng nhập Habit Tracker - Pixel của bạn`,
    intro: 'Mã đăng nhập của bạn',
    expires: `Mã có hiệu lực trong ${MINUTES} phút.`,
    ignore: 'Nếu bạn không yêu cầu mã này, hãy bỏ qua email này.',
  },
} as const;

/** `code` must be 6 digits (validated upstream), so it is safe to inline in HTML. */
export function buildLoginEmail(code: string, lang: Lang): LoginEmail {
  const c = COPY[lang];
  const html = `<!doctype html>
<html lang="${lang}"><body style="margin:0;padding:24px;background:#0b0b14;font-family:'Courier New',monospace;color:#e6e6f0;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0"><tr><td align="center">
<table role="presentation" width="420" cellpadding="0" cellspacing="0" style="max-width:420px;background:#14142a;border:2px solid #39ff14;">
<tr><td style="padding:24px;text-align:center;">
<div style="font-size:14px;letter-spacing:4px;color:#39ff14;">HABIT TRACKER · PIXEL</div>
<div style="margin-top:16px;font-size:14px;color:#a8a8c0;">${c.intro}</div>
<div style="margin:16px 0;font-size:40px;font-weight:bold;letter-spacing:10px;color:#00f0ff;">${code}</div>
<div style="font-size:13px;color:#e6e6f0;">${c.expires}</div>
<div style="margin-top:16px;font-size:12px;color:#7a7a96;">${c.ignore}</div>
</td></tr></table>
</td></tr></table>
</body></html>`;
  const text = `HABIT TRACKER - PIXEL\n\n${c.intro}: ${code}\n\n${c.expires}\n${c.ignore}\n`;
  return { subject: c.subject(code), html, text };
}
