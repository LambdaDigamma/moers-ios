# Papercuts

## Existing Festival SwiftLint errors

- Impact: Strict lint fails in two legacy files touched by the Observation cleanup. The same violations exist in the committed source before this cleanup.
- Reproduction: Run `swiftlint lint --strict --config ios/.swiftlint.yml` on `ios/moers festival/moers festival/Controller/Live/ActiveStreamViewController.swift` and `ios/moers festival/moers festival/News/LegacyPostViewModel.swift`.
- Errors: An unused enum payload pattern, an obsolete TODO, extra blank lines, and an explicit `nil` initializer for an optional property.
- Next step: Fix these style issues in a separate legacy news and stream cleanup.

## Festival bulletin setup uses ignored appearance settings

- Impact: The festival app build reports deprecation warnings for bulletin appearance settings. UIKit controls the sheet appearance and ignores these settings.
- Reproduction: Build the `moers festival` scheme. `OtherViewController.swift` and `LaunchInterceptor.swift` assign `backgroundColor`, `backgroundViewStyle`, or `edgeSpacing` on bulletin managers.
- Next step: Remove the ignored assignments in a scoped festival bulletin cleanup.

## Recovered city Events localization

- Status: The current Events controls use English keys with German translations. The review fix also changes the shared website action to `Open Website` and uses one locale-aware date formatter for list and detail.
- Original impact: Earlier recovered controls showed German search, date, and filter labels in English.
- Original reproduction: Launch City in English and open Events → Filter. The old labels included `Veranstaltungen suchen`, `Heute`, and `Morgen`.

## About screen has no navigation title

- Impact: The About screen has an empty navigation heading. Its SwiftUI `navigationTitle` does not reach the containing UIKit controller.
- Reproduction: Open Other → About on iOS 27.2. The navigation heading is blank, although `AboutScreen` declares `navigationTitle(Text("About"))`.
- Next step: Set the title on `AboutViewController` or forward the hosted view's navigation preferences to its parent.

## UI test locale helper uses deprecated properties

- Impact: Building the UI test target reports three deprecation warnings.
- Reproduction: Run the city `Navigation` test plan. `MoersUITests/UITestHelpers.swift` uses `Locale.languageCode`, `scriptCode`, and `regionCode` in its `currentLanguage` helper.
- Next step: Use the current `Locale.language` and `Locale.region` APIs in that helper.

## AssetPlayer does not populate static item metadata

- Impact: Constructing `AssetPlayer` with a nonempty playlist can access an empty metadata array and crash before playback starts.
- Reproduction: Use a `NowPlayable` implementation whose session-start method succeeds, then pass one `AVPlayerItem` to `AssetPlayer.init`. The initializer sets `staticMetadatas` to an empty array. `play()` calls `handlePlayerItemChange()`, which indexes that array with the current item's playlist index.
- Next step: Supply matching metadata for each player item and add a focused initialization test. This is separate from the media-selection API warning fix.

## Xcode 26.3 validation is pending

- The concurrency fixes pass local tests on iOS 18.6 and iOS 27.1 with Xcode 27 RC / Swift 6.4. Validation with CI's Xcode 26.3 toolchain remains pending.
- Next step: Run the app and dependency concurrency tests and the onboarding UI test on iOS 18.6 with Xcode 26.3.

## Existing SwiftLint errors outside the concurrency changes

- Impact: Linting the larger set of source files touched by explicit destructors exposes four existing errors. The same four errors are present in the branch's committed source before these edits.
- Reproduction: Run `swiftlint lint --config ios/.swiftlint.yml` for `Core/Entry/EntryManager.swift`, `Events/ViewModels/EventViewModel.swift`, `Feeds/UI/ViewController/PostsViewController.swift` under `ios/CityOS/Sources`.
- Errors: One legacy API variable name, two large tuples, and one count comparison. Refactor these separately; they do not affect the older-iOS runtime checks.

## Existing marketing lint errors block the standard check

