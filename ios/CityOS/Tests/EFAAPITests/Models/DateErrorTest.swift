//
//  DateErrorTest.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import Foundation
import XCTest
@testable import EFAAPI

final class DateErrorTest: XCTestCase {
    
    func test_init() {
        
        XCTAssertEqual(DateError(rawValue: -1), .invalidDate)
        XCTAssertEqual(DateError(rawValue: -10), .yearOutOfRange)
        XCTAssertEqual(DateError(rawValue: -20), .monthOutOfRange)
        XCTAssertEqual(DateError(rawValue: -30), .dayOutOfRange)
        XCTAssertEqual(DateError(rawValue: -4001), .dateOutsideOfSchedulePeriod)
        
    }
    
}
