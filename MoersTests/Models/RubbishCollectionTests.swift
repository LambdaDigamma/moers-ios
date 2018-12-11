//
//  RubbishCollectionTests.swift
//  MoersTests
//
//  Created by Lennart Fischer on 30.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import XCTest
@testable import Moers

class RubbishCollectionTests: XCTestCase {
    
    var street: RubbishCollectionStreet!
    var date: RubbishCollectionDate!
    
    override func setUp() {
        
        street = RubbishCollectionStreet(street: "Teststraße",
                                         residualWaste: 1,
                                         organicWaste: 2,
                                         paperWaste: 3,
                                         yellowBag: 4,
                                         greenWaste: 5,
                                         sweeperDay: "Montag")
        
        date = RubbishCollectionDate(id: 2,
                                     date: "20.10.2018",
                                     residualWaste: 9,
                                     organicWaste: 8,
                                     paperWaste: 7,
                                     yellowBag: 6,
                                     greenWaste: 5)
        
    }
    
    override func tearDown() {
        
        street = nil
        
    }
    
    func testStreetInit() {
        
        XCTAssertEqual(street.street, "Teststraße")
        XCTAssertEqual(street.residualWaste, 1)
        XCTAssertEqual(street.organicWaste, 2)
        XCTAssertEqual(street.paperWaste, 3)
        XCTAssertEqual(street.yellowBag, 4)
        XCTAssertEqual(street.greenWaste, 5)
        XCTAssertEqual(street.sweeperDay, "Montag")
        
    }
    
    func testDateInit() {
        
        XCTAssertEqual(date.id, 2)
        XCTAssertEqual(date.residualWaste, 9)
        XCTAssertEqual(date.organicWaste, 8)
        XCTAssertEqual(date.paperWaste, 7)
        XCTAssertEqual(date.yellowBag, 6)
        XCTAssertEqual(date.greenWaste, 5)
        
    }
    
}
