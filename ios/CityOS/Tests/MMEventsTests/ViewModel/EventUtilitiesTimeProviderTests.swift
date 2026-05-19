//
//  EventUtilitiesTimeProviderTests.swift
//
//
//  Created by Codex on 16.05.26.
//

import Combine
import Core
import XCTest
@testable import MMEvents

@MainActor
final class EventUtilitiesTimeProviderTests: XCTestCase {
    
    func testTimeDisplayModeUsesExplicitNowForRelativeEvents() {
        let now = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        let startDate = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 30)
        
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: nil,
                scheduleDisplayMode: .dateTime,
                now: now
            ),
            .relative
        )
    }
    
    func testTimeDisplayModeUsesExplicitNowForLiveEvents() {
        let now = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 15)
        let startDate = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        let endDate = makeDate(year: 2026, month: 5, day: 22, hour: 19, minute: 0)
        
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: endDate,
                scheduleDisplayMode: .dateTime,
                now: now
            ),
            .live
        )
    }
    
    func testEventViewModelUsesInjectedNowForLiveState() {
        let now = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 15)
        let event = Event
            .stub(withID: 1)
            .setting(\.startDate, to: makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0))
            .setting(\.endDate, to: makeDate(year: 2026, month: 5, day: 22, hour: 19, minute: 0))
        
        let viewModel = EventViewModel(event: event, now: now)
        
        XCTAssertTrue(viewModel.isActive)
    }
    
    func testEventListItemRelativeTextUsesInjectedProvider() {
        let provider = TestCurrentDateProvider(
            now: makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 0)
        )
        let viewModel = EventListItemViewModel(
            title: "Debug Clock Test",
            startDate: makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 30),
            scheduleDisplayMode: .dateTime,
            currentDateProvider: provider
        )
        
        XCTAssertFalse(viewModel.relativeStartText.isEmpty)
        XCTAssertEqual(viewModel.timeDisplayMode, .relative)
        
        provider.now = makeDate(year: 2026, month: 5, day: 22, hour: 18, minute: 45)
        
        XCTAssertEqual(viewModel.timeDisplayMode, .live)
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
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        
        return components.date ?? Date()
    }
    
}

private final class TestCurrentDateProvider: CurrentDateProviding {
    
    private let subject: CurrentValueSubject<Date, Never>
    
    var now: Date {
        didSet {
            subject.send(now)
        }
    }
    
    var dateDidChange: AnyPublisher<Date, Never> {
        subject.eraseToAnyPublisher()
    }
    
    init(now: Date) {
        self.now = now
        self.subject = CurrentValueSubject(now)
    }
    
}
