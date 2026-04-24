# Android Module Instructions

This subtree contains Android and Kotlin feature modules shared by the app modules. Follow the local module style instead of normalizing the whole tree.

## Structure

- Festival-era modules usually use `data`, `domain`, and `presentation` packages.
- Older city modules may use feature-specific packages such as `dashboard`, `detail`, `list`, `source`, or `ui`.
- `modules/core` is Kotlin Multiplatform and also defines shared Android UI, navigation, networking, geo, storage, and base ViewModel utilities.
- `modules/pages`, `modules/prosemirror`, and `modules/medialibrary` support CMS and rich-content rendering used by festival features.

## Kotlin And Android Patterns

- Check the touched module's `build.gradle.kts` before choosing Java/Kotlin targets. Some modules are Java 11, while newer festival modules are Java 17.
- Prefer existing Hilt patterns with `@Module`, `@InstallIn`, `@Provides`, and `@Binds`.
- Keep Room schema and KSP setup consistent with existing module configuration. Do not move schema directories.
- ViewModels that use `BaseViewModel` should keep the existing intent/partial-state/event pattern:
  - `UiState` is `Parcelable` where the base class requires it.
  - intents map to flows of partial state.
  - reducers are pure state transformations.
  - one-shot navigation or effects go through event flows/channels.
- Compose routes should collect state with lifecycle-aware APIs already used in the module, such as `collectAsStateWithLifecycle`.
- Put user-facing Android strings in resources. Update German resources when changing visible copy that already has German coverage.

## Testing

- Use JUnit5 in modules that apply the JUnit5 plugin; existing tests often use `org.junit.jupiter.api.Test` plus `kotlin.test` assertions.
- Prefer focused tests for pure mappers, filters, reducers, and use cases.
- For a touched module, run `./gradlew :modules:<module>:testDebugUnitTest`.
- For compile-sensitive changes, also run `./gradlew :modules:<module>:assembleDebug`.
- For `modules/core` KMP changes, consider `./gradlew :modules:core:allTests` or a targeted iOS simulator test only if the changed code affects non-Android source sets.
- For UI/runtime changes in modules consumed by app shells, also build the relevant app and smoke test it with Mobile MCP.

## Do Not

- Do not refactor package structure across modules as part of a narrow feature change.
- Do not change Gradle plugin versions or version catalog entries unless dependency work is explicitly requested.
- Do not run `lintFix`, `detektBaseline`, or other rewriting/baseline tasks unless asked.
