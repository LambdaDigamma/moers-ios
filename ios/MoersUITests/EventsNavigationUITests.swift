import Core
import XCTest

@MainActor
final class EventsNavigationUITests: XCTestCase {

    func testEventsSearchAndFiltersKeepTabLabels() async {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["-FASTLANE_SNAPSHOT", "NO", "-UserDidCompleteSetup", "YES"]
        app.setLanguageTag(.en)
        app.launch()
        defer { app.terminate() }

        let eventsTab = app.buttons[AccessibilityIdentifiers.Menu.events]
        XCTAssertTrue(eventsTab.waitForExistence(timeout: 10))
        eventsTab.tap()

        let searchField = app.searchFields["Veranstaltungen suchen"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))
        searchField.tap()
        searchField.typeText("Moers")
        let closeSearch = app.buttons.matching(NSPredicate(format: "label IN %@", ["Close", "Cancel"])).firstMatch
        XCTAssertTrue(closeSearch.waitForExistence(timeout: 10))
        closeSearch.tap()

        let filterButton = app.navigationBars.buttons["Filter"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 10))
        filterButton.tap()
        XCTAssertTrue(app.navigationBars["Filter"].waitForExistence(timeout: 10))
        app.cells.containing(.staticText, identifier: "Heute").firstMatch.tap()
        app.navigationBars["Filter"].buttons["Done"].tap()

        XCTAssertTrue(app.navigationBars.buttons["Filter, 1 aktiv"].waitForExistence(timeout: 10))
        XCTAssertEqual(eventsTab.label, "Events")
        app.navigationBars.buttons["Filter, 1 aktiv"].tap()
        app.navigationBars["Filter"].buttons["Zurücksetzen"].tap()
        app.navigationBars["Filter"].buttons["Done"].tap()

        XCTAssertTrue(filterButton.waitForExistence(timeout: 10))
        XCTAssertEqual(eventsTab.label, "Events")

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Recovered Events tab"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