- Impact: `npm run lint` stops at ESLint and does not run its TypeScript check. It reports 19 errors in unchanged component files. The output is identical with the dependencies on `master` and with the dependency updates from PRs #49, #50, and #51.
- Reproduction: With Node 22.14, run `cd marketing && npm ci && npm run lint`.
- Errors: `DeviceCarousel.tsx` has eight explicit `any` errors. `DeviceStill.tsx` has seven. `PhoneFrame.tsx` has two explicit `any` errors, one forbidden `require()` import, and one native image element error.
- Next step: Fix these component errors separately. Run `npm exec -- tsc --noEmit` to check TypeScript while the standard lint command is blocked. This check and the Storybook build pass with the proposed dependency updates.

## Festival view observers still use process lifecycle events

- Impact: Update refresh and event timers observe application events. These observers cannot distinguish the owning scene if multiple app windows are enabled later. The festival currently permits one app window.
- City impact: The city app already enables multiple scenes. Shared event timer and subtitle observers still use application events. The shared event-list controllers are separate from the current city Events tab, but remain available to package callers.
- Reproduction: Inspect the application notification observers in festival `Controller/TabBarController.swift`, and shared `Events/UI/EventsViewController.swift`, `EventsViewController_Legacy.swift`, and `EventSubtitleView.swift`. With multiple scenes enabled in a separate change, deactivate one scene while another stays active, then check update refresh and event timers in each window.
- Next step: Use the owning scene's lifecycle or SwiftUI scene phase. Do not replace the application notifications with unfiltered scene notifications. This is outside the AppDelegate migration in the resizability skill.

## City-only map layouts retain manual system and keyboard insets

- Status: The local city resizability changes remove fixed bar deductions, parent-drawer inset copies, and keyboard frame observers from the affected map flows. Forms use the keyboard layout guide. See `ios/RESIZABILITY.md` for validation and limits.
- Original reproduction: In the city app, open a map detail or an entry form, display the keyboard, and resize the window. The old `MapFeature` controllers could use stale geometry. Festival source uses its own map controllers and does not instantiate these surfaces.
- Remaining check: Verify a software keyboard while resizing on an iPad. Synthetic notifications from another window are covered by the focused tests; hardware keyboard input on the simulator cannot prove software keyboard clearance.

## Xcode device capture retains old geometry after a Duo fold change

- Update 2026-10-05: The CLI captures both displays when a display is selected explicitly. Use `simctl io <current-device> enumerate` to find the displays, then `screenshot --display=<id> <path>`. In this check, Screen 1 captured Closed and Screen 3 captured Open. The default display produced a black image. Both explicit captures were inspected. Discover IDs each session. Xcode DeviceInteraction session lookup and the native Screenshot action still failed.

- Impact: DeviceInteraction screenshots and hierarchy hit points can retain the closed display geometry after the app window becomes wider. This blocks screenshot-based validation through that tool.
- Reproduction: With Xcode 27.1 beta and an iOS 27.1 iPhone Duo simulator, capture the closed 466-by-678-point app window, select Open in DeviceHub, and capture again. The live app window becomes 951 by 669 points, but the tool produces a black image with the earlier geometry. Restarting the interaction session did not repair it in this check.
- Next step: Fix display selection in the Xcode interaction tool. Use the observed native DeviceHub UI as evidence until the tool can capture the current display.

## City resize loses navigation and Events filter state

- Update 2026-10-05: The City root now has one tab controller and one coordinator per section. The sidebar and size-trait activity replay are removed. This removes the source of resize-time navigation and filter transfer. Focused validation is in `ios/RESIZABILITY.md`. The process-wide activity fallback during scene restoration remains a separate issue; test two scenes when that fallback is changed.

- Impact: Changing between compact tabs and the regular sidebar can reset an Events filter or select a page that the person did not select.
- Reproduction: On iPhone Duo iOS 27.1, close the device, open Events, and apply the Today filter. Open the device: the filter is no longer active. Select Map in the regular sidebar, then close the device: Events becomes selected. The app process remains the same.
- iPad reproduction: On iPad Pro 11-inch (M5) iOS 27.2, open an event detail in the 1210-by-834-point landscape scene. Resize to a 375-by-651-point window: compact tabs appear, but the event detail is replaced by the Events list. The app process remains the same.
- Original source before 2026-10-05: `Moers/Common/ApplicationCoordinator.swift` restored from process-wide `UserActivity.current` on a size-class change. Its `currentEvents` selects separate compact and regular coordinators. `Moers/Config/SceneDelegate.swift` also uses the global activity as a restoration fallback. The global activity can belong to another window.
- Remaining next step: Move activity writers and the scene-restoration fallback to the owning scene, then test two windows. The tab root now keeps navigation and filter state during narrow/wide changes without a transfer between presentations.

