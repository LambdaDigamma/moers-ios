# Mein Moers Android App Instructions

This is the city Android application module.

## App Facts

- Module: `:moers-android`
- Package/application ID: `com.lambdadigamma.moers`
- Namespace: `com.lambdadigamma.moers`
- Main source package: `moers-android/src/main/java/com/lambdadigamma/moers`
- Main activity: `com.lambdadigamma.moers.MainActivity`
- Uses Compose, Hilt, Room, Retrofit, protobuf/datastore, Google Play services, and shared modules under `modules/`.
- This app currently uses Java/Kotlin 11 settings in its Gradle file.

## Local Configuration

- `local.properties` may contain `TANKERKOENIG_API_KEY` and SDK/local API values.
- `moers-android/local.defaults.properties` documents `MOERS_MAPS_API_KEY`.
- Release signing expects `keystore.properties` and `Keystore.jks`.
- Do not read or edit local secrets or signing files unless the user explicitly asks.

## Run And Verify

- Build debug: `./gradlew :moers-android:assembleDebug`
- Install debug: `./gradlew :moers-android:installDebug`
- Unit tests: `./gradlew :moers-android:testDebugUnitTest`
- Lint: `./gradlew :moers-android:lintDebug`
- Fastlane test lane: `cd moers-android && bundle exec fastlane android test`

For UI/runtime changes:

1. Build or install with Gradle.
2. Use Mobile MCP to list devices dynamically.
3. Launch `com.lambdadigamma.moers`.
4. Capture a screenshot and verify the changed flow or screen.

## Release References

Fastlane lanes exist for `increment_version_code`, `increment_version`, `test`, `debug_build`, `deploy_internal`, `deploy_beta`, and `deploy_production`.

Do not run version bump, deploy, Google Play, signing, or upload lanes without explicit approval.
