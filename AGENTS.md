# AGENTS.md — QuickAirDrop

## What this is

macOS menu bar app (Swift 5.9, AppKit + SwiftUI). No dock icon (`LSUIElement` / `app.setActivationPolicy(.accessory)`). Entry point: `QuickAirDrop/Sources/App/main.swift` — manually creates `NSApplication`; **no `@main`**.

## Build workflow (required order)

```bash
brew install xcodegen        # one-time
xcodegen generate            # REQUIRED before every build; recreates .xcodeproj + Generated/
open QuickAirDrop.xcodeproj
# headless:
xcodebuild build -scheme QuickAirDrop -configuration Release CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

- **`xcodegen generate` is required before every build.** `Generated/` is gitignored; XcodeGen recreates `Generated/App-Info.plist` from `Project.yml`.
- **Code signing disabled everywhere** — `Project.yml` and CI use `CODE_SIGN_IDENTITY="-"`. Do not re-enable without user approval.
- **No test targets** (`testTargets: []`) and **no linter/formatter** (no SwiftLint/SwiftFormat). There is no test suite to run.
- **CI**: GitHub Actions `.github/workflows/build.yml` on `macos-15`, Xcode 16.4 (`setup-xcode`). Runs `xcodegen generate` + Release build, then zips `.app` and uploads as artifact; pushes to `v*` tags also create a GitHub Release from the zip. Triggered on push/PR to `main` and `v*` tags.
- **Deployment target**: macOS 13.0 (Ventura).

## Structure

- `QuickAirDrop/Sources/App/` — `main.swift`, `AppDelegate.swift` (manual NSApplication bootstrap)
- `QuickAirDrop/Sources/AirDrop/` — `AirDropManager`, `AirDropDelegate` (NSSharingService, no private APIs)
- `QuickAirDrop/Sources/StatusBar/` — `StatusBarController`, `DragOverlayWindow`
- `QuickAirDrop/Sources/Features/` — LaunchAtLogin, HotKeyManager, AirDropHistory, RecentDevices / QuickLaunch
- `QuickAirDrop/Sources/UI/` — PopoverView, SettingsView, HistoryView, NotificationManager, QuickLaunchStyle
- `QuickAirDrop/Sources/Utilities/` — Localization (`loc`), FileValidator
- `QuickAirDrop/Resources/` — `en.lproj` + `zh-Hans.lproj` `Localizable.strings`; `Assets.xcassets`
- `Project.yml` — XcodeGen config, single source of truth for build settings. **Do not hand-edit `.xcodeproj`.**

## Localization — critical

- Uses `loc(_:)` (Swift-style key string-lookup; `Localizable.strings` in old .strings format). All user-facing text, including **every Picker option**, goes through `loc` (e.g. `Picker { Text(loc("跟随系统")).tag("system") … }`). Bare `Text("中文")` breaks with the UI language.
- **`en.lproj` is the authoritative full key set.** Every key must exist in **both** `en.lproj` and `zh-Hans.lproj` with a Chinese value — a missing/broken `zh-Hans.lproj/Localizable.strings` makes the Chinese UI *silently fall back to English* (e.g. showing "Follow System" in Chinese mode). **This exact bug occurred before — verify both tables every time.**
- Verify: `plutil -lint QuickAirDrop/Resources/{en,zh-Hans}.lproj/Localizable.strings` must both pass, and `set(en keys) == set(zh keys)` (96 keys). Rebuild `zh-Hans` from `en` keys via `plutil -convert json` round-trip; write `.strings` as UTF-8 with a placeholder-free command, not inline heredocs with f-strings.
- macOS `.strings` = old-style plist; validate with `plutil`, and never commit a table that fails `plutil -lint`.

## SettingsView layout conventions

- Language row must keep its **left edge aligned** with the header text above it ("语言"). Use `.frame(maxWidth: .infinity, alignment: .leading)` for leading alignment — **`.fixedSize()` breaks the alignment**. Don't reintroduce it after a refactor.
- Round-trip a refactor with a **parse check**, not just reading the diff:
  `xcrun swiftc -parse -target arm64-apple-macosx13.0 QuickAirDrop/Sources/UI/SettingsView.swift`

## Git conventions

- Commits are frequent, single-purpose, messages in Chinese describing both change and reasoning. CI green on `main` is the guardrail, not a local-only diff.
- When reverting an unintended refactor, restore from git (`git restore <file>`) rather than re-editing — re-editing on a corrupted working tree re-introduces the bug.