## City Events horizontal sections enter the Duo system area

- Update 24 October 2026: The collection viewport now follows the horizontal safe area. Focused layout checks cover the viewport and its horizontal scrollers at 375- and 1024-point widths with asymmetric insets.

- Impact: Quick-filter chips can appear under the clock and Wi-Fi area. Im Fokus cards can appear under the floating Filter control.
- Reproduction: On the closed iPhone Duo iOS 27.1 simulator, open Events. The horizontal quick-filter row and featured-card section extend across the right inset. Regular event rows respect this area. The same defect is visible with the device open.
- Next step: Review the Events compositional sections and their orthogonal scroll clipping. Use each section's current available width and safe area. Keep the floating system controls clear at both Duo sizes.

## City cold widget URL is not handled on scene connection

- Impact: A news-widget link can be lost when it starts a new app scene.
- Reproduction: Source check: `Moers/Config/SceneDelegate.swift` handles `connectionOptions.userActivities` in `willConnectTo`, but does not handle `connectionOptions.urlContexts`. The warm `openURLContexts` callback opens a news article.
- Next step: Handle the initial URL contexts through the same coordinator route after window setup. Test a cold launch and an existing scene separately.

## City map address form has a negative street-field width

- Impact: Auto Layout cannot give the street field a valid width. The street and house-number controls can be misplaced.
- Reproduction: Open the city map entry Address step. In `MapFeature/Entry Onboarding/EntryOnboardingAddressViewController.swift`, the street field's trailing anchor is constrained to its own leading anchor minus 16 points. This constraint was present before the resizability changes.
- Next step: Constrain the street field to the house-number field and the form's safe area. Validate both layout directions with the keyboard visible.

## Festival programme day button wraps in the wide primary column

- Status: Fixed in the local 4 October 2026 date-strip change. Equal circles and single-line labels replace text compression. The row scrolls when the dates need more room. Five focused tests pass on iOS 18.6. The current Duo build shows all five dates on one line in the 340-point primary column; tapping `22` selects Friday and changes its events. See `ios/moers festival/RESIZABILITY.md` for the full check.
- Original impact: A two-digit day could use two lines in the programme date selector.
- Original reproduction: On iPhone Duo iOS 27.1, open the device and show Programme. In the 340-point primary column, day `22` wraps onto two lines. The device check observed this in the installed build before the Info & Tickets follow-up.
- Original next step: Check the date selector's available width and text compression in the primary column. Keep each day number on one line and verify all five date buttons at narrow and wide widths.

## Festival Info list reset after device snapshot operations needs isolation

- Impact: A later Info overview moved to the top while About and the Info tab remained selected. The immediate fold check had retained the same list position. The cause is not established.
- Reproduction observed on 3 October 2026: On Duo iOS 27.1, scroll the wide Info list, select About, and fold Closed/Open. The immediate before/after hierarchy placed Volunteers at y=74.7 points. After device snapshot/session operations and native window reselection, the list was at the top. The app process remained PID 3565; no agent Info scroll occurred between those observations.
- Validation limit: The comparison with native controls only could not start. Device Hub selected another device window on two recovery attempts; guards stopped before input. Live nested web input was also blocked by a failed hierarchy tap and `windowNotFoundAtPosition` from the coordinate fallback.
- Next step: Repeat the fold and window-focus round trip with Duo as the only active Device Hub window, without snapshot sessions between inputs. If the native-only run resets the list, trace overview reconstruction, scroll-to-top/drag callbacks, and scroll-range clamping. Do not attribute the reset to the app or the tools without that comparison.

## Xcode workspace device session expires during install and run

