# moers festival Android Feature Parity Guide

## Scope

This guide compares the Android festival app in `moers-festival-android` plus its feature modules against the iOS phone app in `ios/moers festival`.

The goal is Android phone parity with the iOS phone app. Separate Apple-only targets like watchOS and tvOS are noted where useful, but they are not treated as parity blockers for the Android app.

The comparison is based on the current repository state on 2026-04-05.

## Current Android Baseline

The Android app already covers the core festival navigation and most read-only content flows:

- `News` tab with pull-to-refresh and post detail flow.
- `Map` tab with festival layers, booth/place search, place detail, and event drill-in.
- `Favorites` tab with persisted liked events.
- `Timetable` tab with daily sections and event detail.
- `Info` tab with festival links, download entry point, legal, and app information.
- Manual timetable/content download flow.
- FCM notification display and custom-scheme deep links such as `moersfestival://events/{id}`.

That means parity work should focus less on rebuilding the basic app shell and more on missing iOS behavior around onboarding, notifications, location, quick access, richer content rendering, and a few missing user flows.

## Parity Summary

| Area | Android Status | iOS Status | Parity Assessment |
| --- | --- | --- | --- |
| Top-level app structure | Implemented | Implemented | Near parity |
| News list and post detail | Implemented | Implemented | Near parity |
| Timetable and event detail | Implemented | Implemented | Near parity |
| Favorites list | Implemented | Implemented | Missing filter controls |
| Festival map | Implemented | Implemented | Missing location-aware behavior and some polish |
| Info & Tickets | Partial | Richer iOS implementation | Missing secondary screens and utilities |
| Offline content download | Implemented manually | Implemented + prompted on first launch | Missing first-run flow |
| Push notifications | Basic FCM display | FCM + onboarding + topic subscription + silent refresh | Important gap |
| Deep linking | Custom scheme only | Universal links + quick actions + user activities | Important gap |
| Widgets / home screen surfacing | Missing | Implemented | Clear parity gap |
| Page block rendering | Partial | Richer native page rendering | Clear parity risk |
| Localization breadth | EN/DE only in Android app resources | iOS has broader localization footprint | Medium gap |

## What To Implement First

### 1. Fix notification parity end-to-end

This is the most important gap because it affects user-facing communication and background freshness.

#### What iOS does

- Requests notification permission as part of the onboarding flow.
- Subscribes the device to the shared FCM topic `all`.
- Handles push taps and deep links.
- Handles silent/background refresh payloads for `events` and `maps`.

Relevant iOS references:

- `ios/moers festival/moers festival/Model/BulletinBoard/PermissionsManager.swift`
- `ios/moers festival/moers festival/SceneDelegate.swift`
- `ios/moers festival/moers festival/AppDelegate.swift`

#### What Android currently does

- Fetches the FCM token in `MainApplication`.
- Displays notifications in `MessagingService`.
- Requests notification permission directly in `MainActivity`.
- Handles deep-link style notification targets.

But Android currently does **not**:

- subscribe to the shared topic `all`;
- handle data-only or silent refresh payloads like `refresh_content=events` / `refresh_content=maps`;
- show a real rationale flow if notification permission was denied once.

Relevant Android files:

- `moers-festival-android/src/main/java/com/lambdadigamma/moersfestival/MainApplication.kt`
- `moers-festival-android/src/main/java/com/lambdadigamma/moersfestival/MainActivity.kt`
- `moers-festival-android/src/main/java/com/lambdadigamma/moersfestival/notifications/MessagingService.kt`

#### Required work

- Subscribe Android clients to `FirebaseMessaging.getInstance().subscribeToTopic("all")`.
- Decide where to do topic subscription:
  - after notification opt-in if you want strict consent symmetry with iOS; or
  - on first launch if topic delivery should work regardless of local permission state.
- Handle `remoteMessage.data["refresh_content"]` and refresh:
  - event cache via `EventRepository.refreshEvents()`;
  - map archive via the festival map repository refresh path.
- Add a proper rationale surface before re-requesting notification permission.
- Keep deep-link notification handling, but make the refresh path work even when no visible notification is shown.

#### Acceptance criteria

- Android devices receive the same broadcast notifications as iOS.
- A push with `deep_link` opens the correct screen.
- A silent or data-only refresh updates events/maps without requiring manual refresh.

### 2. Add first-run onboarding for festival basics

The iOS app does more than just show the main tabs. It actively guides the user through setup and prompts them to download the festival content.

Relevant iOS references:

- `ios/moers festival/moers festival/Controller/LaunchInterceptor.swift`
- `ios/moers festival/moers festival/Model/BulletinBoard/BulletinDataSource.swift`

#### Android gap

Android opens directly into the app and immediately asks for notification permission. There is no first-run explanation, no one-time download prompt, and no contextual setup flow.

#### Required work

