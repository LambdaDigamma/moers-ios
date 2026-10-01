# Papercuts

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
