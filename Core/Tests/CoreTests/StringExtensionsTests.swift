//
//  StringExtensionsTests.swift
//  
//
//  Created by Lennart Fischer on 08.01.21.
//

import Foundation
import XCTest
@testable import Core

class StringExtensionsTests: XCTestCase {
    
    func testEmptyOrWhitespace() {
        
        let failingString = "Just Testing"
        let succeedingString = ""
        let anotherSucceedingString = "   "
        
        XCTAssertFalse(failingString.isEmptyOrWhitespace)
        XCTAssertTrue(succeedingString.isEmptyOrWhitespace)
        XCTAssertTrue(anotherSucceedingString.isEmptyOrWhitespace)
        
    }
    
    func testNotEmptyOrWhitespace() {
        
        let string1 = "Just Testing"
        let string2 = ""
        let string3 = "   "
        
        XCTAssertTrue(string1.isNotEmptyOrWhitespace)
        XCTAssertFalse(string2.isNotEmptyOrWhitespace)
        XCTAssertFalse(string3.isNotEmptyOrWhitespace)
        
    }
    
    func testDoubleValueOfString() {
        
        let numberString = "3.141"
        let converted = numberString.doubleValue
        
        XCTAssertEqual(converted, 3.141)
        
        let anotherNumberString = "-1.4510"
        let anotherConverted = anotherNumberString.doubleValue
        
        XCTAssertEqual(anotherConverted, -1.4510)
        
    }
    
    func testRowToArray() {
        
        let string1 = "4, 2, 10, 8"
        XCTAssertEqual(String.rowToArray(string1), [4, 2, 10, 8])
        
        let string2 = "0"
        XCTAssertEqual(String.rowToArray(string2), [0])
        
        let string3 = "That is Bullshit"
        XCTAssertEqual(String.rowToArray(string3), [])
        
        XCTAssertEqual(String.rowToArray(nil), [])
        
    }
    
    func testSubscript() {
        
        let string1 = "Monday"
        XCTAssertEqual(string1[...1], "Mo")
        
        let string2 = "Tuesday"
        XCTAssertEqual(string2[4...], "day")
        
    }
    
    static var allTests = [
        ("testEmptyOrWhitespace", testEmptyOrWhitespace),
        ("testNotEmptyOrWhitespace", testNotEmptyOrWhitespace),
        ("testDoubleValueOfString", testDoubleValueOfString),
        ("testRowToArray", testRowToArray),
        ("testSubscript", testSubscript),
    ]
    
}

