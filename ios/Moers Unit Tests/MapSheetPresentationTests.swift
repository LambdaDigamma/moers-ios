import Core
import AppScaffold
import MapKit
import UIKit
import XCTest
@testable import MapFeature

@MainActor
final class MapSheetPresentationTests: XCTestCase {
    func testMapAutomaticallyShowsPersistentCompactSearch() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        await waitForCondition { controller.panelNavigationController.presentingViewController != nil }
        let panel = controller.panelNavigationController
        let sheet = try XCTUnwrap(panel.presentationController as? UISheetPresentationController)
        XCTAssertTrue(panel.topViewController === controller.searchViewController)
        XCTAssertTrue((controller.viewController(for: .compact) as? UINavigationController)?.topViewController === controller.mapViewController)
        XCTAssertTrue(panel.isModalInPresentation)
        XCTAssertEqual(sheet.selectedDetentIdentifier, MapSheetPresentationController.compactDetent)
        XCTAssertEqual(sheet.detents.count, 3)
        XCTAssertEqual(sheet.largestUndimmedDetentIdentifier, .large)
        controller.suspendPanelPresentation()
    }

    func testFocusedSearchUsesLargeSheet() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        controller.showSearch(focusSearch: true, animated: false)
        await waitForCondition { controller.searchViewController.searchDrawer.searchBar.searchTextField.isFirstResponder }
        let sheet = try XCTUnwrap(controller.panelNavigationController.presentationController as? UISheetPresentationController)
        XCTAssertEqual(sheet.selectedDetentIdentifier, .large)
        XCTAssertTrue(controller.searchViewController.searchDrawer.searchBar.searchTextField.isFirstResponder)
        controller.searchViewController.view.layoutIfNeeded()
        XCTAssertFalse(controller.searchViewController.searchDrawer.collectionView.isHidden)
        controller.suspendPanelPresentation()
    }

    func testMapTabKeepsItsOwnTitleWhenSearchAndDetailsChange() async throws {
        let coordinator = MapCoordintor()
        let controller = coordinator.mainViewController
        let title = controller.tabBarItem.title
        let item = controller.tabBarItem
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        await waitForCondition { controller.panelNavigationController.presentingViewController != nil }
        XCTAssertFalse(controller.tabBarItem === coordinator.navigationController.tabBarItem)
        controller.showSearch(focusSearch: true, animated: false)
        try? await Task.sleep(for: .milliseconds(350))
        XCTAssertEqual(controller.tabBarItem.title, title)
        XCTAssertTrue(controller.tabBarItem === item)
        XCTAssertFalse(controller.searchViewController.searchDrawer.collectionView.isHidden)
        controller.showLocation(Camera.stub(withID: 1), animated: false)
        controller.showSearch(animated: false)
        XCTAssertEqual(controller.tabBarItem.title, title)
        controller.suspendPanelPresentation()
    }

    func testSearchEditingFromMediumKeepsFocusAfterExpansion() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        await waitForCondition { controller.panelNavigationController.presentingViewController != nil }
        let sheet = try XCTUnwrap(controller.panelNavigationController.presentationController as? UISheetPresentationController)
        sheet.selectedDetentIdentifier = .medium
        controller.searchViewController.searchDrawer.searchBar.becomeFirstResponder()
        try? await Task.sleep(for: .milliseconds(350))
        XCTAssertTrue(controller.searchViewController.searchDrawer.searchBar.searchTextField.isFirstResponder)
        XCTAssertEqual(sheet.selectedDetentIdentifier, .large)
        controller.suspendPanelPresentation()
    }

    func testSuspendingUnloadedMapCompletes() async {
        let controller = MapContainerTestController()
        var completed = false
        controller.suspendPanelPresentation { completed = true }
        XCTAssertTrue(completed)
        XCTAssertFalse(controller.isViewLoaded)
    }

    func testClusterSelectionKeepsBackNavigationAndCanReplaceDetails() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        let first = Camera.stub(withID: 1)
        let second = Camera.stub(withID: 2)
        controller.mapViewController.map.addAnnotations([first, second])
        controller.showCluster([first, second], animated: false)
        let panel = controller.panelNavigationController
        let selection = try XCTUnwrap(panel.topViewController as? SelectionViewController)
        selection.loadViewIfNeeded()
        let list = try XCTUnwrap(selection.view.subviews.compactMap { $0 as? UICollectionView }.first)
        XCTAssertEqual(list.numberOfItems(inSection: 0), 2)

        controller.showLocation(first, fromList: true, animated: false)
        XCTAssertEqual(panel.viewControllers.count, 3)
        XCTAssertTrue((panel.topViewController as? DetailViewController)?.selectedLocation === first)
        panel.popViewController(animated: false)
        XCTAssertTrue(panel.topViewController === selection)

        controller.showLocation(second, animated: false)
        XCTAssertEqual(panel.viewControllers.count, 2)
        XCTAssertTrue((panel.topViewController as? DetailViewController)?.selectedLocation === second)
        controller.suspendPanelPresentation()
    }

    func testClosingDetailRestoresSearchAndClearsMapSelection() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        let camera = Camera.stub(withID: 1)
        controller.mapViewController.map.addAnnotation(camera)
        controller.showLocation(camera, animated: false)
        await waitForCondition { controller.panelNavigationController.presentingViewController != nil }
        controller.showSearch(animated: false)
        try? await Task.sleep(for: .milliseconds(250))
        XCTAssertTrue(controller.mapViewController.map.selectedAnnotations.isEmpty)
        XCTAssertNil(controller.selectedLocation)
        XCTAssertTrue(controller.panelNavigationController.topViewController === controller.searchViewController)
        let sheet = try XCTUnwrap(controller.panelNavigationController.presentationController as? UISheetPresentationController)
        XCTAssertEqual(sheet.selectedDetentIdentifier, MapSheetPresentationController.compactDetent)
        controller.suspendPanelPresentation()
    }

    func testSuspensionAndImmediateReturnKeepSearchState() async {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        let panel = controller.panelNavigationController
        controller.searchViewController.searchDrawer.searchBar.text = "Moers"
        await waitForCondition { panel.presentingViewController != nil }
        controller.suspendPanelPresentation()
        controller.resumePanelPresentation()
        await waitForCondition { panel.presentingViewController != nil }
        XCTAssertTrue(controller.panelNavigationController === panel)
        XCTAssertEqual(controller.searchViewController.searchDrawer.searchBar.text, "Moers")
        XCTAssertTrue(panel.topViewController === controller.searchViewController)
        controller.suspendPanelPresentation()
    }

    func testSidebarTransferKeepsDetailStackAndSearchState() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller, size: CGSize(width: 1000, height: 700))
        defer { window.isHidden = true }
        controller.searchViewController.searchDrawer.searchBar.text = "Moers"
        let camera = Camera.stub(withID: 1)
        controller.mapViewController.map.addAnnotation(camera)
        controller.showLocation(camera, fromList: true, animated: false)
        await waitForCondition { controller.panelNavigationController.presentingViewController != nil }
        controller.traitOverrides.horizontalSizeClass = .regular
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        await waitForCondition { controller.sidebarController != nil }
        let split = try XCTUnwrap(controller.sidebarController)
        let panelNavigation = try XCTUnwrap(split.viewController(for: .primary) as? UINavigationController)
        XCTAssertTrue(panelNavigation === controller.panelNavigationController)
        let mapNavigation = try XCTUnwrap(split.viewController(for: .secondary) as? UINavigationController)
        XCTAssertTrue(mapNavigation.topViewController === controller.mapViewController)
        XCTAssertTrue(mapNavigation.isNavigationBarHidden)
        XCTAssertNil(controller.panelNavigationController.presentingViewController)
        XCTAssertTrue((controller.panelNavigationController.topViewController as? DetailViewController)?.selectedLocation === camera)
        controller.traitOverrides.horizontalSizeClass = .compact
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        await waitForCondition { controller.panelNavigationController.presentingViewController != nil }
        XCTAssertNil(controller.sidebarController)
        XCTAssertTrue((controller.viewController(for: .compact) as? UINavigationController)?.topViewController === controller.mapViewController)
        XCTAssertEqual(controller.panelNavigationController.viewControllers.count, 2)
        XCTAssertEqual(controller.searchViewController.searchDrawer.searchBar.text, "Moers")
        controller.suspendPanelPresentation()
    }

    func testPlaceCardReplacesLocationContentAndAvailableActions() async throws {
        let controller = DetailViewController()
        let entry = Entry(id: 1, name: "Cafe", street: "Street", houseNumber: "1", postcode: "47441", place: "Moers", lat: 51.45, lng: 6.63)
        entry.phone = "+49 2841 123"
        entry.url = "example.org"
        entry.monday = "09:00–18:00"
        controller.selectedLocation = entry
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 600)
        controller.view.layoutIfNeeded()
        let header = try XCTUnwrap(controller.tableView.tableHeaderView as? MapPlaceHeaderView)
        XCTAssertTrue(allSubviews(header).contains { $0.accessibilityIdentifier == "MapPlaceAction-call" })
        XCTAssertTrue(allSubviews(header).contains { $0.accessibilityIdentifier == "MapPlaceAction-website" })
        XCTAssertGreaterThan(controller.tableView.numberOfSections, 1)
        controller.selectedLocation = Camera.stub(withID: 2)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.tableView.numberOfSections, 0)
        XCTAssertFalse(allSubviews(header).contains { $0.accessibilityIdentifier == "MapPlaceAction-call" })
        XCTAssertTrue(allSubviews(header).contains { $0.accessibilityIdentifier == "MapPlaceAction-camera" })
    }

    func testCompactPlaceCardKeepsSummaryAndRestoresActionsWhenExpanded() async throws {
        let controller = DetailViewController()
        controller.selectedLocation = Camera.stub(withID: 1)
        controller.loadViewIfNeeded()
        let header = try XCTUnwrap(controller.tableView.tableHeaderView as? MapPlaceHeaderView)
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 100)
        controller.view.layoutIfNeeded()
        XCTAssertFalse(header.showsActions)
        XCTAssertFalse(controller.tableView.isScrollEnabled)
        controller.view.frame.size.height = 600
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        XCTAssertTrue(header.showsActions)
        XCTAssertTrue(controller.tableView.isScrollEnabled)
        XCTAssertGreaterThan(header.bounds.height, 100)
    }

    func testCompactPlaceSummaryStaysClearOfTabBar() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        let panel = controller.panelNavigationController
        await waitForCondition {
            panel.presentingViewController != nil && !panel.isBeingPresented && panel.transitionCoordinator == nil
        }
        let camera = Camera.stub(withID: 1)
        controller.showLocation(camera, animated: false)
        await waitForCondition { panel.view.safeAreaLayoutGuide.layoutFrame.height >= 210 }
        let sheet = try XCTUnwrap(panel.presentationController as? UISheetPresentationController)
        sheet.animateChanges { sheet.selectedDetentIdentifier = MapSheetPresentationController.compactDetent }
        // Check the compact layout after UIKit's detent animation, rather than the preceding medium layout.
        try? await Task.sleep(for: .milliseconds(700))
        let detail = try XCTUnwrap(controller.panelNavigationController.topViewController as? DetailViewController)
        let label = try XCTUnwrap(allSubviews(detail.view).compactMap { $0 as? UILabel }.first { $0.text == camera.name })
        let tabBar = try XCTUnwrap(controller.tabBarController?.tabBar)
        await waitForCondition {
            window.layoutIfNeeded()
            let labelFrame = label.convert(label.bounds, to: window)
            let barFrame = tabBar.convert(tabBar.bounds, to: window)
            return barFrame.midY > window.bounds.midY
                ? labelFrame.maxY <= barFrame.minY : labelFrame.minY >= barFrame.maxY
        }
        let labelFrame = label.convert(label.bounds, to: window)
        let barFrame = tabBar.convert(tabBar.bounds, to: window)
        if barFrame.midY > window.bounds.midY {
            XCTAssertLessThanOrEqual(labelFrame.maxY, barFrame.minY)
        } else {
            XCTAssertGreaterThanOrEqual(labelFrame.minY, barFrame.maxY)
        }
        controller.suspendPanelPresentation()
    }

    func testSidebarDetailNavigationDoesNotAddTopInsetToMap() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller, size: CGSize(width: 1000, height: 700))
        defer { window.isHidden = true }
        controller.traitOverrides.horizontalSizeClass = .regular
        await waitForCondition { controller.sidebarController != nil }
        window.layoutIfNeeded()
        let map = controller.mapViewController.map
        let initialTop = map.convert(map.bounds, to: controller.view).minY
        controller.showLocation(Camera.stub(withID: 1), animated: false)
        for _ in 0..<6 {
            window.setNeedsLayout()
            window.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
        XCTAssertEqual(map.convert(map.bounds, to: controller.view).minY, initialTop, accuracy: 1)
        controller.suspendPanelPresentation()
    }

    func testInitialSidebarUsesTheSameTopSafeAreaForBothColumns() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller, size: CGSize(width: 1210, height: 834), horizontalSizeClass: .regular)
        defer { window.isHidden = true }
        await waitForCondition { controller.sidebarController != nil }
        for _ in 0..<6 {
            window.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
        let primary = try XCTUnwrap(controller.viewController(for: .primary))
        let secondary = try XCTUnwrap(controller.viewController(for: .secondary))
        XCTAssertTrue(controller.sidebarController === controller)
        XCTAssertEqual(primary.view.safeAreaInsets.top, secondary.view.safeAreaInsets.top, accuracy: 1)
    }

    func testDetailWithLocationCanReleaseOutsideSwiftTask() async {
        weak var releasedController: DetailViewController?
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                autoreleasepool {
                    var controller: DetailViewController? = DetailViewController()
                    controller?.selectedLocation = Camera.stub(withID: 1)
                    controller?.loadViewIfNeeded()
                    releasedController = controller
                    controller = nil
                }
                continuation.resume()
            }
        }
        try? await Task.sleep(for: .milliseconds(200))
        XCTAssertNil(releasedController)
    }

}

