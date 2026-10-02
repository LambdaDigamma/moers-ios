import Core
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

        let otherTab = app.buttons[AccessibilityIdentifiers.Menu.other]
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
            app.buttons[identifier].tap()
            otherTab.tap()
            assertTabLabels(in: app)
        }

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Tab labels after navigation"
        screenshot.lifetime = .keepAlways
        add(screenshot)
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
            XCTAssertEqual(app.buttons[identifier].label, label, file: file, line: line)
        }
    }
}
