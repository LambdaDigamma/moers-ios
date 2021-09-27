//
//  OnboardingUITests.swift
//  MoersUITests
//
//  Created by Lennart Fischer on 13.02.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import XCTest

class OnboardingUITests: XCTestCase {

    override func setUp() {
        
        continueAfterFailure = false

        UIView.setAnimationsEnabled(false)
        
    }

    func testOnboardingCitizen() {
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["-reset"]
        app.launchEnvironment = ["animations": "0"]
        app.launch()
        
        // Initial Page
        XCTAssertTrue(app.staticTexts["StartAppTitleLabel"].exists)
        app.buttons["ContinueButton"].tap()
        
        // User Type Selector Page
        XCTAssertTrue(app.staticTexts["CitizenTypeTitleLabel"].waitForExistence(timeout: 1))
        app.buttons["ContinueButton"].tap()
        
        // Notifications Page
        XCTAssertTrue(app.staticTexts["NotificationsTitleLabel"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["SubscribeNotificationsButton"].exists)
        XCTAssertTrue(app.buttons["NotNowNotificationsButton"].exists)
        
    }
    
}
