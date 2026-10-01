//
//  OnboardingUITests.swift
//  MoersUITests
//
//  Created by Lennart Fischer on 13.02.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import XCTest

@MainActor
class OnboardingUITests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        
        continueAfterFailure = false

    }

    func testOnboardingAnimationTransitions() async {
        
        let app = XCUIApplication()
        // Keep app animations enabled to exercise UIKit's release of animation blocks.
        app.launchArguments = ["-reset", "-FASTLANE_SNAPSHOT", "NO", "-UserDidCompleteSetup", "NO"]
        app.launch()
        defer { app.terminate() }
        
        // Initial Page
        XCTAssertTrue(app.staticTexts["StartAppTitleLabel"].waitForExistence(timeout: 10))
        app.buttons["ContinueButton"].tap()

        // Privacy Page
        XCTAssertTrue(app.staticTexts["PrivacyTitleLabel"].waitForExistence(timeout: 10))
        app.buttons["PrivacyContinueButton"].tap()
        
        // User Type Selector Page
        XCTAssertTrue(app.staticTexts["CitizenTypeTitleLabel"].waitForExistence(timeout: 10))
        app.buttons["ContinueButton"].tap()
        
        // Notifications Page
        XCTAssertTrue(app.staticTexts["NotificationsTitleLabel"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["SubscribeNotificationsButton"].exists)
        
    }
    
}
