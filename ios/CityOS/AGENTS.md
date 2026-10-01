# CityOS Swift Package Instructions

`CityOS` is a local Swift package used by the iOS apps.

## Package Facts

- Manifest: `ios/CityOS/Package.swift`
- Swift tools version: 6.2
- Platforms: iOS 17, macOS 14, watchOS 10, tvOS 17
- Core products include `Core`, `CoreCache`, `DashboardFeature`, `RubbishFeature`, `ParkingFeature`, `NewsFeature`, `FuelFeature`, `MapFeature`, `MMEvents`, `MMPages`, `MMFeeds`, `EFAAPI`, `EFAUI`, `PlaybackKit`, and `AppUpdateFeature`.
- Production targets use MainActor default isolation and the Approachable Concurrency feature flags. Test targets keep the feature flags and use explicit `@MainActor` on UI fixtures and methods. Keep XCTest initializers nonisolated.

## Coding Patterns

- Keep resources under each target's `Resources` directory and access package resources with `Bundle.module`.
- Use Factory registration patterns already present in target code.
- Keep async service and repository APIs consistent with nearby code; do not mix callback and async styles unless the existing API requires it.
- Preserve `@MainActor` on UI-facing view models and controllers.
- Use async XCTest methods for MainActor fixtures and tests. Also test synchronous UI cleanup outside a Swift task when changing object lifetime.
- Keep explicit `nonisolated deinit {}` on ARC-only classes. Inferred isolated destruction can crash on older runtimes with task-local storage ([Swift issue 88036](https://github.com/swiftlang/swift/issues/88036)). Do not read actor state from these destructors. Task cancellation is safe when the stored task is Sendable. Keep required actor cleanup and inherited destructor isolation.
- When touching database-backed packages such as `MMEvents`, `MMPages`, or `MMFeeds`, add focused tests around records, stores, repositories, or mappers.

## Commands

- Build the city app: `xcodebuild -project ios/Moers.xcodeproj -scheme Moers -configuration "Debug (Production)" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- Test the package on iOS: `xcodebuild -workspace ios/Moers.xcworkspace -scheme Moers -configuration "Debug (Production)" -testPlan FullTestPlan -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
- Test one suite: add `-only-testing:MMEventsTests/TimetableViewModelTests` to the iOS test command.
- Select an installed simulator with `xcrun simctl list devices available`.
- Use `swift build` / `swift test` only for targets that support the host platform; UIKit targets need the iOS simulator.
- Live API test opt-in and the optional Thread Sanitizer configuration are documented in `ios/AGENTS.md`.
- Describe package targets: `swift package describe --package-path ios/CityOS`

If SwiftPM needs normal user cache access and the sandbox blocks it, ask for escalation.

## Do Not

- Do not update dependencies or `Package.resolved` unless dependency work is explicitly requested.
- Do not move package targets or products without checking the iOS app project references.
- Do not add app-specific secrets or bundle-specific configuration to the package.
