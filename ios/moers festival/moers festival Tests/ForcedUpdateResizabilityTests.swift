import AppUpdateFeature
import Core
import FactoryKit
import SwiftUI
import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class ForcedUpdateResizabilityTests: XCTestCase {
    func testLatestUpdateRequestWinsWhileMapPresentationIsPending() async throws {
        let tabs = makeTabs()
        let map = tabs.map.mainViewController
        tabs.loadViewIfNeeded()
        tabs.selectedViewController = map
        map.traitOverrides.horizontalSizeClass = .compact
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        window.rootViewController = tabs
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(tabs.view)
        map.drawerDidSelectVenue(FestivalPlaceRowUi(id: -101, name: "Venue", description: "", timeInformation: nil))
        tabs.updateForcedUpdateSheet(presentation(version: "First", allowsDismissal: false))
        tabs.updateForcedUpdateSheet(presentation(version: "Latest", allowsDismissal: true))
        await settle(tabs.view)
        let sheet = try XCTUnwrap(tabs.presentedViewController as? UIHostingController<AppUpdateSheetView>)
        XCTAssertFalse(sheet.isModalInPresentation)
        XCTAssertFalse(map.presentedViewController is NewMapDrawerViewController)
        tabs.updateForcedUpdateSheet(nil)
        await settle(tabs.view)
        XCTAssertNotNil(map.presentedViewController as? NewMapDrawerViewController)
        map.suspendDrawerPresentation()
        await settle(tabs.view)
    }

    func testCancelledPendingUpdateRestoresMapWithoutShowingUpdate() async throws {
        let tabs = makeTabs()
        let map = tabs.map.mainViewController
        tabs.loadViewIfNeeded()
        tabs.selectedViewController = map
        map.traitOverrides.horizontalSizeClass = .compact
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        window.rootViewController = tabs
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(tabs.view)
        let drawer = try XCTUnwrap(map.presentedViewController as? NewMapDrawerViewController)
        map.drawerDidSelectVenue(FestivalPlaceRowUi(id: -101, name: "Venue", description: "", timeInformation: nil))
        tabs.updateForcedUpdateSheet(presentation(version: "Cancelled", allowsDismissal: false))
        map.resumeDrawerPresentation()
        let other = tabs.event.rootViewController
        if tabs.tabBarController(tabs, shouldSelect: other) {
            tabs.selectedViewController = other
            tabs.tabBarController(tabs, didSelect: other)
        }
        tabs.updateForcedUpdateSheet(nil)
        await settle(tabs.view)
        XCTAssertFalse(tabs.presentedViewController is UIHostingController<AppUpdateSheetView>)
        XCTAssertTrue(tabs.selectedViewController === other)
        XCTAssertNil(drawer.presentingViewController)
        if tabs.tabBarController(tabs, shouldSelect: map) {
            tabs.selectedViewController = map
            tabs.tabBarController(tabs, didSelect: map)
        }
        await settle(tabs.view)
        XCTAssertTrue(map.presentedViewController === drawer)
        map.suspendDrawerPresentation()
        await settle(tabs.view)
    }

    private func makeTabs() -> TabBarController {
        TabBarController(
            eventService: Container.shared.legacyEventService(),
            entryManager: Container.shared.entryManager(),
            trackerManager: TrackerManager(storageManager: StorageManager())
        )
    }

    private func presentation(version: String, allowsDismissal: Bool) -> AppUpdatePresentation {
        AppUpdatePresentation(
            version: version,
            storeURL: URL(string: "https://example.test/update")!,
            allowsDismissal: allowsDismissal
        )
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<30 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
