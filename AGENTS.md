# Agent Instructions

These instructions are for AI coding agents working in this repository. Keep them operational: prefer concrete commands, preserve existing user changes, and avoid expanding the scope into contributor documentation.

## Required Practices

- Use Conventional Commits for any commit you create. Follow https://www.conventionalcommits.org, for example `docs: add agent instructions`.
- Treat the worktree as user-owned. This repository often has unrelated local edits; do not revert, reformat, or clean files you were not asked to touch.
- Use `rg` and `rg --files` for searching when available.
- Keep changes scoped to the requested surface. Do not update READMEs, generated outputs, release metadata, screenshots, or IDE files unless the user explicitly asks.
- Do not read, print, edit, or regenerate secrets unless explicitly requested: `.env`, `local.properties`, `keystore.properties`, `play_config.json`, `GoogleService-Info.plist`, `google-services.json`, ASC keys, signing profiles, and keystores.
- Do not run release, deploy, signing, upload, App Store Connect, Google Play, screenshot-upload, or version-bump workflows without explicit user approval.

## Project Map

- Android Gradle root: `settings.gradle.kts` currently includes `:moers-android`, `:moers-festival-android`, and `:modules:*`.
- Android feature modules live under `modules/`.
- City Android app lives under `moers-android` with package `com.lambdadigamma.moers`.
- Festival Android app lives under `moers-festival-android` with package `com.lambdadigamma.moersfestival`.
- City iOS app lives under `ios/Moers.xcodeproj`.
- Festival iOS app lives under `ios/moers festival`.
- Reusable Swift package lives under `ios/CityOS`.
- Marketing and App Store screenshot tooling lives under `marketing`.
- `composeApp` and `shared` exist in the repository, but they are not included in the current root `settings.gradle.kts`. Verify the current Gradle settings before treating them as active build targets.

## Common Commands

Run commands from the repository root unless a nested `AGENTS.md` says otherwise.

- Inspect Gradle projects: `./gradlew projects`
- Build city Android debug: `./gradlew :moers-android:assembleDebug`
- Test city Android debug unit tests: `./gradlew :moers-android:testDebugUnitTest`
- Build festival Android debug: `./gradlew :moers-festival-android:assembleDebug`
- Test festival Android debug unit tests: `./gradlew :moers-festival-android:testDebugUnitTest`
- Test an Android module: `./gradlew :modules:<module>:testDebugUnitTest`
- Test CityOS Swift package: `swift test --package-path ios/CityOS`
- Build city iOS app: `xcodebuild -project ios/Moers.xcodeproj -scheme Moers -configuration "Debug (Production)" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- Build festival iOS app: `xcodebuild -project "ios/moers festival/moers festival.xcodeproj" -scheme "moers festival" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- Marketing lint/typecheck: `cd marketing && npm run lint`
- Marketing Storybook: `cd marketing && npm run storybook`
- Marketing screenshot export: `cd marketing && npm run export:all`

If a command fails because it needs normal Xcode, SwiftPM, Gradle, npm, or simulator caches outside the sandbox, ask for escalation instead of inventing a workaround.

## Validation Policy

- Use targeted checks for the files you touched. Prefer the narrowest module/app test or build that proves the change.
- For UI or runtime behavior changes, build/install with the platform tooling first, then evaluate with Mobile MCP.
- With Mobile MCP, list devices dynamically, choose an appropriate currently available simulator/emulator, launch by package or bundle ID, and capture screenshots. Do not hard-code device IDs from a previous session.
- For documentation-only changes, read the changed files back and verify the expected file list; an app build is not required.

## Release References

These are references only. Do not run them without explicit approval.

- Android release workflows: `.github/workflows/android-release.yml`, `.github/workflows/festival-android-release.yml`.
- iOS release workflows: `.github/workflows/ios-release.yml`, `.github/workflows/festival-ios-release.yml`.
- Android fastlane lanes live under `moers-android/fastlane` and `moers-festival-android/fastlane`.
- iOS fastlane lanes live under `ios/fastlane` and `ios/moers festival/fastlane`.
