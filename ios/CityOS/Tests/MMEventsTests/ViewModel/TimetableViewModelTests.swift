//
//  TimetableViewModelTests.swift
//  
//
//  Created by Codex on 16.03.26.
//

import Foundation
import XCTest
import Factory
import Combine
@testable import MMEvents

@MainActor
final class TimetableViewModelTests: XCTestCase {
    
    override func tearDown() {
        Container.shared.eventRepository.reset()
        super.tearDown()
    }
    
    func testSelectionIsPreservedAcrossEventUpdates() async throws {
        
        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(
            store: store,
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )
        
        Container.shared.eventRepository.register { repository }
        
        let firstDay = makeDate(year: 2030, month: 5, day: 17, hour: 12)
        let secondDay = makeDate(year: 2030, month: 5, day: 18, hour: 12)
        let selectedDay = Calendar.autoupdatingCurrent.startOfDay(for: secondDay)
        
        let viewModel = TimetableViewModel()
        let secondUpdateApplied = expectation(description: "Second timetable update applied")
        var updateCount = 0
        let datesCancellable = viewModel
            .$dates
            .dropFirst()
            .sink { _ in
                updateCount += 1
                if updateCount == 2 {
                    secondUpdateApplied.fulfill()
                }
            }
        
        let firstUpdateApplied = expectation(description: "First timetable update applied")
        let firstUpdateCancellable = viewModel.$dates
            .filter { $0.count == 2 }
            .first()
            .sink { _ in firstUpdateApplied.fulfill() }

        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.startDate, to: secondDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 1, hour: 12))
                .toRecord()
        ])

        await fulfillment(of: [firstUpdateApplied], timeout: 1)
        firstUpdateCancellable.cancel()

        viewModel.selectedDate = selectedDay
        
        try await store.deleteAllAndInsert([
            Event.stub(withID: 1)
                .setting(\.startDate, to: firstDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 2, hour: 12))
                .toRecord(),
            Event.stub(withID: 2)
                .setting(\.startDate, to: secondDay)
                .setting(\.updatedAt, to: makeDate(year: 2030, month: 5, day: 2, hour: 12))
                .toRecord()
        ])
        
        await fulfillment(of: [secondUpdateApplied], timeout: 1)
        datesCancellable.cancel()
        
        XCTAssertEqual(viewModel.selectedDate, selectedDay)
    }
    
    private func makeDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        
        return components.date ?? Date()
    }
    
}
