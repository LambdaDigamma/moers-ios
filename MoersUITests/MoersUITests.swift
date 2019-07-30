//
//  MoersUITests.swift
//  MoersUITests
//
//  Created by Lennart Fischer on 16.02.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import XCTest

class MoersUITests: XCTestCase {
    
    func testExample() {
        
        let app = XCUIApplication()
        
        setupSnapshot(app)
        
        app.launchEnvironment["-Test"] = "true"
        app.launch()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeRight
        } else {
            XCUIDevice.shared.orientation = .portrait
        }
        
        snapshot("01-Dashboard", timeWaitingForIdle: 10)
        
        app.tabBars["TabNews"].tap()
        snapshot("02-News", timeWaitingForIdle: 5)
        
        app.tabBars["TabMap"].tap()
        snapshot("03-Map", timeWaitingForIdle: 10)
        
        app.tabBars["TabEvents"].tap()
        snapshot("04-Event", timeWaitingForIdle: 5)
        
    }
    
}