- Impact: The workspace interaction tool cannot confirm installation and launch after a successful build.
- Reproduction on 4 October 2026: Create a festival workspace session for the booted Duo iOS 27.1, then call InstallAndRun with its returned key. Two bounded attempts reported that the session key no longer existed. Xcode's current build log showed success with no errors and no build still running.
- Workaround: Install the exact simulator app from the current build log and launch it through simulator tooling, then use a standalone device session for capture. This launched the current festival app as PID 31620 without an app-data reset.
- Next step: Check the Xcode interaction service's session lifetime across the build/install operation.

## Shared location manager uses an invalid property on watchOS

- Impact: `Core.LocationManager` cannot compile for watchOS. Its watchOS initialization branch uses `self.locationService`, but the class stores a `CLLocationManager` in `self.locationManager`. This reference was present before the availability cleanup.
- Reproduction: Build the CityOS `Core` target for a watchOS simulator. The branch in `ios/CityOS/Sources/Core/LocationManager.swift` references a member that the class does not define.
- Next step: Use the stored location manager and run a focused watchOS build. Keep this correction separate from the availability cleanup.

## Package lockfiles do not match their BulletinBoard requirements

- Status: The review fix pins BulletinBoard `6.2.0` in the City workspace and both app project lockfiles. Other dependency versions match the baseline. The focused City checks pass with automatic resolution disabled; the Festival check is recorded in `ios/EVENTS.md`.

- Impact: A festival build that disables automatic package resolution fails before compilation. Both app projects require BulletinBoard `6.2.0..<7.0.0`, but the festival project lockfile and the city workspace lockfile pin `6.1.1`.
- Reproduction: Build the festival project with `-disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile`. Xcode reports an out-of-date resolved file. Adding `-skipPackageUpdates` without those flags also fails when the local cache lacks the published `6.2.0` tag.
- Validation: Package resolution used `6.2.0` for the city tests and festival simulator build. Both passed. The original lockfiles were restored because dependency changes are outside the availability cleanup.
- Restoration limit: A background process regenerated the city workspace lockfile after restoration while two Xcode versions were open. The writer was not identified. Do not stop unrelated Xcode work to prevent this write.
- Next step: Update the city workspace and festival project lockfiles to the version already required by their projects in a separate dependency change.


## City rubbish migration uses the hour as the minute

- Status: The review fix passes `reminderMinute` to the minute argument. Focused validation is recorded in `ios/EVENTS.md`.

- Impact: After a person selects a replacement rubbish street in the migration bulletin, a reminder set to 20:30 can be scheduled for 20:20.
- Reproduction: Enable rubbish reminders with hour 20 and minute 30. Use a saved street that is absent from the loaded street list. Select a replacement street in the migration bulletin. Inspect the scheduled notification time.
- Source: `Moers/Common/AppTabBarController.swift`, `makeRubbishMigrationPage()`, passes `reminderHour` to both notification time arguments. The same call was present in the removed `AppSplitViewController`.
- Original next step: Pass `reminderMinute` to the minute argument and add a focused migration reminder test.


## City Settings shows an untranslated rubbish heading

- Status: Fixed in the local localization change. Both Settings controllers use `Pick-up Schedule`, with the German translation retained in the City catalog.
- Impact: English Settings shows `SettingsRubbishCollectionTitle` as the section heading.
- Reproduction: Launch City in English, open Other, then Settings. Inspect the rubbish section heading. This was observed on the Duo simulator during the tab navigation check.
- Source: Both City Settings controllers request `String.localized("SettingsRubbishCollectionTitle")`.
- Next step: Add or repair that key in the City localization resources, then check both Settings controllers. The navigation change does not modify localization resources.

## Fuel configuration tests require the old Xcode project format

- Impact: Two fuel configuration script tests fail before checking the script. They expect `project.pbxproj`, but the projects now use `project.xcproj`.
- Reproduction: Run `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s ios/scripts/tests -p test_prepare_fuel_api_key.py -v`. The two project-wiring tests fail with `FileNotFoundError`.
- Next step: Read the current Xcode project format in these tests. Keep this test repair separate from localization.

## Festival venue navigation returns to the event detail during capture

