# Launch kit — Habit Tracker - Pixel

Ready-to-use copy for the first 8 weeks on Google Play. Store link for posts
(tracked in Play Console → Acquisition → UTM):

```
https://play.google.com/store/apps/details?id=com.nnluong.pixelquest&referrer=utm_source%3D<channel>%26utm_medium%3Dpost
```
Replace `<channel>` with `reddit`, `facebook`, `tiktok`, `producthunt`…

---

## 1. ASO — store listing experiments

Run in Play Console → Grow → Store listing experiments, one variable at a
time, 50/50 split, at least 7 days each.

| # | Variable | Control | Variant |
|---|----------|---------|---------|
| 1 | Short description (vi) | Xây thói quen tốt từng viên gạch pixel. Giữ chuỗi, lên cấp, mở khóa giao diện! | Theo dõi thói quen kiểu game pixel: giữ chuỗi, nhắc nhở, lên cấp, mở khóa skin! (79) |
| 2 | Short description (en) | Build better habits one pixel brick at a time. Keep streaks, level up, unlock! | Daily habit tracker & routine planner. Stack pixel bricks, keep your streak 🧱 (77) |
| 3 | First screenshot | current | Full, colorful matrix (Neon/Nebula skin) + caption "Mỗi thói quen = 1 viên gạch" |
| 4 | Icon | current | Icon with a visible streak flame / brick stack |

App title options (30 max; changing the title resets nothing but test on a
custom listing first): `Pixel Habit Tracker & Streaks` (29),
`Habit Tracker: Pixel Streaks` (28).

### Preview video (15–30 s, portrait, no talking needed)
1. 0–3 s: empty matrix → tap a habit → brick drops with sound (hook).
2. 3–10 s: time-lapse of a week filling the matrix.
3. 10–18 s: level-up + badge popup + theme unlock (Cyberpunk → Nebula).
4. 18–25 s: widget on home screen, reminder notification.
5. End card: app name + "Free · No ads".

---

## 2. Review replies (reply to every review within 48 h)

- **5★:** Cảm ơn bạn! Chúc chuỗi gạch của bạn ngày càng cao 🧱 Có ý tưởng gì cứ gửi qua Cài đặt → Góp ý nhé.
- **Bug / low rating:** Xin lỗi bạn vì sự cố. Bạn có thể gửi chi tiết (dòng máy, bước gặp lỗi) qua Cài đặt → Góp ý & hỗ trợ để mình sửa ngay trong bản tới không?
- **EN 5★:** Thanks a lot! Keep that streak going 🧱 Ideas are always welcome via Config → Feedback.
- **EN bug:** Sorry about that! Could you send the details via Config → Feedback & support? I'll fix it in the next update.

After shipping a fix, reply again saying it is fixed — users often update
their rating.

---

## 3. Community posts

### Reddit (r/SideProject, r/androidapps — check each sub's self-promo day)
**Title:** I made a habit tracker where every completed habit drops a pixel brick into a Tetris-like matrix

**Body:**
> Hi! Solo dev here. I kept quitting habit apps after a week, so I built one
> that feels like a tiny arcade game: finish a habit → a neon brick drops into
> your matrix, rows clear, you level up and unlock skins (Game Boy, Cyberpunk,
> Nebula…) with their own sound packs.
>
> - No ads, works offline, no account needed
> - Reminders can repeat (e.g. drink water every hour 8–22h)
> - English + Vietnamese
>
> It's free on Google Play: <link>. I'd love brutal feedback — what would make
> you open it every day?

Reply to every comment in the first 2 hours.

### Facebook groups VN (năng suất, tự học, kỷ luật bản thân, Android)
> Mình là dev indie, vừa ra mắt app **Habit Tracker - Pixel** 🧱
>
> Ý tưởng: mỗi lần hoàn thành một thói quen (uống nước, đọc sách, chạy bộ…)
> là một viên gạch pixel rơi xuống ma trận như chơi xếp gạch. Giữ chuỗi để
> lên cấp, mở khóa giao diện Game Boy, Cyberpunk, Nebula…
>
> ✅ Không quảng cáo · ✅ Không cần tài khoản · ✅ Nhắc uống nước mỗi giờ
>
> Mọi người dùng thử và góp ý thật lòng giúp mình nhé, mình sửa nhanh lắm 🙏
> 👉 <link>

Attach the shared matrix image (Home → share button) instead of a plain
screenshot — it looks native to the feed.

### Product Hunt / AlternativeTo / Indie Hackers
Tagline: *Build habits one pixel brick at a time.* Add the app as an
alternative to Habitica, Loop Habit Tracker and HabitNow on AlternativeTo.

---

## 4. Short video ideas (TikTok / Reels / Shorts, 3–5 per week)

1. **ASMR brick drop** — 10 s of check-ins with sound, text: "the most satisfying habit app".
2. **30-day matrix** — screen recording of the matrix filling day by day.
3. **Skin tour** — same week in Game Boy → Neon → Cyberpunk → Gold → Nebula.
4. **"POV: you finally kept a habit for 7 days"** — badge unlock moment.
5. **Dev story** — "I built a habit app as a solo dev, here's day 1 vs day 30".

Hook in the first second, captions on screen, link in bio with
`utm_source=tiktok`.

---

## 5. New Year campaign (peak season)

| When | Action |
|------|--------|
| Dec 1–10 | Ship this growth update; new screenshots with "Mục tiêu 2027" caption |
| Dec 10–25 | Daily short videos; reach out to 10–20 small KOC (5k–50k, study/gym/productivity) |
| Dec 26 – Jan 10 | Peak: post in groups, Reddit, PH launch; reply to all reviews daily |
| Jan 10–31 | "Still going?" content for people who started on Jan 1 |
| Late Jan – early Feb | Tết (Feb 6, 2027) angle: "Thói quen mới cho năm Đinh Mùi" |

Optional: Google App Campaign only after D7 retention ≥ 15 %, starting at
100–200k VND/day, optimizing for `habit_created`.

---

## 6. Weekly metrics (Firebase Analytics + Play Console)

| Metric | Where | Healthy target |
|--------|-------|----------------|
| Store listing conversion | Play Console → Store performance | ≥ 25 % |
| Onboarding completion | `onboarding_complete` / `first_open` | ≥ 70 % |
| Activation | `habit_created` / `first_open` | ≥ 60 % |
| First brick | users with `habit_completed` on day 0 | ≥ 40 % |
| D1 / D7 / D30 retention | Firebase → Retention | 35 % / 15 % / 7 % |
| Shares | `share` events per 100 actives | rising |
| Rating | Play Console → Ratings | ≥ 4.5 |

Mark `habit_created` and `habit_completed` as **key events** in the Firebase
console so they show in reports and can be imported into Google Ads later.
