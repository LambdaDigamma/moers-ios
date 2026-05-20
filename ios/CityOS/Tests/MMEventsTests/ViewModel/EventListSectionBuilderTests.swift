//
//  EventListSectionBuilderTests.swift
//
//
//  Created by Codex on 20.05.26.
//

import Foundation
import XCTest
@testable import MMEvents

@MainActor
final class EventListSectionBuilderTests: XCTestCase {

    func testSectionsAssignRowsToEffectiveFestivalDayUsingSixHourBoundary() {

        let calendar = makeCalendar()
        let builder = EventListSectionBuilder(calendar: calendar)
        let lateNight = makeRow(
            id: 1,
            startDate: makeDate(year: 2030, month: 5, day: 17, hour: 23, minute: 30, calendar: calendar)
        )
        let earlyMorning = makeRow(
            id: 2,
            startDate: makeDate(year: 2030, month: 5, day: 18, hour: 5, minute: 59, calendar: calendar)
        )
        let boundary = makeRow(
            id: 3,
            startDate: makeDate(year: 2030, month: 5, day: 18, hour: 6, minute: 0, calendar: calendar)
        )

        let sections = builder.sections(for: [
            lateNight,
            earlyMorning,
            boundary
        ])

        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections.compactMap(\.effectiveDay), [
            makeDate(year: 2030, month: 5, day: 17, calendar: calendar),
            makeDate(year: 2030, month: 5, day: 18, calendar: calendar)
        ])
        XCTAssertEqual(sections.map { $0.events.compactMap(\.eventID) }, [[1, 2], [3]])
    }

    func testSectionsAppendUndatedRowsAsFinalSection() {

        let calendar = makeCalendar()
        let builder = EventListSectionBuilder(calendar: calendar)
        let undatedFirst = makeRow(id: 1, startDate: nil)
        let secondDay = makeRow(
            id: 2,
            startDate: makeDate(year: 2030, month: 5, day: 18, hour: 12, calendar: calendar)
        )
        let undatedSecond = makeRow(id: 3, startDate: nil)
        let firstDay = makeRow(
            id: 4,
            startDate: makeDate(year: 2030, month: 5, day: 17, hour: 12, calendar: calendar)
        )

        let sections = builder.sections(for: [
            undatedFirst,
            secondDay,
            undatedSecond,
            firstDay
        ])

        guard sections.count == 3 else {
            XCTFail("Expected three sections, got \(sections.count)")
            return
        }

        XCTAssertEqual(sections[0].effectiveDay, makeDate(year: 2030, month: 5, day: 17, calendar: calendar))
        XCTAssertEqual(sections[1].effectiveDay, makeDate(year: 2030, month: 5, day: 18, calendar: calendar))
        XCTAssertNil(sections[2].effectiveDay)
        XCTAssertEqual(sections.last?.title, EventPackageStrings.notYetScheduled)
        XCTAssertEqual(sections.map { $0.events.compactMap(\.eventID) }, [[4], [2], [1, 3]])
    }

    func testSectionsPreserveIncomingRowOrderWithinDay() {

        let calendar = makeCalendar()
        let builder = EventListSectionBuilder(calendar: calendar)
        let first = makeRow(
            id: 1,
            startDate: makeDate(year: 2030, month: 5, day: 18, hour: 5, minute: 30, calendar: calendar)
        )
        let second = makeRow(
            id: 2,
            startDate: makeDate(year: 2030, month: 5, day: 17, hour: 23, calendar: calendar)
        )
        let third = makeRow(
            id: 3,
            startDate: makeDate(year: 2030, month: 5, day: 17, hour: 12, calendar: calendar)
        )

        let sections = builder.sections(for: [
            first,
            second,
            third
        ])

        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections.first?.events.compactMap(\.eventID), [1, 2, 3])
    }

    private func makeRow(
        id: Event.ID,
        startDate: Date?
    ) -> EventListItemViewModel {
        EventListItemViewModel(
            eventID: id,
            title: "Event \(id)",
            startDate: startDate
        )
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        calendar: Calendar
    ) -> Date {

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute

        return components.date ?? Date()
    }

}
