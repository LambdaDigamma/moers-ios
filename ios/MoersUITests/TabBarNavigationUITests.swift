import Core
import UIKit
import XCTest

@MainActor
final class TabBarNavigationUITests: XCTestCase {

    func testTabLabelsSurviveOtherNavigation() async {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["-FASTLANE_SNAPSHOT", "NO", "-UserDidCompleteSetup", "YES"]
        app.setLanguageTag(.en)
        app.launch()
        defer { app.terminate() }

        let otherTab = app.buttons[AccessibilityIdentifiers.Menu.other].firstMatch
        XCTAssertTrue(otherTab.waitForExistence(timeout: 10))
        otherTab.tap()
        assertTabLabels(in: app)

        app.cells.containing(.staticText, identifier: "About").firstMatch.tap()
        XCTAssertTrue(app.buttons["About.rateButton"].waitForExistence(timeout: 10))
        app.navigationBars.buttons.firstMatch.tap()
        assertTabLabels(in: app)

        app.cells.containing(.staticText, identifier: "Siri Shortcuts").firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Siri Shortcuts"].waitForExistence(timeout: 10))
        app.navigationBars.buttons.firstMatch.tap()
        assertTabLabels(in: app)

        app.cells.containing(.staticText, identifier: "Bürgerfunk").firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Community radio"].waitForExistence(timeout: 10))
        app.navigationBars.buttons.firstMatch.tap()
        assertTabLabels(in: app)

        // UIKit and SwiftUI screens must not change the parent tab's label.
        app.cells.containing(.staticText, identifier: "Settings").firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 10))
        app.navigationBars.buttons.firstMatch.tap()
        assertTabLabels(in: app)

        app.cells.containing(.staticText, identifier: "Fahrt planen (Beta)").firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Trip Planner"].waitForExistence(timeout: 10))
        app.navigationBars.buttons.firstMatch.tap()
        assertTabLabels(in: app)

        for identifier in [
            AccessibilityIdentifiers.Menu.dashboard,
            AccessibilityIdentifiers.Menu.news,
            AccessibilityIdentifiers.Menu.map,
            AccessibilityIdentifiers.Menu.events
        ] {
            app.buttons[identifier].firstMatch.tap()
            otherTab.tap()
            assertTabLabels(in: app)
        }

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Tab labels after navigation"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testRotationRetainsSettingsDetailAndSelectedMapTab() async throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        defer { XCUIDevice.shared.orientation = .portrait }

        let app = XCUIApplication()
        app.launchArguments = ["-FASTLANE_SNAPSHOT", "NO", "-UserDidCompleteSetup", "YES"]
        app.setLanguageTag(.en)
        app.launch()
        defer { app.terminate() }

        let otherTab = app.buttons[AccessibilityIdentifiers.Menu.other].firstMatch
        XCTAssertTrue(otherTab.waitForExistence(timeout: 10))
        otherTab.tap()
        app.cells.containing(.staticText, identifier: "Settings").firstMatch.tap()
        let settings = app.navigationBars["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 10))
        let initialWindow = app.windows.firstMatch.frame
        let compactWindowWithBottomTabs = initialWindow.width < 600 && otherTab.frame.midY > initialWindow.midY

        for orientation in [UIDeviceOrientation.landscapeLeft, .portrait] {
            XCUIDevice.shared.orientation = orientation
            let rotationObserved = waitForWindowOrientation(orientation, in: app)
            if orientation == .landscapeLeft && !rotationObserved && compactWindowWithBottomTabs {
                throw XCTSkip("Rotation is unavailable in the current compact window. Resize retention is covered by unit tests.")
            }
            XCTAssertTrue(rotationObserved, "The window did not reach the requested orientation.")
            XCTAssertTrue(settings.exists)
            XCTAssertTrue(otherTab.isSelected)
            assertTabLabels(in: app)
            assertSidebarToggleIsAbsent(in: app)
        }

        let mapTab = app.buttons[AccessibilityIdentifiers.Menu.map].firstMatch
        mapTab.tap()
        for orientation in [UIDeviceOrientation.landscapeLeft, .portrait] {
            XCUIDevice.shared.orientation = orientation
            XCTAssertTrue(waitForWindowOrientation(orientation, in: app), "The window did not reach the requested orientation.")
            XCTAssertTrue(mapTab.isSelected)
            assertTabLabels(in: app)
            assertSidebarToggleIsAbsent(in: app)
        }

        otherTab.tap()
        XCTAssertTrue(settings.exists)
    }

    private func waitForWindowOrientation(
        _ orientation: UIDeviceOrientation,
        in app: XCUIApplication
    ) -> Bool {
        let landscape = orientation == .landscapeLeft || orientation == .landscapeRight
        let predicate = NSPredicate { _, _ in
            let frame = app.windows.firstMatch.frame
            return landscape ? frame.width > frame.height : frame.height > frame.width
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        return XCTWaiter.wait(for: [expectation], timeout: 10) == .completed
    }

    private func assertSidebarToggleIsAbsent(
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let sidebarButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[cd] %@", "sidebar"))
        XCTAssertEqual(sidebarButtons.count, 0, file: file, line: line)
    }

    private func assertTabLabels(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let labels = [
            AccessibilityIdentifiers.Menu.dashboard: "Today",
            AccessibilityIdentifiers.Menu.news: "News",
            AccessibilityIdentifiers.Menu.map: "Map",
            AccessibilityIdentifiers.Menu.events: "Events",
            AccessibilityIdentifiers.Menu.other: "Other"
        ]

        for (identifier, label) in labels {
            XCTAssertEqual(app.buttons[identifier].firstMatch.label, label, file: file, line: line)
        }
    }
}