- Add a one-time first-launch coordinator or modal flow in `App.kt` / `MainActivity.kt`.
- Include:
  - a short festival intro;
  - notification rationale;
  - optional location rationale;
  - a one-time prompt to open the download screen.
- Persist completion in local storage, similar to iOS `showedDownload`.

Relevant Android touchpoints:

- `moers-festival-android/src/main/java/com/lambdadigamma/moersfestival/App.kt`
- `moers-festival-android/src/main/java/com/lambdadigamma/moersfestival/MainActivity.kt`
- `modules/festival-events/src/main/java/com/lambdadigamma/events/presentation/download/DownloadScreen.kt`

#### Acceptance criteria

- New users are guided through notification and content-download setup once.
- Returning users are not repeatedly prompted.

### 3. Bring the map up to iOS location parity

The Android map is functionally solid, but it currently behaves like a static festival map rather than a location-aware festival assistant.

#### What iOS does

- Shows the user’s location on the map.
- Requests location permission contextually.
- Uses location-aware map affordances around venue discovery and navigation.

Relevant iOS references:

- `ios/moers festival/moers festival/Venues/Controllers/NewMapViewController.swift`
- `ios/moers festival/moers festival/Controller/LaunchInterceptor.swift`

#### What Android currently does

- Declares location permissions in the manifest.
- Has a reusable `LocationService`.
- Does not request location permission in the festival app flow.
- Does not enable `myLocation` on the Google Map.
- Hides the default my-location button.

Relevant Android files:

- `moers-festival-android/src/main/AndroidManifest.xml`
- `modules/festival-map/src/main/java/com/lambdadigamma/map/presentation/composable/FestivalMapView.kt`
- `modules/core/src/main/java/com/lambdadigamma/core/geo/LocationService.kt`

#### Required work

- Add a contextual permission flow for location.
- Enable user-location rendering on the map after permission is granted.
- Add a clear “center on me” affordance instead of leaving location hidden.
- Verify place detail and navigation still work cleanly when no permission is granted.

#### Acceptance criteria

- Users can grant location access from the map flow.
- The map can show the current user position and jump back to it.
- No hard failure occurs when permission is denied.

### 4. Add favorites filtering parity

The Android favorites tab lists favorite events, but it does not yet match iOS filtering behavior.

#### What iOS does

- Lets the user filter favorites by venue.
- Persists that filter.
- Shows active-filter state and lets the user clear it quickly.

Relevant iOS reference:

- `ios/moers festival/moers festival/User Schedule/UserScheduleViewController.swift`

#### What Android currently does

- Groups favorites by day.
- Supports refresh and empty states.
- Has no filter UI or persisted favorites filter.

Relevant Android files:

- `modules/festival-events/src/main/java/com/lambdadigamma/events/presentation/favorites/composable/FavoriteEventsScreen.kt`
- `modules/festival-events/src/main/java/com/lambdadigamma/events/presentation/favorites/FavoriteEventsViewModel.kt`

#### Required work

- Add a filter model for favorites, at minimum by venue.
- Add filter entry points in the favorites top app bar.
- Persist the filter locally.
- Mirror iOS behavior for “filter active” state and clear action.

#### Acceptance criteria

- Users can filter favorites by venue.
- The filter survives app restarts.
- Empty states distinguish between “no favorites yet” and “no favorites for this filter”.

## Next Priority Work

### 5. Add verified HTTP app links and launcher shortcuts

Android already has custom-scheme deep links. iOS goes further with universal links and launcher quick actions.

Relevant iOS references:

- `ios/moers festival/moers festival/ApplicationController.swift`
- `ios/moers festival/moers festival/Config/ShortcutConfiguration.swift`
- `ios/moers festival/moers festival/SceneDelegate.swift`

#### Android gap

- Only `moersfestival://...` links are declared.
- No verified `https://moers.app/...` app-link handling.
- No launcher shortcuts for `News`, `Events`, or `Favorites`.

#### Required work

- Add Android App Links for relevant web URLs.
- Route those URLs into the existing navigation graph.
- Add dynamic or static launcher shortcuts for:
  - News
  - Events
  - Favorites

Relevant Android touchpoints:

- `moers-festival-android/src/main/AndroidManifest.xml`
- navigation factories under `modules/festival-news`, `modules/festival-events`, `modules/festival-map`

#### Acceptance criteria

- Tapping supported `https://moers.app/...` links can open the app directly.
- Long-pressing the launcher icon exposes quick entry points comparable to iOS.

### 6. Expand the Info & Tickets area

Android currently covers the main festival links, but the iOS Info area is still richer.

#### iOS extras worth bringing over

- Licenses screen.
- A fuller About screen.
- Review/developer links if they are still wanted product-wise.

Relevant iOS references:

- `ios/moers festival/moers festival/Controller/Other/OtherViewController.swift`
- `ios/moers festival/moers festival/Coordinator/OtherCoordinator.swift`
- `ios/moers festival/moers festival/Controller/Other/AboutController.swift`

