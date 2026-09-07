# AGENTS.md — QuickAirDrop

## What this is

macOS menu bar app (Swift 5.9, AppKit + SwiftUI). No dock icon (`LSUIElement: true`). Entry point: `QuickAirDrop/Sources/App/main.swift` — manually creates `NSApplication`, no `@main`.

## Build workflow

```bash
brew install xcodegen   # one-time
xcodegen generate       # regenerates .xcodeproj + Generated/App-Info.plist
open QuickAirDrop.xcodeproj
# or headless:
xcodebuild build -scheme QuickAirDrop -configuration Release CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

**`xcodegen generate` is required before every build.** `Generated/` is gitignored; XcodeGen recreates `Generated/App-Info.plist` from `Project.yml`.

## Key constraints

- **Code signing disabled** everywhere — both `Project.yml` and CI use `CODE_SIGN_IDENTITY="-"`. Do not re-enable without user approval.
- **No test targets.** `Project.yml` sets `testTargets: []`. There is no test suite to run.
- **No linter/formatter configured.** No SwiftLint, SwiftFormat, or similar.
- **CI**: GitHub Actions on `macos-15`, Xcode 16.4. Triggers on push/PR to `main` and version tags (`v*`).
- **Deployment target**: macOS 13.0 (Ventura).

## Structure

- `QuickAirDrop/Sources/App/` — app entry + AppDelegate
- `QuickAirDrop/Sources/StatusBar/` — StatusBarController, DragOverlayWindow
- `QuickAirDrop/Sources/AirDrop/` — AirDropManager, AirDropDelegate
- `QuickAirDrop/Sources/Features/` — LaunchAtLogin, AirDropHistory, RecentDevices
- `QuickAirDrop/Sources/UI/` — PopoverView, SettingsView, HistoryView, NotificationManager
- `QuickAirDrop/Sources/Utilities/` — FileValidator, UserDefaults extensions
- `Project.yml` — XcodeGen config (single source of truth for build settings)
- `Generated/` — auto-generated, gitignored (Info.plist)

## Conventions

- **XcodeGen is the project source of truth.** Do not hand-edit `.xcodeproj`. Edit `Project.yml` and regenerate.
- AppKit for chrome (`NSPopover`, `NSStatusItem`, `NSPanel`), SwiftUI for views.
- AirDrop via `NSSharingService` API (no private APIs).
- Launch at login via `SMAppService` (macOS 13+).
