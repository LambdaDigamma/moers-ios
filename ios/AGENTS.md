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
  `xcodebuild -workspace ios/Moers.xcworkspace -scheme Moers -configuration 'Debug (Production)' -testPlan FullTestPlan -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
- Test one CityOS suite on iOS:
  `xcodebuild -workspace ios/Moers.xcworkspace -scheme Moers -configuration "Debug (Production)" -testPlan FullTestPlan -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:CoreTests/LocationServiceTests test`
- Run fastlane from `ios` only when explicitly requested:
  `cd ios && bundle exec fastlane ios <lane>`

Use an installed simulator from `xcrun simctl list devices available`. The workspace includes CityOS test bundles; a project-only test command does not discover them.

The standard test configuration enables Thread Sanitizer. For a diagnostic run without it, add `-only-test-configuration 'Configuration (English, No Thread Sanitizer)'`. MainActor XCTest methods use async execution. Synchronous task-local release tests also cover UIKit cleanup outside a Swift task. The full plan passes on iOS 18.6 and iOS 27.1 with Xcode 27 RC / Swift 6.4. See `PAPERCUTS.md` for the older-runtime destructor fix.

Before an older-iOS UI check, build for that exact installed runtime. Run `python3 ios/scripts/check-older-ios-runtime-libraries.py '<current build output>/Moers.app'` before installation. A bundle built for a newer runtime can omit compatibility libraries that the older runtime needs. Use the app path from the current build log. Project and workspace builds have separate DerivedData paths. Xcode can also put products under `Variant-NoSanitizers` when the sanitizer setting changes; use that path when the current build log shows it. If you change runtime destinations, rebuild and check the bundle again. Do not install an old bundle from another DerivedData directory.

Live API tests skip by default. To opt in, set `RUN_FUEL_INTEGRATION_TESTS=1` or `RUN_EFA_INTEGRATION_TESTS=1` in the test runner environment through the test plan or scheme. Test fixtures run without these flags.

For UI/runtime changes:

1. Build with Xcode tooling.
2. Use Mobile MCP to list devices dynamically.
3. Launch `de.okfn.niederrhein.Moers`.
4. Capture screenshots for the affected flow.

## Style And Testing

- Both Xcode projects set Swift 6, Approachable Concurrency, MainActor default isolation, and complete strict concurrency at project level for Debug and Release. App, extension, tvOS, and watchOS targets inherit these defaults.
- XCTest targets override default isolation to `nonisolated`. Use explicit MainActor isolation for UI fixtures and async test methods; keep XCTest initialization nonisolated. Do not lower their Swift language mode or strict concurrency settings.
- The city `WidgetsExtension` test plan sets `UserDidCompleteSetup` for its unit-test host. Form and storage tests require a stable launch state. Use the UI test target to check onboarding.
- Check onboarding with the `Screenshots` scheme and `Onboarding` test plan. It selects only `OnboardingUITests` and keeps app animations enabled. The default `Screenshots` plan continues to select the marketing screenshot tests. Example: `xcodebuild -workspace ios/Moers.xcworkspace -scheme Screenshots -configuration 'Debug (Production)' -testPlan Onboarding -destination '<available iOS simulator>' test`.
- External packages use their own manifest settings. Do not apply global Swift compiler overrides to dependency targets; change their source manifest when a dependency migration is required.
- Keep UIKit, SwiftUI, and package code in the style already used by nearby files.
- Respect `@MainActor` boundaries in UI controllers and view models.
- Prefer existing Factory container registration patterns for dependency injection.
- Use XCTest patterns already present in the relevant target.
- Run SwiftLint if you changed enough Swift code that style risk is meaningful.

## Release References

Fastlane lanes under `ios/fastlane` include version bumping, build/upload, metadata, screenshots, release, and signing lanes. Do not run upload, release, signing, screenshot upload, App Store Connect, or version-bump lanes without explicit approval.
