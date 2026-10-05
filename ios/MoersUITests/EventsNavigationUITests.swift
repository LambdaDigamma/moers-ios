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

        let eventsTab = app.buttons[AccessibilityIdentifiers.Menu.events].firstMatch
        XCTAssertTrue(eventsTab.waitForExistence(timeout: 10))
        eventsTab.tap()

        searchEvents(in: app, query: "Moers")
        XCTAssertTrue(eventsTab.isSelected)
        XCTAssertEqual(eventsTab.label, "Events")

        let filterButton = app.navigationBars["Events"].buttons.matching(
            NSPredicate(format: "label ==[cd] %@", "Filter")
        ).firstMatch
        XCTAssertTrue(filterButton.waitForExistence(timeout: 10))
        filterButton.tap()
        XCTAssertTrue(app.navigationBars["Filter"].waitForExistence(timeout: 10))
        app.cells.containing(.staticText, identifier: "Heute").firstMatch.tap()
        app.navigationBars["Filter"].buttons["Done"].tap()

        let activeFilterButton = app.navigationBars["Events"].buttons.matching(
            NSPredicate(format: "label ==[cd] %@", "Filter, 1 aktiv")
        ).firstMatch
        XCTAssertTrue(activeFilterButton.waitForExistence(timeout: 10))
        XCTAssertEqual(eventsTab.label, "Events")
        activeFilterButton.tap()
        app.navigationBars["Filter"].buttons["Zurücksetzen"].tap()
        app.navigationBars["Filter"].buttons["Done"].tap()

        XCTAssertTrue(filterButton.waitForExistence(timeout: 10))
        XCTAssertEqual(eventsTab.label, "Events")

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Recovered Events tab"
        screenshot.lifetime = .keepAlways
        add(screenshot)

        let mapTab = app.buttons[AccessibilityIdentifiers.Menu.map].firstMatch
        mapTab.tap()
        XCTAssertTrue(mapTab.isSelected)
        XCTAssertEqual(eventsTab.label, "Events")
        let mapScreenshot = XCTAttachment(screenshot: app.screenshot())
        mapScreenshot.name = "Map with native tabs"
        mapScreenshot.lifetime = .keepAlways
        add(mapScreenshot)

        eventsTab.tap()
        XCTAssertTrue(eventsTab.isSelected)
        XCTAssertTrue(filterButton.waitForExistence(timeout: 10))
    }

    private func searchEvents(in app: XCUIApplication, query: String) {
        let searchField = app.searchFields["Veranstaltungen suchen"]
        if !searchField.exists {
            let searchButton = app.navigationBars["Events"].buttons["Search"].firstMatch
            XCTAssertTrue(searchButton.waitForExistence(timeout: 10))
            searchButton.tap()
        }
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))
        searchField.tap()
        searchField.typeText(query)
        XCTAssertEqual(searchField.value as? String, query)
        let closeSearch = app.buttons.matching(NSPredicate(format: "label IN %@", ["Close", "Cancel"])).firstMatch
        if closeSearch.exists {
            closeSearch.tap()
        } else {
            let submitSearch = app.keyboards.buttons["Search"].firstMatch
            XCTAssertTrue(submitSearch.waitForExistence(timeout: 10))
            submitSearch.tap()
        }
    }
}
