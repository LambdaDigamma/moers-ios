//
//  EventUtilitiesTests.swift
//
//
//  Created by Codex on 22.05.26.
//

import Foundation
import XCTest
@testable import MMEvents

@MainActor
final class EventUtilitiesTests: XCTestCase {

    func testIsActiveUsesHalfOpenExplicitEnd() async {
        let startDate = makeDate(hour: 12)
        let endDate = makeDate(hour: 13)

        XCTAssertTrue(EventUtilities.isActive(startDate: startDate, endDate: endDate, now: startDate))
        XCTAssertTrue(EventUtilities.isActive(startDate: startDate, endDate: endDate, now: endDate.addingTimeInterval(-1)))
        XCTAssertFalse(EventUtilities.isActive(startDate: startDate, endDate: endDate, now: endDate))
    }

    func testIsActiveUsesDefaultThirtyMinuteEndWhenEndDateIsNil() async {
        let startDate = makeDate(hour: 12)
        let defaultEndDate = startDate.addingTimeInterval(EventUtilities.defaultTimeInterval)

        XCTAssertTrue(EventUtilities.isActive(startDate: startDate, endDate: nil, now: startDate))
        XCTAssertTrue(EventUtilities.isActive(startDate: startDate, endDate: nil, now: defaultEndDate.addingTimeInterval(-1)))
        XCTAssertFalse(EventUtilities.isActive(startDate: startDate, endDate: nil, now: defaultEndDate))
    }

    func testIsActiveUsesDefaultThirtyMinuteEndWhenEndDateIsEqualOrBeforeStart() async {
        let startDate = makeDate(hour: 12)
        let defaultEndDate = startDate.addingTimeInterval(EventUtilities.defaultTimeInterval)

        XCTAssertTrue(EventUtilities.isActive(startDate: startDate, endDate: startDate, now: defaultEndDate.addingTimeInterval(-1)))
        XCTAssertFalse(EventUtilities.isActive(startDate: startDate, endDate: startDate, now: defaultEndDate))
        XCTAssertTrue(EventUtilities.isActive(startDate: startDate, endDate: startDate.addingTimeInterval(-1), now: defaultEndDate.addingTimeInterval(-1)))
        XCTAssertFalse(EventUtilities.isActive(startDate: startDate, endDate: startDate.addingTimeInterval(-1), now: defaultEndDate))
    }

    func testIsActiveReturnsFalseAfterExplicitEnd() async {
        let startDate = makeDate(hour: 12)
        let endDate = makeDate(hour: 13)

        XCTAssertFalse(
            EventUtilities.isActive(
                startDate: startDate,
                endDate: endDate,
                now: endDate.addingTimeInterval(1)
            )
        )
    }

