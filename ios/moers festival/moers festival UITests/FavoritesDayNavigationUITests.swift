import XCTest

@MainActor
final class FavoritesDayNavigationUITests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        try XCTSkipUnless(ProcessInfo.processInfo.environment["RUN_FESTIVAL_UI_INTEGRATION_TESTS"] == "1")
        continueAfterFailure = false
    }

    func testFavoritesDayTapsAndSwipesStayInSync() async {
        let app = XCUIApplication()
        app.launchArguments = [
            "-wasLaunchedBefore", "YES", "-UserDidCompleteSetup", "YES",
            "-showedDownload", "YES", "-currentEventDisplayMode", "0"
        ]
        app.launch()
        let dayButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'DayItem-'"))
        XCTAssertTrue(dayButtons.firstMatch.waitForExistence(timeout: 20))
        let identifiers = Array(Set(dayButtons.allElementsBoundByAccessibilityElement.map(\.identifier))).sorted()
        guard identifiers.count >= 2 else {
            XCTFail("Favorites day navigation needs two distinct programme dates.")
            return
        }
        let firstIdentifier = identifiers[0]
        let secondIdentifier = identifiers[1]
        let firstEvent = await markFirstEventAsFavorite(in: app, dayIdentifier: firstIdentifier)
        let secondEvent = await markFirstEventAsFavorite(in: app, dayIdentifier: secondIdentifier)

        app.buttons[AccessibilityIdentifiers.Menu.userSchedule].tap()
        let firstDay = app.buttons[firstIdentifier]
        let secondDay = app.buttons[secondIdentifier]
        XCTAssertTrue(firstDay.waitForExistence(timeout: 5))
        firstDay.tap()
        await waitForSelection(firstDay)
        secondDay.tap()
        await waitForSelection(secondDay)
        secondDay.tap()
        XCTAssertTrue(secondDay.isSelected)
        XCTAssertTrue(app.cells[secondEvent.identifier].exists)

        let leading = app.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: 0.55))
        let trailing = app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.55))
        leading.press(forDuration: 0.05, thenDragTo: trailing)
        await waitForSelection(firstDay)
        trailing.press(forDuration: 0.05, thenDragTo: leading)
        await waitForSelection(secondDay)

        let headerPosition = secondDay.frame.minY
        app.swipeUp()
        XCTAssertEqual(secondDay.frame.minY, headerPosition, accuracy: 1)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Favorites-day-bubbles"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        app.cells[secondEvent.identifier].tap()
        XCTAssertTrue(app.staticTexts["EventDetail.Title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["EventDetail.Favorite"].isSelected)
        app.navigationBars.buttons.firstMatch.tap()

        removeCreatedFavorite(in: app, dayIdentifier: firstIdentifier, event: firstEvent)
        removeCreatedFavorite(in: app, dayIdentifier: secondIdentifier, event: secondEvent)
    }

    private func removeCreatedFavorite(in app: XCUIApplication, dayIdentifier: String, event: (identifier: String, wasCreated: Bool)) {
        guard event.wasCreated else { return }
        app.buttons[AccessibilityIdentifiers.Menu.events].tap()
        app.buttons[dayIdentifier].tap()
        app.cells[event.identifier].tap()
        app.buttons["EventDetail.Favorite"].tap()
        app.navigationBars.buttons.firstMatch.tap()
    }

    private func markFirstEventAsFavorite(in app: XCUIApplication, dayIdentifier: String) async -> (identifier: String, wasCreated: Bool) {
        let day = app.buttons[dayIdentifier]
        day.tap()
        await waitForSelection(day)
        let event = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Event-Row-'" )).firstMatch
        XCTAssertTrue(event.waitForExistence(timeout: 5))
        let identifier = event.identifier
        event.tap()
        XCTAssertTrue(app.staticTexts["EventDetail.Title"].waitForExistence(timeout: 5))
        let favorite = app.buttons["EventDetail.Favorite"]
        XCTAssertTrue(favorite.waitForExistence(timeout: 5))
        let wasCreated = !favorite.isSelected
        if wasCreated {
            favorite.tap()
            await waitForSelection(favorite)
        }
        app.navigationBars.buttons.firstMatch.tap()
        return (identifier, wasCreated)
    }

    private func waitForSelection(_ element: XCUIElement) async {
        let selected = expectation(for: NSPredicate(format: "selected == true"), evaluatedWith: element)
        await fulfillment(of: [selected], timeout: 5)
    }
}
