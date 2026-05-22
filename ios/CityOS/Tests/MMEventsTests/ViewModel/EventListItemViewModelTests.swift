//
//  EventListItemViewModelTests.swift
//
//
//  Created by Codex on 22.05.26.
//

import Foundation
import XCTest
@testable import MMEvents

@MainActor
final class EventListItemViewModelTests: XCTestCase {

    func testTimeDisplayModeUsesProvidedNow() {
        let startDate = makeDate(hour: 12)
        let viewModel = EventListItemViewModel(
            title: "Boundary Event",
            startDate: startDate,
            endDate: makeDate(hour: 13),
            scheduleDisplayMode: .dateTime
        )

        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate.addingTimeInterval(-60 * 60 - 1)), .range)
        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate.addingTimeInterval(-60 * 60)), .relative)
    }

    func testTimeDisplayModeTransitionsFromRelativeToLiveWithoutEventMutation() {
        let startDate = makeDate(hour: 12)
        let endDate = makeDate(hour: 13)
        let viewModel = EventListItemViewModel(
            title: "Starting Event",
            startDate: startDate,
            endDate: endDate,
            scheduleDisplayMode: .dateTime
        )

        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate.addingTimeInterval(-1)), .relative)
        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate), .live)
    }

    func testTimeDisplayModeTransitionsFromLiveToRangeAfterEndWithoutEventMutation() {
        let startDate = makeDate(hour: 12)
        let endDate = makeDate(hour: 13)
        let viewModel = EventListItemViewModel(
            title: "Ending Event",
            startDate: startDate,
            endDate: endDate,
            scheduleDisplayMode: .dateTime
        )

        XCTAssertEqual(viewModel.timeDisplayMode(at: endDate.addingTimeInterval(-1)), .live)
        XCTAssertEqual(viewModel.timeDisplayMode(at: endDate), .range)
    }

    func testTimeDisplayModeUsesDefaultEndForEqualEndDateWithoutEventMutation() {
        let startDate = makeDate(hour: 12)
        let defaultEndDate = startDate.addingTimeInterval(EventUtilities.defaultTimeInterval)
        let viewModel = EventListItemViewModel(
            title: "Default Duration Event",
            startDate: startDate,
            endDate: startDate,
            scheduleDisplayMode: .dateTime
        )

        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate.addingTimeInterval(-1)), .relative)
        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate), .live)
        XCTAssertEqual(viewModel.timeDisplayMode(at: defaultEndDate.addingTimeInterval(-1)), .live)
        XCTAssertEqual(viewModel.timeDisplayMode(at: defaultEndDate), .range)
    }

    func testTimeDisplayModeUsesDefaultEndForEndDateBeforeStartWithoutEventMutation() {
        let startDate = makeDate(hour: 12)
        let defaultEndDate = startDate.addingTimeInterval(EventUtilities.defaultTimeInterval)
        let viewModel = EventListItemViewModel(
            title: "Invalid End Event",
            startDate: startDate,
            endDate: startDate.addingTimeInterval(-1),
            scheduleDisplayMode: .dateTime
        )

        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate), .live)
        XCTAssertEqual(viewModel.timeDisplayMode(at: defaultEndDate.addingTimeInterval(-1)), .live)
        XCTAssertEqual(viewModel.timeDisplayMode(at: defaultEndDate), .range)
    }

    func testHiddenScheduleDoesNotBecomeRelativeOrLive() {
        let startDate = makeDate(hour: 12)
        let viewModel = EventListItemViewModel(
            title: "Hidden Event",
            startDate: startDate,
            endDate: makeDate(hour: 13),
            scheduleDisplayMode: .hidden
        )

        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate.addingTimeInterval(-1)), .none)
        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate), .none)
    }

    func testDateOnlyScheduleDoesNotBecomeRelativeOrLive() {
        let startDate = makeDate(hour: 12)
        let viewModel = EventListItemViewModel(
            title: "Date Only Event",
            startDate: startDate,
            endDate: makeDate(hour: 13),
            scheduleDisplayMode: .date
        )

        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate.addingTimeInterval(-1)), .date)
        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate), .date)
        XCTAssertEqual(viewModel.timeDisplayMode(at: makeDate(hour: 14)), .date)
    }

    func testDateRangeIsNilForDateOnlySchedule() {
        let viewModel = EventListItemViewModel(
            title: "Date Only Event",
            startDate: makeDate(hour: 12),
            endDate: makeDate(hour: 13),
            scheduleDisplayMode: .date
        )

        XCTAssertNil(viewModel.dateRange)
    }

    func testOpenEndOnlyHidesDateRangeAndDoesNotChangeLiveDuration() {
        let startDate = makeDate(hour: 12)
        let endDate = makeDate(hour: 13)
        let viewModel = EventListItemViewModel(
            title: "Open End Event",
            startDate: startDate,
            endDate: endDate,
            isOpenEnd: true,
            scheduleDisplayMode: .dateTime
        )

        XCTAssertNil(viewModel.dateRange)
        XCTAssertEqual(viewModel.timeDisplayMode(at: startDate), .live)
        XCTAssertEqual(viewModel.timeDisplayMode(at: endDate.addingTimeInterval(-1)), .live)
        XCTAssertEqual(viewModel.timeDisplayMode(at: endDate), .range)
    }

    func testScheduleComponentFlagsMirrorDisplayMode() {
        let hiddenViewModel = EventListItemViewModel(
            title: "Hidden Event",
            startDate: makeDate(hour: 12),
            scheduleDisplayMode: .hidden
        )
        let dateOnlyViewModel = EventListItemViewModel(
            title: "Date Event",
            startDate: makeDate(hour: 12),
            scheduleDisplayMode: .date
        )
        let dateTimeViewModel = EventListItemViewModel(
            title: "Date Time Event",
            startDate: makeDate(hour: 12),
            scheduleDisplayMode: .dateTime
        )

        XCTAssertFalse(hiddenViewModel.showsDateComponent)
        XCTAssertFalse(hiddenViewModel.showsTimeComponent)
        XCTAssertTrue(dateOnlyViewModel.showsDateComponent)
        XCTAssertFalse(dateOnlyViewModel.showsTimeComponent)
        XCTAssertTrue(dateTimeViewModel.showsDateComponent)
        XCTAssertTrue(dateTimeViewModel.showsTimeComponent)
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
