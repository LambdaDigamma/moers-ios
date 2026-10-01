//
//  StorageManagerTests.swift
//  MMAPITests
//
//  Created by Lennart Fischer on 22.07.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import XCTest
import Core
import Combine
import MMEvents
@testable import Moers

@MainActor
final class StorageManagerTests: XCTestCase {
    
    var storageManager: Core.StorageManager<Event>!

    private var bag = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()

        self.storageManager = Core.StorageManager<Event>()

    }

    override func tearDown() async throws {
        try await super.tearDown()

        self.storageManager = nil

    }

    func testSetLastReload() async {

        let lastReloadNow = Date()
        let storageKey = #function

        storageManager.setLastReload(lastReloadNow, forKey: storageKey)

        let lastReloadStorageManager = storageManager.lastReload(forKey: storageKey)

        XCTAssertNotNil(lastReloadStorageManager)
        XCTAssertEqual(lastReloadStorageManager?.description, lastReloadNow.description)

    }

    func testResetLastReload() async {

        let storageKey = #function

        storageManager.setLastReload(nil, forKey: storageKey)

        XCTAssertNil(storageManager.lastReload(forKey: storageKey))

    }

    func testWriteAndRead() async throws {

        let expectation = self.expectation(description: #function)

        let events = [Event].stub(withCount: 10)
        let data = try JSONEncoder().encode(events)
        let storageKey = #function

        storageManager.reset(forKey: storageKey)
        storageManager.write(data: data, forKey: storageKey)

        let loaded = storageManager.read(forKey: storageKey, with: JSONDecoder())

        loaded.sink { (completion: Subscribers.Completion<Error>) in

            switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                default: break
            }

        } receiveValue: { (loadedEvents: [Event]) in
            XCTAssert(loadedEvents.count == events.count)
            expectation.fulfill()

        }.store(in: &bag)

        await fulfillment(of: [expectation], timeout: 10)

    }

    
}
