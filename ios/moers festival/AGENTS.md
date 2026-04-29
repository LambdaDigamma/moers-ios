# Moers Festival iOS Instructions

This subtree contains the festival iOS, widget, watchOS, and tvOS project.

## App Facts

- Project: `ios/moers festival/moers festival.xcodeproj`
- Main app bundle ID: `de.okfn.niederrhein.moers-festival`
- Main scheme: `moers festival`
- Other schemes include `moers festival (Widgets)`, `moers festival tvOS`, `moers festival Watch App`, `WidgetsExtension`, and CityOS package schemes exposed through Xcode.
- Build configurations are `Debug` and `Release`.
- Main app source lives under `ios/moers festival/moers festival`.
- Widgets live under `ios/moers festival/Widgets`.

## Commands

- Build main app:
  `xcodebuild -project "ios/moers festival/moers festival.xcodeproj" -scheme "moers festival" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- Test main app:
  `xcodebuild -project "ios/moers festival/moers festival.xcodeproj" -scheme "moers festival" -testPlan TestPlan -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
- Build widget scheme:
  `xcodebuild -project "ios/moers festival/moers festival.xcodeproj" -scheme "moers festival (Widgets)" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- Run fastlane only when explicitly requested:
  `cd "ios/moers festival" && bundle exec fastlane ios <lane>`

For UI/runtime changes:

1. Build with Xcode tooling.
2. Use Mobile MCP to list devices dynamically.
3. Launch `de.okfn.niederrhein.moers-festival`.
4. Capture screenshots for the affected flow and relevant device class.

## Architecture Notes

- The project mixes UIKit, SwiftUI, WidgetKit, and the local `CityOS` package.
- Use existing coordinator/controller patterns for app navigation.
- Use Factory container registrations where nearby code already does.
- Keep widget data sync behavior consistent with shared widget support code.
- Festival screenshots are connected to the marketing Remotion project; do not update raw screenshots, processed stills, or App Store screenshot assets unless that is the requested task.

## Release And Screenshot References

Fastlane lanes include `load_asc_api_key`, `register_dev_devices`, `match_appstore`, `match_development`, `signing`, `increment_build`, `increment_version`, `build_release`, `upload_testflight`, `upload_release_notes`, `ensure_app_version`, `upload`, `release`, `capture`, `render_stills`, `replace_screenshots`, `upload_screenshots`, `screenshots_pipeline`, and tvOS release lanes.

Do not run signing, match, version bump, upload, release, App Store Connect, screenshot upload, or `screenshots_pipeline` lanes without explicit approval.
