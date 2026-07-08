# Phase 1 — Brand & project setup

## Brand / identity system

Before any code, lock the identity. A consistent system makes the whole app feel
designed rather than assembled.

- **Name & concept.** Short, memorable, one clear job (Reechi, Soon). Decide the
  one-sentence pitch — it's reused verbatim in the App Store subtitle, the review
  notes, and the marketing.
- **Bundle id.** `com.<yourprefix>.<appname>` (e.g. `com.tranquilwaters.soon`).
  The prefix is set once as `bundleIdPrefix` in `project.yml`. Widgets/extensions
  append a suffix: `com.tranquilwaters.soon.widget`.
- **Color palette.** Define a small set of gradients + accent colors in one
  `Theme.swift` (with a `Color(hex:)` helper and a `Palette` of gradients). Every
  screen pulls from it — never hardcode colors inline. Keep SwiftUI color arrays
  as stored `let [Color]` values, not big inline literals (see the type-checker
  note below).
- **Typography.** Pick a type scale (title/headline/subheadline/caption) and use
  system fonts unless there's a strong reason not to — custom fonts add bundling
  and licensing overhead.
- **App icon.** Design at 1024×1024, drop into the asset catalog
  (`Assets.xcassets/AppIcon.appiconset`) or use Apple's **Icon Composer**. Set
  `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon` in the target settings.

## Scaffold with XcodeGen

`project.yml` is the source of truth. The generated `.xcodeproj` is disposable —
**gitignore it** and regenerate anytime. This keeps the repo clean and diffable
and lets two machines share the project without merge hell.

Typical source layout:
```
Sources/
  <App>App.swift            # @main entry
  Theme.swift
  Models/
  Store/                    # persistence (UserDefaults + Codable, or App Group)
  Screens/                  # one file per screen
<AppName>Widget/            # if there's a widget/Live Activity
```

### project.yml template (app + optional widget)

This is the exact shape that works, with the traps already handled. Adapt names.

```yaml
name: <AppName>
options:
  bundleIdPrefix: com.<yourprefix>
  deploymentTarget:
    iOS: "17.0"
  createIntermediateGroups: true
settings:
  base:
    SWIFT_VERSION: "5.0"
    CODE_SIGN_STYLE: Automatic
    DEVELOPMENT_TEAM: "5978FBWL5U"   # pin it — else `xcodegen generate` resets Team to None
    MARKETING_VERSION: "1.0"
    CURRENT_PROJECT_VERSION: "1"     # bump this for each new build upload
packages:
  # only if using ads — see references/03-admob-ads.md
  GoogleMobileAds:
    url: https://github.com/googleads/swift-package-manager-google-mobile-ads
    from: "11.0.0"
targets:
  <AppName>:
    type: application
    platform: iOS
    sources:
      - path: Sources
    dependencies:
      - target: <AppName>Widget   # only if there's a widget
        embed: true
      - package: GoogleMobileAds   # only if ads
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.<yourprefix>.<appname>
        GENERATE_INFOPLIST_FILE: "NO"
        ASSETCATALOG_COMPILER_APPICON_NAME: "AppIcon"
        TARGETED_DEVICE_FAMILY: "1"   # iPhone only
    info:
      path: <AppName>/Info.plist
      properties:
        CFBundleDisplayName: <AppName>
        CFBundleShortVersionString: "$(MARKETING_VERSION)"      # ← TRAP #1
        CFBundleVersion: "$(CURRENT_PROJECT_VERSION)"           # ← TRAP #1
        UILaunchScreen: {}
        UIApplicationSupportsIndirectInputEvents: true
        UISupportedInterfaceOrientations:
          - UIInterfaceOrientationPortrait
        ITSAppUsesNonExemptEncryption: false
        # --- add these only if the feature is used ---
        NSSupportsLiveActivities: true                          # Live Activities
        GADApplicationIdentifier: ca-app-pub-XXXX~YYYY          # AdMob (TRAP #2)
        NSUserTrackingUsageDescription: Used to show you more relevant ads.
    entitlements:                     # only if widget/Live Activity shares data
      path: <AppName>.entitlements
      properties:
        com.apple.security.application-groups:
          - group.com.<yourprefix>.<appname>

  <AppName>Widget:                    # only if there's a widget
    type: app-extension
    platform: iOS
    sources:
      - path: <AppName>Widget
      - path: Sources/Models/<SharedModel>.swift
      - path: Sources/Theme.swift
      # ...share exactly the source files the widget needs
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.<yourprefix>.<appname>.widget
        INFOPLIST_FILE: <AppName>Widget/Info.plist
        GENERATE_INFOPLIST_FILE: "NO"
        TARGETED_DEVICE_FAMILY: "1"
        SKIP_INSTALL: "YES"
    entitlements:
      path: <AppName>Widget/<AppName>Widget.entitlements
      properties:
        com.apple.security.application-groups:
          - group.com.<yourprefix>.<appname>
```

### Why each trap-line matters

- **`CFBundleShortVersionString` / `CFBundleVersion` as `$()` variables.** If you
  write a literal `1` instead, `xcodegen generate` bakes `1` into the Info.plist
  and bumping `CURRENT_PROJECT_VERSION` does nothing — App Store Connect then
  rejects the upload as a duplicate build number. Always reference the build
  settings so a version bump actually flows through.
- **`DEVELOPMENT_TEAM` pinned in `settings.base`.** Without it, every regenerate
  resets each target's Team to "None", which breaks App Group registration and
  device signing.
- **`GENERATE_INFOPLIST_FILE: NO` + explicit `info:` block.** You need a real
  Info.plist file because some keys (notably `GADApplicationIdentifier`) can't be
  injected via `INFOPLIST_KEY_*`.

## App storage

For a simple offline app, `UserDefaults` + `Codable` in a small `Store` class is
plenty (no backend, no login → far fewer review headaches). If a widget or Live
Activity needs the same data, store it in an **App Group** container
(`group.com.<prefix>.<app>`) via a shared `SharedData` helper so the app, widget,
and Live Activity all read/write the same place.

## SwiftUI type-checker survival

Big inline SwiftUI expressions (giant ternaries, nested literals, long modifier
chains inside `ForEach`) blow up type inference and cause multi-minute "hung"
builds. Keep expressions small: extract row views into their own `View` structs,
store color arrays as `let [Color]`, and break complex bodies into computed
subviews.

## First commit

Init git, add a `.gitignore` that excludes `*.xcodeproj`, `build/`, `build-spm/`,
and DerivedData. Public repo is fine — none of the AdMob IDs or Team/device IDs
are secrets. Do **not** commit real API keys or credentials.
