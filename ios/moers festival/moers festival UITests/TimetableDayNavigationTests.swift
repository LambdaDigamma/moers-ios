import XCTest

@MainActor
final class TimetableDayNavigationTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["RUN_FESTIVAL_UI_INTEGRATION_TESTS"] == "1",
            "Set RUN_FESTIVAL_UI_INTEGRATION_TESTS=1 to check navigation with the live programme."
        )
        continueAfterFailure = false
    }

    func testCompactDaySelectionAndSwipingStayInSync() async {
        await verifyDayNavigation(displayMode: 0)
    }

    func testImageDaySelectionAndSwipingStayInSync() async {
        await verifyDayNavigation(displayMode: 1)
    }

    private func verifyDayNavigation(displayMode: Int) async {
        let app = XCUIApplication()
        app.launchArguments = [
            "-wasLaunchedBefore", "YES",
            "-UserDidCompleteSetup", "YES",
            "-showedDownload", "YES",
            "-currentEventDisplayMode", String(displayMode)
        ]
        app.launch()

        let days = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'DayItem-'"))
        XCTAssertTrue(days.firstMatch.waitForExistence(timeout: 20), "The timetable must load its days.")
        guard days.count >= 2 else {
            XCTFail("Day navigation needs at least two programme dates.")
            return
        }

        let firstIdentifier = days.element(boundBy: 0).identifier
        let secondIdentifier = days.element(boundBy: 1).identifier
        let firstDay = app.buttons[firstIdentifier]
        let secondDay = app.buttons[secondIdentifier]
        XCTAssertGreaterThanOrEqual(firstDay.frame.height, 44)

        firstDay.tap()
        await waitForSelection(firstDay)
        secondDay.tap()
        await waitForSelection(secondDay)

        secondDay.tap()
        XCTAssertTrue(secondDay.isSelected, "Tapping the active day must keep it selected.")
        XCTAssertEqual(days.matching(NSPredicate(format: "selected == true")).count, 1)

        // Swipe through the event page, below the separate horizontal day strip.
        let leading = app.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: 0.55))
        let trailing = app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.55))
        leading.press(forDuration: 0.05, thenDragTo: trailing)
        await waitForSelection(firstDay)

        trailing.press(forDuration: 0.05, thenDragTo: leading)
        await waitForSelection(secondDay)
        XCTAssertEqual(days.matching(NSPredicate(format: "selected == true")).count, 1)

        let headerPosition = secondDay.frame.minY
        app.swipeUp()
        XCTAssertEqual(secondDay.frame.minY, headerPosition, accuracy: 1, "The day row must stay pinned.")

        let eventRow = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Event-Row-'")).firstMatch
        XCTAssertTrue(eventRow.waitForExistence(timeout: 5))
        eventRow.tap()
        XCTAssertTrue(app.staticTexts["EventDetail.Title"].waitForExistence(timeout: 5))
    }

    private func waitForSelection(_ day: XCUIElement) async {
        let selected = expectation(for: NSPredicate(format: "selected == true"), evaluatedWith: day)
        await fulfillment(of: [selected], timeout: 5)
    }
}
