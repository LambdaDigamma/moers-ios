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

## Build Resources

- The `Prepare Fuel Configuration` aggregate target owns the `Prepare Fuel API Key` phase. Both `Moers` and `WidgetsExtension` depend on it because they consume the same optional configuration file. Its declared output is the configuration file; it creates the sample fallback only when that output is absent and preserves an existing configuration.
- `Settings Bundle Preparation` writes the app's Settings bundle in the build product directory. `MOERS_SETTINGS_BUNDLE_VARIANT` selects the Debug or Release template. Both configurations use the checked-in licences under `Moers/Resources/Debug/Settings.bundle`. The script uses the source app Info.plist for its version fields, so it does not depend on a processed plist from a previous build.
- After adding or removing Settings resource files, refresh the dependency lists with `python3 ios/scripts/prepare-settings-bundle.py refresh-file-lists` from the repository root. Keep the input and output lists with the resource change.
- The Settings bundle input list tracks `$(PROJECT_FILE_PATH)/project.xcproj`, the city project's JSON configuration file.
- Test these scripts with `PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 -m unittest discover -s ios/scripts/tests -v`. The fuel tests use synthetic files in a temporary directory.

For UI/runtime changes:

1. Build with Xcode tooling.
2. Use Mobile MCP to list devices dynamically.
3. Launch `de.okfn.niederrhein.Moers`.
4. Capture screenshots for the affected flow.

## Style And Testing

- Prefer synchronized folders for file-system content in Xcode projects. Do not add duplicate group references to directories already covered by a synchronized folder. Keep `Products` last so Xcode can hide it, and preserve product and extension-embedding references. Omit explicit SDK framework references when automatic linking is sufficient.
- Use `opaque-folders` for resource directories that must keep their directory names in the app bundle, such as the festival's `FGD2022`, `FGD2024`, and `FGD2025` map archives. Keep unused files out of target membership when converting groups to synchronized folders.
- Both Xcode projects set Swift 6, Approachable Concurrency, MainActor default isolation, and complete strict concurrency at project level for Debug and Release. App, extension, tvOS, and watchOS targets inherit these defaults.
- XCTest targets override default isolation to `nonisolated`. Use explicit MainActor isolation for UI fixtures and async test methods; keep XCTest initialization nonisolated. Do not lower their Swift language mode or strict concurrency settings.
- The city `WidgetsExtension` test plan sets `UserDidCompleteSetup` for its unit-test host. Form and storage tests require a stable launch state. Use the UI test target to check onboarding.
- Check onboarding with the `Screenshots` scheme and `Onboarding` test plan. It selects only `OnboardingUITests` and keeps app animations enabled. The default `Screenshots` plan continues to select the marketing screenshot tests. Example: `xcodebuild -workspace ios/Moers.xcworkspace -scheme Screenshots -configuration 'Debug (Production)' -testPlan Onboarding -destination '<available iOS simulator>' test`.
- City tab coordinators must set `CoordinatedNavigationController.menuItem`. This restores the tab title after navigation. Keep the same `UITabBarItem` instance so UIKit retains its accessibility identifier.
- Check tab labels with the `Moers` scheme and `Navigation` test plan. It selects only `TabBarNavigationUITests`, keeps animations enabled, and bypasses onboarding through launch arguments without resetting stored preferences. Example: `xcodebuild -workspace ios/Moers.xcworkspace -scheme Moers -configuration 'Debug (Production)' -testPlan Navigation -destination '<available iOS simulator>' -parallel-testing-enabled NO test`.
- External packages use their own manifest settings. Do not apply global Swift compiler overrides to dependency targets; change their source manifest when a dependency migration is required.
- Keep UIKit, SwiftUI, and package code in the style already used by nearby files.
- Respect `@MainActor` boundaries in UI controllers and view models.
- Prefer existing Factory container registration patterns for dependency injection.
- Use XCTest patterns already present in the relevant target.
- Run SwiftLint if you changed enough Swift code that style risk is meaningful.

## Release References

Fastlane lanes under `ios/fastlane` include version bumping, build/upload, metadata, screenshots, release, and signing lanes. Do not run upload, release, signing, screenshot upload, App Store Connect, or version-bump lanes without explicit approval.
