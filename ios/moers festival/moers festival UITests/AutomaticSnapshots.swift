//
//  AutomaticSnapshots.swift
//  moers festival UITests
//
//  Created by Lennart Fischer on 28.01.18.
//  Copyright © 2018 Code for Niederrhein. All rights reserved.
//

import XCTest
//@testable import moers_festival

class AutomaticSnapshots: XCTestCase {
    
    override func setUp() {
        
        // In UI Tests we usually want to stop immediately if an error occurs.
        continueAfterFailure = false
        
        // Disable animations so that we do not have to wait on them to finish.
        UIView.setAnimationsEnabled(false)
        
        // In UI tests it’s important to set the initial state - such as interface orientation.
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeRight
        } else {
            XCUIDevice.shared.orientation = .portrait
        }
        
    }
    
    func testTakeScreenshots() {
        
        // 1
        let app = XCUIApplication()
        
        app.launchArguments = [
            //            "-reset",
            "-FASTLANE_SNAPSHOT",
            "-wasLaunchedBefore",
            "-mocked"
        ]
        app.launchEnvironment = ["animations": "0"]
        app.launch()
        
        setupSnapshot(app, waitForAnimations: true)
        
        snapshot("0-events", timeWaitingForIdle: 2)
        
        app.collectionViews.collectionViews.buttons["Event-Row-301"].swipeUp()

        app.collectionViews.buttons.matching(identifier: "Event-Row-304").firstMatch.tap()
        
        snapshot("1-event_detail", timeWaitingForIdle: 2)
        
        app.navigationBars.firstMatch.buttons.firstMatch.tap()
        
        let tabBar = XCUIApplication().tabBars.firstMatch
        
        tabBar.buttons.matching(identifier: AccessibilityIdentifiers.Menu.other).firstMatch.tap()
        
        snapshot("2-info", timeWaitingForIdle: 1)

        app.buttons.matching(identifier: AccessibilityIdentifiers.Menu.map).firstMatch.tap()

        snapshot("3-map", timeWaitingForIdle: 2)
        
    }
    
}
