# Phase 4 — App Store Connect setup

Create the app record and fill everything the review needs. Most of this is done
in the browser (appstoreconnect.apple.com) — the user drives the clicks; you
prepare the exact text/values and guide.

## Create the app record

Apps → **+** → New App. Pick platform iOS, the name, primary language, bundle id
(must match `PRODUCT_BUNDLE_IDENTIFIER`), and an SKU. Note the numeric **app id**
in the URL — you'll reference it (e.g. Soon = 6785822803).

## Metadata checklist (version page)

- **Name / Subtitle / Promotional text / Description / Keywords** — reuse the
  one-sentence pitch and expand. Keywords are comma-separated, ~100 chars.
- **Support URL** and **Marketing URL** (a GitHub Pages page is fine).
- **Category** (e.g. Utilities), **Content Rights** (No, unless you license
  third-party content), **Age Rating** (fill the questionnaire → usually 4+).
- **Price** (Free) and availability.
- **Copyright** e.g. "2026 <Name>".

## Screenshots (they must show the app IN USE)

Requirement: screenshots must show the actual app in use — **not** the launch
screen, title art, or a login screen (Guideline 2.3.3). The store uses the first
3 on the install sheet.

- Required size: **1242 × 2688** (6.5" display). Capture from a matching
  simulator (e.g. an "iPhone 11 Pro Max"-class sim) so the resolution is exact.
- To shoot specific screens (Add / Detail / a celebratory moment) without wiring
  up navigation, temporarily point the app's root view at that screen, build to
  the sim, screenshot, then revert. Keep these throwaway edits out of commits.
- Save them somewhere obvious (e.g. `~/Desktop/<app>-appstore-screens/`).

## App Privacy (must be published before review)

Fill the App Privacy questionnaire honestly. For an offline app with AdMob:
- Data used to track you: **IDFA** (via AdMob) — "Advertising Data".
- Data linked/not linked as appropriate; the countdowns/user content stay
  on-device (not collected).
Publish it. Also host a **Privacy Policy** (GitHub Pages HTML works:
`https://<user>.github.io/<repo>/privacy.html`) and paste its URL.

## IDFA question (because of AdMob)

At submission you'll be asked about the Advertising Identifier. Answer **Yes** and
tick **"Serve advertisements within the app."** Nothing else applies for a simple
banner-ads app.

## Build numbers

Each uploaded build needs a **unique** `CURRENT_PROJECT_VERSION` under the same
marketing version. Bump it in `project.yml` before archiving a replacement build.
(If bumping seems to do nothing, you hit Trap #1 — see Phase 1.)
