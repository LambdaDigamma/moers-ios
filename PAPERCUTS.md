# Papercuts

## Xcode 26.3 validation is pending

- The concurrency fixes pass local tests on iOS 18.6 and iOS 27.1 with Xcode 27 RC / Swift 6.4. Validation with CI's Xcode 26.3 toolchain remains pending.
- Next step: Run the app and dependency concurrency tests and the onboarding UI test on iOS 18.6 with Xcode 26.3.

## Existing SwiftLint errors outside the concurrency changes

- Impact: Linting the larger set of source files touched by explicit destructors exposes seven existing errors. The same seven errors are present in the branch's committed source before these edits.
- Reproduction: Run `swiftlint lint --config ios/.swiftlint.yml` for `Core/Entry/EntryManager.swift`, `MMEvents/ViewModels/EventViewModel.swift`, `MMFeeds/UI/ViewController/PostsViewController.swift`, and `Pulley/PulleyViewController.swift` under `ios/CityOS/Sources`.
- Errors: One legacy API variable name, two large tuples, one count comparison, and Pulley file, function, and class length limits. Refactor these separately; they do not affect the older-iOS runtime checks.

## Existing marketing lint errors block the standard check

- Impact: `npm run lint` stops at ESLint and does not run its TypeScript check. It reports 19 errors in unchanged component files. The output is identical with the dependencies on `master` and with the dependency updates from PRs #49, #50, and #51.
- Reproduction: With Node 22.14, run `cd marketing && npm ci && npm run lint`.
- Errors: `DeviceCarousel.tsx` has eight explicit `any` errors. `DeviceStill.tsx` has seven. `PhoneFrame.tsx` has two explicit `any` errors, one forbidden `require()` import, and one native image element error.
- Next step: Fix these component errors separately. Run `npm exec -- tsc --noEmit` to check TypeScript while the standard lint command is blocked. This check and the Storybook build pass with the proposed dependency updates.
