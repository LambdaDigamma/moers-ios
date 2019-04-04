//
//  EventTests.swift
//  MoersTests
//
//  Created by Lennart Fischer on 29.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import XCTest
@testable import Moers

class EventTests: XCTestCase {

    var event: Event!
    
    override func setUp() {
        
        event = Event(id: 2,
                      name: "Test-Event",
                      description: "This is a description.",
                      url: nil,
                      date: "21.10.2018",
                      timeStart: "10:00",
                      timeEnd: "13:30",
                      category: "Test",
                      organisationID: nil,
                      entryID: nil,
                      organisation: nil,
                      entry: nil,
                      createdAt: Date(),
                      updatedAt: Date())
        
    }

    override func tearDown() {
        
        event = nil
        
    }

    func testInit() {
        
        XCTAssertEqual(event.id, 2)
        XCTAssertEqual(event.name, "Test-Event")
        XCTAssertEqual(event.url, nil)
        XCTAssertEqual(event.date, "21.10.2018")
        XCTAssertEqual(event.timeStart, "10:00")
        XCTAssertEqual(event.timeEnd, "13:30")
        XCTAssertEqual(event.category, "Test")
        
    }

    func testDateParsing() {
        
        XCTAssertEqual(event.parsedDate, Date.from("21.10.2018", withFormat: "dd.MM.yyyy"))
        
    }
    
    func testTimeParsing() {
        
        XCTAssertEqual(event.parsedTime, "10:00 - 13:30")
        
    }
    
}
