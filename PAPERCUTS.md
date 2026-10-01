# Papercuts

## Xcode 26.3 validation is pending

- The concurrency fixes pass local tests on iOS 18.6 and iOS 27.1 with Xcode 27 RC / Swift 6.4. Validation with CI's Xcode 26.3 toolchain remains pending.
- Next step: Run the app and dependency concurrency tests and the onboarding UI test on iOS 18.6 with Xcode 26.3.

## Existing SwiftLint errors outside the concurrency changes

- Impact: Linting the larger set of source files touched by explicit destructors exposes seven existing errors. The same seven errors are present in the branch's committed source before these edits.
- Reproduction: Run `swiftlint lint --config ios/.swiftlint.yml` for `Core/Entry/EntryManager.swift`, `MMEvents/ViewModels/EventViewModel.swift`, `MMFeeds/UI/ViewController/PostsViewController.swift`, and `Pulley/PulleyViewController.swift` under `ios/CityOS/Sources`.
- Errors: One legacy API variable name, two large tuples, one count comparison, and Pulley file, function, and class length limits. Refactor these separately; they do not affect the older-iOS runtime checks.
