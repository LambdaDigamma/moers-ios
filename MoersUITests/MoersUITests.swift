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
        app.launch()
        
        snapshot("01Test")
        
    }
    
}
