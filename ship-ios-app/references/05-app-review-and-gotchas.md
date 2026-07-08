# Phase 5 & 6 — Archive, upload, submit, and survive App Review

## Phase 5 — Archive, upload, submit

### 1. Bump the build number

In `project.yml`, increase `CURRENT_PROJECT_VERSION` (e.g. `"2"` → `"3"`) for any
replacement build. Then `xcodegen generate`. (If the archive still shows the old
number, you hit Trap #1 — the Info.plist must reference `$(CURRENT_PROJECT_VERSION)`.)

### 2. Archive from the CLI (Release)

```bash
export PATH="$HOME/.local/bin:$PATH"
xcodegen generate
xcodebuild -project <AppName>.xcodeproj -scheme <AppName> \
  -sdk iphoneos -destination 'generic/platform=iOS' \
  -archivePath build/<AppName>.xcarchive \
  -clonedSourcePackagesDirPath build-spm \
  -allowProvisioningUpdates CODE_SIGN_STYLE=Automatic archive

# verify the build number that actually got baked in:
/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleVersion" \
  build/<AppName>.xcarchive/Info.plist
/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleShortVersionString" \
  build/<AppName>.xcarchive/Info.plist
```

### 3. Upload via Xcode Organizer (the one GUI step)

There's no App Store Connect API key set up on this machine, so upload through
Xcode's Organizer:

```bash
# put the archive where Organizer lists it, then open it:
mkdir -p ~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)
cp -R build/<AppName>.xcarchive \
  ~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/<AppName>.xcarchive
open ~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/<AppName>.xcarchive
```
In Organizer: select the archive → **Distribute App** → **App Store Connect** →
**Upload** → keep automatic signing → **Upload**. Wait for "Uploaded to Apple".
The dSYM warnings for GoogleMobileAds/UserMessagingPlatform are harmless.

(Xcode is a "click-tier" app for computer-use — you can click its buttons but not
type into it. The Distribute flow is all clicks, so it's drivable; but the user
can also just click through it.)

### 4. Wait for processing, then submit

The build takes ~5–15 min to process before it's selectable. Then on the version
page: **Build** section → select the new build → fill **App Review Information**
→ **Add for Review** / **Resubmit to App Review**.

## Phase 6 — Handle a rejection

Don't panic — most first-submission rejections are **Guideline 2.1 – Information
Needed**, which is the mildest outcome: Apple isn't saying the app is broken,
they want a demo recording + written info to understand it. (The category label
may read "2.1.0 Performance: App Completeness" — read the actual **message from
Apple** in the submission to know what they really want. Expand the collapsed
"Apple" message row under **Messages**.)

### What Apple asks for under 2.1 Information Needed

1. A **screen recording on a physical device**, starting from app launch, showing
   the core flow — and, critically, **any prompt requesting sensitive access
   (App Tracking Transparency, notifications, location, camera…)**.
2. Device models + OS tested.
3. Purpose & target audience.
4. Setup/access instructions (+ demo login if the app has one).
5. External services used.
6. Regional differences.
7. Regulated-industry / protected-material note.

The ready-to-paste answer for points 1–7 is in
`references/app-review-notes-template.md`. Fill in the device/OS line.

### THE ATT PROMPT-TIMING BUG (this caused the real rejection)

If the app uses AdMob it declares ATT usage, so Apple expects to *see* the ATT
prompt. But a naive implementation makes the prompt **never appear** — on the
reviewer's device or in your recording — which fails the review.

Broken code (looks reasonable, silently fails):
```swift
.task {
    ATTrackingManager.requestTrackingAuthorization { _ in }   // too early + races
    await NotificationManager.requestAuthorizationIfNeeded()
}
```
Two bugs: (a) `.task` runs before the scene is reliably `.active`, and iOS
silently drops an ATT request made before active; (b) firing the ATT and
notification prompts together — iOS only presents one system prompt at a time, so
one gets dropped.

Correct implementation — wait for active, request ATT and **await the answer**,
then request notifications:
```swift
import SwiftUI
import UIKit
import AppTrackingTransparency

// inside the App's WindowGroup root:
.task { await requestPermissions() }

@MainActor
private func requestPermissions() async {
    while UIApplication.shared.applicationState != .active {
        try? await Task.sleep(nanoseconds: 150_000_000)
    }
    try? await Task.sleep(nanoseconds: 400_000_000)   // let the window become key
    if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
        await withCheckedContinuation { cont in
            ATTrackingManager.requestTrackingAuthorization { _ in cont.resume() }
        }
    }
    await NotificationManager.requestAuthorizationIfNeeded()   // notifications AFTER
}
```
This is a genuine product bug, not just a review trick: on the broken version the
ATT prompt never shows, so personalized ads never work for any real user either.
Ship the fix as a new build.

Also confirm on the test phone: **Settings → Privacy & Security → Tracking →
"Allow Apps to Request to Track"** is **ON**. If it's off, iOS blocks every app's
ATT prompt regardless of code — a fresh reinstall with the toggle on is needed to
see the prompt.

### Recording the demo (on the physical iPhone)

The prompts only appear on first launch, so **uninstall + reinstall fresh** right
before recording (Phase 2). Record with the phone's own screen recorder
(simplest), not the Mac:

- Add the recorder if missing: on iOS 18 you add it **from inside Control Centre**
  (swipe down from top-right → **+** / long-press → **Add a Control** → search
  "Screen Recording"), *not* from Settings.
- Start recording → open the app → **ATT prompt (Allow)** → **notification prompt
  (Allow)** → create the core item → open it → stop. ~30–60s is enough.

Verify the recording actually contains the ATT prompt before submitting — extract
frames with `ffmpeg` and eyeball them:
```bash
ffmpeg -t 12 -i "<video>" -vf "fps=1.5,scale=300:-1" /tmp/f%02d.png
```

### Attaching the recording — two small but costly gotchas

- **Lowercase `.mp4` only.** The App Store Connect attachment field rejects an
  UPPERCASE `.MP4` extension with a misleading "file type isn't supported" error,
  even though it lists mp4 as allowed. Copy the file to a lowercase extension:
  `cp "ScreenRecording ....MP4" ~/Downloads/review-recording.mp4`.
- **Where to attach:** on a fresh submission it goes in **App Review Information →
  Attachment → Choose File**. On a still-active rejected submission you'd instead
  use **Reply to App Review → Attach File**. Same video either way.

### Removed-submission recovery

If the rejected submission gets **Removed** / cancelled, the version drops back to
**"1.0 Prepare for Submission"** — this is fine, not broken. You now do a clean
**Add for Review** (a fresh submission) instead of replying to the old thread.
Put the notes in App Review Information → Notes, attach the recording there, pick
the new build, and submit.

### "Latest OS" note

Apple asks for the recording on "the latest operating system." If the test iPhone
is on an older-but-supported iOS (e.g. an iPhone 11 on iOS 18.x while 26.x is
current), that's a minor risk — a physical-device recording is the key
requirement and usually accepted. Don't force a risky OS update just for this.

## After approval

- If set to **automatic release**, it goes live after approval; verify on the
  store. If manual, release it.
- The **share-as-image** feature (if the app has one) is the content engine for
  marketing — before/after reels of the app in use.
- AdMob earnings require completing payee/tax/bank details in the AdMob console
  (the user does this — never enter their financial details for them).