    func testTimeDisplayModeReturnsRangeMoreThanOneHourBeforeStart() async {
        let startDate = makeDate(hour: 12)

        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .dateTime,
                now: startDate.addingTimeInterval(-60 * 60 - 1)
            ),
            .range
        )
    }

    func testTimeDisplayModeReturnsRelativeWithinOneHourBeforeStart() async {
        let startDate = makeDate(hour: 12)

        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .dateTime,
                now: startDate.addingTimeInterval(-60 * 60)
            ),
            .relative
        )
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .dateTime,
                now: startDate.addingTimeInterval(-1)
            ),
            .relative
        )
    }

    func testTimeDisplayModeReturnsLiveAtStartAndUntilBeforeEnd() async {
        let startDate = makeDate(hour: 12)
        let endDate = makeDate(hour: 13)

        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: endDate,
                scheduleDisplayMode: .dateTime,
                now: startDate
            ),
            .live
        )
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: endDate,
                scheduleDisplayMode: .dateTime,
                now: endDate.addingTimeInterval(-1)
            ),
            .live
        )
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: endDate,
                scheduleDisplayMode: .dateTime,
                now: endDate
            ),
            .range
        )
    }

    func testTimeDisplayModeUsesDefaultThirtyMinuteEndWhenEndDateIsNil() async {
        let startDate = makeDate(hour: 12)
        let defaultEndDate = startDate.addingTimeInterval(EventUtilities.defaultTimeInterval)

        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: nil,
                scheduleDisplayMode: .dateTime,
                now: defaultEndDate.addingTimeInterval(-1)
            ),
            .live
        )
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: nil,
                scheduleDisplayMode: .dateTime,
                now: defaultEndDate
            ),
            .range
        )
    }

    func testTimeDisplayModeUsesDefaultThirtyMinuteEndWhenExplicitEndIsEqualOrBeforeStart() async {
        let startDate = makeDate(hour: 12)
        let defaultEndDate = startDate.addingTimeInterval(EventUtilities.defaultTimeInterval)

        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: startDate,
                scheduleDisplayMode: .dateTime,
                now: defaultEndDate.addingTimeInterval(-1)
            ),
            .live
        )
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: startDate.addingTimeInterval(-1),
                scheduleDisplayMode: .dateTime,
                now: defaultEndDate
            ),
            .range
        )
    }

    func testTimeDisplayModeReturnsRangeAfterEnd() async {
        let startDate = makeDate(hour: 12)
        let endDate = makeDate(hour: 13)

        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: endDate,
                scheduleDisplayMode: .dateTime,
                now: endDate.addingTimeInterval(1)
            ),
            .range
        )
    }

    func testTimeDisplayModeReturnsDateForDateOnlySchedule() async {
        let startDate = makeDate(hour: 12)

        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: nil,
                scheduleDisplayMode: .date,
                now: startDate
            ),
            .date
        )
    }

    func testTimeDisplayModeKeepsDateOnlyScheduleStaticAcrossNow() async {
        let startDate = makeDate(hour: 12)

        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .date,
                now: startDate.addingTimeInterval(-1)
            ),
            .date
        )
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .date,
                now: startDate
            ),
            .date
        )
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .date,
                now: makeDate(hour: 14)
            ),
            .date
        )
    }

    func testTimeDisplayModeReturnsNoneWhenStartDateIsMissing() async {
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: nil,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .dateTime,
                now: makeDate(hour: 12)
            ),
            .none
        )
        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: nil,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .date,
                now: makeDate(hour: 12)
            ),
            .none
        )
    }

    func testTimeDisplayModeReturnsNoneForHiddenSchedule() async {
        let startDate = makeDate(hour: 12)

        XCTAssertEqual(
            EventUtilities.timeDisplayMode(
                startDate: startDate,
                endDate: makeDate(hour: 13),
                scheduleDisplayMode: .hidden,
                now: startDate
            ),
            .none
        )
    }

    func testDateRangeUsesDefaultEndWhenEndIsNilOrBeforeStart() async {
        let startDate = makeDate(hour: 12)
        let defaultEndDate = startDate.addingTimeInterval(EventUtilities.defaultTimeInterval)

        XCTAssertEqual(EventUtilities.dateRange(startDate: startDate, endDate: nil), startDate...defaultEndDate)
        XCTAssertEqual(EventUtilities.dateRange(startDate: startDate, endDate: startDate), startDate...defaultEndDate)
        XCTAssertEqual(
            EventUtilities.dateRange(startDate: startDate, endDate: startDate.addingTimeInterval(-1)),
            startDate...defaultEndDate
        )
    }

    func testRelativeTimeTextUsesProvidedNow() async {
        let startDate = makeDate(hour: 12)

        let fifteenMinutesBefore = EventUtilities.relativeTimeText(
            startDate: startDate,
            now: startDate.addingTimeInterval(-15 * 60)
        )
        let sevenMinutesBefore = EventUtilities.relativeTimeText(
            startDate: startDate,
            now: startDate.addingTimeInterval(-7 * 60)
        )

        XCTAssertNotEqual(fifteenMinutesBefore, sevenMinutesBefore)
    }

    func testRemainingCountdownMinutesRoundsUpToNextMinute() async {
        let startDate = makeDate(hour: 15)

        XCTAssertEqual(
            EventUtilities.remainingCountdownMinutes(
                startDate: startDate,
                now: makeDate(hour: 14, minute: 11)
            ),
            49
        )
        XCTAssertEqual(
            EventUtilities.remainingCountdownMinutes(
                startDate: startDate,
                now: makeDate(hour: 14, minute: 11).addingTimeInterval(30)
            ),
            49
        )
        XCTAssertEqual(
            EventUtilities.remainingCountdownMinutes(
                startDate: startDate,
                now: makeDate(hour: 14, minute: 11).addingTimeInterval(59)
            ),
            49
        )
        XCTAssertEqual(
            EventUtilities.remainingCountdownMinutes(
                startDate: startDate,
                now: makeDate(hour: 14, minute: 12)
            ),
            48
        )
    }

    func testRemainingCountdownMinutesReturnsNilAtOrAfterStart() async {
        let startDate = makeDate(hour: 15)

        XCTAssertNil(EventUtilities.remainingCountdownMinutes(startDate: startDate, now: startDate))
        XCTAssertNil(
            EventUtilities.remainingCountdownMinutes(
                startDate: startDate,
                now: startDate.addingTimeInterval(1)
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