#### Android gap

- `InfoScreen.kt` exposes only festival links plus legal and app information.
- `AppInformationScreen.kt` is text-only and does not cover licenses or secondary actions.

Relevant Android files:

- `moers-festival-android/src/main/java/com/lambdadigamma/moersfestival/InfoScreen.kt`
- `moers-festival-android/src/main/java/com/lambdadigamma/moersfestival/ui/AppInformationScreen.kt`

#### Recommendation

Treat this as medium priority. It matters for completeness, but it is less critical than notifications, onboarding, map location, and favorites filtering.

### 7. Close the page-rendering gap before content starts drifting

This is the biggest hidden technical parity risk.

#### Android current state

The Android `pages` module declares several block types:

- `youtube-video`
- `soundcloud`
- `externalLink`
- `link-list`
- `tip-tap-text-with-media`
- `image-collection`

But the current deserialization and rendering only support:

- `TextBlock`
- `ImageCollectionBlock`

Relevant Android references:

- `modules/pages/src/main/java/com/lambdadigamma/pages/data/remote/model/BlockType.kt`
- `modules/pages/src/main/java/com/lambdadigamma/pages/data/mapper/BlockDataMapper.kt`
- `modules/pages/src/main/java/com/lambdadigamma/pages/presentation/PageBlockRenderer.kt`

#### Why this matters

Event pages, venue pages, and news detail pages all depend on page blocks. If the CMS starts using link lists, external links, audio, or video blocks that iOS already renders correctly, Android will silently fall behind.

#### Required work

- Audit which page block types are currently emitted by the festival backend.
- Implement Android renderers for any block types that are already used in production.
- Keep page rendering consistent across:
  - event detail pages;
  - venue detail pages;
  - native news pages.

#### Priority note

If the backend currently uses only text and image blocks, this can remain medium priority. If any unsupported block types are already live, it becomes a release blocker.

### 8. Add Android home-screen widgets

The current iOS codebase includes a widget extension with:

- an upcoming events widget;
- a favorites widget;
- favorites sync into the shared widget store.

Relevant iOS references:

- `ios/moers festival/Widgets/Upcoming/UpcomingWidget.swift`
- `ios/moers festival/Widgets/Favorites/FavoritesWidget.swift`
- `ios/moers festival/Shared/Widgets/WidgetFavoritesSyncBridge.swift`

#### Android gap

There is no Android widget or glance/appwidget surface for upcoming or favorite events.

#### Required work

- Add one or two Android widgets:
  - upcoming events;
  - favorite events.
- Back them with the existing Room data and favorites state.
- Refresh widget data after:
  - content download;
  - favorites changes;
  - event refreshes.

#### Recommendation

This is a real parity gap, but it can follow the P0 app-flow work unless widget parity is a release requirement.

### 9. Review localization parity

The Android app resources are clearly set up for English and German. The iOS app has a broader localization footprint, including French resources.

#### Recommendation

- Confirm which languages are product requirements for the festival app.
- If French is still supported on iOS, plan equivalent Android strings and QA.
- Treat this as a structured follow-up after the core feature gaps are closed.

## Suggested Implementation Order

### Phase 1: parity blockers

1. Notification topic subscription and silent refresh.
2. First-run onboarding and download prompt.
3. Map location permission and current-location support.
4. Favorites filtering.

### Phase 2: user-facing completeness

1. Verified HTTP app links.
2. Launcher shortcuts.
3. Info & Tickets expansion.
4. Page-block support audit and gap closure.

### Phase 3: platform-level parity extras

1. Android home-screen widgets.
2. Localization expansion.

## Recommended Acceptance Checklist

- Broadcast notifications sent to the festival audience reach Android devices.
- Notification taps and deep links open the intended screen.
- Event and map data can be refreshed without manual user intervention when the backend signals changes.
- First-run users are guided to enable notifications and download festival content.
- Map can show the user’s current position and recover gracefully when permission is denied.
- Favorites can be filtered and the filter persists.
- `https://moers.app/...` links can open the Android app directly.
- Android renders every page block type that is currently used by festival content.
- If widget parity is in scope, Android exposes upcoming/favorites widgets comparable to iOS.

## Non-Goals For Android Phone Parity

These should not block Android phone parity unless product explicitly asks for them:

- watchOS companion behavior from `ios/moers festival/moers festival Watch App`
- tvOS app behavior from `ios/moers festival/moers festival tvOS`
- internal staff/admin tooling unless Android needs the same operational workflow

## Bottom Line

The Android app already has the right tab structure and most of the main festival flows. The missing work is concentrated in cross-cutting behavior rather than basic screen count.

If we want Android to feel equal to iOS for real users, the highest-value work is:

1. make notifications actually equivalent;
2. add onboarding and offline-download guidance;
3. make the map location-aware;
4. close the favorites-filter gap;
5. add quick-access surfaces like app links, shortcuts, and widgets.
