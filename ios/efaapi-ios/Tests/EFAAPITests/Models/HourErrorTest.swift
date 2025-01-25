//
//  HourErrorTest.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import Foundation
import XCTest
@testable import EFAAPI

final class HourErrorTest: XCTestCase {
    
    func test_init() {
        
        XCTAssertEqual(HourError(rawValue: -1), .invalidTime)
        XCTAssertEqual(HourError(rawValue: -10), .hourOutOfRange)
        XCTAssertEqual(HourError(rawValue: -20), .minuteOutOfRange)
        
    }
    
}