- Impact: The localization check could not verify the venue programme heading through the event-location route.
- Reproduction observed on 5 October 2026: In the English app on iPhone 18 Pro, iOS 27.2, open Schedule, open a WDR Big Band event, tap its metadata row, then tap Location. Venue events appeared in the transition hierarchy, but the next capture showed the event detail again. One retry gave the same result. The app remained running.
- Validation limit: This check used the Xcode device interaction tool. It does not establish whether app navigation or capture timing caused the return.
- Next step: Repeat the route with native interaction, then inspect the event and venue coordinator transitions if the return persists.

## Shared event detail uses iOS-only colours in the tvOS build

- Update 24 October 2026: Shared event detail now uses the existing platform theme and tvOS colour fallbacks. The festival tvOS simulator build passes with signing disabled. The iOS semantic colours are unchanged.

- Impact: The festival tvOS target cannot compile its shared event-detail dependency. This blocks full tvOS app validation and compiler extraction from the app target. Its localization catalog compiles separately.
- Reproduction: Build workspace `ios/Moers.xcworkspace`, scheme `moers festival tvOS`, configuration Debug, with destination `generic/platform=tvOS Simulator`. `Events/UI/View/EventDetailView.swift` uses `systemBackground`, `systemGray6`, `secondarySystemFill`, `secondarySystemBackground`, and `tertiarySystemFill`, which are unavailable on tvOS.
- Baseline: These colour calls were present before the localization change.
- Next step: Use colours available on the owning platform, then build the tvOS target and run the localization extraction check for its compiler output.

## City course description joins adjacent labels

- Impact: Some course details are difficult to read because adjacent labels have no separating space or line break.
- Reproduction: On iPhone 18 Pro, iOS 27.2, launch City in English, search Events for `Stadtarchiv`, open the 6 October 2026 result, and scroll to its course details. The text includes `Kurs-Nr.: I10108Teilnahmegebühr: 2 EuroDozentin: Alena Saam`.
- Scope: The review fixes do not change the description publisher or its text-view assignment. The device check does not establish whether the API text or rendering removes the boundaries.
- Next step: Compare the event's API description with the displayed text, then preserve paragraph and line-break boundaries in the owning layer.

## City event controller tests require English labels

- Impact: Four controller tests fail with five text assertions when the app test host uses German. These failures do not show an app defect.
- Reproduction: On a simulator that uses German, run the `WidgetsExtension` scheme and test plan with `-only-testing:'Moers Unit Tests/EventsViewControllerTests'`. The assertions expect `Today`, `Tomorrow`, `No events found`, and `Events could not be loaded`, but the app uses translated text. The test plan has no language setting.
- Evidence: All six controller tests and five event filter tests pass when the test-plan configuration sets `options.language` to `en`. The temporary language setting was removed after validation.
- Next step: Set an explicit language in the app test plan, or compare the labels with localized expected text.

## MapKit simulator worker can stop hosted map tests

- Impact: One focused test run stopped in a VectorKit worker and the Xcode test process did not finish. The isolated tab resize test passed on retry.
- Reproduction observed on 9 October 2026: With Xcode 27.1 RC and the iOS 27.0 iPad Pro simulator, run `MapSheetPresentationTests` followed by `TabNavigationResizabilityTests` through the `WidgetsExtension` test plan. The 16 sheet tests passed. During the tab resize test, the app stopped with `EXC_BAD_ACCESS` at `gdc::LayerDataSource::updateLayerData`; the crash stack contained no app frames. This occurred once and is not a confirmed app defect.
- Next step: Repeat with a stable Xcode release. If the failure repeats, isolate MapKit view teardown in a small app and report the worker crash to Apple.

## Today dashboard shows data load errors

- Impact: The Today dashboard cannot show one data card and its free parking data. It displays raw `Core.APIError error 1` and `NSURLErrorDomain error -1015` messages.
- Reproduction observed on 9 October 2026: On iPhone 18 Pro, iOS 27.2, open Map, search for Shell with a Diesel category token, open a result, go Back, then select Today. The fuel card loads, but the other two cards show these errors. The app remains running and Map search still works.
- Validation limit: This was observed during native search verification. The check does not establish whether the service response or the app's response handling caused the errors.
- Next step: Check the failed Today data requests and their response formats, then show a useful retry state in the owning cards.

