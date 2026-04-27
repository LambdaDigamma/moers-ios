# Moers Festival Android App Instructions

This is the festival Android application module. The local `README.md` still contains generic starter-project text; do not rely on it for current app behavior.

## App Facts

- Module: `:moers-festival-android`
- Package/application ID: `com.lambdadigamma.moersfestival`
- Namespace: `com.lambdadigamma.moersfestival`
- Main source package: `moers-festival-android/src/main/java/com/lambdadigamma/moersfestival`
- Main activity: `com.lambdadigamma.moersfestival.MainActivity`
- Uses Compose Material3, Hilt, Navigation3, Firebase Analytics/Messaging/Crashlytics, Maps, Ktor/Retrofit, Room, and festival modules under `modules/`.
- This app uses Java/Kotlin 17 settings in its Gradle file.

## Architecture Notes

- `App.kt` owns onboarding, notification setup state, and the main `NavDisplay`.
- `FestivalNavKey` and `FestivalTopLevelBackStack` define the Navigation3 app shell.
- Top-level tabs are News, Map, Favorites, Timetable, and Info.
- Deep links and notification intents should resolve into synthetic navigation stacks instead of bypassing the app shell.
- Keep festival data behavior in feature modules where possible; keep app-module code focused on app shell, setup, notifications, and cross-feature wiring.

## Local Configuration

- `moers-festival-android/local.defaults.properties` documents `FESTIVAL_MAPS_API_KEY`.
- Firebase and Maps configuration may depend on `google-services.json` and local properties.
- Release signing expects keystore material and Play configuration.
- Do not read or edit local secrets, Google service files, Play config, or signing files unless explicitly requested.

## Run And Verify

- Build debug: `./gradlew :moers-festival-android:assembleDebug`
- Install debug: `./gradlew :moers-festival-android:installDebug`
- Unit tests: `./gradlew :moers-festival-android:testDebugUnitTest`
- Lint: `./gradlew :moers-festival-android:lintDebug`
- Detekt: `./gradlew :moers-festival-android:detekt`

For feature-module changes, also run the targeted module test, for example `./gradlew :modules:festival-events:testDebugUnitTest`.

For UI/runtime changes:

1. Build or install with Gradle.
2. Use Mobile MCP to list devices dynamically.
3. Launch `com.lambdadigamma.moersfestival`.
4. Capture screenshots for the affected screen or navigation flow.
5. Check both German and English where visible localized text changed.

## Release References

Fastlane lanes exist for `increment_version_code`, `increment_version`, `test`, `debug_build`, `slack_apk_build`, `deploy_internal`, `deploy_beta`, and `deploy_production`.

Do not run version bump, deploy, Slack upload, Google Play, signing, or release lanes without explicit approval.
