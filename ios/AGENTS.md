# iOS Instructions

This subtree contains the city iOS app, the festival iOS app, shared test plans, fastlane release automation, and the local `CityOS` Swift package.

## Project Map

- City app project: `ios/Moers.xcodeproj`
- City app bundle ID: `de.okfn.niederrhein.Moers`
- City app schemes include `Moers`, `Screenshots`, `Onboarding`, `WidgetsExtension`, and `Intent Extensions`.
- City app build configurations are `Debug (Production)` and `Release (Production)`.
- Festival app project: `ios/moers festival/moers festival.xcodeproj`
- Reusable Swift package: `ios/CityOS`
- Shared test plans live under `ios/Test Plans`.
- SwiftLint config: `ios/.swiftlint.yml`.

## Local Configuration

- Do not read or edit Google service plists, Tankerkoenig plists, ASC keys, signing profiles, or fastlane `.env` files unless explicitly requested.
- Xcode and SwiftPM commands may update package resolution files. Do not keep `Package.resolved` changes unless dependency resolution is the requested work.
- If Xcode needs simulator, SwiftPM, or DerivedData cache access outside the sandbox, ask for escalation instead of changing package paths or project settings.

## City App Commands

- Build city app:
  `xcodebuild -project ios/Moers.xcodeproj -scheme Moers -configuration "Debug (Production)" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- Test city app with the full test plan:
  `xcodebuild -project ios/Moers.xcodeproj -scheme Moers -testPlan FullTestPlan -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
- Test CityOS package:
  `swift test --package-path ios/CityOS`
- Run fastlane from `ios` only when explicitly requested:
  `cd ios && bundle exec fastlane ios <lane>`

For UI/runtime changes:

1. Build with Xcode tooling.
2. Use Mobile MCP to list devices dynamically.
3. Launch `de.okfn.niederrhein.Moers`.
4. Capture screenshots for the affected flow.

## Style And Testing

- Keep UIKit, SwiftUI, and package code in the style already used by nearby files.
- Respect `@MainActor` boundaries in UI controllers and view models.
- Prefer existing Factory container registration patterns for dependency injection.
- Use XCTest patterns already present in the relevant target.
- Run SwiftLint if you changed enough Swift code that style risk is meaningful.

## Release References

Fastlane lanes under `ios/fastlane` include version bumping, build/upload, metadata, screenshots, release, and signing lanes. Do not run upload, release, signing, screenshot upload, App Store Connect, or version-bump lanes without explicit approval.