extension MapSheetPresentationTests {
    func testSearchListFitsSmallWindowAndAsymmetricSafeArea() async {
        let controller = SearchDrawerViewController()
        let window = makeWindow(controller, size: CGSize(width: 600, height: 320))
        defer { window.isHidden = true }
        controller.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 10)
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        let search = controller.searchDrawer.searchBar
        let safeFrame = controller.view.safeAreaLayoutGuide.layoutFrame
        XCTAssertGreaterThanOrEqual(search.frame.minX, safeFrame.minX)
        XCTAssertLessThanOrEqual(search.frame.maxX, safeFrame.maxX)
        XCTAssertGreaterThan(controller.searchDrawer.collectionView.bounds.height, 0)
        XCTAssertLessThanOrEqual(controller.searchDrawer.collectionView.frame.maxY, safeFrame.maxY + 1)
    }

    func testSearchShowsLoadedLocationsBeforeDistanceUpdates() async {
        let controller = SearchDrawerViewController()
        controller.loadViewIfNeeded()
        controller.didReceiveCameras([Camera.stub(withID: 1), Camera.stub(withID: 2)])
        let list = controller.searchDrawer.collectionView
        XCTAssertEqual(list.numberOfItems(inSection: list.numberOfSections - 1), 2)
    }

    func testSearchTokensCombineWithTextAndCanBeRemoved() async {
        let controller = SearchDrawerViewController()
        controller.loadViewIfNeeded()
        let first = Entry(id: 1, name: "Cafe One", street: "Street", houseNumber: "1", postcode: "47441", place: "Moers", lat: 51.45, lng: 6.63)
        first.tags = ["Cafe"]
        let second = Entry(id: 2, name: "Cafe Two", street: "Street", houseNumber: "2", postcode: "47441", place: "Moers", lat: 51.45, lng: 6.63)
        second.tags = ["Bakery"]
        controller.didReceiveEntries([first, second])
        let bar = controller.searchDrawer.searchBar
        let token = UISearchToken(icon: nil, text: "Cafe")
        token.representedObject = "Cafe"
        bar.searchTextField.tokens = [token]
        bar.text = "Cafe"
        bar.searchTextField.sendActions(for: .editingChanged)
        let list = controller.searchDrawer.collectionView
        XCTAssertEqual(list.numberOfItems(inSection: list.numberOfSections - 1), 1)
        bar.searchTextField.tokens = []
        bar.searchTextField.sendActions(for: .editingChanged)
        XCTAssertEqual(list.numberOfItems(inSection: list.numberOfSections - 1), 2)
        bar.text = "zzzzzz"
        controller.searchBar(bar, textDidChange: "zzzzzz")
        XCTAssertEqual(list.numberOfItems(inSection: list.numberOfSections - 1), 0)
        XCTAssertNotNil(list.backgroundView as? UIContentUnavailableView)
    }

    private func allSubviews(_ view: UIView) -> [UIView] {
        [view] + view.subviews.flatMap(allSubviews)
    }

    private func waitForCondition(_ condition: () -> Bool) async {
        for _ in 0..<60 {
            // Layout must run while UIKit finishes a presentation or a trait change.
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(50))
        }
        XCTFail("The UIKit presentation did not reach the expected state.")
    }

    private func makeWindow(
        _ controller: UIViewController,
        size: CGSize = CGSize(width: 402, height: 874),
        horizontalSizeClass: UIUserInterfaceSizeClass = .compact
    ) -> UIWindow {
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        controller.traitOverrides.horizontalSizeClass = horizontalSizeClass
        let tabs = UITabBarController()
        if #available(iOS 18.0, *) { tabs.mode = .tabBar }
        tabs.viewControllers = [controller]
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        controller.loadViewIfNeeded()
        window.layoutIfNeeded()
        return window
    }
}