## Xcode can stall after reporting a failed iOS 18 test

- Impact: A focused test command can keep automation waiting after it prints the test result.
- Reproduction observed on 9 October 2026: With Xcode 27.1 RC and the iOS 18.6 iPhone 16 Pro simulator, run the compact-search tests through the `WidgetsExtension` test plan. After a failed native-control width assertion, both tests finished, but `xcodebuild` did not exit for more than three minutes. The last log entries reported `IDESchemeActionSDKRecord` with `invalidDigitCount(94232)`. This does not establish the cause of the stall. Interrupt did not stop the command; the exact test process was then terminated.
- Next step: Check result completion with a stable Xcode release. If the stall repeats, collect Xcode's result-processing logs and report the issue to Apple.


## UIKit review follow-ups (22 October 2026)

Eight independent fixes are covered by the UIKit review PRs: Info URL parameters (#68), event detail lifetime and observation (#69), saved entry recovery (#70), retained news card refresh (#71), venue detail lifetime (#72), Settings lifetime (#73), trip planner lifetime (#74), and outdated stop-search results (#75). Paths below use the current feature branch; `master` still uses the `MMFeeds` and `MMEvents` package names.

- **Map entry location picker keeps a location stream running.** Impact: Closing the picker can retain its controller and continue location work. Reproduction: Open and close `MapFeature/Controller/MapLocationPickerViewController` with authorized location access. Its untracked task captures the controller while it consumes nested authorization and location streams; the inner stream also blocks later authorization changes. Next step: Give each stream a stored task, cancel on teardown, and test release and authorization changes with controlled streams. Keep this separate from the existing local map changes.
- **Festival scene quick actions do not finish their callback.** Impact: The system does not receive the result of a home-screen quick action. Reproduction: On the current feature branch, invoke `SceneDelegate.windowScene(_:performActionFor:completionHandler:)` with a completion spy. It routes the item but never calls the completion. Next step: Return the route result through the callback once and add a focused test. The scene migration is not yet on `master`.
- **Legacy shared event overview can duplicate an identifier.** Impact: Applying its diffable snapshot can fail for a liked future event. Reproduction: Use `Events/UI/EventsViewController` overview with an event present in both favorites and upcoming events. Both sections append the same event identifier. Current app coordinators do not call this old overview factory. Next step: Use placement-specific IDs or remove the unused route in a separate change, with a duplicate-placement test.
- **Trip search uses a fixed five-hour delay.** Impact: Search requests use a departure five hours after the current time. Reproduction: Capture `EFAUI/Trip/TripSearchViewModel.search()` request arguments; `tripDate` is `.departure(Date().addingTimeInterval(5 * 60 * 60))`. Next step: Confirm the intended time-selection behavior, then add a request-capture test and a separate travel-logic fix.
- **City Events redesign clips large accessibility text.** Update 24 October 2026: Quick filters and spotlight cards now size from their content. Accessibility text uses full-width vertical rows, and spotlight labels use their final width when calculating height. Focused checks cover normal and largest accessibility text sizes. Original impact: Quick-filter labels cannot fit their fixed-height row; spotlight text can also be compressed. Reproduction on the unpublished feature branch: Open Events on a narrow phone with the largest accessibility text size. `EventsViewController.quickFilterSectionLayout()` uses a 34-point height while the Dynamic Type label needs its text height plus 16 points of vertical insets. Spotlight uses a fixed 138-point group with growing text and a square image. Next step: Use content-driven or estimated heights, add large-text layout checks, and verify narrow and wide windows. Keep this separate from the master-based UIKit fixes because the redesign is not on master.

- **Festival venue header and Tickets page were blank during the review.** Impact: The user can open the venue programme but cannot see its venue name/header; the Tickets web view shows no page. Reproduction observed on 22 October 2026: In the combined master-based UIKit review build on iPhone Air, iOS 27.2, open Schedule → WDR Big Band → metadata → Location. Event rows load, but the header is blank on two captures. Open Info → Tickets: the web view stays black on two captures; Back works. The app process stays alive. Validation limit: The venue header uses the separate, unchanged `showVenue` request; event rows use the local store. No useful console error was available. These observations do not establish an app regression or a service failure. Next step: Inspect both request responses and compare the same routes on the published app before changing their presentation or error states. Evidence is stored in the local UIKit review report.

- **City Add entry method buttons are invisible in light appearance.** Impact: The user cannot see either way to start an entry. Reproduction observed on 22 October 2026: In the combined master-based UIKit review build on iPhone Air, iOS 27.2, light appearance, open Other → Add entry with no saved draft. The current-location and address buttons exist in the accessibility hierarchy, but neither is visible in two stable screenshots. Tapping the address button through its hierarchy frame opens the empty address form; Back works. No data was entered or submitted. Source: `MapFeature/Entry Onboarding/EntryOnboardingLocationMenuViewController` uses `CoreViewFactory.button()` and has an empty `setupTheming()`. Next step: Check the inherited button colours in light and dark appearance, apply semantic button configurations, and add focused contrast and large-text layout checks. Keep this presentation change separate from saved-draft recovery.

- **Festival selected Info row has an unreadable title in light appearance.** Impact: The selected topic cannot be identified by its visible title. Reproduction observed on 24 October 2026: On iPad Pro 13-inch (M5), iOS 27.2, open Info → Licenses in the wide layout. The selected overview row has a black background and an invisible title; its icon and chevron remain visible. The state remains after scrolling the license document and taking a second capture. The license text itself is readable after the safe-area constraint fix. Next step: Check selected-state text and background colours in the Info collection cells in light and dark appearance. Evidence: `/Users/lennart/.codex/visualizations/2026/10/24/01a16f16-5279-7aa2-9925-c432f90a9417/licenses-wide-fixed.png` and `licenses-wide-scrolled.png`. Keep this row styling fix separate from license text layout.

## Parking area filter does not change the live grid

- Observed: Source review on 24 October 2026 during branch cleanup.
- Impact: The Open filter can leave closed parking areas visible.
- Reproduction: Open the city parking list and select the Open filter. The picker changes `ParkingAreaListViewModel.filter`, but `ParkingAreaList.freeLiveParkingAreasGrid()` still renders all `viewModel.parkingAreas`. The model does not apply the filter.
- Source: `ios/CityOS/Sources/ParkingFeature/UI/ParkingAreaList.swift` and `ParkingAreaListViewModel.swift`.
- Next step: Apply the selected filter and add focused tests for open areas, all areas, and an empty result. A partial older change is preserved under `archive/2026-10-24/light-mode`; the full old theme branch was not merged.


## Live accessibility text-size change leaves the Events search bar height stale

- Observed: iPhone 18 Pro, iOS 27.2, Xcode 27.2 RC, on 24 October 2026.
- Impact: Changing from standard text to the largest accessibility size while Events is open can leave the first quick filter under the native search field.
- Reproduction: Open Events at the standard text size, then change the simulator content size to accessibility-extra-extra-extra-large. The stacked search field grows to 124 points while the navigation bar retains its earlier 108-point height. The first filter starts at y=174 under the field ending at y=240. Pulling to the top does not correct it.
- Validation limit: A fresh launch at the same accessibility size has a 188-point navigation bar and puts the first filter at y=254. Weighted Event labels and newly created filter cells now scale correctly. This observation does not identify an app or UIKit cause.
- Next step: Compare an isolated standard UISearchController on the same runtime and a stable Xcode/runtime pair before adding a navigation-bar workaround.


## Events loading calls an unavailable inclusive Date operator

- Fixed on 24 October 2026 during Events integration.
- Impact: On one installed pre-release iOS 27.2 runtime, opening Events crashed during the first page callback. Navigation automation then reported missing search/filter controls because the app had exited.
- Evidence: The main-thread crash reaches Date.>= from EventsViewController.visibleEvents(). Disassembly shows the SDK back-deployment thunk taking its iOS 27.2 path and calling a weak operator symbol that resolves to null on that runtime.
- Fix: Inclusive Date comparisons in the city and shared Events code now compare timeIntervalSinceReferenceDate values. Inclusive boundaries, stable strict comparisons, nil handling, and sorting remain the same.
- Validation: All 47 focused city tests and all four navigation UI tests pass on the same iPhone 17 simulator that exposed the crash. The shared date/favorites run has 28 passing tests and 10 existing locale-dependent skips.


## Event subtitle tests skip under the English test plan

- Observed: 24 October 2026, FullTestPlan, Configuration (English, No Thread Sanitizer).
- Impact: Ten legacy event-view-model subtitle assertions do not run, so that run does not prove their formatting behavior.
- Reproduction: Run EventsTests/EventViewModelTests. Locale.isNotEnglish() checks whether Locale.current.identifier contains "en-". An English identifier using an underscore, such as en_US, is treated as non-English and triggers XCTSkip.
- Source: ios/CityOS/Tests/EventsTests/ViewModel/EventViewModelTests.swift.
- Next step: Check the locale's language code, then run the subtitle tests with an explicit locale. Keep this correction separate from the date-operator compatibility fix.

## Festival widget version warning

- Observed: 25 October 2026 while building the event-detail change for an iOS simulator.
- Reproduction: Build the `moers festival` scheme in Debug. Xcode reports that the embedded extension's `CFBundleShortVersionString` is `1.0`, while the parent app uses `2.4.4`.
- Impact: The build succeeds but reports inconsistent app and extension version metadata. Distribution validation was not run.
- Next step: Align the extension's short version with the parent app in a separate configuration change.

## Festival image cards without artwork overlap adjacent rows

- Observed: 25 October 2026 on iPhone 17, iOS 27.2, during day-navigation checks.
- Reproduction: Launch the Festival app with `-currentEventDisplayMode 1`, then select May 22. Rows without artwork, including `Event-Row-590`, have a 52-point cell height while their metadata extends above the cell. Its venue label starts at y=672.3, above the cell's y=716.3 origin.
- Impact: Event titles and venue labels overlap adjacent rows. Day taps and page swipes still work.
- Source area: `ios/CityOS/Sources/Events/Events/EventCard.swift` and `ios/CityOS/Sources/Events/Events/Overview/TimetableDayPageCell.swift`. These files were unchanged by the haptic work. The card uses an optional image and negative top padding for its metadata.
- Next step: Check card sizing without artwork and the hosted cell's measured height. Add an empty-artwork preview and a focused sizing check when fixing this layout.


## DeviceHub input blocks the event-header gesture check

- Observed: 25 October 2026, Xcode 27.2 and Duo iOS 27.2, after installing the soft-edge event-detail build.
- Reproduction: A newly created Xcode interaction session can immediately return `Session not found` on capture. Native DeviceHub hierarchy reads, event-row clicks, and direct simulator screenshots work, but scroll and drag input in the expanded window returns `noWindowsAvailable`. In the compact window, a drag showed a temporary scroll indicator without moving the event content.
- Impact: The artwork's top state can be inspected, but this tool run cannot prove title-bar behavior during live finger scrolling. The mounted-scene test with a long article passes for downward scroll, continued scrolling in both directions, and return to the image.
- Next step: Repair the DeviceHub input route or repeat the gesture check with a working native UI driver. Do not attribute this input failure to the app without that check.
- Follow-up on 25 October 2026: Native scrolling in the compact event detail and Closed → Open resizing now work. A live split-divider check is still blocked: setting the splitter value left it at 34 percent, and the native drag retry returned `noWindowsAvailable`. The same event remained readable after opening Duo. Scene-based resize tests pass on Duo and iPad; repeat the divider drag with a working DeviceHub input route to complete that manual check.
- Header layout follow-up on 25 October 2026: After replacing extension scaling with layout-based stretching, native scrolling and Closed → Open resizing work, with one 16-point text margin. Recorded native-drag and device-touch pull attempts in the open display left the artwork unchanged. The recordings are labelled `no-pull`; they cannot prove transient seam removal. Held rendered tests pass at 30-, 120-, and 240-point pulls with either side inset, including a full-width scan for displaced seams. Repeat live pull-and-release with a working touch input route to complete animation acceptance.
