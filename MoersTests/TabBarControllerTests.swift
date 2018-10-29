//
//  TabBarControllerTests.swift
//  MoersTests
//
//  Created by Lennart Fischer on 29.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import XCTest
@testable import Moers

class TabBarControllerTests: XCTestCase {

    var tabBarController: TabBarController!
    
    override func setUp() {
    
        tabBarController = TabBarController()
        
    }

    override func tearDown() {
        
        tabBarController = nil
        
        super.tearDown()
    }

    func testHasFiveTabs() {
        
        guard let items = tabBarController.tabBar.items else { return }
        
        XCTAssertEqual(items.count, 5)
        
    }
    
}
