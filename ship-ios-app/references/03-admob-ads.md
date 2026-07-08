# Phase 3 — AdMob ads

Only do this if the app monetizes with ads. Ads are why the App Tracking
Transparency prompt exists, which is what drags you into the Guideline 2.1 /
privacy review dance — so if the app doesn't need ads, skipping this whole phase
makes review dramatically easier.

## Add the SDK via SPM

In `project.yml`:
```yaml
packages:
  GoogleMobileAds:
    url: https://github.com/googleads/swift-package-manager-google-mobile-ads
    from: "11.0.0"     # resolves to 11.13.x; compiles fine on Xcode 26
```
Add `- package: GoogleMobileAds` to the app target's `dependencies`. Use the
**GAD-prefixed** API (e.g. `GADMobileAds`, `GADBannerView`).

## Info.plist keys (TRAP: app crashes on launch without these)

Put these under the app target's `info:` `properties:` (real Info.plist keys —
they cannot be injected via `INFOPLIST_KEY_*`):

```yaml
GADApplicationIdentifier: ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
NSUserTrackingUsageDescription: Used to show you more relevant ads.
```

If `GADApplicationIdentifier` is missing or wrong, the app **crashes immediately
on launch**. This is the #2 time-sink trap.

The AdMob **App ID** (`~`-form) and **ad unit IDs** (`/`-form) are public — safe
to commit and to keep in code. They are not secrets.

## Start the SDK + test vs real ad units

Start the SDK once at launch:
```swift
GADMobileAds.sharedInstance().start(completionHandler: nil)
```

Use Google's **test** ad units in DEBUG and your **real** units in release, so you
never accidentally click your own live ads (which can get the account flagged):
```swift
#if DEBUG
static let bannerUnit = "ca-app-pub-3940256099942544/2934735716" // Google test banner
#else
static let bannerUnit = "ca-app-pub-XXXX/YYYY"                    // your real banner
#endif
```

Known values for this account (public):
- App ID `ca-app-pub-4765907187067298~5073486989`
- Banner unit `ca-app-pub-4765907187067298/4530561501`

## App Tracking Transparency — request it CORRECTLY

This is the single most important detail in the whole ads flow, because getting
it wrong causes a silent failure **and** an App Store rejection. See the dedicated
section in `references/05-app-review-and-gotchas.md`. Short version: request ATT
only after the app is active, await the answer, *then* request notifications —
never fire both prompts at once and never call it in `.task` before the scene is
active.

## Answer the IDFA question at submission

Because you use AdMob, in App Store Connect you must declare IDFA use: answer
**Yes** to "Does this app use the Advertising Identifier (IDFA)?" and check
**"Serve advertisements within the app."** (See Phase 4.)

## dSYM upload warnings are harmless

When you upload, you'll see "Upload Symbols Failed" warnings for
`GoogleMobileAds` / `UserMessagingPlatform` dSYMs. These are expected for
precompiled third-party frameworks and do not block the upload — ignore them.
