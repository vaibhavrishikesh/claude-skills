---
name: ship-ios-app
description: >-
  End-to-end playbook for building and shipping a brand-new iOS app entirely
  from the command line (XcodeGen + xcodebuild, no Xcode GUI for coding), all
  the way from a brand/identity system through App Store approval. Use this
  skill whenever the user wants to create a new iOS/iPhone app, start an app
  from scratch, set up an Xcode project without opening Xcode, build or install
  an app onto a physical iPhone from the terminal, add AdMob ads, prepare App
  Store Connect metadata or screenshots, submit to App Review, or fix an App
  Store rejection (especially "Guideline 2.1 - Information Needed", App Tracking
  Transparency prompts, or build/upload problems). Also use it when the user
  says things like "banate hain nayi app", "deploy kar de", "app store pe daal
  do", or references the Reechi or Soon apps. It encodes hard-won gotchas that
  are easy to burn hours on — reach for it even if the user only names one
  stage of the process.
---

# Ship an iOS app from the CLI

This is a battle-tested playbook for taking an iPhone app from **nothing** to
**live on the App Store**, driven from the terminal. It was distilled from
shipping two real apps (Reechi and Soon) and captures the specific traps that
cost hours the first time. The philosophy: **XcodeGen `project.yml` is the
single source of truth**, `xcodebuild`/`devicectl` do the work, and Xcode's GUI
is only opened for the one thing it's still needed for (uploading the archive).

## How to use this skill

Work in **phases** (below). Each phase has a short summary here and a detailed
reference file in `references/`. Read the reference file for the phase you're in
— don't try to hold all of it in your head at once. If the user is only asking
about one stage ("just fix the rejection", "just install it on my phone"), jump
straight to that phase.

Before doing anything destructive or irreversible (uninstalling the app,
deleting a submission, uploading a build, replying to Apple), tell the user what
you're about to do. Publishing actions (submitting for review, uploading) need
the user's go-ahead.

## The user's known values (reused across every app)

These are stable for this user — the same physical device and Apple developer
account are reused for each new app. Confirm they're still current, but you can
start from these:

- **Apple Team ID:** `5978FBWL5U` (Vaibhav Gupta)
- **Physical iPhone UDID:** `00008030-000D642934E1802E` — verify with
  `xcrun devicectl list devices`
- **XcodeGen** lives in `~/.local/bin`, so every shell that runs it needs
  `export PATH="$HOME/.local/bin:$PATH"` first.
- **Toolchain:** Apple requires the current-year SDK to upload. As of 2026 that
  means Xcode 26.x / iOS 26 SDK on macOS 26.x. An archive built with an old
  Xcode gets rejected at upload as "too old". Keep Xcode updated.
- The user prefers **calm, smooth UI/animations** over frantic/attention-seeking
  ones (a real correction from the Soon build).

## The phases

### Phase 1 — Brand & project setup
Pick the name, identity (icon, color palette, typography), bundle id, and scaffold
the XcodeGen project. This is where the versioning and signing traps live.
→ Read `references/01-brand-and-project.md`

### Phase 2 — Build & run on the physical iPhone
Generate the project, build for device, install with `devicectl`, and iterate.
Includes the two-Macs certificate-revocation trap and the "hung build = missing
file" trap.
→ Read `references/02-build-and-device.md`

### Phase 3 — AdMob ads (only if the app shows ads)
Google Mobile Ads via SPM, test vs real ad units, and the Info.plist trap that
crashes the app on launch if you get it wrong.
→ Read `references/03-admob-ads.md`

### Phase 4 — App Store Connect setup
Create the app record, fill metadata, capture screenshots that pass review, set
up App Privacy and the privacy policy, answer the IDFA question.
→ Read `references/04-app-store-connect.md`

### Phase 5 — Archive, upload & submit
Archive from the CLI, upload via Xcode Organizer, select the build, and submit
for review.
→ Read `references/05-app-review-and-gotchas.md` (also covers Phase 6)

### Phase 6 — Handle an App Review rejection
The most important reference. Guideline 2.1 "Information Needed", the App
Tracking Transparency prompt-timing bug, the screen-recording requirements, and
the small gotchas (lowercase `.mp4`, removed-submission recovery) that turn a
5-minute fix into an afternoon.
→ Read `references/05-app-review-and-gotchas.md`

## The five traps that cost the most time (memorize these)

Even before reading the phase files, these are the ones that bite hardest:

1. **Build number won't bump.** `CFBundleVersion` in the app's Info.plist must be
   the literal string `$(CURRENT_PROJECT_VERSION)` (and `CFBundleShortVersionString`
   = `$(MARKETING_VERSION)`). If it's a hardcoded number, bumping the build
   setting is silently ignored and App Store Connect rejects the "duplicate build".

2. **App crashes on launch after adding AdMob.** `GADApplicationIdentifier` must be
   a real Info.plist key via XcodeGen's `info:` block — it can't go through
   `INFOPLIST_KEY_*` (those only cover Apple's own keys). Missing it = immediate
   crash.

3. **"Hung" build that never finishes.** Almost always means you added a new
   `.swift` file but didn't run `xcodegen generate`, so the file isn't in the
   target and the type-checker thrashes. It's not hung — regenerate and rebuild.

4. **ATT (tracking) prompt never appears.** Requesting App Tracking Transparency
   too early (in `.task` before the app is active) or at the same time as the
   notification prompt makes iOS silently drop it. This caused a real Guideline
   2.1 rejection. Fix in `references/05-app-review-and-gotchas.md`.

5. **Second Mac revokes the first Mac's signing cert.** Two Macs on one Apple ID
   fight over the Apple Development certificate. Fix: mint a fresh cert in the
   current machine's keychain (Xcode → Settings → Accounts → Manage Certificates
   → +). Details in `references/02-build-and-device.md`.

## Reusable assets in this skill

- `references/app-review-notes-template.md` — the ready-to-paste App Review
  "Notes" block (the 7 points Apple asks for under Guideline 2.1). Fill in the
  device/OS line and app-specific details.
