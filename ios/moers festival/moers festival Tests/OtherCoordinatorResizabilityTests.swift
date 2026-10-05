import Core
import FactoryKit
import MMEvents
import SwiftUI
import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class OtherCoordinatorResizabilityTests: XCTestCase {
    func testNativeTopicsReplaceTheDetailWithoutPushingTheOverview() async {
        let coordinator = OtherCoordinator()
        XCTAssertTrue(coordinator.rootViewController is AdaptiveTabSplitViewController)
        let menuItem = coordinator.navigationController.tabBarItem
        XCTAssertTrue(coordinator.rootViewController.tabBarItem === menuItem)

        coordinator.showAbout()
        XCTAssertTrue(coordinator.selectedDetailViewController is AboutController)
        coordinator.showLicense()
        XCTAssertTrue(coordinator.selectedDetailViewController is LicensesViewController)
        coordinator.showDebugFCMToken()
        XCTAssertTrue(coordinator.selectedDetailViewController is DebugFCMTokenViewController)
        coordinator.showDownload()
        XCTAssertTrue(coordinator.selectedDetailViewController is UIHostingController<DownloadEventsScreen>)
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, 1)
        XCTAssertFalse(coordinator.rootViewController.isViewLoaded)
    }

    func testAllWebTopicsUseTheDetailColumn() async {
        let coordinator = OtherCoordinator()
        let actions = [
            coordinator.showTickets, coordinator.showFestivalDorf, coordinator.showVolunteers,
            coordinator.showMoersland, coordinator.showLodging, coordinator.showAccessibilty,
            coordinator.showSponsor, coordinator.showShop, coordinator.showLegal,
        ]
        var previous: UIViewController?
        for action in actions {
            action()
            let detail = coordinator.selectedDetailViewController
            XCTAssertTrue(detail is FallbackWebViewController)
            XCTAssertFalse(detail === previous)
            XCTAssertEqual(detail?.navigationItem.largeTitleDisplayMode, .never)
            XCTAssertEqual(coordinator.navigationController.viewControllers.count, 1)
            previous = detail
        }
        XCTAssertFalse(coordinator.rootViewController.isViewLoaded)
    }

    func testNestedWebLinksKeepTheirControllersAndBackStackAfterResize() async throws {
        let coordinator = OtherCoordinator()
        let split = try XCTUnwrap(coordinator.rootViewController as? AdaptiveTabSplitViewController)
        let window = show(split, sizeClass: .regular)
        defer { window.isHidden = true }
        await settle(split.view)
        let url = try XCTUnwrap(URL(string: "about:blank"))
        coordinator.showPage(url: url)
        await settle(split.view)
        let page = try XCTUnwrap(coordinator.selectedDetailViewController as? FallbackWebViewController)
        let webView = page.webkitView
        page.navigationCallback?(url)
        await settle(split.view)
        let child = try XCTUnwrap(coordinator.activeNavigationController.topViewController as? FallbackWebViewController)
        XCTAssertFalse(child === page)

        for sizeClass in [UIUserInterfaceSizeClass.compact, .regular, .compact] {
            split.traitOverrides.horizontalSizeClass = sizeClass
            await settle(split.view)
            XCTAssertEqual(split.isCollapsed, sizeClass == .compact)
            XCTAssertTrue(coordinator.selectedDetailViewController === page)
            XCTAssertTrue(coordinator.activeNavigationController.topViewController === child)
            XCTAssertTrue(page.webkitView === webView)
        }
        coordinator.activeNavigationController.popViewController(animated: false)
        await settle(split.view)
        XCTAssertTrue(coordinator.activeNavigationController.topViewController === page)
        page.navigationCallback?(url)
        await settle(split.view)
        XCTAssertEqual(coordinator.activeNavigationController.viewControllers.count, 3)
        coordinator.showAbout()
        await settle(split.view)
        let replacement = coordinator.selectedDetailViewController
        page.navigationCallback?(url)
        await settle(split.view)
        XCTAssertTrue(coordinator.activeNavigationController.topViewController === replacement)
        XCTAssertEqual(coordinator.activeNavigationController.viewControllers.count, 2)
    }

    func testSelectedRowReturnsInWideLayoutAndClearsAfterCompactBack() async throws {
        let coordinator = OtherCoordinator()
        let split = try XCTUnwrap(coordinator.rootViewController as? AdaptiveTabSplitViewController)
        let window = show(split, sizeClass: .regular)
        defer { window.isHidden = true }
        await settle(split.view)
        let overview = try XCTUnwrap(coordinator.navigationController.viewControllers.first as? OtherViewController)
        let collection = try XCTUnwrap((overview.view as? OtherView)?.collectionView)
        let aboutIndex = IndexPath(item: 0, section: 2)
        select(aboutIndex, in: collection, controller: overview)
        await settle(split.view)
        let about = try XCTUnwrap(coordinator.selectedDetailViewController)
        XCTAssertEqual(collection.indexPathsForSelectedItems, [aboutIndex])

        select(IndexPath(item: 0, section: 0), in: collection, controller: overview)
        XCTAssertTrue(coordinator.selectedDetailViewController === about)
        XCTAssertEqual(collection.indexPathsForSelectedItems, [aboutIndex])

        split.traitOverrides.horizontalSizeClass = .compact
        await settle(split.view)
        XCTAssertTrue(collection.indexPathsForSelectedItems?.isEmpty != false)
        split.traitOverrides.horizontalSizeClass = .regular
        await settle(split.view)
        XCTAssertTrue(coordinator.selectedDetailViewController === about)
        XCTAssertEqual(collection.indexPathsForSelectedItems, [aboutIndex])

        split.traitOverrides.horizontalSizeClass = .compact
        await settle(split.view)
        coordinator.navigationController.popToRootViewController(animated: false)
        await settle(split.view)
        split.traitOverrides.horizontalSizeClass = .regular
        await settle(split.view)
        XCTAssertNil(coordinator.selectedDetailViewController)
        XCTAssertTrue(collection.indexPathsForSelectedItems?.isEmpty != false)
    }

    func testPendingColumnChangesKeepWebLinksAndLatestTopicRequest() async throws {
        let coordinator = OtherCoordinator()
        let split = try XCTUnwrap(coordinator.rootViewController as? AdaptiveTabSplitViewController)
        let window = show(split, sizeClass: .regular)
        defer { window.isHidden = true }
        await settle(split.view)
        let url = try XCTUnwrap(URL(string: "about:blank"))
        coordinator.showPage(url: url)
        await settle(split.view)
        let page = try XCTUnwrap(coordinator.selectedDetailViewController as? FallbackWebViewController)
        _ = split.splitViewController(split, topColumnForCollapsingToProposedTopColumn: .primary)
        page.navigationCallback?(url)
        split.splitViewControllerDidCollapse(split)
        let child = try XCTUnwrap(coordinator.navigationController.topViewController as? FallbackWebViewController)
        XCTAssertFalse(child === page)

        _ = split.splitViewController(split, displayModeForExpandingToProposedDisplayMode: .oneBesideSecondary)
        child.navigationCallback?(url)
        split.splitViewControllerDidExpand(split)
        XCTAssertEqual(coordinator.activeNavigationController.viewControllers.count, 3)
        XCTAssertTrue(coordinator.selectedDetailViewController === page)

        _ = split.splitViewController(split, topColumnForCollapsingToProposedTopColumn: .primary)
        coordinator.showAbout()
        page.navigationCallback?(url)
        split.splitViewControllerDidCollapse(split)
        XCTAssertTrue(coordinator.navigationController.topViewController is AboutController)
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, 2)
        _ = split.splitViewController(split, displayModeForExpandingToProposedDisplayMode: .oneBesideSecondary)
        coordinator.showOverview()
        split.splitViewControllerDidExpand(split)
        XCTAssertNil(coordinator.selectedDetailViewController)
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, 1)
        XCTAssertTrue(coordinator.activeNavigationController.topViewController is SplitDetailPlaceholderViewController)
    }

    func testOverviewClearsDetailInBothLayouts() async throws {
        let coordinator = OtherCoordinator()
        let split = try XCTUnwrap(coordinator.rootViewController as? AdaptiveTabSplitViewController)
        let window = show(split, sizeClass: .regular)
        defer { window.isHidden = true }
        await settle(split.view)
        let overview = try XCTUnwrap(coordinator.navigationController.viewControllers.first as? OtherViewController)
        let collection = try XCTUnwrap((overview.view as? OtherView)?.collectionView)
        for sizeClass in [UIUserInterfaceSizeClass.regular, .compact] {
            split.traitOverrides.horizontalSizeClass = sizeClass
            await settle(split.view)
            select(IndexPath(item: 0, section: 2), in: collection, controller: overview)
            await settle(split.view)
            let detail = try XCTUnwrap(coordinator.selectedDetailViewController)
            coordinator.showOverview()
            XCTAssertTrue(collection.indexPathsForSelectedItems?.isEmpty != false)
            await settle(split.view)
            XCTAssertNil(coordinator.selectedDetailViewController)
            XCTAssertEqual(coordinator.navigationController.viewControllers.count, 1)
            XCTAssertFalse(coordinator.activeNavigationController.viewControllers.contains { $0 === detail })
        }
    }

    func testApplicationInfoAndWebRoutesUseTheAdaptiveDetail() async throws {
        let application = ApplicationController()
        let tabs = try XCTUnwrap(application.rootViewController() as? TabBarController)
        tabs.loadViewIfNeeded()
        tabs.other.showLicense()
        application.openOther()
        XCTAssertNil(tabs.other.selectedDetailViewController)
        XCTAssertTrue(tabs.selectedViewController === tabs.other.rootViewController)

        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "https://www.moers-festival.de/tickets/")
        application.handleUniversalLinks(from: activity)
        XCTAssertTrue(tabs.selectedViewController === tabs.other.rootViewController)
        XCTAssertTrue(tabs.other.selectedDetailViewController is FallbackWebViewController)
    }

    func testTabWebRouteKeepsTheCallersTabSelection() async throws {
        let tabs = makeTabs()
        tabs.loadViewIfNeeded()
        let previous = tabs.selectedViewController
        tabs.showWebpage(url: try XCTUnwrap(URL(string: "about:blank")))
        XCTAssertTrue(tabs.selectedViewController === previous)
        XCTAssertTrue(tabs.other.selectedDetailViewController is FallbackWebViewController)
    }

    func testInfoTabRetainsAboutWhenWindowGeometryChanges() async throws {
        let tabs = makeTabs()
        tabs.loadViewIfNeeded()
        tabs.selectedViewController = tabs.other.rootViewController
        let split = try XCTUnwrap(tabs.other.rootViewController as? AdaptiveTabSplitViewController)
        // The phone tab controller otherwise supplies compact traits to its child.
        split.traitOverrides.horizontalSizeClass = .regular
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        window.rootViewController = tabs
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(tabs.view)
        let overview = try XCTUnwrap(tabs.other.navigationController.viewControllers.first as? OtherViewController)
        let collection = try XCTUnwrap((overview.view as? OtherView)?.collectionView)
        let aboutIndex = IndexPath(item: 0, section: 2)
        select(aboutIndex, in: collection, controller: overview)
        await settle(tabs.view)
        let about = try XCTUnwrap(tabs.other.selectedDetailViewController)

        for _ in 0..<2 {
            window.frame.size = CGSize(width: 466, height: 678)
            split.traitOverrides.horizontalSizeClass = .compact
            await settle(tabs.view)
            XCTAssertTrue(split.isCollapsed)
            XCTAssertTrue(tabs.other.activeNavigationController.topViewController === about)
            window.frame.size = CGSize(width: 1_000, height: 800)
            split.traitOverrides.horizontalSizeClass = .regular
            await settle(tabs.view)
            XCTAssertFalse(split.isCollapsed)
            XCTAssertTrue(tabs.other.activeNavigationController.topViewController === about)
            XCTAssertEqual(collection.indexPathsForSelectedItems, [aboutIndex])
            XCTAssertTrue(tabs.selectedViewController === split)
        }
    }

    func testListPositionReturnsAfterHiddenLayoutChangesAndAllowsUserScrolling() async throws {
        let coordinator = OtherCoordinator()
        let split = try XCTUnwrap(coordinator.rootViewController as? AdaptiveTabSplitViewController)
        let window = show(split, sizeClass: .regular)
        defer { window.isHidden = true }
        await settle(split.view)
        let overview = try XCTUnwrap(coordinator.navigationController.viewControllers.first as? OtherViewController)
        let collection = try XCTUnwrap((overview.view as? OtherView)?.collectionView)
        let volunteersIndex = IndexPath(item: 3, section: 1)
        overview.scrollViewWillBeginDragging(collection)
        collection.scrollToItem(at: volunteersIndex, at: .top, animated: false)
        await settle(split.view)
        select(IndexPath(item: 0, section: 2), in: collection, controller: overview)
        await settle(split.view)
        let originalFrame = try XCTUnwrap(collection.layoutAttributesForItem(at: volunteersIndex)).frame
        let originalPosition = originalFrame.minY - collection.contentOffset.y - collection.adjustedContentInset.top

        for cycle in 0..<2 {
            if cycle > 0 {
                // An intermediate wide layout must not replace the original anchor.
                collection.contentOffset.y = 0
            }
            split.traitOverrides.horizontalSizeClass = .compact
            await settle(split.view)
            // Hidden self-sizing content can change its offset while the detail is visible.
            collection.contentOffset.y = 0
            split.traitOverrides.horizontalSizeClass = .regular
            await settle(split.view)
            let restoredFrame = try XCTUnwrap(collection.layoutAttributesForItem(at: volunteersIndex)).frame
            XCTAssertEqual(
                restoredFrame.minY - collection.contentOffset.y - collection.adjustedContentInset.top,
                originalPosition, accuracy: 1
            )
        }

        overview.scrollViewWillBeginDragging(collection)
        collection.contentOffset.y = 100
        await settle(split.view)
        XCTAssertEqual(collection.contentOffset.y, 100, accuracy: 1)
        let newFrame = try XCTUnwrap(collection.layoutAttributesForItem(at: volunteersIndex)).frame
        let newPosition = newFrame.minY - collection.contentOffset.y - collection.adjustedContentInset.top
        split.traitOverrides.horizontalSizeClass = .compact
        await settle(split.view)
        collection.contentOffset.y = 0
        split.traitOverrides.horizontalSizeClass = .regular
        await settle(split.view)
        let newRestoredFrame = try XCTUnwrap(collection.layoutAttributesForItem(at: volunteersIndex)).frame
        XCTAssertEqual(
            newRestoredFrame.minY - collection.contentOffset.y - collection.adjustedContentInset.top,
            newPosition, accuracy: 1
        )
        XCTAssertTrue(overview.scrollViewShouldScrollToTop(collection))
        collection.contentOffset.y = -collection.adjustedContentInset.top
        await settle(split.view)
        XCTAssertEqual(collection.contentOffset.y, -collection.adjustedContentInset.top, accuracy: 1)
    }

    private func makeTabs() -> TabBarController {
        TabBarController(
            eventService: Container.shared.legacyEventService(),
            entryManager: Container.shared.entryManager(),
            trackerManager: TrackerManager(storageManager: StorageManager())
        )
    }

    private func show(_ split: UIViewController, sizeClass: UIUserInterfaceSizeClass) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        split.traitOverrides.horizontalSizeClass = sizeClass
        window.rootViewController = split
        window.isHidden = false
        return window
    }

    private func select(_ indexPath: IndexPath, in collection: UICollectionView, controller: OtherViewController) {
        collection.selectItem(at: indexPath, animated: false, scrollPosition: [])
        controller.collectionView(collection, didSelectItemAt: indexPath)
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<20 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
