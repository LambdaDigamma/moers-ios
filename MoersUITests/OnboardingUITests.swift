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
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        UIView.setAnimationsEnabled(false)
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
