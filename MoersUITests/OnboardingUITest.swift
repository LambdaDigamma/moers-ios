//
//  OnboardingUITest.swift
//  MoersUITests
//
//  Created by Lennart Fischer on 23.07.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import XCTest
@testable import Moers

class OnboardingUITest: XCTestCase {

    func testExample() {
        
        let app = XCUIApplication()
        app.launchArguments = ["-reset"]
        app.launch()
        
        
        
    }

}
