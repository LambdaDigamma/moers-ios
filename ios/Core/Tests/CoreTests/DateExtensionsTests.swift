//
//  DateExtensionsTests.swift
//
//
//  Created by Lennart Fischer on 08.01.21.
//

import Foundation
import XCTest
@testable import Core

final class DateExtensionsTests: XCTestCase {
    
    func testDateStringParsing() {
        
        let dateString = "03.04.2019"
        let date = Date.from(dateString, withFormat: "dd.MM.yyyy")
        
        var components = DateComponents()
        components.day = 3
        components.month = 4
        components.year = 2019
        
        let calendar = Calendar.autoupdatingCurrent
        let compareDate = calendar.date(from: components) ?? Date()
        
        XCTAssertEqual(date, compareDate)
        
    }
    
    func testFormatDate() {
        
        let date = Date.from("02.02.2020", withFormat: "dd.MM.yyyy") ?? Date()
        let dateString = date.format(format: "dd.MM.yyyy")
        
        XCTAssertEqual(dateString, "02.02.2020")
        
    }
    
    func testDefaultBeautifyDate() {
        
        let date = Date.from("02.02.2018", withFormat: "dd.MM.yyyy") ?? Date()
        
        XCTAssertEqual(date.beautify(), "Fri 02.02.2018")
        
    }
    
    func testTodayBeautifyDate() {
        
        let date = Date(timeIntervalSinceNow: 2)
        
        let dateString = date.beautify()
        
        XCTAssert(dateString.contains("\(String.localized("Today"))"))
        
    }
    
    func testTomorrowBeautifyDate() {
        
        let date = Date(timeIntervalSinceNow: 86400)
        
        let dateString = date.beautify()
        
        XCTAssert(dateString.contains("\(String.localized("Tomorrow"))"))
        
    }
    
    func testIsInIntervalTrue() {
        
        let date = Date(timeIntervalSinceNow: 60 * 59)
        
        let isIn = date.isInBeforeInterval(minutes: 60)
        
        XCTAssertTrue(isIn)
        
    }
    
    func testIsInIntervalFalse() {
        
        let date = Date(timeIntervalSinceNow: -60 * 120)
        
        let isIn = date.isInBeforeInterval(minutes: 60)
        
        XCTAssertFalse(isIn)
        
    }
    
    func testMinuteIntervalFuture() {
        
        let date = Date(timeIntervalSinceNow: 60 * 59)
        
        let minutes = date.minuteInterval()
        
        XCTAssertTrue(minutes == 59)
        
    }
    
    func testMinuteIntervalHistory() {
        
        let date = Date(timeIntervalSinceNow: -60 * 59)
        
        let minutes = date.minuteInterval()
        
        XCTAssertTrue(minutes == 59)
        
    }
    
    func testMinuteIntervalNow() {
        
        let now = Date()
        
        let minutes = now.minuteInterval()
        
        XCTAssertTrue(minutes == 0)
        
    }
    
    // TODO: Add Tests for Today and Tomorrow
    
    static var allTests = [
        ("testDateStringParsing", testDateStringParsing),
        ("testFormatDate", testFormatDate),
        ("testDefaultBeautifyDate", testDefaultBeautifyDate),
        ("testTodayBeautifyDate", testTodayBeautifyDate),
        ("testTomorrowBeautifyDate", testTomorrowBeautifyDate),
        ("testIsInIntervalTrue", testIsInIntervalTrue),
        ("testIsInIntervalFalse", testIsInIntervalFalse),
        ("testMinuteIntervalFuture", testMinuteIntervalFuture),
        ("testMinuteIntervalHistory", testMinuteIntervalHistory),
        ("testMinuteIntervalNow", testMinuteIntervalNow),
    ]
    
}
