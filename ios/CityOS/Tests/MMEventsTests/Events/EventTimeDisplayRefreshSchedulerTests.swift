//
//  EventTimeDisplayRefreshSchedulerTests.swift
//
//
//  Created by Codex on 22.05.26.
//

import Foundation
import XCTest
@testable import MMEvents

final class EventTimeDisplayRefreshSchedulerTests: XCTestCase {

    func testReturnsNilForSchedulesThatDoNotNeedLiveRefreshes() {
        let startDate = makeDate(hour: 12)

        XCTAssertNil(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .hidden,
                after: startDate
            )
        )
        XCTAssertNil(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .date,
                after: startDate
            )
        )
        XCTAssertNil(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: nil,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .dateTime,
                after: startDate
            )
        )
    }

    func testReturnsRelativeWindowStartWhenMoreThanOneHourBeforeStart() {
        let startDate = makeDate(hour: 12)

        XCTAssertEqual(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .dateTime,
                after: startDate.addingTimeInterval(-2 * 60 * 60)
            ),
            startDate.addingTimeInterval(-60 * 60)
        )
    }

    func testReturnsNextMinuteWithinRelativeWindow() {
        let startDate = makeDate(hour: 12)
        let now = makeDate(hour: 11, minute: 10).addingTimeInterval(20)
        let nextMinute = makeDate(hour: 11, minute: 11)

        XCTAssertEqual(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .dateTime,
                after: now
            ),
            nextMinute
        )
    }

    func testReturnsNextMinuteAtRelativeWindowStart() {
        let startDate = makeDate(hour: 12)
        let relativeStartDate = startDate.addingTimeInterval(-60 * 60)

        XCTAssertEqual(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .dateTime,
                after: relativeStartDate
            ),
            makeDate(hour: 11, minute: 1)
        )
    }

    func testCapsRelativeRefreshAtStartDate() {
        let startDate = makeDate(hour: 12)
        let now = makeDate(hour: 11, minute: 59).addingTimeInterval(30)

        XCTAssertEqual(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .dateTime,
                after: now
            ),
            startDate
        )
    }

    func testReturnsExplicitEndDateDuringLiveInterval() {
        let startDate = makeDate(hour: 12)
        let endDate = makeDate(hour: 13)

        XCTAssertEqual(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: endDate,
                scheduleDisplayMode: .dateTime,
                after: startDate
            ),
            endDate
        )
        XCTAssertEqual(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: endDate,
                scheduleDisplayMode: .dateTime,
                after: endDate.addingTimeInterval(-1)
            ),
            endDate
        )
    }

    func testUsesDefaultEndDateWhenEndDateIsNilEqualOrBeforeStart() {
        let startDate = makeDate(hour: 12)
        let defaultEndDate = startDate.addingTimeInterval(EventUtilities.defaultTimeInterval)

        XCTAssertEqual(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: nil,
                scheduleDisplayMode: .dateTime,
                after: startDate
            ),
            defaultEndDate
        )
        XCTAssertEqual(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: startDate,
                scheduleDisplayMode: .dateTime,
                after: startDate
            ),
            defaultEndDate
        )
        XCTAssertEqual(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: startDate.addingTimeInterval(-1),
                scheduleDisplayMode: .dateTime,
                after: startDate
            ),
            defaultEndDate
        )
    }

    func testReturnsNilAtAndAfterEffectiveEndDate() {
        let startDate = makeDate(hour: 12)
        let endDate = makeDate(hour: 13)

        XCTAssertNil(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: endDate,
                scheduleDisplayMode: .dateTime,
                after: endDate
            )
        )
        XCTAssertNil(
            EventUtilities.nextTimeDisplayUpdateDate(
                startDate: startDate,
                endDate: endDate,
                scheduleDisplayMode: .dateTime,
                after: endDate.addingTimeInterval(1)
            )
        )
    }

    private func makeDate(
        year: Int = 2030,
        month: Int = 5,
        day: Int = 22,
        hour: Int,
        minute: Int = 0
    ) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

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
