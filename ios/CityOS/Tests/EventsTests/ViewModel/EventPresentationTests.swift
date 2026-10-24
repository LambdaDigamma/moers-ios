import Foundation
import XCTest
@testable import Events

final class EventPresentationTests: XCTestCase {
    func testAddressDoesNotRepeatItsCity() {
        let event = Event(id: 1, name: "Event", extras: EventExtras(location: "Wilhelm-Schroeder-Straße 10, 47441 Moers", place: "Moers"))
        XCTAssertEqual(EventPresentation.location(for: event), "Wilhelm-Schroeder-Straße 10, 47441 Moers")
    }

    func testLocationIncludesCityWhenMissing() {
        let event = Event(id: 1, name: "Event", extras: EventExtras(location: "Library", place: "Moers"))
        XCTAssertEqual(EventPresentation.location(for: event), "Library, Moers")
    }

    func testRepeatedOpeningTeaserIsNotShownTwice() {
        let event = Event(id: 1, name: "Event", description: "<p>A concert in Moers.</p><p>More information.</p>", teaser: "A concert in Moers.")
        XCTAssertNil(EventPresentation.editorialSubtitle(for: event))
    }

    func testDistinctEditorialSubtitleIsRetained() {
        let event = Event(id: 1, name: "Event", description: "Details", teaser: "Opening act", subtitle: "Anniversary concert")
        XCTAssertEqual(EventPresentation.editorialSubtitle(for: event), "Anniversary concert")
    }

    func testOnlineFlagOverridesOfflineButKeepsHybrid() {
        XCTAssertEqual(Event(id: 1, name: "Event", attendanceMode: "offline", isOnline: true).resolvedAttendanceMode, "online")
        XCTAssertEqual(Event(id: 1, name: "Event", attendanceMode: "mixed", isOnline: true).resolvedAttendanceMode, "mixed")
        XCTAssertEqual(Event(id: 1, name: "Event", attendanceMode: "online").resolvedAttendanceMode, "online")
        XCTAssertNil(Event(id: 1, name: "Event").resolvedAttendanceMode)
    }

    func testDateAndTimeFollowTheRequestedLocale() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-10-07T19:15:00Z"))
        let event = Event(id: 1, name: "Event", startDate: date)
        let english = try XCTUnwrap(EventPresentation.dateRange(for: event, calendar: calendar, locale: Locale(identifier: "en_US")))
        let german = try XCTUnwrap(EventPresentation.dateRange(for: event, calendar: calendar, locale: Locale(identifier: "de_DE")))
        XCTAssertTrue(english.contains("7:15"), english)
        XCTAssertTrue(english.contains("PM"), english)
        XCTAssertTrue(german.contains("19:15"), german)
        XCTAssertNotEqual(english, german)
    }
}
