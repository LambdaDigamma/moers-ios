import Foundation
import Events
import XCTest
@testable import Moers

@MainActor
final class EventFilterTests: XCTestCase {
    func testOnlineFilterUsesOnlineFlagAndKeepsHybridSeparate() async {
        var filter = Moers.EventFilter()
        filter.attendanceModes = ["online"]
        XCTAssertTrue(filter.matches(Event(id: 1, name: "Online", attendanceMode: "offline", isOnline: true)))
        XCTAssertFalse(filter.matches(Event(id: 2, name: "Hybrid", attendanceMode: "mixed", isOnline: true)))
        XCTAssertFalse(filter.matches(Event(id: 3, name: "Unknown")))
        let options = EventFilterOptions(events: [Event(id: 1, name: "Online", attendanceMode: "offline", isOnline: true)])
        XCTAssertEqual(options.attendanceModes, ["online"])
    }

    func testFreeFilterRequiresExplicitPriceStatus() async {
        var filter = Moers.EventFilter()
        filter.onlyFree = true
        XCTAssertTrue(filter.matches(Event(id: 1, name: "Free", extras: EventExtras(isFree: true))))
        XCTAssertFalse(filter.matches(Event(id: 2, name: "Paid", extras: EventExtras(isFree: false))))
        XCTAssertFalse(filter.matches(Event(id: 3, name: "Unknown", subtitle: "Free event")))
        XCTAssertFalse(EventFilterOptions(events: [Event(id: 3, name: "Unknown")]).supportsFreeFilter)
        XCTAssertTrue(EventFilterOptions(events: [Event(id: 2, name: "Paid", extras: EventExtras(isFree: false))]).supportsFreeFilter)
    }

    func testTodayAndTomorrowUseTheSuppliedClockAcrossMidnight() async throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "Europe/Berlin"))
        let clock = try date("2026-10-05T21:59:00Z")
        let afterMidnight = try date("2026-10-05T22:01:00Z")
        let event = Event(id: 1, name: "Event", startDate: try date("2026-10-05T22:30:00Z"))
        var filter = Moers.EventFilter()
        filter.dateScope = .today
        XCTAssertFalse(filter.matches(event, calendar: calendar, now: clock))
        XCTAssertTrue(filter.matches(event, calendar: calendar, now: afterMidnight))
        filter.dateScope = .tomorrow
        XCTAssertTrue(filter.matches(event, calendar: calendar, now: clock))
        XCTAssertFalse(filter.matches(event, calendar: calendar, now: afterMidnight))
    }

    func testAnEventEndingAtMidnightDoesNotOverlapTheNextDay() async throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let midnight = try date("2026-10-06T00:00:00Z")
        let event = Event(id: 1, name: "Ended", startDate: try date("2026-10-05T20:00:00Z"), endDate: midnight)
        XCTAssertFalse(EventFormatter.overlapsToday(event, calendar: calendar, now: midnight))
    }

    func testLocationFilterUsesTheSameAddressAsPresentation() async {
        let event = Event(id: 1, name: "Event", extras: EventExtras(location: "Library", place: "Moers"))
        var filter = Moers.EventFilter()
        filter.venues = ["Library, Moers"]
        XCTAssertTrue(filter.matches(event))
    }

    private func date(_ value: String) throws -> Date {
        try XCTUnwrap(ISO8601DateFormatter().date(from: value))
    }
}
