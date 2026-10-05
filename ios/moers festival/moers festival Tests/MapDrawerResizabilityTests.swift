import MapKit
import Core
import FactoryKit
import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class MapDrawerResizabilityTests: XCTestCase {
    func testDrawerAndVenueSurviveCompactRegularRoundTrip() async throws {
        let map = NewMapViewController()
        let tabs = UITabBarController()
        tabs.viewControllers = [map, UIViewController()]
        tabs.selectedViewController = map
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        map.traitOverrides.horizontalSizeClass = .compact
        window.rootViewController = tabs
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(tabs.view)
        let drawer = try XCTUnwrap(controllers(in: tabs).compactMap { $0 as? NewMapDrawerViewController }.first)
        XCTAssertTrue(drawer.presentingViewController === map)
        XCTAssertGreaterThan(drawer.view.bounds.height, 0)
        XCTAssertTrue(tabs.tabBar.isDescendant(of: tabs.view))
        let collection = try XCTUnwrap(descendants(of: drawer.view).compactMap { $0 as? UICollectionView }.first)
        let mapView = try XCTUnwrap(descendants(of: map.view).compactMap { $0 as? MKMapView }.first)
        let camera = try XCTUnwrap(mapView.camera.copy() as? MKMapCamera)
        drawer.searchBar.text = "Resize fixture"
        drawer.searchBar.delegate?.searchBar?(drawer.searchBar, textDidChange: "Resize fixture")
        let sheet = try XCTUnwrap(drawer.presentationController as? UISheetPresentationController)
        sheet.selectedDetentIdentifier = .medium

        map.traitOverrides.horizontalSizeClass = .regular
        await settle(tabs.view)
        let panel = try XCTUnwrap(map.children.compactMap { $0 as? MapPanelContainerController }.first)
        XCTAssertTrue(drawer.parent === panel)
        XCTAssertEqual(drawer.searchBar.text, "Resize fixture")
        XCTAssertTrue(descendants(of: drawer.view).contains { $0 === collection })
        XCTAssertEqual(panel.baseState, .expanded)
        XCTAssertGreaterThan(drawer.view.bounds.height, 300)
        map.drawerDidSelectVenue(FestivalPlaceRowUi(id: -101, name: "Resize fixture", description: "", timeInformation: nil))
        await settle(tabs.view)
        let detail = try XCTUnwrap(panel.children.compactMap { $0 as? UINavigationController }.first)
        let venue = try XCTUnwrap(detail.viewControllers.first as? VenueDetailController)
        XCTAssertTrue(detail.isNavigationBarHidden)

        map.traitOverrides.horizontalSizeClass = .compact
        await settle(tabs.view)
        XCTAssertNil(panel.parent)
        XCTAssertNotNil(detail.presentingViewController)
        XCTAssertTrue(controllers(in: tabs).contains { $0 === detail })
        XCTAssertTrue(detail.viewControllers.first === venue)
        XCTAssertFalse(detail.isNavigationBarHidden)
        XCTAssertEqual((drawer.presentationController as? UISheetPresentationController)?.selectedDetentIdentifier, .medium)
        XCTAssertEqual(drawer.searchBar.text, "Resize fixture")
        XCTAssertEqual(mapView.camera.centerCoordinate.latitude, camera.centerCoordinate.latitude, accuracy: 0.000_01)
        XCTAssertEqual(mapView.camera.centerCoordinate.longitude, camera.centerCoordinate.longitude, accuracy: 0.000_01)
        XCTAssertEqual(mapView.camera.heading, camera.heading, accuracy: 0.5)
        try await closeVenueAndReturnToRegular(venue, map: map, tabs: tabs, drawer: drawer)
        map.suspendDrawerPresentation()
        await settle(tabs.view)
    }

    func testLeavingMapDuringTransferDoesNotReopenItsSheet() async throws {
        let map = NewMapViewController()
        let other = UIViewController()
        let tabs = UITabBarController()
        tabs.viewControllers = [map, other]
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        map.traitOverrides.horizontalSizeClass = .compact
        window.rootViewController = tabs
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(tabs.view)
        let drawer = try XCTUnwrap(controllers(in: tabs).compactMap { $0 as? NewMapDrawerViewController }.first)
        map.traitOverrides.horizontalSizeClass = .regular
        map.suspendDrawerPresentation()
        tabs.selectedViewController = other
        map.traitOverrides.horizontalSizeClass = .compact
        await settle(tabs.view)
        XCTAssertNil(drawer.presentingViewController)
        XCTAssertNil(tabs.presentedViewController)
        tabs.selectedViewController = map
        await settle(tabs.view)
        XCTAssertNotNil(drawer.presentingViewController)
        XCTAssertTrue(drawer.presentingViewController === map)
        XCTAssertGreaterThan(drawer.view.bounds.height, 0)
        XCTAssertTrue(tabs.tabBar.isDescendant(of: tabs.view))
        map.suspendDrawerPresentation()
        await settle(tabs.view)
    }

    func testImmediateTabReturnQueuesPresentationUntilSuspensionCompletes() async throws {
        let tabs = TabBarController(
            eventService: Container.shared.legacyEventService(),
            entryManager: Container.shared.entryManager(),
            trackerManager: TrackerManager(storageManager: StorageManager())
        )
        tabs.loadViewIfNeeded()
        let map = tabs.map.mainViewController
        let other = tabs.event.rootViewController
        tabs.selectedViewController = map
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        map.traitOverrides.horizontalSizeClass = .compact
        window.rootViewController = tabs
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(tabs.view)
        let drawer = try XCTUnwrap(controllers(in: tabs).compactMap { $0 as? NewMapDrawerViewController }.first)
        if tabs.tabBarController(tabs, shouldSelect: other) {
            tabs.selectedViewController = other
            tabs.tabBarController(tabs, didSelect: other)
        }
        if tabs.tabBarController(tabs, shouldSelect: map) {
            tabs.selectedViewController = map
            tabs.tabBarController(tabs, didSelect: map)
        }
        await settle(tabs.view)
        XCTAssertTrue(tabs.selectedViewController === map)
        XCTAssertTrue(drawer.presentingViewController === map)
        let drawers = controllers(in: tabs).compactMap { $0 as? NewMapDrawerViewController }
        XCTAssertEqual(Set(drawers.map { ObjectIdentifier($0) }).count, 1)
        map.suspendDrawerPresentation()
        await settle(tabs.view)
    }

    func testLatestVenueSelectionWaitsForActivePresentation() async throws {
        let map = NewMapViewController()
        let tabs = UITabBarController()
        tabs.viewControllers = [map]
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        map.traitOverrides.horizontalSizeClass = .compact
        window.rootViewController = tabs
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(tabs.view)
        map.drawerDidSelectVenue(FestivalPlaceRowUi(id: -101, name: "First venue", description: "", timeInformation: nil))
        map.drawerDidSelectVenue(FestivalPlaceRowUi(id: -102, name: "Latest venue", description: "", timeInformation: nil))
        await settle(tabs.view)
        let venues = controllers(in: tabs).compactMap { $0 as? VenueDetailController }
        let venue = try XCTUnwrap(venues.first)
        XCTAssertEqual(venues.count, 1)
        XCTAssertEqual(venue.placeID, -102)
        map.traitOverrides.horizontalSizeClass = .regular
        await settle(tabs.view)
        let panel = try XCTUnwrap(map.children.compactMap { $0 as? MapPanelContainerController }.first)
        XCTAssertTrue(controllers(in: panel).contains { $0 === venue })
        map.suspendDrawerPresentation()
        await settle(tabs.view)
    }

    private func closeVenueAndReturnToRegular(
        _ venue: VenueDetailController,
        map: NewMapViewController,
        tabs: UITabBarController,
        drawer: NewMapDrawerViewController
    ) async throws {
        venue.onClose?()
        map.traitOverrides.horizontalSizeClass = .regular
        await settle(tabs.view)
        let panel = try XCTUnwrap(map.children.compactMap { $0 as? MapPanelContainerController }.first)
        XCTAssertFalse(panel.children.contains { $0 is UINavigationController })
        XCTAssertTrue(drawer.parent === panel)
    }

    private func controllers(in controller: UIViewController) -> [UIViewController] {
        let presented = controller.presentedViewController.map { [$0] + controllers(in: $0) } ?? []
        return [controller] + controller.children.flatMap { controllers(in: $0) } + presented
    }

    private func descendants(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(of: $0) }
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<12 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
