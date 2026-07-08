# Phase 2 — Build & run on the physical iPhone

## Golden rule: regenerate before every build after adding files

Any time you add, rename, or move a `.swift` file, run `xcodegen generate` before
building. A file that exists on disk but isn't in the target makes `xcodebuild`
look **hung** for minutes (the Swift type-checker thrashes). It's not hung — the
project just doesn't know about the file.

```bash
export PATH="$HOME/.local/bin:$PATH"   # xcodegen lives in ~/.local/bin
cd <project-dir>
xcodegen generate
```

## Check the device is ready

```bash
xcrun devicectl list devices
# want: connected, and for the target iPhone:
xcrun devicectl device info details --device <UDID> \
  | grep -iE "developerModeStatus|tunnelState|pairingState|osVersionNumber"
# developerModeStatus: enabled, pairingState: paired, tunnelState: connected
```

Known device: iPhone UDID `00008030-000D642934E1802E`, Team `5978FBWL5U`.

## Build for device (the one-liner)

```bash
export PATH="$HOME/.local/bin:$PATH"
xcodebuild -project <AppName>.xcodeproj -scheme <AppName> -sdk iphoneos \
  -destination 'platform=iOS,id=<UDID>' \
  -derivedDataPath build -clonedSourcePackagesDirPath build-spm \
  -allowProvisioningUpdates CODE_SIGN_STYLE=Automatic build
```

- `-clonedSourcePackagesDirPath build-spm` keeps resolved SPM packages local and
  fast on rebuilds.
- `-allowProvisioningUpdates` lets Xcode register the App Group / provisioning
  automatically.

## Install & (re)install

```bash
# fresh install
xcrun devicectl device install app --device <UDID> \
  build/Build/Products/Debug-iphoneos/<AppName>.app

# uninstall first when you need to RESET first-launch state
# (this is how you make one-time permission prompts — ATT, notifications —
#  appear again; iOS only shows them once per install)
xcrun devicectl device uninstall app --device <UDID> com.<prefix>.<appname>
```

Reinstalling fresh is the reliable way to re-trigger the ATT and notification
prompts for a demo recording (see Phase 6).

## Simulator (for App Store screenshots)

Device screenshots are the wrong resolution for the store. Use a simulator sized
to the required screenshot dimensions instead — see
`references/04-app-store-connect.md`.

```bash
xcrun simctl list devices           # find/boot a sim
# build & run to a booted sim uses -sdk iphonesimulator and -destination 'id=<SIM_UDID>'
```

For simulator builds, ad-hoc signing is fine (so App Groups still work). A helper
`run.sh` in the repo that boots the sim + builds + installs saves time.

## The two-Macs certificate trap

Symptom (after doing signing work on a second Mac on the same Apple ID): device
builds on the first Mac fail with **"certificate revoked / private key not in
keychain"**. The second Mac minted a new Apple Development cert and revoked the
first's.

Fix on the machine that's now broken:
1. Xcode → Settings → Accounts → (your Apple ID) → **Manage Certificates**
2. Click **+** → **Apple Development** (mints a fresh cert whose private key lives
   in *this* keychain).
3. Because regenerating can reset Team to "None", open each target's Signing &
   Capabilities and set the **Team** so Xcode re-registers the App Group on the
   portal. (Pinning `DEVELOPMENT_TEAM` in `project.yml` prevents the recurrence.)

After that, the CLI build/install commands above work again.

## Debugging on device

- Console/crash logs: `xcrun devicectl device info` and the Console.app device
  logs. For crashes right at launch after adding ads, suspect the missing
  `GADApplicationIdentifier` (Phase 3).
- To verify what's installed / bundle version, check the built `.app`'s
  Info.plist or the archive Info.plist (Phase 5).
