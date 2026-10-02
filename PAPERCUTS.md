# Papercuts

## AssetPlayer does not populate static item metadata

- Impact: Constructing `AssetPlayer` with a nonempty playlist can access an empty metadata array and crash before playback starts.
- Reproduction: Use a `NowPlayable` implementation whose session-start method succeeds, then pass one `AVPlayerItem` to `AssetPlayer.init`. The initializer sets `staticMetadatas` to an empty array. `play()` calls `handlePlayerItemChange()`, which indexes that array with the current item's playlist index.
- Next step: Supply matching metadata for each player item and add a focused initialization test. This is separate from the media-selection API warning fix.

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
