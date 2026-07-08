# App Review "Notes" template (Guideline 2.1 – Information Needed)

Paste this into **App Store Connect → App Review Information → Notes** (and/or the
Reply to App Review box). It answers the 7 points Apple asks for. Replace the
`<…>` placeholders and trim any lines that don't apply to the app. Keep it under
the 4,000-character limit.

Attach the demo screen recording separately (App Review Information → Attachment,
lowercase `.mp4` — see `05-app-review-and-gotchas.md`).

---

About <AppName>

<AppName> is <one-sentence pitch>. <One or two lines on what the user does and
where the value shows up — e.g. home list, widgets, Live Activity, reminders.>

1. App flow & sensitive prompts: The app has <no account, no login, no purchases
or subscriptions, and no user-generated content — edit to match reality>. All
data is stored only on the device — there is no server. The app shows these
optional system prompts: (a) a notification permission prompt for reminders, and
(b) an App Tracking Transparency prompt for personalized ads via Google AdMob.
The app is fully functional if either is declined.

2. Devices/OS tested: iPhone <MODEL, e.g. iPhone 11>, iOS <VERSION, e.g. 18.7.8>.

3. Purpose & audience: <who it's for and the problem it solves>.

4. Setup / access: No setup or credentials needed. <Launch → the core 2–3 step
flow.> <If there is a login, give demo credentials here.>

5. External services: Google AdMob (Google Mobile Ads SDK) for banner ads only.
No other backend, analytics, data provider, authentication or payment service —
the app has no server of its own. <Edit if the app uses others.>

6. Regional differences: None. The app behaves identically in all regions.

7. Regulated industry / protected material: Not applicable. No regulated content
and no third-party protected material.

A screen recording demonstrating the full flow (launch, the App Tracking
Transparency prompt, the notification prompt, <the core action>, and the live
result) is attached.

---

## Notes
- If the app has **no ads**, delete the ATT / AdMob mentions in points 1 and 5 —
  fewer sensitive prompts means an easier review.
- The device/OS line (point 2) is the one people forget to fill — an unfilled
  `<MODEL>` placeholder looks sloppy to the reviewer.
- Reuse this same structure for future apps; only points 3–5 really change per
  app.
