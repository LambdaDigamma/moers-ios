import UIKit
import XCTest
@testable import MapFeature

extension MapSheetPresentationTests {
    func testShrinkingSearchKeepsFieldVisibleAboveTabBar() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        let panel = controller.panelNavigationController
        await waitForCondition {
            panel.presentingViewController != nil && !panel.isBeingPresented
                && panel.transitionCoordinator == nil
        }
        let sheet = try XCTUnwrap(panel.presentationController as? UISheetPresentationController)
        let page = controller.searchViewController
        let search = page.searchController
        let field = search.searchBar.searchTextField
        controller.showSearch(focusSearch: true, animated: false)
        await waitForCondition { field.isFirstResponder && !search.isBeingPresented && search.transitionCoordinator == nil }
        search.searchBar.text = "Shell"
        let token = UISearchToken(icon: nil, text: "Diesel")
        token.representedObject = "Diesel"
        field.tokens = [token]
        sheet.animateChanges { sheet.selectedDetentIdentifier = MapSheetPresentationController.compactDetent }
        // Simulate UIKit's notification after a user changes the selected detent.
        controller.sheetPresentationControllerDidChangeSelectedDetentIdentifier(sheet)
        await waitForCondition {
            window.layoutIfNeeded()
            return panel.view.bounds.height < window.bounds.height / 2
                && field.window === window && !page.isDismissingSearch && !field.isFirstResponder
        }
        XCTAssertNotNil(panel.presentingViewController)
        XCTAssertTrue(panel.topViewController === page)
        XCTAssertTrue(search.isActive)
        XCTAssertFalse(field.isFirstResponder)
        XCTAssertFalse(panel.isNavigationBarHidden)
        XCTAssertFalse(search.searchBar.isHidden)
        XCTAssertFalse(field.isHidden)
        XCTAssertTrue(page.searchDrawer.collectionView.isHidden)
        XCTAssertEqual(search.searchBar.text, "Shell")
        XCTAssertEqual(field.tokens.first?.representedObject as? String, "Diesel")
        let fieldFrame = field.convert(field.bounds, to: window)
        let panelFrame = panel.view.convert(panel.view.bounds, to: window)
        let tabBar = try XCTUnwrap(controller.tabBarController?.tabBar)
        let tabFrame = tabBar.convert(tabBar.bounds, to: window)
        let searchRowFrame = search.searchBar.convert(search.searchBar.bounds, to: window)
        XCTAssertGreaterThanOrEqual(searchRowFrame.width, panelFrame.width - 48)
        XCTAssertGreaterThan(fieldFrame.width, 0)
        XCTAssertGreaterThanOrEqual(fieldFrame.minY, panelFrame.minY)
        XCTAssertLessThanOrEqual(fieldFrame.maxY, tabFrame.minY)

        page.focusSearch()
        await waitForCondition { field.isFirstResponder }
        XCTAssertEqual(sheet.selectedDetentIdentifier, .large)
        XCTAssertEqual(search.searchBar.text, "Shell")
        controller.suspendPanelPresentation()
    }

    func testSearchHasNoEmptyNavigationRowOrBottomGap() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        let panel = controller.panelNavigationController
        await waitForCondition {
            window.layoutIfNeeded()
            return panel.presentingViewController != nil && !panel.isBeingPresented
                && panel.transitionCoordinator == nil
        }
        let sheet = try XCTUnwrap(panel.presentationController as? UISheetPresentationController)
        sheet.selectedDetentIdentifier = .large
        await waitForCondition { window.layoutIfNeeded(); return panel.view.bounds.height > window.bounds.height / 2 }
        let page = controller.searchViewController
        let field = page.searchController.searchBar.searchTextField
        let fieldFrame = field.convert(field.bounds, to: panel.view)
        XCTAssertLessThanOrEqual(fieldFrame.minY, 32)
        XCTAssertGreaterThanOrEqual(fieldFrame.width, panel.view.bounds.width - 48)
        let list = page.searchDrawer.collectionView
        XCTAssertEqual(list.frame.maxY, page.view.bounds.maxY, accuracy: 1)
        XCTAssertEqual(panel.additionalSafeAreaInsets, .zero)
        XCTAssertGreaterThanOrEqual(list.adjustedContentInset.bottom, page.view.safeAreaInsets.bottom)
        controller.suspendPanelPresentation()
    }

    func testSearchFieldRemainsVisibleAfterRepeatedDismissal() async throws {
        let controller = MapContainerTestController()
        let window = makeWindow(controller)
        defer { window.isHidden = true }
        let page = controller.searchViewController
        let search = page.searchController
        let field = search.searchBar.searchTextField
        for _ in 0..<3 {
            controller.showSearch(focusSearch: true, animated: false)
            await waitForCondition { field.isFirstResponder }
            page.searchBarCancelButtonClicked(search.searchBar)
            search.isActive = false
            await waitForCondition {
                window.layoutIfNeeded()
                return !page.isDismissingSearch && field.window === window
                    && !controller.panelNavigationController.isNavigationBarHidden
            }
            let frame = field.convert(field.bounds, to: controller.panelNavigationController.view)
            XCTAssertLessThanOrEqual(frame.minY, 32)
            XCTAssertGreaterThanOrEqual(frame.width, controller.panelNavigationController.view.bounds.width - 48)
            XCTAssertFalse(field.isHidden)
            XCTAssertFalse(search.searchBar.isHidden)
        }
        controller.suspendPanelPresentation()
    }
}
