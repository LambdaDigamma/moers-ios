//
//  Snapshotting.swift
//  MoersUITests
//
//  Created by Lennart Fischer on 11.02.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation
import XCTest
// @testable import Moers

class Snappshotting: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        
        // In UI Tests we usually want to stop immediately if an error occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation.
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeRight
        } else {
            XCUIDevice.shared.orientation = .portrait
        }
        
        app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append(contentsOf: ["-ApplePersistenceIgnoreState", "YES"])
        app.setDefaults()
        app.setLaunchArgument(LaunchArguments.Common.isFastlaneSnapshot, to: true)
        app.setLaunchArgument(LaunchArguments.Common.animations, to: "0")
        
    }
    
    func test_appStoreScreenshots() {
        
        let snapshotsActive = true
        
        app.setPreferredContentSizeCategory(accessibility: .normal, size: .M)
        app.launch()
        
        let app = XCUIApplication()
        
        // Dashboard
        
        app.buttons[AccessibilityIdentifiers.Menu.dashboard].tap()
        
        if snapshotsActive {
            snapshot("01-dashboard", timeWaitingForIdle: 1)
        }
        
        // News
        
        app.buttons[AccessibilityIdentifiers.Menu.news].tap()
        
        if snapshotsActive {
            snapshot("02-news", timeWaitingForIdle: 5)
        }
         
        // Map
        
//        tabLeisteTabBar.buttons[AccessibilityIdentifiers.Menu.map].tap()
        
        // Events
        
        app.buttons[AccessibilityIdentifiers.Menu.events].tap()
        
        if snapshotsActive {
            snapshot("04-events", timeWaitingForIdle: 1)
        }
        
    }
    
}
