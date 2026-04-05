//
//  AutomaticSnapshots.swift
//  moers festival UITests
//
//  Created by Lennart Fischer on 28.01.18.
//  Copyright © 2018 Code for Niederrhein. All rights reserved.
//

import XCTest

class AutomaticSnapshots: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)

        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeRight
        } else {
            XCUIDevice.shared.orientation = .portrait
        }
    }

    @MainActor
    func testTakeScreenshots() {
        let app = XCUIApplication()

        app.launchArguments = [
            "-FASTLANE_SNAPSHOT",
            "-wasLaunchedBefore"
        ]
        app.launchEnvironment = ["animations": "0"]
        app.launch()

        setupSnapshot(app, waitForAnimations: true)

        waitForEventsToLoad(app)

        navigateToSecondDayIfNeeded(app)

        if UIDevice.current.userInterfaceIdiom == .pad {
            captureIPadScreenshots(app)
            return
        }

        snapshot("0-events", timeWaitingForIdle: 2)

        tapFirstEvent(app)

        waitForEventDetailToLoad(app)

        snapshot("1-event_detail", timeWaitingForIdle: 2)

        navigateBack(app)

        switchToInfoTab(app)

        snapshot("2-info", timeWaitingForIdle: 1)

        switchToMapTab(app)

        waitForMapToLoad(app)

        snapshot("3-map", timeWaitingForIdle: 2)
    }

    @MainActor
    private func captureIPadScreenshots(_ app: XCUIApplication) {
        tapFirstEvent(app)

        waitForEventDetailToLoad(app)

        snapshot("0-events", timeWaitingForIdle: 2)

        switchToMapTab(app)

        waitForMapToLoad(app)

        snapshot("1-map", timeWaitingForIdle: 2)

        switchToInfoTab(app)

        snapshot("2-info", timeWaitingForIdle: 1)
    }

    // MARK: - Navigation Helpers

    private func waitForEventsToLoad(_ app: XCUIApplication) {
        let eventList = app.collectionViews.firstMatch
        let exists = eventList.waitForExistence(timeout: 15)
        XCTAssert(exists, "Event list should load within timeout")
        
        let hasEvents = eventList.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'Event-Row-'")).firstMatch.waitForExistence(timeout: 5)
        XCTAssert(hasEvents, "At least one event should be present")
    }

    private func navigateToSecondDayIfNeeded(_ app: XCUIApplication) {
        let daySelector = app.buttons["DaySelector"]
        guard daySelector.exists else { return }

        let dayButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'DayItem-'"))
        guard dayButtons.count > 1 else { return }

        let secondDayButton = dayButtons.element(boundBy: 1)
        if secondDayButton.waitForExistence(timeout: 3) {
            secondDayButton.tap()
            sleep(1)
        }
    }

    private func tapFirstEvent(_ app: XCUIApplication) {
        let eventButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'Event-Row-'"))
        let firstEvent = eventButtons.firstMatch

        XCTAssert(firstEvent.waitForExistence(timeout: 5), "First event button should exist")
        firstEvent.tap()
    }

    private func waitForEventDetailToLoad(_ app: XCUIApplication) {
        let title = app.staticTexts["EventDetail.Title"]
        let exists = title.waitForExistence(timeout: 10)
        XCTAssert(exists, "Event detail title should load within timeout")
    }

    private func navigateBack(_ app: XCUIApplication) {
        let backButton = app.navigationBars.firstMatch.buttons.element(boundBy: 0)
        XCTAssert(backButton.waitForExistence(timeout: 5), "Back button should exist")
        backButton.tap()
        sleep(1)
    }

    private func switchToInfoTab(_ app: XCUIApplication) {
        let infoTab = menuButton(app, identifier: AccessibilityIdentifiers.Menu.other)
        XCTAssert(infoTab.waitForExistence(timeout: 5), "Info tab should exist")
        infoTab.tap()
        sleep(1)
    }

    private func switchToMapTab(_ app: XCUIApplication) {
        let mapTab = menuButton(app, identifier: AccessibilityIdentifiers.Menu.map)
        XCTAssert(mapTab.waitForExistence(timeout: 5), "Map tab should exist")
        mapTab.tap()
    }

    private func menuButton(_ app: XCUIApplication, identifier: String) -> XCUIElement {
        let identifierPredicate = NSPredicate(format: "identifier == %@", identifier)
        let queries: [XCUIElementQuery]

        if UIDevice.current.userInterfaceIdiom == .pad {
            queries = [
                app.collectionViews.cells.matching(identifierPredicate),
                app.descendants(matching: .cell).matching(identifierPredicate),
                app.tabBars.firstMatch.buttons.matching(identifierPredicate),
                app.buttons.matching(identifierPredicate),
                app.descendants(matching: .button).matching(identifierPredicate)
            ]
        } else {
            queries = [
                app.tabBars.firstMatch.buttons.matching(identifierPredicate),
                app.buttons.matching(identifierPredicate),
                app.descendants(matching: .button).matching(identifierPredicate)
            ]
        }

        for query in queries {
            let candidates = query.allElementsBoundByIndex.filter(\.exists)

            if let hittableCandidate = candidates.first(where: \.isHittable) {
                return hittableCandidate
            }

            if let firstCandidate = candidates.first {
                return firstCandidate
            }
        }

        return app.descendants(matching: .button).matching(identifierPredicate).element(boundBy: 0)
    }

    private func waitForMapToLoad(_ app: XCUIApplication) {
        let mapView = app.maps["FestivalMap"]
        let exists = mapView.waitForExistence(timeout: 10)
        
        if !exists {
            let anyMap = app.maps.firstMatch
            if anyMap.waitForExistence(timeout: 3) {
                return
            }
        }
        
        XCTAssert(exists || app.maps.count > 0, "Map view should load within timeout")
    }
}
