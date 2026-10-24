import Foundation
import XCTest
@testable import Events

final class EventRecordMappingTests: XCTestCase {
    func testFestivalRecordRetainsLifecycleAndDisplayMetadata() throws {
        let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-10-07T19:15:00Z"))
        let event = Event(id: 42, name: "Festival", description: "Details", url: "https://example.com", startDate: date, endDate: date,
                          category: "Concert", extras: EventExtras(location: "Venue", needsFestivalTicket: true), artists: ["Artist"],
                          pageID: 7, placeID: 9, createdAt: date, updatedAt: date, publishedAt: date, cancelledAt: date, archivedAt: date, deletedAt: date)
        let restored = event.toRecord().toBase()
        XCTAssertEqual(restored.id, 42)
        XCTAssertEqual(restored.description, "Details")
        XCTAssertEqual(restored.url, event.url)
        XCTAssertEqual(restored.startDate, date)
        XCTAssertEqual(restored.endDate, date)
        XCTAssertEqual(restored.extras, event.extras)
        XCTAssertEqual(restored.artists?.compactMap { $0 }, ["Artist"])
        XCTAssertEqual(restored.pageID, 7)
        XCTAssertEqual(restored.placeID, 9)
        XCTAssertEqual(restored.cancelledAt, date)
        XCTAssertEqual(restored.archivedAt, date)
        XCTAssertEqual(restored.deletedAt, date)
    }
}
