//
//  StorageManagerTests.swift
//  MMAPITests
//
//  Created by Lennart Fischer on 22.07.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import XCTest

@testable import MMAPI

final class StorageManagerTests: XCTestCase {
    
    var storageManager: StorageManager<Event>!
    
    override func setUp() {
        super.setUp()
        
        self.storageManager = StorageManager<Event>()
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.storageManager = nil
        
    }
    
    func testSetLastReload() {
        
        let lastReloadNow = Date()
        let storageKey = #function
        
        storageManager.setLastReload(lastReloadNow, forKey: storageKey)
        
        let lastReloadStorageManager = storageManager.lastReload(forKey: storageKey)
        
        XCTAssertNotNil(lastReloadStorageManager)
        XCTAssertEqual(lastReloadStorageManager?.description, lastReloadNow.description)
        
    }
    
    func testResetLastReload() {
        
        let storageKey = #function
        
        storageManager.setLastReload(nil, forKey: storageKey)
        
        XCTAssertNil(storageManager.lastReload(forKey: storageKey))
        
    }
    
    // TODO: Add Reset Test
    
//    func testReset() throws {
//
//        let expectation = self.expectation(description: #function)
//        let events = [Event].stub(withCount: 10)
//        let data = try JSONEncoder().encode(events)
//        let storageKey = #function
//
//        storageManager.write(data: data, forKey: storageKey)
//        storageManager.reset(forKey: storageKey)
//        storageManager.read(forKey: storageKey, with: JSONDecoder())
//            .observeNext { events in
//                XCTAssertEqual(events.count, 0)
//            }.dispose(in: bag)
//        
//        wait(for: [expectation], timeout: 10)
//        
//    }
    
    func testWriteAndRead() throws {
        
        let expectation = self.expectation(description: #function)
        
        let events = [Event].stub(withCount: 10)
        let data = try JSONEncoder().encode(events)
        let storageKey = #function
        
        storageManager.reset(forKey: storageKey)
        storageManager.write(data: data, forKey: storageKey)
        
        let loaded = storageManager.read(forKey: storageKey, with: JSONDecoder())
        
        loaded.observeNext { loadedEvents in
            XCTAssert(loadedEvents.count == events.count)
            expectation.fulfill()
        }.dispose(in: bag)
        
        loaded.observeFailed { error in
            XCTFail(error.localizedDescription)
        }.dispose(in: bag)
        
        wait(for: [expectation], timeout: 10)
        
    }

    static var allTests = [
        ("testSetLastReload", testSetLastReload),
        ("testResetLastReload", testResetLastReload),
        ("testWriteAndRead", testWriteAndRead),
    ]
    
}
