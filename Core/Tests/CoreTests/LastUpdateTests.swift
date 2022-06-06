//
//  LastUpdateTests.swift
//  
//
//  Created by Lennart Fischer on 31.05.22.
//

import Foundation
import XCTest

@testable import Core

final class LastUpdateTests: XCTestCase {
    
    func test_behaviour() {
        
        let lastUpdate = LastUpdate(key: "test1")
        let date = Date(timeIntervalSinceNow: 60)
        
        lastUpdate.set(to: date)
        
        let loadedDate = lastUpdate.get()
        
        if #available(iOS 15.0, *) {
            XCTAssertEqual(date.formatted(), loadedDate?.formatted())
        }
        
    }
    
    func test_reset() {
        
        let lastUpdate = LastUpdate(key: "test2")
        let date = Date(timeIntervalSinceNow: 60)
        
        lastUpdate.set(to: date)
        XCTAssertNotNil(lastUpdate.get())
        
        lastUpdate.reset()
        
        XCTAssertNil(lastUpdate.get())
        
    }
    
    func test_should_reload() {
        
        let lastUpdate = LastUpdate(key: "test3")
        
        lastUpdate.set(to: Date(timeIntervalSinceNow: -60 * 10))
        
        XCTAssertTrue(lastUpdate.shouldReload(ttl: 60 * 5))
        
    }
    
    func test_should_not_reload() {
        
        let lastUpdate = LastUpdate(key: "test4")
        
        lastUpdate.set(to: Date(timeIntervalSinceNow: -60 * 4))
        
        XCTAssertFalse(lastUpdate.shouldReload(ttl: 60 * 5))
        
    }
    
}
