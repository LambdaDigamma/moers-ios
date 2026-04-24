# CityOS Swift Package Instructions

`CityOS` is a local Swift package used by the iOS apps.

## Package Facts

- Manifest: `ios/CityOS/Package.swift`
- Swift tools version: 6.2
- Platforms: iOS 16, macOS 12, watchOS 7, tvOS 14
- Core products include `Core`, `CoreCache`, `DashboardFeature`, `RubbishFeature`, `ParkingFeature`, `NewsFeature`, `FuelFeature`, `MapFeature`, `MMEvents`, `MMPages`, `MMFeeds`, `EFAAPI`, `EFAUI`, `PlaybackKit`, and `AppUpdateFeature`.
- The package enables upcoming Swift features in shared `swiftSettings`; do not remove these settings without a targeted migration reason.

## Coding Patterns

- Keep resources under each target's `Resources` directory and access package resources with `Bundle.module`.
- Use Factory registration patterns already present in target code.
- Keep async service and repository APIs consistent with nearby code; do not mix callback and async styles unless the existing API requires it.
- Preserve `@MainActor` on UI-facing view models and controllers.
- When touching database-backed packages such as `MMEvents`, `MMPages`, or `MMFeeds`, add focused tests around records, stores, repositories, or mappers.

## Commands

- Build package: `swift build --package-path ios/CityOS`
- Test package: `swift test --package-path ios/CityOS`
- Test one suite: `swift test --package-path ios/CityOS --filter MMEventsTests`
- Describe package targets: `swift package describe --package-path ios/CityOS`

If SwiftPM needs normal user cache access and the sandbox blocks it, ask for escalation.

## Do Not

- Do not update dependencies or `Package.resolved` unless dependency work is explicitly requested.
- Do not move package targets or products without checking the iOS app project references.
- Do not add app-specific secrets or bundle-specific configuration to the package.
