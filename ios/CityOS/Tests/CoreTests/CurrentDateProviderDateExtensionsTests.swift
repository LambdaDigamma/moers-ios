//
//  CurrentDateProviderDateExtensionsTests.swift
//  CoreTests
//
//  Created by Codex on 16.05.26.
//

import Factory
import Foundation
import XCTest
@testable import Core

final class CurrentDateProviderDateExtensionsTests: XCTestCase {
    
    override func tearDown() {
        Container.shared.currentDateProvider.reset()
        super.tearDown()
    }
    
    func testIsTodayUsesRegisteredCurrentDateProvider() {
        registerProvider(now: Date.stub(from: "2030-01-15 12:00:00"))
        
        XCTAssertTrue(Date.stub(from: "2030-01-15 00:00:01").isToday)
        XCTAssertFalse(Date.stub(from: "2030-01-16 00:00:00").isToday)
    }
    
    func testIsTomorrowUsesRegisteredCurrentDateProvider() {
        registerProvider(now: Date.stub(from: "2030-01-15 12:00:00"))
        
        XCTAssertTrue(Date.stub(from: "2030-01-16 00:00:00").isTomorrow)
        XCTAssertFalse(Date.stub(from: "2030-01-15 23:59:59").isTomorrow)
    }
    
    func testYesterdayUsesRegisteredCurrentDateProvider() throws {
        let now = Date.stub(from: "2030-01-15 12:34:56")
        registerProvider(now: now)
        
        let expectedYesterday = try XCTUnwrap(
            Calendar.autoupdatingCurrent.date(byAdding: .day, value: -1, to: now)
        )
        
        XCTAssertEqual(Date.yesterday, expectedYesterday)
    }
    
    func testIntervalHelpersUseRegisteredCurrentDateProvider() {
        registerProvider(now: Date.stub(from: "2030-01-15 12:00:00"))
        
        let futureWithinInterval = Date.stub(from: "2030-01-15 12:59:00")
        let futureOutsideInterval = Date.stub(from: "2030-01-15 13:01:00")
        let past = Date.stub(from: "2030-01-15 11:01:00")
        
        XCTAssertTrue(futureWithinInterval.isInBeforeInterval(minutes: 60))
        XCTAssertFalse(futureOutsideInterval.isInBeforeInterval(minutes: 60))
        XCTAssertFalse(past.isInBeforeInterval(minutes: 60))
        XCTAssertEqual(futureWithinInterval.minuteInterval(), 59)
        XCTAssertEqual(past.minuteInterval(), 59)
    }
    
    func testTimeAgoUsesRegisteredCurrentDateProvider() {
        let now = Date.stub(from: "2030-01-15 12:00:00")
        let past = Date.stub(from: "2030-01-15 11:00:00")
        registerProvider(now: now)
        
        XCTAssertEqual(past.timeAgo(), expectedTimeAgo(from: past, to: now))
    }
    
    func testDateHelpersReadUpdatedProviderValue() {
        let provider = FixedCurrentDateProvider(now: Date.stub(from: "2030-01-15 12:00:00"))
        Container.shared.currentDateProvider.register { provider }
        
        let date = Date.stub(from: "2030-01-16 09:00:00")
        
        XCTAssertTrue(date.isTomorrow)
        XCTAssertFalse(date.isToday)
        
        provider.setNow(Date.stub(from: "2030-01-16 12:00:00"))
        
        XCTAssertFalse(date.isTomorrow)
        XCTAssertTrue(date.isToday)
    }
    
    private func registerProvider(now: Date) {
        let provider = FixedCurrentDateProvider(now: now)
        Container.shared.currentDateProvider.register { provider }
    }
    
    private func expectedTimeAgo(from date: Date, to now: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        
        return String(format: formatter.string(from: date, to: now) ?? "", locale: .current)
    }
    
}
