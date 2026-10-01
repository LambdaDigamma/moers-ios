# Papercuts

## Resolved: Watch and XCTest targets did not share the concurrency defaults

- Both Xcode projects now set Swift 6, Approachable Concurrency, MainActor default isolation, and complete strict concurrency at project level in Debug and Release. All seven app and extension targets use these settings, including watchOS and tvOS.
- All six XCTest targets use Swift 6 and Approachable Concurrency with explicit nonisolated default isolation. UI fixtures and async test methods opt into MainActor. Legacy test setup and UI helpers now respect that isolation; immutable launch arguments conform to Sendable.
- All 36 CityOS targets explicitly use Swift 6. The 20 production targets use MainActor default isolation; the 16 test targets explicitly use nonisolated default isolation. All targets share the two Approachable Concurrency features not enabled automatically by Swift 6.
- Validation: Effective Xcode settings were checked for all 26 target configurations. The evaluated package manifest was checked for all 36 targets. All native targets and EFACLI compile. On iOS 18.6, 35 app unit tests and eight focused package tests pass. The package tests report no runtime or Thread Sanitizer warnings. Watch test targets were compiled; watch tests were not run.

## Resolved: BulletinBoard destruction on older iOS

- Impact: With BulletinBoard 6.1.0, a city unit-test host that shows onboarding can abort on iOS 18.6 before its tests complete. The crash is in BulletinBoard 6.1.0's `AnimationPhase`, followed by `swift_task_deinitOnExecutorMainActorBackDeploy` and `TaskLocal::StopLookupScope`. This is a dependency class outside this repository, separate from the fixed CityOS destructors.
- Reproduction with BulletinBoard 6.1.0: Remove the `UserDidCompleteSetup` launch arguments from `ios/Test Plans/WidgetsExtension.xctestplan`, then run the `WidgetsExtension` scheme and test plan on iOS 18.6 with Xcode 27 RC. A fresh onboarding launch reaches the UIKit animation cleanup path. Crash diagnostics from the failed run identify `AnimationPhase.__deallocating_deinit` in the app's linked dependency code.
- Fix published in [BulletinBoard 6.1.1](https://github.com/LambdaDigamma/BulletinBoard/tree/6.1.1). ARC-only classes have explicit nonisolated destructors. The manager retains the items until MainActor teardown completes, with synchronous teardown on the main thread and a MainActor task after a background owner releases it. That task preserves the caller's task-local values. The view controller removes its selector observers without isolated destruction. UI state remains MainActor isolated. The package manifest now enables both extra Approachable Concurrency features and includes a Swift 6 test target with nonisolated default isolation.
- Regression evidence: The new animation phase test aborts with the original 6.1.0 source and the same allocator, task-local, and `AnimationPhase` frames. It passes after the fix. This matches [Swift issue 88036](https://github.com/swiftlang/swift/issues/88036).
- Validation: Six package tests pass on both iOS 18.6 and iOS 27.1 with Thread Sanitizer and no runtime warnings. They cover task-local scope restoration, captured view release, animation completion, controller destruction, and item teardown after main-thread and background release. The original city unit-test host startup with onboarding enabled passes all five tests on iOS 18.6. The onboarding UI test passes with animations enabled through the intro, privacy, user, and notification pages. Both app consumers compile with the fixed package. Toolchain: Xcode 27 RC / Swift 6.4; Xcode 26.3 remains unverified locally.
- Integration: Both app package requirements and all three resolution files use 6.1.1 at revision `06b96b8dc849e4f163294bf12bb633dcf62c8c1e`. Other dependency versions are unchanged. The normal workspace passes all six app lifecycle tests on both iOS 18.6 and iOS 27.1 with Thread Sanitizer and no runtime warnings. The standalone festival project builds for iOS 18.6 with the published package.
- The city unit-test plan retains its completed-onboarding fixture. Onboarding has a separate UI test plan, so form and storage tests do not need to depend on the first-launch interface.

## Resolved: City screenshot scheme assumed an unconfigured Release build path

- Impact: `Screenshots` cannot build its UI test target when `${SYMROOT}/Release-iphonesimulator` is absent. Its pre-build script copies that directory to the selected configuration, although the city project uses `Release (Production)`.
- Reproduction: Run `xcodebuild -workspace ios/Moers.xcworkspace -scheme Screenshots -configuration 'Debug (Production)' -testPlan Screenshots -destination '<available iOS simulator>' build-for-testing`. The pre-build copy fails before test compilation.
- Fix: Removed the pre-build copy. Xcode builds the app and UI test products in the selected configuration. This also prevents the scheme from copying stale Release artifacts into a Debug build.
- Validation: The normal workspace `Screenshots` scheme builds for testing on iOS 18.6 with published BulletinBoard 6.1.1. Its `Onboarding` UI test passes with app animations enabled and no runtime warnings. The UI test source compiles with Swift 6 and MainActor isolation. No screenshot export or upload workflow was run.
- The additional `Onboarding` test plan selects the onboarding UI test without running marketing screenshot tests. The test now includes the privacy page, uses current accessibility identifiers, and keeps app animations enabled.

## Resolved: Onboarding callbacks and tasks retained their pages

- The original lifecycle test found nine pages alive after their external owners released them. Presentation and action handlers captured the page that owned the handler. The street picker also started unowned tasks in its initializer and retained itself across street loading and location stream waits.
- Callback handlers now use the item passed to them. The street picker starts work in `setUp`, uses weak page references across suspension points, and owns cancellation handles for street loading, authorization observation, and location estimation. `tearDown` and final page release cancel that work. Cancellation checks prevent a stopped task from starting a new request or applying a late result. Required view state remains MainActor isolated; the tasks inherit that isolation.
- Six app lifecycle tests pass on both iOS 18.6 and iOS 27.1 with Thread Sanitizer and no runtime warnings. They check page graph release outside a Swift task, accessibility identifiers, loading cancellation on teardown and release, authorization observation termination, and pending location cancellation. The service fixtures do not use live APIs. Validation used the normal workspace with published BulletinBoard 6.1.1, under Xcode 27 RC / Swift 6.4.

## Resolved: CityOS test bundles were not discovered

- `FullTestPlan` now refers to the `CityOS` package and includes all 16 test targets.
- Run tests with `ios/Moers.xcworkspace`. The project-only command does not discover package tests.
- UI fixtures use explicit MainActor isolation and async test methods. XCTest initialization remains nonisolated.
- Old callback tests and Linux test manifests were replaced with async tests and automatic discovery.
- Live fuel and transit API tests require explicit runner environment flags. Page and post fixtures use bundled data and cannot issue network requests.
- Validation: All 16 targets pass the full plan with Xcode 27 RC / Swift 6.4 on both iOS 18.6 and iOS 27.1: 239 tests passed and 17 skipped on each runtime, with no runtime or Thread Sanitizer warnings. Seven skipped tests need live API opt-in; ten legacy event subtitle tests were already disabled.

## Resolved: Festival tvOS dependencies used iOS-only APIs

- Shared Core and event views now restrict unsupported APIs or use tvOS alternatives.
- tvOS explicitly links AppScaffold and shares the legacy event service factory.
- tvOS uses Swift 6, MainActor default isolation, and Approachable Concurrency.
- The player uses async stream loading and cancels its task when the view disappears.
- Validation: The festival iOS and tvOS simulator builds pass with Xcode 27 / Swift 6.4.

## Resolved: Inferred actor destruction crashes on older iOS runtimes

- Cause: Inferred MainActor destruction can crash during synchronous release with task-local storage outside a Swift task. [Swift issue 88036](https://github.com/swiftlang/swift/issues/88036) also reproduces this with Xcode 26.3; this is not limited to Xcode 27 or XCTest.
- Fix: ARC-only classes in CityOS and the city and festival apps have explicit `nonisolated deinit {}`. Their state keeps its existing actor isolation. Required cleanup and inherited destructor isolation remain in place. The transit model cancels its Sendable task from a nonisolated destructor.
- Tests: Core checks synchronous subscription release and task-local scope restoration. Event tests release the nested timetable, repository, service, and row models from a main-queue callback outside a Swift task. The original UIKit search-controller regression also passes and uses normal appearance transitions.
- Validation: The full plan passes on iOS 18.6 and iOS 27.1 with Thread Sanitizer enabled: 239 passed and 17 expected skips on each runtime. No allocator failures or runtime warnings occurred. CI Xcode 26.3 was not run locally; the older runtime was tested directly with Xcode 27 RC / Swift 6.4.

## Resolved: SwiftLint errors in large event test fixtures

- Removed the unused database value from the event repository fixture tuple.
- Split timetable search tests into two extensions. The shared fixture and all test methods remain in the same XCTest class.
- Validation: SwiftLint reports no errors in the 117 changed Swift files checked with `ios/.swiftlint.yml`. All 22 event repository and timetable tests passed after the split. Existing style warnings remain.

## Resolved: Older-iOS startup used a bundle for a different runtime

- The earlier diagnosis used a different DerivedData bundle from the project build. Project and workspace builds have separate output directories. A bundle built for a newer runtime can link Span without embedding its compatibility library.
- Swift's [runtime embedding task](https://github.com/swiftlang/swift-build/blob/main/Sources/SWBTaskConstruction/TaskProducers/OtherTaskProducers/SwiftStandardLibrariesTaskProducer.swift) considers the selected device OS version. Rebuild for the older runtime immediately before installation, including after tests or builds for another runtime.
- Added `ios/scripts/check-older-ios-runtime-libraries.py`. It checks Mach-O dependencies in the app, its frameworks, and extensions before an older-iOS installation. It reads executable headers and load commands, not resource or credential plists.
- Xcode can put the current UI-test products under `Variant-NoSanitizers` after a sanitizer setting change. Use the product path from the current build log. The iOS 18.6 onboarding UI-test bundle passes the compatibility check for all 14 Mach-O binaries and launches with published BulletinBoard 6.1.1.
- Validation: The check passes for both fresh iOS 18.6 app outputs. It rejects the newer-runtime test bundle that omits Span. A fresh workspace build copies `libswiftCompatibilitySpan.dylib`; that exact app was installed and remained running on iOS 18.6. The installed debug binary UUID matches the build output.
- No release or signed archive was tested.

## Resolved: Manual parking check and stale map preview

- Used Device Hub on the unlocked Mac with the iOS 18.6 simulator and synthetic Moers coordinates. A temporary `UserDidCompleteSetup` launch argument skips onboarding; normal app services remain enabled. Simulator location permission was granted for the test.
- Verified the initial location preview, disabling and enabling location saving, and closing and reopening the screen. Unit tests also cover observation cancellation, disabled and restored timers, and late location updates.
- The UI check found a stale map image after the coordinate changed. The parking snapshot now uses coordinate identity, so it refreshes when location loading supplies a new position. The updated preview and screen reopening were checked in the final app bundle.

## Existing SwiftLint errors outside the concurrency changes

- Impact: Linting the larger set of source files touched by explicit destructors exposes seven existing errors. The same seven errors are present in the branch's committed source before these edits.
- Reproduction: Run `swiftlint lint --config ios/.swiftlint.yml` for `Core/Entry/EntryManager.swift`, `MMEvents/ViewModels/EventViewModel.swift`, `MMFeeds/UI/ViewController/PostsViewController.swift`, and `Pulley/PulleyViewController.swift` under `ios/CityOS/Sources`.
- Errors: One legacy API variable name, two large tuples, one count comparison, and Pulley file, function, and class length limits. Refactor these separately; they do not affect the older-iOS runtime checks.
