//
//  DebugTimeControllerTests.swift
//  moers festival Tests
//
//  Created by Codex on 16.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import XCTest
@testable import moers_festival

#if DEBUG

final class DebugTimeControllerTests: XCTestCase {
    
    private var userDefaults: UserDefaults!
    private var userDefaultsSuiteName: String!
    
    override func setUp() {
        super.setUp()
        
        let suiteName = "DebugTimeControllerTests-\(UUID().uuidString)"
        userDefaultsSuiteName = suiteName
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
    }
    
    override func tearDown() {
        if let suiteName = userDefaultsSuiteName {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
        userDefaults = nil
        userDefaultsSuiteName = nil
        
        super.tearDown()
    }
    
    func testFrozenSpeedDoesNotProgressTime() {
        let date = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        let controller = DebugTimeController(userDefaults: userDefaults, arguments: [], observesEvents: false)
        
        controller.setDate(date)
        controller.setSpeedMultiplier(0)
        
        Thread.sleep(forTimeInterval: 0.05)
        
        XCTAssertEqual(controller.now.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 0.001)
    }
    
    func testAcceleratedSpeedProgressesFromAnchor() {
        let date = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        let controller = DebugTimeController(userDefaults: userDefaults, arguments: [], observesEvents: false)
        
        controller.setDate(date)
        controller.setSpeedMultiplier(60)
        
        Thread.sleep(forTimeInterval: 0.05)
        
        XCTAssertGreaterThan(controller.now.timeIntervalSince(date), 1)
    }
    
    func testRealtimeSpeedProgressesAtWallClockRate() {
        let date = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        let controller = DebugTimeController(userDefaults: userDefaults, arguments: [], observesEvents: false)
        
        controller.setDate(date)
        controller.setSpeedMultiplier(1)
        
        Thread.sleep(forTimeInterval: 0.05)
        
        XCTAssertGreaterThan(controller.now.timeIntervalSince(date), 0.01)
        XCTAssertLessThan(controller.now.timeIntervalSince(date), 1)
    }
    
    func testThreeHundredTimesSpeedProgressesFromAnchor() {
        let date = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        let controller = DebugTimeController(userDefaults: userDefaults, arguments: [], observesEvents: false)
        
        controller.setDate(date)
        controller.setSpeedMultiplier(300)
        
        Thread.sleep(forTimeInterval: 0.05)
        
        XCTAssertGreaterThan(controller.now.timeIntervalSince(date), 10)
    }
    
    func testPersistedStateRestoresOnNextController() {
        let date = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        let firstController = DebugTimeController(userDefaults: userDefaults, arguments: [], observesEvents: false)
        
        firstController.setDate(date)
        firstController.setSpeedMultiplier(0)
        
        let restoredController = DebugTimeController(userDefaults: userDefaults, arguments: [], observesEvents: false)
        
        XCTAssertEqual(restoredController.now.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(restoredController.speedMultiplier, 0)
    }
    
    func testLaunchArgumentsOverridePersistedState() {
        let persistedDate = makeDate(year: 2025, month: 1, day: 1, hour: 12, minute: 0)
        let launchedDate = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        let persistedController = DebugTimeController(
            userDefaults: userDefaults,
            arguments: [],
            observesEvents: false
        )
        
        persistedController.setDate(persistedDate)
        persistedController.setSpeedMultiplier(0)
        
        let launchedController = DebugTimeController(
            userDefaults: userDefaults,
            arguments: [
                "app",
                "-debug-time",
                "2026-05-22T18:00:00+02:00",
                "-debug-time-speed",
                "0"
            ],
            observesEvents: false
        )
        
        XCTAssertEqual(
            launchedController.now.timeIntervalSince1970,
            launchedDate.timeIntervalSince1970,
            accuracy: 0.001
        )
        XCTAssertEqual(launchedController.speedMultiplier, 0)
    }
    
    func testResetReturnsToRealTime() {
        let date = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        let controller = DebugTimeController(userDefaults: userDefaults, arguments: [], observesEvents: false)
        
        controller.setDate(date)
        controller.setSpeedMultiplier(0)
        controller.resetToRealTime()
        
        XCTAssertEqual(controller.now.timeIntervalSince1970, Date().timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(controller.speedMultiplier, 1)
    }
    
    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int
    ) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 2 * 60 * 60)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        
        return components.date ?? Date()
    }
    
}

#endif
